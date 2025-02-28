import Utils :: *;
import RegFile :: *;
import Decode :: *;

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
  RegFile#(Bit#(12), Maybe#(BTB_Entry)) entries <- mkRegFileFullInit(Invalid);

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

typedef 12 GhrBits;

typedef Bit#(GhrBits) Ghr;

typedef Bit#(3) GhtEntry;

// Global history table interface: read < tableResponse < tableRequest < update
interface GhtIFC;
  method Ghr read;
  method Action write(Ghr newGhr);

  method Bool takeBranch(Bit#(32) pc);
  method GhtEntry readTable(Bit#(32) pc);
  method Action updateTable(Bit#(32) pc, Ghr ghr, GhtEntry val, Bool taken);
endinterface

module mkGht(GhtIFC);
  RegFile#(Ghr, GhtEntry) entries <- mkRegFileFullInit(4);
  Reg#(Ghr) ghr <- mkReg(0);

  function Ghr hash(Bit#(32) pc, Ghr r);
    return r ^ truncate(pc >> 2) ^ (truncate(pc >> (2 + valueOf(GhrBits))) - 17);
  endfunction

  method read = ghr;
  method write = ghr._write;

  method GhtEntry readTable(Bit#(32) pc);
    return entries.sub(hash(pc, ghr));
  endmethod

  method Bool takeBranch(Bit#(32) pc);
    return entries.sub(hash(pc, ghr)) > 3;
  endmethod

  method Action updateTable(Bit#(32) pc, Ghr r, GhtEntry val, Bool taken);
    action
      if (val != minBound && !taken) val = val - 1;
      else if (val != maxBound && taken) val = val + 1;
      entries.upd(hash(pc, r), val);
    endaction
  endmethod
endmodule

// State used by the branch predictor to backtrack in case of misprediction
typedef struct {
  // Glock branch history register
  Ghr ghr;

  GhtEntry entry;

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
          { ghr: ght.read, entry: ght.readTable(pc), kind: kind, top: ras.top }
      };
    endactionvalue
  endmethod

  // train the branch predictor in case of a prediction hit
  method Action trainHit(BranchPredTrain infos);
    action
      let ghr = infos.state.ghr;
      let taken = infos.next_pc != infos.pc + 4;
      ght.updateTable(infos.pc, ghr, infos.state.entry, taken);
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
        ght.updateTable(infos.pc, ghr, infos.state.entry, taken);

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

