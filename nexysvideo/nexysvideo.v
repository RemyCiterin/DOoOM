`timescale 1ns / 100ps

module nexysvideo_ddr3 (
  input                   clk100mhz,
  // UART line
  input wire rx,
  output wire tx,
  //Debug LEDs
  output wire[7:0] led,
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
  inout   wire    [1:0]   ddr3_dqs_p,
  inout   wire    [1:0]   ddr3_dqs_n,
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

  //artix7_pll
  //u_pll
  //(
  //     .clkref_i(clk100mhz)
  //    ,.clkout0_o(clk_w)         // 100
  //    ,.clkout1_o(clk_ddr_w)     // 400
  //    ,.clkout2_o(clk_ref_w)     // 200
  //    ,.clkout3_o(clk_ddr_dqs_w) // 400 (phase shifted 90 degrees)
  //);

  clk_wiz pll (
    .clk_in1(clk100mhz),
    .clk_out1(clk_w),        // 100mhz
    .clk_out2(clk_ref_w),    // 200mhz
    .clk_out3(clk_ddr_w),    // 400mhz
    .clk_out4(clk_ddr_dqs_w) // 400mhz @ 90°
  );

  reset_gen
  u_rst
  (
       .clk_i(clk_w)
      ,.rst_o(rst_w)
  );

  //-----------------------------------------------------------------
  // DDR Core + PHY
  //-----------------------------------------------------------------
  wire [ 13:0]   dfi_address_w;
  wire [  2:0]   dfi_bank_w;
  wire           dfi_cas_n_w;
  wire           dfi_cke_w;
  wire           dfi_cs_n_w;
  wire           dfi_odt_w;
  wire           dfi_ras_n_w;
  wire           dfi_reset_n_w;
  wire           dfi_we_n_w;
  wire [ 31:0]   dfi_wrdata_w;
  wire           dfi_wrdata_en_w;
  wire [  3:0]   dfi_wrdata_mask_w;
  wire           dfi_rddata_en_w;
  wire [ 31:0]   dfi_rddata_w;
  wire           dfi_rddata_valid_w;
  wire [  1:0]   dfi_rddata_dnv_w;

  wire           awready;
  wire           arready;
  wire  [  7:0]  arlen;
  wire           wvalid;
  wire  [ 31:0]  araddr;
  wire  [  1:0]  bresp;
  wire  [ 31:0]  wdata;
  wire           rlast;
  wire           awvalid;
  wire  [  3:0]  rid;
  wire  [  1:0]  rresp;
  wire           bvalid;
  wire  [  3:0]  wstrb;
  wire  [  1:0]  arburst;
  wire           arvalid;
  wire  [  3:0]  awid;
  wire  [  3:0]  bid;
  wire  [  3:0]  arid;
  wire           rready;
  wire  [  7:0]  awlen;
  wire           wlast;
  wire  [ 31:0]  rdata;
  wire           bready;
  wire  [ 31:0]  awaddr;
  wire           wready;
  wire  [  1:0]  awburst;
  wire           rvalid;

  ddr3_axi
  #(
       .DDR_WRITE_LATENCY(4)
      ,.DDR_READ_LATENCY(4)
      ,.DDR_MHZ(100)
  )
  u_ddr
  (
      // Inputs
       .clk_i(clk_w)
      ,.rst_i(rst_w)
      ,.inport_awvalid_i(awvalid)
      ,.inport_awaddr_i(awaddr)
      ,.inport_awid_i(awid)
      ,.inport_awlen_i(awlen)
      ,.inport_awburst_i(awburst)
      ,.inport_wvalid_i(wvalid)
      ,.inport_wdata_i(wdata)
      ,.inport_wstrb_i(wstrb)
      ,.inport_wlast_i(wlast)
      ,.inport_bready_i(bready)
      ,.inport_arvalid_i(arvalid)
      ,.inport_araddr_i(araddr)
      ,.inport_arid_i(arid)
      ,.inport_arlen_i(arlen)
      ,.inport_arburst_i(arburst)
      ,.inport_rready_i(rready)
      ,.dfi_rddata_i(dfi_rddata_w)
      ,.dfi_rddata_valid_i(dfi_rddata_valid_w)
      ,.dfi_rddata_dnv_i(dfi_rddata_dnv_w)

      // Outputs
      ,.inport_awready_o(awready)
      ,.inport_wready_o(wready)
      ,.inport_bvalid_o(bvalid)
      ,.inport_bresp_o(bresp)
      ,.inport_bid_o(bid)
      ,.inport_arready_o(arready)
      ,.inport_rvalid_o(rvalid)
      ,.inport_rdata_o(rdata)
      ,.inport_rresp_o(rresp)
      ,.inport_rid_o(rid)
      ,.inport_rlast_o(rlast)
      ,.dfi_address_o(dfi_address_w)
      ,.dfi_bank_o(dfi_bank_w)
      ,.dfi_cas_n_o(dfi_cas_n_w)
      ,.dfi_cke_o(dfi_cke_w)
      ,.dfi_cs_n_o(dfi_cs_n_w)
      ,.dfi_odt_o(dfi_odt_w)
      ,.dfi_ras_n_o(dfi_ras_n_w)
      ,.dfi_reset_n_o(dfi_reset_n_w)
      ,.dfi_we_n_o(dfi_we_n_w)
      ,.dfi_wrdata_o(dfi_wrdata_w)
      ,.dfi_wrdata_en_o(dfi_wrdata_en_w)
      ,.dfi_wrdata_mask_o(dfi_wrdata_mask_w)
      ,.dfi_rddata_en_o(dfi_rddata_en_w)
  );

  ddr3_dfi_phy
  #(
       .DQS_TAP_DELAY_INIT(27)
      ,.DQ_TAP_DELAY_INIT(0)
      ,.TPHY_RDLAT(5)
  )
  u_phy
  (
       .clk_i(clk_w)
      ,.rst_i(rst_w)

      ,.clk_ddr_i(clk_ddr_w)
      ,.clk_ddr90_i(clk_ddr_dqs_w)
      ,.clk_ref_i(clk_ref_w)

      ,.cfg_valid_i(1'b0)
      ,.cfg_i(32'b0)

      ,.dfi_address_i(dfi_address_w)
      ,.dfi_bank_i(dfi_bank_w)
      ,.dfi_cas_n_i(dfi_cas_n_w)
      ,.dfi_cke_i(dfi_cke_w)
      ,.dfi_cs_n_i(dfi_cs_n_w)
      ,.dfi_odt_i(dfi_odt_w)
      ,.dfi_ras_n_i(dfi_ras_n_w)
      ,.dfi_reset_n_i(dfi_reset_n_w)
      ,.dfi_we_n_i(dfi_we_n_w)
      ,.dfi_wrdata_i(dfi_wrdata_w)
      ,.dfi_wrdata_en_i(dfi_wrdata_en_w)
      ,.dfi_wrdata_mask_i(dfi_wrdata_mask_w)
      ,.dfi_rddata_en_i(dfi_rddata_en_w)
      ,.dfi_rddata_o(dfi_rddata_w)
      ,.dfi_rddata_valid_o(dfi_rddata_valid_w)
      ,.dfi_rddata_dnv_o(dfi_rddata_dnv_w)

      ,.ddr3_ck_p_o(ddr3_clk_p)
      ,.ddr3_ck_n_o(ddr3_clk_n)
      ,.ddr3_cke_o(ddr3_cke)
      ,.ddr3_reset_n_o(ddr3_reset_n)
      ,.ddr3_ras_n_o(ddr3_ras_n)
      ,.ddr3_cas_n_o(ddr3_cas_n)
      ,.ddr3_we_n_o(ddr3_we_n)
      ,.ddr3_cs_n_o(ddr3_cs_n)
      ,.ddr3_ba_o(ddr3_ba)
      ,.ddr3_addr_o(ddr3_addr[13:0])
      ,.ddr3_odt_o(ddr3_odt)
      ,.ddr3_dm_o(ddr3_dm)
      ,.ddr3_dq_io(ddr3_dq)
      ,.ddr3_dqs_p_io(ddr3_dqs_p)
      ,.ddr3_dqs_n_io(ddr3_dqs_n)
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
    .RST_N(~rst_w),
    .ftdi_txd(rx),
    .ftdi_rxd(tx),
    .led(led)
  );

endmodule

