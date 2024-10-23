package TestBench;

import Core :: *;
import AXI4 :: *;
import AXI4_Lite :: *;
import Utils :: *;

import SpecialFIFOs :: *;
import RegFile :: *;
import GetPut :: *;
import FIFOF :: *;
import UART :: *;
import Ehr :: *;
import Screen :: *;

interface AXI4_Slave#(numeric type idBits, numeric type addrBits, numeric type dataBytes);
  interface RdAXI4_Slave#(idBits, addrBits, dataBytes) read;
  interface WrAXI4_Slave#(idBits, addrBits, dataBytes) write;
endinterface

interface AXI4_Lite_Slave#(numeric type addrBits, numeric type dataBytes);
  interface RdAXI4_Lite_Slave#(addrBits, dataBytes) read;
  interface WrAXI4_Lite_Slave#(addrBits, dataBytes) write;
endinterface


interface VGA_AXI4_Lite;
  interface VGAFabric fabric;

  interface AXI4_Lite_Slave#(32, 4) axi4;
endinterface

module mkVGA_AXI4_Lite#(Bit#(32) vga_addr) (VGA_AXI4_Lite);
  let vga <- mkVGA;

  FIFOF#(AXI4_Lite_RRequest#(32)) rrequest <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_RResponse#(4)) rresponse <- mkBypassFIFOF;

  FIFOF#(AXI4_Lite_WRequest#(32, 4)) wrequest <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_WResponse) wresponse <- mkBypassFIFOF;

  rule read;
    let req = rrequest.first;
    rrequest.deq;

    rresponse.enq(AXI4_Lite_RResponse{
      bytes: 0, resp: OKAY
    });
  endrule

  rule write;
    let req = wrequest.first;
    wrequest.deq;

    //$display("write vga at: %h %h %h", req.addr - vga_addr, req.bytes, req.strb);
    vga.write((req.addr - vga_addr) >> 2, req.bytes, req.strb);
    wresponse.enq(AXI4_Lite_WResponse{resp: OKAY});
  endrule

  interface AXI4_Lite_Slave axi4;
    interface RdAXI4_Lite_Slave read;
      interface request = toPut(rrequest);
      interface response = toGet(rresponse);
    endinterface

    interface WrAXI4_Lite_Slave write;
      interface request = toPut(wrequest);
      interface response = toGet(wresponse);
    endinterface
  endinterface

  method fabric = vga.fabric;
endmodule

