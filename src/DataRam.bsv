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
  #(numeric type buffSize, numeric type addrW, numeric type indexW, numeric type wordW);
  /* Memory interface */
  interface RdAXI4_Master#(4, addrW, wordW) read;
  interface WrAXI4_Master#(4, addrW, wordW) write;

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

module mkDataRam(DataRam#(buffSize, addrW, indexW, wordW));
  Fifo#(1, AXI4_RRequest#(4, addrW)) rrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_RResponse#(4, wordW)) rresponseQ <- mkPipelineFifo;

  Fifo#(1, AXI4_AWRequest#(4, addrW)) awrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_WRequest#(wordW)) wrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_WResponse#(4)) wresponseQ <- mkPipelineFifo;

  Vector#(wordW, RWBram#(Bit#(indexW), Bit#(8))) bram <- replicateM(mkRWBram);
  Fifo#(1, Bool) isReadWord <- mkPipelineFifo;

  Fifo#(buffSize, Tuple2#(Bit#(indexW), Bit#(8))) acquireQ <- mkPipelineFifo;

  Ehr#(2, Bit#(indexW)) acquireIndex <- mkEhr(?);
  Ehr#(2, Maybe#(Bit#(8))) acquireLength <- mkEhr(Invalid);
  Fifo#(1, void) acquireDone <- mkBypassFifo;

  Ehr#(2, Bit#(indexW)) releaseIndex <- mkEhr(0);
  Ehr#(2, Maybe#(Bit#(8))) releaseLength <- mkEhr(Invalid);

  Reg#(Bit#(4)) id <- mkReg(?);
  Reg#(Bool) started <- mkReg(False);

  function Action bramRead(Bit#(indexW) index);
    action
      for (Integer i=0; i < valueOf(wordW); i = i + 1) begin
        bram[i].read(index);
      end
    endaction
  endfunction

  function Byte#(wordW) bramOut;
    Bit#(8) result[valueOf(wordW)];

    for (Integer i=0; i < valueOf(wordW); i = i + 1) begin
      result[i] = bram[i].response;
    end

    return packArray(result);
  endfunction

  function Action bramDeq;
    action
      for (Integer i=0; i < valueOf(wordW); i = i + 1) begin
        bram[i].deq;
      end
    endaction
  endfunction

  function Action bramWrite(Bit#(indexW) index, Byte#(wordW) data, Bit#(wordW) mask);
    action
      for (Integer i=0; i < valueOf(wordW); i = i + 1) begin
        if (mask[i] == 1) bram[i].write(index, data[8*i+7:8*i]);
      end
    endaction
  endfunction

  rule deqAcquireQ if (acquireLength[0] == Invalid);
    match {.index, .length} = acquireQ.first;
    acquireLength[0] <= Valid(length);
    acquireIndex[0] <= index;
    acquireQ.deq;
  endrule

  rule acquireRl if (acquireLength[1] matches tagged Valid .length);
    let resp = rresponseQ.first;
    rresponseQ.deq;

    $display("receive index: %h bytes: %h", acquireIndex[1], resp.bytes);
    bramWrite(acquireIndex[1], resp.bytes, ~0);

    if (length == 0) begin
      acquireDone.enq(?);
      acquireLength[1] <= Invalid;
    end else begin
      acquireIndex[1] <= acquireIndex[1]+1;
      acquireLength[1] <= Valid(length - 1);
    end
  endrule

  rule releaseReqRl
    if (releaseLength[1] matches tagged Valid .length);
    isReadWord.enq(False);
    bramRead(releaseIndex[1]);
    $display("read data req");
  endrule

  rule releaseRespRl
    if (releaseLength[0] matches tagged Valid .length &&& !isReadWord.first);
    isReadWord.deq;
    bramDeq;

    $display("read data resp");

    wrequestQ.enq(AXI4_WRequest{
      last: length == 0,
      bytes: bramOut,
      strb: ~0
    });

    if (length == 0) begin
      releaseLength[0] <= Invalid;
    end else begin
      releaseIndex[0] <= releaseIndex[0] + 1;
      releaseLength[0] <= Valid(length-1);
    end
  endrule


  method Action readWord(Bit#(indexW) index);
    action
      isReadWord.enq(True);
      bramRead(index);
    endaction
  endmethod

  method ActionValue#(Byte#(wordW)) readWordAck if (isReadWord.first);
    actionvalue
      bramDeq;
      isReadWord.deq;
      return bramOut;
    endactionvalue
  endmethod

  method writeWord = bramWrite;

  method Action acquireLine(Bit#(addrW) address, Bit#(indexW) index, Bit#(8) length)
    if (started);
    action
      $display("acquire address: %h index: %h length: %h", address, index, {1'b0,length}+1);
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
      $display("acquire ack");
      acquireDone.deq;
    endaction
  endmethod

  method Action releaseLine(Bit#(addrW) address, Bit#(indexW) index, Bit#(8) length)
    if (started && releaseLength[0] == Invalid);
    action
      releaseIndex[0] <= index;
      releaseLength[0] <= Valid(length);
      $display("release address: %h index: %h length: %h", address, index, {1'b0,length}+1);

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
module mkTestDataRam(Empty);
  DataRam#(4, 32, 10, 4) cache <- mkDataRam;
  AXI4_Slave#(4, 32, 4) rom <-
    mkRom(RomConfig{name: "Mem.hex", start: 'h80000000, size: 'h10000});

  mkConnection(cache.read.request, rom.read.request);
  mkConnection(cache.read.response, rom.read.response);

  mkConnection(cache.write.wrequest, rom.write.wrequest);
  mkConnection(cache.write.awrequest, rom.write.awrequest);
  mkConnection(cache.write.response, rom.write.response);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  Stmt stmt = seq
    par
      cache.setID(0);
      par
        cache.acquireLine('h80000000, 0, 255);
        cache.acquireLineAck();
        cache.acquireLine('h80000000, 0, 255);
        cache.acquireLineAck();
        cache.acquireLine('h80000000, 0, 255);
        cache.acquireLineAck();
        cache.acquireLine('h80000000, 0, 255);
        cache.acquireLineAck();
        cache.acquireLine('h80000000, 0, 255);
        cache.acquireLineAck();
      endpar
    endpar

    par
      cache.readWord(25);
      action
        let x <- cache.readWordAck();
        $display("read value x: %h ", x, cycle);
      endaction
      cache.readWord(25);
      action
        let x <- cache.readWordAck();
        $display("read value x: %h ", x, cycle);
      endaction

      $display(cycle);
      cache.releaseLine('h80000000, 0, 15);
      action
        cache.releaseLineAck;
        $display(cycle);
      endaction
      cache.releaseLine('h80000000, 0, 15);
      action
        cache.releaseLineAck;
        $display(cycle);
      endaction

    endpar
  endseq;

  mkAutoFSM(stmt);

  rule countCycle;
    cycle <= cycle + 1;
  endrule

endmodule




