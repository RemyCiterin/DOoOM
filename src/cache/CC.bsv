/*

This file define a coherency protocol based on MSI, as the protocol is MSI and
it doesn't implement forwarding it doesn't need to talk about the data but only
the addresses and the permissions. Then caches are free to send and receive data
from memory using AXI4 with their own channels when they have the permission.

*/

import AXI4 :: *;
import AXI4_Lite :: *;
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
import LinkList :: *;

// Return the index of the first one of a bit vector
function Maybe#(Integer) searchOne(Bit#(a) value);
  Maybe#(Integer) result = Invalid;

  for (Integer i=0; i < valueOf(a); i = i + 1) begin
    result = result == Invalid && value[i] == 1 ? Valid(i) : result;
  end

  return result;
endfunction


//function Tuple2#(Bit#(32), Bit#(32)) doAtomic(SizeOP size, AtomicOP op, Bit#(32) data, Bit#(32) memval);
//  case (op) matches
//    Word : begin
//    end
//endfunction

// For the moment this cache doesn't have any data, on permissions
interface CacheCore#(type wayT, type tagT, type indexT, type offsetT);
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

module mkCacheCore(CacheCore#(Bit#(wayW), Bit#(tagW), Bit#(indexW), Bit#(offsetW)))
  provisos(Add#(tagW, __a, 32), Add#(indexW, __b, __a));
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bit#(tagW))) tagRam <- mkBram();
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bool)) validRam <- mkBram();
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bool)) dirtyRam <- mkBram();

  // One waiting acquire request
  // 32 bits of address
  // AXI4 bus is 4 bytes wide
  // CPU bus is 4 bytes wide
  DataRam#(1, 32, TAdd#(TAdd#(wayW, indexW), offsetW), 4, 4) dataRam <- mkDataRam;

  Fifo#(1, Bit#(offsetW)) offsetQ <- mkPipelineFifo;
  Fifo#(1, Bit#(indexW))  indexQ <- mkPipelineFifo;
  Fifo#(1, Bool)          readQ <- mkPipelineFifo;
  Fifo#(1, Bit#(32))      dataQ <- mkPipelineFifo;
  Fifo#(1, Bit#(4))       maskQ <- mkPipelineFifo;
  Fifo#(1, Bit#(tagW))    tagQ <- mkPipelineFifo;
  Fifo#(1, Bit#(wayW))    wayQ <- mkPipelineFifo;

  // Length of a cache line
  Bit#(8) length = fromInteger(valueOf(TExp#(offsetW))-1);
  Integer ways = valueOf(TExp#(wayW));

  Reg#(Bit#(wayW)) randomWay <- mkReg(0);

  function Action doMiss(Bit#(wayW) way, Bit#(tagW) tag, Bool read, Bit#(32) data, Bit#(4) mask);
    action
      let index = indexQ.first;
      tagRam.write(index, Vector::update(tagRam.response(), way, tag));
      validRam.write(index, Vector::update(validRam.response(), way, True));
      dirtyRam.write(index, Vector::update(dirtyRam.response(), way, !read));
      readQ.enq(read);
      dataQ.enq(data);
      maskQ.enq(mask);
      tagQ.enq(tag);
      wayQ.enq(way);
    endaction
  endfunction

  Reg#(Bit#(indexW)) initIndex <- mkReg(0);
  Reg#(Bool) started <- mkReg(False);

  rule randomStep;
    randomWay <= randomWay + 1;
  endrule

  /* Initialize all the permissions in the cache */
  rule startRl if (!started);
    validRam.write(initIndex, replicate(False));

    if (initIndex+1 == 0) started <= True;
    initIndex <= initIndex + 1;
  endrule

  rule releaseLineAck if (started);
    let tag = tagQ.first;
    let way = wayQ.first;
    let index = indexQ.first;
    dataRam.acquireLine({tag, index, 0}, {way, index, 0}, length);
    dataRam.releaseLineAck;
  endrule

  rule acquireLineAck if (started);
    dataRam.acquireLineAck;

    let tag <- toGet(tagQ).get;
    let way <- toGet(wayQ).get;
    let read <- toGet(readQ).get;
    let data <- toGet(dataQ).get;
    let mask <- toGet(maskQ).get;
    let index <- toGet(indexQ).get;
    let offset <- toGet(offsetQ).get;

    if (read) dataRam.readWord({way, index, offset});
    else dataRam.writeWord({way, index, offset}, data, mask);
  endrule

  method Action start(Bit#(indexW) index, Bit#(offsetW) offset) if (started);
    action
      indexQ.enq(index);
      offsetQ.enq(offset);
      validRam.read(index);
      dirtyRam.read(index);
      tagRam.read(index);
    endaction
  endmethod

  method Action matching(Bit#(tagW) t, Bool read, Bit#(32) data, Bit#(4) mask)
    if (started);
    action
      let index = indexQ.first;
      let offset = offsetQ.first;

      Bool hit = False;
      Bit#(wayW) way = randomWay;

      for (Integer i=0; i < ways; i = i + 1) begin
        if (tagRam.response[i] == t && validRam.response[i]) begin
          way = fromInteger(i);
          hit = True;
        end
      end

      Bool dirty = dirtyRam.response[way];
      Bool valid = validRam.response[way];
      Bit#(tagW) tag = tagRam.response[way];

      dirtyRam.deq();
      validRam.deq();
      tagRam.deq();

      if (hit) begin
        // Cache hit
        offsetQ.deq;
        indexQ.deq;

        if (read) begin
          dataRam.readWord({way, index, offset});
        end else begin
          dirtyRam.write(index, Vector::update(dirtyRam.response, way, True));
          dataRam.writeWord({way, index, offset}, data, mask);
        end

      end else if (dirty && valid) begin
        // Release then acquire
        doMiss(way, t, read, data, mask);
        dataRam.releaseLine({tag, index, 0}, {way, index, 0}, length);
        //$display("start release");
      end else begin
        // Acquire
        doMiss(way, t, read, data, mask);
        dataRam.acquireLine({t, index, 0}, {way, index, 0}, length);
      end
    endaction
  endmethod

  method readAck = dataRam.readWordAck;
  interface read = dataRam.read;
  interface write = dataRam.write;
  method setID = dataRam.setID;
endmodule

// Use ID 0 for the moment
interface Cache#(type wayT, type tagT, type indexT, type offsetT);
  interface RdAXI4_Lite_Slave#(32, 4) cpu_read;
  interface WrAXI4_Lite_Slave#(32, 4) cpu_write;

  interface RdAXI4_Master#(4, 32, 4) mem_read;
  interface WrAXI4_Master#(4, 32, 4) mem_write;
endinterface

(* synthesize *)
module mkClassicCacheCore(CacheCore#(Bit#(2), Bit#(20), Bit#(6), Bit#(4)));
  let out <- mkCacheCore();
  return out;
endmodule

(* synthesize *)
module mkClassicCache(Cache#(Bit#(2), Bit#(20), Bit#(6), Bit#(4)));
  CacheCore#(Bit#(2), Bit#(20), Bit#(6), Bit#(4)) cache <- mkClassicCacheCore();

  Fifo#(1, AXI4_Lite_RRequest#(32)) rreq <- mkPipelineFifo;
  Fifo#(1, AXI4_Lite_WRequest#(32, 4)) wreq <- mkPipelineFifo;

  rule deqRdReq;
    let req = rreq.first;
    rreq.deq();

    cache.matching(truncateLSB(req.addr), True, ?, ?);
  endrule

  rule setId0;
    cache.setID(0);
  endrule

  interface RdAXI4_Lite_Slave cpu_read;
    interface Put request;
      method Action put(AXI4_Lite_RRequest#(32) request);
        cache.start(request.addr[11:6], request.addr[5:2]);
        rreq.enq(request);
      endmethod
    endinterface

    interface Get response;
      method ActionValue#(AXI4_Lite_RResponse#(4)) get();
        let bytes <- cache.readAck();
        return AXI4_Lite_RResponse{
          bytes: bytes,
          resp: OKAY
        };
      endmethod
    endinterface
  endinterface

  interface WrAXI4_Lite_Slave cpu_write;
    interface Put request;
      method Action put(AXI4_Lite_WRequest#(32, 4) request);
        cache.start(request.addr[11:6], request.addr[5:2]);
        wreq.enq(request);
      endmethod
    endinterface

    interface Get response;
      method ActionValue#(AXI4_Lite_WResponse) get();
        let req = wreq.first;
        wreq.deq();

        cache.matching(truncateLSB(req.addr), False, req.bytes, req.strb);
        return AXI4_Lite_WResponse{resp: OKAY};
      endmethod
    endinterface
  endinterface

  interface mem_read = cache.read();
  interface mem_write = cache.write();
endmodule

(* synthesize *)
module mkTestCache(Empty);
  Cache#(Bit#(2), Bit#(20), Bit#(6), Bit#(4)) cache <- mkClassicCache;
  AXI4_Slave#(4, 32, 4) rom <-
    mkRom(RomConfig{name: "Mem.hex", start: 'h80000000, size: 'h10000});

  Bit#(20) base = truncateLSB(32'h80000000);

  mkConnection(cache.mem_read.request, rom.read.request);
  mkConnection(cache.mem_read.response, rom.read.response);

  mkConnection(cache.mem_write.wrequest, rom.write.wrequest);
  mkConnection(cache.mem_write.awrequest, rom.write.awrequest);
  mkConnection(cache.mem_write.response, rom.write.response);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  function Stmt read(Bit#(20) tag, Bit#(6) index, Bit#(4) offset);
    return seq
      cache.cpu_read.request.put(AXI4_Lite_RRequest{
        addr: {tag, index, offset, 2'b00}
      });
    endseq;
  endfunction

  function Stmt write(Bit#(20) tag, Bit#(6) index, Bit#(4) offset, Bit#(32) data);
    return seq
      cache.cpu_write.request.put(AXI4_Lite_WRequest{
        addr: {tag, index, offset, 2'b00},
        bytes: data, strb: 4'b1111
      });
    endseq;
  endfunction

  function Action readAck();
    action
      let x <- cache.cpu_read.response.get();
      $display("cycle: %d, value: %h", cycle, x.bytes);
    endaction
  endfunction

  function Action writeAck();
    action
      let x <- cache.cpu_write.response.get();
    endaction
  endfunction

  Stmt stmt = seq
    $display("cycle: %d", cycle);

    read(base, 0, 0);
    par
      readAck();
      write(base, 0, 0, 'h55555555);
      writeAck();
    endpar

    par
      read(base, 0, 1);
      read(base, 0, 2);
      read(base, 0, 3);
      read(base, 0, 4);
      read(base, 0, 5);
      read(base, 0, 6);
      read(base, 0, 7);
      read(base, 0, 8);
      read(base, 0, 9);
      read(base, 0, 10);
      read(base, 0, 11);
      read(base, 0, 12);
      readAck();
      readAck();
      readAck();
      readAck();
      readAck();
      readAck();
      readAck();
      readAck();
      readAck();
      readAck();
      readAck();
      readAck();

    endpar

    read(base, 0, 0);
    readAck();
    read(base, 0, 1);
    readAck();
    read(base, 0, 2);
    readAck();
    read(base, 0, 3);
    readAck();
    read(base, 0, 4);
    readAck();
    read(base, 0, 5);
    readAck();
    read(base, 0, 6);
    readAck();
    read(base, 0, 7);
    readAck();
    read(base, 0, 8);
    readAck();
    read(base, 0, 9);
    readAck();
    read(base, 0, 10);
    readAck();
    read(base, 0, 11);
    readAck();
    read(base, 0, 12);
    readAck();

  endseq;

  mkAutoFSM(stmt);

  rule countCycle;
    cycle <= cycle + 1;
  endrule

endmodule


