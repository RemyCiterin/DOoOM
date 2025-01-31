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
  Bit#(32) loadAddr = {loadIQ.issueVal[31:2],2'b00};
  Bool loadBlocked =
    stb.search(loadAddr).found ||
    storeQ.search(loadAddr, loadIQ.issueEpoch, loadIQ.issueAge).found;

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
          tagQ.enq(True);
          nb_load[1] <= nb_load[1] + 1;
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