interface Btn;
  (* always_ready, always_enabled, prefix= "" *)
  method Action fabric((* port= "btn" *) Bit#(6) btn);

  method Action interrupt;

  interface AXI4_Lite_Slave#(32, 4) axi4;
endinterface

module mkBtn#(Bit#(32) btn_addr) (Btn);
  Ehr#(2, Bit#(6)) ehr <- mkEhr(?);

  FIFOF#(AXI4_Lite_RRequest#(32)) rrequest <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_RResponse#(4)) rresponse <- mkBypassFIFOF;

  FIFOF#(AXI4_Lite_WRequest#(32, 4)) wrequest <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_WResponse) wresponse <- mkBypassFIFOF;

  rule read;
    let req = rrequest.first;
    rrequest.deq;

    rresponse.enq(AXI4_Lite_RResponse{
      bytes: (req.addr == btn_addr ? zeroExtend(ehr[1]) : 0), resp: OKAY
    });
  endrule

  rule write;
    let req = wrequest.first;
    wresponse.enq(AXI4_Lite_WResponse{resp: OKAY});
    wrequest.deq;
  endrule

  method Action interrupt if (ehr[1] != ehr[0]);
    noAction;
  endmethod

  interface AXI4_Lite_Slave axi4;
    interface RdAXI4_Lite_Slave read;
      interface request = toPut(rrequest);
      interface response = toGet(rresponse);
    endinterface

    interface WrAXI4_Lite_Slave write;
      interface request = toPut(wrequest);
      interface response = toGet(wresponse);
    endinterface
  endinterface

`ifdef BSIM
  method Action fabric(Bit#(6) value);
    noAction;
  endmethod
`else
  method fabric = ehr[0]._write;
`endif
endmodule

interface UART;
  (* always_ready, always_enabled *)
  method Action receive(Bit#(1) data);

  (* always_ready, always_enabled *)
  method Bit#(1) transmit;

  (* always_ready, always_enabled *)
  method Bit#(8) leds;

  // When this action fire, it must
  // set the interrupt bit of the CPU
  // to imform we receive a data from
  // the UART
  method Action interrupt;

  interface AXI4_Lite_Slave#(32, 4) axi4;
endinterface

typedef union tagged {
  void IDLE;
  struct{
    AXI4_RRequest#(4, 32) req;
    Bit#(8) init_length;
  } Read;
  struct{
    AXI4_AWRequest#(4, 32) req;
    Bit#(8) init_length;
  } Write;
} RomState deriving(Bits, FShow, Eq);

// This module return the value {24'b0, last_rx_data} if we try to read it at uart_addr
module mkUART#(Bit#(32) uart_addr) (UART);
  let rx_uart <- mkRxUART(217);
  let tx_uart <- mkTxUART(217);

  Ehr#(2, Bit#(8)) data <- mkEhr(0);

  FIFOF#(AXI4_Lite_RRequest#(32)) rrequest <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_RResponse#(4)) rresponse <- mkBypassFIFOF;

  FIFOF#(AXI4_Lite_WRequest#(32, 4)) wrequest <- mkPipelineFIFOF;
  FIFOF#(AXI4_Lite_WResponse) wresponse <- mkBypassFIFOF;

  Reg#(Bit#(32)) cycle <- mkReg(0);

  rule cycleCount;
    cycle <= cycle+1;
  endrule

`ifndef BSIM
  rule update_data;
    data[0] <= rx_uart.data;
  endrule
`endif

  rule read;
    let req = rrequest.first;
    rrequest.deq;

    if (req.addr == uart_addr) begin
      rresponse.enq(AXI4_Lite_RResponse{
        bytes: {0, data[1]}, resp: OKAY
      });
    end else begin
      rresponse.enq(AXI4_Lite_RResponse{
        bytes: 0, resp: OKAY
      });
    end
  endrule

  rule write;
    let req = wrequest.first;
    wrequest.deq;

    if (req.addr == uart_addr && req.strb[0] == 1) begin
      `ifndef BSIM
      tx_uart.put(truncate(req.bytes));
      `endif
      $write("%c", req.bytes[7:0]);

      if (req.bytes[7:0] == 0) begin
        $display("finsih at cycle %d", cycle);
        $finish;
      end
    end

    wresponse.enq(AXI4_Lite_WResponse{resp: OKAY});
  endrule

  interface AXI4_Lite_Slave axi4;
    interface RdAXI4_Lite_Slave read;
      interface request = toPut(rrequest);
      interface response = toGet(rresponse);
    endinterface

    interface WrAXI4_Lite_Slave write;
      interface request = toPut(wrequest);
      interface response = toGet(wresponse);
    endinterface
  endinterface


  method leds = rx_uart.leds;

  method transmit = tx_uart.transmit;
  method receive = rx_uart.receive;

`ifdef BSIM
  method Action interrupt = noAction;
`else
  method Action interrupt if (rx_uart.valid);
    rx_uart.ack;
  endmethod
`endif
endmodule



typedef struct {
  String name;
  Bit#(32) start;
  Bit#(32) size;
} RomConfig;

module mkRom#(RomConfig conf) (AXI4_Slave#(4, 32, 4));
  RegFile#(Bit#(32), Bit#(32)) rf <- mkRegFileLoad(conf.name, 0, conf.size / 4 - 1);

  FIFOF#(AXI4_RRequest#(4, 32)) rrequest <- mkBypassFIFOF;
  FIFOF#(AXI4_RResponse#(4, 4)) rresponse <- mkBypassFIFOF;

  FIFOF#(AXI4_WRequest#(4)) wrequest <- mkBypassFIFOF;
  FIFOF#(AXI4_AWRequest#(4, 32)) awrequest <- mkBypassFIFOF;
  FIFOF#(AXI4_WResponse#(4)) wresponse <- mkBypassFIFOF;

  Ehr#(2, RomState) state <- mkEhr(IDLE);

  function Bit#(32) getAddr(Bit#(32) addr);
    return (addr - conf.start) >> 2;
  endfunction

  function Bool inBounds(Bit#(32) addr);
    return addr >= conf.start && addr < conf.start + conf.size;
  endfunction

  function Bit#(32) currentAddr;
    return case (state[0]) matches
      tagged Read{req: .req} : inBounds(req.addr) ? getAddr(req.addr) : 0;
      tagged Write{req: .req} : inBounds(req.addr) ? getAddr(req.addr) : 0;
      default: 0;
    endcase;
  endfunction


  rule step;
    let currentData = rf.sub(currentAddr);
    case (state[0]) matches
      tagged Read {req: .req, init_length: .length} : begin
        Bit#(32) next_addr = axi4NextAddr(4, req.addr, req.burst, length);

        //$display("read addr: %h next_addr: %h length: %h data: %h id: %d", req.addr, next_addr, length, rf.sub(getAddr(req.addr)), req.id);

        rresponse.enq(AXI4_RResponse{
          bytes: currentData,
          last: req.length == 0,
          id: req.id,
          resp: OKAY
        });

        state[0] <= (req.length == 0 ? IDLE : tagged Read {init_length: length, req: AXI4_RRequest{
          length: req.length - 1,
          burst: req.burst,
          addr: next_addr,
          id: req.id
        }});
      end
      tagged Write {req: .awreq, init_length: .length} : begin
        Bit#(32) next_addr = axi4NextAddr(4, awreq.addr, awreq.burst, length);

        let wreq = wrequest.first;
        wrequest.deq;

        let bytes = currentData;
        let new_bytes = filterStrb(bytes, wreq.bytes, wreq.strb);

        if (inBounds(awreq.addr))
          rf.upd(getAddr(awreq.addr), new_bytes);

        //$display("write addr: %h data: %h length: %d, id: %d", awreq.addr, new_bytes, awreq.length, awreq.id);

        if (awreq.length == 0)
          wresponse.enq(AXI4_WResponse{resp: OKAY, id: awreq.id});

        state[0] <= (awreq.length == 0 ? IDLE : tagged Write {init_length: length, req: AXI4_AWRequest{
          length: awreq.length - 1,
          burst: awreq.burst,
          addr: next_addr,
          id: awreq.id
        }});
      end
      default: noAction;
    endcase
  endrule

  rule enq if (state[1] == IDLE);
    if (rrequest.notEmpty) begin
      state[1] <= tagged Read {req: rrequest.first, init_length: rrequest.first.length};
      rrequest.deq;
    end else begin
      state[1] <= tagged Write {req: awrequest.first, init_length: awrequest.first.length};
      awrequest.deq;
    end
  endrule

  interface RdAXI4_Slave read;
    interface request = toPut(rrequest);
    interface response = toGet(rresponse);
  endinterface

  interface WrAXI4_Slave write;
    interface awrequest = toPut(awrequest);
    interface wrequest = toPut(wrequest);
    interface response = toGet(wresponse);
  endinterface
endmodule

endpackage
