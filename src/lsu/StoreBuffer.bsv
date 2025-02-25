import LsuTypes :: *;
import GetPut :: *;
import Utils :: *;
import OOO :: *;
import Ehr :: *;

import Vector :: *;

/* deq,search,empty < enq */
interface STB;
  method Action enq(StbEntry entry);
  method StoreConflict search(Bit#(32) addr);
  method Action deq;
  method Bool empty;
endinterface

(* synthesize *)
module mkSTB(STB);
  Vector#(StbSize, Reg#(Bit#(32))) addrV <- replicateM(mkEhr0(?));
  Vector#(StbSize, Reg#(Bit#(32))) dataV <- replicateM(mkEhr0(?));
  Vector#(StbSize, Reg#(Bit#(4))) maskV <- replicateM(mkEhr0(?));
  Ehr#(2, Bit#(StbSize)) valid <- mkEhr(0);
  Reg#(StbIndex) head <- mkEhr0(0);
  Reg#(StbIndex) tail <- mkEhr0(0);

  function StbIndex next(StbIndex index);
    return index == fromInteger(valueOf(StbSize)-1) ? 0 : index+1;
  endfunction

  method Action enq(StbEntry entry)
    if (valid[1][tail] == 0);
    action
      addrV[tail] <= entry.addr;
      dataV[tail] <= entry.data;
      maskV[tail] <= entry.mask;
      valid[1][tail] <= 1;
      tail <= next(tail);
    endaction
  endmethod

  method StoreConflict search(Bit#(32) addr);
    Bit#(StbSize) found = ?;

    for (Integer i=0; i < valueOf(StbSize); i = i + 1) begin
      found[i] = (valid[1][i] == 1 && addrV[i] == addr) ? 1 : 0;
    end

    return case (lastOneFrom(found, head)) matches
      tagged Valid .idx :
        StoreConflict{found: True, data: dataV[idx], mask: maskV[idx]};
      Invalid : StoreConflict{found: False, data:?,mask:0};
    endcase;
  endmethod

  method Action deq() if (valid[0][head] == 1);
    action
      valid[0][head] <= 0;
      head <= next(head);
    endaction
  endmethod

  method Bool empty;
    return valid[0] == 0;
  endmethod
endmodule

