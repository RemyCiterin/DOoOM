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
import RegisterFile :: *;
import FunctionalUnit :: *;

import Ehr :: *;
import BranchPred :: *;

import LSU :: *;
import LsuTypes :: *;
import MemIssueQueue :: *;

import FetchDecode :: *;

interface Core_IFC;
  interface WrAXI4_Lite_Master#(32, 4) wr_mmio;
  interface RdAXI4_Lite_Master#(32, 4) rd_mmio;
  interface WrAXI4_Master#(4, 32, 4) wr_dmem;
  interface RdAXI4_Master#(4, 32, 4) rd_dmem;

  interface RdAXI4_Lite_Master#(32, 4) rd_imem;

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

  ROB rob <- mkROB;

  IssueQueue#(IqSize, 2) alu_issue_queue <- mkDefaultIssueQueue;
  FunctionalUnit#(2) alu_fu <- mkALU_FU;

  IssueQueue#(IqSize, 2) control_issue_queue <- mkDefaultIssueQueue;
  FunctionalUnit#(2) control_fu <- mkControlFU;

  IssueQueue#(IqSize, 2) direct_issue_queue <- mkDefaultOrderedIssueQueue;

  IssueQueue#(IqSize, 3) fpu_issue_queue <- mkDefaultFloatIssueQueue;
  FunctionalUnit#(3) fpu_fu <- mkFpuFU;

  LSU lsu <- mkLSU;
  let store_addr_issue_queue <- mkStoreIssueQueue;
  let store_data_issue_queue <- mkStoreIssueQueue;
  let load_issue_queue <- mkLoadIssueQueue;

  // indicate if a load is killed by the load store unit
  // because it return a bad value
  Reg#(Bit#(RobSize)) killed <- mkPReg0(0);

  FIFOF#(Tuple2#(RobIndex, ExecOutput)) decodeFail <- mkPipelineFIFOF;

  let toWB <- mkGetScheduler(
    vec(decodeFail.notEmpty, alu_fu.canDeq, control_fu.canDeq, lsu.canDeq, fpu_fu.canDeq),
    vec(toGet(decodeFail).get, alu_fu.deq, control_fu.deq, lsu.deq, fpu_fu.deq)
  );

  RegisterFileOOO registers <- mkRegisterFileOOO;

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

      registers.setReady(destination(entry.instr), index, value, next_pc != Invalid);
      if (next_pc matches tagged Valid .pc) fn_mispredict(pc);

      rob.deq;
    endaction
  endfunction

  // Wakeup all the issue queues (inform the functional units their is a new
  // register)
  function Action wakeupFn(RobIndex index, ExecOutput result);
    action
      let rd_val = case (result) matches
        tagged Ok {rd_val: .v} : v;
        .*: 0;
      endcase;

      control_issue_queue.wakeup(index, rd_val);
      direct_issue_queue.wakeup(index, rd_val);
      alu_issue_queue.wakeup(index, rd_val);
      fpu_issue_queue.wakeup(index, rd_val);
      load_issue_queue.wakeup(index, rd_val);
      store_data_issue_queue.wakeup(index, rd_val);
      store_addr_issue_queue.wakeup(index, rd_val);
    endaction
  endfunction

  // Dispatch a decoded instruction: enqueue it in the Reorder buffer and the
  // issue queues, use the bypassed value for the register evaluation
  function Action fn_dispatch(FromDecode decoded);
    action
      let tag = (decoded.exception ? EXEC_TAG_DIRECT : tagOfInstr(decoded.instr));
      current_age <= current_age+1;

      RobEntry rob_entry = RobEntry{
        pc: decoded.pc,
        tag: tag,
        instr: decoded.instr,
        epoch: decoded.epoch,
        pred_pc: decoded.pred_pc,
        bpred_state: decoded.bpred_state,
        age: current_age
      };

      let index <- rob.enq(rob_entry);
      let rs1_val = registers.rs1(register1(decoded.instr));
      let rs2_val = registers.rs2(register2(decoded.instr));
      let rs3_val = registers.rs3(register3(decoded.instr));
      let imm = immediateBits(decoded.instr);

      if (rs1_val matches tagged Wait .idx &&& rob.read1(idx) matches tagged Valid .res)
        rs1_val = tagged Value getRdVal(res);
      if (rs2_val matches tagged Wait .idx &&& rob.read2(idx) matches tagged Valid .res)
        rs2_val = tagged Value getRdVal(res);
      if (rs3_val matches tagged Wait .idx &&& rob.read3(idx) matches tagged Valid .res)
        rs3_val = tagged Value getRdVal(res);

      if (decoded.exception)
        decodeFail.enq(tuple2(index, tagged Error{cause: decoded.cause, tval: decoded.tval}));

      registers.setBusy(destination(decoded.instr), index);

      IssueQueueInput#(2) iq_entry2 = IssueQueueInput{
        epoch: decoded.epoch, age: current_age,
        pc: decoded.pc, instr: decoded.instr,
        index: index, frm: csr.read_frm,
        regs: vec(rs1_val, rs2_val)
      };

      IssueQueueInput#(3) iq_entry3 = IssueQueueInput{
        epoch: decoded.epoch, age: current_age,
        pc: decoded.pc, instr: decoded.instr,
        regs: vec(rs1_val, rs2_val, rs3_val),
        index: index, frm: csr.read_frm
      };

      case (tag) matches
        EXEC_TAG_EXEC: begin
          alu_issue_queue.enq(iq_entry2);
        end
        EXEC_TAG_CONTROL: begin
          control_issue_queue.enq(iq_entry2);
        end
        EXEC_TAG_DMEM: if (isStore(decoded.instr)) begin
          let sq_idx <- lsu.enqStore(index, decoded.instr, decoded.pc, decoded.epoch, current_age);
          store_addr_issue_queue.enq(sq_idx, rs1_val, imm, decoded.epoch, current_age);
          store_data_issue_queue.enq(sq_idx, rs2_val, 0, decoded.epoch, current_age);
        end else begin
          let lq_idx <- lsu.enqLoad(index, decoded.instr, decoded.pc, decoded.epoch, current_age);
          load_issue_queue.enq(lq_idx, rs1_val, imm, decoded.epoch, current_age);
        end
        EXEC_TAG_DIRECT: if (!decoded.exception) begin
          direct_issue_queue.enq(iq_entry2);
        end
        EXEC_TAG_FLOAT: begin
          fpu_issue_queue.enq(iq_entry3);
        end
        default:
          noAction;
      endcase
    endaction
  endfunction

  // Commit an instruction and remove it of the ROB
  function Action doCommit(RobIndex index, RobEntry entry, ExecOutput result);
    action
      if (verbose)
        $display("  wb %h ", entry.pc, displayInstr(entry.instr));

      if (isOk(result) &&& entry.tag != EXEC_TAG_DIRECT)
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
          //$display("%d %h  ", index, entry.pc, displayInstr(entry.instr));
          //$display("exception from %h ", entry.pc, fshow(cause));
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

  function ActionValue#(ExecOutput)
    execDirect(RobIndex index, RobEntry entry, Bit#(32) rs1, Bit#(32) rs2);
    actionvalue
      case (entry.instr) matches
        tagged Itype {instr: .*, op: ECALL} : begin
          csr.increment_instret;
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
          return tagged Ok {fflags: Invalid, flush: True, rd_val: 0, next_pc: entry.pc + 4};
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

  rule connectALU;
    alu_issue_queue.issue.deq();
    alu_fu.enq(alu_issue_queue.issue.first);
  endrule

  rule connectControl;
    control_issue_queue.issue.deq();
    control_fu.enq(control_issue_queue.issue.first);
  endrule

  rule connectFpu;
    fpu_issue_queue.issue.deq;
    fpu_fu.enq(fpu_issue_queue.issue.first);
  endrule

  rule connectLoad;
    let succede <- lsu.wakeupLoad(load_issue_queue.issue.first);
    if (succede) load_issue_queue.issue.deq();
  endrule

  rule connectStoreData;
    let succede <- lsu.wakeupStoreData(store_data_issue_queue.issue.first);
    if (succede) store_data_issue_queue.issue.deq();
  endrule

  rule connectStoreAddr;
    let succede <- lsu.wakeupStoreAddr(store_addr_issue_queue.issue.first);
    if (succede) store_addr_issue_queue.issue.deq();
  endrule

  //(* descending_urgency = "commit_interrupt, execute_direct, write_back" *)
  rule write_back;
    let response <- toWB.get;
    wakeupFn(response.fst, response.snd);
    rob.writeBack(response.fst, response.snd);
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

  (* mutually_exclusive = "commit_interrupt, execute_direct" *)
  (* preempts = "commit_interrupt, execute_direct" *)
  rule commit_interrupt if (
      csr.readyInterrupt matches tagged Valid .cause &&&
      rob.first_result matches Invalid &&&
      rob.first.tag != EXEC_TAG_DMEM &&
      rob.first.epoch == epoch[0]
    );
    let index = rob.first_index;
    let entry = rob.first;

    let trap_pc <- csr.exec_exception(entry.pc, True, pack(cause), 0);
    //$display("interrupt at %h ", entry.pc, fshow(cause));

    registers.setReady(zeroReg, 0, Invalid, True);
    fn_mispredict(trap_pc);

    fetch.trainMis(BranchPredTrain{
      pc: entry.pc,
      instr: Invalid,
      next_pc: trap_pc,
      state: entry.bpred_state
    });
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

    // The instruction return a mispredicted value according to a previous
    // load store unit commit
    if (killed[index] == 1) begin
      deqRob(Invalid, Invalid, Valid(pc));
      fetch.trainMis(BranchPredTrain{
        pc: pc,
        instr: Invalid,
        next_pc: pc+4,
        state: entry.bpred_state
      });
    end else
      doCommit(index, entry, result);
  endrule

  rule execute_direct if (
      rob.first.tag == EXEC_TAG_DIRECT &&&
      rob.first_result matches Invalid);
    ExecInput#(2) request = direct_issue_queue.issue.first;
    direct_issue_queue.issue.deq();

    ExecOutput result = ?;

    if (rob.first.epoch == epoch[0]) result <-
      execDirect(rob.first_index, rob.first, request.regs[0], request.regs[1]);

    rob.writeBack(rob.first_index, result);
    wakeupFn(rob.first_index, result);
  endrule

  rule dispatch;
    let decoded <- fetch.to_RR.get;

    if (decoded.epoch == epoch[1])
      fn_dispatch(decoded);
  endrule

  // Use 1 instead of 0 to ensure we don't display during initialisation
  rule print_stats if (timer[18:0] == 0);
    $display("hit bpred: %d  mis bpred: %d", hitpred_instr, mispred_instr);
  endrule

  interface RdAXI4_Lite_Master rd_imem;
    interface request = fetch.rrequest;
    interface response = fetch.rresponse;
  endinterface

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

