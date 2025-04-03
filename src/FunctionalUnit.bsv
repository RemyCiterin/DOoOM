import Utils :: *;
import Decode :: *;
import Vector :: *;
import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: *;
import ClientServer :: *;
import MulDiv :: *;
import FPoint :: *;
import Fifo :: *;
import ALU :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;


// Describe a purely functional unit
// The module must have enq < finish
interface FunctionalUnit#(numeric type numReg);
  // start executing an instruction
  method Action enq(ExecInput#(numReg) arg);

  // finish executing an instruction
  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;

  // return if the functoinal unit is ready to dequeue
  method Bool canDeq;
endinterface

function ExecOutput execALU(ExecInput#(2) request);
  let result = case (request.instr) matches
    tagged Utype {op: LUI} : immediateBits(request.instr);
    tagged Utype {op: AUIPC} : request.pc + immediateBits(request.instr);
    default :
      fn_ALU(ALU_Query{instr: request.instr, rs1: request.regs[0], rs2: request.regs[1]});
  endcase;

  return tagged Ok {
    next_pc: request.pc + 4,
    fflags: Invalid,
    flush: False,
    rd_val: result
  };
endfunction

(* synthesize *)
module mkALU_FU(FunctionalUnit#(2));
  FIFOF#(ExecInput#(2)) to_alu <- mkPipelineFIFOF;

  FIFOF#(ExecInput#(2)) to_mul <- mkPipelineFIFOF;
  FIFOF#(ExecInput#(2)) to_div <- mkPipelineFIFOF;

  FIFOF#(Tuple2#(RobIndex, ExecOutput)) to_wb <- mkBypassFIFOF;

  let multiplier <- mkMulServer;
  let diviser <- mkDivServer;

  rule compute;
    if (to_alu.notEmpty) begin
      let req <- toGet(to_alu).get;
      to_wb.enq(tuple2(req.index, execALU(req)));
    end else if (to_mul.notEmpty) begin
      let req <- toGet(to_mul).get;
      let res <- multiplier.response.get;
      to_wb.enq(tuple2(req.index,
        tagged Ok {
          rd_val: res,
          flush: False,
          fflags: Invalid,
          next_pc: req.pc + 4
        }
      ));
    end else begin
      let res <- diviser.response.get;
      let req <- toGet(to_div).get;
      to_wb.enq(tuple2(req.index,
        tagged Ok {
          rd_val: res,
          flush: False,
          fflags: Invalid,
          next_pc: req.pc + 4
        }
      ));
    end
  endrule

  method Action enq(ExecInput#(2) req);
    action
      case (req.instr) matches
        tagged Rtype {op: MUL} : begin
          to_mul.enq(req);
          multiplier.request.put(MulRequest{
            x1: req.regs[0], x2: req.regs[1],
            x1Signed: True, x2Signed: True, high: False
          });
        end
        tagged Rtype {op: MULH} : begin
          to_mul.enq(req);
          multiplier.request.put(MulRequest{
            x1: req.regs[0], x2: req.regs[1],
            x1Signed: True, x2Signed: True, high: True
          });
        end
        tagged Rtype {op: MULHSU} : begin
          to_mul.enq(req);
          multiplier.request.put(MulRequest{
            x1: req.regs[0], x2: req.regs[1],
            x1Signed: True, x2Signed: False, high: True
          });
        end
        tagged Rtype {op: MULHU} : begin
          to_mul.enq(req);
          multiplier.request.put(MulRequest{
            x1: req.regs[0], x2: req.regs[1],
            x1Signed: False, x2Signed: False, high: True
          });
        end
        tagged Rtype {op: DIV} : begin
          to_div.enq(req);
          diviser.request.put(DivRequest{
            x1: req.regs[0], x2: req.regs[1],
            isSigned: True, rem: False
          });
        end
        tagged Rtype {op: DIVU} : begin
          to_div.enq(req);
          diviser.request.put(DivRequest{
            x1: req.regs[0], x2: req.regs[1],
            isSigned: False, rem: False
          });
        end
        tagged Rtype {op: REM} : begin
          to_div.enq(req);
          diviser.request.put(DivRequest{
            x1: req.regs[0], x2: req.regs[1],
            isSigned: True, rem: True
          });
        end
        tagged Rtype {op: REMU} : begin
          to_div.enq(req);
          diviser.request.put(DivRequest{
            x1: req.regs[0], x2: req.regs[1],
            isSigned: False, rem: True
          });
        end
        default: to_alu.enq(req);
      endcase
    endaction
  endmethod

  method deq = toGet(to_wb).get;

  method canDeq = to_wb.notEmpty;
endmodule


function ExecOutput controlFlow(ExecInput#(2) request);
  Bit#(32) rs1 = request.regs[0];
  Bit#(32) rs2 = request.regs[1];
  Int#(32) rs1_int = unpack(rs1);
  Int#(32) rs2_int = unpack(rs2);

  case (request.instr) matches
    tagged Btype {op: .op} : begin
      Bool take_branch =
        case (op) matches
          BEQ : rs1 == rs2;
          BNE : rs1 != rs2;
          BLT : rs1_int < rs2_int;
          BGE : rs1_int >= rs2_int;
          BLTU : rs1 < rs2;
          BGEU : rs1 >= rs2;
      endcase;

      Bit#(32) next_pc =
        (take_branch ? request.pc + immediateBits(request.instr) : request.pc + 4);

      Bool exception = take_branch && next_pc[1:0] != 0;

      if (take_branch && next_pc[1:0] != 0)
        return tagged Error {
          cause: INSTRUCTION_ADDRESS_MISALIGNED,
          tval: next_pc
        };
      else
        return tagged Ok {
          next_pc: next_pc,
          fflags: Invalid,
          flush: False,
          rd_val: 0
        };
    end
    tagged Itype {op: JALR} : begin
      Bit#(32) next_pc = (rs1 + immediateBits(request.instr)) & ~1;
      if (next_pc[1:0] != 0)
        return tagged Error {
          cause: INSTRUCTION_ADDRESS_MISALIGNED,
          tval: next_pc
        };
      else
        return tagged Ok {
          flush: False,
          fflags: Invalid,
          next_pc: next_pc,
          rd_val: request.pc+4
        };
    end
    tagged Jtype .* : begin
      Bit#(32) next_pc = request.pc + immediateBits(request.instr);
      if (next_pc[1:0] != 0)
        return tagged Error {
          cause: INSTRUCTION_ADDRESS_MISALIGNED,
          tval: next_pc
        };
      else
        return tagged Ok {
          flush: False,
          fflags: Invalid,
          next_pc: next_pc,
          rd_val: request.pc+4
        };
    end
  endcase
endfunction

(* synthesize *)
module mkControlFU(FunctionalUnit#(2));
  FIFOF#(ExecInput#(2)) to_control <- mkPipelineFIFOF;
  FIFOF#(Tuple2#(RobIndex, ExecOutput)) to_wb <- mkBypassFIFOF;

  rule compute;
    let request = to_control.first;
    to_control.deq();

    to_wb.enq(tuple2(request.index, controlFlow(request)));
  endrule

  method enq = to_control.enq;

  method deq = toGet(to_wb).get;

  method canDeq = to_wb.notEmpty;
endmodule

(*synthesize *)
module mkFpuFU(FunctionalUnit#(3));
  Fifo#(1, ExecInput#(3)) inputQ <- mkPipelineFifo;
  Fifo#(1, Tuple2#(RobIndex, ExecOutput)) outputQ <- mkBypassFifo;

  FPointPipeline#(Tuple2#(RobIndex, Bit#(32))) fpu <- mkFPointPipeline(False);

  rule enqFma
    if (inputQ.first.instr matches tagged R4type {op: .op, instr: .instr});
    let req <- toGet(inputQ).get();

    let frm = getFunct3(instr.bits) == 3'b111 ?
      req.frm : getFunct3(instr.bits);

    fpu.request.enq(FpuRequest{
        id: tuple2(req.index, req.pc),
        rs1: unpack(req.regs[0]),
        rs2: unpack(req.regs[1]),
        rs3: unpack(req.regs[2]),
        op: Fma(op),
        frm: frm
    });
  endrule

  rule enqRop
    if (inputQ.first.instr matches tagged Rtype {op: tagged FloatOp .op, instr: .instr});
    let req <- toGet(inputQ).get();

    let frm = getFunct3(instr.bits) == 3'b111 ?
      req.frm : getFunct3(instr.bits);

    fpu.request.enq(FpuRequest{
        id: tuple2(req.index, req.pc),
        rs1: unpack(req.regs[0]),
        rs2: unpack(req.regs[1]),
        rs3: unpack(req.regs[2]),
        op: Rop(op),
        frm: frm
    });
  endrule

  rule deqFpu;
    let resp <- toGet(fpu.response).get;
    outputQ.enq(tuple2(resp.id.fst, tagged Ok {
      fflags: Valid(resp.fflags),
      rd_val: pack(resp.result),
      next_pc: resp.id.snd+4,
      flush: False
    }));
  endrule

  method enq = inputQ.enq;
  method deq = toGet(outputQ).get;
  method canDeq = outputQ.canDeq;
endmodule
