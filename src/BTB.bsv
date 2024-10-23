import Utils :: *;
import RegFile :: *;
import Decode :: *;

interface BTB_IFC;
  method Bit#(32) read(Bit#(32) pc); // return the value of next pc
  method Action update(Bit#(32) pc, Bit#(32) next_pc); // update the value of the next pc
endinterface

typedef struct {
  Bit#(32) pc;
  Bit#(32) next_pc;
} BTB_Entry deriving(Bits, Eq);

// return the last target of a branch instruction

(* synthesize *)
module mkBTB(BTB_IFC);
  RegFile#(Bit#(12), Maybe#(BTB_Entry)) entries <- mkRegFileFullInit(Invalid);

  method Bit#(32) read(Bit#(32) pc);
    let index = truncate(pc >> 2);

    return case (entries.sub(index)) matches
      tagged Valid .entry : (entry.pc == pc ? entry.next_pc : pc + 4);
      Invalid : pc + 4;
    endcase;
  endmethod

  method Action update(Bit#(32) pc, Bit#(32) next_pc);
    action
      let index = truncate(pc >> 2);

      if (next_pc != pc + 4)
        entries.upd(index, tagged Valid (BTB_Entry{pc: pc, next_pc: next_pc}));
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
  Ghr ghr;
  GhtEntry entry;
} BranchPredState deriving(Bits, FShow, Eq);

// Informations given to the branch predictor to update itself
typedef struct {
  BranchPredState state;
  Bit#(32) pc;
  Bit#(32) next_pc;
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

  Reg#(Bit#(32)) mispred_count <- mkReg(0);

  method ActionValue#(BranchPredOutput) doPred(Bit#(32) pc);
    actionvalue
      let taken = ght.takeBranch(pc);
      let branch_pc = btb.read(pc);

      if (branch_pc != pc + 4)
      ght.write( { (taken && branch_pc != pc + 4 ? 1'b1 : 1'b0), truncateLSB(ght.read) } );

      return BranchPredOutput{
        pc: taken ? branch_pc : pc + 4,
        state: BranchPredState{ ghr: ght.read, entry: ght.readTable(pc) }
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
      mispred_count <= mispred_count + 1;

      let ghr = infos.state.ghr;
      let taken = infos.next_pc != infos.pc + 4;

      ght.updateTable(infos.pc, ghr, infos.state.entry, taken);

      Ghr newGhr = { (taken ? 1'b1 : 1'b0), truncateLSB(ghr) };

      if (infos.instr matches tagged Valid .*) begin
        btb.update(infos.pc, infos.next_pc);
        ght.write(newGhr);
      end else
        ght.write(ghr);

      //$display("%d  %b    %b", mispred_count, ghr, newGhr);
    endaction
  endmethod

endmodule

