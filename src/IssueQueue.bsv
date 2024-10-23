package IssueQueue;

import Utils :: *;
import Decode :: *;
import Vector :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;

// The module must have issue < wakeup < enq
interface IssueQueue#(numeric type size);
  // Add a new entry in the issue queue
  method Action enq(IssueQueueEntry entry);

  // signal that we found the value of a register
  method Action wakeup(RobIndex index, Bit#(32) value);

  // dequeue a ready instruction from it's queue and send
  // it to the functional units
  method ActionValue#(ExecInput) issue;
endinterface

// generate an issue queue of a given size
module mkIssueQueue(IssueQueue#(size));
  Vector#(size, Ehr#(2, IssueQueueEntry)) queue <- replicateM(mkEhr(?));
  Vector#(size, Ehr#(2, Bool)) valid <- replicateM(mkEhr(False));

  Ehr#(2, Maybe#(Bit#(TLog#(size)))) free_head <- mkEhr(Valid(0));
  Vector#(size, Ehr#(2, Maybe#(Bit#(TLog#(size))))) free_list = newVector;

  for (Integer i=0; i < valueOf(size); i = i + 1) begin
    if (i+1 == valueOf(size)) free_list[i] <- mkEhr(Invalid);
    else free_list[i] <- mkEhr(Valid(fromInteger(i+1)));
  end

  function Maybe#(Bit#(TLog#(size))) getFreeIndex;
    return free_head[1];
  endfunction

  function Maybe#(Bit#(TLog#(size))) getReadyIndex;
    Maybe#(Bit#(TLog#(size))) index = Invalid;

    for (Integer i=0; i < valueOf(size); i = i + 1) begin
      if (valid[i][0]) begin
        let rs1_val = queue[i][0].rs1_val;
        let rs2_val = queue[i][0].rs2_val;
        if (rs1_val matches tagged Value .* &&& rs2_val matches tagged Value .*) begin
          index = tagged Valid fromInteger(i);
        end
      end
    end

    return index;
  endfunction

  method ActionValue#(ExecInput) issue
    if (getReadyIndex matches tagged Valid .idx);
    actionvalue
      free_list[idx][0] <= free_head[0];
      free_head[0] <= Valid(idx);
      valid[idx][0] <= False;

      IssueQueueEntry entry = queue[idx][0];
      return ExecInput {
        pc: entry.pc,
        instr: entry.instr,
        index: entry.index,
        rs1_val: getRegValue(entry.rs1_val),
        rs2_val: getRegValue(entry.rs2_val)
      };
    endactionvalue
  endmethod

  method Action wakeup(RobIndex index, Bit#(32) value);
    for (Integer i=0; i < valueOf(size); i = i + 1) if (valid[i][1]) begin
      IssueQueueEntry entry = queue[i][0];

      if (entry.rs1_val matches tagged Wait .idx &&& idx == index)
        entry.rs1_val = tagged Value value;

      if (entry.rs2_val matches tagged Wait .idx &&& idx == index)
        entry.rs2_val = tagged Value value;

      queue[i][0] <= entry;
    end
  endmethod

  method Action enq(IssueQueueEntry entry) if (getFreeIndex matches tagged Valid .idx);
    free_head[1] <= free_list[idx][1];
    free_list[idx][1] <= Invalid;
    queue[idx][1] <= entry;
    valid[idx][1] <= True;
  endmethod
endmodule

endpackage
