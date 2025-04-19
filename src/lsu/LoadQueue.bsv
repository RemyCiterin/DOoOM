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

  method ActionValue#(Maybe#(ExecOutput)) wakeupAddr(LqIndex index, Bit#(32) addr);

  method LoadIssue tryIssue();
  method Action issue;

  // Search in the load queue if an element match an address
  method Maybe#(RobIndex) search(Bit#(32) addr);

  // Finish the execution of a load and compute it's result
  method ExecOutput finish(LqIndex index, AXI4_Lite_RResponse#(4) resp);
endinterface

/*** (issue,search) < deq < wakeup < enq ***/
(* synthesize *)
module mkLoadQ(LoadQ);
  Vector#(LqSize, Reg#(LoadQueueEntry)) entries <- replicateM(mkReg(?));
  Ehr#(2, Bit#(LqSize)) valid <- mkEhr(0);
  Reg#(LqIndex) head <- mkReg(0);
  Reg#(LqIndex) tail <- mkReg(0);

  Vector#(LqSize, Reg#(Bit#(32))) addresses <- replicateM(mkReg(?));

  // An address is valid if it is
  // 1. already wakeup from the issue queue
  // 2. corectly aligned
  Ehr#(2, Bit#(LqSize)) addrValid <- mkEhr(0);

  Ehr#(2, Bit#(LqSize)) executed <- mkEhr(0);
  Bit#(LqSize) rdy = addrValid[0] & valid[0] & ~executed[0];

  // Forward the oldest ready index to the issue stage
  RWire#(LqIndex) issueIndex <- mkRWire;

  rule findIssue if (firstOneFrom(rdy,head) matches tagged Valid .idx);
    issueIndex.wset(idx);
  endrule

  function LqIndex next(LqIndex index);
    return index == fromInteger(valueOf(LqSize)-1) ? 0 : index+1;
  endfunction

  //rule loadQready if (rdy != 0);
  //  $display("load queue ready");
  //endrule

  method ActionValue#(LqIndex) enq(LoadQueueEntry entry)
    if (valid[1][tail] == 0);
    addrValid[1][tail] <= 0;
    entries[tail] <= entry;
    valid[1][tail] <= 1;
    tail <= next(tail);
    return tail;
  endmethod

  method ActionValue#(Maybe#(ExecOutput)) wakeupAddr(LqIndex index, Bit#(32) addr);
    let entry = entries[index];
    addresses[index] <= addr;

    Bool aligned = case (entry.size) matches
      Word : addr[1:0] == 0;
      Half : addr[0] == 0;
      Byte : True;
    endcase;

    if (aligned) begin
      addrValid[0][index] <= 1;
      return Invalid;
    end else begin
      return Valid(ExecOutput{
          pdst: entry.pdst,
          index: entry.index,
          result:tagged Error{
            cause: LOAD_ADDRESS_MISALIGNED,
            tval: addr
          }
      });
    end
  endmethod

  method LoadIssue tryIssue if (issueIndex.wget matches tagged Valid .index);
    let entry = entries[index];
    let addr = addresses[index];

    return LoadIssue{
      lindex: index,
      age: entry.age,
      epoch: entry.epoch,
      request: AXI4_Lite_RRequest{
        addr: {addr[31:2], 2'b00}
      }
    };
  endmethod

  method Action issue if (issueIndex.wget matches tagged Valid .idx);
    action
      executed[1][idx] <= 1;
      //$display("execute load");
    endaction
  endmethod

  method Action deq() if (valid[0][head] == 1);
    action
      executed[0][head] <= 0;
      valid[0][head] <= 0;
      head <= next(head);
    endaction
  endmethod

  method Maybe#(RobIndex) search(Bit#(32) addr);
    Bit#(LqSize) mask = 0;

    for (Integer i=0; i < valueOf(LqSize); i = i + 1)
      if (executed[0][i] == 1 && addresses[i][31:2] == addr[31:2])
        mask[i] = 1;

    return case (firstOneFrom(mask, head)) matches
      tagged Valid .idx : Valid(entries[idx].index);
      Invalid : Invalid;
    endcase;
  endmethod

  method ExecOutput finish(LqIndex index, AXI4_Lite_RResponse#(4) resp);
    Bit#(32) rd = resp.bytes >> {addresses[index][1:0], 3'b0};
    let signedness = entries[index].signedness;

    case (entries[index].size) matches
      Byte : rd = signedness == Signed ? signExtend(rd[7:0]) : zeroExtend(rd[7:0]);
      Half : rd = signedness == Signed ? signExtend(rd[15:0]) : zeroExtend(rd[15:0]);
    endcase

    return ExecOutput{
      pdst: entries[index].pdst,
      index: entries[index].index,
      result: tagged Ok {
        next_pc: entries[index].pc + 4,
        fflags: Invalid,
        flush: False,
        rd_val: rd
      }};
  endmethod
endmodule
