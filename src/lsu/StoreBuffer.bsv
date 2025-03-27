import LsuTypes :: *;
import GetPut :: *;
import Utils :: *;
import OOO :: *;
import Ehr :: *;

import Vector :: *;

interface STB;
  method Action enq(StbEntry entry);
  method StoreConflict search(Bit#(32) addr);
  method Action deq;
  method Bool empty;
endinterface

/*** deq < empty < enq < search ***/
(* synthesize *)
module mkSTB(STB);
  Vector#(StbSize, Ehr#(2, Bit#(32))) addrV <- replicateM(mkEhr(?));
  Vector#(StbSize, Ehr#(2, Bit#(32))) dataV <- replicateM(mkEhr(?));
  Vector#(StbSize, Ehr#(2, Bit#(4))) maskV <- replicateM(mkEhr(?));
  Ehr#(3, Bit#(StbSize)) valid <- mkEhr(0);
  Ehr#(2, StbIndex) head <- mkEhr(0);
  Ehr#(2, StbIndex) tail <- mkEhr(0);

  function StbIndex next(StbIndex index);
    return index == fromInteger(valueOf(StbSize)-1) ? 0 : index+1;
  endfunction

  method Action enq(StbEntry entry)
    if (valid[1][tail[0]] == 0);
    action
      addrV[tail[0]][0] <= entry.addr;
      dataV[tail[0]][0] <= entry.data;
      maskV[tail[0]][0] <= entry.mask;
      valid[1][tail[0]] <= 1;
      tail[0] <= next(tail[0]);
    endaction
  endmethod

  method StoreConflict search(Bit#(32) addr);
    Bit#(StbSize) found = ?;

    for (Integer i=0; i < valueOf(StbSize); i = i + 1) begin
      found[i] = (valid[2][i] == 1 && addrV[i][1] == addr) ? 1 : 0;
    end

    return case (lastOneFrom(found, head[1])) matches
      tagged Valid .idx :
        StoreConflict{found: True, data: dataV[idx][1], mask: maskV[idx][1]};
      Invalid : StoreConflict{found: False, data:?,mask:0};
    endcase;
  endmethod

  method Action deq() if (valid[0][head[0]] == 1);
    action
      valid[0][head[0]] <= 0;
      head[0] <= next(head[0]);
    endaction
  endmethod

  method Bool empty;
    return valid[1] == 0;
  endmethod
endmodule

