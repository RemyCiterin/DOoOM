import Utils :: *;
import Decode :: *;
import Vector :: *;
import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: *;
import ClientServer :: *;
import MulDiv :: *;
import ALU :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;


// Describe a purely functional unit
// The module must have enq < finish
interface FunctionalUnit;
  // start executing an instruction
  method Action enq(ExecInput arg);

  // finish executing an instruction
  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;

  // return if the functoinal unit is ready to dequeue
  method Bool canDeq;
endinterface

function ExecOutput execALU(ExecInput request);
  let result = case (request.instr) matches
    tagged Utype {op: LUI} : immediateBits(request.instr);
    tagged Utype {op: AUIPC} : request.pc + immediateBits(request.instr);
    default :
      fn_ALU(ALU_Query{instr: request.instr, rs1: request.rs1_val, rs2: request.rs2_val});
  endcase;

  return tagged Ok {
    next_pc: request.pc + 4,
    rd_val: result
  };
endfunction

(* synthesize *)
module mkALU_FU(FunctionalUnit);
  FIFOF#(ExecInput) to_alu <- mkPipelineFIFOF;

  FIFOF#(ExecInput) to_mul <- mkPipelineFIFOF;
  FIFOF#(ExecInput) to_div <- mkPipelineFIFOF;

  let multiplier <- mkMulServer;
  let diviser <- mkDivServer;

  method Action enq(ExecInput req);
    action
      case (req.instr) matches
        tagged Rtype {op: MUL} : begin
          to_mul.enq(req);
          multiplier.request.put(MulRequest{
            x1: req.rs1_val, x2: req.rs2_val,
            x1Signed: True, x2Signed: True, high: False
          });
        end
        tagged Rtype {op: MULH} : begin
          to_mul.enq(req);
          multiplier.request.put(MulRequest{
            x1: req.rs1_val, x2: req.rs2_val,
            x1Signed: True, x2Signed: True, high: True
          });
        end
        tagged Rtype {op: MULHSU} : begin
          to_mul.enq(req);
          multiplier.request.put(MulRequest{
            x1: req.rs1_val, x2: req.rs2_val,
            x1Signed: True, x2Signed: False, high: True
          });
        end
        tagged Rtype {op: MULHU} : begin
          to_mul.enq(req);
          multiplier.request.put(MulRequest{
            x1: req.rs1_val, x2: req.rs2_val,
            x1Signed: False, x2Signed: False, high: True
          });
        end
        tagged Rtype {op: DIV} : begin
          to_div.enq(req);
          diviser.request.put(DivRequest{
            x1: req.rs1_val, x2: req.rs2_val,
            isSigned: True, rem: False
          });
        end
        tagged Rtype {op: DIVU} : begin
          to_div.enq(req);
          diviser.request.put(DivRequest{
            x1: req.rs1_val, x2: req.rs2_val,
            isSigned: False, rem: False
          });
        end
        tagged Rtype {op: REM} : begin
          to_div.enq(req);
          diviser.request.put(DivRequest{
            x1: req.rs1_val, x2: req.rs2_val,
            isSigned: True, rem: True
          });
        end
        tagged Rtype {op: REMU} : begin
          to_div.enq(req);
          diviser.request.put(DivRequest{
            x1: req.rs1_val, x2: req.rs2_val,
            isSigned: False, rem: True
          });
        end
        default: to_alu.enq(req);
      endcase
    endaction
  endmethod

  method ActionValue#(Tuple2#(RobIndex, ExecOutput)) deq;
    actionvalue
      if (to_alu.notEmpty) begin
        let req <- toGet(to_alu).get;
        return Tuple2{fst: req.index, snd: execALU(req)};
      end else if (to_mul.notEmpty) begin
        let req <- toGet(to_mul).get;
        let res <- multiplier.response.get;
        return Tuple2{fst: req.index,
          snd: tagged Ok {
            rd_val: res,
            next_pc: req.pc + 4
          }
        };
      end else begin
        let req <- toGet(to_div).get;
        let res <- diviser.response.get;
        return Tuple2{fst: req.index,
          snd: tagged Ok {
            rd_val: res,
            next_pc: req.pc + 4
          }
        };
      end
    endactionvalue
  endmethod

  method canDeq = to_alu.notEmpty || to_mul.notEmpty || to_div.notEmpty;
endmodule


function ExecOutput controlFlow(ExecInput request);
  Bit#(32) rs1 = request.rs1_val;
  Bit#(32) rs2 = request.rs2_val;
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
          next_pc: next_pc,
          rd_val: request.pc+4
        };
    end
  endcase
endfunction

(* synthesize *)
module mkControlFU(FunctionalUnit);
  FIFOF#(ExecInput) to_control <- mkPipelineFIFOF;
  FIFOF#(Tuple2#(RobIndex, ExecOutput)) to_wb <- mkBypassFIFOF;

  rule step;
    let request = to_control.first;
    to_wb.enq(Tuple2{fst: request.index, snd: controlFlow(request)});
    to_control.deq;
  endrule

  method enq = to_control.enq;

  method deq = toGet(to_wb).get;

  method canDeq = to_wb.notEmpty;
endmodule
