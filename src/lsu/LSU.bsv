import MemIssueQueue :: *;
import StoreBuffer :: *;
import StoreQueue :: *;
import LoadQueue :: *;
import AXI4_Lite :: *;
import LsuTypes :: *;
import GetPut :: *;
import Decode :: *;
import Utils :: *;
import Fifo :: *;
import OOO :: *;
import Ehr :: *;

import Vector :: *;

interface LSU;
  // Add a new entry in the issue queue
  method Action enq(IssueQueueEntry entry);

  // wakeup all the issue queues
  method Action wakeup(RobIndex index, Bit#(32) value);

  // dequeue the result of the execution of an instruction
  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;

  // return if we can dequeue the result of an instruction
  method Bool canDeq;

  // Say if we must commit the instruction with a given reorder buffer index
  method ActionValue#(CommitOutput) commit(RobIndex index, Bool must_commit);

  // An action that fire only if the store buffer is empty
  method Action emptySTB();

  // read interface with memory
  interface RdAXI4_Lite_Master#(32, 4) rd_mem;

  // write interface with memory
  interface WrAXI4_Lite_Master#(32, 4) wr_mem;
endinterface

typedef enum {
  Load, Store
} LsuTag deriving(Bits, FShow, Eq);

(* synthesize *)
module mkLSU(LSU);
  MemIssueQueue#(SiqSize, SqIndex) storeAddrIQ <- mkStoreIssueQueue;
  MemIssueQueue#(SiqSize, SqIndex) storeDataIQ <- mkStoreIssueQueue;
  MemIssueQueue#(LiqSize, LqIndex) loadIQ <- mkLoadIssueQueue;
  StoreQ storeQ <- mkStoreQ;
  LoadQ loadQ <- mkLoadQ;
  STB stb <- mkSTB;

  Fifo#(4, AXI4_Lite_RRequest#(32)) rrequestQ <- mkBypassFifo;
  Fifo#(4, AXI4_Lite_WRequest#(32, 4)) wrequestQ <- mkBypassFifo;
  Fifo#(4, AXI4_Lite_RResponse#(4)) rresponseQ <- mkPipelineFifo;
  Fifo#(4, AXI4_Lite_WResponse) wresponseQ <- mkPipelineFifo;

  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) loadFailureQ <- mkPipelineFifo;
  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) loadSuccessQ <- mkPipelineFifo;
  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) storeSuccessQ <- mkPipelineFifo;

  Fifo#(LqSize, LqIndex) pendingLoadsQ <- mkPipelineFifo;

  Fifo#(TAdd#(LqSize, SqSize), LsuTag) tagQ <- mkPipelineFifo;

  // No forwarding for the moment, the loads are just blocked
  Bit#(32) loadAddr = {loadIQ.issueVal[31:2],2'b00};
  Bool loadBlocked =
    stb.search(loadAddr).found ||
    storeQ.search(loadAddr, loadIQ.issueEpoch, loadIQ.issueAge).found;

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

    if (tagQ.first matches Load) begin
      loadQ.deq();
      return Success;
    end else begin
      let stbEntry <- storeQ.deq();

      if (must_commit) begin
        stb.enq(stbEntry);
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

  method Action enq(IssueQueueEntry entry);
    action
      case (entry.instr) matches
        tagged Itype {op: tagged Load .ltype} : begin
          let index <- loadQ.enq(LoadQueueEntry{
            signedness: loadSignedness(ltype),
            size: loadSize(ltype),
            index: entry.index,
            epoch: entry.epoch,
            age: entry.age,
            pc: entry.pc
          });
          loadIQ.enq(index, entry.rs1_val, immediateBits(entry.instr), entry.epoch, entry.age);
          tagQ.enq(Load);
        end
        tagged Stype {op: .stype} : begin
          let index <- storeQ.enq(StoreQueueEntry{
            size: storeSize(stype),
            index: entry.index,
            epoch: entry.epoch,
            age: entry.age,
            pc: entry.pc
          });
          storeAddrIQ.enq(index, entry.rs1_val, immediateBits(entry.instr), 0, 0);
          storeDataIQ.enq(index, entry.rs2_val, 0 ,0, 0);
          tagQ.enq(Store);
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

  method Action emptySTB() if (stb.empty());
    noAction;
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
