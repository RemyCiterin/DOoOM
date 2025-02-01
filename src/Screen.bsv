import SpecialFIFOs :: *;
import BlockRam :: *;
import GetPut :: *;
import FIFOF :: *;
import Ehr :: *;

// Fabric interface (system verilog size) of the screen buffer
interface VGAFabric;
  (* always_ready, always_enabled, result= "vga_hsync" *)
  method Bool hsync;

  (* always_ready, always_enabled, result= "vga_vsync" *)
  method Bool vsync;

  (* always_ready, always_enabled, result= "vga_blank" *)
  method Bool blank;

  (* always_ready, always_enabled, result= "vga_red" *)
  method Bit#(8) red;

  (* always_ready, always_enabled, result= "vga_blue" *)
  method Bit#(8) blue;

  (* always_ready, always_enabled, result= "vga_green" *)
  method Bit#(8) green;
endinterface

interface VGA;
  (* prefix = "" *)
  interface VGAFabric fabric;

  // CPU interface to write data into the VGA frame buffer
  method Action write(Bit#(32) addr, Bit#(32) data, Bit#(4) mask);
endinterface

module mkVGA(VGA);
  // project a 8-8-4 color into the Red component
  function Bit#(8) projRed(Bit#(8) color);
    return case (color[7:5]) matches
      3'b000 : 8'h00;
      3'b001 : 8'h24;
      3'b010 : 8'h49;
      3'b011 : 8'h6d;
      3'b100 : 8'h92;
      3'b101 : 8'hb6;
      3'b110 : 8'hdb;
      3'b111 : 8'hff;
    endcase;
  endfunction

  // project a 8-8-4 color into the Green component
  function Bit#(8) projGreen(Bit#(8) color);
    return case (color[4:2]) matches
      3'b000 : 8'h00;
      3'b001 : 8'h24;
      3'b010 : 8'h49;
      3'b011 : 8'h6d;
      3'b100 : 8'h92;
      3'b101 : 8'hb6;
      3'b110 : 8'hdb;
      3'b111 : 8'hff;
    endcase;
  endfunction

  // project a 8-8-4 color into the Blue component
  function Bit#(8) projBlue(Bit#(8) color);
    return case (color[1:0]) matches
      2'b00 : 8'h00;
      2'b01 : 8'h55;
      2'b10 : 8'haa;
      2'b11 : 8'hff;
    endcase;
  endfunction


  // Fabric parameters of the vga interface
  Integer hwidth = 640;
  Integer vwidth = 480;

  Integer hsync_front_porch = 16;
  Integer hsync_pulse_width = 96;
  Integer hsync_back_porch = 48;

  Integer vsync_front_porch = 11;
  Integer vsync_pulse_width = 2;
  Integer vsync_back_porch = 31;

  Integer hframe = hwidth + hsync_front_porch + hsync_pulse_width + hsync_back_porch;
  Integer vframe = vwidth + vsync_front_porch + vsync_pulse_width + vsync_back_porch;

  // CPU parameters of the vga interface
  Integer xmax = hwidth;
  Integer ymax = vwidth;

  // Frame buffer
  RWBit32Bram#(Bit#(32)) bram <- mkRWBit32BramOfSize(xmax * ymax / 4);

  // Fabric registers
  Reg#(Bit#(32)) fabric_addr <- mkReg(0);
  Reg#(Bit#(10)) hpos <- mkReg(0);
  Reg#(Bit#(10)) vpos <- mkReg(0);

  Reg#(File) file <- mkReg(InvalidFile);

  function Bit#(32) getFabricAddr;
    Bit#(20) h = zeroExtend(hpos);
    Bit#(20) v = zeroExtend(vpos);

    Bit#(32) ret = zeroExtend(h + v * fromInteger(xmax));
    return (ret >= fromInteger(xmax * ymax) ? 0 : ret);
  endfunction

  function Bit#(8) getFabricResponse;
    let x = bram.response;

    return case (fabric_addr[1:0]) matches
      2'b00 : x[7:0];
      2'b01 : x[15:8];
      2'b10 : x[23:16];
      2'b11 : x[31:24];
    endcase;
  endfunction

  rule deqBramResp;
    bram.deq;
  endrule

  rule openFile if (file == InvalidFile);
    File f <- $fopen("screen.txt", "w");
    file <= f;
  endrule

  rule enqBramRead;
    let addr = getFabricAddr;
    bram.read(zeroExtend(addr[31:2]));
  endrule

  // Write into all the fabric wires
  (* no_implicit_conditions, fire_when_enabled *)
  rule fabric_write;
    let next_hpos = (hpos+1 >= fromInteger(hframe) ? 0 : hpos + 1);
    let next_vpos =
      (hpos+1 >= fromInteger(hframe) ? (vpos+1 >= fromInteger(vframe) ? 0 : vpos+1) : vpos);

    fabric_addr <= getFabricAddr;
    hpos <= next_hpos;
    vpos <= next_vpos;
  endrule

  method Action write(Bit#(32) addr, Bit#(32) data, Bit#(4) mask);
    if (file != InvalidFile)
      $fdisplay(file, "%d %d %d", addr, data, mask);
    bram.write(addr, data, mask);
  endmethod

  interface VGAFabric fabric;
    method hsync =
      hpos < fromInteger(hwidth + hsync_front_porch) ||
      hpos >= fromInteger(hframe - hsync_back_porch);

    method vsync =
      vpos < fromInteger(vwidth + vsync_front_porch) ||
      vpos >= fromInteger(vframe - vsync_back_porch);

    method blank =
      hpos >= fromInteger(hwidth) || vpos >= fromInteger(vwidth);

    method red =
      (bram.canDeq ? projRed(getFabricResponse) : 0);

    method green =
      (bram.canDeq ? projGreen(getFabricResponse) : 0);

    method blue =
      (bram.canDeq ? projBlue(getFabricResponse) : 0);
  endinterface
endmodule



