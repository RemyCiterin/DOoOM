import LsuTypes :: *;
import Utils :: *;
import OOO :: *;
import Ehr :: *;

import Vector :: *;

// An interface of issue queue specialized for the memory operations
interface MemIssueQueue#(numeric type size, type reqId);
  method Action enq(reqId index, RegVal val, Bit#(32) offset, Epoch epoch, Age age);

  method Action wakeup(RobIndex index, Bit#(32) value);

  // Issue port: the issue queue propose a value using a round-robin order
  // and the LSU call the issue method to select it
  method reqId issueId;
  method Bit#(32) issueVal;
  method Epoch issueEpoch;
  method Age issueAge;
  method Action issue();
endinterface

module mkMemIssueQueue(MemIssueQueue#(size, reqId)) provisos(Bits#(reqId, reqIdW));
  Vector#(size, PReg#(2, RegVal)) values <- replicateM(mkPReg(?));
  Vector#(size, Reg#(Bit#(32))) offsets <- replicateM(mkReg(?));
  Vector#(size, Reg#(reqId)) requests <- replicateM(mkReg(?));
  Vector#(size, Reg#(Epoch)) epochs <- replicateM(mkReg(?));
  Vector#(size, Reg#(Age)) ages <- replicateM(mkReg(?));
  PReg#(2, Bit#(size)) valid <- mkPReg(0);

  Bit#(size) rdy = 0;
  for (Integer i=0; i < valueOf(size); i = i + 1) begin
    if (values[i][0] matches tagged Value .* &&& valid[0][i] == 1)
      rdy[i] = 1;
  end

  PReg#(2, Bit#(TLog#(size))) issueIdx <- mkPReg(0);

  rule roundRobib;
    issueIdx[0] <= issueIdx[0] + 1;
  endrule

  method Action enq(reqId index, RegVal val, Bit#(32) offset, Epoch epoch, Age age)
    if (firstOneFrom(~valid[1],0) matches tagged Valid .idx);
    action
      valid[1][idx] <= 1;
      requests[idx] <= index;
      offsets[idx] <= offset;
      values[idx][1] <= val;
      epochs[idx] <= epoch;
      ages[idx] <= age;
    endaction
  endmethod

  method Action wakeup(RobIndex index, Bit#(32) value);
    action
      for (Integer i=0; i < valueOf(size); i = i + 1) begin
        if (values[i][0] matches tagged Wait .idx &&& idx == index)
          values[i][0] <= tagged Value value;
      end
    endaction
  endmethod

  method reqId issueId()
    if (firstOneFrom(rdy,issueIdx[1]) matches tagged Valid .idx);
    return requests[idx];
  endmethod

  method Epoch issueEpoch()
    if (firstOneFrom(rdy,issueIdx[1]) matches tagged Valid .idx);
    return epochs[idx];
  endmethod

  method Age issueAge()
    if (firstOneFrom(rdy,issueIdx[1]) matches tagged Valid .idx);
    return ages[idx];
  endmethod

  method Bit#(32) issueVal()
    if (firstOneFrom(rdy,issueIdx[1]) matches tagged Valid .idx);
    return getRegValue(values[idx][0]) + offsets[idx];
  endmethod

  method Action issue()
    if (firstOneFrom(rdy,issueIdx[1]) matches tagged Valid .idx);
    action
      valid[0][idx] <= 0;
      issueIdx[1] <= idx;
    endaction
  endmethod
endmodule

(* synthesize *)
module mkStoreIssueQueue(MemIssueQueue#(SiqSize, SqIndex));
  let issueQ <- mkMemIssueQueue;
  return issueQ;
endmodule

(* synthesize *)
module mkLoadIssueQueue(MemIssueQueue#(LiqSize, LqIndex));
  let issueQ <- mkMemIssueQueue;
  return issueQ;
endmodule

