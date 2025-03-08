import FIFOF :: *;
import SpecialFIFOs :: *;
import AXI4_Lite :: *;
import Vector :: *;
import GetPut :: *;
import AXI4 :: *;

import Utils :: *;
import MemoryTypes :: *;
import Ehr :: *;
import Fifo :: *;
import BCache :: *;

interface DMEM_Controller;
  // send write request into the speculative memory controller, input address
  // must be aligned on one word
  method Action wrequest(Bit#(32) addr, Bit#(32) data, Bit#(4) mask);

  // commit a write request from the speculative memory controller
  method Action wcommit(Bool commit);

  // send a read request to the speculative memory controller, address must be
  // word aligned
  method Action rrequest(Bit#(32) addr);

  // reveive a read response from the speculative memory controller
  method ActionValue#(Bit#(32)) rresponse;

  interface WrAXI4_Lite_Master#(32, 4) wr_mmio;
  interface RdAXI4_Lite_Master#(32, 4) rd_mmio;
  interface WrAXI4_Master#(4, 32, 4) wr_dmem;
  interface RdAXI4_Master#(4, 32, 4) rd_dmem;

  (* always_enabled, always_ready *)
  method Bool emptySTB;
endinterface

typedef struct {
  // we found a collision with the storeQ or stb so we can't read at this address
  Bool found;
  // the value or the address are equals so we can forward the data
  Maybe#(Bit#(32)) forward;
} STB_SearchResult deriving(Eq, FShow, Bits);

(* synthesize *)
module mkMiniSTB(DMEM_Controller);
  Fifo#(1, AXI4_Lite_WRequest#(32, 4)) storeQ <- mkPipelinePFifo;
  Fifo#(2, AXI4_Lite_RRequest#(32)) loadQ <- mkPipelinePFifo;
  Fifo#(1, AXI4_Lite_WRequest#(32, 4)) stb <- mkPipelinePFifo;

  Fifo#(2, Maybe#(Bit#(32))) forwardQ <- mkPipelineFifo;

  Fifo#(1, AXI4_Lite_WRequest#(32, 4)) wrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_Lite_RRequest#(32)) rrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_Lite_WResponse) wresponseQ <- mkPipelineFifo;
  Fifo#(1, AXI4_Lite_RResponse#(4)) rresponseQ <- mkPipelineFifo;

  let cache <- mkDefaultBCache();

  Fifo#(4, Bool) isStoreMMIO <- mkPipelineFifo;
  Fifo#(4, Bool) isLoadMMIO <- mkPipelineFifo;

  function Action enqLoad(AXI4_Lite_RRequest#(32) req);
    action
      isLoadMMIO.enq(isMMIO(req.addr));
      if (isMMIO(req.addr)) rrequestQ.enq(req);
      else cache.cpu_read.request.put(req);
    endaction
  endfunction

  function Action enqStore(AXI4_Lite_WRequest#(32, 4) req);
    action
      isStoreMMIO.enq(isMMIO(req.addr));
      if (isMMIO(req.addr)) wrequestQ.enq(req);
      else cache.cpu_write.request.put(req);
    endaction
  endfunction

  function ActionValue#(AXI4_Lite_RResponse#(4)) deqLoad();
    actionvalue
      AXI4_Lite_RResponse#(4) ret = ?;
      if (isLoadMMIO.first) ret <- toGet(rresponseQ).get();
      else ret <- cache.cpu_read.response.get();
      isLoadMMIO.deq();
      return ret;
    endactionvalue
  endfunction

  function ActionValue#(AXI4_Lite_WResponse) deqStore();
    actionvalue
      AXI4_Lite_WResponse ret = ?;
      if (isStoreMMIO.first) ret <- toGet(wresponseQ).get();
      else ret <- cache.cpu_write.response.get();
      isStoreMMIO.deq();
      return ret;
    endactionvalue
  endfunction

  function STB_SearchResult searchLoad(Bit#(32) addr);
    STB_SearchResult ret = STB_SearchResult{
      forward: Invalid,
      found: False
    };

    if (stb.canDeq) begin
      ret.found = True;
      //if (addr == stb.first.addr)
      //  ret.found = True;
    end

    if (storeQ.canDeq) begin
      ret.found = True;
      // Their is no storeQ forwarding because the elements
      // of the storeQ may be mispredicted
      //if (addr == storeQ.first.addr) begin
      //  ret.forward = Invalid;
      //  ret.found = True;
      //end
    end

    return ret;
  endfunction

  rule setID1;
    cache.setID(1);
  endrule

  rule write_response;
    let _ <- deqStore();
    stb.deq;
  endrule

  method Action rrequest(Bit#(32) addr);
    action
      let req = AXI4_Lite_RRequest{addr: addr};

      let result = searchLoad(addr);

      case (result.forward) matches
        tagged Valid .data : begin
          forwardQ.enq(Valid(data));
          //when(False, noAction);
        end
        Invalid : begin
          if (result.found)
            when(False, noAction);
          else begin
            forwardQ.enq(Invalid);
            enqLoad(req);
          end
        end
      endcase
    endaction
  endmethod

  method ActionValue#(Bit#(32)) rresponse;
    forwardQ.deq;
    if (forwardQ.first matches tagged Valid .resp)
      return resp;
    else begin
      let resp <- deqLoad();
      return resp.bytes;
    end
  endmethod

  method Action wrequest(Bit#(32) addr, Bit#(32) data, Bit#(4) mask);
    action
      let req = AXI4_Lite_WRequest{addr: addr, bytes: data, strb: mask};
      storeQ.enq(req);
    endaction
  endmethod

  method Action wcommit(Bool commit);
    action
      let req = storeQ.first;
      storeQ.deq;

      if (commit) begin
        enqStore(req);
        stb.enq(req);
      end
    endaction
  endmethod

  interface WrAXI4_Lite_Master wr_mmio;
    interface request = toGet(wrequestQ);
    interface response = toPut(wresponseQ);
  endinterface

  interface RdAXI4_Lite_Master rd_mmio;
    interface request = toGet(rrequestQ);
    interface response = toPut(rresponseQ);
  endinterface

  interface rd_dmem = cache.mem_read;
  interface wr_dmem = cache.mem_write;

  method Bool emptySTB = !stb.canDeq;
endmodule
