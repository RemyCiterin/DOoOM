// Floating point basic functions

import FloatingPoint :: *;
import ClientServer :: *;
import SquareRoot :: *;
import GetPut :: *;
import Decode :: *;
import Divide :: *;
import Fifo :: *;
import Ehr :: *;

typedef FloatingPoint#(8, 23) FSingle;

typedef union tagged {
  FloatOp Rop;
  R4Op Fma;
} FpuOp deriving(Bits, Eq, FShow);

// Out-of-order Fpu request
typedef struct {
  reqId id;
  FpuOp op;
  FSingle rs1;
  FSingle rs2;
  FSingle rs3;
  Bit#(3) frm;
} FpuRequest#(type reqId) deriving(Bits, FShow, Eq);

// Out-of-order Fpu response
typedef struct {
  reqId id;
  FSingle result;
  Bit#(5) fflags;
} FpuResponse#(type reqId) deriving(Bits, FShow, Eq);

Bit#(32) canonicalNan = 32'h7fc00000;

function RoundMode getRoundMode(Bit#(3) frm);
  return case (frm)
    0 : Rnd_Nearest_Even;
    1 : Rnd_Zero;
    2 : Rnd_Minus_Inf;
    3 : Rnd_Plus_Inf;
    4 : Rnd_Nearest_Away_Zero;
    default : Rnd_Nearest_Even;
  endcase;
endfunction

function Bit#(5) getFlags(FloatingPoint::Exception exn);
  Bit#(1) nv  = exn.invalid_op ? 1 : 0 ;
  Bit#(1) dz  = exn.divide_0   ? 1 : 0 ;
  Bit#(1) of  = exn.overflow   ? 1 : 0 ;
  Bit#(1) uf  = exn.underflow  ? 1 : 0 ;
  Bit#(1) nx  = exn.inexact    ? 1 : 0 ;
  return pack ({nv, dz, of, uf, nx});
endfunction

interface FPointPipeline#(type reqId);
  interface FifoI#(FpuRequest#(reqId)) request;
  interface FifoO#(FpuResponse#(reqId)) response;
endinterface

module mkFPointPipeline
  (FPointPipeline#(reqId)) provisos(Bits#(reqId,reqIdW), Eq#(reqId));

  Fifo#(1, FpuRequest#(reqId)) inputQ <- mkPipelineFifo;
  Fifo#(1, FpuResponse#(reqId)) outputQ <- mkBypassFifo;

  Server#(Tuple2#(UInt#(56), UInt#(28)), Tuple2#(UInt#(28), UInt#(28)))
    divider <- mkDivider(1);
  Server#(Tuple3#(FSingle, FSingle, RoundMode), Tuple2#(FSingle, Exception))
    fp_divider <- mkFloatingPointDivider(divider);
  Fifo#(1, reqId) id_divider <- mkPipelineFifo;

  Server#(UInt#(60), Tuple2#(UInt#(60), Bool))
    sqrt <- mkNonPipelinedSquareRooter(2);
  Server#(Tuple2#(FSingle, RoundMode), Tuple2#(FSingle, Exception))
    fp_sqrt <- mkFloatingPointSquareRooter(sqrt);
  Fifo#(1, reqId) id_sqrt <- mkPipelineFifo;

  Server#(Tuple4#(Maybe#(FSingle), FSingle, FSingle, RoundMode), Tuple2#(FSingle, Exception))
    fp_fma <- mkFloatingPointFusedMultiplyAccumulate;
  Fifo#(1, Bool) negate_fma <- mkPipelineFifo;
  Fifo#(1, reqId) id_fma <- mkPipelineFifo;

  // FloatOp:
  //  FMIN_S, // rd = min(rs1, rs2)
  //  FMAX_S, // rd = max(rs1, rs2)

  //  FEQ_S, // rd = rs1 == rs2 ? 1 : 0
  //  FLT_S, // rd = rs1 < rs2 ? 1 : 0
  //  FLE_S, // rd = rs1 <= rs2 ? 1 : 0

  //  FCLASS_S,

  //  FCVT_W_S,  // rd = (int32_t) rs1
  //  FCVT_WU_S, // rd = (uint32_t) rs1
  //  FCVT_S_W,  // rd = (float) rs1
  //  FCVT_S_WU, // rd = (float) rs1

  rule startFMA if (inputQ.first.op matches tagged Fma .op);
    let req = inputQ.first;

    let n = case (op) matches
      FNMADD_S: True;
      FNMSUB_S: True;
      default: False;
    endcase;

    let rs3 = case (op) matches
      FNMSUB_S: negate(req.rs3);
      FMSUB_S: negate(req.rs3);
      default: req.rs3;
    endcase;

    inputQ.deq();
    negate_fma.enq(n);
    id_fma.enq(req.id);
    fp_fma.request.put(tuple4(
        Valid(rs3), req.rs1, req.rs2,
        getRoundMode(req.frm))
    );
  endrule

  rule startADD if (inputQ.first.op matches tagged Rop FADD_S);
    let req <- toGet(inputQ).get();
    fp_fma.request.put(tuple4(
        Valid(req.rs1), req.rs2, one(False),
        getRoundMode(req.frm)
    ));
    negate_fma.enq(False);
    id_fma.enq(req.id);
  endrule

  rule startSUB if (inputQ.first.op matches tagged Rop FSUB_S);
    let req <- toGet(inputQ).get();
    fp_fma.request.put(tuple4(
        Valid(req.rs1), negate(req.rs2), one(False),
        getRoundMode(req.frm)
    ));
    negate_fma.enq(False);
    id_fma.enq(req.id);
  endrule

  rule startMUL if (inputQ.first.op matches tagged Rop FMUL_S);
    let req <- toGet(inputQ).get();
    fp_fma.request.put(tuple4(
        Invalid, req.rs1, req.rs2,
        getRoundMode(req.frm)
    ));
    negate_fma.enq(False);
    id_fma.enq(req.id);
  endrule

  rule endFMA;
    match {.res, .exn} <- fp_fma.response.get();
    let n = negate_fma.first;
    let id = id_fma.first;
    negate_fma.deq();
    id_fma.deq();

    outputQ.enq(FpuResponse{
      result: n ? negate(res) : res,
      fflags: getFlags(exn),
      id: id
    });
  endrule

  rule startSQRT if (inputQ.first.op matches tagged Rop FSQRT_S);
    let req <- toGet(inputQ).get();
    fp_sqrt.request.put(tuple2(req.rs1, getRoundMode(req.frm)));
    id_sqrt.enq(req.id);
  endrule

  rule endSQRT;
    match {.res, .exn} <- fp_sqrt.response.get();
    let id <- toGet(id_sqrt).get();
    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: res,
      id: id
    });
  endrule

  rule startDIV if (inputQ.first.op matches tagged Rop FDIV_S);
    let req <- toGet(inputQ).get();
    fp_divider.request.put(tuple3(req.rs1, req.rs2, getRoundMode(req.frm)));
    id_divider.enq(req.id);
  endrule

  rule endDIV;
    match {.res, .exn} <- fp_divider.response.get();
    let id <- toGet(id_divider).get();
    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: res,
      id: id
    });
  endrule

  rule doFSGNJ_S if (inputQ.first.op matches tagged Rop FSGNJ_S);
    let req <- toGet(inputQ).get();

    outputQ.enq(FpuResponse{
      result: FSingle{sign: req.rs2.sign, exp: req.rs1.exp, sfd: req.rs1.sfd},
      id: req.id,
      fflags: 0
    });
  endrule

  rule doFSGNJN_S if (inputQ.first.op matches tagged Rop FSGNJN_S);
    let req <- toGet(inputQ).get();

    outputQ.enq(FpuResponse{
      result: FSingle{sign: !req.rs2.sign, exp: req.rs1.exp, sfd: req.rs1.sfd},
      id: req.id,
      fflags: 0
    });
  endrule

  rule doFSGNJX_S if (inputQ.first.op matches tagged Rop FSGNJX_S);
    let req <- toGet(inputQ).get();

    let sign = req.rs1.sign != req.rs2.sign;
    outputQ.enq(FpuResponse{
      result: FSingle{sign: sign, exp: req.rs1.exp, sfd: req.rs1.sfd},
      id: req.id,
      fflags: 0
    });
  endrule

  rule doFMV_X_W if (inputQ.first.op matches tagged Rop FMV_X_W);
    let req <- toGet(inputQ).get();

    outputQ.enq(FpuResponse{
      result: req.rs1,
      id: req.id,
      fflags: 0
    });
  endrule

  rule doFMV_W_X if (inputQ.first.op matches tagged Rop FMV_W_X);
    let req <- toGet(inputQ).get();

    outputQ.enq(FpuResponse{
      result: req.rs1,
      id: req.id,
      fflags: 0
    });
  endrule

  rule doFMIN_S if (inputQ.first.op matches tagged Rop FMIN_S);
    let req <- toGet(inputQ).get();

    outputQ.enq(FpuResponse{
      result: req.rs1,
      id: req.id,
      fflags: 0
    });
  endrule

  interface request = toFifoI(inputQ);
  interface response = toFifoO(outputQ);
endmodule
