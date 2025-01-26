import Decode :: *;
import Utils :: *;
import Fifo :: *;
import OOO :: *;
import Ehr :: *;
import CSR :: *;

import Vector :: *;

function Bit#(32) getIssuePc(IssueQueueEntry entry);
  return entry.pc;
endfunction

function Epoch getIssueEpoch(IssueQueueEntry entry);
  return entry.epoch;
endfunction

typedef enum {
  Word, Half, Byte
} Size deriving(Bits, FShow, Eq);

typedef struct {
  // If false, then the store-queue must return
  // a STORE_AMO_ADDRESS_MISALIGNED exception
  Bool aligned;

  // Program counter of the store operation
  Bit#(32) pc;

  // Word-aligned address if `aligned` is true,
  // the raw address overwise
  Bit#(32) addr;

  // Word aligned data of the write operation,
  // to allow a trivial transformation to AXI4
  Bit#(32) data;

  // Word aligned mask of the write operation,
  // to allow a trivial transformation to AXI4
  Bit#(4) mask;

  // Epoch of the operation, a store can only forward
  // it's data to a load of the same epoch
  Epoch epoch;

  // Age of the operation, a store can only forward
  // it's data to a younger load
  Age age;
} StoreQueueEntry deriving(Bits, FShow, Eq);

// Addresses, data, and masks follow the AXI4-lite strict alignment conventions:
// addresses are 32 bits aligned, and data,masks use the AXI4-lite alignement
// conventions

