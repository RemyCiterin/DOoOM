/*

This ile define a cache coherency inspired by TileLink and using MSI

+-------------------+--------------+--------------------+
| Channel (sens)    | Message      | Response           |
+-------------------+--------------+--------------------+
| ChannelA (M -> S) | Acquire      | Grant or GrantData |
+-------------------+--------------+--------------------+
| ChannelB (S -> M) | Probe        | ProbeAck           |
+-------------------+--------------+--------------------+
| ChannelC (M -> S) | ProbeAck     |                    |
|                   | ReleaseData  | ReleaseAck         |
+-------------------+--------------+--------------------+
| ChannelD (S -> M) | Grant        | GrantAck           |
|                   | GrantData    | GrantAck           |
|                   | ReleaseAck   |                    |
+-------------------+--------------+--------------------+
| ChannelE (M -> S) | GrantAck     |                    |
+-------------------+--------------+--------------------+

*/

import AXI4 :: *;
import MemoryTypes :: *;
import BlockRam :: *;
import Utils :: *;
import Fifo :: *;
import Ehr :: *;

import Array :: *;
import Vector :: *;
import GetPut :: *;
import RegFile :: *;
import StmtFSM :: *;
import Connectable :: *;

// setTag < {miss, hit} < request
interface TagRAM#(type indexT, type tagT, type wayT);
  /* Read port: stage 1 */
  method Action request(indexT index);

  /* Read port: stage 2*/
  method Action setTag(tagT tag);

  method ActionValue#(wayT) miss;

  method ActionValue#(wayT) hit;

  /* Write port */
  method Action write(indexT index, wayT way, Maybe#(tagT) tag);
endinterface

module mkTagRAM(TagRAM#(Bit#(indexW), Bit#(tagW), Bit#(wayW)));
  Vector#(TExp#(wayW), RWBram#(Bit#(indexW), Maybe#(Bit#(tagW)))) tagRAM <-
    replicateM(mkRWBram);

  Reg#(Bit#(indexW)) initIndex <- mkReg(0);
  Reg#(Bool) isStarted <- mkReg(False);

  Ehr#(2, Maybe#(Bit#(tagW))) tagReq <- mkEhr(Invalid);

  Reg#(Bit#(wayW)) random <- mkReg(0);

  Integer ways = valueof(TExp#(wayW));

  function Bit#(TExp#(wayW)) valid;
    Bit#(TExp#(wayW)) result = 0;

    for (Integer i=0; i < ways; i = i + 1) begin
      result[i] = isJust(tagRAM[i].response) ? 1 : 0;
    end

    return result;
  endfunction

  function Bit#(wayW) missWay(Bit#(tagW) tag);
    Maybe#(Bit#(wayW)) result = Invalid;
    for (Integer i=0; i < ways; i = i + 1) begin
      if (tagRAM[i].response() == Invalid)
        result = Valid(fromInteger(i));
    end

    return case (result) matches
      tagged Valid .way : way;
      Invalid : random;
    endcase;
  endfunction

  function Maybe#(Bit#(wayW)) hitWay(Bit#(tagW) tag);
    Maybe#(Bit#(wayW)) result = Invalid;
    for (Integer i=0; i < ways; i = i + 1) begin
      if (tagRAM[i].response() == Valid(tag))
        result = Valid(fromInteger(i));
    end

    return result;
  endfunction

  function Action deq();
    action
      for (Integer i=0; i < ways; i = i + 1) begin
        tagRAM[i].deq();
      end
    endaction
  endfunction

  rule add_one_cycle;
    random <= random + 1;
  endrule

  rule init if (!isStarted);
    for (Integer i=0; i < ways; i = i + 1) begin
      tagRAM[i].write(initIndex, Invalid);
    end

    if (initIndex + 1 == 0) isStarted <= True;
    initIndex <= initIndex + 1;
  endrule

  method Action request(Bit#(indexW) index) if (isStarted);
    action
      for (Integer i=0; i < ways; i = i + 1) begin
        tagRAM[i].read(index);
      end
    endaction
  endmethod

  method Action setTag(Bit#(tagW) tag) if (tagReq[0] matches Invalid);
    action
      tagReq[0] <= Valid(tag);
    endaction
  endmethod

  method ActionValue#(Bit#(wayW)) miss
    if (tagReq[1] matches tagged Valid .tag &&& hitWay(tag) matches Invalid);
    actionvalue
      let index = firstOne(~valid);
      deq();

      return missWay(tag);
    endactionvalue
  endmethod

  method ActionValue#(Bit#(wayW)) hit
    if (tagReq[1] matches tagged Valid .tag
    &&& hitWay(tag) matches tagged Valid .way);
    actionvalue
      deq();
      return way;
    endactionvalue
  endmethod

  method Action write(Bit#(indexW) index, Bit#(wayW) way, Maybe#(Bit#(tagW)) tag)
    if (isStarted);
    action
      tagRAM[way].write(index, tag);
    endaction
  endmethod
endmodule

// Function for manipulating Byte Lanes, they allow to construct message and
// parse them respecting the alignment conditions of TileLink

// Given a byte lane and the address of the byte 0 of the data, return the given
// data
function Byte#(size) getData(Bit#(a) address, Byte#(w) lane);
  // offset of the data in the byte lane (w must be a power of two)
  Bit#(a) offset = address & fromInteger(valueOf(w)-1);
  return (lane >> (offset << 3))[valueOf(size)*8-1:0];
endfunction

function Byte#(w) getLane(Bit#(a) address, Byte#(size) data)
  provisos(Add#(__something, TMul#(8, size), TMul#(8, w)));
  // offset of the data in the byte lane (w must be a power of two)
  Bit#(a) offset = address & fromInteger(valueOf(w)-1);
  return zeroExtend(data) << (offset << 3);
endfunction

function Bit#(size) getMask(Bit#(a) address, Bit#(w) laneMask);
  // offset of the data in the byte lane (w must be a power of two)
  Bit#(a) offset = address & fromInteger(valueOf(w)-1);
  return (laneMask >> offset)[valueOf(size)-1:0];
endfunction

function Bit#(w) getLaneMask(Bit#(a) address, Bit#(size) mask)
  provisos(Add#(__something, size, w));
  // offset of the data in the byte lane (w must be a power of two)
  Bit#(a) offset = address & fromInteger(valueOf(w)-1);
  return zeroExtend(mask) << offset;
endfunction

typedef enum {
  M, S, I
} Perms deriving(Bits, Eq, FShow);

// Infer the mask of a continuous set of data
function Bit#(w) inferMask(Bit#(a) min_address, Bit#(s) size);
  Bit#(a) min_offset = min_address & (fromInteger(valueOf(w) - 1));
  Bit#(a) max_offset = min_offset + (1 << size) - 1;

  Bit#(w) mask;
  for (Integer i=0; i < valueOf(w); i = i + 1) begin
    mask[i] = min_offset <= fromInteger(i) && fromInteger(i) <= max_offset ? 1 : 0;
  end

  return mask;
endfunction

// Request to acquire a new cache line
typedef struct {
  Perms from; // initial permission
  Perms to;   // requested permission
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
} Acquire#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Heavy version of the channel A
typedef union tagged {
  Acquire#(o, s, a, w) Acquire;
} ChannelA#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Perms perm; // restrict the premission to a given value
  Bit#(o) source;
  Bit#(s) size;
  Bit#(a) address;
} Probe#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Channel B definition
typedef union tagged {
  Probe#(o, s, a, w) Probe;
} ChannelB#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bool error;
} ProbeAck#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Byte#(w) data;
  Bool error;
} ReleaseData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef union tagged {
  ProbeAck#(o, s, a, w) ProbeAck;
  ReleaseData#(o, s, a, w) ReleaseData;
} ChannelC#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(i) sink;
} Grant#(numeric type i, numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(i) sink;
  Byte#(w) data;
  Bool error;
} GrantData#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bool error;
} ReleaseAck#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef union tagged {
  Grant#(i, o, s, a, w) Grant;
  GrantData#(i, o, s, a, w) GrantData;
  ReleaseAck#(i, o, s, a, w) ReleaseAck;
} ChannelD#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(i) sink;
} GrantAck#(numeric type i)
deriving(Bits, FShow, Eq);

