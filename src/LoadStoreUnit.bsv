package LoadStoreUnit;

import Utils :: *;
import Decode :: *;
import Vector :: *;
import FIFOF :: *;
import SpecialFIFOs :: *;
import GetPut :: *;
import Fifo :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;

import MemoryTypes :: *;

// return the address of an IssueQueueEntry
function Maybe#(Bit#(32)) getIssueAddr(IssueQueueEntry entry);
  return case (entry.rs1_val) matches
    tagged Value .v : tagged Valid (v + immediateBits(entry.instr));
    default: Invalid;
  endcase;
endfunction

// return the data of an IssueQueueEntry
function Maybe#(Bit#(32)) getIssueData(IssueQueueEntry entry);
  return case (entry.rs2_val) matches
    tagged Value .v : tagged Valid v;
    default: Invalid;
  endcase;
endfunction

// return the size of a load or store operation
function Data_Size getIssueSize(IssueQueueEntry entry);
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


// A type of queue manager, a queue has an enqueue port and a dequeue port
// that must be 0 and 1 or 1 and 0. This module allow to manage the head
// (next element to be dequeue) and tail (next element to be enqueue) of
// a queue.
// It is very usefull in the load store unit because their 3 queues to manage
// in the same time (loadQ, storeQ, and stb)
interface QueueManager#(numeric type size);
  // Return the head (next element to be dequeu) and tail
  // (next element to be enqueue) of the queue
  method Vector#(2, Bit#(TLog#(size))) head;
  method Vector#(2, Bit#(TLog#(size))) tail;

  // Return if the queue is empty or full
  method Vector#(2, Bool) empty;
  method Vector#(2, Bool) full;

  // A bit mask that represent if an index is valid
  method Vector#(2, Bit#(size)) valid;

  // Return the next and previous element of an index in the queue
  method Bit#(TLog#(size)) succ(Bit#(TLog#(size)) addr);
  method Bit#(TLog#(size)) prev(Bit#(TLog#(size)) addr);

  // Enqueue or dequeue an element of the queue
  method Action enq;
  method Action deq;
endinterface

