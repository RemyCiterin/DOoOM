package AXI4_Lite_Adapter;

import AXI4_Lite :: *;
import AXI4 :: *;
import Utils :: *;
import Connectable :: *;
import FIFOF :: *;
import SpecialFIFOs :: *;
import GetPut :: *;
import Vector :: *;
import Fifo :: *;
import Ehr :: *;

import MemoryTypes :: *;

// First we must define a type of RISC-V like requests
// (using Byte, Half or Word with the RISC-V alignment convention)


function Bit#(4) riscv_to_AXI4_StrbFst(Bit#(2) addr_offset, Data_Size size);
  return case (Tuple2{fst: addr_offset, snd: size}) matches
    Tuple2{fst: 2'b00, snd: Byte} : 4'b0001;
    Tuple2{fst: 2'b00, snd: Half} : 4'b0011;
    Tuple2{fst: 2'b00, snd: Word} : 4'b1111;

    Tuple2{fst: 2'b01, snd: Byte} : 4'b0010;
    Tuple2{fst: 2'b01, snd: Half} : 4'b0110;
    Tuple2{fst: 2'b01, snd: Word} : 4'b1110;

    Tuple2{fst: 2'b10, snd: Byte} : 4'b0100;
    Tuple2{fst: 2'b10, snd: .*  } : 4'b1100;

    default : 4'b1000;
  endcase;
endfunction

function Bit#(4) riscv_to_AXI4_StrbSnd(Bit#(2) addr_offset, Data_Size size);
  return case (Tuple2{fst: addr_offset, snd: size}) matches
    Tuple2{fst: 2'b01, snd: Word} : 4'b0001;

    Tuple2{fst: 2'b10, snd: Word} : 4'b0011;

    Tuple2{fst: 2'b11, snd: Half} : 4'b0001;
    Tuple2{fst: 2'b11, snd: Word} : 4'b0111;

    default : 4'b0000;
  endcase;
endfunction

function Bit#(32) riscv_to_AXI4_BytesFst(Bit#(2) addr_offset, Bit#(32) bytes);
  return case (addr_offset) matches
    2'b00 : bytes;
    2'b01 : {bytes[23:0], 8'b0};
    2'b10 : {bytes[15:0], 16'b0};
    2'b11 : {bytes[7:0], 24'b0};
  endcase;
endfunction

function Bit#(32) riscv_to_AXI4_BytesSnd(Bit#(2) addr_offset, Bit#(32) bytes);
  return case (addr_offset) matches
    2'b00 : 32'b0;
    2'b01 : {24'b0, bytes[31:24]};
    2'b10 : {16'b0, bytes[31:16]};
    2'b11 : {8'b0, bytes[31:8]};
  endcase;
endfunction

function Bit#(32) riscv_from_AXI4_BytesFst(Bit#(2) addr_offset, Bit#(32) bytes);
  return case (addr_offset) matches
    2'b00 : bytes;
    2'b01 : {bytes[23:0], 8'b0};
    2'b10 : {bytes[15:0], 16'b0};
    2'b11 : {bytes[7:0], 24'b0};
  endcase;
endfunction

function Bit#(32) riscv_from_AXI4_BytesSnd(Bit#(2) addr_offset, Bit#(32) bytes);
  return case (addr_offset) matches
    2'b00 : 32'b0;
    2'b01 : {24'b0, bytes[31:24]};
    2'b10 : {16'b0, bytes[31:16]};
    2'b11 : {8'b0, bytes[31:8]};
  endcase;
endfunction

