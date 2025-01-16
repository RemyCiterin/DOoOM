package WriteBack;

import Array :: *;
import AXI4_Lite_Adapter :: *;
import AXI4_Lite :: *;

import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: *;

import Decode :: *;
import Utils :: *;
import Types :: *;
import CSR :: *;
import BTB :: *;

import Fifo :: *;

interface Fetch_IFC;
  interface Get#(AXI4_Lite_RRequest#(32)) rrequest;

  interface Put#(WB_to_Fetch) from_WriteBack;
  interface Get#(Fetch_to_Decode) to_Decode;

  method Action start(File flog);
endinterface

(* synthesize *)
module mkFetch (Fetch_IFC);
  FIFOF#(WB_to_Fetch) wb_to_fetch <- mkPipelineFIFOF;
  FIFOF#(Fetch_to_Decode) fetch_to_decode <- mkBypassFIFOF;
  FIFOF#(AXI4_Lite_RRequest#(32)) read_request <- mkBypassFIFOF;

  Reg#(Epoch) epoch <- mkReg(0);
  Reg#(Bit#(32)) current_pc <- mkReg(32'h80000000);

  BTB_IFC btb <- mkBTB;

  Reg#(INum) inum <- mkReg(0);

  Reg#(Bool) is_start <- mkReg(False);
  Log_IFC log <- mkLog;

  rule step if(is_start && read_request.notFull);
    let pc = current_pc;
    let predicted_pc = btb.read(pc);
    current_pc <= predicted_pc;
    inum <= inum + 1;

    log.log("F", inum, pc, $format());

    read_request.enq(AXI4_Lite_RRequest{
      addr: pc
    });

    fetch_to_decode.enq(Fetch_to_Decode{
      pc: pc, predicted_pc: predicted_pc, epoch: epoch, inum: inum
    });

  endrule

  rule clear;
    let req = wb_to_fetch.first;
    wb_to_fetch.deq;

    //$display("clear fstch stage with pc= %h", req.next_pc);

    case (req.instr) matches
      tagged Valid .instr :
        btb.update(req.pc, req.next_pc);
      default: noAction;
    endcase

    current_pc <= req.next_pc;
    epoch <= req.next_epoch;
  endrule

  method Action start(File f);
    action
      log.start(f);
      is_start <= True;
    endaction
  endmethod

  interface rrequest = toGet(read_request);

  interface from_WriteBack = toPut(wb_to_fetch);
  interface to_Decode = toGet(fetch_to_decode);
endmodule


interface Decode_IFC;
  interface Put#(AXI4_Lite_RResponse#(4)) rresponse;

  interface Put#(Fetch_to_Decode) from_Fetch;
  interface Get#(Decode_to_RR) to_RR;

  method Action start(File flog);
endinterface

