import Array :: *;
import AXI4_Lite_Adapter :: *;
import AXI4_Lite :: *;
import AXI4 :: *;

import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: *;

import BCache :: *;
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
  method Action redirect(Bit#(32) next_pc, Epoch next_epoch);

  method Action trainHit(BranchPredTrain infos);
  method Action trainMis(BranchPredTrain infos);

  interface RdAXI4_Master#(4, 32, 4) imem;

  interface Get#(FromDecode) to_RR;

  // Request an invalidation request from the CPU
  method Action invalidate(Bit#(32) addr);
  // Ready if all the invalidation request are acknoledge
  method Action invalidateEmpty();
endinterface

(* synthesize *)
module mkFetchDecode(FetchDecode);
  let cache <- mkDefaultBCache();

  Ehr#(2, Epoch) epoch <- mkEhr(0);
`ifdef BSIM
  Ehr#(2, Bit#(32)) current_pc <- mkEhr(32'h80010000);
`else
  Ehr#(2, Bit#(32)) current_pc <- mkEhr(32'h80000000);
`endif
  Reg#(INum) inum <- mkReg(0);

  let bpred <- mkBranchPred;

  Fifo#(1, void) invalidateQ <- mkPipelineFifo;

  Fifo#(2, AXI4_Lite_RResponse#(4)) rresponseQ <- mkBypassFifo;
  Fifo#(2, Maybe#(FetchToDecode)) fetch_to_decode <- mkFifo;
  Fifo#(2, FromDecode) outputs <- mkFifo;

  Reg#(Bit#(32)) misCount <- mkReg(0);
  Reg#(Bit#(32)) cycle <- mkReg(0);

  rule perf;
    cycle <= cycle + 1;

    if (cycle[18:0] == 0) begin
      $display("cycle: %d hit: %d mis: %d", cycle, inum - misCount, misCount);
    end
  endrule

  rule setId0;
    cache.setID(0);
  endrule

  rule invalidateAck;
    cache.invalidateAck();
    invalidateQ.deq();
  endrule

  rule enqRResponse;
    let resp <- cache.cpu_read.response.get();
    rresponseQ.enq(resp);
  endrule

  rule start;
    let pc = current_pc[1];
    bpred.start(pc, epoch[1]);
    cache.cpu_read.request.put(AXI4_Lite_RRequest{addr: pc});
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
    let resp = rresponseQ.first;
    fetch_to_decode.deq();
    rresponseQ.deq();

    outputs.enq(decodeFn(req, resp, inum));
    inum <= inum + 1;
  endrule

  rule decode_ignore_step if (fetch_to_decode.first == Invalid);
    fetch_to_decode.deq;
    rresponseQ.deq();
  endrule

  method Action redirect(Bit#(32) next_pc, Epoch next_epoch);
    action
      misCount <= misCount + 1;
      current_pc[0] <= next_pc;
      epoch[0] <= next_epoch;
    endaction
  endmethod

  method Action invalidate(Bit#(32) addr);
    cache.invalidate(addr);
    invalidateQ.enq(?);
  endmethod

  method invalidateEmpty = when(invalidateQ.canEnq, noAction);

  interface imem = cache.mem_read;

  method trainMis = bpred.trainMis;
  method trainHit = bpred.trainHit;

  interface to_RR = toGet(outputs);
endmodule
