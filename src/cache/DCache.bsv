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

// This interface define the core of a 3 stages cache with one cycle read response
// and two cycles for a write.

// The first stage is in charge of selecting the index and the offset of the request,
// so it load the associated datas, tags and states for each ways.

// Then the cache receive the informations from it's BRAMs (data, tag, state,
// pending tag for each ways) and decide for how it finish the transaction:
// - In case of a cache miss it just set the pending tag at 1 so the
//   user may freely write back the previous cache line and load the new one
// - In case of a cache it the user write the data in case of a store and stop the transaction

// In case of a cache mis (stage 3) can update the data using the Bram interface,
// and unset the pending tag using the stopStage3 function, it update the tag and
// state of the cache line at the same time

interface DCachePipeCore#(
    numeric type numWays, // associativity of the cache
    numeric type tagWidth, // width of the tag used to check is
    numeric type indexWidth, // width of the index used to search for a cache line
    type state // state of a line (MSI, MOESI, ...)
  );
  /* Stage 1 */

  // Set the index of the line we request and load
  // all load the tags of all the lines that use it
  // and the word we search in the line at the given offset.
  // This method also acquire the cache
  method Action initStage1(
    Bit#(indexWidth) index,
    Bit#(TSub#(TSub#(30, tagWidth), indexWidth)) offset,
    Bool must_load
  );

  /* Stage 2 */

  // This stage allow to read all the data loaded by the previous stage and
  // - Either write into the cache and release the lock in case of a write
  // - Set a pair (index, way) as pending in case of a cache miss
  // - Just release the lock in case of a read cache hit/TLB miss

  // read the states of all the cache lines loaded by the initStage1 request
  method Vector#(numWays, state) getStatesStage2;
  // read the tags of all the cache lines loaded by the initStage1 request
  method Vector#(numWays, Bit#(tagWidth)) getTagsStage2;
  // read the words of all the cache lines loaded by the initStage1(_, offset) request
  method Vector#(numWays, Bit#(32)) getWordsStage2;
  // read the pending tags of all the cache lines loaded by the initStage1 request
  method Vector#(numWays, Bool) getPendingsStage2;

  // write into the word at the offset given by initStage1 and stop the transaction
  method Action writeStage2(Bit#(TLog#(numWays)) way, Bit#(32) data, Bit#(4) mask);

  // stop the transaction without doing anything (may be cause by a load success,
  // a TLB cache miss...)
  method Action stopStage2;

  // Set the line as pending, this mean that from the next cycle the stage3 has
  // a complete access to the data, state and tag of this pair (index, way)
  method Action setPendingStage2(Bit#(TLog#(numWays)) way);


  /* Stage 3 */
  // We see at stage 2 that their is a cache miss, now we have to:
  // - evnetualy write back the cache line we decide to evict
  // - load the new cache line, its state and tag
  // - then finish the transaction by calling unsetPending(index, way, newTag, newState)

  // user must care about the index he read/write because
  interface Vector#(numWays, BramBE#(Bit#(TSub#(30, tagWidth)), 4)) bram;

  // unset the pending tag of the cache line and update it's tag/state
  method Action stopStage3(
    Bit#(indexWidth) index,
    Bit#(TLog#(numWays)) way,
    Bit#(tagWidth) newTag,
    state newState
  );
endinterface

module mkDCachePipeCore#(lineState initState)
  (DCachePipeCore#(numWays, tagWidth, indexWidth, lineState))
  provisos (
    Bits#(lineState, lineStateSz)
  );

  Reg#(Bit#(indexWidth)) init_addr <- mkReg(0);
  Reg#(Bool) is_init <- mkReg(False);

  Ehr#(2, Maybe#(Bit#(indexWidth))) indexStage12 <- mkEhr(Invalid);
  Ehr#(2, Bit#(TSub#(TSub#(30, tagWidth), indexWidth))) offsetStage12 <- mkEhr(?);
  Ehr#(2, Bool) mustLoadStage12 <- mkEhr(?);

  Vector#(numWays, Bram#(Bit#(indexWidth), lineState)) stateRam <- replicateM(mkBram);
  Vector#(numWays, Bram#(Bit#(indexWidth), Bit#(tagWidth))) tagRam <- replicateM(mkBram);
  Vector#(numWays, Bram#(Bit#(indexWidth), Bool)) pendingRam <- replicateM(mkBram);

  Vector#(numWays, BramBE#(Bit#(TSub#(30, tagWidth)), 4)) dataRam
    <- replicateM(mkBramBE);


  function Action stopStage2Fn;
    action
      indexStage12[0] <= Invalid;
      for (Integer i=0; i < valueOf(numWays); i = i + 1) begin
        if (mustLoadStage12[0]) dataRam[i].deq;
        pendingRam[i].deq;
        stateRam[i].deq;
        tagRam[i].deq;
      end
    endaction
  endfunction

  rule initRl if (!is_init);
    for (Integer i=0; i < valueOf(numWays); i = i + 1) begin
      stateRam[i].write(init_addr, initState);
    end

    if (init_addr == -1) is_init <= True;
    init_addr <= init_addr + 1;
  endrule

  method Action initStage1(
    Bit#(indexWidth) index,
    Bit#(TSub#(TSub#(30, tagWidth), indexWidth)) offset,
    Bool must_load
  ) if (indexStage12[1] matches Invalid &&& is_init);
    action
      offsetStage12[1] <= offset;
      mustLoadStage12[1] <= must_load;
      indexStage12[1] <= tagged Valid index;

      for (Integer i=0; i < valueOf(numWays); i = i + 1) begin
        if (must_load) dataRam[i].read({index, offset});
        pendingRam[i].read(index);
        stateRam[i].read(index);
        tagRam[i].read(index);
      end
    endaction
  endmethod

  method Vector#(numWays, lineState) getStatesStage2 if (is_init);
    Vector#(numWays, lineState) out = newVector;

    for (Integer i=0; i < valueOf(numWays); i = i + 1) begin
      out[i] = stateRam[i].response;
    end

    return out;
  endmethod

  method Vector#(numWays, Bit#(tagWidth)) getTagsStage2 if (is_init);
    Vector#(numWays, Bit#(tagWidth)) out = newVector;

    for (Integer i=0; i < valueOf(numWays); i = i + 1) begin
      out[i] = tagRam[i].response;
    end

    return out;
  endmethod

  method Vector#(numWays, Bool) getPendingsStage2 if (is_init);
    Vector#(numWays, Bool) out = newVector;

    for (Integer i=0; i < valueOf(numWays); i = i + 1) begin
      out[i] = pendingRam[i].response;
    end

    return out;
  endmethod

  method Vector#(numWays, Bit#(32)) getWordsStage2 if (is_init);
    Vector#(numWays, Bit#(32)) out = newVector;

    for (Integer i=0; i < valueOf(numWays); i = i + 1) begin
      out[i] = dataRam[i].response;
    end

    return out;
  endmethod

  method Action stopStage2
    if (indexStage12[0] matches tagged Valid .* &&& is_init);
    stopStage2Fn;
  endmethod

  method Action writeStage2(Bit#(TLog#(numWays)) way, Bit#(32) data, Bit#(4) mask)
    if (indexStage12[0] matches tagged Valid .idx &&& offsetStage12[0] matches .offset &&& is_init);
    action
      dataRam[way].write({idx, offset}, data, mask);
      stopStage2Fn;
    endaction
  endmethod

  method Action setPendingStage2(Bit#(TLog#(numWays)) way)
    if (indexStage12[0] matches tagged Valid .idx &&& is_init);
    action
      pendingRam[way].write(idx, True);
      stopStage2Fn;
    endaction
  endmethod


  method Action stopStage3(
      Bit#(indexWidth) index, Bit#(TLog#(numWays)) way,
      Bit#(tagWidth) newTag, lineState newState
    ) if (is_init);
    action
      pendingRam[way].write(index, False);
      stateRam[way].write(index, newState);
      tagRam[way].write(index, newTag);
    endaction
  endmethod

  interface bram = dataRam;
endmodule

interface DCache;
  interface RdAXI4_Lite_Slave#(32, 4) cpu_read;
  interface WrAXI4_Lite_Slave#(32, 4) cpu_write;

  interface RdAXI4_Master#(4, 32, 4) mem_read;
  interface WrAXI4_Master#(4, 32, 4) mem_write;
endinterface

typedef union tagged {
  void Idle; // the cache can process cpu requests
  struct {
    Bit#(20) prevTag;
    Bit#(20) newTag;
    Bit#(6) index;
    Bit#(1) way;
    Bit#(32) length;
    Bit#(4) offset;
  } Release; // the cache is blocked because it has to write back a cache line first
  struct {
    Bit#(20) tag;
    Bit#(6) index;
    Bit#(1) way;
    Bit#(32) length;
    Bit#(4) offset;
  } Acquire; // the cache is blocked because it has to load a cache line first
} DCacheState deriving(Bits, FShow, Eq);

module mkDCache(DCache);
  // the cache has 2 way, tags are of size 20, indexes of size 6, and offset of size 6
  // This cache may block: it wait each release and acquire requests before accepting a new request
  DCachePipeCore#(2, 20, 6, Bool) core <- mkDCachePipeCore(False);

  function Bit#(20) getTag(Bit#(32) addr);
    return truncateLSB(addr);
  endfunction

  function Bit#(6) getIndex(Bit#(32) addr);
    return truncate(addr >> 6);
  endfunction

  function Bit#(4) getOffset(Bit#(32) addr);
    return truncate(addr >> 2);
  endfunction

  FIFOF#(AXI4_Lite_RRequest#(32)) cpu_rd_req <- mkBypassFIFOF;
  FIFOF#(AXI4_Lite_RResponse#(4)) cpu_rd_resp <- mkPipelineFIFOF;

  FIFOF#(AXI4_Lite_WRequest#(32, 4)) cpu_wr_req <- mkBypassFIFOF;
  FIFOF#(AXI4_Lite_WResponse) cpu_wr_resp <- mkPipelineFIFOF;

  FIFOF#(AXI4_RRequest#(4, 32)) mem_rd_req <- mkBypassFIFOF;
  FIFOF#(AXI4_RResponse#(4, 4)) mem_rd_resp <- mkPipelineFIFOF;

  FIFOF#(AXI4_AWRequest#(4, 32)) mem_awr_req <- mkBypassFIFOF;
  FIFOF#(AXI4_WRequest#(4)) mem_wr_req <- mkBypassFIFOF;
  FIFOF#(AXI4_WResponse#(4)) mem_wr_resp <- mkPipelineFIFOF;

  Reg#(DCacheState) state <- mkReg(Idle);

  FIFOF#(Bool) put_read_in_stage1 <- mkPipelineFIFOF;

  Reg#(Bit#(1)) randomWay <- mkReg(0);

  FIFOF#(Tuple2#(Bit#(1), Bit#(10))) bram_rd_req <- mkBypassFIFOF;
  FIFOF#(void) must_deq_wresp <- mkPipelineFIFOF;

  Reg#(Bit#(32)) cycle <- mkReg(0);

  Reg#(Bit#(32)) stale <- mkReg(0);
  Reg#(Bit#(32)) nbAcquires <- mkReg(0);
  Reg#(Bit#(32)) nbReleases <- mkReg(0);

  function Action cacheMis(Bit#(32) addr, Bit#(20) prevTag, Bool must_release);
    action
      let tag = getTag(addr);
      let index = getIndex(addr);
      core.setPendingStage2(randomWay);
      nbAcquires <= nbAcquires + 1;

      if (must_release) begin
        nbReleases <= nbReleases + 1;

        //Bit#(32) release_addr = {prevTag, getIndex(addr), 0};
        //$display("release %h", release_addr);
        //Bit#(32) acquire_addr = {tag, getIndex(addr), 0};
        //$display("acquire %h", acquire_addr);

        bram_rd_req.enq(Tuple2{fst: randomWay, snd: {index, 0}});
        mem_awr_req.enq(AXI4_AWRequest{
            addr: {prevTag, getIndex(addr), 0},
            burst: WRAP,
            length: 15,
            id: 0
        });

        must_deq_wresp.enq(?);
        state <= tagged Release {
          prevTag: prevTag,
          newTag: tag,
          index: index,
          way: randomWay,
          length: 15,
          offset: 0
        };
      end else begin
        //Bit#(32) acquire_addr = {tag, getIndex(addr), 0};
        //$display("acquire %h", acquire_addr);

        mem_rd_req.enq(AXI4_RRequest{
          addr: {tag, getIndex(addr), 0},
          burst: WRAP,
          length: 15,
          id: 0
        });

        state <= tagged Acquire {
          tag: tag,
          index: index,
          way: randomWay,
          length: 15,
          offset: 0
        };
      end
    endaction
  endfunction

  rule upd_cycle;
    cycle <= cycle + 1;

    if (state != Idle) stale <= stale + 1;

    //if ((cycle & 'h1FFF) == 0) begin
    //  $display("cycle: %d stale: %d acquires: %d releases %d",
    //    cycle, stale, nbAcquires, nbReleases);
    //end
  endrule

  rule deq_bram_rd_req if (state != Idle);
    match {.way, .addr} = bram_rd_req.first;
    core.bram[way].read(addr);
    bram_rd_req.deq;
  endrule

  rule release_cache_line if (state matches tagged Release .rel);
    let bytes = core.bram[rel.way].response;
    core.bram[rel.way].deq;

    mem_wr_req.enq(AXI4_WRequest{
      last: rel.length == 0,
      bytes: bytes,
      strb: 4'b1111
    });

    //$display("release addr: %h data: %h", {rel.prevTag, rel.index, rel.offset, 2'b0}, bytes);

    if (rel.length == 0) begin
      mem_rd_req.enq(AXI4_RRequest{
        addr: {rel.newTag, rel.index, 0},
        length: 15,
        burst: WRAP,
        id: 0
      });

      state <= tagged Acquire {
        tag: rel.newTag,
        index: rel.index,
        way: rel.way,
        length: 15,
        offset: 0
      };
    end else begin
      bram_rd_req.enq(Tuple2{fst: rel.way, snd: {rel.index, rel.offset+1}});
      state <= tagged Release {
        newTag: rel.newTag,
        prevTag: rel.prevTag,
        index: rel.index,
        way: rel.way,
        length: rel.length - 1,
        offset: rel.offset + 1
      };
    end
  endrule

  rule acquire_cache_line if (state matches tagged Acquire .acq);
    let resp = mem_rd_resp.first;
    mem_rd_resp.deq;

    //$display("acquire addr: %h data: %h", {acq.tag, acq.index, acq.offset, 2'b0}, resp.bytes);
    core.bram[acq.way].write({ acq.index, acq.offset }, resp.bytes, 4'b1111);

    if (acq.length == 0) begin
      state <= Idle;
      core.stopStage3(acq.index, acq.way, acq.tag, True);
    end else begin
      state <= tagged Acquire {
        tag: acq.tag,
        way: acq.way,
        index: acq.index,
        length: acq.length - 1,
        offset: acq.offset + 1
      };
    end
  endrule

  rule incr_randomWay;
    randomWay <= randomWay + 1;
  endrule

  rule deq_wresp;
    must_deq_wresp.deq;
    mem_wr_resp.deq;
  endrule

  rule stage1_read if (state == Idle && !must_deq_wresp.notEmpty);
    let addr = cpu_rd_req.first.addr;
    core.initStage1(getIndex(addr), getOffset(addr), True);
    put_read_in_stage1.enq(True);
  endrule

  rule stage1_write if (state == Idle && !cpu_rd_req.notEmpty && !must_deq_wresp.notEmpty);
    let addr = cpu_wr_req.first.addr;
    core.initStage1(getIndex(addr), getOffset(addr), False);
    put_read_in_stage1.enq(False);
  endrule

  rule stage2_read if (state == Idle && put_read_in_stage1.first);
    let addr = cpu_rd_req.first.addr;
    let tag = getTag(addr);

    let tags = core.getTagsStage2;
    let pendings = core.getPendingsStage2;
    let states = core.getStatesStage2;
    let words = core.getWordsStage2;

    if (tag == tags[0] && states[0]) begin
      // cache hit at the way 0
      cpu_rd_resp.enq(AXI4_Lite_RResponse{
        bytes: words[0],
        resp: OKAY
      });

      //$display("read %h %h %h %h %b", addr, words[0], tag, tags[0], states[0]);

      core.stopStage2;
      put_read_in_stage1.deq;
      cpu_rd_req.deq;
    end else if (tag == tags[1] && states[1]) begin
      // cache hit at the way 1
      cpu_rd_resp.enq(AXI4_Lite_RResponse{
        bytes: words[1],
        resp: OKAY
      });

      //$display("read %h %h %h %h %b", addr, words[1], tag, tags[1], states[1]);

      core.stopStage2;
      put_read_in_stage1.deq;
      cpu_rd_req.deq;
    end else begin
      // cache mis
      cacheMis(addr, tags[randomWay], states[randomWay]);
      put_read_in_stage1.deq;
    end
  endrule

  rule stage2_write if (state == Idle && !put_read_in_stage1.first);
    let addr = cpu_wr_req.first.addr;
    let data = cpu_wr_req.first.bytes;
    let mask = cpu_wr_req.first.strb;
    let tag = getTag(addr);

    let tags = core.getTagsStage2;
    let pendings = core.getPendingsStage2;
    let states = core.getStatesStage2;

    if (tag == tags[0] && states[0]) begin
      // cache hit at the way 0
      cpu_wr_resp.enq(AXI4_Lite_WResponse{
        resp: OKAY
      });

      //$display("write %h %h %b", addr, data, mask);

      core.writeStage2(0, data, mask);
      put_read_in_stage1.deq;
      cpu_wr_req.deq;
    end else if (tag == tags[1] && states[1]) begin
      // cache hit at the way 1
      cpu_wr_resp.enq(AXI4_Lite_WResponse{
        resp: OKAY
      });

      //$display("write %h %h %b", addr, data, mask);

      core.writeStage2(1, data, mask);
      put_read_in_stage1.deq;
      cpu_wr_req.deq;
    end else begin
      // cache mis
      //$display("cache miss: %h %b", addr, states[randomWay]);
      cacheMis(addr, tags[randomWay], states[randomWay]);
      put_read_in_stage1.deq;
    end
  endrule

  interface RdAXI4_Lite_Slave cpu_read;
    interface request = toPut(cpu_rd_req);
    interface response = toGet(cpu_rd_resp);
  endinterface

  interface WrAXI4_Lite_Slave cpu_write;
    interface request = toPut(cpu_wr_req);
    interface response = toGet(cpu_wr_resp);
  endinterface

  interface RdAXI4_Master mem_read;
    interface request = toGet(mem_rd_req);
    interface response = toPut(mem_rd_resp);
  endinterface

  interface WrAXI4_Master mem_write;
    interface wrequest = toGet(mem_wr_req);
    interface awrequest = toGet(mem_awr_req);
    interface response = toPut(mem_wr_resp);
  endinterface
endmodule



