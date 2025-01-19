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
import LinkList :: *;

// size is the maximum number of parallel cache miss on different cache blocks
interface MSHR#(numeric type nMSHR, numeric type nEntry, type addrT, type entryT);
  // allocate a new request, and return the new allocated mshr, or Invalid if the address was
  // already being acquire by an mshr
  method ActionValue#(Maybe#(Bit#(TLog#(nMSHR)))) allocate(addrT address, entryT entry);

  // free one element of the linked-list of entries associated to an mshr
  method ActionValue#(entryT) freeEntry(Bit#(TLog#(nMSHR)) mshr);

  // free an mshr
  method Action free(Bit#(TLog#(nMSHR)) mshr);
endinterface

module mkMSHR(MSHR#(nMSHR, nEntry, Bit#(addrW), entryT))
  provisos( Bits#(entryT, entryW) );

  Reg#(Bit#(nMSHR)) valids <- mkReg(0);
  Vector#(nMSHR, Reg#(Bit#(addrW))) addresses <- replicateM(mkReg(?));
  Vector#(nMSHR, Reg#(Maybe#(Bit#(TLog#(nEntry))))) heads <- replicateM(mkReg(?));
  Vector#(nMSHR, Reg#(Maybe#(Bit#(TLog#(nEntry))))) tails <- replicateM(mkReg(?));

  RegFile#(Bit#(TLog#(nEntry)), entryT) entries <- mkRegFileFull;
  LinkList#(TLog#(nEntry)) lists <- mkLinkList;

  function Maybe#(Bit#(TLog#(nMSHR))) getMSHR(Bit#(addrW) addr);
    Bit#(nMSHR) found = ?;

    for (Integer i=0; i < valueOf(nMSHR); i = i + 1) begin
      found[i] = addr == addresses[i] && valids[i] == 1 ? 1 : 0;
    end

    return case (firstOneFrom(found, 0)) matches
      Invalid : firstOneFrom(valids, 0);
      tagged Valid .x : Valid(x);
    endcase;
  endfunction

  method ActionValue#(Maybe#(Bit#(TLog#(nMSHR)))) allocate(Bit#(addrW) addr, entryT entry);
    actionvalue
      case (getMSHR(addr)) matches
        Invalid : begin
          when(False, noAction);
          return ?;
        end
        tagged Valid .mshr : begin
          valids[mshr] <= 1;
          addresses[mshr] <= addr;

          case (tails[mshr]) matches
            Invalid : begin
              let index <- lists.init();
              heads[mshr] <= Valid(index);
              tails[mshr] <= Valid(index);
              entries.upd(index, entry);
            end
            tagged Valid .tail : begin
              let new_tail <- lists.pushTail(tail);
              tails[mshr] <= Valid(new_tail);
              entries.upd(new_tail, entry);
            end
          endcase

          return valids[mshr] == 1 ? Valid(mshr) : Invalid;
        end
      endcase
    endactionvalue
  endmethod

  method Action free(Bit#(TLog#(nMSHR)) mshr);
    action
      when(heads[mshr] == Invalid, action valids[mshr] <= 0; endaction);
    endaction
  endmethod

  method ActionValue#(entryT) freeEntry(Bit#(TLog#(nMSHR)) mshr);
    actionvalue
      case (heads[mshr]) matches
        Invalid : begin
          when(False, noAction);
          return ?;
        end
        tagged Valid .head : begin
          lists.popHead(head);

          case (lists.next(head)) matches
            tagged Valid .hd : heads[mshr] <= Valid(hd);
            Invalid : begin
              heads[mshr] <= Invalid;
              tails[mshr] <= Invalid;
            end
          endcase

          return entries.sub(head);
        end
      endcase
    endactionvalue
  endmethod
endmodule


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
  Vector#(TExp#(wayW), RWBram#(Bit#(indexW), Bit#(tagW))) tagRam <- replicateM(mkRWBram);
  Vector#(TExp#(wayW), RWBram#(Bit#(indexW), Bool)) validRam <- replicateM(mkRWBram);
  Vector#(TExp#(wayW), RWBram#(Bit#(indexW), Bool)) dirtyRam <- replicateM(mkRWBram);

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
    for (Integer i=0; i < ways; i = i + 1) begin
      validRam[i].write(initIndex, False);
    end

    if (initIndex+1 == 0) started <= True;
    initIndex <= initIndex + 1;
  endrule

  rule releaseLineAck;
    let tag = tagQ.first;
    let way = wayQ.first;
    let index = indexQ.first;
    dataRam.acquireLine({tag, index, 0}, {way, index, 0}, length);
    dataRam.releaseLineAck;
  endrule

  rule acquireLineAck;
    dataRam.acquireLineAck;

    let tag <- toGet(tagQ).get;
    let way <- toGet(wayQ).get;
    let read <- toGet(readQ).get;
    let data <- toGet(dataQ).get;
    let mask <- toGet(maskQ).get;
    let index <- toGet(indexQ).get;
    let offset <- toGet(offsetQ).get;
    validRam[way].write(index, True);
    tagRam[way].write(index, tag);

    if (read) begin
      dirtyRam[way].write(index, False);
      dataRam.readWord({way, index, offset});
    end else begin
      dirtyRam[way].write(index, True);
      dataRam.writeWord({way, index, offset}, data, mask);
    end
  endrule

  method Action start(Bit#(indexW) index, Bit#(offsetW) offset) if (started);
    action
      indexQ.enq(index);
      offsetQ.enq(offset);
      for (Integer w=0; w < ways; w = w + 1) begin
        tagRam[w].read(index);
        validRam[w].read(index);
        dirtyRam[w].read(index);
      end
    endaction
  endmethod

  method Action matching(Bit#(tagW) t, Bool read, Bit#(32) data, Bit#(4) mask)
    if (started);
    action
      let index = indexQ.first;
      let offset = offsetQ.first;

      Bool dirty = ?;
      Bit#(tagW) tag = ?;
      Bool valid = False;
      Bit#(wayW) way = 0;
      for (Integer i=0; i < ways; i = i + 1) begin
        let found = tagRam[i].response == t && validRam[i].response;

        if (found || (fromInteger(i) == randomWay && !valid)) begin
          valid = validRam[i].response;
          dirty = dirtyRam[i].response;
          tag = tagRam[i].response;
          way = fromInteger(i);
        end
        dirtyRam[i].deq;
        validRam[i].deq;
        tagRam[i].deq;
      end

      if (t == tag && valid) begin
        // Cache hit
        offsetQ.deq;
        indexQ.deq;

        if (read) begin
          dataRam.readWord({way, index, offset});
        end else begin
          dirtyRam[way].write(index, True);
          dataRam.writeWord({way, index, offset}, data, mask);
        end

      end else if (dirty && valid) begin
        // Release then acquire
        doMiss(way, t, read, data, mask);
        dataRam.releaseLine({tag, index, 0}, {way, index, 0}, length);
        $display("start release");
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

(* synthesize *)
module mkClassicCacheCore(CacheCore#(Bit#(2), Bit#(20), Bit#(6), Bit#(4)));
  let out <- mkCacheCore();
  return out;
endmodule

(* synthesize *)
module mkTestCache(Empty);
  CacheCore#(Bit#(2), Bit#(20), Bit#(6), Bit#(4)) cache <- mkClassicCacheCore;
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

  endseq;

  mkAutoFSM(stmt);

  rule countCycle;
    cycle <= cycle + 1;
  endrule

endmodule