// return the word aligned address of a memory operation
function Maybe#(Bit#(32)) getIssueAddr(IssueQueueEntry entry);
  case (entry.rs1_val) matches
    tagged Value .v : begin
      Bit#(30) aligned = truncateLSB(v + immediateBits(entry.instr));
      return Valid({aligned,2'b0});
    end
    default: return Invalid;
  endcase
endfunction

// return the offset in a word of a memory operation
function Bit#(2) getIssueOffset(IssueQueueEntry entry);
  return case (entry.rs1_val) matches
    tagged Value .v : truncate(v+immediateBits(entry.instr));
    default: ?;
  endcase;
endfunction

// return the data of an IssueQueueEntry
function Maybe#(Bit#(32)) getIssueData(IssueQueueEntry entry);
  case (tuple2(entry.rs1_val, entry.rs2_val)) matches
    Tuple2{fst: tagged Value .rs1, snd: tagged Value .rs2} : begin
      Bit#(5) offset = {getIssueOffset(entry), 3'b0};
      return Valid(rs2 << offset);
    end
    default: return Invalid;
  endcase
endfunction

// return the size of a load or store operation
function Size getIssueSize(IssueQueueEntry entry);
  return case (entry.instr) matches
    tagged Itype {op: tagged Load LB} : Byte;
    tagged Itype {op: tagged Load LBU} : Byte;
    tagged Itype {op: tagged Load LH} : Half;
    tagged Itype {op: tagged Load LHU} : Half;
    tagged Itype {op: tagged Load LW} : Word;
    tagged Stype {op: SB} : Byte;
    tagged Stype {op: SH} : Half;
    tagged Stype {op: SW} : Word;
    default: ?;
  endcase;
endfunction

function Maybe#(Bit#(4)) getIssueMask(IssueQueueEntry entry);
  case (getIssueAddr(entry)) matches
    tagged Valid .addr :
      case (getIssueSize(entry)) matches
        Half : return Valid(4'b0011 << addr[1:0]);
        Byte : return Valid(4'b0001 << addr[0]);
        Word : return Valid(4'b1111);
      endcase
    Invalid : return Invalid;
  endcase
endfunction

function Maybe#(Bool) getIssueAligned(IssueQueueEntry entry);
  case (getIssueAddr(entry)) matches
    tagged Valid .addr :
      return Valid(case (getIssueSize(entry)) matches
        Half : addr[1:0] == 0;
        Word : addr[0] == 0;
        Byte : True;
      endcase);
    Invalid : return Invalid;
  endcase
endfunction

// return if a load is signed
function Bool isSigned(IssueQueueEntry entry);
  return case (entry.instr) matches
    tagged Itype {op: tagged Load LBU} : False;
    tagged Itype {op: tagged Load LHU} : False;
    tagged Itype {op: tagged Load LB} : True;
    tagged Itype {op: tagged Load LH} : True;
    tagged Itype {op: tagged Load LW} : True;
    default: ?;
  endcase;
endfunction

// return if an operation is a load
function Bool isIssueLoad(IssueQueueEntry entry);
  return case (entry.instr) matches
    tagged Itype {op: tagged Load .*} : True;
    default: False;
  endcase;
endfunction

// return if an operation is a store
function Bool isIssueStore(IssueQueueEntry entry);
  return case (entry.instr) matches
    tagged Stype .* : True;
    default: False;
  endcase;
endfunction

// return if an operation is a fence
function Bool isIssueFence(IssueQueueEntry entry);
  return case (entry.instr) matches
    tagged Itype {op: FENCE_I} : True;
    tagged Itype {op: FENCE} : True;
    default: False;
  endcase;
endfunction

typedef struct {
  Bool found;
  Bit#(32) data;
  Bit#(4) mask;
} StoreConflict deriving(Bits, FShow);

// Store Buffer Size
typedef 8 StbSize;

// Store Buffer Index
typedef Bit#(TLog#(StbSize)) StbIndex;

// Store Queue Size
typedef 8 SqSize;

// Load Queue Size
typedef 8 LqSize;

// Store Queue Index
typedef Bit#(TLog#(SqSize)) SqIndex;

// Load Queue Index
typedef Bit#(TLog#(LqSize)) LqIndex;

/* deq,search,empty < enq */
interface STB;
  method Action enq(Bit#(32) addr, Bit#(32) data, Bit#(4) mask);
  method StoreConflict search(Bit#(32) addr);
  method Action deq;
  method Bool empty;
endinterface

(* synthesize *)
module mkSTB(STB);
  Vector#(StbSize, Reg#(Bit#(32))) addrV <- replicateM(mkReg(?));
  Vector#(StbSize, Reg#(Bit#(32))) dataV <- replicateM(mkReg(?));
  Vector#(StbSize, Reg#(Bit#(4))) maskV <- replicateM(mkReg(?));
  Ehr#(2, Bit#(StbSize)) valid <- mkEhr(0);
  Reg#(StbIndex) head <- mkReg(0);
  Reg#(StbIndex) tail <- mkReg(0);

  function StbIndex next(StbIndex index);
    return index == fromInteger(valueOf(StbSize)-1) ? 0 : index+1;
  endfunction

  method Action enq(Bit#(32) addr, Bit#(32) data, Bit#(4) mask)
    if (valid[1][tail] == 0);
    action
      addrV[tail] <= addr;
      dataV[tail] <= data;
      maskV[tail] <= mask;
      valid[1][tail] <= 1;
      tail <= next(tail);
    endaction
  endmethod

  method StoreConflict search(Bit#(32) addr);
    Bit#(StbSize) found = ?;

    for (Integer i=0; i < valueOf(StbSize); i = i + 1) begin
      found[i] = (valid[1][i] == 1 && addrV[i] == addr) ? 1 : 0;
    end

    return case (lastOneFrom(found, head)) matches
      tagged Valid .idx :
        StoreConflict{found: True, data: dataV[idx], mask: maskV[idx]};
      Invalid : StoreConflict{found: False, data:?,mask:0};
    endcase;
  endmethod

  method Action deq() if (valid[0][head] == 1);
    action
      valid[0][head] <= 0;
      head <= next(head);
    endaction
  endmethod

  method Bool empty;
    return valid[0] == 0;
  endmethod
endmodule

interface IssueQueue;

endinterface

interface LoadQ;
  method Action enq(Epoch age, IssueQueueEntry entry);

  method ActionValue#(IssueQueueEntry) deq();

endinterface


typedef struct {
  Bit#(32) data;
  Bit#(32) addr;
  Bit#(4) mask;
} StbEntry deriving(Bits, FShow, Eq);

/* search,deq,wakeup < enq */
interface StoreQ;
  // search the youngest store `s` such that:
  // `isBefore(s.age,age) /\ epoch == s.epoch /\ s.addr == addr`
  method StoreConflict search(Bit#(32) addr, Epoch epoch, Age age);

  // enqueue a request and it's age
  method Action enq(StoreQueueEntry entry);

  // dequeue a request, return invalid if the address in not aligned
  // in this case we don't add the request to the store buffer and cache
  method ActionValue#(Maybe#(StbEntry)) deq;

  // issue and return the result of the execution of the store
  // to the CPU: check address alignment
  method ActionValue#(ExecOutput) issue;
endinterface

function t readEhr(Integer k, Ehr#(n,t) ehr);
  return ehr[k];
endfunction

function Bit#(n) vecToBit(Vector#(n,Bool) v);
  Bit#(n) result;
  for (Integer i=0; i< valueOf(n); i = i + 1) begin
    result[i] = v[i] ? 1 : 0;
  end

  return result;
endfunction

(* synthesize *)
module mkStoreQ(StoreQ);
  Vector#(SqSize, Reg#(Bit#(32))) addrV <- replicateM(mkReg(?));
  Vector#(SqSize, Reg#(Bit#(32))) dataV <- replicateM(mkReg(?));
  Vector#(SqSize, Reg#(Bit#(4))) maskV <- replicateM(mkReg(?));
  Vector#(SqSize, Reg#(Bool)) alignedV <- replicateM(mkReg(?));
  Vector#(SqSize, Reg#(Bit#(32))) pcV <- replicateM(mkReg(?));
  Vector#(SqSize, Reg#(Epoch)) epochV <- replicateM(mkReg(?));
  Vector#(SqSize, Reg#(Age)) ageV <- replicateM(mkReg(?));

  Ehr#(2, Bit#(SqSize)) toIssue <- mkEhr(0);
  Ehr#(2, Bit#(SqSize)) valid <- mkEhr(0);
  Reg#(SqIndex) head <- mkReg(0);
  Reg#(SqIndex) tail <- mkReg(0);

  function SqIndex next(SqIndex index);
    return index == fromInteger(valueOf(SqSize)-1) ? 0 : index+1;
  endfunction

  method StoreConflict search(Bit#(32) addr, Epoch epoch, Age age);
    Bit#(SqSize) mask = ?;

    for (Integer i=0; i < valueOf(SqSize); i = i + 1) begin
      Bool found =
        valid[0][i] == 1 &&
        addrV[i] == addr &&
        epoch == epochV[i] &&
        isBefore(ageV[i], age);
      mask[i] = found ? 1 : 0;
    end

    return case (lastOneFrom(mask, head)) matches
      tagged Valid .idx :
        StoreConflict{found: True, mask: maskV[idx], data: dataV[idx]};
      Invalid : StoreConflict{found: False, data: ?, mask: ?};
    endcase;
  endmethod

  method Action enq(StoreQueueEntry entry) if (valid[1][tail] == 0);
    action
      alignedV[tail] <= entry.aligned;
      epochV[tail] <= entry.epoch;
      addrV[tail] <= entry.addr;
      dataV[tail] <= entry.data;
      maskV[tail] <= entry.mask;
      ageV[tail] <= entry.age;
      pcV[tail] <= entry.pc;
      toIssue[1][tail] <= 1;
      valid[1][tail] <= 1;
      tail <= next(tail);
    endaction
  endmethod

  method ActionValue#(ExecOutput) issue()
    if (firstOneFrom(toIssue[0] & valid[0], 0) matches tagged Valid .idx);
    actionvalue
      toIssue[0][idx] <= 0;

      if (alignedV[idx])
        return tagged Ok {
          next_pc: pcV[idx]+4,
          rd_val: ?
        };
      else
        return tagged Error {
          cause: STORE_AMO_ADDRESS_MISALIGNED,
          tval: addrV[idx]
        };
    endactionvalue
  endmethod

  method ActionValue#(Maybe#(StbEntry)) deq()
    if (valid[0][head] == 1 && toIssue[0][head] == 0);
    actionvalue
      valid[0][head] <= 0;
      head <= next(head);

      if (alignedV[head])
      return Valid(StbEntry{
          addr: addrV[head],
          data: dataV[head],
          mask: maskV[head]
        });
      else
        return Invalid;
    endactionvalue
  endmethod
endmodule
