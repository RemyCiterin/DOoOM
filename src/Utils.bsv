package Utils;

import FIFOF :: *;
import SpecialFIFOs :: *;
import Connectable :: *;
import GetPut :: *;
import Vector :: *;
import Assert :: *;
import Ehr :: *;
import Fifo :: *;


import Decode :: *;

// return if a memory access is a MMIO access, by convention the memory from the
// address 0x8000_0000 is cachable but the rest of memory is not (so is MMIO)
function Bool isMMIO(Bit#(32) addr);
  return addr < 32'h80000000;
endfunction

typedef enum {
  U = 2'b00,
  S = 2'b01,
  H = 2'b10,
  M = 2'b11
} Priv deriving(Bits, FShow, Eq);

typedef enum {
  DIRECT,
  CONTROL,
  EXEC,
  DMEM,
  FLOAT
} ExecTag deriving(Bits, FShow, Eq);

function ExecTag tagOfInstr(Instr instr);
  case (instr) matches
    tagged Btype .* : return CONTROL;
    tagged R4type .* : return FLOAT;
    tagged Rtype {op: tagged FloatOp .*} : return FLOAT;
    tagged Rtype .* : return EXEC;
    tagged Utype {op: AUIPC} : return EXEC;
    tagged Utype {op: LUI} : return EXEC;
    tagged Jtype .* : return CONTROL;
    tagged Stype .* : return DMEM;
    tagged Itype {op: .op} :
      return case (op) matches
        tagged Load .* : DMEM;
        JALR : CONTROL;
        ADDI : EXEC;
        SLTI : EXEC;
        SLTIU : EXEC;
        XORI : EXEC;
        ORI : EXEC;
        ANDI : EXEC;
        SLLI : EXEC;
        SRLI : EXEC;
        SRAI : EXEC;
        FENCE : DIRECT;
        FENCE_I : DIRECT;
        default : DIRECT;
      endcase;
  endcase
endfunction

instance Ord#(Priv);
  function Bool \<= (Priv p1, Priv p2);
    return pack(p1) <= pack(p2);
  endfunction
endinstance

// "uniq" tag of an instruction for debugging
typedef Bit#(32) INum;

// Epoch must be at least the size of the reorder buffer
// of the pipeline
typedef Bit#(8) Epoch;

// type of age used to track dependencies in the store queue
// Age must be at least two times bigger than
// the maximum number of element in the pipeline
// or the reorder buffer
typedef Bit#(8) Age;

function Bool isBefore(Age a, Age b);
  Integer msb = valueOf(SizeOf#(Age)) - 1;
  return (b-a)[msb] == 0;
endfunction

function Bool isAfter(Epoch a, Epoch b);
  return !isBefore(a, b);
endfunction

function Maybe#(Bit#(TLog#(n))) findYoungest(Vector#(n, Age) ages, Bit#(n) mask);
  Bit#(TLog#(n)) idx = ?;
  Bool empty = True;
  Age age = ?;

  for (Integer i=0; i < valueOf(n); i = i + 1) begin
    if (mask[i] == 1 && (empty || isBefore(age, ages[i]))) begin
      idx = fromInteger(i);
      age = ages[i];
      empty = False;
    end
  end

  return empty ? Invalid : Valid(idx);
endfunction

function Maybe#(Bit#(TLog#(n))) findOldest(Vector#(n, Age) ages, Bit#(n) mask);
  Bit#(TLog#(n)) idx = ?;
  Bool empty = True;
  Age age = ?;

  for (Integer i=0; i < valueOf(n); i = i + 1) begin
    if (mask[i] == 1 && (empty || isBefore(ages[i], age))) begin
      idx = fromInteger(i);
      age = ages[i];
      empty = False;
    end
  end

  return empty ? Invalid : Valid(idx);
endfunction

interface EpochManager;
  method Epoch read;
  method Action update;
endinterface

module mkEpochManager(EpochManager);
  Reg#(Epoch) epoch <- mkReg(0);

  method Epoch read;
    return epoch;
  endmethod

  method Action update;
    action
      epoch <= epoch + 1;
    endaction
  endmethod
endmodule

typedef Bit#(TMul#(8, n)) Byte#(numeric type n);
typedef Bit#(TMul#(16, n)) Half#(numeric type n);
typedef Bit#(TMul#(32, n)) Word#(numeric type n);

typedef union tagged {
  Integer Normal;
  Integer Bypass;
  void Pipeline;
} FIFOF_Config;

module mkEmptyFIFOF(FIFOF#(t)) provisos(Bits#(t, k));
  method clear = noAction;

  method Action enq(t val) if (False);
    noAction;
  endmethod

  method Bool notEmpty;
    return False;
  endmethod

  method Bool notFull;
    return False;
  endmethod

  method Action deq if(False);
    noAction;
  endmethod

  method t first if (False);
    return ?;
  endmethod
endmodule

// align an address using the AXI4 convention: mask the strb
function Tuple2#(Bit#(addrBits), Bit#(dataBytes)) alignAddr(Bit#(addrBits) addr, Bit#(dataBytes) strb);
  Bit#(TSub#(addrBits, TLog#(dataBytes))) addr_truncate =
    addr[valueOf(addrBits)-1: valueOf(TLog#(dataBytes))];

  Bit#(TLog#(dataBytes)) offset =
    addr[valueOf(TLog#(dataBytes)) - 1 : 0];

  for (Integer i=0; i < valueOf(dataBytes); i = i + 1) begin
    strb[i] = strb[i] & (fromInteger(i) >= offset ? 1'b1 : 1'b0);
  end

  return Tuple2{fst: {addr_truncate, 0}, snd: strb};
endfunction

module mkConfigFIFOF#(FIFOF_Config conf) (FIFOF#(t)) provisos(Bits#(t, k));

  FIFOF#(t) fifo = ?;

  case (conf) matches
    tagged Normal .n : fifo <- mkSizedFIFOF(n);
    tagged Bypass .n : fifo <- mkSizedBypassFIFOF(n);
    tagged Pipeline  : fifo <- mkPipelineFIFOF;
  endcase

  method enq = fifo.enq;
  method deq = fifo.deq;
  method clear = fifo.clear;
  method notEmpty = fifo.notEmpty;
  method notFull = fifo.notFull;
  method first = fifo.first;

endmodule

module mkSlowFIFOF#(Integer n) (FIFOF#(t)) provisos (Bits#(t, size_t));
  FIFOF#(t) fst <- mkBypassFIFOF;
  FIFOF#(t) last <- mkBypassFIFOF;

  mkConnection(toGet(fst), toPut(last));

  for (Integer i=0; i<n; i = i + 1) begin
    FIFOF#(t) foo <- mkPipelineFIFOF;
    mkConnection(toGet(foo), toPut(fst));
    fst = foo;
  end

  method enq = fst.enq;
  method notFull = fst.notFull;
  method deq = last.deq;
  method notEmpty = last.notEmpty;
  method first = last.first;
  method clear = noAction;
endmodule

function Byte#(n) strbToMask(Bit#(n) strb);
  Vector#(n, Bit#(8)) v = replicate(?);

  for (Integer i=0; i < valueOf(n); i = i + 1) begin
    v[i] = (strb[i] == 1'b1 ? 1 : 0);
  end

  return pack(v);
endfunction

function Byte#(n) filterStrb(Byte#(n) old_bytes, Byte#(n) new_bytes, Bit#(n) strb);
  Vector#(n, Bit#(8)) v = replicate(?);

  for (Integer i=0; i < valueOf(n); i = i + 1) begin
    Integer ub = (i+1) * 8 - 1;
    Integer lb = i * 8;

    Bit#(8) val = (strb[i] == 1'b1 ? new_bytes[ub:lb] : old_bytes[ub:lb]);
    v[i] = val;
  end

  return pack(v);
endfunction

interface Log_IFC;
  method Action start(File flog);
  method Action log(String tag, INum inum, Bit#(32) pc, Fmt instr);

  method Bit#(32) read;
endinterface

module mkLog (Log_IFC);
  Reg#(Bit#(32)) cycle <- mkReg(0);
  Reg#(Bool) is_start <- mkReg(False);

  Reg#(File) flog <- mkReg(InvalidFile);


  (* fire_when_enabled, no_implicit_conditions *)
  rule step if (is_start);
    cycle <= cycle + 1;
  endrule

  method Action start(File f);
    action
      flog <= f;
      is_start <= True;
    endaction
  endmethod

  method Action log(String tag, INum inum, Bit#(32) pc, Fmt instr);
    action
      if (flog != InvalidFile)
        $fdisplay(flog, "Trace %d %d %h %s ", cycle, inum, pc, tag, instr);
    endaction
  endmethod

  method read = cycle._read;
endmodule

function Reg#(Bit#(n)) readOnlyReg(Bit#(n) value);
  return (interface Reg;
    method Bit#(n) _read = value;
    method Action _write(Bit#(n) new_value) = noAction;
  endinterface);
endfunction

function Reg#(Bit#(n)) truncateReg(Reg#(Bit#(m)) r) provisos (Add#(k, n, m));
  return (interface Reg;
    method Bit#(n) _read;
      return truncate(r._read);
    endmethod

    method Action _write(Bit#(n) new_value);
      r <= {truncateLSB(r._read), new_value};
    endmethod
  endinterface);
endfunction

function Reg#(Bit#(n)) truncateRegLSB(Reg#(Bit#(m)) r) provisos (Add#(k, n, m));
  return (interface Reg;
    method Bit#(n) _read;
      return truncateLSB(r._read);
    endmethod

    method Action _write(Bit#(n) new_value);
      r <= {new_value, truncate(r._read)};
    endmethod
  endinterface);
endfunction

// we construct register concatenation by induction:
// we may type _concatReg(r1, r2) with
// - Reg#(Bit#(k + n))
// - Reg#(Bit#(k + n)) -> r
// depending of the context
typeclass ConcatReg#(type r, numeric type n, numeric type m)
  dependencies ((r, n) determines m, (r, m) determines n);
  function r _concatReg(Reg#(Bit#(n)) x, Reg#(Bit#(m)) y);
endtypeclass

instance ConcatReg#(Reg#(Bit#(m)), k, n) provisos (Add#(k, n, m));
  function Reg#(Bit#(m)) _concatReg(Reg#(Bit#(k)) r1, Reg#(Bit#(n)) r2);
    return (interface Reg;
      method Bit#(m) _read;
        return {r1._read, r2._read};
      endmethod

      method Action _write(Bit#(m) new_value);
        action
          r1 <= truncateLSB(new_value);
          r2 <= truncate(new_value);
        endaction
      endmethod
    endinterface);
  endfunction
endinstance

instance ConcatReg#(function r f(Reg#(Bit#(m)) z), k, n)
  provisos (ConcatReg#(r, TAdd#(k, n), m));

  function function r f(Reg#(Bit#(m)) z) _concatReg(Reg#(Bit#(k)) x, Reg#(Bit#(n)) y);
    return _concatReg(interface Reg;
      method Bit#(TAdd#(k, n)) _read = {x._read, y._read};
      method Action _write(Bit#(TAdd#(k, n)) z);
        x <= truncateLSB(z);
        y <= truncate(z);
      endmethod
    endinterface);
  endfunction
endinstance

function r concatReg(Reg#(Bit#(n)) x, Reg#(Bit#(m)) y) provisos (ConcatReg#(r, n, m));
  return _concatReg(x, y);
endfunction

module mkGetScheduler#(
    Vector#(size, Bool) canGet,
    Vector#(size, ActionValue#(t)) getCall
  ) (Get#(t)) provisos (Bits#(t, sizeT));

  Reg#(Bit#(TLog#(size))) index <- mkReg(0);

  function Bit#(TLog#(size)) nextFn(Bit#(TLog#(size)) idx);
    return (idx == fromInteger(valueOf(size)-1) ? 0 : idx + 1);
  endfunction

  function Bit#(TLog#(size)) getNewIndex;
    Bit#(TLog#(size)) result = ?;
    Bool found = False;

    Bit#(TLog#(size)) idx = nextFn(index);

    for (Integer i=0; i < valueOf(size); i = i + 1) begin
      if (canGet[idx] && !found) begin
        found = True;
        result = idx;
      end

      idx = nextFn(idx);
    end

    return result;
  endfunction

  method ActionValue#(t) get;
    let idx = getNewIndex;
    index <= idx;

    let ret <- getCall[idx];
    return ret;
  endmethod

endmodule

// if x = {x[size-1], ..., x[0]}
// return {x[size-1-a], ..., x[0], x[size-1], ..., x[(size-a) % size]}
function Bit#(size) rotateLeft(Bit#(size) x, Bit#(TLog#(size)) a);
  // x = {x[size-1], ..., x[0]}
  // x << a = {x[size-1-a], ..., x[0], 0, ..., 0}
  // x >> b = {0, ..., 0, x[size-1], ..., x[b]}
  // And we want 1+(size-1-a) to be equal to b, so b=size-a

  Bit#(TLog#(size)) b = fromInteger(valueOf(size) - 1) - a + 1;
  return (x << a) | (x >> b);
endfunction

function Bit#(size) rotateRight(Bit#(size) x, Bit#(TLog#(size)) a);
  // x = {x[size-1], ..., x[0]}
  // x >> a = {0, ..., 0, x[size-1], ..., x[a]}
  // x << b = {x[size-1-b], ..., x[0], 0, ..., 0}
  // And we want 1+(size-1-b) to be equal to a, so b = size-a

  Bit#(TLog#(size)) b = fromInteger(valueOf(size) - 1) - a + 1;
  return (x >> a) | (x << b);
endfunction

// return the index of the less significant one
function Bit#(TAdd#(TLog#(size), 1)) firstOne(Bit#(size) x);

  function Bit#(TAdd#(TLog#(size), 1)) aux(Integer k);
    if (k == valueOf(size))
      return fromInteger(valueOf(size));
    else
      return x[k] == 1 ? fromInteger(k) : aux(k+1);
  endfunction

  return aux(0);
endfunction

// return the index of the most significant one
function Bit#(TAdd#(TLog#(size), 1)) lastOne(Bit#(size) x);

  function Bit#(TAdd#(TLog#(size), 1)) aux(Integer k);
    if (k == valueOf(size))
      return fromInteger(valueOf(size));
    else
      return x[valueOf(size) - 1 - k] == 1 ?
        fromInteger(valueOf(size) - 1 - k) :
        aux(k+1);
  endfunction

  return aux(0);
endfunction

// Return the index of the first one in a bitmask starting by a given index
function Maybe#(Bit#(TLog#(size)))
  firstOneFrom(Bit#(size) x, Bit#(TLog#(size)) n);

  let y = rotateRight(x, n);
  let m = firstOne(y);

  if (m == fromInteger(valueOf(size)))
    return Invalid;
  else begin
    let k = {1'b0, n} + m;
    return Valid(
      k >= fromInteger(valueOf(size)) ?
        truncate(k - fromInteger(valueOf(size))) :
        truncate(k)
    );
  end
endfunction

// Return the index of the last one in a bitmask starting by a given index
function Maybe#(Bit#(TLog#(size)))
  lastOneFrom(Bit#(size) x, Bit#(TLog#(size)) n);

  let y = rotateRight(x, n);
  let m = lastOne(y);

  if (m == fromInteger(valueOf(size)))
    return Invalid;
  else begin
    let k = {1'b0, n} + m;
    return Valid(
      k >= fromInteger(valueOf(size)) ?
        truncate(k - fromInteger(valueOf(size))) :
        truncate(k)
    );
  end
endfunction

endpackage
