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

  // Receive an invalidation request from the CPU
  method Action invalidate(Bit#(32) addr);

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

interface StoreBuffer#(numeric type size);
  method Action enq(Bit#(32) addr, Bit#(32) data, Bit#(4) mask);
  method ActionValue#(Tuple3#(Bit#(32),Bit#(32),Bit#(4))) deq();
  method Bool search(Bit#(32) addr);
  method Bool isEmpty;
endinterface

module mkStoreBuffer#(Integer validPort, Integer addrPort) (StoreBuffer#(size));
  Vector#(size, Ehr#(2, Bit#(32))) addr <- replicateM(mkEhr(?));
  Vector#(size, Reg#(Bit#(32))) data <- replicateM(mkReg(?));
  Vector#(size, Reg#(Bit#(4))) mask <- replicateM(mkReg(?));
  Reg#(Bit#(TLog#(size))) head <- mkReg(0);
  Reg#(Bit#(TLog#(size))) tail <- mkReg(0);
  Ehr#(3, Bit#(size)) valid <- mkEhr(0);

  method Action enq(Bit#(32) a, Bit#(32) d, Bit#(4) m) if (valid[1][tail] == 0);
    tail <= tail == fromInteger(valueof(size)-1) ? 0 : tail + 1;
    valid[1][tail] <= 1;

    addr[tail][0] <= a;
    data[tail] <= d;
    mask[tail] <= m;
  endmethod

  method ActionValue#(Tuple3#(Bit#(32),Bit#(32),Bit#(4))) deq if (valid[0][head] == 1);
    head <= head == fromInteger(valueof(size)-1) ? 0 : head + 1;
    valid[0][head] <= 0;

    return tuple3(addr[head][0], data[head], mask[head]);
  endmethod

  method Bool search(Bit#(32) a);
    return valid[validPort] != 0;
    //Bool ret = False;

    //for (Integer i=0; i < valueOf(size); i = i + 1) begin
    //  if (valid[validPort][i] == 1)// && addr[i][addrPort] == a)
    //    ret = True;
    //end

    //return ret;
  endmethod

  method Bool isEmpty = valid[1] == 0;
endmodule

(* synthesize *)
module mkMiniSTB(DMEM_Controller);
  StoreBuffer#(3) storeQ <- mkStoreBuffer(0, 0);
  StoreBuffer#(3) stb <- mkStoreBuffer(1, 0);

  Fifo#(8, Maybe#(Bit#(32))) forwardQ <- mkFifo;

  Fifo#(2, AXI4_Lite_WRequest#(32, 4)) wrequestQ <- mkFifo;
  Fifo#(2, AXI4_Lite_RRequest#(32)) rrequestQ <- mkFifo;
  Fifo#(2, AXI4_Lite_WResponse) wresponseQ <- mkFifo;
  Fifo#(2, AXI4_Lite_RResponse#(4)) rresponseQ <- mkFifo;

  let cache <- mkDefaultBCache();

  Fifo#(1, void) invalidateQ <- mkPipelineFifo;

  Fifo#(4, Bool) isStoreMMIO <- mkFifo;
  Fifo#(8, Bool) isLoadMMIO <- mkFifo;

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

    if (stb.search(addr) || storeQ.search(addr))
      ret.found = True;

    return ret;
  endfunction

  rule setID1;
    cache.setID(1);
  endrule

  rule invalidateAck;
    cache.invalidateAck();
    invalidateQ.deq();
  endrule

  rule write_response;
    let _1 <- deqStore();
    let _2 <- stb.deq;
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
    storeQ.enq(addr, data, mask);
  endmethod

  method Action wcommit(Bool commit);
    match {.addr, .data, .mask} <- storeQ.deq;
    let req = AXI4_Lite_WRequest{addr: addr, bytes: data, strb: mask};

    if (commit) begin
      stb.enq(addr, data, mask);
      enqStore(req);
    end
  endmethod

  method Action invalidate(Bit#(32) addr);
    cache.invalidate(addr);
    invalidateQ.enq(?);
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

  method Bool emptySTB = stb.isEmpty && invalidateQ.canEnq;
endmodule
