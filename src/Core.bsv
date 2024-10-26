package Core;

import Array :: *;
import AXI4_Lite_Adapter :: *;
import Connectable :: *;
import AXI4_Lite :: *;

import FIFOF :: *;
import SpecialFIFOs :: *;
import GetPut :: *;

import Decode :: *;
import Utils :: *;
import Types :: *;

import WriteBack :: *;
import RegisterRead :: *;
import Vector :: *;

import OOO :: *;
import ROB :: *;
import CSR :: *;
import IssueQueue :: *;
import RegisterFile :: *;
import FunctionalUnit :: *;
import LoadStoreUnit :: *;

import TileLink :: *;
import Mutex :: *;
import BlockRam :: *;
import Ehr :: *;
import BTB :: *;

import FetchDecode :: *;

interface Core_IFC;
  interface WrAXI4_Lite_Master#(32, 4) wr_dmem;
  interface RdAXI4_Lite_Master#(32, 4) rd_dmem;

  interface RdAXI4_Lite_Master#(32, 4) rd_imem;

  method Bit#(64) getTime;

  method Action set_meip(Bool b);
  method Action set_mtip(Bool b);
endinterface

typedef 2 IqSize;

(* synthesize *)
module mkCoreOOO(Core_IFC);
  Bool verbose = False;

  Ehr#(2, Epoch) epoch <- mkEhr(0);

  let fetch <- mkFetchDecode;
  //let decode <- mkDecodeOOO;
  //mkConnection(fetch.to_Decode, decode.from_Fetch);

  ROB rob <- mkROB;

  IssueQueue#(IqSize) alu_issue_queue <- mkIssueQueue;
  FunctionalUnit alu_fu <- mkALU_FU;

  IssueQueue#(IqSize) control_issue_queue <- mkIssueQueue;
  FunctionalUnit control_fu <- mkControlFU;

  LoadStoreUnit lsu <- mkLoadStoreUnit2;

  // indicate if a load is killed by the load store unit
  // because it return a bad value
  Reg#(Bit#(RobSize)) killed <- mkReg(0);

  let toWB <- mkGetScheduler(
    cons(alu_fu.canDeq, cons(control_fu.canDeq, cons(lsu.canDeq, nil))),
    cons(alu_fu.deq, cons(control_fu.deq, cons(lsu.deq, nil)))
  );

  RegisterFile registers <- mkRegisterFile;

  let csr <- mkCsrFile(0);

  RdAXI4_Lite_Master#(32, 4) master_read <-
    mkRiscv_RdAXI4_Lite_Master_Adapter(lsu.mem_read);
  WrAXI4_Lite_Master#(32, 4) master_write <-
    mkRiscv_WrAXI4_Lite_Master_Adapter(lsu.mem_write);

  Reg#(Bit#(64)) timer <- mkReg(0);
  Reg#(Bit#(64)) commitN <- mkReg(0);

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
      Maybe#(Bit#(32)) next_pc
    );
    action
      let entry = rob.first;
      let index = rob.first_index;

      if (entry.tag == EXEC_TAG_DMEM) begin
        let status <- lsu.commit(index, value != Invalid);

        Bit#(RobSize) new_killed = killed;
        if (status matches tagged Exception .idx)
          new_killed[idx] = 1;
        new_killed[index] = 0;
        killed <= new_killed;
      end

      if (value matches tagged Valid .val &&&
        destination(entry.instr).name != 0 &&& verbose)
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
      alu_issue_queue.wakeup(index, rd_val);
      lsu.wakeup(index, rd_val);
    endaction
  endfunction

  // Dispatch a decoded instruction: enqueue it in the Reorder buffer and the
  // issue queues, use the bypassed value for the register evaluation
  function Action fn_dispatch(FromDecode decoded);
    action
      let rob_result = (decoded.exception ?
        tagged Valid (tagged Error {cause: decoded.cause, tval: decoded.tval}) :
        Invalid
      );

      let tag = (decoded.exception ? EXEC_TAG_DIRECT : tagOfInstr(decoded.instr));

      RobEntry rob_entry = RobEntry{
        pc: decoded.pc,
        tag: tag,
        instr: decoded.instr,
        epoch: decoded.epoch,
        pred_pc: decoded.pred_pc,
        result: rob_result,
        bpred_state: decoded.bpred_state
      };

      let index <- rob.enq(rob_entry);
      let rs1_val = registers.rs1(register1(decoded.instr));
      let rs2_val = registers.rs2(register2(decoded.instr));

      if (rs1_val matches tagged Wait .idx &&& rob.read1(idx).result matches tagged Valid .res)
        rs1_val = tagged Value getRdVal(res);
      if (rs2_val matches tagged Wait .idx &&& rob.read2(idx).result matches tagged Valid .res)
        rs2_val = tagged Value getRdVal(res);

      registers.setBusy(destination(decoded.instr), index);

      IssueQueueEntry iq_entry = IssueQueueEntry{
        index: index,
        pc: decoded.pc,
        instr: decoded.instr,
        rs1_val: rs1_val,
        rs2_val: rs2_val
      };

      case (tag) matches
        EXEC_TAG_EXEC: begin
          alu_issue_queue.enq(iq_entry);
        end
        EXEC_TAG_CONTROL: begin
          control_issue_queue.enq(iq_entry);
        end
        EXEC_TAG_DMEM: begin
          lsu.enq(iq_entry);
        end
        default: noAction;
      endcase
    endaction
  endfunction

  // Commit an instruction and remove it of the ROB
  function Action doCommit(RobIndex index, RobEntry entry, ExecOutput result);
    action
      if (verbose)
        $display("  wb %h ", entry.pc, displayInstr(entry.instr));

      if (entry.tag != EXEC_TAG_DIRECT)
        csr.increment_instret;

      case (result) matches
        tagged Ok {next_pc: .next_pc, rd_val: .rd_val} : begin
          deqRob(
            tagged Valid rd_val,
            next_pc != entry.pred_pc ? Valid(next_pc) : Invalid
          );

          if (next_pc != entry.pred_pc) begin
            fetch.trainMis(BranchPredTrain{
              pc: entry.pc,
              instr: tagged Valid entry.instr,
              next_pc: next_pc,
              state: entry.bpred_state
            });
          end else begin
            fetch.trainHit(BranchPredTrain{
              pc: entry.pc,
              instr: tagged Valid entry.instr,
              next_pc: next_pc,
              state: entry.bpred_state
            });

          end
        end
        tagged Error {cause: .cause, tval: .tval} : begin
          //$display("%d %h  ", index, entry.pc, displayInstr(entry.instr));
          Bit#(32) trap_pc <- csr.exec_exception(entry.pc, False, pack(cause), tval);
          deqRob(Invalid, Valid(trap_pc));

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

  function Action execCSR(RobIndex index, RobEntry entry);
    action
      case (entry.instr) matches
        tagged Itype {instr: .*, op: ECALL} : begin
          csr.increment_instret;
          rob.writeBack(index, tagged Error {
            cause: ECALL_FROM_M,
            tval: entry.pc
          });
        end
        tagged Itype {instr: .instr, op: tagged Ret MRET} : begin
          let pc <- csr.mret;
          csr.increment_instret;
          rob.writeBack(index, tagged Ok { rd_val: 0, next_pc: pc });
          wakeupFn(index, tagged Ok { rd_val: 0, next_pc: pc });
        end
        tagged Itype {instr: .instr, op: .op} : begin
          let rs1 = registers.read_commited(register1(instr));

          Maybe#(Bit#(32)) result <- csr.exec_csrxx(instr, op, rs1);

          case (result) matches
            tagged Valid .v : begin
              wakeupFn(index, tagged Ok {rd_val: v, next_pc: entry.pc+4});
              rob.writeBack(index, tagged Ok {rd_val: v, next_pc: entry.pc+4});
            end
            Invalid: begin
              wakeupFn(index, tagged Error {cause: ILLEGAL_INSTRUCTION, tval: entry.pc});
              rob.writeBack(index, tagged Error {cause: ILLEGAL_INSTRUCTION, tval: entry.pc});
            end
          endcase
        end
        default: begin
          wakeupFn(index, tagged Error {cause: ILLEGAL_INSTRUCTION, tval: entry.pc});
          rob.writeBack(index, tagged Error {cause: ILLEGAL_INSTRUCTION, tval: entry.pc});
        end
      endcase
    endaction
  endfunction

  rule connectALU;
    let request <- alu_issue_queue.issue;
    alu_fu.enq(request);
  endrule

  rule connectControl;
    let request <- control_issue_queue.issue;
    control_fu.enq(request);
  endrule

  (* descending_urgency = "commit_interrupt, execute_csr, writeback_mispredicted_csr, write_back" *)
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
    if (rob.first.epoch != epoch[0] &&& rob.first.result matches tagged Valid .*);
    deqRob(Invalid, Invalid);
  endrule

  rule commit_interrupt if (
      csr.readyInterrupt matches tagged Valid .cause &&&
      rob.first.result matches Invalid &&&
      rob.first.epoch == epoch[0]
    );
    let index = rob.first_index;
    let entry = rob.first;

    let trap_pc <- csr.exec_exception(entry.pc, True, pack(cause), 0);
    registers.setReady(RegName{name: 0}, 0, Invalid, False);

    fetch.trainMis(BranchPredTrain{
      pc: entry.pc,
      instr: Invalid,
      next_pc: trap_pc,
      state: entry.bpred_state
    });
  endrule

  rule commit_instruction if (
      rob.first.result matches tagged Valid .result &&&
      rob.first.epoch == epoch[0]);

    let index = rob.first_index;
    let entry = rob.first;
    let pc = entry.pc;

    // The instruction return a mispredicted value according to a previous
    // load store unit commit
    if (killed[0][index] == 1) begin
      deqRob(Invalid, Valid(pc));
      fetch.trainMis(BranchPredTrain{
        pc: pc,
        instr: Invalid,
        next_pc: pc+4,
        state: entry.bpred_state
      });
    end else
      doCommit(index, entry, result);
  endrule

  // write back a direct instruction so we may commit it at the next cycle
  rule writeback_mispredicted_csr
    if (rob.first.tag == EXEC_TAG_DIRECT && rob.first.epoch != epoch[0] &&& rob.first.result matches Invalid);
    rob.writeBack(rob.first_index, ?);
    wakeupFn(rob.first_index, ?);
  endrule

  // write back a direct instruction so we may commit it at the next cycle
  rule execute_csr
    if (rob.first.tag == EXEC_TAG_DIRECT && rob.first.epoch == epoch[0] &&& rob.first.result matches Invalid);
    execCSR(rob.first_index, rob.first);
  endrule

  rule dispatch;
    let decoded <- fetch.to_RR.get;

    if (decoded.epoch == epoch[1])
      fn_dispatch(decoded);
  endrule

  interface RdAXI4_Lite_Master rd_imem;
    interface request = fetch.rrequest;
    interface response = fetch.rresponse;
  endinterface

  interface rd_dmem = master_read;
  interface wr_dmem = master_write;

  method Bit#(64) getTime;
    return timer;
  endmethod

  method set_meip = csr.set_meip;
  method set_mtip = csr.set_mtip;
endmodule


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

  RdAXI4_Lite_Master#(32, 4) master_read <- mkRiscv_RdAXI4_Lite_Master_Adapter(dmem.mem_read);
  WrAXI4_Lite_Master#(32, 4) master_write <- mkRiscv_WrAXI4_Lite_Master_Adapter(dmem.mem_write);

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

  method Bit#(64) getTime;
    return timer;
  endmethod

  interface RdAXI4_Lite_Master rd_imem;
    interface request = fetch.rrequest;
    interface response = decode.rresponse;
  endinterface

  interface rd_dmem = master_read;
  interface wr_dmem = master_write;

  method set_meip = wb.set_meip;
  method set_mtip = wb.set_mtip;
endmodule


endpackage
