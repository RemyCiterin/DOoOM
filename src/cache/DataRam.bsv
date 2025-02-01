import AXI4 :: *;
import Vector :: *;
import Array :: *;
import BlockRam :: *;
import Utils :: *;
import Fifo :: *;
import Ehr :: *;

import TestBench :: *;
import StmtFSM :: *;
import Connectable :: *;

import GetPut :: *;


// Generic implementation of data RAM for cache implementation
interface DataRam
  #(numeric type buffSize, numeric type addrW, numeric type indexW, numeric type wordW, numeric type beatW);
  /* Memory interface */
  interface RdAXI4_Master#(4, addrW, beatW) read;
  interface WrAXI4_Master#(4, addrW, beatW) write;

  /* read or write one word in the data ram */
  method Action readWord(Bit#(indexW) index);
  method ActionValue#(Byte#(wordW)) readWordAck;
  method Action writeWord(Bit#(indexW) index, Byte#(wordW) value, Bit#(wordW) mask);

  /* Ask for acquire a cache line using the AXI4 channel */
  method Action acquireLine(Bit#(addrW) address, Bit#(indexW) index, Bit#(8) length);
  method Action acquireLineAck;

  /* Ask for releasing a cache line using the AXI4 channel */
  method Action releaseLine(Bit#(addrW) address, Bit#(indexW) index, Bit#(8) length);
  method Action releaseLineAck;

  /* Set the AXI4 id */
  method Action setID(Bit#(4) id);
endinterface

module mkDataRam(DataRam#(buffSize, addrW, indexW, wordW, beatW))
  provisos(Mul#(beatW, beatPerWord, wordW));

  function Byte#(beatW) truncateWord(Byte#(wordW) word, Bit#(TLog#(wordW)) offset);
    word = word >> {offset, 3'b000};
    return word[8*valueOf(beatW)-1:0];
  endfunction

  function Byte#(wordW) setBeat(Byte#(wordW) buffer, Byte#(beatW) beat, Bit#(TLog#(wordW)) offset);
    Byte#(beatW) beats[valueOf(beatPerWord)];

    Integer j=0;
    for (Integer i=0; i < valueOf(wordW); i = i + valueOf(beatW)) begin
      beats[j] = offset == fromInteger(i) ?
        beat : truncateWord(buffer, fromInteger(i));
      j = j + 1;
    end

    return packArray(beats);
  endfunction

  Fifo#(1, AXI4_RRequest#(4, addrW)) rrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_RResponse#(4, beatW)) rresponseQ <- mkPipelineFifo;

  Fifo#(1, AXI4_AWRequest#(4, addrW)) awrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_WRequest#(beatW)) wrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_WResponse#(4)) wresponseQ <- mkPipelineFifo;

  Vector#(wordW, RWBram#(Bit#(indexW), Bit#(8))) bram <- replicateM(mkRWBram);
  Fifo#(1, Bool) isReadWord <- mkPipelineFifo;

  Fifo#(buffSize, Tuple2#(Bit#(indexW), Bit#(8))) acquireQ <- mkPipelineFifo;

  Ehr#(2, Bit#(indexW)) acquireIndex <- mkEhr(?);
  Ehr#(2, Bit#(TLog#(wordW))) acquireOffset <- mkEhr(?);
  Ehr#(2, Maybe#(Bit#(8))) acquireLength <- mkEhr(Invalid);
  Reg#(Byte#(wordW)) acquireBuffer <- mkReg(?);
  Fifo#(1, void) acquireDone <- mkBypassFifo;

  Ehr#(2, Bit#(indexW)) releaseIndex <- mkEhr(0);
  Ehr#(2, Bit#(TLog#(wordW))) releaseOffset <- mkEhr(0);
  Ehr#(2, Maybe#(Bit#(8))) releaseLength <- mkEhr(Invalid);
  Reg#(Byte#(wordW)) releaseBuffer <- mkReg(?);

  Reg#(Bit#(4)) id <- mkReg(?);
  Reg#(Bool) started <- mkReg(False);

  function Bit#(TLog#(wordW)) newOffset(Bit#(TLog#(wordW)) offset);
    if (offset == fromInteger(valueOf(wordW) - valueOf(beatW))) return 0;
    else return offset + fromInteger(valueOf(beatW) % valueOf(wordW));
  endfunction

  function Action bramReadWord(Bit#(indexW) index);
    action
      for (Integer i=0; i < valueOf(wordW); i = i + 1) begin
        bram[i].read(index);
      end
    endaction
  endfunction

  function Byte#(wordW) bramOutWord;
    Bit#(8) result[valueOf(wordW)];

    for (Integer i=0; i < valueOf(wordW); i = i + 1) begin
      result[i] = bram[i].response;
    end

    return packArray(result);
  endfunction

  function Action bramDeqWord;
    action
      for (Integer i=0; i < valueOf(wordW); i = i + 1) begin
        bram[i].deq;
      end
    endaction
  endfunction

  function Action bramWriteWord(Bit#(indexW) index, Byte#(wordW) data, Bit#(wordW) mask);
    action
      for (Integer i=0; i < valueOf(wordW); i = i + 1) begin
        if (mask[i] == 1) bram[i].write(index, data[8*i+7:8*i]);
      end
    endaction
  endfunction

  function Action
    bramWriteBeat(Bit#(indexW) index, Bit#(TLog#(wordW)) offset, Byte#(beatW) data, Bit#(beatW) mask);
    action
      for (Integer i=0; i < valueOf(beatW); i = i + 1) begin
        if (mask[i] == 1) bram[offset+fromInteger(i)].write(index, data[8*i+7:8*i]);
      end
    endaction
  endfunction

  rule deqAcquireQ if (acquireLength[0] == Invalid);
    match {.index, .length} = acquireQ.first;
    acquireLength[0] <= Valid(length);
    acquireIndex[0] <= index;
    acquireOffset[0] <= 0;
    acquireQ.deq;
  endrule

  rule acquireRl if (acquireLength[1] matches tagged Valid .length);
    let new_offset = newOffset(acquireOffset[1]);
    let resp = rresponseQ.first;
    rresponseQ.deq;

    let new_buffer = setBeat(acquireBuffer, resp.bytes, acquireOffset[1]);
    acquireBuffer <= new_buffer;

    if (new_offset == 0) begin
      bramWriteWord(acquireIndex[1], new_buffer, ~0);
    end

    if (length == 0) begin
      acquireDone.enq(?);
      acquireLength[1] <= Invalid;
    end else begin
      if (new_offset == 0) acquireIndex[1] <= acquireIndex[1]+1;
      acquireLength[1] <= Valid(length - 1);
      acquireOffset[1] <= new_offset;
    end
  endrule

  (* execution_order = "releaseRespRl, releaseReqRl" *)
  rule releaseRespRl
    if (releaseLength[0] matches tagged Valid .length);
    Byte#(beatW) beat = truncateWord(releaseBuffer, releaseOffset[0]);

    if (releaseOffset[0] == 0) begin
      when(!isReadWord.first, isReadWord.deq);
      beat = truncateWord(bramOutWord, 0);
      releaseBuffer <= bramOutWord;
      bramDeqWord;
    end

    wrequestQ.enq(AXI4_WRequest{
      last: length == 0,
      bytes: beat,
      strb: ~0
    });

    if (length == 0) begin
      releaseLength[0] <= Invalid;
    end else begin
      let new_offset = newOffset(releaseOffset[0]);
      if (new_offset == 0) releaseIndex[0] <= releaseIndex[0] + 1;
      releaseLength[0] <= Valid(length-1);
      releaseOffset[0] <= new_offset;
    end
  endrule

  rule releaseReqRl
    if (releaseLength[1] matches tagged Valid .length &&& releaseOffset[1] == 0);
    bramReadWord(releaseIndex[1]);
    isReadWord.enq(False);
  endrule

  method Action readWord(Bit#(indexW) index);
    action
      isReadWord.enq(True);
      bramReadWord(index);
    endaction
  endmethod

  method ActionValue#(Byte#(wordW)) readWordAck if (isReadWord.first);
    actionvalue
      bramDeqWord;
      isReadWord.deq;
      return bramOutWord;
    endactionvalue
  endmethod

  method Action writeWord(Bit#(indexW) index, Byte#(wordW) data, Bit#(wordW) mask);
    action
      bramWriteWord(index, data, mask);
    endaction
  endmethod

  method Action acquireLine(Bit#(addrW) address, Bit#(indexW) index, Bit#(8) length)
    if (started);
    action
      acquireQ.enq(tuple2(index, length));

      rrequestQ.enq(AXI4_RRequest{
        length: length,
        addr: address,
        burst: INCR,
        id: id
      });
    endaction
  endmethod

  method Action acquireLineAck;
    action
      acquireDone.deq;
    endaction
  endmethod

  method Action releaseLine(Bit#(addrW) address, Bit#(indexW) index, Bit#(8) length)
    if (started && releaseLength[0] == Invalid);
    action
      releaseOffset[0] <= 0;
      releaseIndex[0] <= index;
      releaseLength[0] <= Valid(length);

      awrequestQ.enq(AXI4_AWRequest{
        length: length,
        addr: address,
        burst: INCR,
        id: id
      });
    endaction
  endmethod

  method Action releaseLineAck;
    action
      wresponseQ.deq;
    endaction
  endmethod

  method Action setID(Bit#(4) x) if (!started);
    action
      id <= x;
      started <= True;
    endaction
  endmethod

  interface RdAXI4_Master read;
    interface request = toGet(rrequestQ);
    interface response = toPut(rresponseQ);
  endinterface

  interface WrAXI4_Master write;
    interface response = toPut(wresponseQ);
    interface awrequest = toGet(awrequestQ);
    interface wrequest = toGet(wrequestQ);
  endinterface
endmodule

(* synthesize *)
module mkClassicDataRam(DataRam#(4, 32, 10, 4, 4));
  let out <- mkDataRam;
  return out;
endmodule

(* synthesize *)
module mkTestDataRam(Empty);
  DataRam#(4, 32, 10, 4, 4) cache <- mkClassicDataRam;
  AXI4_Slave#(4, 32, 4) rom <-
    mkRom(RomConfig{name: "Mem.hex", start: 'h80000000, size: 'h10000});

  mkConnection(cache.read.request, rom.read.request);
  mkConnection(cache.read.response, rom.read.response);

  mkConnection(cache.write.wrequest, rom.write.wrequest);
  mkConnection(cache.write.awrequest, rom.write.awrequest);
  mkConnection(cache.write.response, rom.write.response);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  function Stmt readLine(Bit#(10) index, Integer length);
    if (length == 0) return seq endseq;
    else return seq
      cache.readWord(index);
      action
        let x <- cache.readWordAck();
        $display("cache[%d] := %h", index, x);
      endaction
      readLine(index+1, length-1);
    endseq;
  endfunction

  Stmt stmt = seq
    par
      cache.setID(0);
      cache.acquireLine('h80000000, 0, 15);
      cache.acquireLineAck();
    endpar

    //readLine(0, 8);

    //cache.writeWord(0, 64'hfedcba9876543210, -1);
    //cache.writeWord(0, 32'h76543210, -1);

    readLine(0, 16);

    //par
    //  cache.releaseLine('h80000000, 0, 15);
    //  cache.releaseLineAck();
    //endpar

    //par
    //  cache.acquireLine('h80000000, 4, 15);
    //  cache.acquireLineAck();
    //endpar

    //readLine(4, 8);
  endseq;

  mkAutoFSM(stmt);

  rule countCycle;
    cycle <= cycle + 1;
  endrule

endmodule
