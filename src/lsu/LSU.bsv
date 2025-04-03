import MemIssueQueue :: *;
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
  // Add a new entry in the issue queue
  method ActionValue#(SqIndex) enqStore(RobIndex index, Instr instr, Bit#(32) pc, Epoch epoch, Age age);
  method ActionValue#(LqIndex) enqLoad(RobIndex index, Instr instr, Bit#(32) pc, Epoch epoch, Age age);

  // wakeup all the issue queues
  method ActionValue#(Bool) wakeupLoad(MemIssueQueueOutput#(LqIndex) entry);
  method ActionValue#(Bool) wakeupStoreAddr(MemIssueQueueOutput#(SqIndex) entry);
  method ActionValue#(Bool) wakeupStoreData(MemIssueQueueOutput#(SqIndex) entry);

  // dequeue the result of the execution of an instruction
  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;

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

  Fifo#(4, AXI4_Lite_RRequest#(32)) rrequestQ <- mkBypassFifo;
  Fifo#(4, AXI4_Lite_WRequest#(32, 4)) wrequestQ <- mkBypassFifo;
  Fifo#(4, AXI4_Lite_RResponse#(4)) rresponseQ <- mkPipelineFifo;
  Fifo#(4, AXI4_Lite_WResponse) wresponseQ <- mkPipelineFifo;

  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) loadFailureQ <- mkBypassFifo;
  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) loadSuccessQ <- mkBypassFifo;
  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) storeSuccessQ <- mkBypassFifo;

  Fifo#(LqSize, LqIndex) pendingDmemLoadsQ <- mkPipelineFifo;
  Fifo#(LqSize, LqIndex) pendingMmioLoadsQ <- mkPipelineFifo;

  Fifo#(TAdd#(LqSize, SqSize), LsuTag) tagQ <- mkPipelineFifo;

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

    loadSuccessQ.enq(loadQ.issue(idx, resp));
  endrule

  rule issueStore;
    let result <- storeQ.issue();
    storeSuccessQ.enq(result);
  endrule

  method ActionValue#(Bool) wakeupLoad(MemIssueQueueOutput#(LqIndex) entry);
    Bit#(32) loadAddr = {entry.value[31:2],2'b00};
    Bool loadBlocked =
      stb.search(loadAddr).found ||
      storeQ.search(loadAddr, entry.epoch, entry.age).found;

    if (loadBlocked) return False;
    else begin
      let result <- loadQ.wakeupAddr(entry.id, entry.value);
      case (result) matches
        tagged Success .request : begin
          if (isMMIO(request.addr)) begin
            pendingMmioLoadsQ.enq(entry.id);
            rrequestQ.enq(request);
          end else begin
            pendingDmemLoadsQ.enq(entry.id);
            rrequestQ.enq(request);
          end
        end
        tagged Failure .cause :
          loadFailureQ.enq(tuple2(cause.index, cause.result));
      endcase
      return True;
    end
  endmethod

  method ActionValue#(Bool) wakeupStoreData(MemIssueQueueOutput#(LqIndex) entry);
    storeQ.wakeupData(entry.id, entry.value);
    return True;
  endmethod

  method ActionValue#(Bool) wakeupStoreAddr(MemIssueQueueOutput#(LqIndex) entry);
    storeQ.wakeupAddr(entry.id, entry.value);
    return True;
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

  method ActionValue#(LqIndex) enqLoad(RobIndex idx, Instr instr, Bit#(32) pc, Epoch epoch, Age age);
    case (instr) matches
      tagged Itype {op: tagged Load .ltype} : begin
        let index <- loadQ.enq(LoadQueueEntry{
          signedness: loadSignedness(ltype),
          size: loadSize(ltype),
          epoch: epoch,
          index: idx,
          age: age,
          pc: pc
        });
        tagQ.enq(Load);
        return index;
      end
    endcase
  endmethod

  method ActionValue#(SqIndex) enqStore(RobIndex idx, Instr instr, Bit#(32) pc, Epoch epoch, Age age);
    case (instr) matches
      tagged Stype {op: .stype} : begin
        let index <- storeQ.enq(StoreQueueEntry{
          size: storeSize(stype),
          epoch: epoch,
          index: idx,
          age: age,
          pc: pc
        });
        tagQ.enq(Store);
        return index;
      end
    endcase
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
