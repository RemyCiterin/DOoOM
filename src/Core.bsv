import AXI4_Lite_Adapter :: *;
import Connectable :: *;
import AXI4_Lite :: *;
import AXI4 :: *;

import FIFOF :: *;
import SpecialFIFOs :: *;
import GetPut :: *;

import Decode :: *;
import Utils :: *;
import Types :: *;

import WriteBack :: *;
import RegisterRead :: *;

interface Core_IFC;
  interface WrAXI4_Master#(4, 32, 4) wr_dmem;
  interface RdAXI4_Master#(4, 32, 4) rd_dmem;
  interface WrAXI4_Lite_Master#(32, 4) wr_mmio;
  interface RdAXI4_Lite_Master#(32, 4) rd_mmio;

  interface RdAXI4_Lite_Master#(32, 4) rd_imem;

  method Bit#(64) getTime;

  method Action set_meip(Bool b);
  method Action set_mtip(Bool b);
  method Action set_msip(Bool b);
endinterface

(* synthesize *)
module mkCore(Core_IFC);
  EpochManager epoch <- mkEpochManager;
  Fetch_IFC fetch <- mkFetch;
  Decode_IFC decode <- mkDecode(epoch);
  RegisterRead_IFC reg_read <- mkRegisterRead;

  DMEM_IFC dmem <- mkDMEM;
  Pipeline control <- mkControlPipeline;
  Pipeline alu <- mkALUPipeline;

  WriteBack_IFC wb <- mkWriteBack(epoch);

  mkConnection(fetch.to_Decode, decode.from_Fetch);
  mkConnection(decode.to_RR, reg_read.from_Decode);

  mkConnection(reg_read.to_DMEM, dmem.pipeline.from_RR);
  mkConnection(reg_read.to_Ex_Pipes, alu.from_RR);
  mkConnection(reg_read.to_Ex_Control, control.from_RR);

  mkConnection(dmem.pipeline.to_WB, wb.from_DMEM);
  mkConnection(control.to_WB, wb.from_Control);
  mkConnection(alu.to_WB, wb.from_Exec);

  mkConnection(reg_read.to_WB, wb.from_RR);

  mkConnection(wb.to_RR, reg_read.from_WriteBack);
  mkConnection(wb.to_Fetch, fetch.from_WriteBack);

  Reg#(Bit#(64)) timer <- mkReg(0);

  Reg#(Bool) is_start <- mkReg(False);

  rule start if (!is_start);
    File f <- $fopen("log.txt", "w");

    reg_read.start(f);
    decode.start(f);
    fetch.start(f);
    wb.start(f);

    is_start <= True;
  endrule

  (* fire_when_enabled, no_implicit_conditions *)
  rule set_TIME;
    wb.set_TIME(timer);
    timer <= timer + 1;
  endrule

  rule commit;
    Bool commit <- wb.dmem_commit();
    dmem.commit(commit);
  endrule

  rule setEmptySTB;
    wb.set_EmptySTB(dmem.emptySTB);
  endrule

  method Bit#(64) getTime;
    return timer;
  endmethod

  interface RdAXI4_Lite_Master rd_imem;
    interface request = fetch.rrequest;
    interface response = decode.rresponse;
  endinterface

  interface rd_dmem = dmem.rd_dmem;
  interface wr_dmem = dmem.wr_dmem;
  interface rd_mmio = dmem.rd_mmio;
  interface wr_mmio = dmem.wr_mmio;

  method set_meip = wb.set_meip;
  method set_mtip = wb.set_mtip;
  method set_msip = wb.set_msip;
endmodule
