/*

This file define a coherency protocol based on MSI, as the protocol is MSI and
it doesn't implement forwarding it doesn't need to talk about the data but only
the addresses and the permissions. Then caches are free to send and receive data
from memory using AXI4 with their own channels when they have the permission.

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
import BuildVector :: *;
import Connectable :: *;
import DataRam :: *;

import TestBench :: *;

typedef 8 LengthW;
typedef 4 SourceW;
typedef 4 SinkW;

typedef enum {M, S, I} Perms deriving(Bits, FShow, Eq);

/* Acquire request */
typedef struct {
  Perms perms;          // requested permissions
  Bit#(a) address;      // aligned address to the begining of the cache line
  Bit#(LengthW) length; // from 1 to 256
  Bit#(SourceW) source; // Up to 16 sources to translate it to 16 possible AXI4 ids
} Acquire#(numeric type a) deriving(Bits, FShow, Eq);

typedef struct {
  Perms perms;           // restrict the premission to a given value
  Bit#(SourceW) source; // source identifier
  Bit#(LengthW) length; // length of the invalidated burst
  Bit#(a) address;      // address of the first invalidated beat
} Invalidate#(numeric type a)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(SourceW) source;
} InvalidateAck
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(SourceW) source;
  Bit#(SinkW) sink;
} Grant
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(SinkW) sink;
  Bit#(SourceW) source;
} GrantAck
deriving(Bits, FShow, Eq);

interface Master#(numeric type a);
  interface Get#(Acquire#(a)) acquire;
  interface Put#(Invalidate#(a)) invalidate;
  interface Get#(InvalidateAck) invalidateAck;
  interface Put#(Grant) grant;
  interface Get#(GrantAck) grantAck;
endinterface

interface Slave#(numeric type a);
  interface Put#(Acquire#(a)) acquire;
  interface Get#(Invalidate#(a)) invalidate;
  interface Put#(InvalidateAck) invalidateAck;
  interface Get#(Grant) grant;
  interface Put#(GrantAck) grantAck;
endinterface

typedef Bit#(4) AcquireIndex;

typedef struct {
  Acquire#(a) request;                   // initial request
  Bit#(TAdd#(SourceW, 1)) invalidations; // number of received invalidations
} SnoopState#(numeric type a)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(SourceW) source; // index in the source list
  Bit#(LengthW) length;
  Bit#(addrW) address;
  Perms perms;
} InvalidateState#(numeric type addrW)
deriving(Bits, FShow, Eq);

