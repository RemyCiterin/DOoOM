import RegFile :: *;
import Decode :: *;
import Utils :: *;
import Fifo :: *;
import Ehr :: *;


typedef enum {
  Call, Ret, RetCall, Branch, Jump, Linear
} InstrKind deriving(Bits, FShow, Eq);

function InstrKind instrKind(Instr instr);
  return case (instr) matches
    tagged Btype .* : Branch;
    tagged Itype {instr: .itype, op: JALR} :
      case (tuple2(destination(itype).name, register1(itype).name)) matches
        Tuple2 {fst: 1, snd: 5} : Call;
        Tuple2 {fst: 5, snd: 1} : Call;
        Tuple2 {fst: 5, snd: .*} : Call;
        Tuple2 {fst: 1, snd: .*} : Call;
        Tuple2 {fst: .*, snd: 5} : Ret;
        Tuple2 {fst: .*, snd: 1} : Ret;
        default: Jump;
      endcase
    tagged Jtype .* : Jump;
    default: Linear;
  endcase;
endfunction

function InstrKind instrKindOpt(Maybe#(Instr) opt);
  return case (opt) matches
    tagged Valid .instr : instrKind(instr);
    Invalid : Linear;
  endcase;
endfunction

typedef 256 StackSize;
typedef 10 HistorySize;
typedef 12 TagSize;

typedef Bit#(TLog#(TagSize)) Tag;
typedef Bit#(TLog#(HistorySize)) History;
typedef Bit#(TLog#(StackSize)) StackIndex;

// An entry of the branch target buffer
typedef struct {
  Bit#(32) pc;
  Bit#(32) next_pc;
  InstrKind kind;
} BtbEntry deriving(Bits, Eq);
