import Utils :: *;
import Decode :: *;
import Vector :: *;
import Fifo :: *;
import DReg :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;

// The module must have wakeup < issue < enqueue
interface IssueQueue#(numeric type size, numeric type numReg);
  // Add a new entry in the issue queue
  method Action enq(IssueQueueInput#(numReg) entry);

  // signal that we found the value of a register
  method Action wakeup(PhysReg pdst, Bit#(32) value);

  // dequeue a ready instruction from it's queue and send
  // it to the functional units
  interface FifoO#(ExecInput#(numReg)) issue;
endinterface

// generate an issue queue of a given size
module mkIssueQueue(IssueQueue#(size, numReg));
  Vector#(size, Ehr#(3, IssueQueueInput#(numReg))) queue <- replicateM(mkEhr(?));
  Ehr#(2, Bit#(size)) valid <- mkEhr(0);

  Ehr#(2, Maybe#(Bit#(TLog#(size)))) head <- mkEhr(Valid(0));

  Bit#(size) rdy = 0;
  for (Integer i=0; i < valueOf(size); i = i + 1) if (valid[0][i] == 1) begin
    if (Vector::all(isValue, queue[i][0].regs)) rdy[i] = 1;
  end

  // Foward the ready signal to the issue stage
  FWire#(Maybe#(Bit#(TLog#(size)))) readyIndex <- mkFWire(firstOneFrom(rdy,0));
  FWire#(IssueQueueInput#(numReg)) readyEntry <- mkFWire(queue[unJust(readyIndex.read)][0]);

  interface FifoO issue;
    method Action deq()
      if (readyIndex.read matches tagged Valid .idx &&& readyIndex.valid);
      action
        if (head[0] == Invalid) head[0] <= Valid(fromInteger(valueOf(size)-1));
        else head[0] <= Valid(unJust(head[0]) - 1);
        valid[0] <= valid[0] >> 1;

        for (Integer i=0; i < valueOf(size) - 1; i = i + 1) begin
          if (fromInteger(i) >= idx) queue[i][1]  <= queue[i+1][1];
        end
      endaction
    endmethod

    method ExecInput#(numReg) first
      if (readyIndex.read matches tagged Valid .idx &&& readyIndex.valid);
    return mapMicroOpN(getRegValue,readyEntry.read);
    endmethod

    method Bool canDeq = readyIndex.read != Invalid && readyIndex.valid;
  endinterface

  method Action wakeup(PhysReg pdst, Bit#(32) value);
    for (Integer i=0; i < valueOf(size); i = i + 1) begin
      IssueQueueInput#(numReg) entry = queue[i][0];

      for (Integer j=0; j < valueOf(numReg); j = j + 1) begin
        if (entry.regs[j] matches tagged Wait .p &&& p == pdst)
          entry.regs[j] = Value(value);
      end

      queue[i][0] <= entry;
    end
  endmethod

  method Action enq(IssueQueueInput#(numReg) entry)
    if (head[1] matches tagged Valid .idx);
    head[1] <= idx == fromInteger(valueOf(size)-1) ? Invalid : Valid(idx+1);
    valid[1] <= (valid[1] << 1) | 1;
    queue[idx][2] <= entry;
  endmethod
endmodule

(* synthesize *)
module mkDefaultIssueQueue(IssueQueue#(IqSize, 2));
  let iq <- mkIssueQueue();
  return iq;
endmodule

module mkOrderedIssueQueue(IssueQueue#(size, numReg));
  Vector#(size, Ehr#(3, IssueQueueInput#(numReg))) queue <- replicateM(mkEhr(?));
  Reg#(Bit#(TLog#(size))) head <- mkReg(0);
  Reg#(Bit#(TLog#(size))) tail <- mkReg(0);
  Ehr#(2, Bit#(size)) valid <- mkEhr(0);

  interface FifoO issue;
    method Action deq()
      if (Vector::all(isValue, queue[head][0].regs) && valid[0][head] == 1);
      action
        head <= head == fromInteger(valueOf(size)-1) ? 0 : head + 1;
        valid[0][head] <= 0;
      endaction
    endmethod

    method ExecInput#(numReg) first
      if (Vector::all(isValue, queue[head][0].regs) && valid[0][head] == 1);
      return mapMicroOpN(getRegValue, queue[head][0]);
    endmethod

    method Bool canDeq =
      Vector::all(isValue, queue[head][0].regs) && valid[0][head] == 1;
  endinterface

  method Action wakeup(PhysReg pdst, Bit#(32) value);
    for (Integer i=0; i < valueOf(size); i = i + 1) begin
      IssueQueueInput#(numReg) entry = queue[i][1];

      for (Integer j=0; j < valueOf(numReg); j = j + 1) begin
        if (entry.regs[j] matches tagged Wait .p &&& p == pdst)
          entry.regs[j] = Value(value);
      end

      queue[i][1] <= entry;
    end
  endmethod

  method Action enq(IssueQueueInput#(numReg) entry) if (valid[1][tail] == 0);
    tail <= tail == fromInteger(valueOf(size)-1) ? 0 : tail + 1;
    queue[tail][2] <= entry;
    valid[1][tail] <= 1;
  endmethod
endmodule

(* synthesize *)
module mkDefaultOrderedIssueQueue(IssueQueue#(IqSize, 2));
  let iq <- mkOrderedIssueQueue();
  return iq;
endmodule
