//*****************************************************************************
// (c) Copyright 2009 Xilinx, Inc. All rights reserved.
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
// /___/  \  /   Vendor             : Xilinx
// \   \   \/    Version            : 3.92
//  \   \        Application        : MIG
//  /   /        Filename           : sim_tb_top.v
// /___/   /\    Date Last Modified : $Date: 2011/06/02 07:16:56 $
// \   \  /  \   Date Created	    : Mon Mar 2 2009
//  \___\/\___\
//
// Device      : Spartan-6
// Design Name : DDR/DDR2/DDR3/LPDDR
// Purpose     : This is the simulation testbench which is used to verify the
//               design. The basic clocks and resets to the interface are
//               generated here. This also connects the memory interface to the
//               memory model.
//*****************************************************************************

`timescale 1ps/1ps
module sim_tb_top;

// ========================================================================== //
// Parameters                                                                 //
// ========================================================================== //
   parameter DEBUG_EN                = 0;
   localparam DBG_WR_STS_WIDTH       = 32;
   localparam DBG_RD_STS_WIDTH       = 32;
   localparam C1_P0_PORT_MODE             =  "BI_MODE";
   localparam C1_P1_PORT_MODE             =  "BI_MODE";
   localparam C1_P2_PORT_MODE             =  "BI_MODE";
   localparam C1_P3_PORT_MODE             =  "BI_MODE";
   localparam C1_P4_PORT_MODE             =  "NONE";
   localparam C1_P5_PORT_MODE             =  "NONE";
   localparam C1_PORT_ENABLE              = 6'b001111;
   localparam C1_PORT_CONFIG             =  "B32_B32_B32_B32";
   	parameter C1_MEMCLK_PERIOD     = 8000;
   parameter C1_RST_ACT_LOW        = 0;
   parameter C1_INPUT_CLK_TYPE     = "SINGLE_ENDED";
   parameter C1_NUM_DQ_PINS        = 16;
   parameter C1_MEM_ADDR_WIDTH     = 13;
   parameter C1_MEM_BANKADDR_WIDTH = 2;   
   parameter C1_MEM_ADDR_ORDER     = "ROW_BANK_COLUMN"; 
      parameter C1_P0_MASK_SIZE       = 4;
   parameter C1_P0_DATA_PORT_SIZE  = 32;  
   parameter C1_P1_MASK_SIZE       = 4;
   parameter C1_P1_DATA_PORT_SIZE  = 32;
   parameter C1_MEM_BURST_LEN	  = 4;
   parameter C1_MEM_NUM_COL_BITS   = 10;
   parameter C1_CALIB_SOFT_IP      = "TRUE";  
   parameter C1_SIMULATION      = "TRUE";
   parameter C1_HW_TESTING      = "FALSE";
   parameter C1_SMALL_DEVICE    = "FALSE";
   localparam C1_p0_BEGIN_ADDRESS                   = (C1_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C1_p0_DATA_MODE                       = 4'b0010;
   localparam C1_p0_END_ADDRESS                     = (C1_HW_TESTING == "TRUE") ? 32'h02ffffff:32'h000002ff;
   localparam C1_p0_PRBS_EADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'hfc000000:32'hfffffc00;
   localparam C1_p0_PRBS_SADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C1_p1_BEGIN_ADDRESS                   = (C1_HW_TESTING == "TRUE") ? 32'h03000000:32'h00000300;
   localparam C1_p1_DATA_MODE                       = 4'b0010;
   localparam C1_p1_END_ADDRESS                     = (C1_HW_TESTING == "TRUE") ? 32'h04ffffff:32'h000004ff;
   localparam C1_p1_PRBS_EADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'hf8000000:32'hfffff800;
   localparam C1_p1_PRBS_SADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'h03000000:32'h00000300;
   localparam C1_p2_BEGIN_ADDRESS                   = (C1_HW_TESTING == "TRUE") ? 32'h05000000:32'h00000500;
   localparam C1_p2_DATA_MODE                       = 4'b0010;
   localparam C1_p2_END_ADDRESS                     = (C1_HW_TESTING == "TRUE") ? 32'h06ffffff:32'h000006ff;
   localparam C1_p2_PRBS_EADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'hf8000000:32'hfffff800;
   localparam C1_p2_PRBS_SADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'h05000000:32'h00000500;
   localparam C1_p3_BEGIN_ADDRESS                   = (C1_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000700;
   localparam C1_p3_DATA_MODE                       = 4'b0010;
   localparam C1_p3_END_ADDRESS                     = (C1_HW_TESTING == "TRUE") ? 32'h02ffffff:32'h000008ff;
   localparam C1_p3_PRBS_EADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'hfc000000:32'hfffff000;
   localparam C1_p3_PRBS_SADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000700;
   localparam C1_p4_BEGIN_ADDRESS                   = (C1_HW_TESTING == "TRUE") ? 32'h05000000:32'h00000500;
   localparam C1_p4_DATA_MODE                       = 4'b0010;
   localparam C1_p4_END_ADDRESS                     = (C1_HW_TESTING == "TRUE") ? 32'h06ffffff:32'h000006ff;
   localparam C1_p4_PRBS_EADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'hf8000000:32'hfffff800;
   localparam C1_p4_PRBS_SADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'h05000000:32'h00000500;
   localparam C1_p5_BEGIN_ADDRESS                   = (C1_HW_TESTING == "TRUE") ? 32'h05000000:32'h00000500;
   localparam C1_p5_DATA_MODE                       = 4'b0010;
   localparam C1_p5_END_ADDRESS                     = (C1_HW_TESTING == "TRUE") ? 32'h06ffffff:32'h000006ff;
   localparam C1_p5_PRBS_EADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'hf8000000:32'hfffff800;
   localparam C1_p5_PRBS_SADDR_MASK_POS             = (C1_HW_TESTING == "TRUE") ? 32'h05000000:32'h00000500;
// ========================================================================== //
// Signal Declarations                                                        //
// ========================================================================== //

// Clocks
		// Clocks
   reg                              c1_sys_clk;
   wire                             c1_sys_clk_p;
   wire                             c1_sys_clk_n;
// System Reset
   reg                              c1_sys_rst;
   wire                             c1_sys_rst_i;

// Design-Top Port Map
   wire                             c1_error;
   wire                             c1_calib_done;
   wire [31:0]                      c1_cmp_data;
   wire                             c1_cmp_error;

   wire [C1_MEM_ADDR_WIDTH-1:0]      mcb1_dram_a;
   wire [C1_MEM_BANKADDR_WIDTH-1:0]  mcb1_dram_ba;  
   wire                             mcb1_dram_ck;  
   wire                             mcb1_dram_ck_n;
   wire [C1_NUM_DQ_PINS-1:0]        mcb1_dram_dq;   
   wire                             mcb1_dram_dqs;  
   wire                             mcb1_dram_dqs_n;
   wire                             mcb1_dram_dm;
   wire                             mcb1_dram_ras_n; 
   wire                             mcb1_dram_cas_n; 
   wire                             mcb1_dram_we_n;  
   wire                             mcb1_dram_cke; 
   wire				                mcb1_dram_odt;

   wire [64 + (2*C1_P0_DATA_PORT_SIZE - 1):0]     c1_p0_error_status;
   wire [64 + (2*C1_P1_DATA_PORT_SIZE - 1):0]     c1_p1_error_status;
   wire [127 : 0]     c1_p2_error_status;
   wire [127 : 0]     c1_p3_error_status;
   wire [127 : 0]     c1_p4_error_status;
   wire [127 : 0]     c1_p5_error_status;

   wire                             mcb1_dram_udqs;    // for X16 parts
   wire                             mcb1_dram_udqs_n;  // for X16 parts
   wire                             mcb1_dram_udm;     // for X16 parts
   wire                              c1_vio_modify_enable   = 1'b1;
   wire  [2:0]                       c1_vio_data_mode_value = 3'b010;
   wire  [2:0]                       c1_vio_addr_mode_value = 3'b011;

// User design  Sim
        wire                             c1_clk0;
   wire							 c1_rst0;

   reg                              c1_aresetn;
   wire                              c1_wrap_en;
   wire                              c1_cmd_err;
   wire                              c1_data_msmatch_err;
   wire                              c1_write_err;
   wire                              c1_read_err;
   wire                              c1_test_cmptd;
   wire                              c1_dbg_wr_sts_vld;
   wire                              c1_dbg_rd_sts_vld;
   wire  [DBG_WR_STS_WIDTH-1:0]                      c1_dbg_wr_sts;
   wire  [DBG_WR_STS_WIDTH-1:0]                      c1_dbg_rd_sts;
     wire		c1_p0_cmd_en;
  wire [2:0]	c1_p0_cmd_instr;
  wire [5:0]	c1_p0_cmd_bl;
  wire [29:0]	c1_p0_cmd_byte_addr;
  wire		c1_p0_cmd_empty;
  wire		c1_p0_cmd_full;
  wire		c1_p0_wr_en;
  wire [C1_P0_MASK_SIZE - 1:0]	c1_p0_wr_mask;
  wire [C1_P0_DATA_PORT_SIZE - 1:0]	c1_p0_wr_data;
  wire		c1_p0_wr_full;
  wire		c1_p0_wr_empty;
  wire [6:0]	c1_p0_wr_count;
  wire		c1_p0_wr_underrun;
  wire		c1_p0_wr_error;
  wire		c1_p0_rd_en;
  wire [C1_P0_DATA_PORT_SIZE - 1:0]	c1_p0_rd_data;
  wire		c1_p0_rd_full;
  wire		c1_p0_rd_empty;
  wire [6:0]	c1_p0_rd_count;
  wire		c1_p0_rd_overflow;
  wire		c1_p0_rd_error;

  wire		c1_p1_cmd_en;
  wire [2:0]	c1_p1_cmd_instr;
  wire [5:0]	c1_p1_cmd_bl;
  wire [29:0]	c1_p1_cmd_byte_addr;
  wire		c1_p1_cmd_empty;
  wire		c1_p1_cmd_full;
  wire		c1_p1_wr_en;
  wire [C1_P1_MASK_SIZE - 1:0]	c1_p1_wr_mask;
  wire [C1_P1_DATA_PORT_SIZE - 1:0]	c1_p1_wr_data;
  wire		c1_p1_wr_full;
  wire		c1_p1_wr_empty;
  wire [6:0]	c1_p1_wr_count;
  wire		c1_p1_wr_underrun;
  wire		c1_p1_wr_error;
  wire		c1_p1_rd_en;
  wire [C1_P1_DATA_PORT_SIZE - 1:0]	c1_p1_rd_data;
  wire		c1_p1_rd_full;
  wire		c1_p1_rd_empty;
  wire [6:0]	c1_p1_rd_count;
  wire		c1_p1_rd_overflow;
  wire		c1_p1_rd_error;

  wire		c1_p2_cmd_en;
  wire [2:0]	c1_p2_cmd_instr;
  wire [5:0]	c1_p2_cmd_bl;
  wire [29:0]	c1_p2_cmd_byte_addr;
  wire		c1_p2_cmd_empty;
  wire		c1_p2_cmd_full;
  wire		c1_p2_wr_en;
  wire [3:0]	c1_p2_wr_mask;
  wire [31:0]	c1_p2_wr_data;
  wire		c1_p2_wr_full;
  wire		c1_p2_wr_empty;
  wire [6:0]	c1_p2_wr_count;
  wire		c1_p2_wr_underrun;
  wire		c1_p2_wr_error;
  wire		c1_p2_rd_en;
  wire [31:0]	c1_p2_rd_data;
  wire		c1_p2_rd_full;
  wire		c1_p2_rd_empty;
  wire [6:0]	c1_p2_rd_count;
  wire		c1_p2_rd_overflow;
  wire		c1_p2_rd_error;

  wire		c1_p3_cmd_en;
  wire [2:0]	c1_p3_cmd_instr;
  wire [5:0]	c1_p3_cmd_bl;
  wire [29:0]	c1_p3_cmd_byte_addr;
  wire		c1_p3_cmd_empty;
  wire		c1_p3_cmd_full;
  wire		c1_p3_wr_en;
  wire [3:0]	c1_p3_wr_mask;
  wire [31:0]	c1_p3_wr_data;
  wire		c1_p3_wr_full;
  wire		c1_p3_wr_empty;
  wire [6:0]	c1_p3_wr_count;
  wire		c1_p3_wr_underrun;
  wire		c1_p3_wr_error;
  wire		c1_p3_rd_en;
  wire [31:0]	c1_p3_rd_data;
  wire		c1_p3_rd_full;
  wire		c1_p3_rd_empty;
  wire [6:0]	c1_p3_rd_count;
  wire		c1_p3_rd_overflow;
  wire		c1_p3_rd_error;

wire				c1_p4_cmd_clk;
wire				c1_p4_cmd_en;
wire[2:0]			c1_p4_cmd_instr;
wire[5:0]			c1_p4_cmd_bl;
wire[29:0]			c1_p4_cmd_byte_addr;
wire				c1_p4_cmd_empty;
wire				c1_p4_cmd_full;
wire				c1_p4_wr_clk;
wire				c1_p4_wr_en;
wire[3:0]			c1_p4_wr_mask;
wire[31:0]			c1_p4_wr_data;
wire				c1_p4_wr_full;
wire				c1_p4_wr_empty;
wire[6:0]			c1_p4_wr_count;
wire				c1_p4_wr_underrun;
wire				c1_p4_wr_error;
wire				c1_p4_rd_clk;
wire				c1_p4_rd_en;
wire[31:0]			c1_p4_rd_data;
wire				c1_p4_rd_full;
wire				c1_p4_rd_empty;
wire[6:0]			c1_p4_rd_count;
wire				c1_p4_rd_overflow;
wire				c1_p4_rd_error;
wire				c1_p5_cmd_clk;
wire				c1_p5_cmd_en;
wire[2:0]			c1_p5_cmd_instr;
wire[5:0]			c1_p5_cmd_bl;
wire[29:0]			c1_p5_cmd_byte_addr;
wire				c1_p5_cmd_empty;
wire				c1_p5_cmd_full;
wire				c1_p5_wr_clk;
wire				c1_p5_wr_en;
wire[3:0]			c1_p5_wr_mask;
wire[31:0]			c1_p5_wr_data;
wire				c1_p5_wr_full;
wire				c1_p5_wr_empty;
wire[6:0]			c1_p5_wr_count;
wire				c1_p5_wr_underrun;
wire				c1_p5_wr_error;
wire				c1_p5_rd_clk;
wire				c1_p5_rd_en;
wire[31:0]			c1_p5_rd_data;
wire				c1_p5_rd_full;
wire				c1_p5_rd_empty;
wire[6:0]			c1_p5_rd_count;
wire				c1_p5_rd_overflow;
wire				c1_p5_rd_error;

// Error & Calib Signals
   wire                             error;
   wire                             calib_done;
   wire				    rzq1;
     
   
// ========================================================================== //
// Clocks Generation                                                          //
// ========================================================================== //

   initial
      c1_sys_clk = 1'b0;
   always
      #(C1_MEMCLK_PERIOD/2) c1_sys_clk = ~c1_sys_clk;

   assign                c1_sys_clk_p = c1_sys_clk;
   assign                c1_sys_clk_n = ~c1_sys_clk;

// ========================================================================== //
// Reset Generation                                                           //
// ========================================================================== //
 
   initial begin
      c1_sys_rst = 1'b0;		
      #20000;
      c1_sys_rst = 1'b1;
   end
   assign c1_sys_rst_i = C1_RST_ACT_LOW ? c1_sys_rst : ~c1_sys_rst;

// ========================================================================== //
// Error Grouping                                                           //
// ========================================================================== //
assign error = c1_error;
assign calib_done = c1_calib_done;

   

   PULLDOWN rzq_pulldown1 (.O(rzq1));
   

// ========================================================================== //
// DESIGN TOP INSTANTIATION                                                    //
// ========================================================================== //



pano_g2_ddr2_c1 #(

.C1_P0_MASK_SIZE       (C1_P0_MASK_SIZE      ),
.C1_P0_DATA_PORT_SIZE  (C1_P0_DATA_PORT_SIZE ),
.C1_P1_MASK_SIZE       (C1_P1_MASK_SIZE      ),
.C1_P1_DATA_PORT_SIZE  (C1_P1_DATA_PORT_SIZE ),
.C1_MEMCLK_PERIOD      (C1_MEMCLK_PERIOD),
.C1_RST_ACT_LOW        (C1_RST_ACT_LOW),
.C1_INPUT_CLK_TYPE     (C1_INPUT_CLK_TYPE),

 
.DEBUG_EN              (DEBUG_EN),

.C1_MEM_ADDR_ORDER     (C1_MEM_ADDR_ORDER    ),
.C1_NUM_DQ_PINS        (C1_NUM_DQ_PINS       ),
.C1_MEM_ADDR_WIDTH     (C1_MEM_ADDR_WIDTH    ),
.C1_MEM_BANKADDR_WIDTH (C1_MEM_BANKADDR_WIDTH),

.C1_SIMULATION         (C1_SIMULATION),
.C1_CALIB_SOFT_IP      (C1_CALIB_SOFT_IP )
)
design_top (


    .c1_sys_clk           (c1_sys_clk),
  .c1_sys_rst_i           (c1_sys_rst_i),                        

  .mcb1_dram_dq           (mcb1_dram_dq),  
  .mcb1_dram_a            (mcb1_dram_a),  
  .mcb1_dram_ba           (mcb1_dram_ba),
  .mcb1_dram_ras_n        (mcb1_dram_ras_n),                        
  .mcb1_dram_cas_n        (mcb1_dram_cas_n),                        
  .mcb1_dram_we_n         (mcb1_dram_we_n),                          
  .mcb1_dram_odt          (mcb1_dram_odt),
  .mcb1_dram_cke          (mcb1_dram_cke),                          
  .mcb1_dram_ck           (mcb1_dram_ck),                          
  .mcb1_dram_ck_n         (mcb1_dram_ck_n),       
  .mcb1_dram_dqs          (mcb1_dram_dqs),                          
  .mcb1_dram_dqs_n        (mcb1_dram_dqs_n),
  .mcb1_dram_udqs         (mcb1_dram_udqs),    // for X16 parts                        
  .mcb1_dram_udqs_n       (mcb1_dram_udqs_n),  // for X16 parts
  .mcb1_dram_udm          (mcb1_dram_udm),     // for X16 parts
  .mcb1_dram_dm           (mcb1_dram_dm),
    .c1_clk0		        (c1_clk0),
  .c1_rst0		        (c1_rst0),
	
 
  .c1_calib_done          (c1_calib_done),
     .mcb1_rzq               (rzq1),
               
         
     .c1_p0_cmd_clk                          (c1_clk0),
   .c1_p0_cmd_en                           (c1_p0_cmd_en),
   .c1_p0_cmd_instr                        (c1_p0_cmd_instr),
   .c1_p0_cmd_bl                           (c1_p0_cmd_bl),
   .c1_p0_cmd_byte_addr                    (c1_p0_cmd_byte_addr),
   .c1_p0_cmd_empty                        (c1_p0_cmd_empty),
   .c1_p0_cmd_full                         (c1_p0_cmd_full),
   .c1_p0_wr_clk                           (c1_clk0),
   .c1_p0_wr_en                            (c1_p0_wr_en),
   .c1_p0_wr_mask                          (c1_p0_wr_mask),
   .c1_p0_wr_data                          (c1_p0_wr_data),
   .c1_p0_wr_full                          (c1_p0_wr_full),
   .c1_p0_wr_empty                         (c1_p0_wr_empty),
   .c1_p0_wr_count                         (c1_p0_wr_count),
   .c1_p0_wr_underrun                      (c1_p0_wr_underrun),
   .c1_p0_wr_error                         (c1_p0_wr_error),
   .c1_p0_rd_clk                           (c1_clk0),
   .c1_p0_rd_en                            (c1_p0_rd_en),
   .c1_p0_rd_data                          (c1_p0_rd_data),
   .c1_p0_rd_full                          (c1_p0_rd_full),
   .c1_p0_rd_empty                         (c1_p0_rd_empty),
   .c1_p0_rd_count                         (c1_p0_rd_count),
   .c1_p0_rd_overflow                      (c1_p0_rd_overflow),
   .c1_p0_rd_error                         (c1_p0_rd_error),
   .c1_p1_cmd_clk                          (c1_clk0),
   .c1_p1_cmd_en                           (c1_p1_cmd_en),
   .c1_p1_cmd_instr                        (c1_p1_cmd_instr),
   .c1_p1_cmd_bl                           (c1_p1_cmd_bl),
   .c1_p1_cmd_byte_addr                    (c1_p1_cmd_byte_addr),
   .c1_p1_cmd_empty                        (c1_p1_cmd_empty),
   .c1_p1_cmd_full                         (c1_p1_cmd_full),
   .c1_p1_wr_clk                           (c1_clk0),
   .c1_p1_wr_en                            (c1_p1_wr_en),
   .c1_p1_wr_mask                          (c1_p1_wr_mask),
   .c1_p1_wr_data                          (c1_p1_wr_data),
   .c1_p1_wr_full                          (c1_p1_wr_full),
   .c1_p1_wr_empty                         (c1_p1_wr_empty),
   .c1_p1_wr_count                         (c1_p1_wr_count),
   .c1_p1_wr_underrun                      (c1_p1_wr_underrun),
   .c1_p1_wr_error                         (c1_p1_wr_error),
   .c1_p1_rd_clk                           (c1_clk0),
   .c1_p1_rd_en                            (c1_p1_rd_en),
   .c1_p1_rd_data                          (c1_p1_rd_data),
   .c1_p1_rd_full                          (c1_p1_rd_full),
   .c1_p1_rd_empty                         (c1_p1_rd_empty),
   .c1_p1_rd_count                         (c1_p1_rd_count),
   .c1_p1_rd_overflow                      (c1_p1_rd_overflow),
   .c1_p1_rd_error                         (c1_p1_rd_error),
   .c1_p2_cmd_clk                          (c1_clk0),
   .c1_p2_cmd_en                           (c1_p2_cmd_en),
   .c1_p2_cmd_instr                        (c1_p2_cmd_instr),
   .c1_p2_cmd_bl                           (c1_p2_cmd_bl),
   .c1_p2_cmd_byte_addr                    (c1_p2_cmd_byte_addr),
   .c1_p2_cmd_empty                        (c1_p2_cmd_empty),
   .c1_p2_cmd_full                         (c1_p2_cmd_full),
   .c1_p2_wr_clk                           (c1_clk0),
   .c1_p2_wr_en                            (c1_p2_wr_en),
   .c1_p2_wr_mask                          (c1_p2_wr_mask),
   .c1_p2_wr_data                          (c1_p2_wr_data),
   .c1_p2_wr_full                          (c1_p2_wr_full),
   .c1_p2_wr_empty                         (c1_p2_wr_empty),
   .c1_p2_wr_count                         (c1_p2_wr_count),
   .c1_p2_wr_underrun                      (c1_p2_wr_underrun),
   .c1_p2_wr_error                         (c1_p2_wr_error),
   .c1_p2_rd_clk                           (c1_clk0),
   .c1_p2_rd_en                            (c1_p2_rd_en),
   .c1_p2_rd_data                          (c1_p2_rd_data),
   .c1_p2_rd_full                          (c1_p2_rd_full),
   .c1_p2_rd_empty                         (c1_p2_rd_empty),
   .c1_p2_rd_count                         (c1_p2_rd_count),
   .c1_p2_rd_overflow                      (c1_p2_rd_overflow),
   .c1_p2_rd_error                         (c1_p2_rd_error),
   .c1_p3_cmd_clk                          (c1_clk0),
   .c1_p3_cmd_en                           (c1_p3_cmd_en),
   .c1_p3_cmd_instr                        (c1_p3_cmd_instr),
   .c1_p3_cmd_bl                           (c1_p3_cmd_bl),
   .c1_p3_cmd_byte_addr                    (c1_p3_cmd_byte_addr),
   .c1_p3_cmd_empty                        (c1_p3_cmd_empty),
   .c1_p3_cmd_full                         (c1_p3_cmd_full),
   .c1_p3_wr_clk                           (c1_clk0),
   .c1_p3_wr_en                            (c1_p3_wr_en),
   .c1_p3_wr_mask                          (c1_p3_wr_mask),
   .c1_p3_wr_data                          (c1_p3_wr_data),
   .c1_p3_wr_full                          (c1_p3_wr_full),
   .c1_p3_wr_empty                         (c1_p3_wr_empty),
   .c1_p3_wr_count                         (c1_p3_wr_count),
   .c1_p3_wr_underrun                      (c1_p3_wr_underrun),
   .c1_p3_wr_error                         (c1_p3_wr_error),
   .c1_p3_rd_clk                           (c1_clk0),
   .c1_p3_rd_en                            (c1_p3_rd_en),
   .c1_p3_rd_data                          (c1_p3_rd_data),
   .c1_p3_rd_full                          (c1_p3_rd_full),
   .c1_p3_rd_empty                         (c1_p3_rd_empty),
   .c1_p3_rd_count                         (c1_p3_rd_count),
   .c1_p3_rd_overflow                      (c1_p3_rd_overflow),
   .c1_p3_rd_error                         (c1_p3_rd_error)
);      


// Test bench top for the controller-1
      memc_tb_top #
      (
         .C_SIMULATION                   (C1_SIMULATION),
         .C_NUM_DQ_PINS                  (C1_NUM_DQ_PINS),
         .C_MEM_BURST_LEN                (C1_MEM_BURST_LEN),
         .C_MEM_NUM_COL_BITS             (C1_MEM_NUM_COL_BITS),
         .C_SMALL_DEVICE                 (C1_SMALL_DEVICE),

         // The following parameters from C_PORT_ENABLE to C_P5_PORT_MODE are introduced
         // to handle the static instances of all the six traffic generators inside the
   	     // memc_tb_top module. 
         .C_PORT_ENABLE                  (C1_PORT_ENABLE),
         .C_P0_MASK_SIZE                 (C1_P0_MASK_SIZE),
         .C_P0_DATA_PORT_SIZE            (C1_P0_DATA_PORT_SIZE),
         .C_P1_MASK_SIZE                 (C1_P1_MASK_SIZE),
         .C_P1_DATA_PORT_SIZE            (C1_P1_DATA_PORT_SIZE),
         .C_P0_PORT_MODE                 (C1_P0_PORT_MODE),  
         .C_P1_PORT_MODE                 (C1_P1_PORT_MODE),  
         .C_P2_PORT_MODE                 (C1_P2_PORT_MODE),  
         .C_P3_PORT_MODE                 (C1_P3_PORT_MODE),
         .C_P4_PORT_MODE                 (C1_P4_PORT_MODE),
         .C_P5_PORT_MODE                 (C1_P5_PORT_MODE),

         .C_p0_BEGIN_ADDRESS             (C1_p0_BEGIN_ADDRESS),
         .C_p0_DATA_MODE                 (C1_p0_DATA_MODE),
         .C_p0_END_ADDRESS               (C1_p0_END_ADDRESS),
         .C_p0_PRBS_EADDR_MASK_POS       (C1_p0_PRBS_EADDR_MASK_POS),
         .C_p0_PRBS_SADDR_MASK_POS       (C1_p0_PRBS_SADDR_MASK_POS),
         .C_p1_BEGIN_ADDRESS             (C1_p1_BEGIN_ADDRESS),
         .C_p1_DATA_MODE                 (C1_p1_DATA_MODE),
         .C_p1_END_ADDRESS               (C1_p1_END_ADDRESS),
         .C_p1_PRBS_EADDR_MASK_POS       (C1_p1_PRBS_EADDR_MASK_POS),
         .C_p1_PRBS_SADDR_MASK_POS       (C1_p1_PRBS_SADDR_MASK_POS),
         .C_p2_BEGIN_ADDRESS             (C1_p2_BEGIN_ADDRESS),
         .C_p2_DATA_MODE                 (C1_p2_DATA_MODE),
         .C_p2_END_ADDRESS               (C1_p2_END_ADDRESS),
         .C_p2_PRBS_EADDR_MASK_POS       (C1_p2_PRBS_EADDR_MASK_POS),
         .C_p2_PRBS_SADDR_MASK_POS       (C1_p2_PRBS_SADDR_MASK_POS),
         .C_p3_BEGIN_ADDRESS             (C1_p3_BEGIN_ADDRESS),
         .C_p3_DATA_MODE                 (C1_p3_DATA_MODE),
         .C_p3_END_ADDRESS               (C1_p3_END_ADDRESS),
         .C_p3_PRBS_EADDR_MASK_POS       (C1_p3_PRBS_EADDR_MASK_POS),
         .C_p3_PRBS_SADDR_MASK_POS       (C1_p3_PRBS_SADDR_MASK_POS),
         .C_p4_BEGIN_ADDRESS             (C1_p4_BEGIN_ADDRESS),
         .C_p4_DATA_MODE                 (C1_p4_DATA_MODE),
         .C_p4_END_ADDRESS               (C1_p4_END_ADDRESS),
         .C_p4_PRBS_EADDR_MASK_POS       (C1_p4_PRBS_EADDR_MASK_POS),
         .C_p4_PRBS_SADDR_MASK_POS       (C1_p4_PRBS_SADDR_MASK_POS),
         .C_p5_BEGIN_ADDRESS             (C1_p5_BEGIN_ADDRESS),
         .C_p5_DATA_MODE                 (C1_p5_DATA_MODE),
         .C_p5_END_ADDRESS               (C1_p5_END_ADDRESS),
         .C_p5_PRBS_EADDR_MASK_POS       (C1_p5_PRBS_EADDR_MASK_POS),
         .C_p5_PRBS_SADDR_MASK_POS       (C1_p5_PRBS_SADDR_MASK_POS)
         )
      memc1_tb_top_inst
      (
         .error			                 (c1_error),
         .calib_done			         (c1_calib_done), 
         .clk0			                 (c1_clk0),
         .rst0			                 (c1_rst0),
         .cmp_error			             (c1_cmp_error),
         .cmp_data_valid  	             (c1_cmp_data_valid),
         .cmp_data			             (c1_cmp_data),
         .vio_modify_enable              (c1_vio_modify_enable),
         .vio_data_mode_value            (c1_vio_data_mode_value),
         .vio_addr_mode_value            (c1_vio_addr_mode_value),
         .p0_error_status	             (c1_p0_error_status),
         .p1_error_status	             (c1_p1_error_status),
         .p2_error_status	             (c1_p2_error_status),
         .p3_error_status	             (c1_p3_error_status),
         .p4_error_status	             (c1_p4_error_status),
         .p5_error_status	             (c1_p5_error_status),

  	     // The following port map shows that all the memory controller ports are connected
         // to the test bench top. However, a traffic generator can be connected to the 
         // corresponding port only if the port is enabled, whose information can be obtained
         // from the parameters C_PORT_ENABLE.

         // User Port-0 command interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
         .p0_mcb_cmd_en                  (c1_p0_cmd_en),
         .p0_mcb_cmd_instr               (c1_p0_cmd_instr),
         .p0_mcb_cmd_bl                  (c1_p0_cmd_bl),
         .p0_mcb_cmd_addr                (c1_p0_cmd_byte_addr),
         .p0_mcb_cmd_full                (c1_p0_cmd_full),
         // User Port-0 data write interface will be active only when the port is enabled in
         // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
         .p0_mcb_wr_en                   (c1_p0_wr_en),
         .p0_mcb_wr_mask                 (c1_p0_wr_mask),
         .p0_mcb_wr_data                 (c1_p0_wr_data),
         .p0_mcb_wr_full                 (c1_p0_wr_full),
         .p0_mcb_wr_fifo_counts          (c1_p0_wr_count),
         // User Port-0 data read interface will be active only when the port is enabled in
         // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
         .p0_mcb_rd_en                   (c1_p0_rd_en),
         .p0_mcb_rd_data                 (c1_p0_rd_data),
         .p0_mcb_rd_empty                (c1_p0_rd_empty),
         .p0_mcb_rd_fifo_counts          (c1_p0_rd_count),

         // User Port-1 command interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2, Config-3 and Config-4
         .p1_mcb_cmd_en                  (c1_p1_cmd_en),
         .p1_mcb_cmd_instr               (c1_p1_cmd_instr),
         .p1_mcb_cmd_bl                  (c1_p1_cmd_bl),
         .p1_mcb_cmd_addr                (c1_p1_cmd_byte_addr),
         .p1_mcb_cmd_full                (c1_p1_cmd_full),
         // User Port-1 data write interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2, Config-3 and Config-4
         .p1_mcb_wr_en                   (c1_p1_wr_en),
         .p1_mcb_wr_mask                 (c1_p1_wr_mask),
         .p1_mcb_wr_data                 (c1_p1_wr_data),
         .p1_mcb_wr_full                 (c1_p1_wr_full),
         .p1_mcb_wr_fifo_counts          (c1_p1_wr_count),
         // User Port-1 data read interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2, Config-3 and Config-4
         .p1_mcb_rd_en                   (c1_p1_rd_en),
         .p1_mcb_rd_data                 (c1_p1_rd_data),
         .p1_mcb_rd_empty                (c1_p1_rd_empty),
         .p1_mcb_rd_fifo_counts          (c1_p1_rd_count),

         // User Port-2 command interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2 and Config-3
         .p2_mcb_cmd_en                  (c1_p2_cmd_en),
         .p2_mcb_cmd_instr               (c1_p2_cmd_instr),
         .p2_mcb_cmd_bl                  (c1_p2_cmd_bl),
         .p2_mcb_cmd_addr                (c1_p2_cmd_byte_addr),
         .p2_mcb_cmd_full                (c1_p2_cmd_full),
         // User Port-2 data write interface will be active only when the port is enabled in 
         // the port configurations Config-1 write direction, Config-2 and Config-3
         .p2_mcb_wr_en                   (c1_p2_wr_en),
         .p2_mcb_wr_mask                 (c1_p2_wr_mask),
         .p2_mcb_wr_data                 (c1_p2_wr_data),
         .p2_mcb_wr_full                 (c1_p2_wr_full),
         .p2_mcb_wr_fifo_counts          (c1_p2_wr_count),
         // User Port-2 data read interface will be active only when the port is enabled in 
         // the port configurations Config-1 read direction, Config-2 and Config-3
         .p2_mcb_rd_en                   (c1_p2_rd_en),
         .p2_mcb_rd_data                 (c1_p2_rd_data),
         .p2_mcb_rd_empty                (c1_p2_rd_empty),
         .p2_mcb_rd_fifo_counts          (c1_p2_rd_count),

         // User Port-3 command interface will be active only when the port is enabled in 
         // the port configurations Config-1 and Config-2
         .p3_mcb_cmd_en                  (c1_p3_cmd_en),
         .p3_mcb_cmd_instr               (c1_p3_cmd_instr),
         .p3_mcb_cmd_bl                  (c1_p3_cmd_bl),
         .p3_mcb_cmd_addr                (c1_p3_cmd_byte_addr),
         .p3_mcb_cmd_full                (c1_p3_cmd_full),
         // User Port-3 data write interface will be active only when the port is enabled in 
         // the port configurations Config-1 write direction and Config-2
         .p3_mcb_wr_en                   (c1_p3_wr_en),
         .p3_mcb_wr_mask                 (c1_p3_wr_mask),
         .p3_mcb_wr_data                 (c1_p3_wr_data),
         .p3_mcb_wr_full                 (c1_p3_wr_full),
         .p3_mcb_wr_fifo_counts          (c1_p3_wr_count),
         // User Port-3 data read interface will be active only when the port is enabled in 
         // the port configurations Config-1 read direction and Config-2
         .p3_mcb_rd_en                   (c1_p3_rd_en),
         .p3_mcb_rd_data                 (c1_p3_rd_data),
         .p3_mcb_rd_empty                (c1_p3_rd_empty),
         .p3_mcb_rd_fifo_counts          (c1_p3_rd_count),

         // User Port-4 command interface will be active only when the port is enabled in 
         // the port configuration Config-1
         .p4_mcb_cmd_en                  (c1_p4_cmd_en),
         .p4_mcb_cmd_instr               (c1_p4_cmd_instr),
         .p4_mcb_cmd_bl                  (c1_p4_cmd_bl),
         .p4_mcb_cmd_addr                (c1_p4_cmd_byte_addr),
         .p4_mcb_cmd_full                (c1_p4_cmd_full),
         // User Port-4 data write interface will be active only when the port is enabled in 
         // the port configuration Config-1 write direction
         .p4_mcb_wr_en                   (c1_p4_wr_en),
         .p4_mcb_wr_mask                 (c1_p4_wr_mask),
         .p4_mcb_wr_data                 (c1_p4_wr_data),
         .p4_mcb_wr_full                 (c1_p4_wr_full),
         .p4_mcb_wr_fifo_counts          (c1_p4_wr_count),
         // User Port-4 data read interface will be active only when the port is enabled in 
         // the port configuration Config-1 read direction
         .p4_mcb_rd_en                   (c1_p4_rd_en),
         .p4_mcb_rd_data                 (c1_p4_rd_data),
         .p4_mcb_rd_empty                (c1_p4_rd_empty),
         .p4_mcb_rd_fifo_counts          (c1_p4_rd_count),

         // User Port-5 command interface will be active only when the port is enabled in 
         // the port configuration Config-1
         .p5_mcb_cmd_en                  (c1_p5_cmd_en),
         .p5_mcb_cmd_instr               (c1_p5_cmd_instr),
         .p5_mcb_cmd_bl                  (c1_p5_cmd_bl),
         .p5_mcb_cmd_addr                (c1_p5_cmd_byte_addr),
         .p5_mcb_cmd_full                (c1_p5_cmd_full),
         // User Port-5 data write interface will be active only when the port is enabled in 
         // the port configuration Config-1 write direction
         .p5_mcb_wr_en                   (c1_p5_wr_en),
         .p5_mcb_wr_mask                 (c1_p5_wr_mask),
         .p5_mcb_wr_data                 (c1_p5_wr_data),
         .p5_mcb_wr_full                 (c1_p5_wr_full),
         .p5_mcb_wr_fifo_counts          (c1_p5_wr_count),
         // User Port-5 data read interface will be active only when the port is enabled in 
         // the port configuration Config-1 read direction
         .p5_mcb_rd_en                   (c1_p5_rd_en),
         .p5_mcb_rd_data                 (c1_p5_rd_data),
         .p5_mcb_rd_empty                (c1_p5_rd_empty),
         .p5_mcb_rd_fifo_counts          (c1_p5_rd_count)
        );
   









// ========================================================================== //
// Memory model instances                                                     // 
// ========================================================================== //

   generate
      if(C1_NUM_DQ_PINS == 16) begin : MEM_INST1
     ddr2_model_c1 u_mem_c1(
        .ck         (mcb1_dram_ck),
        .ck_n       (mcb1_dram_ck_n),
        .cke        (mcb1_dram_cke),
        .cs_n       (1'b0),
        .ras_n      (mcb1_dram_ras_n),
        .cas_n      (mcb1_dram_cas_n),
        .we_n       (mcb1_dram_we_n),
        .dm_rdqs    ({mcb1_dram_udm,mcb1_dram_dm}),
        .ba         (mcb1_dram_ba),
        .addr       (mcb1_dram_a),
        .dq         (mcb1_dram_dq),
        .dqs        ({mcb1_dram_udqs,mcb1_dram_dqs}),
        .dqs_n      ({mcb1_dram_udqs_n,mcb1_dram_dqs_n}),
        .rdqs_n     (),
        .odt        (mcb1_dram_odt)
      );
      end else begin
     ddr2_model_c1 u_mem_c1(
        .ck         (mcb1_dram_ck),
        .ck_n       (mcb1_dram_ck_n),
        .cke        (mcb1_dram_cke),
        .cs_n       (1'b0),
        .ras_n      (mcb1_dram_ras_n),
        .cas_n      (mcb1_dram_cas_n),
        .we_n       (mcb1_dram_we_n),
        .dm_rdqs    (mcb1_dram_dm),
        .ba         (mcb1_dram_ba),
        .addr       (mcb1_dram_a),
        .dq         (mcb1_dram_dq),
        .dqs        (mcb1_dram_dqs),
        .dqs_n      (mcb1_dram_dqs_n),
        .rdqs_n     (),
        .odt        (mcb1_dram_odt)
      );
     end
   endgenerate

// ========================================================================== //
// Reporting the test case status 
// ========================================================================== //
   initial
   begin : Logging
      fork
         begin : calibration_done
            wait (calib_done);
            $display("Calibration Done");
            #50000000;
            if (!error) begin
               $display("TEST PASSED");
            end   
            else begin
               $display("TEST FAILED: DATA ERROR");		 
            end
            disable calib_not_done;
	    $finish;
         end	 
         
         begin : calib_not_done
            #200000000;
            if (!calib_done) begin
               $display("TEST FAILED: INITIALIZATION DID NOT COMPLETE");
            end
            disable calibration_done;
	    $finish;
         end
      join	 
   end      

endmodule
