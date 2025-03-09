
import Ehr :: *;
import Fifo :: *;

interface SdCardFab;
  (* always_ready, always_enabled *)
  method Bit#(1) clk;

  (* always_ready, always_enabled *)
  method Bit#(1) cmd_out;

  (* always_ready, always_enabled *)
  method Bit#(1) cmd_out_valid;

  (* always_ready, always_enabled, prefix = "" *)
  method Action cmd_in((* port = "cmd_in" *)Bit#(1) cmd);

  (* always_ready, always_enabled *)
  method Bit#(4) data_out;

  (* always_ready, always_enabled *)
  method Bit#(4) data_out_valid;

  (* always_ready, always_enabled, prefix = "" *)
  method Action data_in((* port= "data_in" *)Bit#(4) data);
endinterface

interface SPI;
  method Action setCS(Bit#(1) newCS);
  method Action setClk(Bit#(32) clkSpeed);

  method Action send(Bit#(8) msg);
  method ActionValue#(Bit#(8)) receive;

  (* prefix = "sd" *)
  interface SdCardFab fabric;
endinterface

module mkSPI(SPI);
  Reg#(Bit#(32)) maxPhase <- mkReg(32);
  Reg#(Bit#(32)) clkPhase <- mkReg(32);
  Reg#(Bit#(1)) sclk <- mkReg(0);
  Reg#(Bit#(1)) cs <- mkReg(1);

  Reg#(Bit#(8)) requestValid <- mkReg(0);
  Reg#(Bit#(8)) requestBuffer <- mkReg(0);
  Reg#(Bit#(8)) responseValid <- mkReg(0);
  Reg#(Bit#(8)) responseBuffer <- mkReg(0);
  Bit#(1) mosi = truncateLSB(requestBuffer);

  Wire#(Bit#(4)) dataIn <- mkBypassWire;
  Bit#(1) miso = dataIn[0];

  Fifo#(1, Bit#(8)) bytesFifo <- mkBypassFifo;

  Reg#(Bool) started <- mkReg(False);
  Reg#(File) file <- mkReg(InvalidFile);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  rule incrCycle;
    cycle <= cycle + 1;
  endrule

  rule openFile if (!started);
    File f <- $fopen("spi.log", "w");
    started <= True;
    file <= f;
  endrule

  rule decrClkPhase if (clkPhase != 0);
    clkPhase <= clkPhase - 1;
  endrule

  rule sendBit if (clkPhase == 0 && requestValid != 0);
    if (sclk == 1) begin
      requestValid <= {truncate(requestValid), 1'b0};

      requestBuffer <= {truncate(requestBuffer), 1'b1};

      responseBuffer <= {truncate(responseBuffer), miso};
      responseValid <= {truncate(responseValid), 1'b1};
    end

    sclk <= ~sclk;
    clkPhase <= maxPhase;
  endrule

  method Action send(Bit#(8) msg)
    if (responseValid == 0 && requestValid == 0 && started);
    action
`ifdef BSIM
      $fdisplay(file, "[%d] SPI send: %h", cycle, msg);
      responseValid <= 8'hFF;
      responseBuffer <= 8'hFF;
`else
      requestValid <= 8'b11111111;
      requestBuffer <= msg;
`endif
    endaction
  endmethod

  method ActionValue#(Bit#(8)) receive()
    if (responseValid == -1);
    responseValid <= 0;
    return responseBuffer;
  endmethod

  method Action setClk(Bit#(32) clk);
    action
      maxPhase <= clk;
`ifdef BSIM
      $fdisplay(file, "[%d] CLK set: %d", cycle, clk);
`endif
    endaction
  endmethod

  method Action setCS(Bit#(1) b);
    action
      cs <= b;
`ifdef BSIM
      $fdisplay(file, "[%d] CS set: %b", cycle, b);
`endif
    endaction
  endmethod

  interface SdCardFab fabric;
    method clk = sclk;
    method cmd_out = mosi;
    method cmd_out_valid = 1;
    method Action cmd_in(Bit#(1) _something);
      action endaction
    endmethod
    method data_out = {cs, 3'b000};
    method data_out_valid = 4'b1000;
    method data_in = dataIn._write;
  endinterface
endmodule

