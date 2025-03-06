import Array :: *;
import AXI4_Lite_Adapter :: *;
import AXI4_Lite :: *;

import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: *;

import Decode :: *;
import Utils :: *;
import CSR :: *;
import BranchPred :: *;
import Types :: *;
import Fifo :: *;
import Ehr :: *;

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
  INum inum;
} FromDecode deriving(Bits, FShow, Eq);

function FromDecode decodeFn(FetchToDecode req, AXI4_Lite_RResponse#(4) resp, INum inum);
  if (resp.resp == OKAY) begin
    return case (decodeInstr(resp.bytes)) matches
      tagged Valid .instr :
        FromDecode{
          exception: False,
          cause: ?,
          tval: ?,
          epoch: req.epoch,
          pc: req.pc,
          inum: inum,
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
          inum: inum,
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
      inum: inum,
      instr: ?,
      pred_pc: ?,
      bpred_state: req.bpred_state
    };
  end
endfunction

// {redirect, trainHit, trainMis} < to_RR
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

  Ehr#(2, Epoch) epoch <- mkEhr(0);
  Ehr#(2, Bit#(32)) current_pc <- mkEhr(32'h80000000);

  Reg#(INum) inum <- mkReg(0);

  let bpred <- mkBranchPred;

  Fifo#(4, AXI4_Lite_RResponse#(4)) read_response <- mkPipelineFifo;
  Fifo#(3, Maybe#(FetchToDecode)) fetch_to_decode <- mkPipelineFifo;
  Fifo#(1, FromDecode) outputs <- mkBypassFifo;

  Reg#(Bit#(32)) misCount <- mkReg(0);
  Reg#(Bit#(32)) cycle <- mkReg(0);

  rule perf;
    cycle <= cycle + 1;

    if (cycle[18:0] == 0) begin
      $display("cycle: %d hit: %d mis: %d", cycle, inum - misCount, misCount);
    end
  endrule

  rule start;
    let pc = current_pc[1];
    bpred.start(pc, epoch[1]);
    read_request.enq(AXI4_Lite_RRequest{addr: pc});
  endrule

  rule deq_bpred_result if (epoch[0] == bpred.predEpoch);
    let pred <- bpred.pred();

    current_pc[0] <= pred.pc;
    fetch_to_decode.enq(Valid(FetchToDecode{
      bpred_state: pred.state,
      epoch: bpred.predEpoch,
      pc: bpred.predPc,
      pred_pc: pred.pc
    }));

    bpred.deq();
  endrule

  rule ignore_bpred_result if (epoch[0] != bpred.predEpoch);
    fetch_to_decode.enq(Invalid);
    bpred.deq();
  endrule

  rule decode_step if (fetch_to_decode.first matches tagged Valid .req);
    let resp = read_response.first;
    fetch_to_decode.deq;
    read_response.deq;

    outputs.enq(decodeFn(req, resp, inum));
    inum <= inum + 1;
  endrule

  rule decode_ignore_step if (fetch_to_decode.first == Invalid);
    fetch_to_decode.deq;
    read_response.deq;
  endrule

  method Action redirect(Bit#(32) next_pc, Epoch next_epoch);
    action
      misCount <= misCount + 1;
      current_pc[0] <= next_pc;
      epoch[0] <= next_epoch;
    endaction
  endmethod

  interface rrequest = toGet(read_request);

  method trainMis = bpred.trainMis;
  method trainHit = bpred.trainHit;

  interface to_RR = toGet(outputs);
  interface rresponse = toPut(read_response);
endmodule
