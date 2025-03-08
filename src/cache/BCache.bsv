import BCacheUtils :: *;
import AXI4_Lite :: *;
import BlockRam :: *;
import GetPut :: *;
import Vector :: *;
import Utils :: *;
import Fifo :: *;
import AXI4 :: *;
import Ehr :: *;

typedef enum {
  Read, Write, Invalidate
} BCacheOp deriving(Bits, FShow, Eq);

// Blocking cache type
interface BCacheCore
  #(type wayT, type tagT, type indexT, type offsetT, numeric type wordW);
  // Start a memory operation
  method Action start(indexT index, offsetT offset);

  // Tag matching
    method Action matching(tagT tag, BCacheOp op, Byte#(wordW) data, Bit#(wordW) mask);

  // Acknoledge a read request
      method ActionValue#(Byte#(wordW)) readAck;

  interface RdAXI4_Master#(4, 32, 4) read;
  interface WrAXI4_Master#(4, 32, 4) write;
  method Action setID(Bit#(4) id);
endinterface

// All the informations about a cache request that we
// Save from the matching phase
typedef struct {
  Bit#(wayW) way;
  Bit#(tagW) tag;
  Byte#(wordW) data;
  Bit#(wordW) mask;
  BCacheOp op;
} BCacheInfo#(numeric type wayW, numeric type tagW, numeric type wordW)
deriving(FShow, Eq, Bits);

typedef enum {
  // Wait for a request
  Idle,
  // Wait for matching
  Matching,
  // Acquire+Release a cache line
  AcqRel,
  // Acquire a cache line
  Acquire,
  // Release a cache line (ex: Invalidation)
  Release
} CacheState deriving(FShow, Eq, Bits);

module mkBCacheCore
  (BCacheCore#(Bit#(wayW), Bit#(tagW), Bit#(indexW), Bit#(offsetW), wordW))
  provisos(Add#(tagW, __a, 32), Add#(indexW, __b, __a), Mul#(4, beatPerWord, wordW));
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bit#(tagW))) tagRam <- mkBram();
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bool)) dirtyRam <- mkBram();
  Bram#(Bit#(indexW), Vector#(TExp#(wayW), Bool)) validRam <-
    mkBramInit(replicate(False));

  let bram <- mkBramBE();
  Vector#(2, BramBE#(Bit#(TAdd#(wayW, TAdd#(indexW, offsetW))), wordW)) vbram
    <- mkVectorBramBE(bram);

  BAcquireBlock#(TAdd#(wayW, TAdd#(indexW, offsetW)), 32, 4, wordW, TMul#(wordW, TExp#(offsetW)))
    rdAXI4 <- mkBAcquireBlock(vbram[0]);
  BReleaseBlock#(TAdd#(wayW, TAdd#(indexW, offsetW)), 32, 4, wordW, TMul#(wordW, TExp#(offsetW)))
    wrAXI4 <- mkBReleaseBlock(vbram[0]);
  let dataRam = vbram[1];

  Reg#(Bit#(indexW)) index <- mkReg(0);
  Reg#(Bit#(offsetW)) offset <- mkReg(0);
  Reg#(BCacheInfo#(wayW, tagW, wordW)) info <- mkReg(?);
  Ehr#(2, CacheState) state <- mkEhr(Idle);

  Integer ways = valueOf(TExp#(wayW));

  Reg#(Bit#(wayW)) randomWay <- mkReg(0);

  Reg#(Bit#(32)) numHit <- mkReg(0);
  Reg#(Bit#(32)) numMis <- mkReg(0);

  function Action doMiss
    (Bit#(wayW) way, Bit#(tagW) tag, BCacheOp op, Byte#(wordW) data, Bit#(wordW) mask);
    action
      tagRam.write(index, update(tagRam.response(), way, tag));
      validRam.write(index, update(validRam.response(), way, True));
      dirtyRam.write(index, update(dirtyRam.response(), way, op == Write));
      let tmp = info;
      tmp.data = data;
      tmp.mask = mask;
      tmp.tag = tag;
      tmp.way = way;
      tmp.op = op;
      info <= tmp;
    endaction
  endfunction

  rule randomStep;
    randomWay <= randomWay + 1;
  endrule

  rule releaseBlockAck if (state[0] == AcqRel);
    rdAXI4.acquireBlock({info.tag, index, 0}, {info.way, index, 0});
    wrAXI4.releaseBlockAck();
    state[0] <= Acquire;
  endrule

  rule releaseBlockAckInv if (state[0] == Release);
    wrAXI4.releaseBlockAck();
    state[0] <= Idle;
  endrule

  rule acquireBlockAck if (state[0] == Acquire);
    rdAXI4.acquireBlockAck();

    state[0] <= Idle;

    case (info.op) matches
      Read : dataRam.read({info.way, index, offset});
      Write : dataRam.write({info.way, index, offset}, info.data, info.mask);
    endcase
  endrule

  method Action start(Bit#(indexW) idx, Bit#(offsetW) off)
    if (state[1] == Idle);
    action
      index <= idx;
      offset <= off;
      state[1] <= Matching;
      validRam.read(idx);
      dirtyRam.read(idx);
      tagRam.read(idx);
    endaction
  endmethod

  method Action matching
    (Bit#(tagW) t, BCacheOp op, Byte#(wordW) data, Bit#(wordW) mask)
    if (state[0] == Matching);
    action
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

      if (hit) numHit <= numHit + 1;
      else numMis <= numMis + 1;

      if (hit) begin
        // Cache hit
        if (op != Invalidate || !dirty) begin
          state[0] <= Idle;
        end

        case (op) matches
          Read :
            dataRam.read({way, index, offset});
          Write : begin
            dirtyRam.write(index, update(dirtyRam.response(), way, True));
            dataRam.write({way, index, offset}, data, mask);
          end
          Invalidate : if (dirty) begin
            doMiss(way, t, op, data, mask);
            wrAXI4.releaseBlock({tag, index, 0}, {way, index, 0});
            state[0] <= Release;
          end
        endcase

      end else if (dirty && valid) begin
        doMiss(way, t, op, data, mask);
        wrAXI4.releaseBlock({tag, index, 0}, {way, index, 0});
        state[0] <= AcqRel;
      end else begin
        doMiss(way, t, op, data, mask);
        rdAXI4.acquireBlock({t, index, 0}, {way, index, 0});
        state[0] <= Acquire;
      end
    endaction
  endmethod

  method ActionValue#(Byte#(wordW)) readAck;
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
interface BCache
  #(type wayT, type tagT, type indexT, type offsetT, numeric type logWordW);
  interface RdAXI4_Lite_Slave#(32, TExp#(logWordW)) cpu_read;
  interface WrAXI4_Lite_Slave#(32, TExp#(logWordW)) cpu_write;

  method Action invalidate(Bit#(32) addr);
  method Action invalidateAck();

  interface RdAXI4_Master#(4, 32, 4) mem_read;
  interface WrAXI4_Master#(4, 32, 4) mem_write;

  method Action setID(Bit#(4) id);
endinterface

module mkBCache
  (BCache#(Bit#(wayW), Bit#(tagW), Bit#(indexW), Bit#(offsetW), logWordW))
  provisos(
      Add#(tagW, __a, 32),
      Add#(indexW, __b, __a),
      Mul#(4, beatPerWord, wordW),
      NumAlias#(TExp#(logWordW), wordW)
  );

  BCacheCore#(Bit#(wayW), Bit#(tagW), Bit#(indexW), Bit#(offsetW), wordW) cache
    <- mkBCacheCore();

  Fifo#(1, AXI4_Lite_RRequest#(32)) rreq <- mkPipelineFifo;
  Fifo#(1, AXI4_Lite_WRequest#(32, wordW)) wreq <- mkPipelineFifo;
  Fifo#(1, Bit#(32)) invreq <- mkPipelineFifo;

  function Bit#(indexW) getIndex(Bit#(32) addr);
    return (addr >> valueOf(TAdd#(offsetW, logWordW)))[valueOf(indexW)-1: 0];
  endfunction

  function Bit#(offsetW) getOffset(Bit#(32) addr);
    return (addr >> valueOf(logWordW))[valueOf(offsetW)-1: 0];
  endfunction

  rule deqRdReq;
    let req = rreq.first;
    rreq.deq();

    cache.matching(truncateLSB(req.addr), Read, ?, ?);
  endrule

  method setID = cache.setID;

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
      method ActionValue#(AXI4_Lite_RResponse#(wordW)) get();
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
      method Action put(AXI4_Lite_WRequest#(32, wordW) request);
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
module mkDefaultBCache(BCache#(Bit#(2), Bit#(20), Bit#(7), Bit#(3), 2));
  let ifc <- mkBCache();
  return ifc;
endmodule
