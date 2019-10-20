//*****************************************************************************
// (c) Copyright 2008-2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: %version
//  \   \         Application: MEMC
//  /   /         Filename: mcb_traffic_gen.v
// /___/   /\     Date Last Modified: $Date:
// \   \  /  \    Date Created:
//  \___\/\___\
//
//Device: Spartan6/Virtex6
//Design Name: mcb_traffic_gen
//Purpose: This is top level module of memory traffic generator which can
//         generate different CMD_PATTERN and DATA_PATTERN to Spartan 6
//         hard memory controller core.
//Reference:
//Revision History:     1.1      Brought out internal signals cmp_data and cmp_error as outputs.
//                      1.2    7/1/2009  Added EYE_TEST parameter for signal SI probing.
//                      1.3    10/1/2009 Added dq_error_bytelane_cmp,cumlative_dq_lane_error signals for V6.
//                                       Any comparison error on user read data bus are mapped back to 
//                                       dq bus.  The cumulative_dq_lane_error accumulate any errors on
//                                       DQ bus. And the dq_error_bytelane_cmp shows error during current 
//                                       command cycle. The error can be cleared by input signal "manual_clear_error".
//                      1.4    04/10/2010 Removed local generated version of  mcb_rd_empty and mcb_wr_full in TG.
//                      1.5    05/19/2010 If MEM_BURST_LEN value is passed with value of zero, it is treated as
//                                        "OTF" Burst Mode and TG will only generate BL 8 traffic.

