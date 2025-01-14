package RegisterRead;

import Utils :: *;
import Types :: *;
import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: *;
import Decode :: *;
import Vector :: *;
import CSR :: *;
import ALU :: *;
import AXI4_Lite :: *;
import MemoryTypes :: *;
import WriteBack :: *;
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
  interface RdAXI4_Lite_Master#(32, 4) mem_read;
  interface WrAXI4_Lite_Master#(32, 4) mem_write;

  // this pipeline has a type of effect so it have the commit interface to commit the
  // write operations
  method Action commit(Bool must_commit);
endinterface

// DMEM stage mix requests between read, stores, and misaligned requests, so we
// have to remember the type of the requests to ensures we send them to the
// write-back stage in order
typedef enum {Rd, Wr, NotAlign} DMEM_Tag deriving(Bits, Eq, FShow);

(* synthesize *)
module mkDMEM(DMEM_IFC);
  DMEM_Controller dmem <- mkMiniSTB;
  Fifo#(3, Bool) must_wcommit <- mkPipelineFifo;

  Fifo#(3, Bool) sign_fifo <- mkPipelineFifo;
  Fifo#(3, Data_Size) size_fifo <- mkPipelineFifo;
  Fifo#(3, Bit#(2)) offset_fifo <- mkPipelineFifo;
  Fifo#(3, RR_to_Pipeline) req_fifo <- mkPipelineFifo;

  Fifo#(1, RR_to_Pipeline) rr_to_dmem <- mkPipelineFifo;

  Fifo#(3, Pipeline_to_WB) rd_to_wb <- mkBypassFifo;
  Fifo#(3, Pipeline_to_WB) wr_to_wb <- mkBypassFifo;
  Fifo#(3, DMEM_Tag) tag_to_wb <- mkBypassFifo;

  function Bool isAligned(Bit#(32) addr, Data_Size size);
    return case (size) matches
      Word : addr[1:0] == 0;
      Half : addr[0] == 0;
      Byte : True;
    endcase;
  endfunction

  rule deq_rresponse;
    let sign = sign_fifo.first;
    let size = size_fifo.first;
    let offset = offset_fifo.first;
    sign_fifo.deq;
    size_fifo.deq;
    offset_fifo.deq;

    let req = req_fifo.first;
    req_fifo.deq;

    Bit#(32) response <- dmem.rresponse;
    Bit#(32) bytes = response >> {offset, 3'b0};

    let result = case (size) matches
      Word : bytes;
      Half : (sign ? signExtend(bytes[15:0]) : zeroExtend(bytes[15:0]));
      Byte : (sign ? signExtend(bytes[7:0]) : zeroExtend(bytes[7:0]));
    endcase;

    rd_to_wb.enq(Pipeline_to_WB{
      exception: False,
      cause: ?,
      tval: ?,
      epoch: req.epoch,
      next_pc: req.pc+4,
      result: result
    });
  endrule

  rule deq_from_rr;
    let req = rr_to_dmem.first;
    rr_to_dmem.deq;

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

        must_wcommit.enq(aligned);

        if (aligned) begin
          tag_to_wb.enq(Wr);

          bytes = bytes << {addr[1:0], 3'b0};
          mask = mask << addr[1:0];

          dmem.wrequest(addr, bytes, mask);
          wr_to_wb.enq(Pipeline_to_WB{
            exception: False,
            cause: ?,
            tval: ?,
            epoch: req.epoch,
            next_pc: req.pc+4,
            result: ?
          });
        end else begin
          tag_to_wb.enq(NotAlign);
          wr_to_wb.enq(Pipeline_to_WB{
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

        must_wcommit.enq(False);
        tag_to_wb.enq(aligned ? Rd : NotAlign);


        if (aligned) begin
          req_fifo.enq(req);
          sign_fifo.enq(sign);
          size_fifo.enq(size);
          offset_fifo.enq(addr[1:0]);
          dmem.rrequest(addr & ~32'b11);
        end else begin
          wr_to_wb.enq(Pipeline_to_WB{
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
    interface from_RR = toPut(rr_to_dmem);
    interface Get to_WB;
      method ActionValue#(Pipeline_to_WB) get;
        actionvalue
          let tag = tag_to_wb.first;
          tag_to_wb.deq;

          case (tag) matches
            Rd : begin
              let ret = rd_to_wb.first;
              rd_to_wb.deq;
              return ret;
            end
            Wr : begin
              let ret = wr_to_wb.first;
              wr_to_wb.deq;
              return ret;
            end
            NotAlign : begin
              let ret = wr_to_wb.first;
              wr_to_wb.deq;
              return ret;
            end
          endcase
        endactionvalue
      endmethod
    endinterface
  endinterface

  method Action commit(Bool b);
    let op = must_wcommit.first;
    must_wcommit.deq;

    if (op)
      dmem.wcommit(b);
  endmethod

  interface mem_read = dmem.rd_port;
  interface mem_write = dmem.wr_port;
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

interface RegisterRead_IFC;
  // input fifo
  interface Put#(Decode_to_RR) from_Decode;

  // send information about the current instruction to the WriteBack stage
  interface Get#(RR_to_WB) to_WB;

  // send instructions to the Control pipeline (Branch, Jumps...)
  interface Get#(RR_to_Pipeline) to_Ex_Control;

  // send instructions to the execute pipeline (ALU, FPU...)
  interface Get#(RR_to_Pipeline) to_Ex_Pipes;

  // send instruction to the Data Memory pipeline
  interface Get#(RR_to_Pipeline) to_DMEM;

  // update a register from the WriteBack stage
  // It's not necessary to send a message if rd = 0 (e.g. the instruction
  // is an exception)
  interface Put#(WB_to_RR) from_WriteBack;

  method Action start(File flog);
endinterface


function Exec_Tag tagOfInstr(Instr instr);
  case (instr) matches
    tagged Btype .* : return EXEC_TAG_CONTROL;
    tagged Rtype .* : return EXEC_TAG_EXEC;
    tagged Utype {op: AUIPC} : return EXEC_TAG_EXEC;
    tagged Utype {op: LUI} : return EXEC_TAG_EXEC;
    tagged Jtype .* : return EXEC_TAG_CONTROL;
    tagged Stype .* : return EXEC_TAG_DMEM;
    tagged Itype {op: .op} :
      return case (op) matches
        tagged Load .* : EXEC_TAG_DMEM;
        JALR : EXEC_TAG_CONTROL;
        ADDI : EXEC_TAG_EXEC;
        SLTI : EXEC_TAG_EXEC;
        SLTIU : EXEC_TAG_EXEC;
        XORI : EXEC_TAG_EXEC;
        ORI : EXEC_TAG_EXEC;
        ANDI : EXEC_TAG_EXEC;
        SLLI : EXEC_TAG_EXEC;
        SRLI : EXEC_TAG_EXEC;
        SRAI : EXEC_TAG_EXEC;
        FENCE : EXEC_TAG_DMEM;
        FENCE_I : EXEC_TAG_DMEM;
        default : EXEC_TAG_DIRECT;
      endcase;
  endcase
endfunction

(* synthesize *)
module mkRegisterRead(RegisterRead_IFC);
  FIFOF#(WB_to_RR)       wb_to_rr      <- mkPipelineFIFOF;
  FIFOF#(Decode_to_RR)   decode_to_rr  <- mkPipelineFIFOF;
  FIFOF#(RR_to_Pipeline) rr_to_dmem    <- mkBypassFIFOF;
  FIFOF#(RR_to_WB)       rr_to_wb      <- mkSizedBypassFIFOF(4);
  FIFOF#(RR_to_Pipeline) rr_to_control <- mkBypassFIFOF;
  FIFOF#(RR_to_Pipeline) rr_to_pipes   <- mkBypassFIFOF;

  Vector#(32, Reg#(Bit#(32))) registers <- replicateM(mkReg(0));
  Vector#(32, Reg#(Bool)) scoreboard <- replicateM(mkReg(False));

  Log_IFC log <- mkLog;

  rule dispatch;
    let request = decode_to_rr.first;

    let rs1 = register1(request.instr).name;
    let rs2 = register2(request.instr).name;
    let rd = (request.exception ? 0 : destination(request.instr).name);

    Bool busy_rs1 = scoreboard[rs1];
    Bool busy_rs2 = scoreboard[rs2];
    let busy = busy_rs1 || busy_rs2 || scoreboard[rd];

    if (request.exception || !busy) begin
      decode_to_rr.deq;
      if (rd != 0) scoreboard[rd] <= True;

      log.log("RR", request.inum, request.pc, displayInstr(request.instr));

      //$display(displayInstr(request.instr));

      // Direct tag correspond to a CSR operation or an exception
      Exec_Tag tag = (request.exception ? EXEC_TAG_DIRECT : tagOfInstr(request.instr));

      // send the request to the wb stage
      rr_to_wb.enq(RR_to_WB{
        exec_tag: tag,
        exception: request.exception,
        cause: request.cause,
        tval: request.tval,
        epoch: request.epoch,
        pc: request.pc,
        instr: request.instr,
        predicted_pc: request.predicted_pc,
        rs1_val: registers[rs1],
        rs2_val: registers[rs2],
        inum: request.inum
      });

      let msg = RR_to_Pipeline{
        epoch: request.epoch,
        pc: request.pc,
        instr: request.instr,
        rs1_val: registers[rs1],
        rs2_val: registers[rs2]
      };


      // send the request to the pipeline
      case (tag) matches
        EXEC_TAG_DMEM : rr_to_dmem.enq(msg);
        EXEC_TAG_EXEC : rr_to_pipes.enq(msg);
        EXEC_TAG_CONTROL : rr_to_control.enq(msg);
        default: noAction;
      endcase
    end
  endrule

  rule from_wb;
    let request = wb_to_rr.first;
    let rd = request.rd.name;
    wb_to_rr.deq;

    if (rd != 0) begin
      scoreboard[rd] <= False;

      if (request.commit)
        registers[rd] <= request.val;
    end
  endrule


  interface from_Decode = toPut(decode_to_rr);
  interface to_DMEM = toGet(rr_to_dmem);
  interface to_WB = toGet(rr_to_wb);
  interface to_Ex_Control = toGet(rr_to_control);
  interface to_Ex_Pipes = toGet(rr_to_pipes);
  interface from_WriteBack = toPut(wb_to_rr);

  method start = log.start;
endmodule

endpackage