module mkQueueManager#(Integer enqPort, Integer deqPort)
  (QueueManager#(size));
  Ehr#(2, Bit#(TLog#(size))) headEhr <- mkEhr(0);
  Ehr#(2, Bit#(TLog#(size))) tailEhr <- mkEhr(0);
  Ehr#(2, Bit#(size)) validEhr <- mkEhr(0);

  function Bit#(TLog#(size)) succFn(Bit#(TLog#(size)) addr);
    return (addr == fromInteger(valueOf(size) - 1) ? 0 : addr + 1);
  endfunction

  function Bit#(TLog#(size)) prevFn(Bit#(TLog#(size)) addr);
    return (addr == 0 ? fromInteger(valueOf(size) - 1) : addr - 1);
  endfunction

  function Bool isEmpty(Integer port);
    return (headEhr[port] == tailEhr[port] && validEhr[port][headEhr[port]] == 0);
  endfunction

  function Bool isFull(Integer port);
    return (headEhr[port] == tailEhr[port] && validEhr[port][headEhr[port]] == 1);
  endfunction

  method succ = succFn;
  method prev = prevFn;

  method Vector#(2, Bit#(TLog#(size))) head;
    Vector#(2, Bit#(TLog#(size))) ret = newVector;
    ret[0] = headEhr[0];
    ret[1] = headEhr[1];
    return ret;
  endmethod

  method Vector#(2, Bit#(TLog#(size))) tail;
    Vector#(2, Bit#(TLog#(size))) ret = newVector;
    ret[0] = tailEhr[0];
    ret[1] = tailEhr[1];
    return ret;
  endmethod

  method Vector#(2, Bit#(size)) valid;
    Vector#(2, Bit#(size)) ret = newVector;
    ret[0] = validEhr[0];
    ret[1] = validEhr[1];
    return ret;
  endmethod

  method Vector#(2, Bool) empty;
    Vector#(2, Bool) ret = newVector;
    ret[0] = isEmpty(0);
    ret[1] = isEmpty(1);
    return ret;
  endmethod

  method Vector#(2, Bool) full;
    Vector#(2, Bool) ret = newVector;
    ret[0] = isFull(0);
    ret[1] = isFull(1);
    return ret;
  endmethod

  method Action enq if (!isFull(enqPort));
    action
      validEhr[enqPort][tailEhr[enqPort]] <= 1;
      tailEhr[enqPort] <= succFn(tailEhr[enqPort]);
    endaction
  endmethod

  method Action deq if (!isEmpty(deqPort));
    action
      validEhr[deqPort][headEhr[deqPort]] <= 0;
      headEhr[deqPort] <= succFn(headEhr[deqPort]);
    endaction
  endmethod
endmodule


// The module must satisfy deq < {wakeup, commit} < enq
// This module must satisfy commit < deq < wakeup < enq
interface LoadStoreUnit;
  // Add a new entry in the issue queue
  method Action enq(IssueQueueEntry entry);

  // signal that we found the value of a register
  method Action wakeup(RobIndex index, Bit#(32) value);

  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;

  method Bool canDeq;

  // Say if we must commit the instruction with a given roerder buffer index
  method ActionValue#(CommitOutput)
    commit(RobIndex index, Bool must_commit);

  // read interface with memory
  interface Riscv_Read_Master mem_read;

  // write interface with memory
  interface Riscv_Write_Master mem_write;
endinterface

// The store buffer contain the stores that we already send to the
// memory controller and wait a response
typedef struct {
  Bit#(32) addr;
  Bit#(32) data;
  Data_Size size;
  Bool isFence;
} StbEntry deriving(Bits, FShow, Eq);

// Result of a conflict search
typedef struct {
  // True if a confloct exist
  Bool found;
  // A value if we can forward a value from the store buffer
  Maybe#(Bit#(32)) forward;
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

(* synthesize *)
module mkLoadStoreUnit2(LoadStoreUnit);
  FIFOF#(Riscv_WRequest) wr_request_fifo <- mkBypassFIFOF;
  FIFOF#(Riscv_RRequest) rd_request_fifo <- mkBypassFIFOF;
  FIFOF#(Riscv_WResponse) wr_response_fifo <- mkPipelineFIFOF;
  FIFOF#(Riscv_RResponse) rd_response_fifo <- mkPipelineFIFOF;

  FIFOF#(Tuple2#(RobIndex, ExecOutput)) loadOutputs <- mkPipelineFIFOF;
  FIFOF#(Tuple2#(RobIndex, ExecOutput)) storeOutputs <- mkPipelineFIFOF;

  // fifo to commit the operation if it is not a load
  Fifo#(TMul#(SqSize, 2), Bool) isLoadF <- mkPipelineFifo;

  // This queue contain all the store to perform in the futur
  Vector#(SqSize, Ehr#(2, IssueQueueEntry)) storeQ <- replicateM(mkEhr(?));
  // manage the store queue head, tail, valid bits...
  QueueManager#(SqSize) storeM <- mkQueueManager(1, 0);

  // This queue contain all the loads to perform
  Vector#(LqSize, Ehr#(2, IssueQueueEntry)) loadQ <- replicateM(mkEhr(?));
  // manage the load queue head, tail, valid bits...
  QueueManager#(LqSize) loadM <- mkQueueManager(1, 0);

  Vector#(StbSize, Reg#(StbEntry)) stb <- replicateM(mkReg(?));
  // manage the store buffer head, tail, valid bits...
  QueueManager#(StbSize) stbM <- mkQueueManager(1, 0);

  // Overapproximate the read-from relation over loads and store: link each
  // load to all the older stores
  Vector#(LqSize, Ehr#(2, Bit#(SqSize))) read_from <- replicateM(mkEhr(0));

  Reg#(LqIndex) loadCommitHead <- mkReg(0);

  function Bool compatible(Bit#(32) addr1, Bit#(32) addr2);
    Int#(32) diff = unpack(addr1 - addr2);
    return diff < -3 || diff > 3;
  endfunction

  // return the youngest store that overwite an address in the store buffer
  function Maybe#(StbIndex) searchSTB(Bit#(32) addr);
    Bit#(StbSize) subset = 0;

    for (Integer i=0; i < valueOf(StbSize); i = i + 1) begin
      let store = stb[i];

      if (store.isFence || !compatible(addr, store.addr)) begin
        subset[i] = 1;
      end
    end

    return lastOneFrom(subset & stbM.valid[0], stbM.head[0]);
  endfunction

  // return the youngest store that overwrite an address in the store buffer
  function Maybe#(SqIndex) searchStoreQ(Bit#(32) addr, Bit#(SqSize) mask);
    Bit#(SqSize) subset = 0;

    for (Integer i=0; i < valueOf(SqSize); i = i + 1) begin
      let store = storeQ[i][0];
      let is_fence = isIssueFence(store);

      if (isIssueFence(store)) begin

        subset[i] = 1;

      end else if (getIssueAddr(store) matches tagged Valid .storeAddr) begin

        if (!compatible(addr, storeAddr)) begin
          subset[i] = 1;
        end

      end else if (!loadSpeculation) begin
        subset[i] = 1;
      end
    end

    return lastOneFrom(subset & mask & storeM.valid[0], storeM.head[0]);
  endfunction


  // Search if their is a store such that it address conflict with the given
  // address, the mask is used to check in a subset of stores. This function
  // return it their is such a load and it it comme from the store buffer (it is
  // already commited, it's data is not speculative), it may return a value to
  // forward
  function StoreConflict
    searchConflictStore(Bit#(32) addr, Bit#(SqSize) mask);

    if (searchStoreQ(addr, mask) matches tagged Valid .*) begin

      return StoreConflict{
        found: True,
        forward: ?
      };

    end else if (searchSTB(addr) matches tagged Valid .*) begin

      return StoreConflict{
        found: True,
        forward: ?
      };


    end else
      return StoreConflict{
        found: False,
        forward: ?
      };

  endfunction

  (* descending_urgency = "deqFenceStb, deqStoreStb" *)
  rule deqFenceStb if (!stbM.empty[0] && stb[stbM.head[0]].isFence);
    stbM.deq;
  endrule

  rule deqStoreStb if (!stbM.empty[0] && !stb[stbM.head[0]].isFence);
    wr_response_fifo.deq;
    stbM.deq;
  endrule

  // Commit the next load if possible
  rule enqLoadRequest if (
      getIssueAddr(loadQ[loadCommitHead][0]) matches tagged Valid .addr &&&
      loadM.succ(loadCommitHead) != loadM.head[0] &&
      loadM.valid[0][loadCommitHead] == 1
    );

    Bit#(SqSize) mask = read_from[loadCommitHead][0];

    let conflict = searchConflictStore(addr, mask);

    if (!conflict.found) begin
      rd_request_fifo.enq(Riscv_RRequest{
        size: getIssueSize(loadQ[loadCommitHead][0]),
        addr: addr
      });

      loadCommitHead <= loadM.succ(loadCommitHead);
    end
  endrule

  //(* execution_order = "deqLoadResponse, enqLoadRequest" *)
  rule deqLoadResponse;
    let entry = loadQ[loadM.head[0]][0];
    let resp = rd_response_fifo.first;
    rd_response_fifo.deq;
    loadM.deq;

    let data = case (getIssueSize(entry)) matches
      Half: isSigned(entry) ?
        signExtend(resp.bytes[15:0]) : zeroExtend(resp.bytes[15:0]);
      Byte: isSigned(entry) ?
        signExtend(resp.bytes[7:0]) : zeroExtend(resp.bytes[7:0]);
      Word: resp.bytes;
    endcase;

    loadOutputs.enq(Tuple2{
      fst: entry.index,
      snd: tagged Ok {
        rd_val: data,
        next_pc: entry.pc + 4
      }
    });
  endrule

  method Action wakeup(RobIndex index, Bit#(32) value);
    action
      for(Integer i=0; i < valueOf(LqSize); i = i + 1) begin
        IssueQueueEntry entry = loadQ[i][0];

        if (entry.rs1_val matches tagged Wait .idx &&& idx == index)
          entry.rs1_val = tagged Value value;

        if (entry.rs2_val matches tagged Wait .idx &&& idx == index)
          entry.rs2_val = tagged Value value;

        loadQ[i][0] <= entry;
      end

      for(Integer i=0; i < valueOf(SqSize); i = i + 1) begin
        IssueQueueEntry entry = storeQ[i][0];

        if (entry.rs1_val matches tagged Wait .idx &&& idx == index)
          entry.rs1_val = tagged Value value;

        if (entry.rs2_val matches tagged Wait .idx &&& idx == index)
          entry.rs2_val = tagged Value value;

        storeQ[i][0] <= entry;
      end
    endaction
  endmethod


  method Action enq(IssueQueueEntry entry);
    action
      if (isIssueLoad(entry)) begin
        read_from[loadM.tail[1]][1] <= storeM.valid[1];
        loadQ[loadM.tail[1]][1] <= entry;
        isLoadF.enq(True);
        loadM.enq;
      end else begin
        storeQ[storeM.tail[1]][1] <= entry;
        isLoadF.enq(False);
        storeM.enq;

        storeOutputs.enq(Tuple2{
          fst: entry.index,
          snd: tagged Ok {
            rd_val: 0, next_pc: entry.pc + 4
          }
        });
      end
    endaction
  endmethod

  method ActionValue#(CommitOutput) commit(RobIndex idx, Bool must_commit);
    actionvalue
      isLoadF.deq;

      if (!isLoadF.first) begin
        let entry = storeQ[storeM.head[0]][0];

        for (Integer i=0; i < valueOf(LqSize); i = i + 1) begin
          read_from[i][0][storeM.head[0]] <= 0;
        end

        storeM.deq;

        let isStore = isIssueStore(entry);
        let addr = unJust(getIssueAddr(entry));
        let data = unJust(getIssueData(entry));
        let size = getIssueSize(entry);


        if (isStore && getIssueAddr(entry) == Invalid)
          $display("address must be know at commit");
        if (isStore && getIssueData(entry) == Invalid)
          $display("address must be know at commit");

        if (must_commit) begin
          stbM.enq;
          stb[stbM.tail[1]] <= StbEntry {
            isFence: !isStore,
            addr: addr,
            data: data,
            size: size
          };

          if (isStore)
            wr_request_fifo.enq(Riscv_WRequest{
              bytes: data,
              addr: addr,
              size: size
            });
        end
      end

      return Success;
    endactionvalue
  endmethod

  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;
    actionvalue
      let result;
      if (loadOutputs.notEmpty)
        result <- toGet(loadOutputs).get;
      else
        result <- toGet(storeOutputs).get;
      return result;
    endactionvalue
  endmethod
  method canDeq = loadOutputs.notEmpty || storeOutputs.notEmpty;

  interface Riscv_Write_Master mem_write;
    interface request = toGet(wr_request_fifo);
    interface response = toPut(wr_response_fifo);
  endinterface

  interface Riscv_Read_Master mem_read;
    interface request = toGet(rd_request_fifo);
    interface response = toPut(rd_response_fifo);
  endinterface
endmodule

interface LoadQueue;
  // Stage 1
  method Vector#(LqSize, RobIndex) index;
  method Vector#(LqSize, Maybe#(Bit#(32))) addr;
  method Vector#(LqSize, Data_Size) size;
  method Vector#(LqSize, Bit#(32)) pc;
  method Vector#(LqSize, Bool) sign;

  // Stage 2
  method Action wakeup(RobIndex idx, Bit#(32) value);

  // Stage 3
  method Action enq(LqIndex idx, IssueQueueEntry entry);
endinterface

(* synthesize *)
module mkLoadQueue(LoadQueue);
  Vector#(LqSize, Ehr#(2, IssueQueueEntry)) entryV <- replicateM(mkEhr(?));

  function IssueQueueEntry getEntry(Ehr#(2, IssueQueueEntry) entry);
    return entry[0];
  endfunction

  function RobIndex getIndex(IssueQueueEntry entry);
    return entry.index;
  endfunction

  function Bit#(32) getPC(IssueQueueEntry entry);
    return entry.pc;
  endfunction

  method index = map(compose(getIndex, getEntry), entryV);
  method addr = map(compose(getIssueAddr, getEntry), entryV);
  method size = map(compose(getIssueSize, getEntry), entryV);
  method sign = map(compose(isSigned, getEntry), entryV);
  method pc = map(compose(getPC, getEntry), entryV);

  method Action wakeup(RobIndex idx, Bit#(32) value);
    action
      for (Integer i=0; i < valueOf(LqSize); i = i + 1) begin
        IssueQueueEntry entry = entryV[i][0];

        if (entry.rs1_val matches tagged Wait .x &&& x == idx)
          entry.rs1_val = tagged Value value;

        if (entry.rs2_val matches tagged Wait .x &&& x == idx)
          entry.rs2_val = tagged Value value;

        entryV[i][0] <= entry;
      end
    endaction
  endmethod

  method Action enq(LqIndex idx, IssueQueueEntry entry);
    action
      entryV[idx][1] <= entry;
    endaction
  endmethod
endmodule

// Choose if mkLoadStoreUnit3 use speculation
Bool loadSpeculation = True;

// A Load Store Unit with load speculation: this unit may have a larger critical
// path than the others but may be faster in term of IPC because it doesn't wait
// for older stores to complete during a load, and in practice a lot of theses
// stores doesn't use the same addresses than the load.
(* synthesize *)
module mkLoadStoreUnit3(LoadStoreUnit);
  FIFOF#(Riscv_WRequest) wr_request_fifo <- mkBypassFIFOF;
  FIFOF#(Riscv_RRequest) rd_request_fifo <- mkBypassFIFOF;
  FIFOF#(Riscv_WResponse) wr_response_fifo <- mkPipelineFIFOF;
  FIFOF#(Riscv_RResponse) rd_response_fifo <- mkPipelineFIFOF;

  // todo: find a way to use a pipeline fifo: decreases the critical path
  FIFOF#(Tuple2#(RobIndex, ExecOutput)) loadOutputs <- mkPipelineFIFOF;
  FIFOF#(Tuple2#(RobIndex, ExecOutput)) storeOutputs <- mkPipelineFIFOF;

  // todo: remove it: we may use the RobIndex to remove the ambiguity
  // fifo to commit the operation if it is not a load
  Fifo#(TMul#(SqSize, 2), Bool) isLoadF <- mkPipelineFifo;

  // This queue contain all the store to perform in the futur
  Vector#(SqSize, Ehr#(2, IssueQueueEntry)) storeQ <- replicateM(mkEhr(?));
  // manage the store queue head, tail, valid bits...
  QueueManager#(SqSize) storeM <- mkQueueManager(1, 0);

  // This queue contain all the loads to perform
  LoadQueue loadQ <- mkLoadQueue;
  // manage the load queue head, tail, valid bits...
  QueueManager#(LqSize) loadM <- mkQueueManager(1, 0);

  Vector#(StbSize, Reg#(StbEntry)) stb <- replicateM(mkReg(?));
  // manage the store buffer head, tail, valid bits...
  QueueManager#(StbSize) stbM <- mkQueueManager(1, 0);

  // Overapproximate the read-from relation over loads and store: link each
  // load to all the older stores
  Vector#(LqSize, Ehr#(2, Bit#(SqSize))) read_from <- replicateM(mkEhr(0));

  // Indicate if a load is already commited to the main memory
  Ehr#(2, Bit#(LqSize)) loadCommit <- mkEhr(0);

  // Fifo of commited loads
  Fifo#(LqSize, LqIndex) loadF <- mkPipelineFifo;

  // Instantiate the next load address
  RWire#(LqIndex) nextLoad <- mkRWire;

  // Choose the next load to commit to the main memory
  function Maybe#(LqIndex) chooseLoad;
    Bit#(LqSize) subset = loadM.valid[0] & ~loadCommit[0];

    for (Integer i=0; i < valueOf(LqSize); i = i + 1) begin
      if (loadQ.addr[i] matches Invalid)
        subset[i] = 0;
    end

    return firstOneFrom(subset, loadM.head[0]);
  endfunction

  function Bool compatible(Bit#(32) addr1, Bit#(32) addr2);
    Int#(32) diff = unpack(addr1 - addr2);
    return diff < -3 || diff > 3;
  endfunction

  // return the oldest load that read an address and is already commited in
  // the load queue
  function Maybe#(LqIndex) searchLoadQ(Bit#(32) addr);
    Bit#(LqSize) subset = 0;

    // If we already found a result, we stop the research:
    //   We search only the oldest load
    for (Integer i=0; i < valueOf(LqSize); i = i + 1) begin
      if (loadM.valid[0][i] == 1 && loadCommit[0][i] == 1) begin
        if (loadQ.addr[i] matches tagged Valid .a) begin
          if (!compatible(addr, a))
            subset[i] = 1;
        end
      end
    end

    return firstOneFrom(subset, loadM.head[0]);
  endfunction

  // return the youngest store that overwite an address in the store buffer
  function Maybe#(StbIndex) searchSTB(Bit#(32) addr);
    Bit#(StbSize) subset = 0;

    for (Integer i=0; i < valueOf(StbSize); i = i + 1) begin
      let store = stb[i];

      if (store.isFence || !compatible(addr, store.addr)) begin
        subset[i] = 1;
      end
    end

    return lastOneFrom(subset & stbM.valid[0], stbM.head[0]);
  endfunction

  // return the youngest store that overwrite an address in the store buffer
  function Maybe#(SqIndex) searchStoreQ(Bit#(32) addr, Bit#(SqSize) mask);
    Bit#(SqSize) subset = 0;

    for (Integer i=0; i < valueOf(SqSize); i = i + 1) begin
      let store = storeQ[i][0];
      let is_fence = isIssueFence(store);

      if (isIssueFence(store)) begin

        subset[i] = 1;

      end else if (getIssueAddr(store) matches tagged Valid .storeAddr) begin

        if (!compatible(addr, storeAddr)) begin
          subset[i] = 1;
        end

      end else if (!loadSpeculation) begin
        subset[i] = 1;
      end
    end

    return lastOneFrom(subset & mask & storeM.valid[0], storeM.head[0]);
  endfunction


  // Search if their is a store such that it address conflict with the given
  // address, the mask is used to check in a subset of stores. This function
  // return it their is such a load and it it comme from the store buffer (it is
  // already commited, it's data is not speculative), it may return a value to
  // forward
  function StoreConflict
    searchConflictStore(Bit#(32) addr, Bit#(SqSize) mask);

    if (searchStoreQ(addr, mask) matches tagged Valid .*) begin

      return StoreConflict{
        found: True,
        forward: ?
      };

    end else if (searchSTB(addr) matches tagged Valid .*) begin

      return StoreConflict{
        found: True,
        forward: ?
      };


    end else
      return StoreConflict{
        found: False,
        forward: ?
      };

  endfunction

  (* descending_urgency = "deqFenceStb, deqStoreStb" *)
  rule deqFenceStb if (!stbM.empty[0] && stb[stbM.head[0]].isFence);
    stbM.deq;
  endrule

  rule deqStoreStb if (!stbM.empty[0] && !stb[stbM.head[0]].isFence);
    wr_response_fifo.deq;
    stbM.deq;
  endrule

  rule chooseLoadIndex if (
      chooseLoad matches tagged Valid .index
    );
    let addr = unJust(loadQ.addr[index]);
    Bit#(SqSize) mask = read_from[index][0];

    let conflict = searchConflictStore(addr, mask);

    if (!conflict.found) begin
      nextLoad.wset(index);
    end
  endrule

  // Commit the next load if possible
  rule enqLoadRequest if (
      nextLoad.wget matches tagged Valid .index
    );

    let addr = unJust(loadQ.addr[index]);

    loadCommit[0][index] <= 1;
    rd_request_fifo.enq(Riscv_RRequest{
      size: loadQ.size[index],
      addr: addr
    });

    loadF.enq(index);
  endrule

  //(* descending_urgency = "deqLoadResponse, enq" *)
  //(* execution_order = "deqLoadResponse, enqLoadRequest" *)
  (* execution_order = "chooseLoadIndex, commit, deqLoadResponse, enqLoadRequest" *)
  rule deqLoadResponse;
    let index = loadF.first;
    let resp = rd_response_fifo.first;
    rd_response_fifo.deq;
    loadF.deq;

    let data = case (loadQ.size[index]) matches
      Half: loadQ.sign[index] ?
        signExtend(resp.bytes[15:0]) : zeroExtend(resp.bytes[15:0]);
      Byte: loadQ.sign[index] ?
        signExtend(resp.bytes[7:0]) : zeroExtend(resp.bytes[7:0]);
      Word: resp.bytes;
    endcase;

    loadOutputs.enq(Tuple2{
      fst: loadQ.index[index],
      snd: tagged Ok {
        rd_val: data,
        next_pc: loadQ.pc[index] + 4
      }
    });
  endrule

  method Action wakeup(RobIndex index, Bit#(32) value);
    action
      loadQ.wakeup(index, value);

      for(Integer i=0; i < valueOf(SqSize); i = i + 1) begin
        IssueQueueEntry entry = storeQ[i][0];

        if (entry.rs1_val matches tagged Wait .idx &&& idx == index)
          entry.rs1_val = tagged Value value;

        if (entry.rs2_val matches tagged Wait .idx &&& idx == index)
          entry.rs2_val = tagged Value value;

        storeQ[i][0] <= entry;
      end
    endaction
  endmethod

  method Action enq(IssueQueueEntry entry);
    action
      if (isIssueLoad(entry)) begin
        read_from[loadM.tail[1]][1] <= storeM.valid[1];
        loadCommit[1][loadM.tail[1]] <= 0;
        loadQ.enq(loadM.tail[1], entry);
        isLoadF.enq(True);
        loadM.enq;
      end else begin
        storeQ[storeM.tail[1]][1] <= entry;
        isLoadF.enq(False);
        storeM.enq;

        storeOutputs.enq(Tuple2{
          fst: entry.index,
          snd: tagged Ok {
            rd_val: 0, next_pc: entry.pc + 4
          }
        });
      end
    endaction
  endmethod

  method ActionValue#(CommitOutput) commit(RobIndex idx, Bool must_commit);
    actionvalue
      isLoadF.deq;

      if (!isLoadF.first) begin
        let entry = storeQ[storeM.head[0]][0];

        for (Integer i=0; i < valueOf(LqSize); i = i + 1) begin
          read_from[i][0][storeM.head[0]] <= 0;
        end

        storeM.deq;

        let isStore = isIssueStore(entry);
        let addr = unJust(getIssueAddr(entry));
        let data = unJust(getIssueData(entry));
        let size = getIssueSize(entry);


        if (isStore && getIssueAddr(entry) == Invalid)
          $display("address must be know at commit");
        if (isStore && getIssueData(entry) == Invalid)
          $display("address must be know at commit");

        if (must_commit) begin
          stbM.enq;
          stb[stbM.tail[1]] <= StbEntry {
            isFence: !isStore,
            addr: addr,
            data: data,
            size: size
          };

          if (isStore)
            wr_request_fifo.enq(Riscv_WRequest{
              bytes: data,
              addr: addr,
              size: size
            });

          // Check for load misspeculation
          if (
            searchLoadQ(addr) matches tagged Valid .l_id &&&
            loadSpeculation && isStore
          ) begin

            $display("load dependency misprediction");
            return Exception(loadQ.index[l_id]);

          end else
            return Success;
        end else
          return Success;

      end else begin
        loadM.deq;
        return Success;
      end
    endactionvalue
  endmethod

  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;
    actionvalue
      let result;
      if (loadOutputs.notEmpty)
        result <- toGet(loadOutputs).get;
      else
        result <- toGet(storeOutputs).get;
      return result;
    endactionvalue
  endmethod

  method canDeq = loadOutputs.notEmpty || storeOutputs.notEmpty;

  interface Riscv_Write_Master mem_write;
    interface request = toGet(wr_request_fifo);
    interface response = toPut(wr_response_fifo);
  endinterface

  interface Riscv_Read_Master mem_read;
    interface request = toGet(rd_request_fifo);
    interface response = toPut(rd_response_fifo);
  endinterface
endmodule

(* synthesize *)
module mkLoadStoreUnit(LoadStoreUnit);
  Reg#(Bool) busy <- mkReg(False);

  // stage 1: receive it's registers values
  Reg#(Bool) stage1_valid <- mkReg(False);
  Reg#(RobIndex) index1 <- mkReg(?);
  Reg#(Instr) instr <- mkReg(?);
  Reg#(Bit#(32)) pc1 <- mkReg(?);
  Reg#(RegVal) rs1_val <- mkReg(?);
  Reg#(RegVal) rs2_val <- mkReg(?);

  // stage 2: decode the instruction
  Reg#(Bool) stage2_valid <- mkReg(False);
  Reg#(Bool) is_store <- mkReg(False);
  Reg#(RobIndex) index2 <- mkReg(?);
  Reg#(LoadOp) loadOp <- mkReg(?);
  Reg#(SOp) storeOp <- mkReg(?);
  Reg#(Bit#(32)) addr <- mkReg(?);
  Reg#(Bit#(32)) data <- mkReg(?);
  Reg#(Bit#(32)) pc2 <- mkReg(?);

  FIFOF#(Bool) store_to_commit <- mkPipelineFIFOF;
  FIFOF#(Tuple2#(RobIndex, ExecOutput)) results <- mkPipelineFIFOF;

  FIFOF#(Riscv_WRequest) wr_request_fifo <- mkBypassFIFOF;
  FIFOF#(Riscv_RRequest) rd_request_fifo <- mkBypassFIFOF;
  FIFOF#(Riscv_WResponse) wr_response_fifo <- mkPipelineFIFOF;
  FIFOF#(Riscv_RResponse) rd_response_fifo <- mkPipelineFIFOF;

  rule deq_wresponse;
    wr_response_fifo.deq;
    stage2_valid <= False;
  endrule

  rule receive_rresult;
    stage2_valid <= False;
    let resp = rd_response_fifo.first.bytes;
    rd_response_fifo.deq;

    let bytes = case (loadOp) matches
      LB : signExtend(resp[7:0]);
      LH : signExtend(resp[15:0]);
      LBU : zeroExtend(resp[7:0]);
      LHU : zeroExtend(resp[15:0]);
      default: resp;
    endcase;

    results.enq(Tuple2{fst: index2, snd: tagged Ok {
      rd_val: bytes,
      next_pc: pc2+4
    }});
  endrule

  rule stage1_to_stage2 if (
    rs1_val matches tagged Value .rs1 &&&
    rs2_val matches tagged Value .rs2 &&&
    stage1_valid && !stage2_valid);

    stage1_valid <= False;
    stage2_valid <= True;

    pc2 <= pc1;
    index2 <= index1;
    addr <= rs1 + immediateBits(instr);
    data <= rs2;

    case (instr) matches
      tagged Stype {op: .op} : begin
        store_to_commit.enq(True);
        is_store <= True;
        storeOp <= op;

        results.enq(Tuple2{fst: index1, snd: tagged Ok {
          rd_val: 0,
          next_pc: pc1+4
        }});
      end
      tagged Itype {op: tagged Load .op} : begin
        store_to_commit.enq(False);
        is_store <= False;
        let size = case (op) matches
          LB : Byte;
          LH : Half;
          LW : Word;
          LBU : Byte;
          LHU : Half;
        endcase;
        loadOp <= op;

        rd_request_fifo.enq(Riscv_RRequest{
          addr: rs1+immediateBits(instr),
          size: size
        });
      end
    endcase
  endrule

  method ActionValue#(CommitOutput) commit(RobIndex i, Bool must_commit);
    actionvalue
      if (store_to_commit.first) begin
        let size = case (storeOp) matches
          SB : Byte;
          SH : Half;
          SW : Word;
        endcase;

        if (must_commit)
          wr_request_fifo.enq(Riscv_WRequest{
            bytes: data,
            addr: addr,
            size: size
          });
        else stage2_valid <= False;
      end

      store_to_commit.deq;
      return Success;
    endactionvalue
  endmethod


  method Action wakeup(RobIndex idx, Bit#(32) value);
    action
      if (stage1_valid) begin
        if (rs1_val matches tagged Wait .i &&& i == idx)
          rs1_val <= tagged Value value;

        if (rs2_val matches tagged Wait .i &&& i == idx)
          rs2_val <= tagged Value value;
      end
    endaction
  endmethod

  method deq = toGet(results).get;

  method canDeq = results.notEmpty;

  method Action enq(IssueQueueEntry entry) if (!stage1_valid);
    stage1_valid <= True;
    index1 <= entry.index;
    pc1 <= entry.pc;
    instr <= entry.instr;
    rs1_val <= entry.rs1_val;
    rs2_val <= entry.rs2_val;
  endmethod


  interface Riscv_Write_Master mem_write;
    interface request = toGet(wr_request_fifo);
    interface response = toPut(wr_response_fifo);
  endinterface

  interface Riscv_Read_Master mem_read;
    interface request = toGet(rd_request_fifo);
    interface response = toPut(rd_response_fifo);
  endinterface
endmodule


endpackage
