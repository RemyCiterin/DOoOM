import FIFOF :: *;
import SpecialFIFOs :: *;
import GetPut :: *;
import Vector :: *;
import BlockRam :: *;
import AXI4 :: *;
import AXI4_Lite :: *;
import Utils :: *;
import OOO :: *;
import Ehr :: *;
import Fifo :: *;
import MSHR :: *;

import StmtFSM :: *;


// Interface of mkBram#(addrT, dataT)
//interface Bram#(type addrT, type dataT);
//  method Action write(addrT addr, dataT data);
//  method Action read(addrT addr);
//  method dataT response;
//  method Bool canDeq;
//  method Action deq;
//endinterface

// SRam type used in a cache pipeline
interface SRamPipe#(type addrT, type dataT);
  // Start a read-write operation, the pipeline is locked until we finish the
  // transaction with response < finish < start
  method Action start(addrT addr);

  // Ensure that the previous pipelined operation finish, and conflict with
  // itself (we can only call this operation one times per cycle)
  method Action sync;

  // Read the data at the address we start the pipeline
  method dataT response;

  // Finish the pipeline, and eventualy write a value
  method Action finish(Maybe#(dataT) value);

  // Write and bypass the pipeline, to do this operation we must ensure that we
  // doesn't write and perform a pipelined operation on the same address at the
  // same times, overwise one may observe race conditions...
  method Action unsafeWrite(addrT addr, dataT data);
endinterface

module mkSRamPipe#(Maybe#(dataT) initValue) (SRamPipe#(addrT, dataT))
  provisos (Bits#(addrT, addrWidth), Bits#(dataT, dataWidth), Eq#(addrT));
  Bram#(addrT, dataT) bram <- mkBram();

  Fifo#(1, addrT) currentAddr <- mkPipelineFifo;

  Reg#(Bit#(addrWidth)) initAddr <- mkReg(0);
  Reg#(Bool) initDone <- mkReg(!isJust(initValue));

  Wire#(void) sync_wire <- mkWire;

  if (initValue matches tagged Valid .val &&& !initDone) rule init;
    bram.write(unpack(initAddr), val);

    if (initAddr + 1 == 0) initDone <= True;
    initAddr <= initAddr + 1;
  endrule

  method Action sync if (currentAddr.canEnq);
    action
      sync_wire <= ?;
    endaction
  endmethod

  method Action start(addrT addr) if (initDone);
    action
      bram.read(addr);
      currentAddr.enq(addr);
    endaction
  endmethod

  method response = bram.response;

  method Action finish (Maybe#(dataT) data);
    action
      let addr = currentAddr.first;

      case (data) matches
        tagged Valid .d : bram.write(addr, d);
        .* : noAction;
      endcase

      currentAddr.deq;
      bram.deq;
    endaction
  endmethod

  method Action unsafeWrite(addrT addr, dataT data) if (initDone);
    bram.write(addr, data);
  endmethod
endmodule

// Type of a cache line
typedef Byte#(16) LineT;

// Type of a tag
typedef Bit#(20) TagT;

// Type of an index
typedef Bit#(8) IndexT;

// Offset in word in a cache line
typedef Bit#(2) OffsetT;

typedef struct {
  reqId id;
  Bool read;
  Bit#(32) addr; // must be aligned on 32 bits
  Bit#(32) data; // ignored if the access is a read
  Bit#(4) strb;  // ignored if the access is a read
} CpuRequest#(type reqId) deriving(Bits, Eq, FShow);

typedef struct {
  reqId id;
  Bool read;
  Bit#(32) data; // ignored if the access is a write
} CpuResponse#(type reqId) deriving(Bits, Eq, FShow);

// A struct used to send requests to the memory
typedef struct {
  TagT tag;
  IndexT index;
  OffsetT offset;
} Sender deriving(Bits, FShow, Eq);

// A struct used to send requests to the memory
typedef struct {
  TagT tag;
  IndexT index;
  OffsetT offset;
} Receiver deriving(Bits, FShow, Eq);


interface SimpleCache#(type reqId);
  method Action cpuRequest(CpuRequest#(reqId) request);
  method ActionValue#(CpuResponse#(reqId)) cpuResponse;

  // Directly communicate cache lines to the cache controller, no need for Id's
  // because their is no interconnect between the cache controller and the cache
  interface RdAXI4_Master#(4, 32, 4) mem_read;
  interface WrAXI4_Master#(4, 32, 4) mem_write;

  // set the ID for AXI4 messages
  method Action setID(Bit#(4) id);
endinterface

typedef enum {M, S, I} MSI deriving(Bits, FShow, Eq);

module mkCache(SimpleCache#(reqId))
  provisos (Bits#(reqId, _reqIdBits));

  // Index of a cache line in the cache
  function IndexT getIndex(Bit#(32) addr);
    return truncate(addr >> 4);
  endfunction

  // Tag of a cache line
  function TagT getTag(Bit#(32) addr);
    return truncateLSB(addr);
  endfunction

  // Offset (in words) in a cache line
  function OffsetT getOffset(Bit#(32) addr);
    return truncate(addr >> 2);
  endfunction

  // tagRam and stateRam are accessed in `pipelined-mode` only by
  // the request handling, the cache miss resolution only access these RAM
  // using the unsafeWrite primitive to avoid deadlock:
  // If a line is not present in the cache, the cache must allocate ressources
  // in the MSHR data structure (a request and eventualy a new register), but if
  // no ressources are available the cache may stall with these pipelined RAM in
  // a busy state, so the cache must not use this interface to free the
  // ressources in the MSHR to avoid deadlock
  SRamPipe#(IndexT, TagT) tagRam <- mkSRamPipe(Invalid);
  SRamPipe#(IndexT, MSI) stateRam <- mkSRamPipe(Valid(I));
  SRamPipe#(IndexT, Bool) pendingRam <- mkSRamPipe(Valid(False));
  Vector#(4, SRamPipe#(IndexT, Bit#(32))) dataRam <-
    replicateM(mkSRamPipe(Invalid));

  Fifo#(1, AXI4_RRequest#(4, 32)) mem_rd_req <- mkBypassFifo;
  Fifo#(1, AXI4_RResponse#(4, 4)) mem_rd_resp <- mkPipelineFifo;

  Fifo#(1, AXI4_AWRequest#(4, 32)) mem_awr_req <- mkBypassFifo;
  Fifo#(1, AXI4_WRequest#(4)) mem_wr_req <- mkBypassFifo;
  Fifo#(1, AXI4_WResponse#(4)) mem_wr_resp <- mkPipelineFifo;

  Reg#(Bit#(4)) axi4ID <- mkReg(0);

  // Queue of input requests from CPU
  Fifo#(1, CpuRequest#(reqId)) inputQ <- mkPipelineFifo;

  // requests that wait for a dataRam response, we remove the elements from this
  // queue in cpuResponse
  Fifo#(1, CpuRequest#(reqId)) outputQ <- mkPipelineFifo;

  MSHR#(4, 6, 28, CpuRequest#(reqId)) mshr <- mkMSHR;

  // MSHR to release
  Fifo#(10, Bit#(4)) mshrRelease <- mkPipelineFifo;

  // MSHR to acquire
  Fifo#(10, Bit#(4)) mshrAcquire <- mkPipelineFifo;

  // Take a request from the MSHR and read from the data BRAM
  rule freeEntryFromMSHR;
    let req <- mshr.freeEntry();
    let idx = getIndex(req.addr);
    let offset = getOffset(req.addr);

    dataRam[offset].start(idx);
    outputQ.enq(req);
  endrule

  rule finishFreeMSHR;
    mshr.freeDone;
  endrule

  rule matchReq;
    let req = inputQ.first;

    let idx = getIndex(req.addr);
    let offset = getOffset(req.addr);
    let t = getTag(req.addr);

    let pending = pendingRam.response;
    let state = stateRam.response;
    let tag = tagRam.response;

    if (t == tag && state != I && !pending) begin
      // Cache Hit
      outputQ.enq(req);
      dataRam[offset].start(idx);

      pendingRam.finish(Invalid);
      stateRam.finish(Invalid);
      tagRam.finish(Invalid);
      inputQ.deq;
    end else if (pending && t == tag && state != I) begin
      // Secondary Cache Miss: we must allocate a new MSHR sub-entry to finish
      // the request later
      mshr.allocEntry({tag, idx}, req);
      pendingRam.finish(Invalid);
      stateRam.finish(Invalid);
      tagRam.finish(Invalid);
      inputQ.deq;
    end else if (pending) begin
      // Primary Cache Miss but this cache line is busy by another cache miss...
      // So we must wait this cache miss to be resolved
      noAction;
    end else begin
      // Primary Cache Miss: we must allocate a new MSHR and start the cache
      // line refill
      let mshr_idx <- mshr.allocMSHR({tag, idx}, req);

      if (state == I)
        mshrAcquire.enq(mshr_idx);
      else
        mshrRelease.enq(mshr_idx);

      // Ensures that every observer reading data ram read the pending bit first
      for (Integer i=0; i < 4; i = i + 1) begin
        dataRam[i].sync();
      end

      // We must write the final state into the ram to not have deadlock
      pendingRam.finish(Valid(True));
      stateRam.finish(Valid(M));
      tagRam.finish(Valid(t));
      inputQ.deq;
    end
  endrule

  method ActionValue#(CpuResponse#(reqId)) cpuResponse;
    actionvalue
      let req = outputQ.first;
      outputQ.deq;

      let offset = getOffset(req.addr);
      let data = dataRam[offset].response;

      if (req.read) begin
        dataRam[offset].finish(Invalid);
      end else begin
        data = filterStrb(data, req.data, req.strb);
        dataRam[offset].finish(Valid(data));
      end

      return CpuResponse {
        id: req.id,
        read: req.read,
        data: data
      };
    endactionvalue
  endmethod

  method Action cpuRequest(CpuRequest#(reqId) request);
    action
      // Compute the cache line index
      IndexT index = getIndex(request.addr);

      // add the requests to the inputs to have it at the next stage
      inputQ.enq(request);

      // start all the pipelined SRAM blocks
      pendingRam.start(index);
      stateRam.start(index);
      tagRam.start(index);
    endaction
  endmethod

  interface RdAXI4_Master mem_read;
    interface request = toGet(mem_rd_req);
    interface response = toPut(mem_rd_resp);
  endinterface

  interface WrAXI4_Master mem_write;
    interface awrequest = toGet(mem_awr_req);
    interface wrequest = toGet(mem_wr_req);
    interface response = toPut(mem_wr_resp);
  endinterface

  method Action setID(Bit#(4) id);
    action
      axi4ID <= id;
    endaction
  endmethod
endmodule
