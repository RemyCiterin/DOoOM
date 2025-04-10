import AXI4_Lite :: *;
import AXI4 :: *;

import FIFOF :: *;
import SpecialFIFOs :: *;
import Fifo :: *;
import GetPut :: *;

import Decode :: *;
import Utils :: *;
import Types :: *;

import BuildVector :: *;
import Vector :: *;

import OOO :: *;
import ROB :: *;
import CSR :: *;
import IssueQueue :: *;
//import RegisterFile :: *;
import PhysRegFile :: *;
import FunctionalUnit :: *;

import Ehr :: *;
import BranchPred :: *;

import LSU :: *;
import LsuTypes :: *;

import FetchDecode :: *;

interface Core_IFC;
  interface WrAXI4_Lite_Master#(32, 4) wr_mmio;
  interface RdAXI4_Lite_Master#(32, 4) rd_mmio;
  interface WrAXI4_Master#(4, 32, 4) wr_dmem;
  interface RdAXI4_Master#(4, 32, 4) rd_dmem;

  interface RdAXI4_Master#(4, 32, 4) rd_imem;

  method Bit#(64) getTime;

  method Action set_meip(Bool b);
  method Action set_mtip(Bool b);
  method Action set_msip(Bool b);
endinterface

(* synthesize *)
module mkCoreOOO(Core_IFC);
  Bool verbose = False;

  // Count the number of mispredicted instructions
  Reg#(Bit#(64)) mispred_instr <- mkReg(0);
  Reg#(Bit#(64)) hitpred_instr <- mkReg(0);

  Ehr#(2, Epoch) epoch <- mkEhr(0);
  Reg#(Age) current_age <- mkReg(0);

  let fetch <- mkFetchDecode;
  Fifo#(1, FromDecode) decodedQ <- mkPipelineFifo;
  Fifo#(1, Vector#(3,PhysReg)) renamedQ <- mkPipelineFifo;

  ROB rob <- mkROB;

  FunctionalUnit#(2) alu_fu <- mkALU_FU;
  IssueQueue#(IqSize, 2) alu_iq <- mkDefaultIssueQueue;

  FunctionalUnit#(2) control_fu <- mkControlFU;
  IssueQueue#(IqSize, 2) control_iq <- mkDefaultIssueQueue;

`ifdef FLOAT
  FunctionalUnit#(3) fpu_fu <- mkFpuFU;
  IssueQueue#(IqSize, 3) fpu_iq <- mkDefaultFloatIssueQueue;
`endif

  LSU lsu <- mkLSU;
  IssueQueue#(IqSize, 2) lsu_iq <- mkDefaultIssueQueue;

  IssueQueue#(IqSize, 2) direct_issue_queue <- mkDefaultOrderedIssueQueue;

  // indicate if a load is killed by the load store unit
  // because it return a bad value
  Reg#(Bit#(RobSize)) killed <- mkPReg0(0);

  FIFOF#(ExecOutput) decodeFail <- mkPipelineFIFOF;

`ifdef FLOAT
  let toWB <- mkGetScheduler(
    vec(decodeFail.notEmpty, alu_fu.canDeq, control_fu.canDeq, lsu.canDeq, fpu_fu.canDeq),
    vec(toGet(decodeFail).get, alu_fu.deq, control_fu.deq, lsu.deq, fpu_fu.deq)
  );
`else
  let toWB <- mkGetScheduler(
    vec(decodeFail.notEmpty, alu_fu.canDeq, control_fu.canDeq, lsu.canDeq),
    vec(toGet(decodeFail).get, alu_fu.deq, control_fu.deq, lsu.deq)
  );
