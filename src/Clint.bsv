// implement a Clint (Core-local intrrupt controller) to control timer
// interrupts

import Core :: *;
import AXI4 :: *;
import AXI4_Lite :: *;
import Utils :: *;

import RegFile :: *;
import GetPut :: *;
import UART :: *;
import Fifo :: *;
import Ehr :: *;
import Screen :: *;


interface CLINT_AXI4_Lite;
  interface RdAXI4_Lite_Slave#(32, 4) read;
  interface WrAXI4_Lite_Slave#(32, 4) write;

  method Bool timer_interrupt;
  method Bool software_interrupt;
endinterface

module mkCLINT_AXI4_Lite#(Bit#(32) clint_addr) (CLINT_AXI4_Lite);
  Fifo#(2, AXI4_Lite_RRequest#(32)) rrequest <- mkFifo;
  Fifo#(1, AXI4_Lite_RResponse#(4)) rresponse <- mkBypassFifo;

  Fifo#(2, AXI4_Lite_WRequest#(32, 4)) wrequest <- mkFifo;
  Fifo#(1, AXI4_Lite_WResponse) wresponse <- mkBypassFifo;

  Reg#(Bit#(64)) mtimecmp <- mkReg(0);
  Reg#(Bit#(64)) mtime <- mkReg(0);
  Reg#(Bit#(1)) msip <- mkReg(0);

  rule count_timer;
    mtime <= mtime + 1;
  endrule

  rule read_rl;
    let req = rrequest.first;
    rrequest.deq;

    AXI4_Lite_Response resp = OKAY;
    Bit#(32) bytes = 0;

    case (req.addr - clint_addr)
      0: bytes = zeroExtend(msip);
      'h4000: bytes = truncate(mtimecmp);
      'h4004: bytes = truncateLSB(mtimecmp);
      'hBFF8: bytes = truncate(mtime);
      'hBFFC: bytes = truncateLSB(mtime);
      default: resp = SLVERR;
    endcase

    rresponse.enq(AXI4_Lite_RResponse{
      bytes: bytes, resp: resp
    });
  endrule

  rule write_rl;
    let req = wrequest.first;
    wrequest.deq;

    AXI4_Lite_Response resp = OKAY;

    case (req.addr - clint_addr)
      0: if (req.strb[0] == 1) msip <= req.bytes[0];
      'h4000:
        mtimecmp <= {
          truncateLSB(mtimecmp),
          filterStrb(truncate(mtimecmp), req.bytes, req.strb)
        };
      'h4004:
        mtimecmp <= {
          filterStrb(truncateLSB(mtimecmp), req.bytes, req.strb),
          truncate(mtimecmp)
        };
      default: resp = SLVERR;
    endcase

    wresponse.enq(AXI4_Lite_WResponse{resp: resp});
  endrule

  interface RdAXI4_Lite_Slave read;
    interface request = toPut(rrequest);
    interface response = toGet(rresponse);
  endinterface

  interface WrAXI4_Lite_Slave write;
    interface request = toPut(wrequest);
    interface response = toGet(wresponse);
  endinterface

  method Bool software_interrupt = msip == 1;

  method Bool timer_interrupt = mtime >= mtimecmp;
endmodule
