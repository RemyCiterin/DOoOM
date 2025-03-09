import Utils :: *;
import Types :: *;
import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: *;
import Decode :: *;
import Vector :: *;
import CSR :: *;
import ALU :: *;
import AXI4 :: *;
import AXI4_Lite :: *;
import MemoryTypes :: *;
import RegFile :: *;
import ClientServer :: *;
import MulDiv :: *;

import STB :: *;

import Ehr :: *;
import Fifo :: *;

interface Pipeline;
  interface Put#(RR_to_Pipeline) from_RR;
  interface Get#(Pipeline_to_WB) to_WB;
endinterface

interface DMEM_IFC;
  interface Pipeline pipeline;
  interface RdAXI4_Lite_Master#(32, 4) rd_mmio;
  interface WrAXI4_Lite_Master#(32, 4) wr_mmio;
  interface RdAXI4_Master#(4, 32, 4) rd_dmem;
  interface WrAXI4_Master#(4, 32, 4) wr_dmem;

  // this pipeline has a type of effect so it have the commit interface to commit the
  // write operations
  method Action commit(Bool must_commit);

  (* always_ready, always_enabled *)
  method Bool emptySTB;
endinterface

// DMEM stage mix requests between read, stores, and misaligned requests, so we
// have to remember the type of the requests to ensures we send them to the
// write-back stage in order
typedef enum {Rd, Wr, NotAlign} DMEM_Tag deriving(Bits, Eq, FShow);

