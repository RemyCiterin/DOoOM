import FIFOF :: *;
import SpecialFIFOs :: *;
import BypassReg :: *;
import BRAMCore :: *;
import Vector :: *;
import Utils :: *;

import Ehr :: *;


interface Bram#(type addrT, type dataT);
  method Action write(addrT addr, dataT data);
  method Action read(addrT addr);
  method dataT response;
  method Bool canDeq;
  method Action deq;
endinterface

module mkSizedBram#(Integer size) (Bram#(addrT, dataT))
  provisos (Bits#(addrT, addrWidth), Bits#(dataT, dataWidth), Eq#(addrT));
  BRAM_DUAL_PORT#(addrT, dataT) bram <- mkBRAMCore2(size, False);
  let wrPort = bram.a;
  let rdPort = bram.b;

  FIFOF#(Maybe#(dataT)) rsp <- mkPipelineFIFOF;

  // currentData and currentAddr contain the arguments of the last write
  RWire#(dataT) currentWrData <- mkRWire;
  RWire#(addrT) currentWrAddr <- mkRWire;
  let wrAddr = fromMaybe(?, currentWrAddr.wget);
  let wrData = fromMaybe(?, currentWrData.wget);
  let wrValid = isJust(currentWrAddr.wget);

  RWire#(addrT) currentRdAddr <- mkRWire;
  let rdAddr = fromMaybe(?, currentRdAddr.wget);
  let rdValid = isJust(currentRdAddr.wget);

  (* no_implicit_conditions, fire_when_enabled *)
  rule block_ram_apply_write if (wrValid);
    wrPort.put(True, wrAddr, wrData);
  endrule

  (* fire_when_enabled *)
  rule block_ram_apply_read if (rdValid && rsp.notFull());
    let data = (wrValid && wrAddr == rdAddr ? Valid(wrData) : Invalid);
    rdPort.put(False, rdAddr, ?);
    rsp.enq(data);
  endrule

  method Action write(addrT addr, dataT data);
    currentWrAddr.wset(addr);
    currentWrData.wset(data);
  endmethod

  method Action read(addrT addr) if (rsp.notFull());
    currentRdAddr.wset(addr);
  endmethod

  method dataT response if (rsp.notEmpty);
    case (rsp.first) matches
      tagged Valid .data : return data;
      tagged Invalid: return rdPort.read;
    endcase
  endmethod

  method canDeq = rsp.notEmpty;

  method deq = rsp.deq;
endmodule


module mkBram(Bram#(addrT, dataT))
  provisos (Bits#(addrT, addrWidth), Bits#(dataT, dataWidth), Eq#(addrT));
  let ifc <- mkSizedBram(valueOf(TExp#(addrWidth)));
  return ifc;
endmodule

// This is a wrapper on Bram that allow to write using a mask (so it's not necessary to load
// the data first)
interface BramBE#(type addrT, numeric type dataW);
  method Action write(addrT addr, Byte#(dataW) data, Bit#(dataW) mask);
  method Action read(addrT addr);
  method Byte#(dataW) response;
  method Bool canDeq;
  method Action deq;
endinterface

module mkSizedBramBE#(Integer size) (BramBE#(addrT, dataW))
  provisos (Bits#(addrT, addrSz), Eq#(addrT));
  Vector#(dataW, Bram#(addrT, Bit#(8))) bram <- replicateM(mkSizedBram(size));

  method Action write(addrT addr, Byte#(dataW) data, Bit#(dataW) mask);
    action
      for (Integer i=0; i < valueOf(dataW); i = i + 1) begin
        if (mask[i] == 1) bram[i].write(addr, data[8*i+7:8*i]);
      end
    endaction
  endmethod

  method Action read(addrT addr);
    action
      for (Integer i=0; i < valueOf(dataW); i = i + 1) begin
        bram[i].read(addr);
      end
    endaction
  endmethod

  method Byte#(dataW) response;
    Vector#(dataW, Bit#(8)) result;
    for (Integer i=0; i < valueOf(dataW); i = i + 1) begin
      result[i] = bram[i].response;
    end

    return pack(result);
  endmethod

  method Bool canDeq;
    Bool result = True;
    for (Integer i=0; i < valueOf(dataW); i = i + 1) begin
      result = result && bram[i].canDeq;
    end
    return result;
  endmethod

  method Action deq;
    action
      for (Integer i=0; i < valueOf(dataW); i = i + 1) begin
        bram[i].deq();
      end
    endaction
  endmethod
endmodule

module mkBramBE(BramBE#(addrT, dataW))
  provisos (Bits#(addrT, addrWidth), Eq#(addrT));
  let ifc <- mkSizedBramBE(valueOf(TExp#(addrWidth)));
  return ifc;
endmodule

typedef Tuple2#(Bram#(addrT, dataT), Bram#(addrT, dataT))
  DualBram#(type addrT, type dataT);

typedef Tuple2#(BramBE#(addrT, dataW), BramBE#(addrT, dataW))
  DualBramBE#(type addrT, numeric type dataW);

module mkSizedDualBram#(Integer size) (DualBram#(addrT, dataT))
  provisos (Bits#(addrT, addrWidth), Bits#(dataT, dataWidth), Eq#(addrT));
  let bram <- mkSizedBram(size);
  Ehr#(2, Bool) ehr <- mkEhr(False);

  return tuple2(interface Bram;
    method Action read(addrT addr);
      action
        ehr[1] <= True;
        bram.read(addr);
      endaction
    endmethod

    method Action deq() if (ehr[0]);
      bram.deq();
    endmethod

    method dataT response() if (ehr[0]);
      return bram.response();
    endmethod

    method canDeq = ehr[0] && bram.canDeq();

    method write = bram.write;
  endinterface,

  interface Bram;
    method Action read(addrT addr);
      action
        ehr[1] <= False;
        bram.read(addr);
      endaction
    endmethod

    method Action deq() if (!ehr[0]);
      bram.deq();
    endmethod

    method dataT response() if (!ehr[0]);
      return bram.response();
    endmethod

    method canDeq = !ehr[0] && bram.canDeq();

    method write = bram.write;
  endinterface);

endmodule

module mkDualBram(DualBram#(addrT, dataT))
  provisos (Bits#(addrT, addrWidth), Bits#(dataT, dataWidth), Eq#(addrT));
  let ifc <- mkSizedDualBram(valueOf(TExp#(addrWidth)));
  return ifc;
endmodule

module mkSizedDualBramBE#(Integer size) (DualBramBE#(addrT, dataW))
  provisos (Bits#(addrT, addrWidth), Eq#(addrT));
  let bram <- mkSizedBramBE(size);
  Ehr#(2, Bool) ehr <- mkEhr(False);

  return tuple2(interface BramBE;
    method Action read(addrT addr);
      action
        ehr[1] <= True;
        bram.read(addr);
      endaction
    endmethod

    method Action deq() if (ehr[0]);
      bram.deq();
    endmethod

    method Byte#(dataW) response() if (ehr[0]);
      return bram.response();
    endmethod

    method canDeq = ehr[0] && bram.canDeq();

    method write = bram.write;
  endinterface,

  interface BramBE;
    method Action read(addrT addr);
      action
        ehr[1] <= False;
        bram.read(addr);
      endaction
    endmethod

    method Action deq() if (!ehr[0]);
      bram.deq();
    endmethod

    method Byte#(dataW) response() if (!ehr[0]);
      return bram.response();
    endmethod

    method canDeq = !ehr[0] && bram.canDeq();

    method write = bram.write;
  endinterface);

endmodule


module mkDualBramBE(DualBramBE#(addrT, dataW))
  provisos (Bits#(addrT, addrWidth), Eq#(addrT));
  let ifc <- mkSizedDualBramBE(valueOf(TExp#(addrWidth)));
  return ifc;
endmodule