typedef union tagged {
  GrantAck#(i) GrantAck;
} ChannelE#(numeric type i)
deriving(Bits, FShow, Eq);


// TileLink master interface
interface Master#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w);
  interface FifoO#(ChannelA#(o, s, a, w)) channelA;
  interface FifoI#(ChannelB#(o, s, a, w)) channelB;
  interface FifoO#(ChannelC#(o, s, a, w)) channelC;
  interface FifoI#(ChannelD#(i, o, s, a, w)) channelD;
  interface FifoO#(ChannelE#(i)) channelE;
endinterface

// TileLink slave interface
interface Slave#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w);
  interface FifoI#(ChannelA#(o, s, a, w)) channelA;
  interface FifoO#(ChannelB#(o, s, a, w)) channelB;
  interface FifoI#(ChannelC#(o, s, a, w)) channelC;
  interface FifoO#(ChannelD#(i, o, s, a, w)) channelD;
  interface FifoI#(ChannelE#(i)) channelE;
endinterface

// Return a pair (Master, Slave) using pipeline fifos of size 1
module mkMasterSlave(Tuple2#(Master#(i,o,s,a,w), Slave#(i,o,s,a,w)));
  Fifo#(1, ChannelA#(o,s,a,w)) chA <- mkPipelineFifo;
  Fifo#(1, ChannelB#(o,s,a,w)) chB <- mkPipelineFifo;
  Fifo#(1, ChannelC#(o,s,a,w)) chC <- mkPipelineFifo;
  Fifo#(1, ChannelD#(i,o,s,a,w)) chD <- mkPipelineFifo;
  Fifo#(1, ChannelE#(i)) chE <- mkPipelineFifo;

  let master = (interface Master;
    method channelA = toFifoO(chA);
    method channelB = toFifoI(chB);
    method channelC = toFifoO(chC);
    method channelD = toFifoI(chD);
    method channelE = toFifoO(chE);
  endinterface);

  let slave = (interface Slave;
    method channelA = toFifoI(chA);
    method channelB = toFifoO(chB);
    method channelC = toFifoI(chC);
    method channelD = toFifoO(chD);
    method channelE = toFifoI(chE);
  endinterface);

  return tuple2(master, slave);
endmodule


/* A snoop controller interface a memory system (using AXI4) with a cache
set of caches (using my protocol) and use a snoop approach (for each acquire
request we start by an invalidation request to all the caches) */
interface SnoopController
  #(numeric type i, numeric type o, numeric type s, numeric type a, numeric type w);

  interface Slave#(i, o, s, a, w) slaveTL;

  // interface to memory
  interface WrAXI4_Master#(o, a, w) wrAXI4;
  interface RdAXI4_Master#(o, a, w) rdAXI4;
endinterface


typedef struct {
  Bool valid;
  Acquire#(o, s, a, w) request;    // Acquire request
  Bit#(TAdd#(1, o)) invalidations; // Number of response to the invalidation
} SnoopState#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

instance DefaultValue#(SnoopState#(o,s,a,w));
  function defaultValue;
    return SnoopState{valid: False, request: ?, invalidations: 0};
  endfunction
endinstance

typedef Bit#(4) AcquireIndex;

// mkSnoopController(sinkID, sources)
// return a snoop controller with a given ID and an array of sources
module mkSnoopController
  #(Bit#(sinkW) index, Array#(Bit#(sourceW)) sources)
  (SnoopController#(sinkW, sourceW, sizeW, addrW, wordW));
  match {.master, .slave} <- mkMasterSlave;

  Fifo#(1, AXI4_AWRequest#(sourceW, addrW)) axi4AWRequest <- mkPipelineFifo;
  Fifo#(1, AXI4_WResponse#(sourceW)) axi4WResponse <- mkPipelineFifo;
  Fifo#(1, AXI4_WRequest#(wordW)) axi4WRequest <- mkPipelineFifo;

  Fifo#(1, AXI4_RRequest#(sourceW, addrW)) axi4RRequest <- mkPipelineFifo;
  Fifo#(1, AXI4_RResponse#(sourceW, wordW)) axi4RResponse <- mkPipelineFifo;

  // Expected order of the ProbeAck and GrantAck messages
  Array#(Fifo#(4, AcquireIndex)) probeOrder;
  Array#(Fifo#(4, AcquireIndex)) grantOrder;

  for (Integer i=0; i < arrayLength(sources); i = i + 1) begin
    probeOrder[i] <- mkPipelineFifo;
    grantOrder[i] <- mkPipelineFifo;
  end

  RegFile#(AcquireIndex, SnoopState#(sourceW, sizeW, addrW, wordW))
    states <- mkRegFileFullInit(defaultValue);

  function AcquireIndex getAcquireIndex(Bit#(addrW) address);
    return address[valueOf(TExp#(sizeW)) + 3:valueOf(TExp#(sizeW))];
  endfunction

  rule receiveAcquire
    if (master.channelA.first matches tagged Acquire .acquire &&&
    !states.sub(getAcquireIndex(acquire.address)).valid);

    let index = getAcquireIndex(acquire.address);

    states.upd(index, SnoopState{
      invalidations: 0,
      request: acquire,
      valid: True
    });
  endrule

  interface slaveTL = slave;

  interface WrAXI4_Master wrAXI4;
    interface awrequest = toGet(axi4AWRequest);
    interface response = toPut(axi4WResponse);
    interface wrequest = toGet(axi4WRequest);
  endinterface

  interface RdAXI4_Master rdAXI4;
    interface response = toPut(axi4RResponse);
    interface request = toGet(axi4RRequest);
  endinterface
endmodule
