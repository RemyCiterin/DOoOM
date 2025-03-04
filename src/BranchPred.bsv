import BlockRam :: *;
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

interface Btb;
  /* Stage 1: read request */
  method Action start(Bit#(32) pc);

  /* Stage 2: get the result of the read request */
  method Tuple2#(Bit#(32), InstrKind) response();
  method Action deq();

  /* Stage 3: update the state */
  method Action write(Bit#(32) pc, Bit#(32) next_pc, InstrKind kind);
endinterface

(* synthesize *)
module mkBtb(Btb);
  Bram#(Tag, Maybe#(BtbEntry)) entries <- mkBramInit(Invalid);
  Fifo#(1, Bit#(32)) pcQ <- mkPipelineFifo;

  method Action start(Bit#(32) pc);
    action
      entries.read(truncate(pc >> 2));
      pcQ.enq(pc);
    endaction
  endmethod

  method Tuple2#(Bit#(32), InstrKind) response();
    let pc = pcQ.first();

    case (entries.response) matches
      tagged Valid .entry :
        if (entry.pc == pc) return tuple2(entry.next_pc, entry.kind);
        else return tuple2(pc+4, Linear);
      Invalid :
        return tuple2(pc+4, Linear);
    endcase
  endmethod

  method Action deq();
    action
      entries.deq();
      pcQ.deq();
    endaction
  endmethod

  method Action write(Bit#(32) pc, Bit#(32) next_pc, InstrKind kind);
    action
      if (pc + 4 != next_pc && kind != Linear)
        entries.write(truncate(pc >> 2), Valid(BtbEntry{
          next_pc: next_pc,
          kind: kind,
          pc: pc
        }));
    endaction
  endmethod
endmodule

interface RetrnAddresStack;
  method StackIndex topOfStack();
  method ActionValue#(Maybe#(Bit#(32))) pred(Bit#(32) pc, InstrKind kind);
  method Action backtrack(StackIndex head, InstrKind kind);
endinterface

(* synthesize *)
module mkReturnAddressStack(ReturnAddressStack);
  RegFile#(StackIndex, Maybe#(Bit#(32))) stack <- mkRegFileFullInit(Invalid);
  Reg#(StackIndex) head <- mkReg(0);

  method top = head;

  method ActionValue#(Maybe#(Bit#(32))) pred(Bit#(32) pc, InstrKind kind);
    head <= case (kind) matches
      Call : head + 1;
      Ret : head - 1;
      default : head;
    endcase;

    if (kind == Call)
      stack.upd(head, Valid(pc+4));

    return kind == Ret ? stack.sub(head-1) : Invalid;
  endmethod

  method Action backtrack(StackIndex index, InstrKind kind);
    action
      head <= case (kind) matches
        Call : index + 1;
        Ret : index - 1;
        default : index;
      endcase;
    endaction
  endmethod
endmodule

typedef struct {
  // Basic prediciton using only the program counter
  Int#(2) base;

  // Accurate prediction using the program counter and the history
  Int#(2) pred;

  // Tag to check the validity of the accurate prediction
  Maybe#(tag) tag;
} GhtState deriving(Bits, FShow, Eq);

interface GlobalHistoryTable;
  /* Stage 1: read request */
  method Action start(Bit#(32) pc, History h);

  /* Stage 2: get the read result */
  method Bool prediction;
  method GhtState state;
  method Action deq();
endinterface

module mkGlobalHistoryTable(GlobalHistoryTable);
  Bram#(History, Maybe#(Tag)) tagRam <- mkBramInit(Invalid);
  Bram#(History, Int#(2)) predRam <- mkBram();
  Bram#(Tag, Int#(2)) baseRam <- mkBram();

  Fifo#(1, History) historyQ <- mkPipelineFifo;
  Fifo#(1, Tag) tagQ <- mkPipelineFifo;

  function History hashTaged(Bit#(32) pc, History h);
    return history ^ truncate(pc >> 2);
  endfunction

  function Tag hashBasic(Bit#(32) pc);
    return truncate(pc >> 2);
  endfunction

  method Action start(Bit#(32) pc, History h);
    action
      historyQ.enq(hashTagged(pc, h));
      predRam.read(hashTagged(pc, h));
      tagRam.read(hashTagged(pc, h));
      baseRam.read(hashBasic(pc));
      tagQ.enq(hashBasic(pc));
    endaction
  endmethod

  method GhtState state;
    return GhtEntry{
      pred: predRam.response(),
      base: baseRam.response(),
      tag: tagRam.response()
    };
  endmethod

  method Bool prediction();
    return
      tagRam.response() == Valid(tagQ.first) ?
        predRam.response() >= 0 : baseRam.response() >= 0;
  endmethod

  method Action deq();
    action
      historyQ.deq();
      predRam.deq();
      baseRam.deq();
      tagRam.deq();
      tagQ.deq();
    endaction
  endmethod
endmodule
