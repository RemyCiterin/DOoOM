package STB;

import FIFOF :: *;
import SpecialFIFOs :: *;
import Vector :: *;
import GetPut :: *;

import Utils :: *;
import MemoryTypes :: *;
import Ehr :: *;

interface BufferFIFOF#(numeric type n, type t);
  interface FIFOF#(t) fifo;
  method Vector#(3, Vector#(n, t)) buffer;
  method Vector#(3, Bit#(TAdd#(TLog#(n), 1))) size;
endinterface

module mkPipelineBufferFIFOF(BufferFIFOF#(n, t)) provisos(Bits#(t, size_t));
  Vector#(n, Ehr#(2, t)) data <- replicateM(mkEhr(?));

  Ehr#(2, Bit#(TLog#(n))) nextP <- mkEhr(0);
  Ehr#(2, Bit#(TLog#(n))) firstP <- mkEhr(0);
  Ehr#(3, Bool) empty <- mkEhr(True);
  Ehr#(3, Bool) full <- mkEhr(False);

  Bit#(TLog#(n)) max_index = fromInteger(valueOf(n) - 1);

  // TODO : wrong addr: modulo next_index, not the size of the integer
  function t get_data(Integer instant, Integer index);
    Bit#(TLog#(n)) addr;
    if (instant == 0)
      addr = firstP[0] + fromInteger(index);
    else
      addr = firstP[1] + fromInteger(index);

    if (instant == 2)
      return data[addr][1];
    else
      return data[addr][0];
  endfunction

  function Tuple2#(Bit#(TLog#(n)), Bit#(TLog#(n))) get_first_next(Integer instant);
    if (instant == 0)
      return Tuple2{fst: firstP[0], snd: nextP[0]};
    else if (instant == 1)
      return Tuple2{fst: firstP[1], snd: nextP[0]};
    else
      return Tuple2{fst: firstP[1], snd: nextP[1]};
  endfunction

  function Bit#(TAdd#(TLog#(n), 1)) get_size(Bool is_full, Bit#(TLog#(n)) first, Bit#(TLog#(n)) next);
    if (next >= first) begin
      if (is_full)
        return fromInteger(valueOf(n));
      else
        return zeroExtend(next - first);
    end else begin
      return fromInteger(valueOf(n)) - zeroExtend(first - next);
    end
  endfunction

  interface FIFOF fifo;
    // at instant 0
    method notEmpty = !empty[0];

    method t first if (!empty[0]);
      return data[firstP[0]][0];
    endmethod

    method Action deq if (!empty[0]);
      let next_firstP = ( firstP[0] == max_index ? 0 : firstP[0] + 1 );
      full[0] <= False;

      firstP[0] <= next_firstP;
      if (next_firstP == nextP[0])
        empty[0] <= True;
    endmethod

    // at instant 1
    method notFull = !full[1];

    method Action enq(t val) if (!full[1]);
      let next_nextP = (nextP[0] == max_index ? 0 : nextP[0] + 1);

      data[nextP[0]][0] <= val;
      empty[1] <= False;
      nextP[0] <= next_nextP;

      if (next_nextP == firstP[1])
        full[1] <= True;
    endmethod

    // at instant 2
    method Action clear;
      nextP[1] <= 0;
      firstP[1] <= 0;
      empty[2] <= True;
      full[2] <= False;
    endmethod

  endinterface

  method Vector#(3, Vector#(n, t)) buffer;
    Vector#(3, Vector#(n, t)) ret = replicate(replicate(?));
    Vector#(3, Bit#(TLog#(n))) addr = replicate(?);
    addr[0] = firstP[0];
    addr[1] = firstP[1];
    addr[2] = firstP[2];

    for (Integer i=0; i < valueOf(n); i = i + 1) begin
      ret[0][i] = data[addr[0]][0];
      ret[1][i] = data[addr[1]][0];
      ret[2][i] = data[addr[2]][1];

      for (Integer instant=0; instant < 3; instant = instant + 1) begin
        addr[instant] = (addr[instant] == max_index ? 0 : addr[instant] + 1);
      end
    end

    return ret;
  endmethod

  method Vector#(3, Bit#(TAdd#(TLog#(n), 1))) size;
    Vector#(3, Bit#(TAdd#(TLog#(n), 1))) ret = replicate(?);

    for (Integer instant = 0; instant < 3; instant = instant + 1) begin
      match {.first, .next} = get_first_next(instant);
      ret[instant] = get_size(full[instant], first, next);
    end

    return ret;
  endmethod
endmodule

interface DMEM_Controller;
  // send write request into the speculative memory controller
  method Action wrequest(Bit#(32) addr, Bit#(32) data, Data_Size size);

  // commit a write request from the speculative memory controller
  method Action wcommit(Bool commit);

  // send a read request to the speculative memory controller
  method Action rrequest(Bit#(32) addr, Data_Size size);

  // reveive a read response from the speculative memory controller
  method ActionValue#(Bit#(32)) rresponse;

  // memory write port
  interface Riscv_Write_Master wr_port;

  // memory read port
  interface Riscv_Read_Master rd_port;
endinterface

typedef union tagged {
  Riscv_RRequest RdReq; // process a read request
  Riscv_WRequest WrReq; // process a write request
  Riscv_WRequest WrCom; // process a write commit
  void Idle;
} State deriving(Bits, Eq, FShow);

typedef struct {
  // we found a collision with the storeQ or stb so we can't read at this address
  Bool found;
  // the value or the address are equals so we can forward the data
  Maybe#(Bit#(32)) forward;
} STB_SearchResult deriving(Eq, FShow, Bits);

typedef 10 BuffSize;

module mkMiniSTB(DMEM_Controller);
  FIFOF#(Riscv_WRequest) storeQ <- mkPipelineFIFOF;
  FIFOF#(Riscv_RRequest) loadQ <- mkPipelineFIFOF;
  FIFOF#(Riscv_WRequest) stb <- mkBypassFIFOF;

  FIFOF#(Bool) have_forward <- mkSizedBypassFIFOF(2);
  FIFOF#(Bit#(32)) forward <- mkSizedBypassFIFOF(2);

  FIFOF#(Riscv_WRequest) wr_request_fifo <- mkBypassFIFOF;
  FIFOF#(Riscv_RRequest) rd_request_fifo <- mkBypassFIFOF;
  FIFOF#(Riscv_WResponse) wr_response_fifo <- mkPipelineFIFOF;
  FIFOF#(Riscv_RResponse) rd_response_fifo <- mkPipelineFIFOF;

  Reg#(Bit#(32)) cycle <- mkReg(0);

  function Bool compatible(Bit#(32) addr1, Bit#(32) addr2);
    Int#(32) diff = unpack(addr1 - addr2);
    return diff < -3 || diff > 3;
  endfunction

  function STB_SearchResult searchLoad(Bit#(32) addr, Data_Size size);
    STB_SearchResult ret = STB_SearchResult{
      forward: Invalid,
      found: False
    };

    if (stb.notEmpty) begin
      if (!compatible(addr, stb.first.addr))
        ret.found = True;

      //if (addr == stb.first.addr && stb.first.size == Word)
      //  ret.forward = tagged Valid stb.first.bytes;
    end

    if (storeQ.notEmpty) begin
      // Their is no storeQ forwarding because the elements
      // of the storeQ may be mispredicted
      if (!compatible(addr, storeQ.first.addr)) begin
        ret.forward = Invalid;
        ret.found = True;
      end
    end

    return ret;
  endfunction

  rule increase_cycle;
    cycle <= cycle + 1;
  endrule

  rule write_response;
    wr_response_fifo.deq;
    stb.deq;
  endrule

  method Action rrequest(Bit#(32) addr, Data_Size size);
    action
      let req = Riscv_RRequest{addr: addr, size: size};

      let result = searchLoad(addr, size);

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

  method Action wrequest(Bit#(32) addr, Bit#(32) data, Data_Size size);
    action
      let req = Riscv_WRequest{addr: addr, bytes: data, size: size};
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

  interface Riscv_Write_Master wr_port;
    interface request = toGet(wr_request_fifo);
    interface response = toPut(wr_response_fifo);
  endinterface

  interface Riscv_Read_Master rd_port;
    interface request = toGet(rd_request_fifo);
    interface response = toPut(rd_response_fifo);
  endinterface
endmodule

endpackage
