import Vector :: *;
import GetPut :: *;
import Fifo :: *;
import DReg :: *;
import Ehr :: *;

`ifdef BSIM
import "BDPI" function Action simWriteSDRAM(Bit#(32) addr, Bit#(32) data);
import "BDPI" function ActionValue#(Bit#(32)) simReadSDRAM(Bit#(32) addr);
`endif

(* always_enabled, always_ready *)
interface PinsSDRAM;
  interface Clock sdram_nclk; // Inverse of the clock given to the sdram

  method Bit#(1) sdram_casn; // Those wires are used to encode the command
  method Bit#(1) sdram_rasn; // of the current operation: precharge,
  method Bit#(1) sdram_csn;  // autorefresh, read, write, modeset, nop,
  method Bit#(1) sdram_wen;  // activate...

  method Bit#(13) sdram_a;  // addresse used to encode the row/column

  method Bit#(2) sdram_ba;  // choose the current bank

  method Bit#(2) sdram_dqm; // choose the byte to read/write

  method Bool sdram_d_en;  // true when we write a data

  method Bit#(16) sdram_d_out; // write data

  (* prefix = "" *)
  method Action sdram_d_in((* port = "sdram_d_in" *) Bit#(16) data_in); // read_data
endinterface

interface UserSDRAM;
  method Action request(Bit#(32) addr, Bit#(32) data, Bit#(4) mask);
  method ActionValue#(Bit#(32)) response();
endinterface

interface SDRAM;
  (* prefix = "" *)
  interface PinsSDRAM pins;
  interface UserSDRAM user;
endinterface

typedef enum {
  NOP = 4'b1000,
  PRECHARGE = 4'b0001,
  AUTOREFRESH = 4'b0100,
  MODESET = 4'b0000,
  READ = 4'b0110,
  WRITE = 4'b0010,
  ACTIVATE = 4'b0101
} SDRAM_COMMAND deriving(Bits, FShow, Eq);

typedef struct {
  Integer tRP; // precharge time
  Integer tMRD; // time of update of the MRS register
  Integer tRCD; // Activation time
  Integer tRC; // Auto refresh time
  Integer tCL; // Column update time
} ConfigSDRAM;

typedef 4 NumBank;
typedef Bit#(2) Bank;
typedef Bit#(4) Delay;

interface ControllerSDRAM;
  // send a command and select the delay until the next command
  method Action command(SDRAM_COMMAND cmd, Bank bank, Maybe#(Bit#(13)) addr);

  // Give the value of the previous 32 received bits of data
  method Bit#(32) read();

  // Write some data
  method Action write(Bit#(16) data, Bit#(2) we);

  (* prefix = "" *)
  interface PinsSDRAM pins;
endinterface

// Control the pins of the SDRAM
module mkControllerSDRAM(ControllerSDRAM);
  Clock clock <- exposeCurrentClock;

  Reg#(Bit#(13)) addresse <- mkReg(0);
  Ehr#(2, SDRAM_COMMAND) cmd <- mkEhr(NOP);
  Ehr#(2, Bit#(2)) dqm <- mkPReg(0);

  Reg#(Bit#(2)) bank <- mkReg(0);

  Wire#(Bit#(16)) dataIn <- mkBypassWire;
  Reg#(Bit#(32)) inoutBuf <- mkReg(0);

  Reg#(Bit#(16)) dataOut <- mkReg(0);
  Reg#(Bool) dataEn <- mkDReg(False);

  rule defaultCmd;
    cmd[0] <= NOP;
  endrule

  rule readInput;
    inoutBuf <= {dataIn, truncateLSB(inoutBuf)};
  endrule

  method Action write(Bit#(16) data, Bit#(2) we);
    action
      dataOut <= data;
      dataEn <= True;
      dqm[1] <= ~we;
    endaction
  endmethod

  method read = inoutBuf;

  method Action command(SDRAM_COMMAND c, Bank ba, Maybe#(Bit#(13)) addr);
    action
      if (c == READ || c == AUTOREFRESH) dqm[0] <= 0;
      if (addr matches tagged Valid .a)
        addresse <= a;
      cmd[1] <= c;
      bank <= ba;
    endaction
  endmethod

  interface PinsSDRAM pins;
    interface sdram_nclk = clock;
    method sdram_csn = pack(cmd[0])[3];
    method sdram_wen = pack(cmd[0])[2];
    method sdram_rasn = pack(cmd[0])[1];
    method sdram_casn = pack(cmd[0])[0];
    method sdram_dqm = dqm[0];
    method sdram_a = addresse;
    method sdram_ba = bank;
    method sdram_d_in = dataIn._write;
    method sdram_d_en = dataEn;
    method sdram_d_out = dataOut;
  endinterface
endmodule

interface LocalDelaySdram;
  method Action send(Delay delay);
endinterface

interface DelaySdram;
  // send a global command adding a delay for all the future operations
  method Action sendGlobal(Delay delay);

  // Send a command only to a specific bank
  interface Vector#(NumBank, LocalDelaySdram) locals;

  /* Now we represeny the delay constraints used to ensure
  the absence of race condition to acquire the data bus */

  // Block the reads for `readDelay` cycles, and the writes for `wrDelay` cycles
  method Action read(Delay readDelay, Delay writeDelay);

  // Reserve the bus for a given delay
  method Action write(Delay delay);
endinterface

// Ensure that we respect the dalays, and the absence of bus race condition
(* synthesize *)
module mkDelaySdram(DelaySdram);
  Vector#(NumBank, Ehr#(2, Delay)) bankDelay <- replicateM(mkEhr(0));
  Ehr#(2, Delay) rdDelay <- mkEhr(0);
  Ehr#(2, Delay) wrDelay <- mkEhr(0);

  function Delay newDelay(Delay delay) = delay == 0 ? 0 : delay - 1;

  rule updateBankDelay;
    for (Integer i=0; i < valueOf(NumBank); i = i + 1)
      bankDelay[i][0] <= newDelay(bankDelay[i][0]);
    rdDelay[0] <= newDelay(rdDelay[0]);
    wrDelay[0] <= newDelay(wrDelay[0]);
  endrule

  Vector#(NumBank, LocalDelaySdram) localDelays = newVector;
  for (Integer bank = 0; bank < valueOf(NumBank); bank = bank + 1) begin
    localDelays[bank] = interface LocalDelaySdram;

      method Action send(Delay delay)
        if (bankDelay[bank][1] == 0);
        action
          bankDelay[bank][1] <= delay;
        endaction
      endmethod

    endinterface;
  end

  Bool readySendGlobal = True;
  for (Integer i=0; i < valueOf(NumBank); i = i + 1)
    if (bankDelay[i][1] != 0) readySendGlobal = False;

  method Action sendGlobal(Delay delay)
    if (readySendGlobal);
    action
      for (Integer i=0; i < valueOf(NumBank); i = i + 1)
        bankDelay[i][1] <= delay;
    endaction
  endmethod

  method locals = localDelays;

  method Action read(Delay rd, Delay wr)
    if (rdDelay[1] == 0);
    action
      rdDelay[1] <= rd;
      wrDelay[1] <= max(wrDelay[1], wr);
    endaction
  endmethod

  method Action write(Delay d)
    if (wrDelay[1] == 0);
    action
      rdDelay[1] <= max(rdDelay[1], d);
      wrDelay[1] <= d;
    endaction
  endmethod
endmodule

typedef enum {
  IDLE, REFRESH1, REFRESH2,
  CONFIG, RDWR, READREADY,
  WRITE1, INIT
} SDRAM_STATE deriving(Bits, FShow, Eq);

typedef enum {
  IDLE, READ0, READ1, WRITE0, WRITE1
} LocalSdramState deriving(Bits, FShow, Eq);

typedef enum {
  INIT,      // initialisation phase
  IDLE,      // ready to send command to memory
  PRECHARGE, // close all the banks before a MODESET command or a refresh
  REFRESH,   // send the AUTOREFRESH command
  MODESET    // setup the configuration of the MODE register
} GlobalSdramState deriving(Bits, FShow, Eq);

interface BankController;
  method Action request(Bit#(13) row, Bit#(9) col, Bit#(32) data, Bit#(4) mask);
  method ActionValue#(Bit#(32)) response;

  // close the bank
  method Action close();

  // return if the bank is in IDLE mode
  method Bool isIdle();
endinterface

// Control the read/write sequence of one bank
module mkBankController
  #(Bank bank, ControllerSDRAM mem, DelaySdram delays)
  (BankController);

  Fifo#(2, Bit#(32)) outputQ <- mkBypassFifo;

  Reg#(LocalSdramState) state <- mkPReg0(IDLE);

  Reg#(Maybe#(Bit#(13))) open <- mkReg(Invalid);

  Reg#(Bit#(32)) data <- mkReg(?);
  Reg#(Bit#(4)) mask <- mkReg(?);
  Reg#(Bit#(13)) row <- mkReg(?);
  Reg#(Bit#(9)) col <- mkReg(?);

  Bit#(4) tRP = 3;
  //Bit#(4) tMRD = 2;
  Bit#(4) tRCD = 3;
  //Bit#(4) tRC = 9;
  Bit#(4) tCL = 3;

  Reg#(Bit#(32)) cycle <- mkReg(0);

  rule incrCycle;
    cycle <= cycle + 1;
  endrule

  rule activate
    if (state != IDLE && open == Invalid);
    //$display("%d activate[%b]", cycle, bank);
    mem.command(ACTIVATE, bank, Valid(row));
    delays.locals[bank].send(tRCD);
    open <= Valid(row);
  endrule

  rule precharge
    if (open matches tagged Valid .r &&& r != row && state != IDLE);
    //$display("%d precharge[%b]", cycle, bank);
    mem.command(PRECHARGE, bank, Valid(0));
    delays.locals[bank].send(tRP);
    open <= Invalid;
  endrule

  rule read0
    if (state == READ0 && open == Valid(row));
    //$display("%d read0[%b]", cycle, bank);
    mem.command(READ, bank, Valid({0,col}));
    delays.locals[bank].send(tCL+2);
    delays.read(2, tCL+2);
    state <= READ1;
  endrule

  rule read1
    if (state == READ1);
    //$display("%d read1[%b]", cycle, bank);
    delays.locals[bank].send(1);
    state <= IDLE;

    `ifndef BSIM
    outputQ.enq(mem.read);
    `else
    let d <- simReadSDRAM(zeroExtend(cmdAddr));
    outputQ.enq(d);
    `endif
  endrule

  rule write0
    if (state == WRITE0 && open == Valid(row));
    //$display("%d write0[%b]", cycle, bank);
    mem.command(WRITE, bank, Valid({0,col}));
    delays.locals[bank].send(1);
    delays.write(2);
    state <= WRITE1;

    `ifndef BSIM
    mem.write(data[15:0], mask[1:0]);
    `else
    simWriteSDRAM(zeroExtend(addr), zeroExtend(data));
    `endif
  endrule

  rule write1
    if (state == WRITE1);
    //$display("%d write1[%b]", cycle, bank);
    delays.locals[bank].send(tCL);
    state <= IDLE;

    `ifndef BSIM
    mem.write(data[31:16], mask[3:2]);
    `endif
  endrule

  method Action request(Bit#(13) r, Bit#(9) c, Bit#(32) d, Bit#(4) m)
    if (state == IDLE && outputQ.canEnq);
    action
      state <= m == 0 ? READ0 : WRITE0;
      data <= d;
      mask <= m;
      row <= r;
      col <= c;
    endaction
  endmethod

  method Action close = open._write(Invalid);

  method Bool isIdle = state == IDLE;

  method response = toGet(outputQ).get;
endmodule

(* synthesize *)
module mkSDRAM#(Bit#(16) clock_mhz) (SDRAM);
  Clock clock <- exposeCurrentClock;

  Fifo#(4, Tuple3#(Bit#(32),Bit#(32),Bit#(4))) inputQ <- mkPipelineFifo;
  Fifo#(NumBank, Bank) tagQ <- mkPipelineFifo;
  Fifo#(2, Bit#(32)) outputQ <- mkBypassFifo;

  Bit#(16) init_cycles = 100 * clock_mhz;
  Bit#(16) rf_cycles = clock_mhz * 78 / 10;
  //Bit#(13) addrMode = 13'b000_1_00_011_0_000;
  Bit#(13) addrMode = 13'b000_0_00_011_0_001;

  Bit#(4) tRP = 3;
  Bit#(4) tMRD = 2;
  Bit#(4) tRCD = 3;
  Bit#(4) tRC = 9;
  Bit#(4) tCL = 3;


  Reg#(GlobalSdramState) state <- mkReg(INIT);

  let delays <- mkDelaySdram;
  let mem <- mkControllerSDRAM;

  Vector#(NumBank, BankController) banks = newVector;
  for (Integer i=0; i < valueOf(NumBank); i = i + 1) begin
    banks[i] <- mkBankController(fromInteger(i), mem, delays);
  end

  Reg#(Bit#(16)) counter <- mkPReg0(0);

  Reg#(Bool) isInit <- mkReg(False);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  rule init if (state == INIT);
    if (counter+1 >= init_cycles) begin
      state <= PRECHARGE;
      counter <= 0;
    end else
      counter <= counter + 1;
  endrule

  rule count if (isInit);
    if (state == REFRESH) counter <= 0;
    else counter <= counter + 1;
  endrule

  Bool mustRefresh = counter >= rf_cycles;
  for (Integer i=0; i < valueOf(NumBank); i = i + 1) begin
    if (!banks[i].isIdle()) mustRefresh = False;
  end

  rule idleToPrecharge
    if (state == IDLE && mustRefresh);
    state <= PRECHARGE;
  endrule

  for (Integer i=0; i < valueOf(NumBank); i = i + 1) begin
    match {.addr, .data, .we} = inputQ.first;
    Bank bank = fromInteger(i);
    addr = addr << 1;

    rule idle
      if (state == IDLE && addr[2:1] == bank && !mustRefresh);

      banks[bank].request(addr[23:11], {addr[10:3],1'b0}, data, we);
      if (we == 0) tagQ.enq(bank);
      inputQ.deq();
    endrule
  end

  rule precharge
    if (state == PRECHARGE);
    // set Bit 10 to close all the banks
    mem.command(PRECHARGE, ?, Valid(1 << 10));
    state <= isInit ? REFRESH : MODESET;
    delays.sendGlobal(tRP);

    for (Integer i=0; i < valueOf(NumBank); i = i + 1) begin
      banks[i].close();
    end
  endrule

  rule refresh
    if (state == REFRESH);
    mem.command(AUTOREFRESH, ?, Invalid);
    if (isInit) state <= IDLE;
    delays.sendGlobal(tRC);
    isInit <= True;
  endrule

  rule modeset
    if (state == MODESET);
    mem.command(MODESET, 0, Valid(addrMode));
    delays.sendGlobal(tMRD);
    state <= REFRESH;
  endrule

  interface pins = mem.pins;

  interface UserSDRAM user;
    method Action request(Bit#(32) addr, Bit#(32) data, Bit#(4) we) =
      inputQ.enq(tuple3(addr, data, we));

    method ActionValue#(Bit#(32)) response;
      let tag = tagQ.first;
      tagQ.deq;

      let x <- banks[tag].response();
      return x;
    endmethod
  endinterface
endmodule