module mkDecode#(EpochManager epoch) (Decode_IFC);
  Fifo#(3, AXI4_Lite_RResponse#(4)) read_response <- mkPipelineFifo;
  Fifo#(2, Fetch_to_Decode) fetch_to_decode <- mkPipelineFifo;

  Log_IFC log <- mkLog;

  function Decode_to_RR decodeFn(Fetch_to_Decode req, AXI4_Lite_RResponse#(4) resp);
    if (resp.resp == OKAY) begin
      return case (decodeInstr(resp.bytes)) matches
        tagged Valid .instr :
          Decode_to_RR{
            exception: False,
            cause: ?,
            tval: ?,
            epoch: req.epoch,
            pc: req.pc,
            inum: req.inum,
            instr: instr,
            predicted_pc: req.predicted_pc
          };
        Invalid :
          Decode_to_RR{
            exception: True,
            cause: ILLEGAL_INSTRUCTION,
            tval: req.pc,
            epoch: req.epoch,
            pc: req.pc,
            inum: req.inum,
            instr: ?,
            predicted_pc: ?
          };
      endcase;
    end else begin
      return Decode_to_RR{
        exception: True,
        cause: INSTRUCTION_ACCESS_FAULT,
        tval: req.pc,
        epoch: req.epoch,
        pc: req.pc,
        inum: req.inum,
        instr: ?,
        predicted_pc: ?
      };
    end
  endfunction

  // // kill the request if the epoch is not up-to-date with the epoch manager
  // rule wrong_epoch if (fetch_to_decode.first.epoch != epoch.read);
  //       let req = fetch_to_decode.first;
  //       fetch_to_decode.deq;
  //       read_response.deq;

  //       log.log("D", req.inum, req.pc, $format());
  // endrule

  // only propagate the request if the epoch is up-to-data with the epoch manager
  interface Get to_RR;
    method ActionValue#(Decode_to_RR) get; //  if (fetch_to_decode.first.epoch == epoch.read);
      actionvalue
        let resp = read_response.first;
        let req = fetch_to_decode.first;
        fetch_to_decode.deq;
        read_response.deq;

        log.log("D", req.inum, req.pc, $format());

        return decodeFn(req, resp);
      endactionvalue
    endmethod
  endinterface

  interface from_Fetch = toPut(fetch_to_decode);
  interface rresponse = toPut(read_response);

  method start = log.start;
endmodule


interface WriteBack_IFC;
  interface Get#(WB_to_Fetch) to_Fetch;
  interface Get#(WB_to_RR) to_RR;

  interface Put#(RR_to_WB) from_RR;

  interface Put#(Pipeline_to_WB) from_Control;
  interface Put#(Pipeline_to_WB) from_Exec;
  interface Put#(Pipeline_to_WB) from_DMEM;

  (* always_ready, always_enabled *)
  method Action set_TIME(Bit#(64) t);

  method ActionValue#(Bool) dmem_commit;

  method Action start(File flog);

  method Action set_meip(Bool b);
  method Action set_mtip(Bool b);
  method Action set_msip(Bool b);
endinterface

//  -- it take an I-type instruction, the value of rs1, and return the value of rd (or Nothing in case of error)
//  exec_csrxx :: Itype -> IOp -> Bit 32 -> ActionValue (Maybe (Bit 32))
//
//  -- it take the value of EPC, is_interrupt, the cause and the value of tval, and return the new value of pc
//  exec_exception :: Bit 32 -> Bool -> Bit 4 -> Bit 32 -> ActionValue (Bit 32)
//
//  -- read the value of epc
//  read_epc :: Bit 32
//
//  -- increment minstret
//  incr_instret :: Action
//
//  -- set the current time
//  set_TIME :: Bit 64 -> Action {-# always_ready, always_enabled #-}

Bool verbose = False;

module mkWriteBack#(EpochManager epoch)(WriteBack_IFC);

  FIFOF#(WB_to_Fetch) wb_to_fetch <- mkBypassFIFOF;
  FIFOF#(WB_to_RR) wb_to_rr <- mkBypassFIFOF;

  FIFOF#(RR_to_WB) rr_to_wb <- mkPipelineFIFOF;
  FIFOF#(Pipeline_to_WB) control_to_wb <- mkPipelineFIFOF;
  FIFOF#(Pipeline_to_WB) exec_to_wb <- mkPipelineFIFOF;
  FIFOF#(Pipeline_to_WB) dmem_to_wb <- mkPipelineFIFOF;

  FIFOF#(Bool) to_commit <- mkPipelineFIFOF;

  Log_IFC log <- mkLog;

  // control and status registers
  let csr <- mkCsrFile(0);

  Reg#(Bit#(32)) instr_count <- mkReg(0);

  function Action fn_mispredict(Maybe#(Instr) instr, Bit#(32) pc, Bit#(32) next_pc);
    action
      wb_to_fetch.enq(WB_to_Fetch{
        next_pc: next_pc, next_epoch: epoch.read + 1, pc: pc, instr: instr
      });

      epoch.update;
    endaction
  endfunction

  function Action fn_exception(Bit#(32) pc, CauseException cause, Bit#(32) tval);
    action
      Bit#(32) trap_pc <- csr.exec_exception(pc, False, pack(cause), tval);
      //$display("==========> exception pc= %h trap pc= %h", pc, trap_pc);

      // redirect fetch stage
      fn_mispredict(Invalid, pc, trap_pc);
    endaction
  endfunction

  function Action fn_commitRR(Exec_Tag tag, Instr instr, Bool commit, Bit#(32) val);
    action
      // send to the DMEM stage the information to commit the operation
      if (tag matches EXEC_TAG_DMEM)
        to_commit.enq(commit);

      if (verbose && commit && destination(instr).name != 0)
        $display("       ", fshow(destination(instr)), " := %h", val);

      // send to the register read the information to release the destination register
      // of the score board and update it's value if necessary
      wb_to_rr.enq(WB_to_RR{
        rd: destination(instr),
        commit: commit,
        val: val
      });

      if (commit)
        instr_count <= instr_count + 1;
      //$display(instr_count);
    endaction
  endfunction

  // process a system instruction (csrxx, ecall...)
  function Action fn_tag_direct(RR_to_WB direct);
    action
      case (direct.instr) matches
        tagged Itype {instr: .*, op: ECALL} : begin
          csr.increment_instret();
          fn_exception(direct.pc, ECALL_FROM_M, direct.pc);
          fn_commitRR(direct.exec_tag, direct.instr, False, ?);
        end
        tagged Itype {instr: .*, op: tagged Ret MRET} : begin
          let next_pc <- csr.mret;
          csr.increment_instret();
          fn_commitRR(direct.exec_tag, direct.instr, True, ?);
          fn_mispredict(tagged Valid direct.instr, direct.pc, next_pc);
        end
        tagged Itype {instr: .instr, op: .op} : begin
          Maybe#(Bit#(32)) result <- csr.exec_csrxx(instr, op, direct.rs1_val);

          case (result) matches
            tagged Valid .val : begin
              fn_commitRR(direct.exec_tag, direct.instr, True, val);
              if (direct.predicted_pc != direct.pc + 4)
                fn_mispredict(Invalid, direct.pc, direct.pc + 4);

            end
            Invalid : begin
              fn_exception(direct.pc, ILLEGAL_INSTRUCTION, direct.pc);
              fn_commitRR(direct.exec_tag, direct.instr, False, ?);
            end
          endcase
        end
        default:
          $display("horrible error!!!");
      endcase
    endaction
  endfunction

  function ActionValue#(Pipeline_to_WB) fn_get_request(Exec_Tag tag);
    actionvalue
      Pipeline_to_WB ret = ?;

      case (tag) matches
        EXEC_TAG_DMEM : begin
          ret = dmem_to_wb.first;
          dmem_to_wb.deq;
        end
        EXEC_TAG_EXEC : begin
          ret = exec_to_wb.first;
          exec_to_wb.deq;
        end
        EXEC_TAG_CONTROL : begin
          ret = control_to_wb.first;
          control_to_wb.deq;
        end
        default : noAction;
      endcase

      return ret;
    endactionvalue
  endfunction

  (* descending_urgency = "interrupt, commit" *)
  rule interrupt
    if (csr.readyInterrupt matches tagged Valid .cause &&& rr_to_wb.first.epoch == epoch.read);
    let pc = rr_to_wb.first.pc;

    Bit#(32) trap_pc <- csr.exec_exception(pc, True, pack(cause), 0);
    $display("interrupt at %h with cause ", pc, fshow(cause));
    fn_mispredict(Invalid, pc, trap_pc);
  endrule

  rule commit;
    let direct = rr_to_wb.first;
    rr_to_wb.deq;

    Pipeline_to_WB req <- fn_get_request(direct.exec_tag);

    log.log((direct.epoch == epoch.read ? "WB_Y" : "WB_N"), direct.inum, direct.pc, $format());

    if (direct.epoch == epoch.read) begin

      if (verbose)
        $display("  wb %h ", direct.pc, displayInstr(direct.instr));

      if (direct.exception) begin
        $display("********************************* exception find: decode %h *********************************", direct.pc);
        fn_exception(direct.pc, direct.cause, direct.tval);
        // it's not necessray to discard at the wb stage
      end else begin
        case (direct.exec_tag) matches
          EXEC_TAG_DIRECT: fn_tag_direct(direct);

          default: begin
            csr.increment_instret();
            fn_commitRR(direct.exec_tag, direct.instr, !req.exception, req.result);

            if (req.exception) begin
              $display("********************************* exception find: fu *********************************");
              $display(fshow(req.cause), "  %h", direct.pc);
              fn_exception(direct.pc, req.cause, req.tval);
            end else if (req.next_pc != direct.predicted_pc) begin
              //$display("mispredict pc= %h next= %h pred= %h", direct.pc, req.next_pc, direct.predicted_pc);
              fn_mispredict(tagged Valid direct.instr, direct.pc, req.next_pc);
            end
          end
        endcase
      end
    end else
      fn_commitRR(direct.exec_tag, direct.instr, False, ?);
  endrule

  method Action set_TIME(Bit#(64) t);
    csr.set_TIME(t);
  endmethod

  method ActionValue#(Bool) dmem_commit;
    actionvalue
      let val = to_commit.first;
      to_commit.deq;
      return val;
    endactionvalue
  endmethod

  interface to_Fetch = toGet(wb_to_fetch);
  interface to_RR = toGet(wb_to_rr);

  interface from_RR = toPut(rr_to_wb);
  interface from_Control = toPut(control_to_wb);
  interface from_Exec = toPut(exec_to_wb);
  interface from_DMEM = toPut(dmem_to_wb);

  method start = log.start;

  method set_meip = csr.set_meip;
  method set_mtip = csr.set_mtip;
endmodule

endpackage
