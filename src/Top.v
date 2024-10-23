
module mkTop (
  input CLK,
  input RST_N,

  output [7:0] led,
  output ftdi_rxd,
  input ftdi_txd,

  output sdram_clk, // clock ram
  output sdram_cke,
  inout [15:0] sdram_d,
  output [12:0] sdram_a,
  output [1:0] sdram_ba,
  output [1:0] sdram_dqm,
  output sdram_csn,
  output sdram_wen,
  output sdram_rasn,
  output sdram_casn,

  input [6:1] btn,

  // DVI output
  output [3:0] gpdi_dp
);

  parameter C_ddr = 1'b1;

  //wire [7:0] led;

  wire awvalid;
  wire awready;
  wire [31:0] awaddr;
  wire [7:0] awlen;
  wire [1:0] awburst;
  wire [3:0] awid;

  wire wready;
  wire wvalid;
  wire [31:0] wdata;
  wire [3:0] wstrb;
  wire wlast;

  wire bready;
  wire bvalid;
  wire [1:0] bresp;
  wire [3:0] bid;

  wire arready;
  wire arvalid;
  wire [31:0] araddr;
  wire [1:0] arburst;
  wire [7:0] arlen;
  wire [3:0] arid;

  wire rready;
  wire rvalid;
  wire [31:0] rdata;
  wire [1:0] rresp;
  wire rlast;
  wire [3:0] rid;

  wire [15:0] sdram_d_in;
  wire [15:0] sdram_d_out;
  wire sdram_d_out_en;

  assign sdram_d_in = sdram_d;
  assign sdram_d = sdram_d_out_en ? sdram_d_out : 16'hzzzz;
  //genvar i;
  //for (i=0; i < 16; i = i + 1)
  //begin
  //  IOBUF
  //  #(
  //    .DRIVE(12),
  //    .IOSTANDARD("LVTTL"),
  //    .SLEW("FAST")
  //  )
  //  u_data_buf
  //  (
  //    .O(sdram_d_in[i]),
  //    .IO(sdram_d[i]),
  //    .I(sdram_d_out[i]),
  //    .T(~sdram_d_out_en)
  //  );
  //end

  reg [31:0] cycles = 0;

  always @(posedge CLK) begin
    cycles <= cycles + 1;
    // if (RST_N) $display("reset: ", RST_N, " at ", cycles);
    //if (arready) $display("read ready at ", cycles);
    //if (awready) $display("write address ready at ", cycles);
    //if (wready) $display("write ready at ", cycles);
    //if (awvalid) $display("write address valid at ", cycles);
    //if (wvalid) $display("write valid at ", cycles);
    //if (bready) $display("write response ready at ", cycles);
  end

  // reg [15:0] sdram_d_in_buff;
  // always @(posedge clk) sdram_d_in_buff <= sdram_d;
  // assign sdram_d_in = sdram_d_in_buff;

// DVI output clock
  wire clkdvi;
  wire clkvga;

  // VGA signals
  wire vga_hsync, vga_vsync, vga_blank;
  // wire video;
  wire [7:0] r_video;
  wire [7:0] g_video;
  wire [7:0] b_video;


  // converter from VGA to DVI
  wire [1:0] tmds[3:0];

  `ifndef __ICARUS__
  vga2dvid
  #(
    .C_ddr(C_ddr),
    .C_shift_clock_synchronizer(1'b1)
  )
  vga2dvid_instance
  (
    .clk_pixel(CLK),
    .clk_shift(clkdvi),
    .in_red(r_video),
    .in_green(g_video),
    .in_blue(b_video),
    .in_hsync(vga_hsync),
    .in_vsync(vga_vsync),
    .in_blank(vga_blank),
    .out_clock(tmds[3]),
    .out_red(tmds[2]),
    .out_green(tmds[1]),
    .out_blue(tmds[0])
  );

  fake_differential
  #(
    .C_ddr(C_ddr)
  )
  fake_differential_instance
  (
    .clk_shift(clkdvi),
    .in_clock(tmds[3]),
    .in_red(tmds[2]),
    .in_green(tmds[1]),
    .in_blue(tmds[0]),
    .out_p(gpdi_dp),
    .out_n(gpdi_dn)
  );

  // clock generation for the DVI output
  clk_25_system
  clk_25_system_inst
  (
    .clk_in(CLK),
    .pll_125(clkdvi), // 125 Mhz, DDR bit rate
    .pll_25(clkvga)   //  25 Mhz, VGA pixel rate
  );
  `endif



  sdram_axi #(.SDRAM_ADDR_W(24), .SDRAM_MHZ(25)) sdram (
    .clk_i(CLK),
    .rst_i(!RST_N),

    // AXI port
    .inport_awvalid_i(awvalid),
    .inport_awaddr_i(awaddr),
    .inport_awid_i(awid),
    .inport_awlen_i(awlen),
    .inport_awburst_i(awburst),
    .inport_wvalid_i(wvalid),
    .inport_wdata_i(wdata),
    .inport_wstrb_i(wstrb),
    .inport_wlast_i(wlast),
    .inport_bready_i(bready),
    .inport_arvalid_i(arvalid),
    .inport_araddr_i(araddr),
    .inport_arid_i(arid),
    .inport_arlen_i(arlen),
    .inport_arburst_i(arburst),
    .inport_rready_i(rready),
    .inport_awready_o(awready),
    .inport_wready_o(wready),
    .inport_bvalid_o(bvalid),
    .inport_bresp_o(bresp),
    .inport_bid_o(bid),
    .inport_arready_o(arready),
    .inport_rvalid_o(rvalid),
    .inport_rdata_o(rdata),
    .inport_rresp_o(rresp),
    .inport_rid_o(rid),
    .inport_rlast_o(rlast),

    // SDRAM Interface
    .sdram_clk_o(sdram_clk),
    .sdram_cke_o(sdram_cke),
    .sdram_cs_o(sdram_csn),
    .sdram_ras_o(sdram_rasn),
    .sdram_cas_o(sdram_casn),
    .sdram_we_o(sdram_wen),
    .sdram_dqm_o(sdram_dqm),
    .sdram_addr_o(sdram_a),
    .sdram_ba_o(sdram_ba),
    .sdram_data_input_i(sdram_d_in),
    .sdram_data_output_o(sdram_d_out),
    .sdram_data_out_en_o(sdram_d_out_en)
  );

  mkCPU cpu(
    .CLK(CLK),
    .RST_N(RST_N),
    .awvalid(awvalid),
    .awready(awready),
    .awaddr(awaddr),
    .awlength(awlen),
    .awburst(awburst),
    .awid(awid),

    .wready(wready),
    .wvalid(wvalid),
    .wdata(wdata),
    .wstrb(wstrb),
    .wlast(wlast),

    .bready(bready),
    .bvalid(bvalid),
    .bresp(bresp),
    .bid(bid),

    .arready(arready),
    .arvalid(arvalid),
    .araddr(araddr),
    .arburst(arburst),
    .arlength(arlen),
    .arid(arid),

    .rready(rready),
    .rvalid(rvalid),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rid(rid),

    .led(led),
    .ftdi_rxd(ftdi_rxd),
    .ftdi_txd(ftdi_txd),



    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync),
    .vga_blank(vga_blank),
    .vga_red(r_video),
    .vga_green(g_video),
    .vga_blue(b_video),
    .btn(btn)
  );

endmodule
