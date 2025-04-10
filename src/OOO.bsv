import Utils :: *;
import Decode :: *;
import Vector :: *;
import Ehr :: *;
import CSR :: *;
import BranchPred :: *;

// The number of slots in the reorder buffer
typedef 16 RobSize;
typedef Bit#(TLog#(RobSize)) RobIndex;

typedef 4 IqSize;

// Store Buffer Size
typedef 2 StbSize;

// Store Queue Size
typedef 4 SqSize;

// Load Queue Size
typedef 4 LqSize;

typedef 128 NumPhysReg;

typedef Bit#(TLog#(NumPhysReg)) PhysReg;

// Store Buffer Index
typedef Bit#(TLog#(StbSize)) StbIndex;

// Store Queue Index
typedef Bit#(TLog#(SqSize)) SqIndex;

// Load Queue Index
typedef Bit#(TLog#(LqSize)) LqIndex;

// The execution of an instruction return either
// an exception with a cause and a mtval value,
// or the value to put in rd and the next pc
typedef union tagged {
  struct {
    CauseException cause;
    Bit#(32) tval;
  } Error;

  struct {
    // Force to flush the pipeline (e.g. FENCE.I)
    Bool flush;
    Bit#(32) rd_val;
    Bit#(32) next_pc;
    Maybe#(Bit#(5)) fflags;
  } Ok;
} ExecResult deriving(Bits, FShow, Eq);

function Bit#(32) getRdVal(ExecResult result);
  return case (result) matches
    tagged Ok {rd_val: .rd_val} : rd_val;
    .* : (?);
  endcase;
endfunction

function Bool isOk(ExecResult result);
  return case (result) matches
    tagged Ok .* : True;
    .* : False;
  endcase;
endfunction

typedef struct {
  ExecResult result;
  RobIndex index;
  PhysReg pdst;
} ExecOutput deriving(Bits, FShow, Eq);

//   During a store commit, the load store unit may return that
// all the instruction from a certain points are mispredicted,
// in particular a load may return a mispredicted value if the
// address dependency check fail
typedef union tagged {
  RobIndex Exception;
  void Success;
} CommitOutput deriving(Bits, FShow, Eq);

typedef struct {
  // the program pointer associated to the instruction
  Bit#(32) pc;

  // the decoded instruction
  Instr instr;

  // tag of the instruction (or Direct if their is a fetching of decoding error)
  // If the tag is TAG_DMEM then the reorder buffer mst wait the LSU to enter
  // into the commit stage
  ExecTag tag;

  // the value of the epoch register at the instruction fetching
  Epoch epoch;

  // age of the operation, mostly used by the LSU
  Age age;

  // PC predicted by the branch predictor
  Bit#(32) pred_pc;

  // all the informations used by the branch predictor to backtrack in case of misprediction
  BranchPredState bpred_state;

  // Physical destination register
  PhysReg pdst;
} RobEntry deriving(Bits, FShow, Eq);

typedef union tagged {
  Bit#(32) Value;
  PhysReg Wait;
} RegVal deriving(Bits, Eq);

instance FShow#(RegVal);
  function Fmt fshow(RegVal r);
    return case (r) matches
      tagged Value .v : $format("0x%h",v);
      tagged Wait .id : $format("p%h",id);
    endcase;
  endfunction
endinstance

function Bit#(32) getRegValue(RegVal r);
  return case (r) matches
    tagged Value .v : v;
    default: ?;
  endcase;
endfunction

function Bool isValue(RegVal r);
  return case (r) matches
    tagged Value .* : True;
    default: False;
  endcase;
endfunction

function Bool isWait(RegVal r);
  return case (r) matches
    tagged Wait .* : True;
    default: False;
  endcase;
endfunction

typedef struct {
  // Reorder buffer index
  RobIndex index;

  // Program counter
  Bit#(32) pc;

  // Decoded instruction
  Instr instr;

  // Polymorphic payload
  t regs;

  // Epoch counter
  Epoch epoch;

  // Age counter
  Age age;

  // Floating-point rounding-mode
  Bit#(3) frm;

  // Instruction type
  ExecTag tag;

  // Index in the load queue
  LqIndex lindex;

  // Index in the store queue
  SqIndex sindex;

  // Physical destination register
  PhysReg pdst;
} MicroOp#(type t) deriving(Bits, FShow, Eq);

function MicroOp#(b) mapMicroOp(function b f(a x), MicroOp#(a) op);
  return MicroOp{
    sindex: op.sindex,
    lindex: op.lindex,
    regs: f(op.regs),
    index: op.index,
    epoch: op.epoch,
    instr: op.instr,
    pdst: op.pdst,
    frm: op.frm,
    age: op.age,
    tag: op.tag,
    pc: op.pc
  };
endfunction

typedef MicroOp#(Vector#(n,t)) MicroOpN#(numeric type n, type t);

function MicroOpN#(n,b) mapMicroOpN(function b f(a x), MicroOpN#(n,a) op) =
  mapMicroOp(Vector::map(f),op);

// Input of the execution of an instruction
typedef MicroOpN#(numReg, Bit#(32)) ExecInput#(numeric type numReg);

// data needed to execute an instruction in a functional unit
// (except for loads and stores)
typedef MicroOpN#(numReg,RegVal) IssueQueueInput#(numeric type numReg);
