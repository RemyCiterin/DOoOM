`timescale 1ns/100ps  // 1 ns time unit, 100 ps resolution
`default_nettype none // Makes it easier to detect typos !

module test_sdram;
  reg clk;
  always #20 clk = !clk; // 25 MHz
  // always #10 clk = !clk; // 40 MHz
  // always #12.5 clk = !clk; // 50 MHz

  reg resetq = 1;

  /***************************************************************************/
  // SD-RAM-Controller
  /***************************************************************************/

  //wire [31:0] sdram_rdata;
  //wire sdram_busy;

  //reg [3:0] sdram_wmask = 4'b0000;
  //reg       sdram_rd    = 0;

  //SDRAM sdram(
  //  // Physical interface
  //  .sd_d(sdram_d),
  //  .sd_addr(sdram_a),
  //  .sd_dqm(sdram_dqm),
  //  .sd_cs(sdram_csn),
  //  .sd_ba(sdram_ba),
  //  .sd_we(sdram_wen),
  //  .sd_ras(sdram_rasn),
  //  .sd_cas(sdram_casn),
  //  .sd_clk(sdram_clk),
  //  .sd_cke(sdram_cke),

  //  // Internal bus interface
  //  .clk(clk),
  //  .resetq(resetq),
  //  .addr(mem_address[25:0]),
  //  .wmask(sdram_wmask),
  //  .rd(sdram_rd),
  //  .din(mem_wdata),
  //  .dout(sdram_rdata),
  //  .busy(sdram_busy)
  //);

  mkTop top(
    .CLK(clk),
    .RST_N(resetq),
    .sdram_d(sdram_d),
    .sdram_a(sdram_a),
    .sdram_dqm(sdram_dqm),
    .sdram_csn(sdram_csn),
    .sdram_ba(sdram_ba),
    .sdram_wen(sdram_wen),
    .sdram_rasn(sdram_rasn),
    .sdram_casn(sdram_casn),
    .sdram_clk(sdram_clk),
    .sdram_cke(sdram_cke)
  );
  //wire busy;               // indicate if the RAM is busy
  //wire [25:0] sdram_addr;  // address of the current read or write if the CPU and the RAM are ready
  //wire [31:0] sdram_din;   // input data of a write
  //wire [31:0] dout;        // output data of a read
  //wire [3:0]  sdram_wmask; // true if the CPU want to write a data
  //wire        sdram_read;  // true if the CPU want to read a data

  //wire [25:0] cpu_addr;  // address of the current read or write if the CPU and the RAM are ready
  //wire [31:0] cpu_din;   // input data of a write
  //wire [3:0]  cpu_wmask; // true if the CPU want to write a data
  //wire        cpu_read;  // true if the CPU want to read a data

  //reg [25:0] prev_cpu_addr;  // address of the current read or write if the CPU and the RAM are ready
  //reg [31:0] prev_cpu_din;   // input data of a write
  //reg [3:0]  prev_cpu_wmask; // true if the CPU want to write a data
  //reg        prev_cpu_read;  // true if the CPU want to read a data

  //always @(posedge clk) begin
  //  prev_cpu_addr  <= cpu_addr;
  //  prev_cpu_din   <= cpu_din;
  //  prev_cpu_wmask <= cpu_wmask;
  //  prev_cpu_read  <= cpu_read;
  //end

  //reg [25:0] addr  = 0; // address of the current read or write if the CPU and the RAM are ready
  //reg [31:0] din   = 0; // input data of a write
  //reg [3:0]  wmask = 0; // true if the CPU want to write a data
  //reg        read  = 0; // true if the CPU want to read a data

  //reg ctrl = 0;

  //assign sdram_addr  = (ctrl ? addr  : ( prev_cpu_read | (|prev_cpu_wmask) ? prev_cpu_addr  : cpu_addr));
  //assign sdram_din   = (ctrl ? din   : ( prev_cpu_read | (|prev_cpu_wmask) ? prev_cpu_din   : cpu_din));
  //assign sdram_wmask = (ctrl ? wmask : ( prev_cpu_read | (|prev_cpu_wmask) ? prev_cpu_wmask : cpu_wmask));
  //assign sdram_read  = (ctrl ? read  : ( prev_cpu_read | (|prev_cpu_wmask) ? prev_cpu_read  : cpu_read));

  //assign sdram_addr  = (ctrl ? addr  : cpu_addr);
  //assign sdram_din   = (ctrl ? din   : cpu_din);
  //assign sdram_wmask = (ctrl ? wmask : cpu_wmask);
  //assign sdram_read  = (ctrl ? read  : cpu_read);

  ////$monitor("t=%d: sdram_d = %8h Busy %b sdram_rdata %8h", $time, din, busy, dout);

  //SDRAM sdr(
  //  .sd_clk(sdram_clk),
  //  .sd_cke(sdram_cke),
  //  .sd_d(sdram_d),
  //  .sd_addr(sdram_a),
  //  .sd_ba(sdram_ba),
  //  .sd_dqm(sdram_dqm),
  //  .sd_cs(sdram_csn),
  //  .sd_we(sdram_wen),
  //  .sd_ras(sdram_rasn),
  //  .sd_cas(sdram_casn),
  //  .clk(clk),
  //  .resetn(resetq),
  //  .wmask(sdram_wmask),
  //  .rd(sdram_read),
  //  .addr(sdram_addr),
  //  .din(sdram_din),
  //  .dout(dout),
  //  .busy(busy)
  //);

  //mkCPU cpu(
  //  .CLK(clk),
	//  .RST_N(resetq),
	//  .sdram_addr(cpu_addr),
	//  .sdram_write_data(cpu_din),
	//  .sdram_wmask(cpu_wmask),
	//  .sdram_read_cmd(cpu_read),
	//  .sdram_read_response(dout),
	//  .sdram_busy(busy)
  //);


  //wire [31:0] mem_address = 0;
  //wire [31:0] mem_wdata = 32'h00030004;

   /***************************************************************************/
   // 64 MB SD-RAM
   /***************************************************************************/

  wire  sdram_csn;       // chip select
  wire  sdram_clk;       // clock to SDRAM
  wire  sdram_cke;       // clock enable to SDRAM
  wire  sdram_rasn;      // SDRAM RAS
  wire  sdram_casn;      // SDRAM CAS
  wire  sdram_wen;       // SDRAM write-enable
  wire [12:0] sdram_a;  // SDRAM address bus
  wire  [1:0] sdram_ba;  // SDRAM bank-address
  wire  [1:0] sdram_dqm; // byte select
  wire [15:0] sdram_d;

  mt48lc16m16a2 memory(
    .Dq(sdram_d),
    .Addr(sdram_a),
    .Ba(sdram_ba),
    .Clk(sdram_clk),
    .Cke(sdram_cke),
    .Cs_n(sdram_csn),
    .Ras_n(sdram_rasn),
    .Cas_n(sdram_casn),
    .We_n(sdram_wen),
    .Dqm(sdram_dqm)
  );

  /***************************************************************************/
  // Test sequence
  /***************************************************************************/

  integer i;
  initial begin
    $dumpfile("build/sdram.vcd");    // create a VCD waveform dump
    $dumpvars(0, test_sdram); // dump variable changes in the testbench
                             // and all modules under it

    clk = 0;
    resetq = 1;
    @(negedge clk);
    resetq = 0;
    @(negedge clk);
    resetq = 1;


    for (i=0; i < 100000000; i = i + 1) begin
      @(negedge clk);
    end

    $finish();

  end
endmodule