`endif

  PhysRegFile registers <- mkPhysRegFile;

  let csr <- mkCsrFile(0);

  Reg#(Bit#(64)) timer <- mkReg(0);

  // Redirect the fetch unit on a new pc
  function Action fn_mispredict(Bit#(32) next_pc);
    action
      fetch.redirect(next_pc, epoch[0]+1);
      epoch[0] <= epoch[0] + 1;
    endaction
  endfunction

  // Dequeue the first item of the Reorder buffer, and do the necessary
  // procedures:
  //   - commit the instruction in the LSU if the operation has a DMEM tag
  //   - write it's value in the register file
  //   - flush the register file in case of a misspeculation (next_pc is not
  //   invalid
  //   - redirect the fetch unit and increase the epoch if next_pc is not
  //   invalid
  function Action deqRob(
      Maybe#(Bit#(32)) value,
      Maybe#(Bit#(5)) fflags,
      Maybe#(Bit#(32)) next_pc
    );
    action
      let entry = rob.first;
      let index = rob.first_index;

      if (fflags matches tagged Valid .f) csr.set_fflags(f);

      if (value matches tagged Valid .val &&& destination(entry.instr) != zeroReg &&& verbose)
        $display("       ", fshow(destination(entry.instr)), " := %h", val);

      //registers.setReady(destination(entry.instr), index, value, next_pc != Invalid);
      registers.commit(destination(entry.instr), entry.pdst, value != Invalid, next_pc != Invalid);
      if (next_pc matches tagged Valid .pc) fn_mispredict(pc);

      rob.deq;
    endaction
  endfunction

  // Wakeup all the issue queues (inform the functional units their is a new
  // register)
  function Action wakeupFn(PhysReg pdst, ExecResult result);
    action
      let rd_val = case (result) matches
        tagged Ok {rd_val: .v} : v;
        .*: 0;
      endcase;

      lsu_iq.wakeup(pdst, rd_val);
      alu_iq.wakeup(pdst, rd_val);
`ifdef FLOAT
      fpu_iq.wakeup(pdst, rd_val);
`endif
      control_iq.wakeup(pdst, rd_val);
      direct_issue_queue.wakeup(pdst, rd_val);
      registers.wakeup(pdst,rd_val);
    endaction
  endfunction

  // Dispatch a decoded instruction: enqueue it in the Reorder buffer and the
  // issue queues, use the bypassed value for the register evaluation
  function Action fn_dispatch(FromDecode decoded, Vector#(3,PhysReg) regs);
    action
      let tag = (decoded.exception ? DIRECT : tagOfInstr(decoded.instr));
      current_age <= current_age+1;

      PhysReg pdst = 0;
      if (!decoded.exception) pdst <- registers.enter(destination(decoded.instr));
      let rs1_val = decoded.exception ? Value(0) : registers.read1(regs[0]);
      let rs2_val = decoded.exception ? Value(0) : registers.read2(regs[1]);
      let rs3_val = decoded.exception ? Value(0) : registers.read3(regs[3]);

      RobEntry rob_entry = RobEntry{
        bpred_state: decoded.bpred_state,
        pred_pc: decoded.pred_pc,
        instr: decoded.instr,
        epoch: decoded.epoch,
        age: current_age,
        pc: decoded.pc,
        pdst: pdst,
        tag: tag
      };

      let index <- rob.enq(rob_entry);

      if (decoded.exception)
        decodeFail.enq(ExecOutput{
          result: tagged Error{cause: decoded.cause, tval: decoded.tval},
          index: index,
          pdst: pdst
        });


      IssueQueueInput#(3) entry3 = IssueQueueInput{
        regs: vec(rs1_val, rs2_val, rs3_val),
        instr: decoded.instr,
        epoch: decoded.epoch,
        frm: csr.read_frm,
        age: current_age,
        pc: decoded.pc,
        index: index,
        pdst: pdst,
        sindex: ?,
        lindex: ?,
        tag: tag
      };

      IssueQueueInput#(0) entry0 = mapMicroOp(Vector::take,entry3);
      if (isLoad(decoded.instr) && tag == DMEM) entry3.lindex <- lsu.enqLoad(entry0);
      else if (tag == DMEM) entry3.sindex <- lsu.enqStore(entry0);
      IssueQueueInput#(2) entry2 = mapMicroOp(Vector::take,entry3);

      case (tag) matches
        DIRECT: if (!decoded.exception)
          direct_issue_queue.enq(entry2);
        CONTROL: control_iq.enq(entry2);
`ifdef FLOAT
        FLOAT: fpu_iq.enq(entry3);
