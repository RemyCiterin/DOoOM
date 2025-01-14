import FIFOF :: *;
import SpecialFIFOs :: *;
import AXI4_Lite :: *;
import Vector :: *;
import GetPut :: *;

import Utils :: *;
import MemoryTypes :: *;
import Ehr :: *;
import Fifo :: *;

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

  interface WrAXI4_Lite_Master#(32, 4) wr_port;
  interface RdAXI4_Lite_Master#(32, 4) rd_port;
endinterface

typedef struct {
  // we found a collision with the storeQ or stb so we can't read at this address
  Bool found;
  // the value or the address are equals so we can forward the data
  Maybe#(Bit#(32)) forward;
} STB_SearchResult deriving(Eq, FShow, Bits);

module mkMiniSTB(DMEM_Controller);
  FIFOF#(AXI4_Lite_WRequest#(32, 4)) storeQ <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_RRequest#(32)) loadQ <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_WRequest#(32, 4)) stb <- mkBypassFIFOF;

  Fifo#(2, Bool) have_forward <- mkPipelineFifo;
  Fifo#(2, Bit#(32)) forward <- mkPipelineFifo;

  FIFOF#(AXI4_Lite_WRequest#(32, 4)) wr_request_fifo <- mkBypassFIFOF;
  FIFOF#(AXI4_Lite_RRequest#(32)) rd_request_fifo <- mkBypassFIFOF;
  FIFOF#(AXI4_Lite_WResponse) wr_response_fifo <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_RResponse#(4)) rd_response_fifo <- mkPipelineFIFOF;

  function STB_SearchResult searchLoad(Bit#(32) addr);
    STB_SearchResult ret = STB_SearchResult{
      forward: Invalid,
      found: False
    };

    if (stb.notEmpty) begin
      if (addr == stb.first.addr)
        ret.found = True;
    end

    if (storeQ.notEmpty) begin
      // Their is no storeQ forwarding because the elements
      // of the storeQ may be mispredicted
      if (addr == storeQ.first.addr) begin
        ret.forward = Invalid;
        ret.found = True;
      end
    end

    return ret;
  endfunction

  rule write_response;
    wr_response_fifo.deq;
    stb.deq;
  endrule

  method Action rrequest(Bit#(32) addr);
    action
      let req = AXI4_Lite_RRequest{addr: addr};

      let result = searchLoad(addr);

      case (result.forward) matches
        tagged Valid .data : begin
          have_forward.enq(True);
          forward.enq(data);
          //when(False, noAction);
        end
        Invalid : begin
          if (result.found)
            when(False, noAction);
          else begin
            have_forward.enq(False);
            rd_request_fifo.enq(req);
          end
        end
      endcase
    endaction
  endmethod

  method ActionValue#(Bit#(32)) rresponse;
    actionvalue
      if (have_forward.first) begin
        let resp = forward.first;
        have_forward.deq;
        forward.deq;
        return resp;
      end else begin
        let resp = rd_response_fifo.first;
        rd_response_fifo.deq;
        have_forward.deq;
        return resp.bytes;
      end
    endactionvalue
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
        wr_request_fifo.enq(req);
        stb.enq(req);
      end
    endaction
  endmethod

  interface WrAXI4_Lite_Master wr_port;
    interface request = toGet(wr_request_fifo);
    interface response = toPut(wr_response_fifo);
  endinterface

  interface RdAXI4_Lite_Master rd_port;
    interface request = toGet(rd_request_fifo);
    interface response = toPut(rd_response_fifo);
  endinterface
endmodule
