// Floating point basic functions

import FloatingPoint :: *;
import ClientServer :: *;
import SquareRoot :: *;
import GetPut :: *;
import Decode :: *;
import Divide :: *;
import Fifo :: *;
import Ehr :: *;

typedef FloatingPoint#(8, 23) F32;

typedef union tagged {
  FloatOp Rop;
  R4Op Fma;
} FpuOp deriving(Bits, Eq, FShow);

// Out-of-order Fpu request
typedef struct {
  reqId id;
  FpuOp op;
  F32 rs1;
  F32 rs2;
  F32 rs3;
  Bit#(3) frm;
} FpuRequest#(type reqId) deriving(Bits, FShow, Eq);

// Out-of-order Fpu response
typedef struct {
  reqId id;
  F32 result;
  Bit#(5) fflags;
} FpuResponse#(type reqId) deriving(Bits, FShow, Eq);

Bit#(32) canonicalNaN = 32'h7fc00000;

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
  Server#(Tuple3#(F32, F32, RoundMode), Tuple2#(F32, Exception))
    fp_divider <- mkFloatingPointDivider(divider);
  Fifo#(1, reqId) id_divider <- mkPipelineFifo;

  Server#(UInt#(60), Tuple2#(UInt#(60), Bool))
    sqrt <- mkNonPipelinedSquareRooter(2);
  Server#(Tuple2#(F32, RoundMode), Tuple2#(F32, Exception))
    fp_sqrt <- mkFloatingPointSquareRooter(sqrt);
  Fifo#(1, reqId) id_sqrt <- mkPipelineFifo;

  Server#(Tuple4#(Maybe#(F32), F32, F32, RoundMode), Tuple2#(F32, Exception))
    fp_fma <- mkFloatingPointFusedMultiplyAccumulate;
  Fifo#(1, Bool) negate_fma <- mkPipelineFifo;
  Fifo#(1, reqId) id_fma <- mkPipelineFifo;

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
      result: F32{sign: req.rs2.sign, exp: req.rs1.exp, sfd: req.rs1.sfd},
      id: req.id,
      fflags: 0
    });
  endrule

  rule doFSGNJN_S if (inputQ.first.op matches tagged Rop FSGNJN_S);
    let req <- toGet(inputQ).get();

    outputQ.enq(FpuResponse{
      result: F32{sign: !req.rs2.sign, exp: req.rs1.exp, sfd: req.rs1.sfd},
      id: req.id,
      fflags: 0
    });
  endrule

  rule doFSGNJX_S if (inputQ.first.op matches tagged Rop FSGNJX_S);
    let req <- toGet(inputQ).get();

    let sign = req.rs1.sign != req.rs2.sign;
    outputQ.enq(FpuResponse{
      result: F32{sign: sign, exp: req.rs1.exp, sfd: req.rs1.sfd},
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

  rule doFCLASS_S if (inputQ.first.op matches tagged Rop FCLASS_S);
    let req <- toGet(inputQ).get();
    F32 rs1 = req.rs1;
    Bit#(32) res = 1;

    if (isNaN(rs1)) res = isQNaN(rs1) ? res << 9 : res << 8;
    else if (isInfinity(rs1)) res = rs1.sign ? res : res << 7;
    else if (isZero(rs1)) res = rs1.sign ? res << 3 : res << 4;
    else if (isSubNormal(rs1)) res = rs1.sign ? res << 2 : res << 5;
    else res = rs1.sign ? res << 1 : res << 6;

    outputQ.enq(FpuResponse{
      result: unpack(res),
      id: req.id,
      fflags: 0
    });
  endrule

  rule doFMIN_S if (inputQ.first.op matches tagged Rop FMIN_S);
    let req <- toGet(inputQ).get();
    F32 rs1 = req.rs1;
    F32 rs2 = req.rs2;

    F32 res = compareFP(rs1,rs2) == LT ? rs1 : rs2;

    if (isSNaN(rs1) && isSNaN(rs2)) res = unpack(canonicalNaN);
    else if (isSNaN(rs1)) res = rs2;
    else if (isSNaN(rs2)) res = rs1;

    else if (isQNaN(rs1) && isQNaN(rs2)) res = unpack(canonicalNaN);
    else if (isQNaN(rs1)) res = rs2;
    else if (isQNaN(rs2)) res = rs1;

    else if (isZero(rs1) && !rs1.sign && isZero(rs2) && rs2.sign) res = rs2;
    else if (isZero(rs1) && rs1.sign && isZero(rs2) && !rs2.sign) res = rs1;

    Exception exn = defaultValue;
    if (isSNaN(rs1) || isSNaN(rs2)) exn.invalid_op = True;

    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: res,
      id: req.id
    });
  endrule

  rule doFMAX_S if (inputQ.first.op matches tagged Rop FMIN_S);
    let req <- toGet(inputQ).get();
    F32 rs1 = req.rs1;
    F32 rs2 = req.rs2;

    F32 res = compareFP(rs1,rs2) == LT ? rs2 : rs1;

    if (isSNaN(rs1) && isSNaN(rs2)) res = unpack(canonicalNaN);
    else if (isSNaN(rs1)) res = rs2;
    else if (isSNaN(rs2)) res = rs1;

    else if (isQNaN(rs1) && isQNaN(rs2)) res = unpack(canonicalNaN);
    else if (isQNaN(rs1)) res = rs2;
    else if (isQNaN(rs2)) res = rs1;

    else if (isZero(rs1) && !rs1.sign && isZero(rs2) && rs2.sign) res = rs1;
    else if (isZero(rs1) && rs1.sign && isZero(rs2) && !rs2.sign) res = rs2;

    Exception exn = defaultValue;
    if (isSNaN(rs1) || isSNaN(rs2)) exn.invalid_op = True;

    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: res,
      id: req.id
    });
  endrule

  rule doFEQ_S if (inputQ.first.op matches tagged Rop FEQ_S);
    let req <- toGet(inputQ).get();
    F32 rs1 = req.rs1;
    F32 rs2 = req.rs2;

    Bit#(32) res = compareFP(rs1, rs2) == EQ ? 1 : 0;

    if (isSNaN(rs1) || isSNaN(rs2)) res = 0;
    else if (isQNaN(rs1) || isQNaN(rs2)) res = 0;

    Exception exn = defaultValue;
    if (isSNaN(rs1) || isSNaN(rs2)) exn.invalid_op = True;

    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: unpack(res),
      id: req.id
    });
  endrule

  rule doFLT_S if (inputQ.first.op matches tagged Rop FLT_S);
    let req <- toGet(inputQ).get();
    F32 rs1 = req.rs1;
    F32 rs2 = req.rs2;

    Bit#(32) res = compareFP(rs1, rs2) == LT ? 1 : 0;

    if (isSNaN(rs1) || isSNaN(rs2)) res = 0;
    else if (isQNaN(rs1) || isQNaN(rs2)) res = 0;

    Exception exn = defaultValue;
    if (isSNaN(rs1) || isSNaN(rs2)) exn.invalid_op = True;

    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: unpack(res),
      id: req.id
    });
  endrule

  rule doFLE_S if (inputQ.first.op matches tagged Rop FLE_S);
    let req <- toGet(inputQ).get();
    F32 rs1 = req.rs1;
    F32 rs2 = req.rs2;

    Bit#(32) res =
      compareFP(rs1, rs2) == LT ? 1 :
      compareFP(rs1, rs2) == EQ ? 1 : 0;

    if (isSNaN(rs1) || isSNaN(rs2)) res = 0;
    else if (isQNaN(rs1) || isQNaN(rs2)) res = 0;

    Exception exn = defaultValue;
    if (isSNaN(rs1) || isSNaN(rs2)) exn.invalid_op = True;

    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: unpack(res),
      id: req.id
    });
  endrule

  rule doFCVT_S_W if (inputQ.first.op matches tagged Rop FCVT_S_W);
    let req <- toGet(inputQ).get();
    Int#(32) rs1 = unpack(pack(req.rs1));
    match {.res, .exn} =
      Tuple2#(F32, Exception)'(vFixedToFloat(rs1, 6'd0, getRoundMode(req.frm)));

    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: res,
      id: req.id
    });
  endrule

  rule doFCVT_S_WU if (inputQ.first.op matches tagged Rop FCVT_S_WU);
    let req <- toGet(inputQ).get();
    UInt#(32) rs1 = unpack(pack(req.rs1));
    match {.res, .exn} =
      Tuple2#(F32, Exception)'(vFixedToFloat(rs1, 6'd0, getRoundMode(req.frm)));

    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: res,
      id: req.id
    });
  endrule

  rule doFCVT_W_S if (inputQ.first.op matches tagged Rop FCVT_W_S);
    let req <- toGet(inputQ).get();
    match {.res, .exn} =
      Tuple2#(Int#(32), Exception)'(vFloatToFixed(6'd0, req.rs1, getRoundMode(req.frm)));

    outputQ.enq(FpuResponse{
      fflags: getFlags(exn),
      result: unpack(pack(res)),
      id: req.id
    });
  endrule

  rule doFCVT_WU_S if (inputQ.first.op matches tagged Rop FCVT_WU_S);
    let req <- toGet(inputQ).get();
    F32 arg = F32{sfd: req.rs1.sfd, exp: req.rs1.exp, sign: False};

    match {.res, .exn} =
      Tuple2#(UInt#(32), Exception)'(vFloatToFixed(6'd0, arg, getRoundMode(req.frm)));

    if (req.rs1.sign) begin
      if (pack(exn) != 0) exn.invalid_op = True;
      res = 0;
    end else if (isInfinity(req.rs1))
      res = 32'hffffffff;
    else if (isNaN(req.rs1))
      res = 32'hffffffff;

    outputQ.enq(FpuResponse{
      result: unpack(pack(res)),
      fflags: getFlags(exn),
      id: req.id
    });
  endrule

  interface request = toFifoI(inputQ);
  interface response = toFifoO(outputQ);
endmodule
