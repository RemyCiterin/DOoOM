import Utils :: *;
import Decode :: *;
import Vector :: *;
import Ehr :: *;
import CSR :: *;
import BTB :: *;

typedef 6 RobSize;
typedef Bit#(TLog#(RobSize)) RobIndex;

// The execution of an instruction return either
// an exception with a cause and a mtval value,
// or the value to put in rd and the next pc
typedef union tagged {
  struct {
    CauseException cause;
    Bit#(32) tval;
  } Error;

  struct {
    Bit#(32) rd_val;
    Bit#(32) next_pc;
  } Ok;
} ExecOutput deriving(Bits, FShow, Eq);

function Bit#(32) getRdVal(ExecOutput result);
  return case (result) matches
    tagged Ok {rd_val: .rd_val} : rd_val;
    .* : (?);
  endcase;
endfunction

//   During a store commit, the load store unit may return that
// all the instruction from a certain points are mispredicted,
// in particular a load may return a mispredicted value if the
// address dependency check fail
typedef union tagged {
  RobIndex Exception;
  void Success;
} CommitOutput deriving(Bits, FShow, Eq);

// Input of the execution of an instruction
typedef struct {
  RobIndex index;
  Bit#(32) pc;
  Instr instr;
  Bit#(32) rs1_val;
  Bit#(32) rs2_val;
} ExecInput deriving(Bits, FShow, Eq);

typedef struct {
  // the program pointer associated to the instruction
  Bit#(32) pc;

  // the decoded instruction
  Instr instr;

  // tag of the instruction (or Direct if their is a fetching of decoding error)
  Exec_Tag tag;

  // the value of the epoch register at the instruction fetching
  Epoch epoch;

  // age of the operation, mostly used by the LSU
  Age age;

  // PC predicted by the branch predictor
  Bit#(32) pred_pc;

  // all the informations used by the branch predictor to backtrack in case of misprediction
  BranchPredState bpred_state;
} RobEntry deriving(Bits, FShow, Eq);

typedef union tagged {
  Bit#(32) Value;
  RobIndex Wait;
} RegVal deriving(Bits, FShow, Eq);

function Bit#(32) getRegValue(RegVal r);
  return case (r) matches
    tagged Value .v : v;
    default: ?;
  endcase;
endfunction


// data needed to execute an instruction in a functional unit
// (except for loads and stores)
typedef struct {
  RobIndex index;
  Bit#(32) pc;
  Instr instr;
  RegVal rs1_val;
  RegVal rs2_val;
  Age age;

  // Store queue forward the stores values only if the epochs matches
  Epoch epoch;
} IssueQueueEntry deriving(Bits, FShow, Eq);
