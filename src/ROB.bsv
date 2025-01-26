import Utils :: *;
import Decode :: *;
import Vector :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;

// first < deq < writeBack < read < enq
interface ROB;
  /* Stage 1: enqueue */
  // read an entry from the rob
  method RobEntry read1(RobIndex index);

  // read an entry from the rob
  method RobEntry read2(RobIndex index);

  // enqueue a new entry in the reorder buffer
  method ActionValue#(RobIndex) enq(RobEntry entry);

  /* Stage 2: write back */
  // write back the result of the execution of an instruction to the rob
  method Action writeBack(RobIndex index, ExecOutput result);

  /* Stage 3: dequeue */
  // return the first element of the rob before deq
  method RobEntry first;

  // return the first index of the rob before deq
  method RobIndex first_index;

  // dequeue an element of the rob
  method Action deq;
endinterface

(* synthesize *)
module mkROB(ROB);
  // we cannot writeBack and enqueue at the same addresse in the
  // same cycle, so only a register is needed
  Vector#(RobSize, Ehr#(2, RobEntry)) data <- replicateM(mkEhr(?));

  Ehr#(2, RobIndex) firstP <- mkEhr(0);
  Reg#(RobIndex) nextP <- mkReg(0);

  RobIndex max_index = fromInteger(valueOf(RobSize) - 1);

  Ehr#(2, Bool) empty <- mkEhr(True);
  Ehr#(2, Bool) full <- mkEhr(False);

  (* execution_order = "deq, writeBack, enq" *)
  rule emptyRl;
  endrule

  // use port 1 of data, empty and full
  method ActionValue#(RobIndex) enq(RobEntry entry) if (!full[1]);
    let next_nextP = (nextP == max_index ? 0 : nextP + 1);
    let index = nextP;

    data[nextP][1] <= entry;
    empty[1] <= False;
    nextP <= next_nextP;

    if (next_nextP == firstP[1])
      full[1] <= True;

    return index;
  endmethod

  method RobEntry first if (!empty[0]);
    return data[firstP[0]][0];
  endmethod

  method RobIndex first_index if (!empty[0]);
    return firstP[0];
  endmethod

  method Action deq if (!empty[0]);
    let next_firstP = (firstP[0] == max_index ? 0 : firstP[0] + 1);
    full[0] <= False;

    firstP[0] <= next_firstP;
    if (next_firstP == nextP)
      empty[0] <= True;
  endmethod

  method RobEntry read1(RobIndex index);
    return data[index][1];
  endmethod

  method RobEntry read2(RobIndex index);
    return data[index][1];
  endmethod

  method Action writeBack(RobIndex index, ExecOutput result);
    action
      //$display("set entry %h to ", index, fshow(result));
      RobEntry x = data[index][0];
      x.result = tagged Valid result;
      data[index][0] <= x;
    endaction
  endmethod
endmodule
