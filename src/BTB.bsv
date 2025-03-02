import Utils :: *;
import RegFile :: *;
import Decode :: *;
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

typedef 8 RasWidth;
typedef TExp#(RasWidth) RasSize;
typedef Bit#(RasWidth) RasIndex;


interface RAS;
  method RasIndex top();
  method ActionValue#(Maybe#(Bit#(32))) pred(Bit#(32) pc, InstrKind kind);
  method Action backtrack(RasIndex head, InstrKind kind);
endinterface

(* synthesize *)
module mkRAS(RAS);
  RegFile#(RasIndex, Maybe#(Bit#(32))) stack <- mkRegFileFullInit(Invalid);
  Reg#(RasIndex) head <- mkReg(0);

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

  method Action backtrack(RasIndex index, InstrKind kind);
    action
      head <= case (kind) matches
        Call : index + 1;
        Ret : index - 1;
        default : index;
      endcase;
    endaction
  endmethod
endmodule

interface BTB_IFC;
  // Predict the next instruction and it's kind (Jump, Call, Ret...)
  method Tuple2#(Bit#(32), InstrKind) read(Bit#(32) pc);

  // Update the next program pointer and kind of an instruction
  method Action update(Bit#(32) pc, Bit#(32) next_pc, InstrKind kind);
endinterface

typedef struct {
  Bit#(32) pc;
  Bit#(32) next_pc;
  InstrKind kind;
} BTB_Entry deriving(Bits, Eq);

// return the last target of a branch instruction

(* synthesize *)
module mkBTB(BTB_IFC);
  RegFile#(Bit#(10), Maybe#(BTB_Entry)) entries <- mkRegFileFullInit(Invalid);

  method Tuple2#(Bit#(32), InstrKind) read(Bit#(32) pc);
    let index = truncate(pc >> 2);

    return case (entries.sub(index)) matches
      Invalid : tuple2(pc + 4, Linear);
      tagged Valid .entry : entry.pc == pc ?
        tuple2(entry.next_pc, entry.kind) :
        tuple2(pc + 4, Linear);
    endcase;
  endmethod

  method Action update(Bit#(32) pc, Bit#(32) next_pc, InstrKind kind);
    action
      let index = truncate(pc >> 2);

      if (next_pc != pc + 4)
        entries.upd(index, tagged Valid (BTB_Entry{pc: pc, next_pc: next_pc, kind: kind}));
    endaction
  endmethod
endmodule

typedef 12 TagBits;

typedef 10 GhrBits;

typedef Bit#(TagBits) Tag;

typedef Bit#(GhrBits) Ghr;

typedef Int#(2) GhtEntry;

interface GlobalHistoryTable;
  method Ghr read;
  method Action write(Ghr newGhr);

  method Bool takeBranch(Bit#(32) pc);
  method Action updateTable(Bit#(32) pc, Ghr ghr, Bool taken);
endinterface

(* synthesize *)
module mkGht(GlobalHistoryTable);
  RegFile#(Ghr, GhtEntry) taggedTable <- mkRegFileFull;
  RegFile#(Tag, GhtEntry) basicTable <- mkRegFileFullInit(0);
  RegFile#(Ghr, Maybe#(Tag)) tags <- mkRegFileFullInit(Invalid);
  Reg#(Ghr) ghr <- mkReg(0);

  function Ghr hash(Bit#(32) pc, Ghr r);
    return r ^ truncate(pc >> 2);
  endfunction

  function Tag defaultKey(Bit#(32) pc);
    return truncate(pc >> 2);
  endfunction

  method read = ghr;
  method write = ghr._write;

  method Bool takeBranch(Bit#(32) pc);
    let tag = tags.sub(hash(pc, ghr));
    let pred = taggedTable.sub(hash(pc, ghr));
    let base = basicTable.sub(defaultKey(pc));

    return (tag == Valid(defaultKey(pc)) ? pred : base) >= 0;
  endmethod

  method Action updateTable(Bit#(32) pc, Ghr r, Bool taken);
    action
      Ghr k1 = hash(pc, r);
      Tag k2 = defaultKey(pc);
      let v1 = taggedTable.sub(k1);
      let found = tags.sub(k1) == Valid(k2);
      v1 = satPlus(Sat_Bound, v1, taken ? 1 : -1);
      v1 = found ? v1 : (taken ? 0 : -1);
      tags.upd(k1, Valid(k2));
      taggedTable.upd(k1, v1);

      let v2 = basicTable.sub(k2);
      v2 = satPlus(Sat_Bound, v1, taken ? 1 : -1);
      basicTable.upd(k2, v2);
    endaction
  endmethod
endmodule

// State used by the branch predictor to backtrack in case of misprediction
typedef struct {
  // Glock branch history register
  Ghr ghr;

  // Predicted instruction kind
  InstrKind kind;

  // Top of the return address stack
  RasIndex top;
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
  // return the predicted pc, and generate the state to train in case of misprediction
  method ActionValue#(BranchPredOutput) doPred(Bit#(32) pc);

  method Action trainMis(BranchPredTrain infos);
  method Action trainHit(BranchPredTrain infos);
endinterface

module mkBranchPred(BranchPred);
  let btb <- mkBTB;
  let ght <- mkGht;
  let ras <- mkRAS;

  Reg#(Bit#(32)) mispred_count <- mkReg(0);

  method ActionValue#(BranchPredOutput) doPred(Bit#(32) pc);
    actionvalue
      match {.branch_pc, .kind} = btb.read(pc);
      let taken = ght.takeBranch(pc) || kind != Branch;

      let ret_pc <- ras.pred(pc, kind);

      if (ret_pc matches tagged Valid .new_pc) branch_pc = new_pc;

      if (branch_pc != pc + 4 && kind == Branch)
        ght.write( { (taken && branch_pc != pc + 4 ? 1'b1 : 1'b0), truncateLSB(ght.read) } );

      //$display("pred pc: %h ras top: %d kind: ", pc, ras.top, fshow(kind));

      return BranchPredOutput{
        pc: taken ? branch_pc : pc + 4,
        state: BranchPredState
          { ghr: ght.read, kind: kind, top: ras.top }
      };
    endactionvalue
  endmethod

  // train the branch predictor in case of a prediction hit
  method Action trainHit(BranchPredTrain infos);
    action
      let ghr = infos.state.ghr;
      let taken = infos.next_pc != infos.pc + 4;
      ght.updateTable(infos.pc, ghr, taken);
    endaction
  endmethod

  // train the branch predictor in case of a misprediction
  method Action trainMis(BranchPredTrain infos);
    action
      let kind = instrKindOpt(infos.instr);
      mispred_count <= mispred_count + 1;

      let ghr = infos.state.ghr;
      let taken = infos.next_pc != infos.pc + 4;

      if (kind == Branch)
        ght.updateTable(infos.pc, ghr, taken);

      Ghr newGhr = { (taken ? 1'b1 : 1'b0), truncateLSB(ghr) };

      if (infos.instr matches tagged Valid .instr) begin
        btb.update(infos.pc, infos.next_pc, kind);
        ght.write(kind == Branch ? newGhr : ghr);
        ras.backtrack(infos.state.top, kind);
      end else begin
        ras.backtrack(infos.state.top, infos.state.kind);
        ght.write(ghr);
      end


      //$display("%d  %b    %b", mispred_count, ghr, newGhr);
    endaction
  endmethod

endmodule

