import StoreBuffer :: *;
import StoreQueue :: *;
import LoadQueue :: *;
import AXI4_Lite :: *;
import LsuTypes :: *;
import GetPut :: *;
import Decode :: *;
import Utils :: *;
import AXI4 :: *;
import Fifo :: *;
import OOO :: *;
import Ehr :: *;

import BCache :: *;

import Vector :: *;

interface LSU;
  // Receive an invalidation request from the CPU
  method Action invalidate(Bit#(32) addr);

  // Add a new entry in the issue queue
  method ActionValue#(SqIndex) enqStore(IssueQueueInput#(0) entry);
  method ActionValue#(LqIndex) enqLoad(IssueQueueInput#(0) entry);

  // wakeup all the issue queues
  method Action wakeupLoad(ExecInput#(1) entry);
  method Action wakeupStoreAddr(ExecInput#(1) entry);
  method Action wakeupStoreData(ExecInput#(1) entry);

  // dequeue the result of the execution of an instruction
  method ActionValue#(ExecOutput) deq;

  // return if we can dequeue the result of an instruction
  method Bool canDeq;

  // Say if we must commit the instruction with a given reorder buffer index
  method ActionValue#(CommitOutput) commit(RobIndex index, Bool must_commit);

  // An action that fire only if the store buffer is empty
  method Action emptySTB();

  // read interface with memory
  interface RdAXI4_Master#(4, 32, 4) rd_dmem;

  // write interface with memory
  interface WrAXI4_Master#(4, 32, 4) wr_dmem;

  // read interface with memory
  interface RdAXI4_Lite_Master#(32, 4) rd_mmio;

  // write interface with memory
  interface WrAXI4_Lite_Master#(32, 4) wr_mmio;
endinterface

typedef enum {
  Load, Store
} LsuTag deriving(Bits, FShow, Eq);

(* synthesize *)
module mkLSU(LSU);
  StoreQ storeQ <- mkStoreQ;
  LoadQ loadQ <- mkLoadQ;

  STB stb <- mkSTB;
  Fifo#(StbSize, Bool) isStoreMMIO <- mkPipelineFifo;

  let cache <- mkDefaultBCache();

  Fifo#(2, void) stbDeqQ <- mkFifo;

  Fifo#(1, void) invalidateQ <- mkPipelineFifo;

  Fifo#(4, AXI4_Lite_RRequest#(32)) rrequestQ <- mkBypassFifo;
  Fifo#(4, AXI4_Lite_WRequest#(32, 4)) wrequestQ <- mkBypassFifo;
  Fifo#(2, AXI4_Lite_RResponse#(4)) rresponseQ <- mkFifo;
  Fifo#(2, AXI4_Lite_WResponse) wresponseQ <- mkFifo;

  Fifo#(2, ExecOutput) loadFailureQ <- mkFifo;
  Fifo#(2, ExecOutput) loadSuccessQ <- mkBypassFifo;
  Fifo#(2, ExecOutput) storeSuccessQ <- mkBypassFifo;

  Fifo#(LqSize, LqIndex) pendingDmemLoadsQ <- mkFifo;
  Fifo#(LqSize, LqIndex) pendingMmioLoadsQ <- mkFifo;

  Fifo#(TAdd#(LqSize, SqSize), LsuTag) tagQ <- mkFifo;

  rule enqRdCache if (!isMMIO(rrequestQ.first.addr));
    let req <- toGet(rrequestQ).get;
    cache.cpu_read.request.put(req);
  endrule

  rule enqWrCache if (!isMMIO(wrequestQ.first.addr));
    let req <- toGet(wrequestQ).get;
    cache.cpu_write.request.put(req);
  endrule

  rule setID1;
    cache.setID(1);
  endrule

  rule deqSTB;
    isStoreMMIO.deq();
    if (isStoreMMIO.first) wresponseQ.deq();
    else let _ <- cache.cpu_write.response.get();
    stbDeqQ.enq(?);
    //stb.deq;
  endrule

  rule doDeqSTB;
    stbDeqQ.deq;
    stb.deq;
  endrule

  rule loadResponse;
    AXI4_Lite_RResponse#(4) resp = ?;
    LqIndex idx = ?;

    if (pendingDmemLoadsQ.canDeq) begin
      resp <- cache.cpu_read.response.get;
      idx <- toGet(pendingDmemLoadsQ).get;
    end else begin
      resp <- toGet(rresponseQ).get;
      idx <- toGet(pendingMmioLoadsQ).get;
    end

    loadSuccessQ.enq(loadQ.finish(idx, resp));
    //$display("finish load");
  endrule

  rule issueStore;
    let result <- storeQ.issue();
    storeSuccessQ.enq(result);
  endrule

  let loadIssue = loadQ.tryIssue;

  Bool loadBlocked =
    stb.search(loadIssue.request.addr).found ||
    storeQ.search(loadIssue.request.addr, loadIssue.epoch, loadIssue.age).found;

  rule issueLoad if (!loadBlocked);
    let entry = loadQ.tryIssue;

    loadQ.issue;

    if (isMMIO(entry.request.addr)) begin
      pendingMmioLoadsQ.enq(entry.lindex);
      rrequestQ.enq(entry.request);
    end else begin
      pendingDmemLoadsQ.enq(entry.lindex);
      rrequestQ.enq(entry.request);
    end
  endrule

  method Action wakeupLoad(ExecInput#(1) entry);
    Bit#(32) addr = entry.regs[0] + immediateBits(entry.instr);

    let result <- loadQ.wakeupAddr(entry.lindex, addr);
    case (result) matches
      tagged Valid .cause :
        loadFailureQ.enq(cause);
      default: noAction;
    endcase
  endmethod

  method Action wakeupStoreData(ExecInput#(1) entry);
    storeQ.wakeupData(entry.sindex, entry.regs[0]);
  endmethod

  method Action wakeupStoreAddr(ExecInput#(1) entry);
    storeQ.wakeupAddr(entry.sindex, entry.regs[0] + immediateBits(entry.instr));
  endmethod

  method ActionValue#(CommitOutput) commit(RobIndex index, Bool must_commit);
    tagQ.deq;

    if (tagQ.first matches Load) begin
      loadQ.deq();
      return Success;
    end else begin
      let stbEntry <- storeQ.deq();

      if (must_commit) begin
        stb.enq(stbEntry);
        isStoreMMIO.enq(isMMIO(stbEntry.addr));
        wrequestQ.enq(AXI4_Lite_WRequest{
          bytes: stbEntry.data,
          addr: stbEntry.addr,
          strb: stbEntry.mask
        });

        if (loadQ.search(stbEntry.addr) matches tagged Valid .idx)
          return Exception(idx);
        else
          return Success;
      end else
        return Success;
    end
  endmethod

  method ActionValue#(LqIndex) enqLoad(IssueQueueInput#(0) entry);
    case (entry.instr) matches
      tagged Itype {op: tagged Load .ltype} : begin
        let index <- loadQ.enq(LoadQueueEntry{
          signedness: loadSignedness(ltype),
          size: loadSize(ltype),
          epoch: entry.epoch,
          index: entry.index,
          pdst: entry.pdst,
          age: entry.age,
          pc: entry.pc
        });
        tagQ.enq(Load);
        return index;
      end
    endcase
  endmethod

  method ActionValue#(SqIndex) enqStore(IssueQueueInput#(0) entry);
    case (entry.instr) matches
      tagged Stype {op: .stype} : begin
        let index <- storeQ.enq(StoreQueueEntry{
          size: storeSize(stype),
          epoch: entry.epoch,
          index: entry.index,
          pdst: entry.pdst,
          age: entry.age,
          pc: entry.pc
        });
        tagQ.enq(Store);
        return index;
      end
    endcase
  endmethod

  method Bool canDeq;
    return loadSuccessQ.canDeq || loadFailureQ.canDeq || storeSuccessQ.canDeq;
  endmethod

  method ActionValue#(ExecOutput) deq();
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

  method Action emptySTB() if (stb.empty() && invalidateQ.canEnq);
    noAction;
  endmethod

  method Action invalidate(Bit#(32) addr);
    cache.invalidate(addr);
    invalidateQ.enq(?);
  endmethod

  interface RdAXI4_Lite_Master rd_mmio;
    method response = toPut(rresponseQ);
    method request = when(isMMIO(rrequestQ.first.addr), toGet(rrequestQ));
  endinterface

  interface WrAXI4_Lite_Master wr_mmio;
    method response = toPut(wresponseQ);
    method request = when(isMMIO(wrequestQ.first.addr), toGet(wrequestQ));
  endinterface

  interface rd_dmem = cache.mem_read;
  interface wr_dmem = cache.mem_write;
endmodule
