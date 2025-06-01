`timescale 1ns / 100ps

module nexysvideo_ddr3 (
  input                   clk100mhz,
  input wire i_rst,
  // UART line
  input wire rx,
  output wire tx,
  //Debug LEDs
  output reg[7:0] led,
  input wire[3:0] btn,
  // DDR3 SDRAM
  output  wire            ddr3_reset_n,
  output  wire            ddr3_cke,
  output  wire            ddr3_clk_p,
  output  wire            ddr3_clk_n,
  output  wire            ddr3_cs_n,
  output  wire            ddr3_ras_n,
  output  wire            ddr3_cas_n,
  output  wire            ddr3_we_n,
  output  wire    [2:0]   ddr3_ba,
  output  wire    [13:0]  ddr3_addr,
  output  wire    [0:0]   ddr3_odt,
  output  wire    [1:0]   ddr3_dm,
  inout   wire    [0:0]   ddr3_dqs_p,
  inout   wire    [0:0]   ddr3_dqs_n,
  inout   wire    [15:0]  ddr3_dq
);

  //-----------------------------------------------------------------
  // Clocking / Reset
  //-----------------------------------------------------------------
  wire clk_w;
  wire rst_w;
  wire clk_ddr_w;
  wire clk_ddr_dqs_w;
  wire clk_ref_w;

  wire [31:0] o_debug1;
  wire [31:0] o_debug2;

  assign led = {o_debug2[7:0]};
  assign ddr3_cs_n = 0; //tie cs_n to ground (same as disabling the chip-select)


  (* mark_debug="true" *) wire clk_locked;
  clk_wiz pll (
    .clk_in1(clk100mhz),
    .clk_out1(clk_w),        // 100mhz
    .clk_out2(clk_ref_w),    // 200mhz
    .clk_out3(clk_ddr_w),    // 400mhz
    .clk_out4(clk_ddr_dqs_w),// 400mhz @ 90°
    .reset(i_rst),
    .locked(clk_locked)
  );

  wire        awready;
  wire        arready;
  wire [7:0]  arlen  ;
  wire        wvalid ;
  wire [31:0] araddr ;
  wire [1:0]  bresp  ;
  wire [31:0] wdata  ;
  wire        rlast  ;
  wire        awvalid;
  wire [3:0]  rid    ;
  wire [1:0]  rresp  ;
  wire        bvalid ;
  wire [3:0]  wstrb  ;
  wire [1:0]  arburst;
  wire        arvalid;
  wire [3:0]  awid   ;
  wire [3:0]  bid    ;
  wire [3:0]  arid   ;
  wire        rready ;
  wire [7:0]  awlen  ;
  wire        wlast  ;
  wire [31:0] rdata  ;
  wire        bready ;
  wire [31:0] awaddr ;
  wire        wready ;
  wire [1:0]  awburst;
  wire        rvalid ;

  reg [8:0] refresh_counter;
  initial begin
    refresh_counter <= 0;
  end

  always @(posedge clk_w) begin
    refresh_counter <= refresh_counter + 1;
  end

  // DDR3 Controller
  ddr3_top_axi #(
    .CONTROLLER_CLK_PERIOD(12_000), //12_000ps, clock period of the controller interface
    .DDR3_CLK_PERIOD(3_000), //3_000ps, clock period of the DDR3 RAM device (must be 1/4 of the CONTROLLER_CLK_PERIOD)
    .ROW_BITS(14), //width of row address
    .COL_BITS(10), //width of column address
    .BA_BITS(3), //width of bank address
    .DQ_BITS(8),  //width of DQ
    .BYTE_LANES(1), //number of DDR3 modules to be controlled
    .AXI_ID_WIDTH(4),
    .WB2_ADDR_BITS(32), //width of 2nd wishbone address bus
    .WB2_DATA_BITS(32), //width of 2nd wishbone data bus
    .MICRON_SIM(0), //enable faster simulation for micron ddr3 model
    .ODELAY_SUPPORTED(0), //set to 1 when ODELAYE2 is supported
    .SECOND_WISHBONE(0), //set to 1 if 2nd wishbone is needed
    .SELF_REFRESH(1)
  ) ddr3_top_inst
  (
      //clock and reset
      .i_controller_clk(clk_w),
      .i_ddr3_clk(clk_ddr_w), //i_controller_clk has period of CONTROLLER_CLK_PERIOD, i_ddr3_clk has period of DDR3_CLK_PERIOD
      .i_ref_clk(clk_ref_w),
      .i_ddr3_clk_90(clk_ddr_dqs_w),
      .i_rst_n(!i_rst && clk_locked),

      .i_user_self_refresh(),

      // PHY Interface (to be added later)
      // DDR3 I/O Interface
      .o_ddr3_clk_p(ddr3_clk_p),
      .o_ddr3_clk_n(ddr3_clk_n),
      .o_ddr3_reset_n(ddr3_reset_n),
      .o_ddr3_cke(ddr3_cke), // CKE
      .o_ddr3_cs_n(/*ddr3_cs_n*/), // chip select signal (controls rank 1 only)
      .o_ddr3_ras_n(ddr3_ras_n), // RAS#
      .o_ddr3_cas_n(ddr3_cas_n), // CAS#
      .o_ddr3_we_n(ddr3_we_n), // WE#
      .o_ddr3_addr(ddr3_addr),
      .o_ddr3_ba_addr(ddr3_ba),
      .io_ddr3_dq(ddr3_dq),
      .io_ddr3_dqs(ddr3_dqs_p),
      .io_ddr3_dqs_n(ddr3_dqs_n),
      .o_ddr3_dm(ddr3_dm),
      .o_ddr3_odt(ddr3_odt), // on-die termination
      .o_debug1(o_debug1),
      .o_debug2(o_debug2),

      /// AXI Interface
      .s_axi_awvalid(awvalid),
      .s_axi_awready(awready),
      .s_axi_awid(awid),
      .s_axi_awaddr(awaddr),
      .s_axi_awlen(awlen),
      .s_axi_awsize(2),
      .s_axi_awburst(awburst),
      .s_axi_awlock(0),
      .s_axi_awcache(0),
      .s_axi_awprot(0),
      .s_axi_awqos(0),
      // AXI write data channel signals
      .s_axi_wvalid(wvalid),
      .s_axi_wready(wready),
      .s_axi_wdata(wdata),
      .s_axi_wstrb(wstrb),
      .s_axi_wlast(wlast),
      // AXI write response channel signals
      .s_axi_bvalid(bvalid),
      .s_axi_bready(bready),
      .s_axi_bid(bid),
      .s_axi_bresp(bresp),
      // AXI read address channel signals
      .s_axi_arvalid(arvalid),
      .s_axi_arready(arready),
      .s_axi_arid(arid),
      .s_axi_araddr(araddr),
      .s_axi_arlen(arlen),
      .s_axi_arsize(2),
      .s_axi_arburst(arburst),
      .s_axi_arlock(0),
      .s_axi_arcache(0),
      .s_axi_arprot(0),
      .s_axi_arqos(0),
      // AXI read data channel signals
      .s_axi_rvalid(rvalid),  // rd rslt valid
      .s_axi_rready(rready),  // rd rslt ready
      .s_axi_rid(rid), // response id
      .s_axi_rdata(rdata),// read data
      .s_axi_rlast(rlast),   // read last
      .s_axi_rresp(rresp)   // read response
  );

  mkDDR3_TEST top_instance (

    .awready   (awready),
    .arready   (arready),
    .arlength  (arlen  ),
    .wvalid    (wvalid ),
    .araddr    (araddr ),
    .bresp     (bresp  ),
    .wdata     (wdata  ),
    .rlast     (rlast  ),
    .awvalid   (awvalid),
    .rid       (rid    ),
    .rresp     (rresp  ),
    .bvalid    (bvalid ),
    .wstrb     (wstrb  ),
    .arburst   (arburst),
    .arvalid   (arvalid),
    .awid      (awid   ),
    .bid       (bid    ),
    .arid      (arid   ),
    .rready    (rready ),
    .awlength  (awlen  ),
    .wlast     (wlast  ),
    .rdata     (rdata  ),
    .bready    (bready ),
    .awaddr    (awaddr ),
    .wready    (wready ),
    .awburst   (awburst),
    .rvalid    (rvalid ),

    .CLK(clk_w),
    .RST_N(!i_rst && clk_locked),
    .ftdi_txd(rx),
    .ftdi_rxd(tx)
    //.led(led)
  );

endmodule

