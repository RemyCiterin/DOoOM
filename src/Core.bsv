import AXI4_Lite_Adapter :: *;
import Connectable :: *;
import AXI4_Lite :: *;
import AXI4 :: *;

import ForwardRegFile :: *;
import FetchDecode :: *;
import BranchPred :: *;
import CSR :: *;
import Ehr :: *;
import Fifo :: *;

import FIFOF :: *;
import SpecialFIFOs :: *;
import GetPut :: *;

import Decode :: *;
import Utils :: *;
import Types :: *;

import Pipeline :: *;

interface RegisterFile;
  method Action setBusy(RegName r);
  method Bit#(32) read1(RegName r);
  method Bit#(32) read2(RegName r);
  method Action setReady(RegName r, Bit#(32) value, Bool commit);
  method Bool isReady(RegName rd, RegName rs1, RegName rs2);
endinterface

(* synthesize *)
module mkRegisterFile(RegisterFile);
  Ehr#(2, Bit#(32)) scoreboard <- mkEhr(0);
  ForwardRegFile#(Bit#(5), Bit#(32)) registers <- mkForwardRegFileFullInit(0);

  method Bool isReady(RegName rd, RegName rs1, RegName rs2);
    return scoreboard[1][rd.name] == 0 &&
      scoreboard[1][rs1.name] == 0 &&
      scoreboard[1][rs2.name] == 0;
  endmethod

  method Action setBusy(RegName r);
    action
      if (r.name != 0)
        scoreboard[1][r.name] <= 1;
    endaction
  endmethod

  method Bit#(32) read1(RegName r);
    return registers.forward(r.name);
  endmethod

  method Bit#(32) read2(RegName r);
    return registers.forward(r.name);
  endmethod

  method Action setReady(RegName r, Bit#(32) value, Bool commit);
    action
      if (commit && r.name != 0) registers.upd(r.name, value);
      scoreboard[0][r.name] <= 0;
    endaction
  endmethod
endmodule

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
  Ehr#(2, Epoch) epoch <- mkEhr(0);
  FetchDecode fetch <- mkFetchDecode;
  Fifo#(1, FromDecode) decoded <- mkBypassFifo;
  mkConnection(toPut(decoded), fetch.to_RR);

  DMEM_IFC dmem <- mkDMEM;
  Pipeline control <- mkControlPipeline;
  Pipeline alu <- mkALUPipeline;

  CsrFile csr <- mkCsrFile(0);

  RegisterFile registers <- mkRegisterFile();

  // Instructions window: Fifo of instructions to write-back
  Fifo#(6, RR_to_WB) window <- mkPipelineFifo();
  Fifo#(6, BranchPredState) bpred_states <- mkPipelineFifo();

  Reg#(Bit#(32)) stall <- mkReg(0);
  Reg#(Bit#(32)) cycle <- mkReg(0);

  Reg#(Bit#(64)) timer <- mkReg(0);

  function Action dispatchFn(FromDecode req);
    action
      let tag = (req.exception ? EXEC_TAG_DIRECT : tagOfInstr(req.instr));

      let rd = req.exception ? RegName{name: 0} : destination(req.instr);
      let rs1 = req.exception ? RegName{name: 0} : register1(req.instr);
      let rs2 = req.exception ? RegName{name: 0} : register2(req.instr);

      when(registers.isReady(rd, rs1, rs2), registers.setBusy(rd));
      decoded.deq();

      let rs1_val = registers.read1(rs1);
      let rs2_val = registers.read2(rs2);

      bpred_states.enq(req.bpred_state);
      window.enq(RR_to_WB{
        inum: req.inum,
        exec_tag: tag,
        exception: req.exception,
        cause: req.cause,
        tval: req.tval,
        epoch: req.epoch,
        pc: req.pc,
        instr: req.instr,
        predicted_pc: req.pred_pc,
        rs1_val: rs1_val,
        rs2_val: rs2_val
      });

      let msg = RR_to_Pipeline{
        epoch: req.epoch,
        instr: req.instr,
        rs1_val: rs1_val,
        rs2_val: rs2_val,
        pc: req.pc
      };

      case (tag) matches
        EXEC_TAG_EXEC: alu.from_RR.put(msg);
        EXEC_TAG_CONTROL: control.from_RR.put(msg);
        EXEC_TAG_DMEM: dmem.pipeline.from_RR.put(msg);
        default: noAction;
      endcase
    endaction
  endfunction

  function Action hitFn();
    action
      let req = window.first;
      let state = bpred_states.first;
      fetch.trainHit(BranchPredTrain{
        next_pc: req.predicted_pc,
        instr: Valid(req.instr),
        state: state,
        pc: req.pc
      });
    endaction
  endfunction

  function Action mispredictFn(Maybe#(Instr) instr, Bit#(32) next);
    action
      fetch.redirect(next, epoch[0] + 1);
      epoch[0] <= epoch[0] + 1;

      let pc = window.first.pc;
      fetch.trainMis(BranchPredTrain{
        pc: pc, instr: instr, next_pc: next,
        state: bpred_states.first
      });
    endaction
  endfunction

  function Action exceptionFn(CauseException cause, Bit#(32) tval);
    action
      let pc = window.first.pc;
      Bit#(32) trapPc <- csr.exec_exception(pc, False, pack(cause), tval);
      mispredictFn(Invalid, trapPc);
    endaction
  endfunction

  function Action commitFn(Bool commit, Bit#(32) val);
    action
      let req = window.first;
      if (req.exec_tag == EXEC_TAG_DMEM) dmem.commit(commit);

      let rd = destination(req.instr);
      registers.setReady(rd, val, commit);
    endaction
  endfunction

  function Action execDirect();
    action
      let req = window.first();
      case (req.instr) matches
        tagged Itype {op: ECALL} : begin
          exceptionFn(ECALL_FROM_M, req.pc);
          csr.increment_instret();
          commitFn(False, ?);
        end
        tagged Itype {op: FENCE} : begin
          when(dmem.emptySTB(), csr.increment_instret());
          mispredictFn(Invalid, req.pc+4);
          commitFn(True, 0);
        end
        tagged Itype {op: FENCE_I} : begin
          mispredictFn(Invalid, req.pc+4);
          csr.increment_instret();
          commitFn(True, 0);
        end
        tagged Itype {op: tagged Ret MRET} : begin
          let next_pc <- csr.mret;
          mispredictFn(Valid(req.instr), next_pc);
          csr.increment_instret();
          commitFn(True, ?);
        end
        tagged Itype {op: .op, instr: .instr} : begin
          Maybe#(Bit#(32)) result <- csr.exec_csrxx(instr, op, req.rs1_val);

          case (result) matches
            tagged Valid .val : begin
              commitFn(True, val);
              if (req.predicted_pc != req.pc + 4)
                mispredictFn(Invalid, req.pc+4);
              else hitFn();
            end
            Invalid : begin
              exceptionFn(ILLEGAL_INSTRUCTION, req.pc);
              commitFn(False, ?);
            end
          endcase
        end
        default: $display("Direct: unexpected instruction");
      endcase
    endaction
  endfunction

  function ActionValue#(Pipeline_to_WB) getPipelineResp;
    actionvalue
      let req = window.first;
      case (req.exec_tag) matches
        EXEC_TAG_DMEM: begin
          let resp <- dmem.pipeline.to_WB.get();
          return resp;
        end
        EXEC_TAG_EXEC: begin
          let resp <- alu.to_WB.get();
          return resp;
        end
        EXEC_TAG_CONTROL: begin
          let resp <- control.to_WB.get();
          return resp;
        end
        default: return ?;
      endcase
    endactionvalue
  endfunction

  (* descending_urgency = "interrupt, commit" *)
  rule interrupt
    if (csr.readyInterrupt matches tagged Valid .cause &&&
    window.first.epoch == epoch[0]);

    let req = window.first;
    let _ <- getPipelineResp();
    let trapPc <- csr.exec_exception(req.pc, True, pack(cause), 0);
    mispredictFn(Invalid, trapPc);
    commitFn(False, ?);
    bpred_states.deq();
    window.deq();
  endrule

  rule commit;
    let req = window.first;

    let resp <- getPipelineResp();

    if (req.epoch == epoch[0]) begin

      if (req.exception) begin
        exceptionFn(req.cause, req.tval);
        commitFn(False, ?);
      end else begin
        case (req.exec_tag) matches
          EXEC_TAG_DIRECT: execDirect();
          default: begin
            csr.increment_instret();

            commitFn(!resp.exception, resp.result);

            if (resp.exception)
              exceptionFn(resp.cause, resp.tval);
            else if (resp.next_pc != req.predicted_pc)
              mispredictFn(Valid(req.instr), resp.next_pc);
            else hitFn();
          end
        endcase
      end
    end else begin
      commitFn(False, ?);
    end

    window.deq();
    bpred_states.deq();
  endrule

  rule dispatch;
    if (decoded.first.epoch == epoch[1])
      dispatchFn(decoded.first);
    else decoded.deq();
  endrule

  rule incrTimer;
    timer <= timer + 1;
    csr.set_TIME(timer);
  endrule

  rule countStall;
    let req = decoded.first;
    let tag = (req.exception ? EXEC_TAG_DIRECT : tagOfInstr(req.instr));

    let rd = req.exception ? RegName{name: 0} : destination(req.instr);
    let rs1 = req.exception ? RegName{name: 0} : register1(req.instr);
    let rs2 = req.exception ? RegName{name: 0} : register2(req.instr);

    if (!registers.isReady(rd, rs1, rs2)) stall <= stall + 1;
  endrule

  rule countCycle;
    cycle <= cycle + 1;
    if (cycle[18:0] == 0)
      $display("cycle: %d stall: %d", cycle, stall);
  endrule

  interface RdAXI4_Lite_Master rd_imem;
    interface request = fetch.rrequest;
    interface response = fetch.rresponse;
  endinterface

  method getTime = timer;

  interface rd_dmem = dmem.rd_dmem;
  interface wr_dmem = dmem.wr_dmem;
  interface rd_mmio = dmem.rd_mmio;
  interface wr_mmio = dmem.wr_mmio;

  method set_msip = csr.set_msip;
  method set_mtip = csr.set_mtip;
  method set_meip = csr.set_meip;
endmodule
