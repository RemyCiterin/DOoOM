import RegFileUtils :: *;
import RegFile :: *;
import Utils :: *;
import Decode :: *;
import Vector :: *;
import Fifo :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;

// first < dmemCommit < deq < writeBack < read < enq
interface ROB;
  /* Stage 1: enqueue */
  // enqueue a new entry in the reorder buffer
  method ActionValue#(RobIndex) enq(RobEntry entry);

  /* Stage 2: write back */
  // write back the result of the execution of an instruction to the rob
  method Action writeBack(RobIndex index, ExecResult result);

  /* Stage 3: dequeue */
  // return the first element of the rob before deq
  method RobEntry first;

  // return the first index of the rob before deq
  method RobIndex first_index;

  // return the result of the execution of the first item
  method Maybe#(ExecResult) first_result;

  // commit the first instruction before deq if necessary
  method Action dmemCommit();

  // dequeue an element of the rob
  method Action deq;
endinterface

(* synthesize *)
module mkROB(ROB);
  RegFile#(RobIndex, RobEntry) data <- mkRegFileFull;
  RegFile#(RobIndex, ExecResult) results <- mkRegFileFull;
  Ehr#(3, Bit#(RobSize)) resultValid <- mkEhr(0);

  Ehr#(2, RobIndex) firstP <- mkEhr(0);
  Reg#(RobIndex) nextP <- mkReg(0);

  RobIndex max_index = fromInteger(valueOf(RobSize) - 1);

  Ehr#(2, Bool) empty <- mkEhr(True);
  Ehr#(2, Bool) full <- mkEhr(False);

  // true if we wait the commit notification from DMEM
  Ehr#(2, Bit#(RobSize)) waitDmemCommit <- mkEhr(0);

  // use port 1 of data, empty and full
  method ActionValue#(RobIndex) enq(RobEntry entry)
    if (!full[1]);
    actionvalue
      //resultValid[1][nextP] <= 0;
      let next_nextP = (nextP == max_index ? 0 : nextP + 1);
      let index = nextP;

      data.upd(nextP, entry);
      empty[1] <= False;
      nextP <= next_nextP;

      if (next_nextP == firstP[1])
        full[1] <= True;

      waitDmemCommit[1][nextP] <= entry.tag == DMEM ? 1 : 0;

      return index;
    endactionvalue
  endmethod

  method RobEntry first if (!empty[0]);
    return data.sub(firstP[0]);
  endmethod

  method RobIndex first_index if (!empty[0]);
    return firstP[0];
  endmethod

  method first_result if (!empty[0]);
    return resultValid[0][firstP[0]] == 1 ?
      Valid(results.sub(firstP[0])) : Invalid;
  endmethod

  method Action dmemCommit() if (waitDmemCommit[0][firstP[0]] == 1);
    action
      waitDmemCommit[0][firstP[0]] <= 0;
    endaction
  endmethod

  method Action deq if (!empty[0] && waitDmemCommit[1][firstP[0]] == 0);
    let next_firstP = (firstP[0] == max_index ? 0 : firstP[0] + 1);
    full[0] <= False;

    firstP[0] <= next_firstP;
    resultValid[0][firstP[0]] <= 0;
    if (next_firstP == nextP)
      empty[0] <= True;
  endmethod

  method Action writeBack(RobIndex index, ExecResult result);
    action
      results.upd(index, result);
      resultValid[1][index] <= 1;
    endaction
  endmethod
endmodule
