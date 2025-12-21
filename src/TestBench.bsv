import AXI4 :: *;
import AXI4_Lite :: *;
import Utils :: *;

import BRAMCore :: *;
import GetPut :: *;
import UART :: *;
import Fifo :: *;
import Ehr :: *;
import Screen :: *;
import SdCard :: *;
import SDRAM :: *;

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

  Fifo#(2, AXI4_Lite_RRequest#(32)) rrequest <- mkFifo;
  Fifo#(2, AXI4_Lite_RResponse#(4)) rresponse <- mkFifo;

  Fifo#(2, AXI4_Lite_WRequest#(32, 4)) wrequest <- mkFifo;
  Fifo#(2, AXI4_Lite_WResponse) wresponse <- mkFifo;

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

interface SdCard_AXI4_Lite;
  (* prefix = "" *)
  interface SdCardFab fabric;

  interface AXI4_Lite_Slave#(32, 4) axi4;
endinterface

module mkSdCard#(Bit#(32) sdcard_addr) (SdCard_AXI4_Lite);
  SPI spi <- mkSPI;

  Fifo#(2, AXI4_Lite_RRequest#(32)) rrequest <- mkFifo;
  Fifo#(2, AXI4_Lite_RResponse#(4)) rresponse <- mkFifo;

  Fifo#(2, AXI4_Lite_WRequest#(32, 4)) wrequest <- mkFifo;
  Fifo#(2, AXI4_Lite_WResponse) wresponse <- mkFifo;

  Reg#(Bit#(8)) result <- mkReg(0);

  Reg#(Bool) canAnswer <- mkReg(True);

  rule receive if (!canAnswer);
    let x <- spi.receive;
    canAnswer <= True;
    result <= x;
  endrule

  rule read if (canAnswer);
    let req = rrequest.first;
    rrequest.deq;

    Bit#(32) bytes = 0;

    if (req.addr == sdcard_addr) begin
      bytes[7:0] = result;
    end

    rresponse.enq(AXI4_Lite_RResponse{
      bytes: bytes, resp: OKAY
    });
  endrule

  rule write if (canAnswer);
    let req = wrequest.first;
    wrequest.deq;

    if (req.addr == sdcard_addr) begin
      if (req.strb[0] == 1) begin
        spi.send(req.bytes[7:0]);
        canAnswer <= False;
      end

      if (req.strb[1] == 1) begin
        spi.setCS(req.bytes[15:8] == 0 ? 0 : 1);
      end

      if (req.strb[2] == 1) begin
        spi.setClk(zeroExtend(req.bytes[23:16]));
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

  method fabric = spi.fabric;
endmodule