module mkSlave
    #(Integer lineSize, Bit#(SinkW) sinkId, Array#(Bit#(SourceW)) sources)
    (Slave#(addrW));

  RegFile#(AcquireIndex, Maybe#(SnoopState#(addrW))) states
    <- mkRegFileFullInit(Invalid);

  Fifo#(4, AcquireIndex) waitGrantAckQ[arrayLength(sources)];
  Fifo#(4, AcquireIndex) waitInvalidateAckQ[arrayLength(sources)];

  for (Integer i=0; i < arrayLength(sources); i = i + 1) begin
    waitInvalidateAckQ[i] <- mkPipelineFifo;
    waitGrantAckQ[i] <- mkPipelineFifo;
  end

  function AcquireIndex getAcquireIndex(Bit#(addrW) addr);
    return addr[3 + log(lineSize):log(lineSize)];
  endfunction

  function Integer getSourceIndex(Bit#(SourceW) source);
    Integer result = 0;

    for (Integer i=0; i < arrayLength(sources); i = i + 1) begin
      if (sources[i] == source) result = i;
    end

    return result;
  endfunction

  Fifo#(1, Acquire#(addrW)) acquireQ <- mkPipelineFifo;
  Fifo#(1, InvalidateAck) invalidateAckQ <- mkPipelineFifo;
  Fifo#(1, Grant) grantQ <- mkBypassFifo;

  Reg#(Maybe#(InvalidateState#(addrW))) invalidateState <- mkReg(Invalid);

  function Action startGrant(AcquireIndex index, Acquire#(addrW) req);
    action
      let sourceIndex = getSourceIndex(req.source);
      waitGrantAckQ[sourceIndex].enq(index);

      grantQ.enq(Grant{
        source: req.source,
        sink: sinkId
      });
    endaction
  endfunction

  rule acquireRl
    if (states.sub(getAcquireIndex(acquireQ.first.address)) == Invalid &&&
    invalidateState matches Invalid);

    states.upd(getAcquireIndex(acquireQ.first.address), Valid(SnoopState{
      request: acquireQ.first,
      invalidations: 0
    }));

    invalidateState <= Valid(InvalidateState{
      address: acquireQ.first.address,
      length: acquireQ.first.length,
      perms: acquireQ.first.perms,
      source: 0 // index 0 in "sources"
    });

    acquireQ.deq;
  endrule

  rule invalidateAckRl;
    let sourceIndex = getSourceIndex(invalidateAckQ.first.source);
    let acquireIndex = waitInvalidateAckQ[sourceIndex].first;
    waitInvalidateAckQ[sourceIndex].deq;
    invalidateAckQ.deq;

    let state = unJust(states.sub(acquireIndex));

    states.upd(acquireIndex, Valid(SnoopState{
      invalidations: state.invalidations + 1,
      request: state.request
    }));

    if (state.invalidations == fromInteger(arrayLength(sources)-1)) begin
      /* Start grant operation */
      startGrant(acquireIndex, state.request);
    end
  endrule

  interface acquire = toPut(acquireQ);
  interface invalidateAck = toPut(invalidateAckQ);
  interface grant = toGet(grantQ);

  interface Get invalidate;
    method ActionValue#(Invalidate#(addrW)) get
      if (invalidateState matches tagged Valid .st);
      actionvalue
        if (st.source == fromInteger(arrayLength(sources)-1))
          invalidateState <= Invalid;
        else
          invalidateState <= Valid(InvalidateState{
            address: st.address,
            source: st.source+1,
            length: st.length,
            perms: st.perms
          });

        waitInvalidateAckQ[sources[st.source]].enq(getAcquireIndex(st.address));

        return Invalidate{
          perms: st.perms == M ? I : S,
          address: st.address,
          length: st.length,
          source: sources[st.source]
        };
      endactionvalue
    endmethod
  endinterface

  interface Put grantAck;
    method Action put(GrantAck ack);
      action
        let sourceIndex = getSourceIndex(ack.source);
        let acquireIndex = waitGrantAckQ[sourceIndex].first;
        states.upd(acquireIndex, Invalid);
        waitGrantAckQ[sourceIndex].deq;
      endaction
    endmethod
  endinterface
endmodule


// For the moment this cache doesn't have any data, on permissions
interface Cache#(type tagT, type indexT, type offsetT);
  // Start a memory operation
  method Action start(indexT index, offsetT offset);

  // Tag matching
  method Action matching(tagT tag, Bool read, Bit#(32) data, Bit#(4) mask);

  // Acknoledge a read request
  method ActionValue#(Bit#(32)) readAck;

  interface RdAXI4_Master#(4, 32, 4) read;
  interface WrAXI4_Master#(4, 32, 4) write;
  method Action setID(Bit#(4) id);
endinterface

module mkCache(Cache#(Bit#(tagW), Bit#(indexW), Bit#(offsetW)))
  provisos(Add#(tagW, __a, 32), Add#(indexW, __b, __a));
  RWBram#(Bit#(indexW), Bit#(tagW)) tagRam <- mkRWBram;
  RWBram#(Bit#(indexW), Bool) validRam <- mkRWBram;
  RWBram#(Bit#(indexW), Bool) dirtyRam <- mkRWBram;

  DataRam#(1, 32, TAdd#(indexW, offsetW), 4) dataRam <- mkDataRam;

  Fifo#(1, Bit#(offsetW)) offsetQ <- mkPipelineFifo;
  Fifo#(1, Bit#(indexW))  indexQ <- mkPipelineFifo;
  Fifo#(1, Bool)          readQ <- mkPipelineFifo;
  Fifo#(1, Bit#(32))      dataQ <- mkPipelineFifo;
  Fifo#(1, Bit#(4))       maskQ <- mkPipelineFifo;
  Fifo#(1, Bit#(tagW))    tagQ <- mkPipelineFifo;

  // Length of a cache line
  Bit#(8) length = fromInteger(valueOf(TExp#(offsetW))-1);

  function Action doMiss(Bit#(tagW) tag, Bool read, Bit#(32) data, Bit#(4) mask);
    action
      let index = indexQ.first;
      readQ.enq(read);
      dataQ.enq(data);
      maskQ.enq(mask);
      tagQ.enq(tag);
    endaction
  endfunction

  Reg#(Bit#(indexW)) initIndex <- mkReg(0);
  Reg#(Bool) started <- mkReg(False);

  /* Initialize all the permissions in the cache */
  rule startRl if (!started);
    validRam.write(initIndex, False);

    if (initIndex+1 == 0) started <= True;
    initIndex <= initIndex + 1;
  endrule

  rule releaseLineAck;
    let tag = tagQ.first;
    let index = indexQ.first;
    dataRam.acquireLine({tag, index, 0}, {index, 0}, length);
    dataRam.releaseLineAck;
  endrule

  rule acquireLineAck;
    dataRam.acquireLineAck;

    let tag <- toGet(tagQ).get;
    let read <- toGet(readQ).get;
    let data <- toGet(dataQ).get;
    let mask <- toGet(maskQ).get;
    let index <- toGet(indexQ).get;
    let offset <- toGet(offsetQ).get;
    validRam.write(index, True);
    tagRam.write(index, tag);

    if (read) begin
      dirtyRam.write(index, False);
      dataRam.readWord({index, offset});
    end else begin
      dirtyRam.write(index, True);
      dataRam.writeWord({index, offset}, data, mask);
    end
  endrule

  method Action start(Bit#(indexW) index, Bit#(offsetW) offset) if (started);
    action
      tagRam.read(index);
      validRam.read(index);
      dirtyRam.read(index);
      offsetQ.enq(offset);
      indexQ.enq(index);
    endaction
  endmethod

  method Action matching(Bit#(tagW) t, Bool read, Bit#(32) data, Bit#(4) mask)
    if (started);
    action
      let index = indexQ.first;
      let offset = offsetQ.first;
      let tag = tagRam.response;
      let valid = validRam.response;
      let dirty = dirtyRam.response;
      dirtyRam.deq;
      validRam.deq;
      tagRam.deq;

      if (t == tag && valid) begin
        // Cache hit
        offsetQ.deq;
        indexQ.deq;

        if (read) begin
          dataRam.readWord({index, offset});
        end else begin
          dirtyRam.write(index, True);
          dataRam.writeWord({index, offset}, data, mask);
        end

      end else if (dirty && valid) begin
        // Release then acquire
        doMiss(t, read, data, mask);
        dataRam.releaseLine({tag, index, 0}, {index, 0}, length);
        $display("start release");
      end else begin
        // Acquire
        doMiss(t, read, data, mask);
        dataRam.acquireLine({t, index, 0}, {index, 0}, length);
      end
    endaction
  endmethod

  method readAck = dataRam.readWordAck;
  interface read = dataRam.read;
  interface write = dataRam.write;
  method setID = dataRam.setID;
endmodule

(* synthesize *)
module mkTestCache(Empty);
  Cache#(Bit#(20), Bit#(6), Bit#(4)) cache <- mkCache;
  AXI4_Slave#(4, 32, 4) rom <-
    mkRom(RomConfig{name: "Mem.hex", start: 'h80000000, size: 'h10000});

  Bit#(20) base = truncateLSB(32'h80000000);

  mkConnection(cache.read.request, rom.read.request);
  mkConnection(cache.read.response, rom.read.response);

  mkConnection(cache.write.wrequest, rom.write.wrequest);
  mkConnection(cache.write.awrequest, rom.write.awrequest);
  mkConnection(cache.write.response, rom.write.response);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  function Stmt read(Bit#(20) tag, Bit#(6) index, Bit#(4) offset);
    return seq
      cache.start(index, offset);
      cache.matching(tag, True, ?, ?);
    endseq;
  endfunction

  function Stmt write(Bit#(20) tag, Bit#(6) index, Bit#(4) offset, Bit#(32) data);
    return seq
      cache.start(index, offset);
      cache.matching(tag, False, data, 4'b1111);
    endseq;
  endfunction

  function Action readAck();
    action
      let x <- cache.readAck();
      $display("cycle: %d, value: %h", cycle, x);
    endaction
  endfunction

  Stmt stmt = seq
    cache.setID(0);
    $display("cycle: %d", cycle);

    read(base, 0, 0);
    par
      readAck();
      write(base, 0, 0, 'h55555555);
    endpar
    read(base+1, 0, 0);
    readAck();

  endseq;

  mkAutoFSM(stmt);

  rule countCycle;
    cycle <= cycle + 1;
  endrule

endmodule


