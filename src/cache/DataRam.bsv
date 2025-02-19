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

  let bram <- mkDualBramBE();
  BramBE#(Bit#(indexW), wordW) memPort = bram.fst;
  BramBE#(Bit#(indexW), wordW) cpuPort = bram.snd;

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
      memPort.write(acquireIndex[1], new_buffer, ~0);
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
      beat = truncateWord(memPort.response(), 0);
      releaseBuffer <= memPort.response();
      memPort.deq();
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
    memPort.read(releaseIndex[1]);
  endrule

  method readWord = cpuPort.read;

  method ActionValue#(Byte#(wordW)) readWordAck;
    cpuPort.deq();
    return cpuPort.response();
  endmethod

  method writeWord = cpuPort.write;

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

  method Action releaseLineAck = wresponseQ.deq;

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
