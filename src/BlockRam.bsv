import FIFOF :: *;
import SpecialFIFOs :: *;
import BypassReg :: *;
import BRAMCore :: *;
import Vector :: *;

import Ehr :: *;


interface RWBram#(type addrT, type dataT);
  method Action write(addrT addr, dataT data);
  method Action read(addrT addr);
  method dataT response;
  method Bool canDeq;
  method Action deq;
endinterface

//    // A module for implenting Block RAM with one read port and one write port,
//    // the resulting RAM block has three main functions : `read` to add a read request
//    // (only one at a time), `write` to write into the RAM, and `response` to see the
//    // result of the read request. This module use bypassing: when we use `response`
//    // it use all the write to compute the value, including the write from the cycle
//    // of the read request to the write of the last cycle.
//    module mkRWBramOfSize#(Integer size) (RWBram#(addrT, dataT))
//      provisos (Bits#(addrT, addrWidth), Bits#(dataT, dataWidth), Eq#(addrT));
//      BRAM_DUAL_PORT#(addrT, dataT) bram <- mkBRAMCore2(size, False);
//      let wrPort = bram.a;
//      let rdPort = bram.b;
//
//      FIFOF#(void) rsp <- mkPipelineFIFOF;
//
//      // currentData and currentAddr contain the arguments of the last write
//      RWire#(dataT) currentWrData <- mkRWire;
//      RWire#(addrT) currentWrAddr <- mkRWire;
//      let wrAddr = fromMaybe(?, currentWrAddr.wget);
//      let wrData = fromMaybe(?, currentWrData.wget);
//      let wrValid = isJust(currentWrAddr.wget);
//
//      // Address of the current read
//      Ehr#(2, addrT) currentRdAddr <- mkEhr(?);
//
//      // Bypassed data
//      Ehr#(2, Maybe#(dataT)) currentRdData <- mkEhr(Invalid);
//
//      (* no_implicit_conditions, fire_when_enabled *)
//      rule apply_write if (wrValid);
//        wrPort.put(True, wrAddr, wrData);
//      endrule
//
//      (* fire_when_enabled, no_implicit_conditions *)
//      rule bypass_read;
//        currentRdData[1] <=
//          wrValid && wrAddr == currentRdAddr[1] ? Valid(wrData) : currentRdData[1];
//      endrule
//
//      method Action write(addrT addr, dataT data);
//        currentWrAddr.wset(addr);
//        currentWrData.wset(data);
//      endmethod
//
//      method Action read(addrT addr) if (rsp.notFull());
//        rdPort.put(False, addr, ?);
//        currentRdData[0] <= Invalid;
//        currentRdAddr[0] <= addr;
//        rsp.enq(?);
//      endmethod
//
//      method dataT response if (rsp.notEmpty);
//        case (currentRdData[0]) matches
//          tagged Valid .data : return data;
//          Invalid : return rdPort.read;
//        endcase
//      endmethod
//
//      method canDeq = rsp.notEmpty;
//
//      method deq = rsp.deq;
//    endmodule

module mkRWBramOfSize#(Integer size) (RWBram#(addrT, dataT))
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
  rule apply_write if (wrValid);
    wrPort.put(True, wrAddr, wrData);
  endrule

  (* fire_when_enabled *)
  rule apply_read if (rdValid && rsp.notFull());
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


module mkRWBram(RWBram#(addrT, dataT))
  provisos (Bits#(addrT, addrWidth), Bits#(dataT, dataWidth), Eq#(addrT));
  let ifc <- mkRWBramOfSize(valueOf(TExp#(addrWidth)));
  return ifc;
endmodule

// This is a wrapper on RWBram that allow to write using a mask (so it's not necessary to load
// the data first)
interface RWBit32Bram#(type addrT);
  method Action write(addrT addr, Bit#(32) data, Bit#(4) mask);
  method Action read(addrT addr);
  method Bit#(32) response;
  method Bool canDeq;
  method Action deq;
endinterface

module mkRWBit32BramOfSize#(Integer size) (RWBit32Bram#(addrT)) provisos (Bits#(addrT, addrSz), Eq#(addrT));
  Vector#(4, RWBram#(addrT, Bit#(8))) bram <- replicateM(mkRWBramOfSize(size));

  method Action write(addrT addr, Bit#(32) data, Bit#(4) mask);
    action
      if (mask[0] == 1) bram[0].write(addr, data[7:0]);
      if (mask[1] == 1) bram[1].write(addr, data[15:8]);
      if (mask[2] == 1) bram[2].write(addr, data[23:16]);
      if (mask[3] == 1) bram[3].write(addr, data[31:24]);
    endaction
  endmethod

  method Action read(addrT addr);
    action
      bram[0].read(addr);
      bram[1].read(addr);
      bram[2].read(addr);
      bram[3].read(addr);
    endaction
  endmethod

  method Bit#(32) response;
    return { bram[3].response, bram[2].response, bram[1].response, bram[0].response };
  endmethod

  method Bool canDeq;
    return bram[0].canDeq && bram[1].canDeq && bram[2].canDeq && bram[3].canDeq;
  endmethod

  method Action deq;
    bram[0].deq;
    bram[1].deq;
    bram[2].deq;
    bram[3].deq;
  endmethod
endmodule

module mkRWBit32Bram(RWBit32Bram#(addrT))
  provisos (Bits#(addrT, addrWidth), Eq#(addrT));
  let ifc <- mkRWBit32BramOfSize(valueOf(TExp#(addrWidth)));
  return ifc;
endmodule

