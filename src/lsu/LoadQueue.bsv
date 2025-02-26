import AXI4_Lite :: *;
import LsuTypes :: *;
import Utils :: *;
import Fifo :: *;
import OOO :: *;
import Ehr :: *;
import CSR :: *;

import Vector :: *;

interface LoadQ;
  method ActionValue#(LqIndex) enq(LoadQueueEntry entry);

  method Action deq;

  method ActionValue#(LoadWakeup) wakeupAddr(LqIndex index, Bit#(32) addr);

  method Maybe#(RobIndex) search(Bit#(32) addr);

  method Tuple2#(RobIndex, ExecOutput)
    issue(LqIndex index, AXI4_Lite_RResponse#(4) resp);
endinterface

(* synthesize *)
module mkLoadQ(LoadQ);
  Vector#(LqSize, Reg#(LoadQueueEntry)) entries <- replicateM(mkReg(?));
  PReg#(2, Bit#(LqSize)) valid <- mkPReg(0);
  Reg#(LqIndex) head <- mkPReg0(0);
  Reg#(LqIndex) tail <- mkPReg0(0);

  Vector#(LqSize, Reg#(Bit#(32))) addresses <- replicateM(mkPReg0(?));
  PReg#(2, Bit#(LqSize)) addrValid <- mkPReg(0);

  Bit#(LqSize) rdy = addrValid[0] & valid[0];

  function LqIndex next(LqIndex index);
    return index == fromInteger(valueOf(LqSize)-1) ? 0 : index+1;
  endfunction

  method ActionValue#(LqIndex) enq(LoadQueueEntry entry)
    if (valid[1][tail] == 0);
    addrValid[1][tail] <= 0;
    entries[tail] <= entry;
    valid[1][tail] <= 1;
    tail <= next(tail);
    return tail;
  endmethod

  method ActionValue#(LoadWakeup) wakeupAddr(LqIndex index, Bit#(32) addr);
    let entry = entries[index];
    addresses[index] <= addr;

    Bool aligned = case (entry.size) matches
      Word : addr[1:0] == 0;
      Half : addr[0] == 0;
      Byte : True;
    endcase;

    if (aligned) begin
      addrValid[0][index] <= 1;

      return tagged Success (AXI4_Lite_RRequest{
          addr: {addr[31:2], 2'b00}
      });
    end else begin
      return tagged Failure {
          index: entry.index,
          result:tagged Error{
            cause: LOAD_ADDRESS_MISALIGNED,
            tval: addr
          }
      };
    end
  endmethod

  method Action deq() if (valid[0][head] == 1);
    action
      valid[0][head] <= 0;
      head <= next(head);
    endaction
  endmethod

  method Maybe#(RobIndex) search(Bit#(32) addr);
    Bit#(LqSize) mask = 0;

    for (Integer i=0; i < valueOf(LqSize); i = i + 1)
      if (rdy[i] == 1 && addresses[i][31:2] == addr[31:2])
        mask[i] = 1;

    return case (firstOneFrom(mask, head)) matches
      tagged Valid .idx : Valid(entries[idx].index);
      Invalid : Invalid;
    endcase;
  endmethod

  method Tuple2#(RobIndex, ExecOutput)
    issue(LqIndex index, AXI4_Lite_RResponse#(4) resp);

    Bit#(32) rd = resp.bytes >> {addresses[index][1:0], 3'b0};
    let signedness = entries[index].signedness;

    case (entries[index].size) matches
      Byte : rd = signedness == Signed ? signExtend(rd[7:0]) : zeroExtend(rd[7:0]);
      Half : rd = signedness == Signed ? signExtend(rd[15:0]) : zeroExtend(rd[15:0]);
    endcase

    return tuple2(entries[index].index, tagged Ok {
      next_pc: entries[index].pc + 4,
      flush: False,
      rd_val: rd
    });
  endmethod
endmodule