//*****************************************************************************
`timescale 1ps/1ps

module mcb_traffic_gen #
  (
   parameter TCQ           = 100,            // SIMULATION tCQ delay.
   parameter FAMILY        = "SPARTAN6",     // "VIRTEX6", "SPARTAN6"
   parameter SIMULATION    = "FALSE",
   parameter MEM_BURST_LEN = 8,               // For VIRTEX6 Only in this traffic gen.
                                              // This traffic gen doesn't support DDR3 OTF Burst mode.

   parameter PORT_MODE     = "BI_MODE",       // SPARTAN6: "BI_MODE", "WR_MODE", "RD_MODE"
                                              // VIRTEX6: "BI_MODE"
   parameter DATA_PATTERN  = "DGEN_ALL", // "DGEN__HAMMER", "DGEN_WALING1","DGEN_WALING0","DGEN_ADDR","DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter CMD_PATTERN   = "CGEN_ALL",     // "CGEN_RPBS","CGEN_FIXED",  "CGEN_BRAM", "CGEN_SEQUENTIAL", "CGEN_ALL",

   parameter ADDR_WIDTH    = 30,             // Spartan 6 Addr width is 30

   parameter CMP_DATA_PIPE_STAGES = 0,       // parameter for MPMC, it should always set to 0

   // memory type specific
   parameter MEM_COL_WIDTH = 10,             // memory column width
   parameter NUM_DQ_PINS   = 16,             // Spartan 6 Options: 4,8,16;
                                             // Virtex 6 DDR2/DDR3 Options: 8,16,24,32,.....144
   parameter DQ_ERROR_WIDTH = 1,

   parameter SEL_VICTIM_LINE = 3,            // SEL_VICTIM_LINE LINE is one of the DQ pins is selected to be different than hammer pattern
                                             // SEL_VICTIM_LINE is only for V6.
                                             // Virtex 6 option: 8,9,16,17,32,36,64,72
   parameter DWIDTH        = 32,             //NUM_DQ_PINS*4,         // Spartan 6 Options: 32,64,128;
                                             // Virtex 6 Always: 4* NUM_DQ_PINS


   // the following parameter is to limit the range of generated PRBS Address
   //
   //      e.g PRBS_SADDR_MASK_POS = 32'h0000_7000   the bit 14:12 of PRBS_SADDR will be ORed with
   //          PRBS_SADDR          = 32'h0000_5000   the LFSR[14:12] to add the starting address offset.

   //          PRBS_EADDR          = 32'h0000_7fff
   //          PRBS_EADDR_MASK_POS = 32'hffff_7000 => mark all the leading 0's in PRBS_EADDR to 1 to
   //                                                 zero out the LFSR[31:15]

   parameter PRBS_EADDR_MASK_POS = 32'hFFFFD000,
   parameter PRBS_SADDR_MASK_POS =  32'h00002000,
   parameter PRBS_EADDR = 32'h00002000,
   parameter PRBS_SADDR = 32'h00005000,
   parameter EYE_TEST   = "FALSE"  // set EYE_TEST = "TRUE" to probe memory signals.
                                   // Traffic Generator will only write to one single location and no
                                   // read transactions will be generated.


 )

 (

   input                    clk_i,
   input                    rst_i,
   input                    run_traffic_i,
   input                    manual_clear_error,
  // *** runtime parameter ***
   input [31:0]             start_addr_i,   // define the start of address
   input [31:0]             end_addr_i,     // define upper limit addressboundary
   input [31:0]             cmd_seed_i,     // seed for cmd PRBS generators
   input [31:0]             data_seed_i,    // data seed will be added to generated address
                                            // for PRBS data generation
    // seed for cmd PRBS generators
   input                    load_seed_i,   //  when asserted the cmd_seed and data_seed inputs will be registered.

   // upper layer inputs to determine the command bus and data pattern
   // internal traffic generator initialize the memory with
   input [2:0]              addr_mode_i,  // "00" = bram; takes the address from bram interface
                                          // "01" = fixed address from the fixed_addr input
                                          // "10" = psuedo ramdom pattern; generated from internal 64 bit LFSR
                                          // "11" = sequential


  // for each instr_mode, traffic gen fill up with a predetermined pattern before starting the instr_pattern that defined
  // in the instr_mode input. The runtime mode will be automatically loaded inside when it is in
   input [3:0]              instr_mode_i, // "0000" = Fixed
                                          // "0001" = bram; takes instruction from bram output
                                          // "0010" = R/W
                                          // "0011" = RP/WP
                                          // "0100" = R/RP/W/WP
                                          // "0101" = R/RP/W/WP/REF
                                          // "0110" = PRBS


   input [1:0]              bl_mode_i,    // "00" = bram;   takes the burst length from bram output
                                          // "01" = fixed , takes the burst length from the fixed_bl input
                                          // "10" = psuedo ramdom pattern; generated from internal 16 bit LFSR

   input [3:0]              data_mode_i,   // "000" = address as data
                                           // "001" = hammer
                                           // "010" = neighbour
                                           // "011" = prbs
                                           // "100" = walking 0's
                                           // "101" = walking 1's
                                           // "110" =
                                           // "111" =

   input                    mode_load_i,

   // fixed pattern inputs interface
   input [5:0]              fixed_bl_i,      // range from 1 to 64
   input [2:0]              fixed_instr_i,   //RD              3'b001
                                             //RDP             3'b011
                                             //WR              3'b000
                                             //WRP             3'b010
                                             //REFRESH         3'b100


   input [31:0]             fixed_addr_i,       // only upper 30 bits will be used
   input [DWIDTH-1:0]       fixed_data_i, // 

   // BRAM interface.
                                          //   bram bus formats:
                                          //   Only SP6 has been tested.
   input [38:0]             bram_cmd_i,   //  {{bl}, {cmd}, {address[28:2]}}
   input                    bram_valid_i,
   output                   bram_rdy_o,  //

   /////////////////////////////////////////////////////////////////////////////
   //  MCB INTERFACE
   // interface to mcb command port
   output                   mcb_cmd_en_o,
   output [2:0]             mcb_cmd_instr_o,
   output [ADDR_WIDTH-1:0]  mcb_cmd_addr_o,
   output [5:0]             mcb_cmd_bl_o,      // this output is for Spartan 6

   input                    mcb_cmd_full_i,

   // interface to mcb wr data port
   output                   mcb_wr_en_o,
   output [DWIDTH-1:0]      mcb_wr_data_o,
   output                   mcb_wr_data_end_o,
   output [(DWIDTH/8) - 1:0]  mcb_wr_mask_o,

   input                    mcb_wr_full_i,
   input [6:0]              mcb_wr_fifo_counts,

   // interface to mcb rd data port
   output                   mcb_rd_en_o,
   input [DWIDTH-1:0]       mcb_rd_data_i,
   input                    mcb_rd_empty_i,
   input [6:0]              mcb_rd_fifo_counts,
   /////////////////////////////////////////////////////////////////////////////
   // status feedback
   input                    counts_rst,
   output reg [47:0]        wr_data_counts,
   output reg [47:0]        rd_data_counts,
   output                   cmp_error,
   output                   cmp_data_valid,
   output                   error,       // asserted whenever the read back data is not correct.
   output  [64 + (2*DWIDTH - 1):0]            error_status ,// TBD how signals mapped
   output [DWIDTH-1:0]      cmp_data,
   output [DWIDTH-1:0]      mem_rd_data,
   
   
   // **** V6 Signals
   output [DQ_ERROR_WIDTH - 1:0] dq_error_bytelane_cmp,   // V6: real time compare error byte lane
   output [DQ_ERROR_WIDTH - 1:0] cumlative_dq_lane_error  // V6: latched error byte lane that occure on
                                                       //     first error
   


  );

localparam MEM_BLEN =  (MEM_BURST_LEN == 4) ? 4 :
                       (MEM_BURST_LEN == 8) ? 8 :
                        8;

   wire [DWIDTH-1:0]        rdpath_rd_data_i;
   wire                     rdpath_data_valid_i;
   wire                     mcb_wr_en;
   wire                     cmd2flow_valid;
   wire [2:0]               cmd2flow_cmd;
   wire [31:0]              cmd2flow_addr;
   wire [5:0]               cmd2flow_bl;
   wire                     last_word_rd;
   wire                     last_word_wr;
   wire                     flow2cmd_rdy;
   wire [31:0]              wr_addr;
   wire [31:0]              rd_addr;
   wire [5:0]               wr_bl;
   wire [5:0]               rd_bl;
   reg                      run_traffic_reg;
wire wr_validB, wr_valid,wr_validC;
wire [31:0] bram_addr_i;
wire [2:0] bram_instr_i;
wire [5:0] bram_bl_i;
reg AC2_G_E2,AC1_G_E1,AC3_G_E3;
reg upper_end_matched;
reg [7:0] end_boundary_addr;
reg lower_end_matched;
wire [31:0] addr_o;
wire [31:0] m_addr;
wire dcount_rst;
wire [31:0] rd_addr_error;
wire rd_rdy;
//wire cmp_error;
wire  cmd_full;
wire rd_mdata_fifo_rd_en;
wire rd_mdata_fifo_empty;
wire rd_mdata_fifo_afull;
wire [DWIDTH-1:0] rd_v6_mdata;

//
wire [31:0]       cmp_addr;
wire [5:0]       cmp_bl;
// synthesis attribute keep of rst_ra is "true";
// synthesis attribute keep of rst_rb is "true";

reg [9:0]         rst_ra,rst_rb;
// synthesis attribute keep of mcb_wr_full_r1 is "true";
// synthesis attribute keep of mcb_wr_full_r2 is "true";

reg mcb_wr_full_r1,mcb_wr_full_r2;
reg mcb_rd_empty_r;
wire force_wrcmd_gen;
wire [6:0] rd_buff_avail;

reg [3:0] data_mode_r_a;
reg [3:0] data_mode_r_b;
reg [3:0] data_mode_r_c;
reg        rd_mdata_afull_set;
reg error_access_range = 1'b0;
  //synthesis translate_off

  initial begin
    if((MEM_BURST_LEN !== 4) && (MEM_BURST_LEN !== 8)) begin
      $display("Current Traffic Generator logic does not support OTF (On The Fly) Burst Mode!");
      $display("If memory is set to OTF (On The Fly) , Traffic Generator only generates BL8 traffic");
      
    end
  end

always @ (mcb_cmd_en_o,mcb_cmd_addr_o,mcb_cmd_bl_o,end_addr_i)

if (mcb_cmd_en_o && (mcb_cmd_addr_o + mcb_cmd_bl_o * (DWIDTH/8)) > end_addr_i[ADDR_WIDTH-1:0])
   begin
   $display("Error ! Data access beyond address range");
   error_access_range = 1'b1;
   $stop;
   end

  //synthesis translate_on

wire mcb_rd_empty;
assign     mcb_rd_empty = mcb_rd_empty_i;




wire mcb_wr_full;
assign     mcb_wr_full = mcb_wr_full_i;


always @ (posedge clk_i)
begin
    data_mode_r_a <= #TCQ data_mode_i;
    data_mode_r_b <= #TCQ data_mode_i;
    data_mode_r_c <= #TCQ data_mode_i;
end
always @ (posedge clk_i)
begin
if (rst_ra[0])
    mcb_wr_full_r1 <= #TCQ 1'b0;
else if (mcb_wr_fifo_counts >= 63) begin
    mcb_wr_full_r1 <= #TCQ 1'b1;
    mcb_wr_full_r2 <= #TCQ 1'b1;
    end
else begin
    mcb_wr_full_r1 <= #TCQ 1'b0;
    mcb_wr_full_r2 <= #TCQ 1'b0;
    end
end


always @ (posedge clk_i)
begin
if (rst_ra[0])
    mcb_rd_empty_r <= #TCQ 1'b1;

else if (mcb_rd_fifo_counts <= 1)
    mcb_rd_empty_r <= #TCQ 1'b1;
else
    mcb_rd_empty_r <= #TCQ 1'b0;
end



// synthesis attribute MAX_FANOUT of rst_ra is 20;
// synthesis attribute MAX_FANOUT of rst_rb is 20;


//reg GSR = 1'b0;
   always @(posedge clk_i)
   begin
         rst_ra <= #TCQ {rst_i,rst_i,rst_i,rst_i,rst_i,rst_i,rst_i,rst_i,rst_i,rst_i};
         rst_rb <= #TCQ {rst_i,rst_i,rst_i,rst_i,rst_i,rst_i,rst_i,rst_i,rst_i,rst_i};

   end
   // register it . Just in case the calling modules didn't syn with clk_i
   always @(posedge clk_i)
   begin
       run_traffic_reg <= #TCQ run_traffic_i;
   end

   assign bram_addr_i = {bram_cmd_i[29:0],2'b00};
   assign bram_instr_i = bram_cmd_i[32:30];
   assign bram_bl_i[5:0] = bram_cmd_i[38:33];


//
//
assign dcount_rst = counts_rst | rst_ra[0];
always @ (posedge clk_i)
begin
  if (dcount_rst)
      wr_data_counts <= #TCQ 'b0;
  else if (mcb_wr_en)
      wr_data_counts <= #TCQ wr_data_counts + DWIDTH/8;

end

always @ (posedge clk_i)
begin
  if (dcount_rst)
      rd_data_counts <= #TCQ 'b0;
  else if (mcb_rd_en_o)
      rd_data_counts <= #TCQ rd_data_counts + DWIDTH/8;

end



// ****  for debug
// this part of logic is to check there are no commands been duplicated or dropped
// in the cmd_flow_control logic
generate
if (SIMULATION == "TRUE") begin: cmd_check
reg fifo_error;
wire [31:0] xfer_addr;
wire cmd_fifo_rd;

assign cmd_fifo_wr =  flow2cmd_rdy & cmd2flow_valid;

always @ (posedge clk_i)
begin
if ( mcb_cmd_en_o)
   if ( xfer_addr != mcb_cmd_addr_o)
      fifo_error <= #TCQ 1'b1;
   else
      fifo_error <= #TCQ 1'b0;

end

wire cmd_fifo_empty;
assign cmd_fifo_rd = mcb_cmd_en_o & ~mcb_cmd_full_i & ~cmd_fifo_empty;

  afifo #
   (.TCQ           (TCQ),
    .DSIZE         (38),
    .FIFO_DEPTH    (16),
    .ASIZE         (4),
    .SYNC          (1)  // set the SYNC to 1 because rd_clk = wr_clk to reduce latency


   )
   cmd_fifo
   (
    .wr_clk        (clk_i),
    .rst           (rst_ra[0]),
    .wr_en         (cmd_fifo_wr),
    .wr_data       ({cmd2flow_bl,cmd2flow_addr}),
    .rd_en         (cmd_fifo_rd),
    .rd_clk        (clk_i),
    .rd_data       ({xfer_cmd_bl,xfer_addr}),
    .full          (cmd_fifo_full),
    .empty         (cmd_fifo_empty)

   );


end
endgenerate

reg [31:0] end_addr_r;
 always @ (posedge clk_i)
    end_addr_r <= end_addr_i;


   cmd_gen
     #(
       .TCQ                 (TCQ),
       .FAMILY               (FAMILY)     ,
       .MEM_BURST_LEN     (MEM_BLEN),
       .PORT_MODE            (PORT_MODE),
       
       .NUM_DQ_PINS          (NUM_DQ_PINS),
       .DATA_PATTERN         (DATA_PATTERN),
       .CMD_PATTERN          (CMD_PATTERN),
       .ADDR_WIDTH            (ADDR_WIDTH),
       .DWIDTH               (DWIDTH),
       .MEM_COL_WIDTH  (MEM_COL_WIDTH),
       .PRBS_EADDR_MASK_POS          (PRBS_EADDR_MASK_POS ),
       .PRBS_SADDR_MASK_POS           (PRBS_SADDR_MASK_POS  ),
       .PRBS_EADDR         (PRBS_EADDR),
       .PRBS_SADDR          (PRBS_SADDR )

       )
   u_c_gen
     (
      .clk_i              (clk_i),
      .rst_i               (rst_ra),
      .rd_buff_avail_i        (rd_buff_avail),
      .reading_rd_data_i (mcb_rd_en_o),
      .force_wrcmd_gen_i (force_wrcmd_gen),
      .run_traffic_i    (run_traffic_reg),
      .start_addr_i     (start_addr_i),
      .end_addr_i       (end_addr_r),
      .cmd_seed_i       (cmd_seed_i),
      .data_seed_i      (data_seed_i),
      .load_seed_i      (load_seed_i),
      .addr_mode_i      (addr_mode_i),
      .data_mode_i        (data_mode_r_a),

      .instr_mode_i     (instr_mode_i),
      .bl_mode_i        (bl_mode_i),
      .mode_load_i      (mode_load_i),
   // fixed pattern inputs interface
      .fixed_bl_i       (fixed_bl_i),
      .fixed_addr_i     (fixed_addr_i),
      .fixed_instr_i    (fixed_instr_i),
   // BRAM FIFO input : Holist vector inputs

      .bram_addr_i      (bram_addr_i),
      .bram_instr_i     (bram_instr_i ),
      .bram_bl_i        (bram_bl_i ),
      .bram_valid_i     (bram_valid_i ),
      .bram_rdy_o       (bram_rdy_o   ),

      .rdy_i            (flow2cmd_rdy),
      .instr_o          (cmd2flow_cmd),
      .addr_o           (cmd2flow_addr),
      .bl_o             (cmd2flow_bl),
//      .m_addr_o         (m_addr),
      .cmd_o_vld        (cmd2flow_valid)

      );

assign mcb_cmd_addr_o = addr_o[ADDR_WIDTH-1:0];



assign cmd_full = mcb_cmd_full_i;
   mcb_flow_control #
     (
       .TCQ           (TCQ),
       .FAMILY  (FAMILY)
       
     )
   mcb_control
     (
      .clk_i            (clk_i),
      .rst_i            (rst_ra),

      .cmd_rdy_o        (flow2cmd_rdy),
      .cmd_valid_i      (cmd2flow_valid),
      .cmd_i            (cmd2flow_cmd),
      .addr_i           (cmd2flow_addr),
      .bl_i             (cmd2flow_bl),
      // interface to mcb_cmd port
      .mcb_cmd_full        (cmd_full),// (~rd_rdy ), // mcb_cmd_full
//      .mcb_cmd_empty        ( ),
      .cmd_o                 (mcb_cmd_instr_o),
      .addr_o                (addr_o),//(mcb_cmd_instr_o),
      .bl_o                  (mcb_cmd_bl_o),
      .cmd_en_o              (mcb_cmd_en_o),//(mcb_cmd_bl_o),
   // interface to write data path module

      .last_word_wr_i         (last_word_wr),
      .wdp_rdy_i            (wr_rdy),//(wr_rdy),
      .wdp_valid_o          (wr_valid),
      .wdp_validB_o         (wr_validB),
      .wdp_validC_o         (wr_validC),

      .wr_addr_o            (wr_addr),
      .wr_bl_o              (wr_bl),
   // interface to read data path module

      .last_word_rd_i         (last_word_rd),
      .rdp_rdy_i            (rd_rdy),// (rd_rdy),
      .rdp_valid_o           (rd_valid),
      .rd_addr_o            (rd_addr),
      .rd_bl_o              (rd_bl)

      );


   afifo #
   (
   
    .TCQ           (TCQ),
    .DSIZE         (DWIDTH),
    .FIFO_DEPTH    (32),
    .ASIZE         (5),
    .SYNC          (1)  // set the SYNC to 1 because rd_clk = wr_clk to reduce latency 
   
   
   )
   rd_mdata_fifo
   (
    .wr_clk        (clk_i),
    .rst           (rst_rb[0]),
    .wr_en         (!mcb_rd_empty),
    .wr_data       (mcb_rd_data_i),
    .rd_en         (mcb_rd_en_o),
    .rd_clk        (clk_i),
    .rd_data       (rd_v6_mdata),
    .full          (),
    .almost_full   (rd_mdata_fifo_afull),
    .empty         (rd_mdata_fifo_empty)
   
   );


wire cmd_rd_en;

always @ (posedge clk_i)
begin
if (rst_rb[0])
   rd_mdata_afull_set <= #TCQ 1'b0;
else if (rd_mdata_fifo_afull)
   rd_mdata_afull_set <= #TCQ 1'b1;
end
assign cmd_rd_en = ~mcb_cmd_full_i & mcb_cmd_en_o;


assign rdpath_data_valid_i =(FAMILY == "VIRTEX6" && MEM_BLEN == 4) ? (!rd_mdata_fifo_empty & rd_mdata_afull_set) :!mcb_rd_empty ;
assign rdpath_rd_data_i =(FAMILY == "VIRTEX6" && MEM_BLEN == 4) ? rd_v6_mdata : mcb_rd_data_i ;

generate
if (PORT_MODE == "RD_MODE" || PORT_MODE == "BI_MODE")  begin : RD_PATH
   read_data_path
     #(
       .TCQ           (TCQ),
       .FAMILY            (FAMILY)  ,
       .MEM_BURST_LEN     (MEM_BLEN),

       .CMP_DATA_PIPE_STAGES (CMP_DATA_PIPE_STAGES),
       .ADDR_WIDTH        (ADDR_WIDTH),
       .SEL_VICTIM_LINE   (SEL_VICTIM_LINE),
       .DATA_PATTERN      (DATA_PATTERN),
       .DWIDTH            (DWIDTH),
       .NUM_DQ_PINS       (NUM_DQ_PINS),
       .DQ_ERROR_WIDTH    (DQ_ERROR_WIDTH),
       .MEM_COL_WIDTH     (MEM_COL_WIDTH)

       )
   read_data_path
     (
      .clk_i              (clk_i),
      .rst_i              (rst_rb),
      .manual_clear_error (manual_clear_error),
      .cmd_rdy_o          (rd_rdy),
      .cmd_valid_i        (rd_valid),
      .prbs_fseed_i         (data_seed_i),
      .cmd_sent                 (mcb_cmd_instr_o),
      .bl_sent                  (mcb_cmd_bl_o),
      .cmd_en_i              (cmd_rd_en),

      .data_mode_i        (data_mode_r_b),
      .last_word_rd_o         (last_word_rd),
//      .m_addr_i               (m_addr),
      .fixed_data_i         (fixed_data_i),

      .addr_i                 (rd_addr),
      .bl_i                   (rd_bl),
      .data_rdy_o             (mcb_rd_en_o),
      
      .data_valid_i           (rdpath_data_valid_i),
      .data_i                 (rdpath_rd_data_i), 
      
      
      .data_error_o           (cmp_error),
      .cmp_data_valid         (cmp_data_valid),
      .cmp_data_o             (cmp_data),
      .rd_mdata_o             (mem_rd_data ),
      .cmp_addr_o             (cmp_addr),
      .cmp_bl_o               (cmp_bl),
      .force_wrcmd_gen_o      (force_wrcmd_gen),
      .rd_buff_avail_o        (rd_buff_avail),
      .dq_error_bytelane_cmp     (dq_error_bytelane_cmp),
      .cumlative_dq_lane_error_r   (cumlative_dq_lane_error)

      );

end
else begin: WR_ONLY_PATH

   assign cmp_error = 1'b0;
end   
endgenerate





generate
if (PORT_MODE == "WR_MODE" || PORT_MODE == "BI_MODE") begin : WR_PATH

   write_data_path
     #(
     
       .TCQ           (TCQ),
       .FAMILY  (FAMILY),
       .MEM_BURST_LEN     (MEM_BLEN),
       .ADDR_WIDTH        (ADDR_WIDTH),
       .DATA_PATTERN      (DATA_PATTERN),
       .DWIDTH            (DWIDTH),
       .NUM_DQ_PINS       (NUM_DQ_PINS),
       .SEL_VICTIM_LINE   (SEL_VICTIM_LINE),
       .MEM_COL_WIDTH     (MEM_COL_WIDTH),
       .EYE_TEST          (EYE_TEST)

       )
   write_data_path
     (
      .clk_i(clk_i),
      .rst_i            (rst_rb),
      .cmd_rdy_o            (wr_rdy),
      .cmd_valid_i          (wr_valid),
      .cmd_validB_i          (wr_validB),
      .cmd_validC_i          (wr_validC),
      .prbs_fseed_i         (data_seed_i),
      .data_mode_i          (data_mode_r_c),
      .last_word_wr_o       (last_word_wr),
//      .m_addr_i             (m_addr),//(rd_addr),
      .fixed_data_i         (fixed_data_i),
      .addr_i               (wr_addr),
      .bl_i                 (wr_bl),
      .data_rdy_i           (!mcb_wr_full),
      .data_valid_o         (mcb_wr_en),
      .data_o               (mcb_wr_data_o),
      .data_mask_o          (mcb_wr_mask_o),
      .data_wr_end_o           (mcb_wr_data_end_o)
      );
   
end
endgenerate

assign  mcb_wr_en_o = mcb_wr_en;



   tg_status
     #(
     
       .TCQ           (TCQ),
       .DWIDTH            (DWIDTH)
       )
   tg_status
     (
      .clk_i              (clk_i),
      .rst_i              (rst_ra[2]),
      .manual_clear_error (manual_clear_error),
      .data_error_i       (cmp_error),
      .cmp_data_i         (cmp_data),
      .rd_data_i          (mem_rd_data ),
      .cmp_addr_i         (cmp_addr),
      .cmp_bl_i           (cmp_bl),
      .mcb_cmd_full_i     (mcb_cmd_full_i),
      .mcb_wr_full_i      (mcb_wr_full),           // mcb_wr_full_r2 ???
      .mcb_rd_empty_i     (mcb_rd_empty),
      .error_status       (error_status),
      .error              (error)
      );


endmodule // mcb_traffic_gen
