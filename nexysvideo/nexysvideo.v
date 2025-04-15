`timescale 1ns / 100ps

module nexysvideo_ddr3 (
  input wire i_clk,
  input wire i_rst,
  // UART line
  input wire rx,
  output wire tx,
  //Debug LEDs
  output wire[7:0] led
);

  wire i_controller_clk, i_ddr3_clk, i_ref_clk, i_ddr3_clk_90;

  (* mark_debug = "true" *) wire clk_locked;
  clk_wiz clk_wiz_inst
  (
    // Clock out ports
    .clk_out1(i_controller_clk), //83.333 Mhz
    .clk_out2(i_ddr3_clk), // 333.333 MHz
    .clk_out3(i_ref_clk), //200MHz
    .clk_out4(i_ddr3_clk_90), // 333.333 MHz with 90degree shift
    // Status and control signals
    .reset(i_rst),
    .locked(clk_locked),
    // Clock in ports
    .clk_in1(i_clk)
  );


  reg RST_N = 1;
  always @(posedge i_controller_clk) begin
    RST_N <= !i_rst && clk_locked ? 1 : 0;
  end

  mkCPU_MINIMAL top_instance (
    .CLK(i_controller_clk),
    .RST_N(RST_N),
    .ftdi_txd(rx),
    .ftdi_rxd(tx),
    .led(led)
  );

endmodule

