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

interface BramVec#(type addrT, numeric type n, type dataT);
  method Action write(addrT addr, Vector#(n, dataT) data, Bit#(n) mask);
  method Action read(addrT addr);
    method Vector#(n, dataT) response;
  method Bool canDeq;
  method Action deq;
endinterface

module mkSizedBramVec#(Integer size) (BramVec#(addrT, n, dataT))
  provisos (Bits#(addrT, addrWidth), Eq#(addrT), Bits#(dataT, dataW));
  Vector#(n, BRAM_DUAL_PORT#(addrT, dataT)) bram <-
    replicateM(mkBRAMCore2(size, False));

  FIFOF#(Tuple2#(Vector#(n, dataT), Bit#(n))) rsp <- mkPipelineFIFOF;

  // currentData and currentAddr contain the arguments of the last write
  RWire#(addrT) currentWrAddr <- mkRWire;
  RWire#(Bit#(n)) currentWrMask <- mkRWire;
  RWire#(Vector#(n, dataT)) currentWrData <- mkRWire;
  let wrAddr = fromMaybe(?, currentWrAddr.wget);
  let wrData = fromMaybe(?, currentWrData.wget);
  let wrMask = fromMaybe(?, currentWrMask.wget);
  let wrValid = isJust(currentWrAddr.wget);

  RWire#(addrT) currentRdAddr <- mkRWire;
  let rdAddr = fromMaybe(?, currentRdAddr.wget);
  let rdValid = isJust(currentRdAddr.wget);

  (* no_implicit_conditions, fire_when_enabled *)
  rule block_ram_apply_write if (wrValid);
    for (Integer i=0; i < valueOf(n); i = i + 1) if (wrMask[i] == 1) begin
      bram[i].a.put(True, wrAddr, wrData[i]);
    end
  endrule

  (* fire_when_enabled *)
  rule block_ram_apply_read if (rdValid && rsp.notFull());
    let data = tuple2(wrData, wrValid && wrAddr == rdAddr ? wrMask : 0);

    for (Integer i=0; i < valueOf(n); i = i + 1) begin
      bram[i].b.put(False, rdAddr, ?);
    end

    rsp.enq(data);
  endrule

  method Action write(addrT addr, Vector#(n, dataT) data, Bit#(n) mask);
    currentWrAddr.wset(addr);
    currentWrData.wset(data);
    currentWrMask.wset(mask);
  endmethod

  method Action read(addrT addr) if (rsp.notFull());
    currentRdAddr.wset(addr);
  endmethod

  method Vector#(n, dataT) response if (rsp.notEmpty);
    match {.data, .mask} = rsp.first;
    Vector#(n, dataT) ret = data;

    for (Integer i=0; i < valueOf(n); i = i + 1) begin
      if (mask[i] == 0) ret[i] = bram[i].b.read;
    end

    return ret;
  endmethod

  method canDeq = rsp.notEmpty;

  method deq = rsp.deq;
endmodule

module mkBramVec(BramVec#(addrT, n, dataT))
  provisos (Bits#(addrT, addrWidth), Eq#(addrT), Bits#(dataT, dataW));
  let ifc <- mkSizedBramVec(valueOf(TExp#(addrWidth)));
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
  BramVec#(addrT, dataW, Bit#(8)) bram <- mkSizedBramVec(size);

  method canDeq = bram.canDeq;
  method response = pack(bram.response);
  method read = bram.read;
  method deq = bram.deq;

  method Action write(addrT addr, Byte#(dataW) data, Bit#(dataW) mask);
    action
      bram.write(addr, unpack(data), mask);
    endaction
  endmethod
endmodule

module mkBramBE(BramBE#(addrT, dataW))
  provisos (Bits#(addrT, addrWidth), Eq#(addrT));
  let ifc <- mkSizedBramBE(valueOf(TExp#(addrWidth)));
  return ifc;
endmodule

// Return a vector of BlockRam using a uniq Block of RAM
module mkVectorBram#(Bram#(addrT, dataT) bram) (Vector#(n, Bram#(addrT, dataT)));
  Ehr#(2, Bit#(TLog#(n))) ehr <- mkEhr(?);

  Vector#(n, Bram#(addrT, dataT)) ret = newVector;

  for (Integer i=0; i < valueOf(n); i = i + 1) begin
    ret[i] = interface Bram;
      method Action read(addrT addr);
        action
          ehr[1] <= fromInteger(i);
          bram.read(addr);
        endaction
      endmethod

      method dataT response() if (ehr[0] == fromInteger(i));
        return bram.response();
      endmethod

      method Action deq() if (ehr[0] == fromInteger(i));
        bram.deq();
      endmethod

      method canDeq = ehr[0] == fromInteger(i) && bram.canDeq();

      method write = bram.write;
    endinterface;
  end

  return ret;
endmodule

// Return a vector of BlockRam using a uniq Block of RAM
module mkVectorBramBE#(BramBE#(addrT, dataW) bram) (Vector#(n, BramBE#(addrT, dataW)));
  Ehr#(2, Bit#(TLog#(n))) ehr <- mkEhr(?);

  Vector#(n, BramBE#(addrT, dataW)) ret = newVector;

  for (Integer i=0; i < valueOf(n); i = i + 1) begin
    ret[i] = interface BramBE;
      method Action read(addrT addr);
        action
          ehr[1] <= fromInteger(i);
          bram.read(addr);
        endaction
      endmethod

      method Byte#(dataW) response() if (ehr[0] == fromInteger(i));
        return bram.response();
      endmethod

      method canDeq = ehr[0] == fromInteger(i) && bram.canDeq();

      method Action deq() if (ehr[0] == fromInteger(i));
        bram.deq();
      endmethod

      method write = bram.write;
    endinterface;
  end

  return ret;
endmodule