`endif
        EXEC: alu_iq.enq(entry2);
        DMEM: lsu_iq.enq(entry2);
      endcase
    endaction
  endfunction

  // Commit an instruction and remove it of the ROB
  function Action doCommit(RobIndex index, RobEntry entry, ExecResult result);
    action
      if (verbose)
        $display("  wb %h ", entry.pc, displayInstr(entry.instr));

      if (isOk(result) &&& entry.tag != DIRECT)
        csr.increment_instret;

      case (result) matches
        tagged Ok {next_pc: .next_pc, rd_val: .rd_val, fflags: .fflags} : begin
          deqRob(
            Valid(rd_val), fflags,
            next_pc != entry.pred_pc ? Valid(next_pc) : Invalid
          );

          if (next_pc != entry.pred_pc) begin
            fetch.trainMis(BranchPredTrain{
              pc: entry.pc,
              instr: Valid(entry.instr),
              next_pc: next_pc,
              state: entry.bpred_state
            });
          end else begin
            fetch.trainHit(BranchPredTrain{
              pc: entry.pc,
              instr: Valid(entry.instr),
              next_pc: next_pc,
              state: entry.bpred_state
            });

          end
        end
        tagged Error {cause: .cause, tval: .tval} : begin
          Bit#(32) trap_pc <- csr.exec_exception(entry.pc, False, pack(cause), tval);
          deqRob(Invalid, Invalid, Valid(trap_pc));

          fetch.trainMis(BranchPredTrain{
            pc: entry.pc,
            instr: Invalid,
            next_pc: trap_pc,
            state: entry.bpred_state
          });
        end
      endcase

    endaction
  endfunction

  function ActionValue#(ExecResult)
    execDirect(RobIndex index, RobEntry entry, Bit#(32) rs1, Bit#(32) rs2);
    actionvalue
      case (entry.instr) matches
        tagged Itype {instr: .*, op: ECALL} : begin
          csr.increment_instret();
          return tagged Error{
            cause: ECALL_FROM_M,
            tval: entry.pc
          };
        end
        tagged Itype {op: FENCE} : begin
          csr.increment_instret;
          lsu.emptySTB();

          return tagged Ok {fflags: Invalid, flush: True, rd_val: 0, next_pc: entry.pc + 4};
        end
        tagged Itype {op: FENCE_I} : begin
          csr.increment_instret;
          fetch.invalidateEmpty();
          return tagged Ok {fflags: Invalid, flush: True, rd_val: 0, next_pc: entry.pc + 4};
        end
        tagged Itype {op: CBO} : begin
          csr.increment_instret;
          lsu.invalidate(rs1 + immediateBits(entry.instr));
          fetch.invalidate(rs1 + immediateBits(entry.instr));
          return tagged Ok {fflags: Invalid, flush: False, rd_val: 0, next_pc: entry.pc + 4};
        end
        tagged Itype {instr: .instr, op: tagged Ret MRET} : begin
          let pc <- csr.mret;
          csr.increment_instret;
          return tagged Ok { fflags: Invalid, flush: False, rd_val: 0, next_pc: pc };
        end
        tagged Itype {instr: .instr, op: .op} : begin
          Maybe#(Bit#(32)) val <- csr.exec_csrxx(instr, op, rs1);

          if (val matches tagged Valid .v)
            return tagged Ok {fflags: Invalid, flush: False, rd_val: v, next_pc: entry.pc+4};
          else
            return tagged Error {cause: ILLEGAL_INSTRUCTION, tval: entry.pc};
        end
        default:
          return tagged Error {cause: ILLEGAL_INSTRUCTION, tval: entry.pc};
      endcase
    endactionvalue
  endfunction

  rule connectEXEC;
    alu_iq.issue.deq;
    alu_fu.enq(alu_iq.issue.first);
  endrule

`ifdef FLOAT
  rule connectFLOAT;
    fpu_iq.issue.deq;
    fpu_fu.enq(fpu_iq.issue.first);
  endrule
