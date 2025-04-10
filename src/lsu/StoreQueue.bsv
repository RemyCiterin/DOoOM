import LsuTypes :: *;
import Utils :: *;
import Fifo :: *;
import OOO :: *;
import Ehr :: *;
import CSR :: *;

import Vector :: *;


/* search,deq,wakeup < enq */
interface StoreQ;
  // search the youngest store `s` such that:
  // `isBefore(s.age,age) /\ epoch == s.epoch /\ s.addr == addr`
  method StoreConflict search(Bit#(32) addr, Epoch epoch, Age age);

  // enqueue a request and it's age
  method ActionValue#(SqIndex) enq(StoreQueueEntry entry);

  // dequeue a request
  method ActionValue#(StbEntry) deq;

  // Add a new address
  method Action wakeupAddr(SqIndex index, Bit#(32) addr);

  // Add a new data
  method Action wakeupData(SqIndex index, Bit#(32) data);

  // issue and return the result of the execution of the store
  // to the CPU: check address alignment
  method ActionValue#(ExecOutput) issue;
endinterface

/*** issue < deq < search < wakeup < enq ***/
(* synthesize *)
module mkStoreQ(StoreQ);
  Vector#(SqSize, Reg#(StoreQueueEntry)) entries <- replicateM(mkReg(?));

  Ehr#(2, Bit#(SqSize)) toIssue <- mkEhr(0);
  Ehr#(2, Bit#(SqSize)) valid <- mkEhr(0);
  Ehr#(2, SqIndex) head <- mkEhr(0);
  Reg#(SqIndex) tail <- mkReg(0);

  Vector#(SqSize, Reg#(Bit#(32))) addresses <- replicateM(mkReg(?));
  Vector#(SqSize, Reg#(Bit#(32))) datas <- replicateM(mkReg(?));
  Ehr#(2, Bit#(SqSize)) addrValid <- mkEhr(0);
  Ehr#(2, Bit#(SqSize)) dataValid <- mkEhr(0);

  Bit#(SqSize) rdy = toIssue[0] & addrValid[0] & valid[0] & dataValid[0];

  function SqIndex next(SqIndex index);
    return index == fromInteger(valueOf(SqSize)-1) ? 0 : index+1;
  endfunction

  method StoreConflict search(Bit#(32) addr, Epoch epoch, Age age);
    Bit#(SqSize) mask = 0;

    for (Integer i=0; i < valueOf(SqSize); i = i + 1) begin
      let entry = entries[i];

      if (valid[1][i] == 1 && addrValid[0][i] == 1 && addr[31:2] == addresses[i][31:2] &&
        entry.epoch == epoch && isBefore(entry.age, age))
        mask[i] = 1;
    end

    return case (lastOneFrom(mask, head[1])) matches
      tagged Valid .idx : StoreConflict{found: True,mask:0,data:?};
      Invalid : StoreConflict{found: False,mask:0,data:?};
    endcase;
  endmethod

  method ActionValue#(SqIndex) enq(StoreQueueEntry entry)
    if (valid[1][tail] == 0);
    addrValid[1][tail] <= 0;
    dataValid[1][tail] <= 0;
    entries[tail] <= entry;
    toIssue[1][tail] <= 1;
    valid[1][tail] <= 1;
    tail <= next(tail);
    return tail;
  endmethod

  method Action wakeupAddr(SqIndex index, Bit#(32) addr);
    action
      addrValid[0][index] <= 1;
      addresses[index] <= addr;
    endaction
  endmethod

  method Action wakeupData(SqIndex index, Bit#(32) data);
    action
      dataValid[0][index] <= 1;
      datas[index] <= data;
    endaction
  endmethod

  method ActionValue#(StbEntry) deq()
    if (valid[0][head[0]] == 1);
    let addr = addresses[head[0]];
    let entry = entries[head[0]];
    let data = datas[head[0]];
    valid[0][head[0]] <= 0;
    head[0] <= next(head[0]);

    let mask = case (entry.size) matches
      Word : 4'b1111;
      Half : 4'b0011;
      Byte : 4'b0001;
    endcase;

    return StbEntry{
      data: data << {addr[1:0],3'b0},
      addr: {addr[31:2], 2'b0},
      mask: mask << addr[1:0]
    };
  endmethod

  method ActionValue#(ExecOutput) issue()
    if (firstOneFrom(rdy, 0) matches tagged Valid .idx);
    let addr = addresses[idx];
    let entry = entries[idx];
    toIssue[0][idx] <= 0;

    let aligned = case (entry.size) matches
      Word : addr[1:0] == 0;
      Half : addr[0] == 0;
      Byte : True;
    endcase;

    if (aligned) begin
      return ExecOutput{
        pdst: entry.pdst,
        index: entry.index,
        result: tagged Ok {
          next_pc: entry.pc + 4,
          fflags: Invalid,
          flush: False,
          rd_val: ?
      }};
    end else begin
      return ExecOutput{
        pdst: entry.pdst,
        index: entry.index,
        result: tagged Error {
          cause: STORE_AMO_ADDRESS_MISALIGNED,
          tval: addr
      }};
    end
  endmethod
endmodule