(* synthesize *)
module mkDMEM(DMEM_IFC);
  DMEM_Controller dmem <- mkMiniSTB;
  Fifo#(4, Bool) commitQ <- mkPipelineFifo;

  Fifo#(3, Bool) signQ <- mkPipelineFifo;
  Fifo#(3, Data_Size) sizeQ <- mkPipelineFifo;
  Fifo#(3, Bit#(2)) offsetQ <- mkPipelineFifo;
  Fifo#(3, RR_to_Pipeline) reqQ <- mkPipelineFifo;

  Fifo#(1, RR_to_Pipeline) inputQ <- mkPipelineFifo;

  Fifo#(1, Pipeline_to_WB) rresponseQ <- mkBypassFifo;
  Fifo#(3, Pipeline_to_WB) wresponseQ <- mkPipelineFifo;
  Fifo#(3, DMEM_Tag) tagQ <- mkPipelineFifo;

  function Bool isAligned(Bit#(32) addr, Data_Size size);
    return case (size) matches
      Word : addr[1:0] == 0;
      Half : addr[0] == 0;
      Byte : True;
    endcase;
  endfunction

  rule deq_rresponse;
    let sign = signQ.first;
    let size = sizeQ.first;
    let offset = offsetQ.first;
    signQ.deq;
    sizeQ.deq;
    offsetQ.deq;

    let req = reqQ.first;
    reqQ.deq;

    Bit#(32) response <- dmem.rresponse;
    Bit#(32) bytes = response >> {offset, 3'b0};

    let result = case (size) matches
      Word : bytes;
      Half : (sign ? signExtend(bytes[15:0]) : zeroExtend(bytes[15:0]));
      Byte : (sign ? signExtend(bytes[7:0]) : zeroExtend(bytes[7:0]));
    endcase;

    rresponseQ.enq(Pipeline_to_WB{
      exception: False,
      cause: ?,
      tval: ?,
      epoch: req.epoch,
      next_pc: req.pc+4,
      result: result
    });
  endrule

  rule deq_from_rr;
    let req = inputQ.first;
    inputQ.deq;

    let addr = req.rs1_val + immediateBits(req.instr);
    let bytes = req.rs2_val;

    case (req.instr) matches
      tagged Stype {op: .op} : begin
        let size = case (op) matches
          SB : Byte;
          SH : Half;
          SW : Word;
        endcase;

        Bit#(4) mask = case (op) matches
          SB : 4'b0001;
          SH : 4'b0011;
          SW : 4'b1111;
        endcase;

        let aligned = isAligned(addr, size);

        commitQ.enq(aligned);

        if (aligned) begin
          tagQ.enq(Wr);

          bytes = bytes << {addr[1:0], 3'b0};
          mask = mask << addr[1:0];

          dmem.wrequest(addr, bytes, mask);
          wresponseQ.enq(Pipeline_to_WB{
            exception: False,
            cause: ?,
            tval: ?,
            epoch: req.epoch,
            next_pc: req.pc+4,
            result: ?
          });
        end else begin
          tagQ.enq(NotAlign);
          wresponseQ.enq(Pipeline_to_WB{
            epoch: req.epoch,
            exception: True,
            cause: STORE_AMO_ADDRESS_MISALIGNED,
            tval: addr,
            next_pc: ?,
            result: ?
          });
        end
      end

      tagged Itype {op: tagged Load .op} : begin
        match {.size, .sign} = case (op) matches
          LB : Tuple2{fst: Byte, snd: True};
          LH : Tuple2{fst: Half, snd: True};
          LW : Tuple2{fst: Word, snd: True};
          LBU : Tuple2{fst: Byte, snd: False};
          LHU : Tuple2{fst: Half, snd: False};
        endcase;

        let aligned = isAligned(addr, size);

        commitQ.enq(False);
        tagQ.enq(aligned ? Rd : NotAlign);

        if (aligned) begin
          reqQ.enq(req);
          signQ.enq(sign);
          sizeQ.enq(size);
          offsetQ.enq(addr[1:0]);
          dmem.rrequest(addr & ~32'b11);
        end else begin
          wresponseQ.enq(Pipeline_to_WB{
            epoch: req.epoch,
            exception: True,
            cause: LOAD_ADDRESS_MISALIGNED,
            tval: addr,
            next_pc: ?,
            result: ?
          });
        end
      end
      default: $display("no-dmem instr in the dmem stage");
    endcase
  endrule

  interface Pipeline pipeline;
    interface from_RR = toPut(inputQ);
    interface Get to_WB;
      method ActionValue#(Pipeline_to_WB) get;
        actionvalue
          let tag = tagQ.first;
          tagQ.deq;

          case (tag) matches
            Rd : begin
              let ret <- toGet(rresponseQ).get;
              return ret;
            end
            Wr : begin
              let ret <- toGet(wresponseQ).get;
              return ret;
            end
            NotAlign : begin
              let ret <- toGet(wresponseQ).get;
              return ret;
            end
          endcase
        endactionvalue
      endmethod
    endinterface
  endinterface

  method Action commit(Bool b);
    let op = commitQ.first;
    commitQ.deq;

    if (op)
      dmem.wcommit(b);
  endmethod

  interface rd_dmem = dmem.rd_dmem;
  interface wr_dmem = dmem.wr_dmem;
  interface rd_mmio = dmem.rd_mmio;
  interface wr_mmio = dmem.wr_mmio;
  method emptySTB = dmem.emptySTB;
endmodule


function Pipeline_to_WB execALU(RR_to_Pipeline request);
  let result = case (request.instr) matches
    tagged Utype {op: LUI} : immediateBits(request.instr);
    tagged Utype {op: AUIPC} : request.pc + immediateBits(request.instr);
    default :
      fn_ALU(ALU_Query{instr: request.instr, rs1: request.rs1_val, rs2: request.rs2_val});
  endcase;

  return Pipeline_to_WB {
    exception: False,
    cause: ?,
    tval: ?,
    epoch: request.epoch,
    //instr: request.instr,
    next_pc: request.pc+4,
    result: result
  };
endfunction

(* synthesize *)
module mkALUPipeline(Pipeline);
  FIFOF#(RR_to_Pipeline) rr_to_alu <- mkPipelineFIFOF;
  FIFOF#(Bit#(2)) tags <- mkPipelineFIFOF;

  let multiplier <- mkMulServer;
  let diviser <- mkDivServer;

  interface Put from_RR;
    method Action put(RR_to_Pipeline request);
      action
        rr_to_alu.enq(request);
        case (request.instr) matches
          tagged Rtype {op: MUL} : begin
            multiplier.request.put(MulRequest{
              x1: request.rs1_val, x2: request.rs2_val,
              x1Signed: True, x2Signed: True, high: False
            });
            tags.enq(0);
          end
          tagged Rtype {op: MULH} : begin
            multiplier.request.put(MulRequest{
              x1: request.rs1_val, x2: request.rs2_val,
              x1Signed: True, x2Signed: True, high: True
            });
            tags.enq(0);
          end
          tagged Rtype {op: MULHSU} : begin
            multiplier.request.put(MulRequest{
              x1: request.rs1_val, x2: request.rs2_val,
              x1Signed: True, x2Signed: False, high: True
            });
            tags.enq(0);
          end
          tagged Rtype {op: MULHU} : begin
            multiplier.request.put(MulRequest{
              x1: request.rs1_val, x2: request.rs2_val,
              x1Signed: False, x2Signed: False, high: True
            });
            tags.enq(0);
          end
          tagged Rtype {op: DIV} : begin
            diviser.request.put(DivRequest{
              x1: request.rs1_val, x2: request.rs2_val,
              isSigned: True, rem: False
            });
            tags.enq(1);
          end
          tagged Rtype {op: DIVU} : begin
            diviser.request.put(DivRequest{
              x1: request.rs1_val, x2: request.rs2_val,
              isSigned: False, rem: False
            });
            tags.enq(1);
          end
          tagged Rtype {op: REM} : begin
            diviser.request.put(DivRequest{
              x1: request.rs1_val, x2: request.rs2_val,
              isSigned: True, rem: True
            });
            tags.enq(1);
          end
          tagged Rtype {op: REMU} : begin
            diviser.request.put(DivRequest{
              x1: request.rs1_val, x2: request.rs2_val,
              isSigned: False, rem: True
            });
            tags.enq(1);
          end
          default: tags.enq(2);
        endcase
      endaction
    endmethod
  endinterface

  interface Get to_WB;
    method ActionValue#(Pipeline_to_WB) get;
      actionvalue
        let result = execALU(rr_to_alu.first);
        rr_to_alu.deq;

        case (tags.first) matches
          0 : result.result <- multiplier.response.get;
          1 : result.result <- diviser.response.get;
          default: noAction;
        endcase
        tags.deq;

        return result;
      endactionvalue
    endmethod
  endinterface
endmodule


function Pipeline_to_WB controlFlow(RR_to_Pipeline request);
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

      return Pipeline_to_WB {
        exception: exception,
        cause: INSTRUCTION_ADDRESS_MISALIGNED,
        tval: next_pc,
        epoch: request.epoch,
        //instr: request.instr,
        next_pc: next_pc,
        result: 0
      };
    end
    tagged Itype {op: JALR} : begin
      Bit#(32) next_pc = (rs1 + immediateBits(request.instr)) & ~1;
      Bool exception = next_pc[1:0] != 0;
      return Pipeline_to_WB {
        exception: exception,
        cause: INSTRUCTION_ADDRESS_MISALIGNED,
        tval: next_pc,
        epoch: request.epoch,
        //instr: request.instr,
        next_pc: next_pc,
        result: request.pc+4
      };
    end
    tagged Jtype .* : begin
      Bit#(32) next_pc = request.pc + immediateBits(request.instr);
      Bool exception = next_pc[1:0] != 0;

      return Pipeline_to_WB {
        exception: exception,
        cause: INSTRUCTION_ADDRESS_MISALIGNED,
        tval: next_pc,
        epoch: request.epoch,
        //instr: request.instr,
        next_pc: next_pc,
        result: request.pc+4
      };
    end
  endcase
endfunction

(* synthesize *)
module mkControlPipeline(Pipeline);
  FIFOF#(RR_to_Pipeline) rr_to_control <- mkPipelineFIFOF;
  FIFOF#(Pipeline_to_WB) control_to_wb <- mkBypassFIFOF;

  rule connect;
    control_to_wb.enq(controlFlow(rr_to_control.first));
    rr_to_control.deq;
  endrule

  interface from_RR = toPut(rr_to_control);
  interface to_WB = toGet(control_to_wb);
endmodule
