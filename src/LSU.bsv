import IssueQueue :: *;
import AXI4_Lite :: *;
import GetPut :: *;
import Decode :: *;
import Utils :: *;
import Fifo :: *;
import OOO :: *;
import Ehr :: *;
import CSR :: *;

import Vector :: *;

// Store Buffer Size
typedef 8 StbSize;

// Store Buffer Index
typedef Bit#(TLog#(StbSize)) StbIndex;

// Store Queue Size
typedef 8 SqSize;

// Load Queue Size
typedef 8 LqSize;

// Store issue queue size
typedef 4 SiqSize;

// Load issue queue size
typedef 4 LiqSize;

// Store Queue Index
typedef Bit#(TLog#(SqSize)) SqIndex;

// Load Queue Index
typedef Bit#(TLog#(LqSize)) LqIndex;

// An interface of issue queue specialized for the memory operations
interface MemIssueQueue#(numeric type size, type reqId);
  method Action enq(reqId index, RegVal val);

  method Action wakeup(RobIndex index, Bit#(32) value);

  // Issue port: the issue queue propose a value using a round-robin order
  // and the LSU call the issue method to select it
  method reqId issueId;
  method Bit#(32) issueVal;
  method Action issue();
endinterface

module mkMemIssueQueue(MemIssueQueue#(size, reqId)) provisos(Bits#(reqId, reqIdW));
  Vector#(size, Ehr#(2, RegVal)) values <- replicateM(mkEhr(?));
  Vector#(size, Reg#(reqId)) requests <- replicateM(mkReg(?));
  Ehr#(2, Bit#(size)) valid <- mkEhr(0);

  Bit#(size) rdy = 0;
  for (Integer i=0; i < valueOf(size); i = i + 1) begin
    if (values[i][0] matches tagged Value .* &&& valid[0][i] == 1)
      rdy[i] = 1;
  end

  Ehr#(2, Bit#(TLog#(size))) issueIdx <- mkEhr(0);

  rule roundRobib;
    issueIdx[0] <= issueIdx[0] + 1;
  endrule

  method Action enq(reqId index, RegVal val)
    if (firstOneFrom(~valid[1],0) matches tagged Valid .idx);
    action
      valid[1][idx] <= 1;
      requests[idx] <= index;
      values[idx][1] <= val;
    endaction
  endmethod

  method Action wakeup(RobIndex index, Bit#(32) value);
    action
      for (Integer i=0; i < valueOf(size); i = i + 1) begin
        if (values[i][0] matches tagged Wait .idx &&& idx == index)
          values[i][0] <= tagged Value value;
      end
    endaction
  endmethod

  method reqId issueId()
    if (firstOneFrom(rdy,issueIdx[1]) matches tagged Valid .idx);
    return requests[idx];
  endmethod

  method Bit#(32) issueVal()
    if (firstOneFrom(rdy,issueIdx[1]) matches tagged Valid .idx);
    return getRegValue(values[idx][0]);
  endmethod

  method Action issue()
    if (firstOneFrom(rdy,issueIdx[1]) matches tagged Valid .idx);
    action
      valid[0][idx] <= 0;
      issueIdx[1] <= idx;
    endaction
  endmethod
endmodule

(* synthesize *)
module mkStoreIssueQueue(MemIssueQueue#(SiqSize, SqIndex));
  let issueQ <- mkMemIssueQueue;
  return issueQ;
endmodule

(* synthesize *)
module mkLoadIssueQueue(MemIssueQueue#(LiqSize, LqIndex));
  let issueQ <- mkMemIssueQueue;
  return issueQ;
endmodule

typedef enum {
  Word, Half, Byte
} Size deriving(Bits, FShow, Eq);

typedef enum {
  Signed, Unsigned
} Signedness deriving(Bits, FShow, Eq);

function Size loadSize(LoadOp ltype);
  return case (ltype) matches
    LB : Byte; LBU : Byte;
    LH : Half; LHU : Half;
    LW : Word;
  endcase;
endfunction

function Signedness loadSignedness(LoadOp ltype);
  return case (ltype) matches
    LB : Signed; LBU : Unsigned;
    LH : Signed; LHU : Unsigned;
    LW : Signed;
  endcase;
endfunction

function Size storeSize(SOp ltype);
  return case (ltype) matches
    SB : Byte;
    SH : Half;
    SW : Word;
  endcase;
endfunction

typedef struct {
  // Index in the reorder buffer
  RobIndex index;

  // Program counter of the store operation
  Bit#(32) pc;

  // Epoch of the operation, a store can only forward
  // it's data to a load of the same epoch
  Epoch epoch;

  // Age of the operation, a store can only forward
  // it's data to a younger load
  Age age;

  // Size of the memory access
  Size size;

  // Offset of the memory access
  Bit#(32) offset;
} StoreQueueEntry deriving(Bits, FShow, Eq);

typedef struct {
  // Index in the reorder buffer
  RobIndex index;

  // Program counter of the load operation
  Bit#(32) pc;

  // Epoch of the operation, a load can only forward
  // data from a store of the same epoch
  Epoch epoch;

  // Age of the operation, a store can only forward
  // it's data to a younger load
  Age age;

  // Size of the memory access
  Size size;

  // Offset of the memory access
  Bit#(32) offset;

  // Return if the input operation is signed
  Signedness signedness;
} LoadQueueEntry deriving(Bits, FShow, Eq);

typedef struct {
  Bool found;
  Bit#(32) data;
  Bit#(4) mask;
} StoreConflict deriving(Bits, FShow);

typedef struct {
  Bit#(32) data;
  Bit#(32) addr;
  Bit#(4) mask;
} StbEntry deriving(Bits, FShow, Eq);

/* deq,search,empty < enq */
interface STB;
  method Action enq(StbEntry entry);
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

  method Action enq(StbEntry entry)
    if (valid[1][tail] == 0);
    action
      addrV[tail] <= entry.addr;
      dataV[tail] <= entry.data;
      maskV[tail] <= entry.mask;
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

/* search,deq,wakeup < enq */
interface StoreQ;
  // search the youngest store `s` such that:
  // `isBefore(s.age,age) /\ epoch == s.epoch /\ s.addr == addr`
  method StoreConflict search(Bit#(32) addr, Epoch epoch, Age age);

  // enqueue a request and it's age
  method ActionValue#(SqIndex) enq(StoreQueueEntry entry);

  // dequeue a request
  method ActionValue#(StbEntry) deq;

  // Add a new address
  method Action wakeupAddr(SqIndex index, Bit#(32) addr);

  // Add a new data
  method Action wakeupData(SqIndex index, Bit#(32) data);

  // issue and return the result of the execution of the store
  // to the CPU: check address alignment
  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) issue;
endinterface

(* synthesize *)
module mkStoreQ(StoreQ);
  Vector#(SqSize, Reg#(StoreQueueEntry)) entries <- replicateM(mkReg(?));

  Ehr#(2, Bit#(SqSize)) toIssue <- mkEhr(0);
  Ehr#(2, Bit#(SqSize)) valid <- mkEhr(0);
  Reg#(SqIndex) head <- mkEhr0(0);
  Reg#(SqIndex) tail <- mkEhr0(0);

  Vector#(SqSize, Reg#(Bit#(32))) addresses <- replicateM(mkEhr0(?));
  Vector#(SqSize, Reg#(Bit#(32))) datas <- replicateM(mkEhr0(?));
  Ehr#(2, Bit#(SqSize)) addrValid <- mkEhr(0);
  Ehr#(2, Bit#(SqSize)) dataValid <- mkEhr(0);

  Bit#(SqSize) rdy = toIssue[0] & addrValid[0] & valid[0] & dataValid[0];

  function SqIndex next(SqIndex index);
    return index == fromInteger(valueOf(SqSize)-1) ? 0 : index+1;
  endfunction

  method StoreConflict search(Bit#(32) addr, Epoch epoch, Age age);
    Bit#(SqSize) mask = 0;

    for (Integer i=0; i < valueOf(SqSize); i = i + 1) begin
      let entry = entries[i];

      if (valid[0][i] == 1 && addrValid[0][i] == 1 && addr[31:2] == addresses[i][31:2] &&
        entry.epoch == epoch && isBefore(entry.age, age))
        mask[i] = 1;
    end

    return case (lastOneFrom(mask, head)) matches
      tagged Valid .idx : StoreConflict{found: True,mask:0,data:?};
      Invalid : StoreConflict{found: False,mask:0,data:?};
    endcase;
  endmethod

  method ActionValue#(SqIndex) enq(StoreQueueEntry entry)
    if (valid[1][tail] == 0);
    addrValid[1][tail] <= 0;
    dataValid[1][tail] <= 0;
    entries[tail] <= entry;
    toIssue[1][tail] <= 1;
    valid[1][tail] <= 1;
    tail <= next(tail);
    return tail;
  endmethod

  method Action wakeupAddr(SqIndex index, Bit#(32) addr);
    action
      addrValid[0][index] <= 1;
      addresses[index] <= addr + entries[index].offset;
    endaction
  endmethod

  method Action wakeupData(SqIndex index, Bit#(32) data);
    action
      dataValid[0][index] <= 1;
      datas[index] <= data;
    endaction
  endmethod

  method ActionValue#(StbEntry) deq()
    if (valid[0][head] == 1);
    let addr = addresses[head];
    let entry = entries[head];
    let data = datas[head];
    valid[0][head] <= 0;
    head <= next(head);

    let mask = case (entry.size) matches
      Word : 4'b1111;
      Half : 4'b0011;
      Byte : 4'b0001;
    endcase;

    return StbEntry{
      data: data << {addr[1:0],3'b0},
      addr: {addr[31:2], 2'b0},
      mask: mask << addr[1:0]
    };
  endmethod

  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) issue()
    if (firstOneFrom(rdy, 0) matches tagged Valid .idx);
    let addr = addresses[idx];
    let entry = entries[idx];
    toIssue[0][idx] <= 0;

    let aligned = case (entry.size) matches
      Word : addr[1:0] == 0;
      Half : addr[0] == 0;
      Byte : True;
    endcase;

    if (aligned) begin
      return tuple2(entry.index, tagged Ok {
        next_pc: entry.pc + 4,
        rd_val: ?
      });
    end else begin
      return tuple2(entry.index, tagged Error {
        cause: STORE_AMO_ADDRESS_MISALIGNED,
        tval: addr
      });
    end
  endmethod
endmodule

typedef union tagged {
  struct {
    RobIndex index;
    ExecOutput result;
  } Failure; // Tell to the Reorder Buffer that the access is misaligned
  AXI4_Lite_RRequest#(32) Success; // Ask a value to the data cache
} LoadWakeup deriving(Bits, FShow, Eq);

interface LoadQ;
  method ActionValue#(LqIndex) enq(LoadQueueEntry entry);

  method Action deq;

  method ActionValue#(LoadWakeup) wakeupAddr(LqIndex index, Bit#(32) addr);

  method Maybe#(RobIndex) search(Bit#(32) addr);

  method Tuple2#(RobIndex, ExecOutput)
    issue(LqIndex index, AXI4_Lite_RResponse#(4) resp);

  // Read the age at a given index: used to lookup into the store buffers
  method Age readAge(LqIndex index);

  // Read the epoch at a given index: used to lookup into the store buffers
  method Epoch readEpoch(LqIndex index);

  // Read the offset at a given index: used to lookup into the store buffers
  method Bit#(32) readOffset(LqIndex index);
endinterface

(* synthesize *)
module mkLoadQ(LoadQ);
  Vector#(LqSize, Reg#(LoadQueueEntry)) entries <- replicateM(mkReg(?));
  Ehr#(2, Bit#(LqSize)) valid <- mkEhr(0);
  Reg#(LqIndex) head <- mkEhr0(0);
  Reg#(LqIndex) tail <- mkEhr0(0);

  Vector#(LqSize, Reg#(Bit#(32))) addresses <- replicateM(mkEhr0(?));
  Ehr#(2, Bit#(LqSize)) addrValid <- mkEhr(0);

  Bit#(LqSize) rdy = addrValid[0] & valid[0];

  function LqIndex next(LqIndex index);
    return index == fromInteger(valueOf(LqSize)-1) ? 0 : index+1;
  endfunction

  method ActionValue#(LqIndex) enq(LoadQueueEntry entry)
    if (valid[1][tail] == 0);
    addrValid[1][tail] <= 0;
    entries[tail] <= entry;
    valid[1][tail] <= 1;
    tail <= next(tail);
    return tail;
  endmethod

  method ActionValue#(LoadWakeup) wakeupAddr(LqIndex index, Bit#(32) rs1);
    let entry = entries[index];
    let addr = rs1 + entry.offset;
    addresses[index] <= addr;

    Bool aligned = case (entry.size) matches
      Word : addr[1:0] == 0;
      Half : addr[0] == 0;
      Byte : True;
    endcase;

    if (aligned) begin
      addrValid[0][index] <= 1;

      return tagged Success (AXI4_Lite_RRequest{
          addr: {addr[31:2], 2'b00}
      });
    end else begin
      return tagged Failure {
          index: entry.index,
          result:tagged Error{
            cause: LOAD_ADDRESS_MISALIGNED,
            tval: addr
          }
      };
    end
  endmethod

  method Action deq() if (valid[0][head] == 1);
    action
      valid[0][head] <= 0;
      head <= next(head);
    endaction
  endmethod

  method Maybe#(RobIndex) search(Bit#(32) addr);
    Bit#(LqSize) mask = 0;

    for (Integer i=0; i < valueOf(LqSize); i = i + 1)
      if (rdy[i] == 1 && addresses[i][31:2] == addr[31:2])
        mask[i] = 1;

    return case (firstOneFrom(mask, head)) matches
      tagged Valid .idx : Valid(entries[idx].index);
      Invalid : Invalid;
    endcase;
  endmethod

  method Tuple2#(RobIndex, ExecOutput)
    issue(LqIndex index, AXI4_Lite_RResponse#(4) resp);

    Bit#(32) rd = resp.bytes >> {addresses[index][1:0], 3'b0};
    let signedness = entries[index].signedness;

    case (entries[index].size) matches
      Byte : rd = signedness == Signed ? signExtend(rd[7:0]) : zeroExtend(rd[7:0]);
      Half : rd = signedness == Signed ? signExtend(rd[15:0]) : zeroExtend(rd[15:0]);
    endcase

    return tuple2(entries[index].index, tagged Ok {
      next_pc: entries[index].pc + 4,
      rd_val: rd
    });
  endmethod

  method Epoch readEpoch(LqIndex index);
    return entries[index].epoch;
  endmethod

  method Age readAge(LqIndex index);
    return entries[index].age;
  endmethod

  method Bit#(32) readOffset(LqIndex index);
    return entries[index].offset;
  endmethod
endmodule


interface LSU;
  // Add a new entry in the issue queue
  method Action enq(IssueQueueEntry entry);

  method Action wakeup(RobIndex index, Bit#(32) value);

  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;

  method Bool canDeq;

  // Say if we must commit the instruction with a given reorder buffer index
  method ActionValue#(CommitOutput)
    commit(RobIndex index, Bool must_commit);

  // read interface with memory
  interface RdAXI4_Lite_Master#(32, 4) rd_mem;

  // write interface with memory
  interface WrAXI4_Lite_Master#(32, 4) wr_mem;
endinterface

(* synthesize *)
module mkLSU(LSU);
  MemIssueQueue#(SiqSize, SqIndex) storeAddrIQ <- mkStoreIssueQueue;
  MemIssueQueue#(SiqSize, SqIndex) storeDataIQ <- mkStoreIssueQueue;
  MemIssueQueue#(LiqSize, LqIndex) loadIQ <- mkLoadIssueQueue;
  StoreQ storeQ <- mkStoreQ;
  LoadQ loadQ <- mkLoadQ;
  STB stb <- mkSTB;

  Fifo#(1, AXI4_Lite_RRequest#(32)) rrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_Lite_WRequest#(32, 4)) wrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_Lite_RResponse#(4)) rresponseQ <- mkPipelineFifo;
  Fifo#(1, AXI4_Lite_WResponse) wresponseQ <- mkPipelineFifo;

  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) loadFailureQ <- mkPipelineFifo;
  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) loadSuccessQ <- mkPipelineFifo;
  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) storeSuccessQ <- mkPipelineFifo;

  Fifo#(LqSize, LqIndex) pendingLoadsQ <- mkPipelineFifo;

  Fifo#(TAdd#(LqSize, SqSize), Bool) tagQ <- mkPipelineFifo;

  // No forwarding for the moment, the loads are just blocked untill they are
  // ready. But they are performed speculatively if they are into storeQ
  Bit#(32) loadAddr =
    {(loadIQ.issueVal+loadQ.readOffset(loadIQ.issueId))[31:2],2'b00};
  Bool loadBlocked =
    stb.search(loadAddr).found ||
    storeQ.search(
      loadAddr, loadQ.readEpoch(loadIQ.issueId),
      loadQ.readAge(loadIQ.issueId)).found;

  Ehr#(2, Bit#(32)) nb_load <- mkEhr(0);
  Ehr#(2, Bit#(32)) nb_store <- mkEhr(0);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  rule countCycle;
    cycle <= cycle + 1;

    //if (cycle[9:0] == 0) begin
    //  $display("loads: %d stores: %d", nb_load[0], nb_store[0]);
    //end
  endrule

  rule deqSTB;
    wresponseQ.deq;
    stb.deq;
  endrule

  rule wakeupLoad if (!loadBlocked);
    loadIQ.issue();
    let result <- loadQ.wakeupAddr(loadIQ.issueId, loadIQ.issueVal);

    case (result) matches
      tagged Success .request : begin
        pendingLoadsQ.enq(loadIQ.issueId);
        rrequestQ.enq(request);
      end
      tagged Failure .cause :
        loadFailureQ.enq(tuple2(cause.index, cause.result));
    endcase
  endrule

  rule loadResponse;
    let resp <- toGet(rresponseQ).get;
    let idx <- toGet(pendingLoadsQ).get;
    loadSuccessQ.enq(loadQ.issue(idx, resp));
  endrule

  rule wakeupStoreAddr;
    storeAddrIQ.issue();
    storeQ.wakeupAddr(storeAddrIQ.issueId, storeAddrIQ.issueVal);
  endrule

  rule wakeupStoreData;
    storeDataIQ.issue();
    storeQ.wakeupData(storeDataIQ.issueId, storeDataIQ.issueVal);
  endrule

  rule issueStore;
    let result <- storeQ.issue();
    storeSuccessQ.enq(result);
  endrule

  method ActionValue#(CommitOutput) commit(RobIndex index, Bool must_commit);
    tagQ.deq;

    if (tagQ.first) begin
      nb_load[0] <= nb_load[0] - 1;
      loadQ.deq();
      return Success;
    end else begin
      nb_store[0] <= nb_store[0] - 1;
      let stbEntry <- storeQ.deq();

      if (must_commit) begin
        stb.enq(stbEntry);
        wrequestQ.enq(AXI4_Lite_WRequest{
          bytes: stbEntry.data,
          addr: stbEntry.addr,
          strb: stbEntry.mask
        });

        //if (stbEntry.addr == 32'h1000_0000) begin
        //  $display("data: %c", stbEntry.data[7:0]);
        //end

        if (loadQ.search(stbEntry.addr) matches tagged Valid .idx) begin
          $display("load dependency misprediction at address %h", stbEntry.addr);
          return Exception(idx);
        end else
          return Success;
      end else
        return Success;
    end
  endmethod

  method Action enq(IssueQueueEntry entry);
    action
      case (entry.instr) matches
        tagged Itype {op: tagged Load .ltype} : begin
          let index <- loadQ.enq(LoadQueueEntry{
            offset: immediateBits(entry.instr),
            signedness: loadSignedness(ltype),
            size: loadSize(ltype),
            index: entry.index,
            epoch: entry.epoch,
            age: entry.age,
            pc: entry.pc
          });
          loadIQ.enq(index, entry.rs1_val);
          tagQ.enq(True);
          nb_load[1] <= nb_load[1] + 1;
        end
        tagged Stype {op: .stype} : begin
          let index <- storeQ.enq(StoreQueueEntry{
            offset: immediateBits(entry.instr),
            size: storeSize(stype),
            index: entry.index,
            epoch: entry.epoch,
            age: entry.age,
            pc: entry.pc
          });
          storeAddrIQ.enq(index, entry.rs1_val);
          storeDataIQ.enq(index, entry.rs2_val);
          tagQ.enq(False);
          nb_store[1] <= nb_store[1] + 1;
        end
      endcase
    endaction
  endmethod

  method Action wakeup(RobIndex index, Bit#(32) value);
    action
      loadIQ.wakeup(index, value);
      storeAddrIQ.wakeup(index, value);
      storeDataIQ.wakeup(index, value);
    endaction
  endmethod

  method Bool canDeq;
    return loadSuccessQ.canDeq || loadFailureQ.canDeq || storeSuccessQ.canDeq;
  endmethod

  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq();
    if (loadSuccessQ.canDeq) begin
      loadSuccessQ.deq;
      return loadSuccessQ.first;
    end else if (loadFailureQ.canDeq) begin
      loadFailureQ.deq;
      return loadFailureQ.first;
    end else begin
      storeSuccessQ.deq;
      return storeSuccessQ.first;
    end
  endmethod

  interface RdAXI4_Lite_Master rd_mem;
    method response = toPut(rresponseQ);
    method request = toGet(rrequestQ);
  endinterface

  interface WrAXI4_Lite_Master wr_mem;
    method response = toPut(wresponseQ);
    method request = toGet(wrequestQ);
  endinterface
endmodule