module mkRiscv_WrAXI4_Lite_Master_Adapter#(Riscv_Write_Master master)(WrAXI4_Lite_Master#(32, 4));
  FIFOF#(AXI4_Lite_WRequest#(32, 4)) next_request <- mkPipelineFIFOF;

  FIFOF#(AXI4_Lite_WRequest#(32, 4)) wrequest <- mkBypassFIFOF;
  FIFOF#(AXI4_Lite_WResponse) wresponse <- mkBypassFIFOF;

  FIFOF#(Bool) req_is_double <- mkSizedBypassFIFOF(32);
  FIFOF#(AXI4_Lite_WResponse) prev_response <- mkPipelineFIFOF;

  rule fst_response_step if (prev_response.notFull);
    let resp = wresponse.first;
    wresponse.deq;

    if (req_is_double.first) begin
      prev_response.enq(resp);
    end else begin
      master.response.put(Riscv_WResponse{resp: (resp.resp == OKAY ? OK : ERR)});
    end

    req_is_double.deq;
  endrule

  rule snd_response_step;
    let resp1 = prev_response.first;
    let resp2 = wresponse.first;
    prev_response.deq;
    wresponse.deq;

    master.response.put(
      Riscv_WResponse{
        resp: (resp1.resp == OKAY && resp2.resp == OKAY ? OK : ERR)
      }
    );
  endrule

  rule snd_request_step;
    let req = next_request.first;
    wrequest.enq(req);
    next_request.deq;
  endrule

  rule fst_request_step if (next_request.notFull);
    let req <- master.request.get;

    wrequest.enq (AXI4_Lite_WRequest{
      bytes: riscv_to_AXI4_BytesFst(req.addr[1:0], req.bytes),
      strb: riscv_to_AXI4_StrbFst(req.addr[1:0], req.size),
      addr: {req.addr[31:2], 2'b00}
    });

    let snd_req = AXI4_Lite_WRequest{
      bytes: riscv_to_AXI4_BytesSnd(req.addr[1:0], req.bytes),
      strb: riscv_to_AXI4_StrbSnd(req.addr[1:0], req.size),
      addr: {req.addr[31:2] + 1, 2'b00}
    };
    //$display("wr addr: %h data: %h", req.addr, req.bytes);

    req_is_double.enq(snd_req.strb != 0);

    if (snd_req.strb != 0) begin
      next_request.enq(snd_req);
    end
  endrule

  interface request = toGet(wrequest);
  interface response = toPut(wresponse);

endmodule


function Bit#(32) riscv_from_AXI4_Bytes(Bit#(2) offset, Bit#(32) bytes_at_addr, Bit#(32) bytes_at_next_addr);
  let b0 = bytes_at_addr;
  let b1 = bytes_at_next_addr;

  return case (offset) matches
    2'b00 : b0;
    2'b01 : { b1[7:0], b0[31:8] };
    2'b10 : { b1[15:0], b0[31:16] };
    2'b11 : { b1[23:0], b0[31:24] };
  endcase;
endfunction


module mkRiscv_RdAXI4_Lite_Master_Adapter#(Riscv_Read_Master master)(RdAXI4_Lite_Master#(32, 4));
  FIFOF#(AXI4_Lite_RRequest#(32)) next_request <- mkPipelineFIFOF;

  FIFOF#(AXI4_Lite_RRequest#(32)) rrequest <- mkBypassFIFOF;
  FIFOF#(AXI4_Lite_RResponse#(4)) rresponse <- mkBypassFIFOF;

  FIFOF#(Bool) req_is_double <- mkSizedBypassFIFOF(8);
  FIFOF#(AXI4_Lite_RResponse#(4)) prev_response <- mkPipelineFIFOF;

  FIFOF#(Bit#(2)) offset_fifo <- mkSizedBypassFIFOF(8);

  rule fst_response_step if (prev_response.notFull);
    let resp = rresponse.first;
    rresponse.deq;

    if (req_is_double.first) begin
      prev_response.enq(resp);
    end else begin
      let offset = offset_fifo.first;
      offset_fifo.deq;

      master.response.put(Riscv_RResponse{
        resp: (resp.resp == OKAY ? OK : ERR),
        bytes: riscv_from_AXI4_Bytes(offset, resp.bytes, 0)
      });
    end

    req_is_double.deq;
  endrule

  rule snd_response_step;
    let resp1 = prev_response.first;
    let resp2 = rresponse.first;
    prev_response.deq;
    rresponse.deq;

    let offset = offset_fifo.first;
    offset_fifo.deq;

    master.response.put(
      Riscv_RResponse{
        resp: (resp1.resp == OKAY && resp2.resp == OKAY ? OK : ERR),
        bytes: riscv_from_AXI4_Bytes(offset, resp1.bytes, resp2.bytes)
      }
    );
  endrule

  rule snd_request_step;
    let req = next_request.first;
    rrequest.enq(req);
    next_request.deq;
  endrule

  rule fst_request_step if (next_request.notFull);
    let req <- master.request.get;

    offset_fifo.enq(req.addr[1:0]);

    rrequest.enq (AXI4_Lite_RRequest{
      addr: {req.addr[31:2], 2'b00}
    });

    let snd_req = AXI4_Lite_RRequest{
      addr: {req.addr[31:2] + 1, 2'b00}
    };

    let strb = riscv_to_AXI4_StrbSnd(req.addr[1:0], req.size);
    req_is_double.enq(strb != 0);

    if (strb != 0) begin
      next_request.enq(snd_req);
    end
  endrule

  interface request = toGet(rrequest);
  interface response = toPut(rresponse);

endmodule


module mkAXI4_Lite_RdAXI4_Master_Adapter
  #(RdAXI4_Lite_Master#(addrBits, dataBytes) master, Bit#(idBits) id)
  (RdAXI4_Master#(idBits, addrBits, dataBytes));

  interface Get request;

    method ActionValue#(AXI4_RRequest#(idBits, addrBits)) get;
      actionvalue
        let req <- master.request.get;
        return AXI4_RRequest{
          addr: req.addr,
          burst: FIXED,
          length: 0,
          id: id
        };
      endactionvalue
    endmethod
  endinterface

  interface Put response;
    method Action put(AXI4_RResponse#(idBits, dataBytes) resp);
      action
        if (resp.id != id || !resp.last)
          $display("resp must have the id %h and last must be set to true: ", fshow(resp));
        master.response.put(AXI4_Lite_RResponse{
          bytes: resp.bytes,
          resp: unpack(pack(resp.resp))
        });
      endaction
    endmethod
  endinterface
endmodule

module mkAXI4_Lite_WrAXI4_Master_Adapter
  #(WrAXI4_Lite_Master#(addrBits, dataBytes) master, Bit#(idBits) id)
  (WrAXI4_Master#(idBits, addrBits, dataBytes));

  FIFOF#(AXI4_AWRequest#(idBits, addrBits)) awrequest_fifo <- mkBypassFIFOF;
  FIFOF#(AXI4_WRequest#(dataBytes)) wrequest_fifo <- mkBypassFIFOF;

  rule deq_request;
    let req <- master.request.get;

    awrequest_fifo.enq(AXI4_AWRequest{
      addr: req.addr,
      burst: FIXED,
      length: 0,
      id: id
    });

    wrequest_fifo.enq(AXI4_WRequest{
      bytes: req.bytes,
      strb: req.strb,
      last: True
    });
  endrule

  interface wrequest = toGet(wrequest_fifo);
  interface awrequest = toGet(awrequest_fifo);

  interface Put response;
    method Action put(AXI4_WResponse#(idBits) resp);
      action
        if (resp.id != id)
          $display("resp must have the id %h: ", fshow(resp));
        master.response.put(AXI4_Lite_WResponse{
          resp: unpack(pack(resp.resp))
        });
      endaction
    endmethod
  endinterface
endmodule

// N * M interconnect that receive the mesages in order
module mkXBarRdAXI4_Lite#(
    Vector#(nMaster, RdAXI4_Lite_Master#(aW, dW)) masters,
    Vector#(nSlave, RdAXI4_Lite_Slave#(aW, dW)) slaves,
    function Bit#(TLog#(nSlave)) dispatch(AXI4_Lite_RRequest#(aW) req)
  ) (Empty);

  Vector#(nMaster, FIFOF#(AXI4_Lite_RRequest#(aW))) requests;

  Vector#(nMaster, Fifo#(4, Bit#(TLog#(nSlave)))) receiveRspFrom;
  Vector#(nSlave, Fifo#(4, Bit#(TLog#(nMaster)))) sendRspTo;

  for (Integer i=0; i < valueOf(nMaster); i = i + 1) begin
    receiveRspFrom[i] <- mkPipelineFifo;
    requests[i] <- mkBypassFIFOF;
  end

  for (Integer i=0; i < valueOf(nSlave); i = i + 1) begin
    sendRspTo[i] <- mkPipelineFifo;
  end

  function Bool receiveGuard(Integer i, Integer j);
    if (valueOf(nSlave) == 1 && valueOf(nMaster) == 1)
      return True;
    else if (valueOf(nSlave) == 1)
      return sendRspTo[j].first == fromInteger(i);
    else if (valueOf(nMaster) == 1)
      return receiveRspFrom[i].first == fromInteger(j);
    else
      return
        sendRspTo[j].first == fromInteger(i) &&
        receiveRspFrom[i].first == fromInteger(j);
  endfunction

  for (Integer i=0; i < valueOf(nMaster); i = i + 1) begin

    rule deqRequest;
      let req <- masters[i].request.get;
      requests[i].enq(req);
    endrule

    for (Integer j=0; j < valueOf(nSlave); j = j + 1) begin

      rule sendRequest
        if (valueOf(nSlave) == 1 || dispatch(requests[i].first) == fromInteger(j));
        receiveRspFrom[i].enq(fromInteger(j));
        sendRspTo[j].enq(fromInteger(i));

        slaves[j].request.put(requests[i].first);
        requests[i].deq;
      endrule

      rule receiveResponse
        if (receiveGuard(i, j));
        let rsp <- slaves[j].response.get;
        masters[i].response.put(rsp);

        receiveRspFrom[i].deq;
        sendRspTo[j].deq;
      endrule
    end
  end
endmodule

// N * M interconnect that receive the mesages in order
module mkXBarWrAXI4_Lite#(
    Vector#(nMaster, WrAXI4_Lite_Master#(aW, dW)) masters,
    Vector#(nSlave, WrAXI4_Lite_Slave#(aW, dW)) slaves,
    function Bit#(TLog#(nSlave)) dispatch(AXI4_Lite_WRequest#(aW, dW) req)
  ) (Empty);

  Vector#(nMaster, FIFOF#(AXI4_Lite_WRequest#(aW, dW))) requests;

  Vector#(nMaster, Fifo#(4, Bit#(TLog#(nSlave)))) receiveRspFrom;
  Vector#(nSlave, Fifo#(4, Bit#(TLog#(nMaster)))) sendRspTo;

  for (Integer i=0; i < valueOf(nMaster); i = i + 1) begin
    receiveRspFrom[i] <- mkPipelineFifo;
    requests[i] <- mkBypassFIFOF;
  end

  for (Integer i=0; i < valueOf(nSlave); i = i + 1) begin
    sendRspTo[i] <- mkPipelineFifo;
  end

  function Bool receiveGuard(Integer i, Integer j);
    if (valueOf(nSlave) == 1 && valueOf(nMaster) == 1)
      return True;
    else if (valueOf(nSlave) == 1)
      return sendRspTo[j].first == fromInteger(i);
    else if (valueOf(nMaster) == 1)
      return receiveRspFrom[i].first == fromInteger(j);
    else
      return
        sendRspTo[j].first == fromInteger(i) &&
        receiveRspFrom[i].first == fromInteger(j);
  endfunction

  for (Integer i=0; i < valueOf(nMaster); i = i + 1) begin

    rule deqRequest;
      let req <- masters[i].request.get;
      requests[i].enq(req);
    endrule

    for (Integer j=0; j < valueOf(nSlave); j = j + 1) begin

      rule sendRequest
        if (valueOf(nSlave) == 1 || dispatch(requests[i].first) == fromInteger(j));
        receiveRspFrom[i].enq(fromInteger(j));
        sendRspTo[j].enq(fromInteger(i));

        slaves[j].request.put(requests[i].first);
        requests[i].deq;
      endrule

      rule receiveResponse
        if (receiveGuard(i, j));
        let rsp <- slaves[j].response.get;
        masters[i].response.put(rsp);

        receiveRspFrom[i].deq;
        sendRspTo[j].deq;
      endrule
    end
  end
endmodule

// N * M interconnect that receive the mesages in order
module mkXBarRdAXI4#(
    Vector#(nMaster, RdAXI4_Master#(idW, aW, dW)) masters,
    Vector#(nSlave, RdAXI4_Slave#(idW, aW, dW)) slaves,
    function Bit#(TLog#(nSlave)) dispatch(AXI4_RRequest#(idW, aW) req)
  ) (Empty);

  Vector#(nMaster, FIFOF#(AXI4_RRequest#(idW, aW))) requests;

  Vector#(nMaster, Fifo#(4, Bit#(TLog#(nSlave)))) receiveRspFrom;
  Vector#(nSlave, Fifo#(4, Bit#(TLog#(nMaster)))) sendRspTo;

  for (Integer i=0; i < valueOf(nMaster); i = i + 1) begin
    receiveRspFrom[i] <- mkPipelineFifo;
    requests[i] <- mkBypassFIFOF;
  end

  for (Integer i=0; i < valueOf(nSlave); i = i + 1) begin
    sendRspTo[i] <- mkPipelineFifo;
  end

  function Bool receiveGuard(Integer i, Integer j);
    if (valueOf(nSlave) == 1 && valueOf(nMaster) == 1)
      return True;
    else if (valueOf(nSlave) == 1)
      return sendRspTo[j].first == fromInteger(i);
    else if (valueOf(nMaster) == 1)
      return receiveRspFrom[i].first == fromInteger(j);
    else
      return
        sendRspTo[j].first == fromInteger(i) &&
        receiveRspFrom[i].first == fromInteger(j);
  endfunction

  for (Integer i=0; i < valueOf(nMaster); i = i + 1) begin

    rule deqRequest;
      let req <- masters[i].request.get;
      requests[i].enq(req);
    endrule

    for (Integer j=0; j < valueOf(nSlave); j = j + 1) begin

      rule sendRequest
        if (valueOf(nSlave) == 1 || dispatch(requests[i].first) == fromInteger(j));
        receiveRspFrom[i].enq(fromInteger(j));
        sendRspTo[j].enq(fromInteger(i));

        slaves[j].request.put(requests[i].first);
        requests[i].deq;
      endrule

      rule receiveResponse
        if (receiveGuard(i, j));
        let rsp <- slaves[j].response.get;
        masters[i].response.put(rsp);

        if (rsp.last) begin
          receiveRspFrom[i].deq;
          sendRspTo[j].deq;
        end
      endrule
    end
  end
endmodule

// N * M interconnect that receive the messages in order
module mkXBarWrAXI4#(
    Vector#(nMaster, WrAXI4_Master#(idW, aW, dW)) masters,
    Vector#(nSlave, WrAXI4_Slave#(idW, aW, dW)) slaves,
    function Bit#(TLog#(nSlave)) dispatch(AXI4_AWRequest#(idW, aW) req)
  ) (Empty);

  Vector#(nMaster, FIFOF#(AXI4_AWRequest#(idW, aW))) requests;

  Vector#(nMaster, PReg#(2, Maybe#(Bit#(TLog#(nSlave))))) sendDataTo;
  Vector#(nMaster, Fifo#(4, Bit#(TLog#(nSlave)))) receiveRspFrom;
  Vector#(nSlave, Fifo#(4, Bit#(TLog#(nMaster)))) sendRspTo;

  for (Integer i=0; i < valueOf(nMaster); i = i + 1) begin
    receiveRspFrom[i] <- mkPipelineFifo;
    sendDataTo[i] <- mkPReg(Invalid);
    requests[i] <- mkBypassFIFOF;
  end

  for (Integer i=0; i < valueOf(nSlave); i = i + 1) begin
    sendRspTo[i] <- mkPipelineFifo;
  end

  function Bool receiveGuard(Integer i, Integer j);
    if (valueOf(nSlave) == 1 && valueOf(nMaster) == 1)
      return True;
    else if (valueOf(nSlave) == 1)
      return sendRspTo[j].first == fromInteger(i);
    else if (valueOf(nMaster) == 1)
      return receiveRspFrom[i].first == fromInteger(j);
    else
      return
        sendRspTo[j].first == fromInteger(i) &&
        receiveRspFrom[i].first == fromInteger(j);
  endfunction

  for (Integer i=0; i < valueOf(nMaster); i = i + 1) begin

    rule deqRequest;
      let req <- masters[i].awrequest.get;
      requests[i].enq(req);
    endrule

    for (Integer j=0; j < valueOf(nSlave); j = j + 1) begin

      rule sendAWRequest
        if (
          (valueOf(nSlave) == 0 || dispatch(requests[i].first) == fromInteger(j)) &&
          sendDataTo[i][0] == Invalid
        );
        sendDataTo[i][0] <= tagged Valid fromInteger(j);
        receiveRspFrom[i].enq(fromInteger(j));
        sendRspTo[j].enq(fromInteger(i));

        slaves[j].awrequest.put(requests[i].first);
        requests[i].deq;
      endrule

      rule sendWRequest
        if (sendDataTo[i][1] matches tagged Valid .x &&& valueOf(nSlave) == 0 || x == fromInteger(j));
        let req <- masters[i].wrequest.get;
        slaves[j].wrequest.put(req);


        if (req.last)
          sendDataTo[i][1] <= Invalid;
      endrule

      rule receiveResponse
        if (receiveGuard(i, j));
        let rsp <- slaves[j].response.get;
        masters[i].response.put(rsp);

        receiveRspFrom[i].deq;
        sendRspTo[j].deq;
      endrule
    end
  end
endmodule

endpackage
