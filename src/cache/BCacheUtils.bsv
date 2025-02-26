import BlockRam :: *;
import GetPut :: *;
import Vector :: *;
import Utils :: *;
import Fifo :: *;
import AXI4 :: *;
import Ehr :: *;

/* A (blocking) module to acquire cache blocks from a block Ram */
interface BAcquireBlock
  #(numeric type indexW, numeric type addrW, numeric type wordW, numeric type blockW);
  /* Memory interface */
  interface RdAXI4_Master#(4, addrW, wordW) read;

  /* Control interface */
  method Action acquireBlock(Bit#(addrW) address, Bit#(indexW) index);
  method Action acquireBlockAck();
  method Action setID(Bit#(4) id);
endinterface

module mkBAcquireBlock#(BramBE#(Bit#(indexW), wordW) bram)
  (BAcquireBlock#(indexW, addrW, wordW, blockW))
  provisos(Mul#(wordW, wordPerBlock, blockW));

  Fifo#(1, AXI4_RRequest#(4, addrW)) rrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_RResponse#(4, wordW)) rresponseQ <- mkPipelineFifo;

  Bit#(TLog#(wordPerBlock)) maxOffset = fromInteger(valueOf(wordPerBlock) - 1);

  Reg#(Bit#(TLog#(wordPerBlock))) offset <- mkReg(?);
  Reg#(Maybe#(Bit#(indexW))) index <- mkReg(Invalid);

  Reg#(Bit#(4)) id <- mkReg(?);
  Reg#(Bool) started <- mkReg(False);

  Fifo#(1, void) ackQ <- mkPipelineFifo();

  rule receiveWord if (index matches tagged Valid .idx);
    bram.write(idx, rresponseQ.first.bytes, ~0);
    rresponseQ.deq();

    offset <= offset == maxOffset ? 0 : offset + 1;
    index <= offset == maxOffset ? Invalid : Valid(idx+1);
  endrule

  method Action acquireBlock(Bit#(addrW) address, Bit#(indexW) idx)
    if (started &&& index matches Invalid);
    action
      offset <= 0;
      index <= Valid(idx);
      ackQ.enq(?);

      rrequestQ.enq(AXI4_RRequest{
        burst: INCR, id: id, addr: address,
        length: fromInteger(valueOf(wordPerBlock) - 1)
      });
    endaction
  endmethod

  method Action acquireBlockAck() if (index matches Invalid);
    action
      ackQ.deq();
    endaction
  endmethod

  method Action setID(Bit#(4) i) if (!started);
    action
      id <= i;
      started <= True;
    endaction
  endmethod

  interface RdAXI4_Master read;
    interface request = toGet(rrequestQ);
    interface response = toPut(rresponseQ);
  endinterface
endmodule

/* A (blocking) module to release cache blocks */
interface BReleaseBlock
  #(numeric type indexW, numeric type addrW, numeric type wordW, numeric type blockW);
  /* Memory interface */
  interface WrAXI4_Master#(4, addrW, wordW) write;

  /* Control interface */
  method Action releaseBlock(Bit#(addrW) address, Bit#(indexW) index);
  method Action releaseBlockAck();

  method Action setID(Bit#(4) id);
endinterface

module mkBReleaseBlock#(BramBE#(Bit#(indexW), wordW) bram)
  (BReleaseBlock#(indexW, addrW, wordW, blockW))
  provisos(Mul#(wordW, wordPerBlock, blockW));

  Fifo#(1, AXI4_AWRequest#(4, addrW)) awrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_WRequest#(wordW)) wrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_WResponse#(4)) wresponseQ <- mkPipelineFifo;

  Bit#(TLog#(wordPerBlock)) maxOffset = fromInteger(valueOf(wordPerBlock) - 1);

  Reg#(Bit#(TLog#(wordPerBlock))) offset <- mkReg(?);
  PReg#(2, Maybe#(Bit#(indexW))) index <- mkPReg(Invalid);

  Reg#(Bit#(4)) id <- mkReg(?);
  Reg#(Bool) started <- mkReg(False);

  rule readBram if (index[1] matches tagged Valid .idx);
    bram.read(idx);
  endrule

  rule sendWord if (index[0] matches tagged Valid .idx);
    bram.deq();

    wrequestQ.enq(AXI4_WRequest{
      last: offset == maxOffset,
      bytes: bram.response(),
      strb: ~0
    });

    index[0] <= offset == maxOffset ? Invalid : Valid(idx + 1);
    offset <= offset == maxOffset ? 0 : offset + 1;
  endrule

  method Action releaseBlock(Bit#(addrW) address, Bit#(indexW) idx)
    if (started && index[0] == Invalid);
    action
      offset <= 0;
      index[0] <= Valid(idx);

      awrequestQ.enq(AXI4_AWRequest{
        burst: INCR, id: id, addr: address,
        length: fromInteger(valueOf(wordPerBlock) - 1)
      });
    endaction
  endmethod

  method releaseBlockAck = wresponseQ.deq;

  method Action setID(Bit#(4) i) if (!started);
    action
      id <= i;
      started <= True;
    endaction
  endmethod

  interface WrAXI4_Master write;
    interface response = toPut(wresponseQ);
    interface awrequest = toGet(awrequestQ);
    interface wrequest = toGet(wrequestQ);
  endinterface
endmodule
