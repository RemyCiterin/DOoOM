import BlockRam :: *;
import GetPut :: *;
import Vector :: *;
import Utils :: *;
import Fifo :: *;
import AXI4 :: *;
import Ehr :: *;

/* A (blocking) module to acquire cache blocks from a block Ram */
interface BAcquireBlock
  #(numeric type indexW, numeric type addrW, numeric type beatW, numeric type wordW, numeric type blockW);
  /* Memory interface */
  interface RdAXI4_Master#(4, addrW, beatW) read;

  /* Control interface */
  method Action acquireBlock(Bit#(addrW) address, Bit#(indexW) index);
  method Action acquireBlockAck();
  method Action setID(Bit#(4) id);
endinterface

module mkBAcquireBlock#(BramBE#(Bit#(indexW), wordW) bram)
  (BAcquireBlock#(indexW, addrW, beatW, wordW, blockW))
  provisos(Mul#(wordW, wordPerBlock, blockW), Mul#(beatW, beatPerWord, wordW));

  Fifo#(1, AXI4_RRequest#(4, addrW)) rrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_RResponse#(4, beatW)) rresponseQ <- mkPipelineFifo;

  Bit#(TLog#(wordPerBlock)) maxOffsetBlock = fromInteger(valueOf(wordPerBlock) - 1);
  Bit#(TLog#(beatPerWord)) maxOffsetWord = fromInteger(valueOf(beatPerWord) - 1);

  Reg#(Bit#(TLog#(wordPerBlock))) offsetBlock <- mkReg(?);
  Reg#(Bit#(TLog#(beatPerWord))) offsetWord <- mkReg(?);
  Reg#(Maybe#(Bit#(indexW))) index <- mkReg(Invalid);

  Reg#(Bit#(4)) id <- mkReg(?);
  Reg#(Bool) started <- mkReg(False);

  Reg#(Vector#(beatPerWord, Byte#(beatW))) buffer <- mkReg(?);

  Fifo#(1, void) ackQ <- mkPipelineFifo();

  rule receiveWord if (index matches tagged Valid .idx &&& started);
    let newBuf = Vector::update(buffer, offsetWord, rresponseQ.first.bytes);
    rresponseQ.deq();

    buffer <= newBuf;

    if (offsetWord == maxOffsetWord) begin
      index <= offsetBlock == maxOffsetBlock ? Invalid : Valid(idx+1);
      bram.write(idx, pack(newBuf), ~0);
      offsetBlock <= offsetBlock + 1;
      offsetWord <= 0;
    end else begin
      offsetWord <= offsetWord + 1;
      index <= Valid(idx + 1);
    end
  endrule

  method Action acquireBlock(Bit#(addrW) address, Bit#(indexW) idx)
    if (started &&& index matches Invalid);
    action
      offsetWord <= 0;
      offsetBlock <= 0;
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
  #(numeric type indexW, numeric type addrW, numeric type beatW, numeric type wordW, numeric type blockW);
  /* Memory interface */
  interface WrAXI4_Master#(4, addrW, beatW) write;

  /* Control interface */
  method Action releaseBlock(Bit#(addrW) address, Bit#(indexW) index);
  method Action releaseBlockAck();

  method Action setID(Bit#(4) id);
endinterface

module mkBReleaseBlock#(BramBE#(Bit#(indexW), wordW) bram)
  (BReleaseBlock#(indexW, addrW, beatW, wordW, blockW))
  provisos(Mul#(wordW, wordPerBlock, blockW), Mul#(beatW, beatPerWord, wordW));

  Fifo#(1, AXI4_AWRequest#(4, addrW)) awrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_WRequest#(beatW)) wrequestQ <- mkBypassFifo;
  Fifo#(1, AXI4_WResponse#(4)) wresponseQ <- mkPipelineFifo;

  Bit#(TLog#(wordPerBlock)) maxOffsetBlock = fromInteger(valueOf(wordPerBlock) - 1);
  Bit#(TLog#(beatPerWord)) maxOffsetWord = fromInteger(valueOf(beatPerWord) - 1);

  Ehr#(2, Bit#(TLog#(beatPerWord))) offsetWord <- mkEhr(?);
  Reg#(Bit#(TLog#(wordPerBlock))) offsetBlock <- mkReg(?);
  Ehr#(2, Maybe#(Bit#(indexW))) index <- mkEhr(Invalid);

  Reg#(Vector#(beatPerWord, Byte#(beatW))) buffer <- mkReg(?);

  Reg#(Bit#(4)) id <- mkReg(?);
  Reg#(Bool) started <- mkReg(False);

  rule readBram if (index[1] matches tagged Valid .idx &&& offsetWord[1] == 0);
    bram.read(idx);
  endrule

  rule sendWord if (index[0] matches tagged Valid .idx);
    Vector#(beatPerWord, Byte#(beatW)) newBuf = buffer;

    if (offsetWord[0] == 0) begin
      newBuf = unpack(bram.response());
      buffer <= newBuf;
      bram.deq();
    end

    wrequestQ.enq(AXI4_WRequest{
      bytes: newBuf[offsetWord[0]],
      last: offsetBlock == maxOffsetBlock && offsetWord[0] == maxOffsetWord,
      strb: ~0
    });

    if (offsetWord[0] == maxOffsetWord) begin
      index[0] <= offsetBlock == maxOffsetBlock ? Invalid : Valid(idx+1);
      offsetBlock <= offsetBlock + 1;
      offsetWord[0] <= 0;
    end else begin
      offsetWord[0] <= offsetWord[0] + 1;
      index[0] <= Valid(idx + 1);
    end
  endrule

  method Action releaseBlock(Bit#(addrW) address, Bit#(indexW) idx)
    if (started && index[0] == Invalid);
    action
      offsetBlock <= 0;
      offsetWord[0] <= 0;
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
