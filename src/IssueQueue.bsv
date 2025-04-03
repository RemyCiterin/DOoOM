import Utils :: *;
import Decode :: *;
import Vector :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;

// The module must have issue < wakeup < enq
interface IssueQueue#(numeric type size, numeric type numReg);
  // Add a new entry in the issue queue
  method Action enq(IssueQueueInput#(numReg) entry);

  // signal that we found the value of a register
  method Action wakeup(RobIndex index, Bit#(32) value);

  // dequeue a ready instruction from it's queue and send
  // it to the functional units
    method ActionValue#(ExecInput#(numReg)) issue;
endinterface

// generate an issue queue of a given size
module mkIssueQueue(IssueQueue#(size, numReg));
  Vector#(size, Ehr#(2, IssueQueueInput#(numReg))) queue <- replicateM(mkEhr(?));
  Reg#(Bit#(TLog#(size))) lastIssue <- mkReg(0);
  Ehr#(2, Bit#(size)) valid <- mkEhr(0);

  Bit#(size) rdy = 0;
  for (Integer i=0; i < valueOf(size); i = i + 1) if (valid[0][i] == 1) begin
    if (Vector::all(isValue, queue[i][0].regs)) rdy[i] = 1;
  end

  Vector#(size, Age) ages = ?;
  for (Integer i=0; i < valueOf(size); i = i + 1) ages[i] = queue[i][0].age;

  function Maybe#(Bit#(TLog#(size))) getReadyIndex;
    return findOldest(ages, rdy);
  endfunction

  function Bit#(TLog#(size)) next(Bit#(TLog#(size)) idx) =
    idx == fromInteger(valueOf(size)-1) ? 0 : idx + 1;

    method ActionValue#(ExecInput#(numReg)) issue
    if (getReadyIndex matches tagged Valid .idx);
    valid[0][idx] <= 0;
    lastIssue <= idx+1;

    IssueQueueInput#(numReg) entry = queue[idx][0];
    return ExecInput {
      pc: entry.pc,
      frm: entry.frm,
      instr: entry.instr,
      index: entry.index,
      regs: Vector::map(getRegValue, entry.regs)
    };
  endmethod

  method Action wakeup(RobIndex index, Bit#(32) value);
    for (Integer i=0; i < valueOf(size); i = i + 1) begin
      IssueQueueInput#(numReg) entry = queue[i][0];

      for (Integer j=0; j < valueOf(numReg); j = j + 1) begin
        if (entry.regs[j] matches tagged Wait .idx &&& idx == index)
          entry.regs[j] = Value(value);
      end

      queue[i][0] <= entry;
    end
  endmethod

  method Action enq(IssueQueueInput#(numReg) entry)
    if (firstOneFrom(~valid[1],0) matches tagged Valid .idx);
    queue[idx][1] <= entry;
    valid[1][idx] <= 1;
  endmethod
endmodule

(* synthesize *)
module mkDefaultIssueQueue(IssueQueue#(IqSize, 2));
  let iq <- mkIssueQueue();
  return iq;
endmodule

(* synthesize *)
module mkDefaultFloatIssueQueue(IssueQueue#(IqSize, 3));
  let iq <- mkIssueQueue();
  return iq;
endmodule

module mkOrderedIssueQueue(IssueQueue#(size, numReg));
  Vector#(size, Ehr#(2, IssueQueueInput#(numReg))) queue <- replicateM(mkEhr(?));
  Reg#(Bit#(TLog#(size))) head <- mkReg(0);
  Reg#(Bit#(TLog#(size))) tail <- mkReg(0);
  Ehr#(2, Bit#(size)) valid <- mkEhr(0);

  method ActionValue#(ExecInput#(numReg)) issue()
    if (Vector::all(isValue, queue[head][0].regs) && valid[0][head] == 1);

    head <= head == fromInteger(valueOf(size)-1) ? 0 : head + 1;
    valid[0][head] <= 0;

    IssueQueueInput#(numReg) entry = queue[head][0];
    return ExecInput {
      pc: entry.pc,
      frm: entry.frm,
      instr: entry.instr,
      index: entry.index,
      regs: Vector::map(getRegValue, entry.regs)
    };
  endmethod

  method Action wakeup(RobIndex index, Bit#(32) value);
    for (Integer i=0; i < valueOf(size); i = i + 1) begin
      IssueQueueInput#(numReg) entry = queue[i][0];

      for (Integer j=0; j < valueOf(numReg); j = j + 1) begin
        if (entry.regs[j] matches tagged Wait .idx &&& idx == index)
          entry.regs[j] = Value(value);
      end

      queue[i][0] <= entry;
    end
  endmethod

  method Action enq(IssueQueueInput#(numReg) entry) if (valid[1][tail] == 0);
    tail <= tail == fromInteger(valueOf(size)-1) ? 0 : tail + 1;
    queue[tail][1] <= entry;
    valid[1][tail] <= 1;
  endmethod
endmodule

(* synthesize *)
module mkDefaultOrderedIssueQueue(IssueQueue#(IqSize, 2));
  let iq <- mkOrderedIssueQueue();
  return iq;
endmodule
