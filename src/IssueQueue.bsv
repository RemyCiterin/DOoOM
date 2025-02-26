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
  Vector#(size, PReg#(2, IssueQueueEntry)) queue <- replicateM(mkEhr(?));
  Reg#(Bit#(TLog#(size))) lastIssue <- mkReg(0);
  PReg#(2, Bit#(size)) valid <- mkEhr(0);

  function Maybe#(Bit#(TLog#(size))) getReadyIndex;
    Bit#(size) mask = 0;

    for (Integer i=0; i < valueOf(size); i = i + 1) begin
      if (valid[0][i] == 1) begin
        let rs1_val = queue[i][0].rs1_val;
        let rs2_val = queue[i][0].rs2_val;
        if (rs1_val matches tagged Value .* &&& rs2_val matches tagged Value .*) begin
          mask[i] = 1;
        end
      end
    end

    return firstOneFrom(mask, lastIssue);
  endfunction

  method ActionValue#(ExecInput) issue
    if (getReadyIndex matches tagged Valid .idx);
    actionvalue
      valid[0][idx] <= 0;
      lastIssue <= idx+1;

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
    for (Integer i=0; i < valueOf(size); i = i + 1) if (valid[1][i] == 1) begin
      IssueQueueEntry entry = queue[i][0];

      if (entry.rs1_val matches tagged Wait .idx &&& idx == index)
        entry.rs1_val = tagged Value value;

      if (entry.rs2_val matches tagged Wait .idx &&& idx == index)
        entry.rs2_val = tagged Value value;

      queue[i][0] <= entry;
    end
  endmethod

  method Action enq(IssueQueueEntry entry)
    if (firstOneFrom(~valid[1],0) matches tagged Valid .idx);
    queue[idx][1] <= entry;
    valid[1][idx] <= 1;
  endmethod
endmodule

(* synthesize *)
module mkDefaultIssueQueue(IssueQueue#(IqSize));
  let iq <- mkIssueQueue();
  return iq;
endmodule
