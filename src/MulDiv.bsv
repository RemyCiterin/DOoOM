import ClientServer :: *;
import GetPut :: *;
import Fifo :: *;

import Decode :: *;
import Utils :: *;
import Ehr :: *;

typedef struct {
  Bit#(32) x1;
  Bit#(32) x2;
  Bool x1Signed;
  Bool x2Signed;
  Bool high;
} MulRequest deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(32) x1;
  Bit#(32) x2;
  Bool isSigned;
  Bool rem;
} DivRequest deriving(Bits, FShow, Eq);

typedef Server#(MulRequest, Bit#(32)) MulServer;
typedef Server#(DivRequest, Bit#(32)) DivServer;

// Very slow but very small
module mkMulServer64(Server#(Tuple2#(Bit#(64),Bit#(64)), Bit#(64)));
  Reg#(Bit#(64)) status <- mkReg(0);
  Reg#(Bool) busy <- mkReg(False);
  Reg#(Bit#(64)) acc <- mkReg(0);
  Reg#(Bit#(64)) lhs <- mkReg(?);
  Reg#(Bit#(64)) rhs <- mkReg(?);

  rule step if (busy && status != 0);
    acc <= acc +
      (rhs[0] == 1 ? lhs : 0) +
      (rhs[1] == 1 ? lhs << 1 : 0) +
      (rhs[2] == 1 ? lhs << 2 : 0) +
      (rhs[3] == 1 ? lhs << 3 : 0);
    status <= status << 4;
    rhs <= rhs >> 4;
    lhs <= lhs << 4;
  endrule

  interface Put request;
    method Action put(Tuple2#(Bit#(64),Bit#(64)) req) if (!busy);
      action
        lhs <= req.fst;
        rhs <= req.snd;
        busy <= True;
        status <= 1;
        acc <= 0;
      endaction
    endmethod
  endinterface

  interface Get response;
    method ActionValue#(Bit#(64)) get if (busy && status == 0);
      busy <= False;
      return acc;
    endmethod
  endinterface
endmodule

module mkMulServer(MulServer);
  Bool fastMul = True;

  Fifo#(2, MulRequest) requests <- mkFifo;

  Fifo#(2, Bool) highQ <- mkFifo;
  Server#(Tuple2#(Bit#(64),Bit#(64)), Bit#(64)) server <- mkMulServer64;

  if (!fastMul) rule start_mul;
    let req = requests.first;
    requests.deq;

    Bit#(64) x1 = (req.x1Signed ? signExtend(req.x1) : zeroExtend(req.x1));
    Bit#(64) x2 = (req.x2Signed ? signExtend(req.x2) : zeroExtend(req.x2));
    highQ.enq(req.high);

    server.request.put(tuple2(x1,x2));
  endrule

  method request = toPut(requests);

  interface Get response;
    method ActionValue#(Bit#(32)) get;
      actionvalue
        if (fastMul) begin
          let req = requests.first;
          requests.deq;

          Bit#(64) x1 = (req.x1Signed ? signExtend(req.x1) : zeroExtend(req.x1));
          Bit#(64) x2 = (req.x2Signed ? signExtend(req.x2) : zeroExtend(req.x2));
          Bit#(64) ret = x1 * x2;

          return req.high ? ret[63:32] : ret[31:0];
        end else begin
          let high = highQ.first;
          highQ.deq;

          let ret <- server.response.get;
          return high ? ret[63:32] : ret[31:0];
        end
      endactionvalue
    endmethod
  endinterface
endmodule

// Represent an intermediate state
// of the division
typedef struct {
  Bit#(size) index;
  Bit#(size) rem;
  Bit#(size) div;
  Bit#(size) num;
  Bit#(size) den;
} DivideUState#(numeric type size) deriving(Bits, FShow, Eq);

function DivideUState#(size) divideInit(Bit#(size) num, Bit#(size) den);
  Bool found = False;
  Bit#(size) index = 0;
  for (Integer i=valueOf(size)-1; i >= 0; i = i - 1) if (!found && num[i] == 1) begin
    index[i] = 1;
    found = True;
  end

  return DivideUState{
    index: index,
    num: num,
    den: den,
    rem: 0,
    div: 0
  };
endfunction

// Let a = b * (2^-(n+1) * q) + 1
//   2 * a = b * (2^-n * q) + 2*r
//   2 * a + 1 = b * (2^-n * q) + 2*r+1
//
// Then we remove b to the reminder if 2*r+1 or 2*r is greater than b
function DivideUState#(size) divideStep(DivideUState#(size) state);
  state.rem = (state.num & state.index) != 0 ? (state.rem << 1) | 1 : state.rem << 1;

  if (state.rem >= state.den) begin
    state.rem = state.rem - state.den;
    state.div = state.div | state.index;
  end

  state.index = state.index >> 1;

  return state;
endfunction

typedef 34 DivideSize;

typedef union tagged {
  void Overflow;
  void Zero;
  void Idle;
  DivideUState#(DivideSize) Busy;
} DivideState deriving(Bits, FShow, Eq);

module mkDivServer(DivServer);
  Ehr#(2, DivideState) state <- mkEhr(Idle);
  Fifo#(2, DivRequest) requests <- mkFifo;

  // Let return Q, R such that
  // N = Q * D + R with sign(R) = sign(N) and 0 <= |R| < |D|

  // First if D < 0 and N > 0
  //   N = -Q * -D + R
  //   with -D > 0, R > 0 and N > 0
  // So we compute q, r = divMod(N, -D) and return (-q, r)

  // Second if D > 0 and N < 0
  //   -N = -Q * D - R
  //   with -N > 0, -R > 0 and D > 0
  // So we compute q, r = divMod(-N, D) and return (-q, -r)

  // Then if D < 0 and N < 0
  //   -N = Q * -D - R
  //   with -N > 0, -D > 0 and N < 0
  // So we compute q, r = divMod(-N, -D) and return (q, -r)

  function Bool getIsReady;
    return case (state[0]) matches
      Zero : True;
      Overflow : True;
      tagged Busy .st : st.index == 0;
      default: False;
    endcase;
  endfunction

  rule step if (state[0] matches tagged Busy .st &&& st.index != 0);
    state[0] <= tagged Busy divideStep(st);
  endrule

  interface Put request;
    method Action put(DivRequest req) if (state[1] matches Idle);

      Bit#(DivideSize) n = (req.isSigned ? signExtend(req.x1) : zeroExtend(req.x1));
      Bit#(DivideSize) d = (req.isSigned ? signExtend(req.x2) : zeroExtend(req.x2));
      Int#(DivideSize) n_int = unpack(n);
      Int#(DivideSize) d_int = unpack(d);

      n = req.isSigned && n_int < 0 ? -n : n;
      d = req.isSigned && d_int < 0 ? -d : d;

      if (req.x2 == 0)
        state[1] <= Zero;
      else if (req.x1 == -(1 << 31) && req.x2 == -1 && req.isSigned)
        state[1] <= Overflow;
      else
        state[1] <= Busy(divideInit(n, d));

      requests.enq(req);
    endmethod
  endinterface

  interface Get response;
    method ActionValue#(Bit#(32)) get if (getIsReady);
      actionvalue
        requests.deq;
        state[0] <= Idle;

        let req = requests.first;
        Bit#(DivideSize) n = (req.isSigned ? signExtend(req.x1) : zeroExtend(req.x1));
        Bit#(DivideSize) d = (req.isSigned ? signExtend(req.x2) : zeroExtend(req.x2));
        Int#(DivideSize) n_int = unpack(n);
        Int#(DivideSize) d_int = unpack(d);

        case (state[0]) matches
          tagged Busy .st : begin
            if (req.rem) begin
              if (req.isSigned && n_int < 0)
                return -truncate(st.rem);
              else
                return truncate(st.rem);
            end else begin
              if (req.isSigned && ((n_int < 0) != (d_int < 0)))
                return -truncate(st.div);
              else
                return truncate(st.div);
            end
          end
          Overflow : return req.rem ? 0 : req.x1;
          Zero : return req.rem ? 0 : -1;
          default: return ?;
        endcase
      endactionvalue
    endmethod
  endinterface
endmodule