`endif

  rule connectCONTROL;
    control_iq.issue.deq;
    control_fu.enq(control_iq.issue.first);
  endrule

  rule connectSTORE if (isStore(lsu_iq.issue.first.instr));
    let entry2 = lsu_iq.issue.first;
    ExecInput#(1) entry2fst = mapMicroOp(Vector::take,entry2);
    ExecInput#(1) entry2snd = mapMicroOp(Vector::drop,entry2);

    lsu.wakeupStoreAddr(entry2fst);
    lsu.wakeupStoreData(entry2snd);
    lsu_iq.issue.deq;
  endrule

  rule connectLOAD if (isLoad(lsu_iq.issue.first.instr));
    let entry2 = lsu_iq.issue.first;
    ExecInput#(1) entry1 = mapMicroOp(Vector::take,entry2);

    let success <- lsu.wakeupLoad(entry1);
    if (success) lsu_iq.issue.deq;
  endrule

  rule write_back;
    let resp <- toWB.get;
    rob.writeBack(resp.index, resp.result);
    wakeupFn(resp.pdst, resp.result);
  endrule

  rule set_timer;
    csr.set_TIME(timer);
    timer <= timer+1;
  endrule

  rule discard_instruction
    if (rob.first.epoch != epoch[0] &&& rob.first_result matches tagged Valid .*);
    mispred_instr <= mispred_instr + 1;
    deqRob(Invalid, Invalid, Invalid);
  endrule

  rule commit_dmem if (
    rob.first_result matches tagged Valid .result);
    let must_commit = rob.first.epoch == epoch[0] && isOk(result);
    let index = rob.first_index;

    let status <- lsu.commit(index, must_commit);
    rob.dmemCommit();

    Bit#(RobSize) new_killed = killed;
    if (status matches tagged Exception .idx)
      new_killed[idx] = 1;
    new_killed[index] = 0;
    killed <= new_killed;
  endrule

  rule commit_instruction if (
      rob.first_result matches tagged Valid .result &&&
      rob.first.epoch == epoch[0]);

    hitpred_instr <= hitpred_instr+1;
    let index = rob.first_index;
    let entry = rob.first;
    let pc = entry.pc;

    if (killed[index] == 1) begin
      deqRob(Invalid, Invalid, Valid(pc));
      fetch.trainMis(BranchPredTrain{
        state: entry.bpred_state,
        instr: Invalid,
        next_pc: pc+4,
        pc: pc
      });
    end else if (csr.readyInterrupt matches tagged Valid .cause &&&
      entry.tag != DMEM && entry.tag != DIRECT) begin
      // The instruction is abort due to an interrupt, we can't abort already
      // "commited" instructions like memory or CSR operations
      let trap_pc <- csr.exec_exception(pc, True, pack(cause), 0);
      deqRob(Invalid, Invalid, Valid(trap_pc));
      fetch.trainMis(BranchPredTrain{
        state: entry.bpred_state,
        next_pc: trap_pc,
        instr: Invalid,
        pc: pc
      });
    end else
      doCommit(index, entry, result);
  endrule

  rule execute_direct if (
      rob.first.tag == DIRECT &&&
      rob.first_result matches Invalid);
    ExecInput#(2) request = direct_issue_queue.issue.first;
    direct_issue_queue.issue.deq();

    ExecResult result = ?;

    if (rob.first.epoch == epoch[0]) result <-
      execDirect(rob.first_index, rob.first, request.regs[0], request.regs[1]);

    rob.writeBack(rob.first_index, result);
    wakeupFn(rob.first.pdst, result);
  endrule

  rule rename;
    let decoded <- fetch.to_RR.get;
    let rs1 = registers.rename1(register1(decoded.instr));
    let rs2 = registers.rename2(register2(decoded.instr));
    let rs3 = registers.rename3(register3(decoded.instr));

    renamedQ.enq(vec(rs1,rs2,rs3));
    decodedQ.enq(decoded);
  endrule

  rule dispatch;
    let decoded = decodedQ.first;
    let renamed = renamedQ.first;
    decodedQ.deq;
    renamedQ.deq;


    if (decoded.epoch == epoch[1])
      fn_dispatch(decoded, renamed);
  endrule

  // Use 1 instead of 0 to ensure we don't display during initialisation
  rule print_stats if (timer[18:0] == 0);
    $display("hit bpred: %d  mis bpred: %d", hitpred_instr, mispred_instr);
  endrule

  interface rd_imem = fetch.imem;

  interface rd_dmem = lsu.rd_dmem;
  interface wr_dmem = lsu.wr_dmem;
  interface rd_mmio = lsu.rd_mmio;
  interface wr_mmio = lsu.wr_mmio;

  method Bit#(64) getTime;
    return timer;
  endmethod

  method set_meip = csr.set_meip;
  method set_mtip = csr.set_mtip;
  method set_msip = csr.set_msip;
endmodule