interface Btn;
  (* always_ready, always_enabled, prefix= "" *)
  method Action fabric((* port= "btn" *) Bit#(6) btn);

  method Action interrupt;

  interface AXI4_Lite_Slave#(32, 4) axi4;
endinterface

module mkBtn#(Bit#(32) btn_addr) (Btn);
  Ehr#(2, Bit#(6)) ehr <- mkEhr(?);

  Fifo#(2, AXI4_Lite_RRequest#(32)) rrequest <- mkFifo;
  Fifo#(2, AXI4_Lite_RResponse#(4)) rresponse <- mkFifo;

  Fifo#(2, AXI4_Lite_WRequest#(32, 4)) wrequest <- mkFifo;
  Fifo#(2, AXI4_Lite_WResponse) wresponse <- mkFifo;

  Reg#(Bit#(6)) cycle <- mkReg(0);

  rule cycle_update;
    cycle <= cycle + 1;
  endrule

  rule read;
    let req = rrequest.first;
    rrequest.deq;

    rresponse.enq(AXI4_Lite_RResponse{
`ifdef BSIM
      bytes: (req.addr == btn_addr ? zeroExtend(cycle) : 0), resp: OKAY
`else
      bytes: (req.addr == btn_addr ? zeroExtend(ehr[1]) : 0), resp: OKAY
`endif
    });
  endrule

  rule write;
    let req = wrequest.first;
    wresponse.enq(AXI4_Lite_WResponse{resp: OKAY});
    wrequest.deq;
  endrule

`ifdef BSIM
  method Action interrupt if (False);
    noAction;
  endmethod
`else
  method Action interrupt if (ehr[1] != ehr[0]);
    noAction;
  endmethod
`endif

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
module mkUART#(Bit#(32) cycle_per_bit, Bit#(32) uart_addr) (UART);
  let rx_uart <- mkRxUART(cycle_per_bit);
  let tx_uart <- mkTxUART(cycle_per_bit);

  Ehr#(2, Bit#(8)) data <- mkEhr(0);

  Fifo#(2, AXI4_Lite_RRequest#(32)) rrequest <- mkFifo;
  Fifo#(2, AXI4_Lite_RResponse#(4)) rresponse <- mkFifo;

  Fifo#(2, AXI4_Lite_WRequest#(32, 4)) wrequest <- mkFifo;
  Fifo#(2, AXI4_Lite_WResponse) wresponse <- mkFifo;

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

`ifdef BSIM
    // Read next char for simulation
    if (req.addr == uart_addr + 4 && req.strb[0] == 1) begin
      let char <- $fgetc(stdin);
      data[0] <= char == -1 ? 8'b0 : pack(char)[7:0];
    end
`endif

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


  method leds = tx_uart.leds;

  method transmit = tx_uart.transmit;
  method receive = rx_uart.receive;

`ifdef BSIM
  method Action interrupt if (False);
    noAction;
  endmethod
`else
  method Action interrupt if (rx_uart.valid);
    rx_uart.ack;
  endmethod
`endif
endmodule



typedef struct {
  String name;
  Bit#(32) start;
  Integer size;
  Bit#(32) maxPhase;
} RomConfig;

module mkRom#(RomConfig conf) (AXI4_Slave#(4, 32, 4));
  BRAM_PORT_BE#(Bit#(32), Bit#(32), 4) bram;
  if (conf.name == "")
    bram <- mkBRAMCore1BE(conf.size / 4, False);
  else
    bram <- mkBRAMCore1BELoad(conf.size / 4, False, conf.name, False);

  Fifo#(2, AXI4_RRequest#(4, 32)) rrequest <- mkFifo;
  Fifo#(2, AXI4_RResponse#(4, 4)) rresponse <- mkFifo;

  Fifo#(2, AXI4_WRequest#(4)) wrequest <- mkFifo;
  Fifo#(2, AXI4_AWRequest#(4, 32)) awrequest <- mkFifo;
  Fifo#(2, AXI4_WResponse#(4)) wresponse <- mkFifo;

  Fifo#(2, void) readQ <- mkFifo;

  Ehr#(2, RomState) state <- mkEhr(IDLE);
  Reg#(Bit#(32)) phase <- mkReg(0);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  function Bit#(32) getAddr(Bit#(32) addr);
    return (addr - conf.start) >> 2;
  endfunction

  function Bool inBounds(Bit#(32) addr);
    return addr >= conf.start && addr < conf.start + fromInteger(conf.size);
  endfunction

  rule updatePhase;
    phase <= phase == conf.maxPhase ? 0 : phase + 1;
    cycle <= cycle + 1;
  endrule

  rule readReq if (state[1] matches tagged Read {req: .req});
    let addr = getAddr(req.addr);
    bram.put(0, inBounds(req.addr) ? addr : 0, ?);
    readQ.enq(?);
  endrule

  rule stepRead
    if (state[0] matches tagged Read {req: .req, init_length: .length});
    rresponse.enq(AXI4_RResponse{
      bytes: bram.read(),
      last: req.length == 0,
      id: req.id,
      resp: OKAY
    });

    readQ.deq();

    //$display("read at cycle: %d", cycle);

    Bit#(32) next_addr = axi4NextAddr(4, req.addr, req.burst, length);
    state[0] <= (req.length == 0 ? IDLE : tagged Read {init_length: length, req: AXI4_RRequest{
      length: req.length - 1,
      burst: req.burst,
      addr: next_addr,
      id: req.id
    }});
  endrule

  rule stepWrite
    if (state[0] matches tagged Write {req: .awreq, init_length: .length});
    let wreq = wrequest.first;
    wrequest.deq;

    if (inBounds(awreq.addr) && wreq.strb != 0)
      bram.put(wreq.strb, getAddr(awreq.addr), wreq.bytes);

    if (awreq.length == 0)
      wresponse.enq(AXI4_WResponse{resp: OKAY, id: awreq.id});

    //$display("write at cycle: %d", cycle);

    Bit#(32) next_addr = axi4NextAddr(4, awreq.addr, awreq.burst, length);
    state[0] <= (awreq.length == 0 ? IDLE : tagged Write {init_length: length, req: AXI4_AWRequest{
      length: awreq.length - 1,
      burst: awreq.burst,
      addr: next_addr,
      id: awreq.id
    }});
  endrule

  rule enq if (state[1] == IDLE && phase == 0);
    if (rrequest.canDeq) begin
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

interface SdramAXI4;
  (* prefix = "" *)
  interface PinsSDRAM memory;

  interface AXI4_Slave#(4, 32, 4) slave;
endinterface

module mkSdramAXI4#(Bit#(32) start) (SdramAXI4);
  let sdram <- mkSDRAM(25);

  Fifo#(2, AXI4_RRequest#(4, 32)) rrequest <- mkFifo;
  Fifo#(2, AXI4_RResponse#(4, 4)) rresponse <- mkFifo;

  Fifo#(2, AXI4_WRequest#(4)) wrequest <- mkFifo;
  Fifo#(2, AXI4_AWRequest#(4, 32)) awrequest <- mkFifo;
  Fifo#(2, AXI4_WResponse#(4)) wresponse <- mkFifo;

  Fifo#(2, void) readQ <- mkFifo;

  Ehr#(2, RomState) state <- mkEhr(IDLE);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  function Bit#(32) getAddr(Bit#(32) addr);
    return (addr - start) >> 2;
  endfunction

  function Bool inBounds(Bit#(32) addr);
    return (addr - start) <= 32 * 1024 * 1024;
  endfunction

  rule readReq if (state[1] matches tagged Read {req: .req});
    sdram.user.request(getAddr(req.addr), ?, 0);
    readQ.enq(?);
  endrule

  rule stepRead
    if (state[0] matches tagged Read {req: .req, init_length: .length});
    let response <- sdram.user.response();

    rresponse.enq(AXI4_RResponse{
      last: req.length == 0,
      bytes: response,
      id: req.id,
      resp: OKAY
    });

    readQ.deq();

    //$display("read at cycle: %d", cycle);

    Bit#(32) next_addr = axi4NextAddr(4, req.addr, req.burst, length);
    state[0] <= (req.length == 0 ? IDLE : tagged Read {init_length: length, req: AXI4_RRequest{
      length: req.length - 1,
      burst: req.burst,
      addr: next_addr,
      id: req.id
    }});
  endrule

  rule stepWrite
    if (state[0] matches tagged Write {req: .awreq, init_length: .length});
    let wreq = wrequest.first;
    wrequest.deq;

    if (inBounds(awreq.addr) && wreq.strb != 0)
      sdram.user.request(getAddr(awreq.addr), wreq.bytes, wreq.strb);

    if (awreq.length == 0)
      wresponse.enq(AXI4_WResponse{resp: OKAY, id: awreq.id});

    //$display("write at cycle: %d", cycle);

    Bit#(32) next_addr = axi4NextAddr(4, awreq.addr, awreq.burst, length);
    state[0] <= (awreq.length == 0 ? IDLE : tagged Write {init_length: length, req: AXI4_AWRequest{
      length: awreq.length - 1,
      burst: awreq.burst,
      addr: next_addr,
      id: awreq.id
    }});
  endrule

  rule enq if (state[1] == IDLE);
    if (rrequest.canDeq) begin
      state[1] <= tagged Read {req: rrequest.first, init_length: rrequest.first.length};
      rrequest.deq;
    end else begin
      state[1] <= tagged Write {req: awrequest.first, init_length: awrequest.first.length};
      awrequest.deq;
    end
  endrule

  interface memory = sdram.pins;

  interface AXI4_Slave slave;
    interface RdAXI4_Slave read;
      interface request = toPut(rrequest);
      interface response = toGet(rresponse);
    endinterface

    interface WrAXI4_Slave write;
      interface awrequest = toPut(awrequest);
      interface wrequest = toPut(wrequest);
      interface response = toGet(wresponse);
    endinterface
  endinterface
endmodule
