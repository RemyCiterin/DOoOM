import BuildVector :: *;
import AXI4_Lite :: *;
import BlockRam :: *;
import StmtFSM :: *;
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
  Ehr#(2, Maybe#(Bit#(indexW))) index <- mkEhr(Invalid);

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

typedef enum {
  Read, Write, Invalidate
} CacheOp deriving(Bits, FShow, Eq);

// Blocking cache type
interface BCacheCore#(type wayT, type tagT, type indexT, type offsetT);
  // Start a memory operation
  method Action start(indexT index, offsetT offset);

  // Tag matching
  method Action matching(tagT tag, CacheOp op, Bit#(32) data, Bit#(4) mask);

  // Acknoledge a read request
  method ActionValue#(Bit#(32)) readAck;

  interface RdAXI4_Master#(4, 32, 4) read;
  interface WrAXI4_Master#(4, 32, 4) write;
  method Action setID(Bit#(4) id);
endinterface

module mkBCacheCore(BCacheCore#(Bit#(wayW), Bit#(tagW), Bit#(indexW), Bit#(offsetW)))
  provisos(Add#(tagW, __a, 32), Add#(indexW, __b, __a));
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bit#(tagW))) tagRam <- mkBram();
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bool)) validRam <- mkBram();
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bool)) dirtyRam <- mkBram();

  DualBramBE#(Bit#(TAdd#(wayW, TAdd#(indexW, offsetW))), 4) bram <- mkDualBramBE();
  BAcquireBlock#(TAdd#(wayW, TAdd#(indexW, offsetW)), 32, 4, TMul#(4, TExp#(offsetW)))
    rdAXI4 <- mkBAcquireBlock(bram.snd);
  BReleaseBlock#(TAdd#(wayW, TAdd#(indexW, offsetW)), 32, 4, TMul#(4, TExp#(offsetW)))
    wrAXI4 <- mkBReleaseBlock(bram.snd);
  let dataRam = bram.fst;

  Fifo#(1, Bit#(offsetW)) offsetQ <- mkPipelineFifo;
  Fifo#(1, Bit#(indexW))  indexQ <- mkPipelineFifo;
  Fifo#(1, Bit#(32))      dataQ <- mkPipelineFifo;
  Fifo#(1, Bit#(4))       maskQ <- mkPipelineFifo;
  Fifo#(1, Bit#(tagW))    tagQ <- mkPipelineFifo;
  Fifo#(1, Bit#(wayW))    wayQ <- mkPipelineFifo;
  Fifo#(1, CacheOp)       opQ <- mkPipelineFifo;

  // Length of a cache line
  Bit#(8) length = fromInteger(valueOf(TExp#(offsetW))-1);
  Integer ways = valueOf(TExp#(wayW));

  Reg#(Bit#(wayW)) randomWay <- mkReg(0);

  function Action doMiss(Bit#(wayW) way, Bit#(tagW) tag, CacheOp op, Bit#(32) data, Bit#(4) mask);
    action
      let index = indexQ.first;
      tagRam.write(index, Vector::update(tagRam.response(), way, tag));
      validRam.write(index, Vector::update(validRam.response(), way, True));
      dirtyRam.write(index, Vector::update(dirtyRam.response(), way, op == Write));
      dataQ.enq(data);
      maskQ.enq(mask);
      tagQ.enq(tag);
      wayQ.enq(way);
      opQ.enq(op);
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
    rdAXI4.acquireBlock({tag, index, 0}, {way, index, 0});
    wrAXI4.releaseBlockAck();
  endrule

  rule acquireLineAck if (started);
    rdAXI4.acquireBlockAck();

    let op <- toGet(opQ).get;
    let tag <- toGet(tagQ).get;
    let way <- toGet(wayQ).get;
    let data <- toGet(dataQ).get;
    let mask <- toGet(maskQ).get;
    let index <- toGet(indexQ).get;
    let offset <- toGet(offsetQ).get;

    case (op) matches
      Read : dataRam.read({way, index, offset});
      Write : dataRam.write({way, index, offset}, data, mask);
      Invalidate : noAction;
    endcase
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

  method Action matching(Bit#(tagW) t, CacheOp op, Bit#(32) data, Bit#(4) mask)
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
        if (op != Invalidate) begin
          offsetQ.deq;
          indexQ.deq;
        end

        case (op) matches
          Read :
            dataRam.read({way, index, offset});
          Write : begin
            dirtyRam.write(index, Vector::update(dirtyRam.response, way, True));
            dataRam.write({way, index, offset}, data, mask);
          end
          Invalidate : begin
            doMiss(way, t, op, data, mask);
            if (dirty) wrAXI4.releaseBlock({tag, index, 0}, {way, index, 0});
            else rdAXI4.acquireBlock({t, index, 0}, {way, index, 0});
          end
        endcase

      end else if (dirty && valid) begin
        // Release then acquire
        doMiss(way, t, op, data, mask);
        wrAXI4.releaseBlock({tag, index, 0}, {way, index, 0});
        //$display("start release");
      end else begin
        // Acquire
        doMiss(way, t, op, data, mask);
        rdAXI4.acquireBlock({t, index, 0}, {way, index, 0});
      end
    endaction
  endmethod

  method ActionValue#(Bit#(32)) readAck;
    dataRam.deq();
    return dataRam.response();
  endmethod

  interface read = rdAXI4.read;
  interface write = wrAXI4.write;
  method Action setID(Bit#(4) id);
    action
      rdAXI4.setID(id);
      wrAXI4.setID(id);
    endaction
  endmethod
endmodule

// Use ID 0 for the moment
interface BCache#(type wayT, type tagT, type indexT, type offsetT);
  interface RdAXI4_Lite_Slave#(32, 4) cpu_read;
  interface WrAXI4_Lite_Slave#(32, 4) cpu_write;

  method Action invalidate(Bit#(32) addr);
  method Action invalidateAck();

  interface RdAXI4_Master#(4, 32, 4) mem_read;
  interface WrAXI4_Master#(4, 32, 4) mem_write;
endinterface

module mkBCache(BCache#(Bit#(wayW), Bit#(tagW), Bit#(indexW), Bit#(offsetW)))
  provisos(Add#(tagW, __a, 32), Add#(indexW, __b, __a));
  BCacheCore#(Bit#(wayW), Bit#(tagW), Bit#(indexW), Bit#(offsetW)) cache <- mkBCacheCore();

  Fifo#(1, AXI4_Lite_RRequest#(32)) rreq <- mkPipelineFifo;
  Fifo#(1, AXI4_Lite_WRequest#(32, 4)) wreq <- mkPipelineFifo;
  Fifo#(1, Bit#(32)) invreq <- mkPipelineFifo;

  function Bit#(indexW) getIndex(Bit#(32) addr);
    return addr[2+valueOf(indexW)+valueOf(offsetW)-1: 2+valueOf(offsetW)];
  endfunction

  function Bit#(offsetW) getOffset(Bit#(32) addr);
    return addr[2+valueOf(offsetW)-1: 2];
  endfunction

  rule deqRdReq;
    let req = rreq.first;
    rreq.deq();

    cache.matching(truncateLSB(req.addr), Read, ?, ?);
  endrule

  rule setId0;
    cache.setID(0);
  endrule

  method Action invalidate(Bit#(32) addr);
    action
      cache.start(getIndex(addr), getOffset(addr));
      invreq.enq(addr);
    endaction
  endmethod

  method Action invalidateAck();
    action
      cache.matching(truncateLSB(invreq.first), Invalidate, ?, ?);
      invreq.deq();
    endaction
  endmethod

  interface RdAXI4_Lite_Slave cpu_read;
    interface Put request;
      method Action put(AXI4_Lite_RRequest#(32) request);
        cache.start(getIndex(request.addr), getOffset(request.addr));
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
        cache.start(getIndex(request.addr), getOffset(request.addr));
        wreq.enq(request);
      endmethod
    endinterface

    interface Get response;
      method ActionValue#(AXI4_Lite_WResponse) get();
        let req = wreq.first;
        wreq.deq();

        cache.matching(truncateLSB(req.addr), Write, req.bytes, req.strb);
        return AXI4_Lite_WResponse{resp: OKAY};
      endmethod
    endinterface
  endinterface

  interface mem_read = cache.read();
  interface mem_write = cache.write();
endmodule

(* synthesize *)
module mkDefaultBCache(BCache#(Bit#(2), Bit#(20), Bit#(6), Bit#(4)));
  let ifc <- mkBCache();
  return ifc;
endmodule
