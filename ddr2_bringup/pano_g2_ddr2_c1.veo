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
//  /   /        Filename           : pano_g2_ddr2_c1.veo
// /___/   /\    Date Last Modified : $Date: 2011/06/02 07:19:03 $
// \   \  /  \   Date Created       : Fri Aug 7 2009
//  \___\/\___\
//
// Purpose     : Template file containing code that can be used as a model
//               for instantiating a CORE Generator module in a HDL design.
// Revision History:
//*****************************************************************************

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

 pano_g2_ddr2_c1 # (
    .C1_P0_MASK_SIZE(4),
    .C1_P0_DATA_PORT_SIZE(32),
    .C1_P1_MASK_SIZE(4),
    .C1_P1_DATA_PORT_SIZE(32),
    .DEBUG_EN(1),
    .C1_MEMCLK_PERIOD(8000),
    .C1_CALIB_SOFT_IP("TRUE"),
    .C1_SIMULATION("FALSE"),
    .C1_RST_ACT_LOW(0),
    .C1_INPUT_CLK_TYPE("SINGLE_ENDED"),
    .C1_MEM_ADDR_ORDER("ROW_BANK_COLUMN"),
    .C1_NUM_DQ_PINS(16),
    .C1_MEM_ADDR_WIDTH(13),
    .C1_MEM_BANKADDR_WIDTH(2)
)
u_pano_g2_ddr2_c1 (

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
               
     .mcb1_zio               (zio1),
               
     .c1_p0_cmd_clk                          (c1_p0_cmd_clk),
   .c1_p0_cmd_en                           (c1_p0_cmd_en),
   .c1_p0_cmd_instr                        (c1_p0_cmd_instr),
   .c1_p0_cmd_bl                           (c1_p0_cmd_bl),
   .c1_p0_cmd_byte_addr                    (c1_p0_cmd_byte_addr),
   .c1_p0_cmd_empty                        (c1_p0_cmd_empty),
   .c1_p0_cmd_full                         (c1_p0_cmd_full),
   .c1_p0_wr_clk                           (c1_p0_wr_clk),
   .c1_p0_wr_en                            (c1_p0_wr_en),
   .c1_p0_wr_mask                          (c1_p0_wr_mask),
   .c1_p0_wr_data                          (c1_p0_wr_data),
   .c1_p0_wr_full                          (c1_p0_wr_full),
   .c1_p0_wr_empty                         (c1_p0_wr_empty),
   .c1_p0_wr_count                         (c1_p0_wr_count),
   .c1_p0_wr_underrun                      (c1_p0_wr_underrun),
   .c1_p0_wr_error                         (c1_p0_wr_error),
   .c1_p0_rd_clk                           (c1_p0_rd_clk),
   .c1_p0_rd_en                            (c1_p0_rd_en),
   .c1_p0_rd_data                          (c1_p0_rd_data),
   .c1_p0_rd_full                          (c1_p0_rd_full),
   .c1_p0_rd_empty                         (c1_p0_rd_empty),
   .c1_p0_rd_count                         (c1_p0_rd_count),
   .c1_p0_rd_overflow                      (c1_p0_rd_overflow),
   .c1_p0_rd_error                         (c1_p0_rd_error),
   .c1_p1_cmd_clk                          (c1_p1_cmd_clk),
   .c1_p1_cmd_en                           (c1_p1_cmd_en),
   .c1_p1_cmd_instr                        (c1_p1_cmd_instr),
   .c1_p1_cmd_bl                           (c1_p1_cmd_bl),
   .c1_p1_cmd_byte_addr                    (c1_p1_cmd_byte_addr),
   .c1_p1_cmd_empty                        (c1_p1_cmd_empty),
   .c1_p1_cmd_full                         (c1_p1_cmd_full),
   .c1_p1_wr_clk                           (c1_p1_wr_clk),
   .c1_p1_wr_en                            (c1_p1_wr_en),
   .c1_p1_wr_mask                          (c1_p1_wr_mask),
   .c1_p1_wr_data                          (c1_p1_wr_data),
   .c1_p1_wr_full                          (c1_p1_wr_full),
   .c1_p1_wr_empty                         (c1_p1_wr_empty),
   .c1_p1_wr_count                         (c1_p1_wr_count),
   .c1_p1_wr_underrun                      (c1_p1_wr_underrun),
   .c1_p1_wr_error                         (c1_p1_wr_error),
   .c1_p1_rd_clk                           (c1_p1_rd_clk),
   .c1_p1_rd_en                            (c1_p1_rd_en),
   .c1_p1_rd_data                          (c1_p1_rd_data),
   .c1_p1_rd_full                          (c1_p1_rd_full),
   .c1_p1_rd_empty                         (c1_p1_rd_empty),
   .c1_p1_rd_count                         (c1_p1_rd_count),
   .c1_p1_rd_overflow                      (c1_p1_rd_overflow),
   .c1_p1_rd_error                         (c1_p1_rd_error),
   .c1_p2_cmd_clk                          (c1_p2_cmd_clk),
   .c1_p2_cmd_en                           (c1_p2_cmd_en),
   .c1_p2_cmd_instr                        (c1_p2_cmd_instr),
   .c1_p2_cmd_bl                           (c1_p2_cmd_bl),
   .c1_p2_cmd_byte_addr                    (c1_p2_cmd_byte_addr),
   .c1_p2_cmd_empty                        (c1_p2_cmd_empty),
   .c1_p2_cmd_full                         (c1_p2_cmd_full),
   .c1_p2_wr_clk                           (c1_p2_wr_clk),
   .c1_p2_wr_en                            (c1_p2_wr_en),
   .c1_p2_wr_mask                          (c1_p2_wr_mask),
   .c1_p2_wr_data                          (c1_p2_wr_data),
   .c1_p2_wr_full                          (c1_p2_wr_full),
   .c1_p2_wr_empty                         (c1_p2_wr_empty),
   .c1_p2_wr_count                         (c1_p2_wr_count),
   .c1_p2_wr_underrun                      (c1_p2_wr_underrun),
   .c1_p2_wr_error                         (c1_p2_wr_error),
   .c1_p2_rd_clk                           (c1_p2_rd_clk),
   .c1_p2_rd_en                            (c1_p2_rd_en),
   .c1_p2_rd_data                          (c1_p2_rd_data),
   .c1_p2_rd_full                          (c1_p2_rd_full),
   .c1_p2_rd_empty                         (c1_p2_rd_empty),
   .c1_p2_rd_count                         (c1_p2_rd_count),
   .c1_p2_rd_overflow                      (c1_p2_rd_overflow),
   .c1_p2_rd_error                         (c1_p2_rd_error),
   .c1_p3_cmd_clk                          (c1_p3_cmd_clk),
   .c1_p3_cmd_en                           (c1_p3_cmd_en),
   .c1_p3_cmd_instr                        (c1_p3_cmd_instr),
   .c1_p3_cmd_bl                           (c1_p3_cmd_bl),
   .c1_p3_cmd_byte_addr                    (c1_p3_cmd_byte_addr),
   .c1_p3_cmd_empty                        (c1_p3_cmd_empty),
   .c1_p3_cmd_full                         (c1_p3_cmd_full),
   .c1_p3_wr_clk                           (c1_p3_wr_clk),
   .c1_p3_wr_en                            (c1_p3_wr_en),
   .c1_p3_wr_mask                          (c1_p3_wr_mask),
   .c1_p3_wr_data                          (c1_p3_wr_data),
   .c1_p3_wr_full                          (c1_p3_wr_full),
   .c1_p3_wr_empty                         (c1_p3_wr_empty),
   .c1_p3_wr_count                         (c1_p3_wr_count),
   .c1_p3_wr_underrun                      (c1_p3_wr_underrun),
   .c1_p3_wr_error                         (c1_p3_wr_error),
   .c1_p3_rd_clk                           (c1_p3_rd_clk),
   .c1_p3_rd_en                            (c1_p3_rd_en),
   .c1_p3_rd_data                          (c1_p3_rd_data),
   .c1_p3_rd_full                          (c1_p3_rd_full),
   .c1_p3_rd_empty                         (c1_p3_rd_empty),
   .c1_p3_rd_count                         (c1_p3_rd_count),
   .c1_p3_rd_overflow                      (c1_p3_rd_overflow),
   .c1_p3_rd_error                         (c1_p3_rd_error)
);

// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file pano_g2_ddr2_c1.v when simulating
// the core, pano_g2_ddr2_c1. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

