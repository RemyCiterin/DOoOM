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
typedef 12 HistorySize;
typedef 12 TagSize;

typedef Bit#(TagSize) Tag;
typedef Bit#(HistorySize) History;
typedef Bit#(TLog#(StackSize)) StackIndex;

// An entry of the branch target buffer
typedef struct {
  Bit#(32) pc;
  Bit#(32) next_pc;
  InstrKind kind;
} BtbEntry deriving(Bits, Eq);

interface BranchTargetBuffer;
  /* Stage 1: read request */
  method Action start(Bit#(32) pc);

  /* Stage 2: get the result of the read request */
  method Tuple2#(Bit#(32), InstrKind) response();
  method Action deq();

  /* Stage 3: update the state */
  method Action write(Bit#(32) pc, Bit#(32) next_pc, InstrKind kind);
endinterface

(* synthesize *)
module mkBranchTargetBuffer(BranchTargetBuffer);
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

    return case (entries.response) matches
      tagged Valid .entry : entry.pc == pc ?
        tuple2(entry.next_pc, entry.kind) :
        tuple2(pc+4, Linear);
      Invalid :
        tuple2(pc+4, Linear);
    endcase;
  endmethod

  method Action deq();
    action
      entries.deq();
      pcQ.deq();
    endaction
  endmethod

  method Action write(Bit#(32) pc, Bit#(32) next_pc, InstrKind kind);
    action
      if (pc + 4 != next_pc)
        entries.write(truncate(pc >> 2), Valid(BtbEntry{
          next_pc: next_pc,
          kind: kind,
          pc: pc
        }));
    endaction
  endmethod
endmodule

interface ReturnAddressStack;
  method StackIndex topOfStack();
  method ActionValue#(Maybe#(Bit#(32))) pred(Bit#(32) pc, InstrKind kind);
  method Action backtrack(StackIndex head, InstrKind kind);
endinterface

(* synthesize *)
module mkReturnAddressStack(ReturnAddressStack);
  RegFile#(StackIndex, Maybe#(Bit#(32))) stack <- mkRegFileFullInit(Invalid);
  Reg#(StackIndex) head <- mkReg(0);

  method topOfStack = head;

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
  Int#(3) base;

  // Accurate prediction using the program counter and the history
  Int#(3) pred;

  // Tag to check the validity of the accurate prediction
  Maybe#(Tag) tag;
} GhtState deriving(Bits, FShow, Eq);

interface GlobalHistoryTable;
  /* Stage 1: read request */
  method Action start(Bit#(32) pc, History h);

  /* Stage 2: get the read result */
  method Bool prediction;
  method GhtState state;
  method Action deq();

  method Action train(Bit#(32) pc, History h, Bool taken, GhtState st);
endinterface

(* synthesize *)
module mkGlobalHistoryTable(GlobalHistoryTable);
  Bram#(History, Maybe#(Tag)) tagRam <- mkBramInit(Invalid);
  Bram#(Tag, Int#(3)) baseRam <- mkBramInit(0);
  Bram#(History, Int#(3)) predRam <- mkBram();

  Fifo#(1, History) historyQ <- mkPipelineFifo;
  Fifo#(1, Tag) tagQ <- mkPipelineFifo;

  function History hashTagged(Bit#(32) pc, History h);
    return h ^ truncate(pc >> 2);
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
    return GhtState{
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

  method Action train(Bit#(32) pc, History h, Bool taken, GhtState st);
    action
      let base = satPlus(Sat_Bound, st.base, taken ? 1 : -1);
      let pred = satPlus(Sat_Bound, st.pred, taken ? 1 : -1);
      let found = st.tag == Valid(hashBasic(pc));
      pred = found ? pred : (taken ? 0 : -1);

      tagRam.write(hashTagged(pc, h), Valid(hashBasic(pc)));
      predRam.write(hashTagged(pc, h), pred);
      baseRam.write(hashBasic(pc), base);
    endaction
  endmethod
endmodule

// State used by the branch predictor to backtrack in case of misprediction
typedef struct {
  // Glock branch history register
  History ghr;

  // Predicted instruction kind
  InstrKind kind;

  // Top of the return address stack
  StackIndex top;

  // State saved from the GlobalHistoryTable
  GhtState state;
} BranchPredState deriving(Bits, FShow, Eq);

// Informations given to the branch predictor to update itself
typedef struct {
  // Backtracking state
  BranchPredState state;

  // Current program counter
  Bit#(32) pc;

  // Next program counter
  Bit#(32) next_pc;

  // Instruction if the backtracking is due to a branch misprediction
  Maybe#(Instr) instr;
} BranchPredTrain deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(32) pc;
  BranchPredState state;
} BranchPredOutput deriving(Bits, FShow, Eq);

interface BranchPred;
  /* Stage 1: read request */
  method Action start(Bit#(32) pc, Epoch epoch);

  /* Stage 2: do the prediction */
  // deq and pred are in two different methods such that if the epoch is not
  // up-to-date we may ignore the prediction and just deq from the predictor
  method ActionValue#(BranchPredOutput) pred;
  // return the Epoch and Program counter we used to make the prediciton
  // (not the predicted Pc, the initial Pc)
  method Epoch predEpoch();
  method Bit#(32) predPc();
  method Action deq();

  method Action trainMis(BranchPredTrain infos);
  method Action trainHit(BranchPredTrain infos);
endinterface

(* synthesize *)
module mkBranchPred(BranchPred);
  let btb <- mkBranchTargetBuffer;
  let ght <- mkGlobalHistoryTable;
  let ras <- mkReturnAddressStack;
  Ehr#(2, History) history <- mkEhr(0);

  Fifo#(1, Epoch) epochQ <- mkPipelineFifo;
  Fifo#(1, Bit#(32)) pcQ <- mkPipelineFifo;

  method Action start(Bit#(32) pc, Epoch epoch);
    action
      ght.start(pc, history[1]);
      epochQ.enq(epoch);
      btb.start(pc);
      pcQ.enq(pc);
    endaction
  endmethod

  method ActionValue#(BranchPredOutput) pred();
    let pc = pcQ.first();

    match {.branch_pc, .kind} = btb.response();
    let taken = ght.prediction() || kind != Branch;

    let ret_pc <- ras.pred(pc, kind);
    if (ret_pc matches tagged Valid .new_pc) branch_pc = new_pc;

    if (branch_pc != pc + 4 && kind == Branch)
      history[0] <= {truncate(history[0]), taken ? 1'b1 : 1'b0};

    return BranchPredOutput{
      pc: taken ? branch_pc : pc + 4,
      state: BranchPredState{
        top: ras.topOfStack,
        state: ght.state,
        ghr: history[0],
        kind: kind
      }
    };
  endmethod

  method predEpoch = epochQ.first;
  method predPc = pcQ.first;

  method Action deq();
    action
      epochQ.deq();
      btb.deq();
      ght.deq();
      pcQ.deq();
    endaction
  endmethod

  method Action trainHit(BranchPredTrain infos);
    action
      let ghr = infos.state.ghr;
      let taken = infos.next_pc != infos.pc + 4;
      ght.train(infos.pc, ghr, taken, infos.state.state);
    endaction
  endmethod

  method Action trainMis(BranchPredTrain infos);
    action
      let kind = instrKindOpt(infos.instr);

      let ghr = infos.state.ghr;
      let taken = infos.next_pc != infos.pc + 4;

      if (kind == Branch)
        ght.train(infos.pc, ghr, taken, infos.state.state);

      History newGhr = {truncate(ghr), taken ? 1'b1 : 1'b0};

      if (infos.instr matches tagged Valid .instr) begin
        history[0] <= kind == Branch ? newGhr : ghr;
        btb.write(infos.pc, infos.next_pc, kind);
        ras.backtrack(infos.state.top, kind);
      end else begin
        ras.backtrack(infos.state.top, infos.state.kind);
        history[0] <= ghr;
      end
    endaction
  endmethod
endmodule
