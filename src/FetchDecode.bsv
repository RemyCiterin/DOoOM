import Array :: *;
import AXI4_Lite_Adapter :: *;
import AXI4_Lite :: *;

import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: *;

import Decode :: *;
import Utils :: *;
import CSR :: *;
import BTB :: *;
import Types :: *;
import Fifo :: *;

typedef struct {
  Bit#(32) pc;
  Bit#(32) pred_pc;
  Epoch epoch;
  BranchPredState bpred_state;
} FetchToDecode deriving(Bits, FShow, Eq);


typedef struct {
  Bool exception;
  CauseException cause;
  Bit#(32) tval;
  Epoch epoch;
  Bit#(32) pc;
  Instr instr;
  Bit#(32) pred_pc;
  BranchPredState bpred_state;
} FromDecode deriving(Bits, FShow, Eq);

function FromDecode decodeFn(FetchToDecode req, AXI4_Lite_RResponse#(4) resp);
  if (resp.resp == OKAY) begin
    return case (decodeInstr(resp.bytes)) matches
      tagged Valid .instr :
        FromDecode{
          exception: False,
          cause: ?,
          tval: ?,
          epoch: req.epoch,
          pc: req.pc,
          instr: instr,
          pred_pc: req.pred_pc,
          bpred_state: req.bpred_state
        };
      Invalid :
        FromDecode{
          exception: True,
          cause: ILLEGAL_INSTRUCTION,
          tval: req.pc,
          epoch: req.epoch,
          pc: req.pc,
          instr: ?,
          pred_pc: ?,
          bpred_state: req.bpred_state
        };
    endcase;
  end else begin
    return FromDecode{
      exception: True,
      cause: INSTRUCTION_ACCESS_FAULT,
      tval: req.pc,
      epoch: req.epoch,
      pc: req.pc,
      instr: ?,
      pred_pc: ?,
      bpred_state: req.bpred_state
    };
  end
endfunction

interface FetchDecode;
  interface Get#(AXI4_Lite_RRequest#(32)) rrequest;

  method Action redirect(Bit#(32) next_pc, Epoch next_epoch);

  method Action trainHit(BranchPredTrain infos);
  method Action trainMis(BranchPredTrain infos);

  interface Put#(AXI4_Lite_RResponse#(4)) rresponse;

  interface Get#(FromDecode) to_RR;
endinterface

(* synthesize *)
module mkFetchDecode(FetchDecode);
  Fifo#(1, AXI4_Lite_RRequest#(32)) read_request <- mkBypassFifo;

  Reg#(Epoch) epoch <- mkReg(0);
  Reg#(Bit#(32)) current_pc <- mkReg(32'h80000000);

  let branchPred <- mkBranchPred;

  Fifo#(3, AXI4_Lite_RResponse#(4)) read_response <- mkPipelineFifo;
  Fifo#(2, FetchToDecode) fetch_to_decode <- mkPipelineFifo;
  Fifo#(1, FromDecode) outputs <- mkBypassFifo;

  rule fetch_step;
    let pc = current_pc;

    let pred <- branchPred.doPred(pc);
    current_pc <= pred.pc;

    read_request.enq(AXI4_Lite_RRequest{
      addr: pc
    });

    fetch_to_decode.enq(FetchToDecode{
      pc: pc, pred_pc: pred.pc, epoch: epoch, bpred_state: pred.state
    });
  endrule

  rule decode_step;
    let resp = read_response.first;
    let req = fetch_to_decode.first;
    fetch_to_decode.deq;
    read_response.deq;

    outputs.enq(decodeFn(req, resp));
  endrule

  method Action redirect(Bit#(32) next_pc, Epoch next_epoch);
    action
      current_pc <= next_pc;
      epoch <= next_epoch;
    endaction
  endmethod

  interface rrequest = toGet(read_request);

  method trainMis = branchPred.trainMis;
  method trainHit = branchPred.trainHit;

  interface to_RR = toGet(outputs);
  interface rresponse = toPut(read_response);
endmodule