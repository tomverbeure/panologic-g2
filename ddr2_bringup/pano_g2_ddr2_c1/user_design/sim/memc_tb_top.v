//*****************************************************************************
// (c) Copyright 2009-10 Xilinx, Inc. All rights reserved.
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
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Application        : MIG                          
//  \   \         Filename           : memc_tb_top.v
//  /   /         Date Last Modified : $Date: 2011/06/02 07:17:10 $
// /___/   /\     Date Created       : Fri Mar 26 2010
// \   \  /  \    
//  \___\/\___\
//
//Device           : Spartan-6
//Design Name      : DDR/DDR2/DDR3/LPDDR
//Purpose          : This is top level module for test bench, which instantiates 
//                   init_mem_pattern_ctr and mcb_traffic_gen modules for each user
//                   logical port.
//Reference        :
//Revision History :
//*****************************************************************************

`timescale 1ps/1ps

module memc_tb_top #(

   parameter C_SIMULATION                  = "FALSE",   
   parameter C_NUM_DQ_PINS                 = 4,
   parameter C_MEM_BURST_LEN               = 8,	       
   parameter C_MEM_NUM_COL_BITS            = 11,
   parameter C_SMALL_DEVICE                = "FALSE",         

   parameter C_PORT_ENABLE                 = 6'b111111,	       
   parameter C_P0_MASK_SIZE                = 4,
   parameter C_P0_DATA_PORT_SIZE           = 32,
   parameter C_P1_MASK_SIZE                = 4,
   parameter C_P1_DATA_PORT_SIZE           = 32,
   parameter C_P0_PORT_MODE                = "BI_MODE",           
   parameter C_P1_PORT_MODE                = "BI_MODE",
   parameter C_P2_PORT_MODE                = "RD_MODE",           
   parameter C_P3_PORT_MODE                = "RD_MODE",           
   parameter C_P4_PORT_MODE                = "RD_MODE",           
   parameter C_P5_PORT_MODE                = "RD_MODE",

   parameter C_p0_BEGIN_ADDRESS            = 32'h00000100,
   parameter C_p0_DATA_MODE                = 4'b0010,
   parameter C_p0_END_ADDRESS              = 32'h000002ff,
   parameter C_p0_PRBS_EADDR_MASK_POS      = 32'hfffffc00,
   parameter C_p0_PRBS_SADDR_MASK_POS      = 32'h00000100,
   parameter C_p1_BEGIN_ADDRESS            = 32'h00000300,
   parameter C_p1_DATA_MODE                = 4'b0010,
   parameter C_p1_END_ADDRESS              = 32'h000004ff,
   parameter C_p1_PRBS_EADDR_MASK_POS      = 32'hfffff800,
   parameter C_p1_PRBS_SADDR_MASK_POS      = 32'h00000300,
   parameter C_p2_BEGIN_ADDRESS            = 32'h00000100,
   parameter C_p2_DATA_MODE                = 4'b0010,
   parameter C_p2_END_ADDRESS              = 32'h000002ff,
   parameter C_p2_PRBS_EADDR_MASK_POS      = 32'hfffffc00,
   parameter C_p2_PRBS_SADDR_MASK_POS      = 32'h00000100,
   parameter C_p3_BEGIN_ADDRESS            = 32'h00000100,
   parameter C_p3_DATA_MODE                = 4'b0010,
   parameter C_p3_END_ADDRESS              = 32'h000002ff,
   parameter C_p3_PRBS_EADDR_MASK_POS      = 32'hfffffc00,
   parameter C_p3_PRBS_SADDR_MASK_POS      = 32'h00000100,
   parameter C_p4_BEGIN_ADDRESS            = 32'h00000100,
   parameter C_p4_DATA_MODE                = 4'b0010,
   parameter C_p4_END_ADDRESS              = 32'h000002ff,
   parameter C_p4_PRBS_EADDR_MASK_POS      = 32'hfffffc00,
   parameter C_p4_PRBS_SADDR_MASK_POS      = 32'h00000100,
   parameter C_p5_BEGIN_ADDRESS            = 32'h00000100,
   parameter C_p5_DATA_MODE                = 4'b0010,
   parameter C_p5_END_ADDRESS              = 32'h000002ff,
   parameter C_p5_PRBS_EADDR_MASK_POS      = 32'hfffffc00,
   parameter C_p5_PRBS_SADDR_MASK_POS      = 32'h00000100
  )
  (
   input                    clk0, 
   input                    rst0, 
   input                    calib_done, 

/////////////////////////////////////////////////////////////////////////////
//  MCB INTERFACE
/////////////////////////////////////////////////////////////////////////////
// The following port declarations depicts that all the memory controller ports
// are connected to the test bench top. However, a traffic generator can be 
// connected to the corresponding port only if the port is enabled, whose 
// information can be obtained from the parameter C_PORT_ENABLE. The following
// list describes the active ports in each port configuration.
//
// Config 1: "B32_B32_X32_X32_X32_X32"
//            User port 0  --> 32 bit,  User port 1  --> 32 bit 
//            User port 2  --> 32 bit,  User port 3  --> 32 bit
//            User port 4  --> 32 bit,  User port 5  --> 32 bit
// Config 2: "B32_B32_B32_B32"  
//            User port 0  --> 32 bit 
//            User port 1  --> 32 bit 
//            User port 2  --> 32 bit 
//            User port 3  --> 32 bit 
// Config 3: "B64_B32_B3"  
//            User port 0  --> 64 bit 
//            User port 1  --> 32 bit 
//            User port 2  --> 32 bit 
// Config 4: "B64_B64"          
//            User port 0  --> 64 bit 
//            User port 1  --> 64 bit
// Config 5  "B128"          
//            User port 0  --> 128 bit


   // User Port-0 command interface will be active only when the port is enabled in 
   // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
   output		p0_mcb_cmd_en,
   output [2:0]	        p0_mcb_cmd_instr,
   output [5:0]	        p0_mcb_cmd_bl,
   output [29:0]	p0_mcb_cmd_addr,
   input		p0_mcb_cmd_full,

   // User Port-0 data write interface will be active only when the port is enabled in
   // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
   output		p0_mcb_wr_en,
   output [C_P0_MASK_SIZE - 1:0]	p0_mcb_wr_mask,
   output [C_P0_DATA_PORT_SIZE - 1:0]	p0_mcb_wr_data,
   input		p0_mcb_wr_full,
   input [6:0]	        p0_mcb_wr_fifo_counts,

   // User Port-0 data read interface will be active only when the port is enabled in
   // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
   output		p0_mcb_rd_en,
   input [C_P0_DATA_PORT_SIZE - 1:0]	p0_mcb_rd_data,
   input		p0_mcb_rd_empty,
   input [6:0]	        p0_mcb_rd_fifo_counts,

   // User Port-1 command interface will be active only when the port is enabled in 
   // the port configurations Config-1, Config-2, Config-3 and Config-4
   output		p1_mcb_cmd_en,
   output [2:0]	        p1_mcb_cmd_instr,
   output [5:0]	        p1_mcb_cmd_bl,
   output [29:0]	p1_mcb_cmd_addr,
   input		p1_mcb_cmd_full,

   // User Port-1 data write interface will be active only when the port is enabled in 
   // the port configurations Config-1, Config-2, Config-3 and Config-4
   output		p1_mcb_wr_en,
   output [C_P1_MASK_SIZE - 1:0]	p1_mcb_wr_mask,
   output [C_P1_DATA_PORT_SIZE - 1:0]	p1_mcb_wr_data,
   input		p1_mcb_wr_full,
   input [6:0]	        p1_mcb_wr_fifo_counts,

   // User Port-1 data read interface will be active only when the port is enabled in 
   // the port configurations Config-1, Config-2, Config-3 and Config-4
   output		p1_mcb_rd_en,
   input [C_P1_DATA_PORT_SIZE - 1:0]	p1_mcb_rd_data,
   input		p1_mcb_rd_empty,
   input [6:0]	        p1_mcb_rd_fifo_counts,

   // User Port-2 command interface will be active only when the port is enabled in 
   // the port configurations Config-1, Config-2 and Config-3
   output		p2_mcb_cmd_en,
   output [2:0]	        p2_mcb_cmd_instr,
   output [5:0]	        p2_mcb_cmd_bl,
   output [29:0]	p2_mcb_cmd_addr,
   input		p2_mcb_cmd_full,

   // User Port-2 data write interface will be active only when the port is enabled in 
   // the port configurations Config-1 write direction, Config-2 and Config-3
   output		p2_mcb_wr_en,
   output [3:0]	        p2_mcb_wr_mask,
   output [31:0]	p2_mcb_wr_data,
   input		p2_mcb_wr_full,
   input [6:0]	        p2_mcb_wr_fifo_counts,

   // User Port-2 data read interface will be active only when the port is enabled in 
   // the port configurations Config-1 read direction, Config-2 and Config-3
   output		p2_mcb_rd_en,
   input [31:0]	        p2_mcb_rd_data,
   input		p2_mcb_rd_empty,
   input [6:0]	        p2_mcb_rd_fifo_counts,

   // User Port-3 command interface will be active only when the port is enabled in 
   // the port configurations Config-1 and Config-2
   output		p3_mcb_cmd_en,
   output [2:0]	        p3_mcb_cmd_instr,
   output [5:0]	        p3_mcb_cmd_bl,
   output [29:0]	p3_mcb_cmd_addr,
   input		p3_mcb_cmd_full,

   // User Port-3 data write interface will be active only when the port is enabled in 
   // the port configurations Config-1 write direction and Config-2
   output		p3_mcb_wr_en,
   output [3:0]	        p3_mcb_wr_mask,
   output [31:0]	p3_mcb_wr_data,
   input		p3_mcb_wr_full,
   input [6:0]	        p3_mcb_wr_fifo_counts,

   // User Port-3 data read interface will be active only when the port is enabled in 
   // the port configurations Config-1 read direction and Config-2
   output		p3_mcb_rd_en,
   input [31:0]	        p3_mcb_rd_data,
   input		p3_mcb_rd_empty,
   input [6:0]	        p3_mcb_rd_fifo_counts,

   // User Port-4 command interface will be active only when the port is enabled in 
   // the port configuration Config-1
   output		p4_mcb_cmd_en,
   output [2:0]	        p4_mcb_cmd_instr,
   output [5:0]	        p4_mcb_cmd_bl,
   output [29:0]	p4_mcb_cmd_addr,
   input		p4_mcb_cmd_full,

   // User Port-4 data write interface will be active only when the port is enabled in 
   // the port configuration Config-1 write direction
   output		p4_mcb_wr_en,
   output [3:0]	        p4_mcb_wr_mask,
   output [31:0]	p4_mcb_wr_data,
   input		p4_mcb_wr_full,
   input [6:0]	        p4_mcb_wr_fifo_counts,

   // User Port-4 data read interface will be active only when the port is enabled in 
   // the port configuration Config-1 read direction
   output		p4_mcb_rd_en,
   input [31:0]	        p4_mcb_rd_data,
   input		p4_mcb_rd_empty,
   input [6:0]	        p4_mcb_rd_fifo_counts,

   // User Port-5 command interface will be active only when the port is enabled in 
   // the port configuration Config-1
   output		p5_mcb_cmd_en,
   output [2:0]	        p5_mcb_cmd_instr,
   output [5:0]	        p5_mcb_cmd_bl,
   output [29:0]	p5_mcb_cmd_addr,
   input		p5_mcb_cmd_full,

   // User Port-5 data write interface will be active only when the port is enabled in 
   // the port configuration Config-1 write direction
   output		p5_mcb_wr_en,
   output [3:0]	        p5_mcb_wr_mask,
   output [31:0]	p5_mcb_wr_data,
   input		p5_mcb_wr_full,
   input [6:0]	        p5_mcb_wr_fifo_counts,

   // User Port-5 data read interface will be active only when the port is enabled in 
   // the port configuration Config-1 read direction
   output		p5_mcb_rd_en,
   input [31:0]	        p5_mcb_rd_data,
   input		p5_mcb_rd_empty,
   input [6:0]	        p5_mcb_rd_fifo_counts,

   // Signal declarations that can be connected to vio module 
   input                vio_modify_enable,
   input [2:0]          vio_data_mode_value,
   input [2:0]          vio_addr_mode_value,

   // status feedback
   output [31:0]        cmp_data,
   output               cmp_data_valid,
   output               cmp_error,
   output               error,       // asserted whenever the read back data is not correct.
   output [64 + (2*C_P0_DATA_PORT_SIZE - 1):0]     p0_error_status,
   output [64 + (2*C_P1_DATA_PORT_SIZE - 1):0]     p1_error_status,
   output [127 : 0]     p2_error_status,
   output [127 : 0]     p3_error_status,
   output [127 : 0]     p4_error_status,
   output [127 : 0]     p5_error_status
  );

  
   localparam P2_DWIDTH            = 32;           
   localparam P3_DWIDTH            = 32;           
   localparam P4_DWIDTH            = 32;           
   localparam P5_DWIDTH            = 32;             
   localparam FAMILY               = "SPARTAN6";  
   localparam CMP_DATA_PIPE_STAGES = 0;            
   localparam DQ_ERROR_WIDTH       = (C_NUM_DQ_PINS==4)? 1 : (C_NUM_DQ_PINS/8);
   localparam TG_DATA_PATTERN      = (C_SMALL_DEVICE == "FALSE") ? "DGEN_ALL" : "DGEN_ADDR";

   localparam P2_PRBS_SADDR_MASK_POS = (C_P2_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_PRBS_SADDR_MASK_POS : 
                                                                     C_PORT_ENABLE[1] ? C_p1_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_PRBS_SADDR_MASK_POS : 
			  					     C_p2_PRBS_SADDR_MASK_POS
								   : C_p2_PRBS_SADDR_MASK_POS;
   localparam P2_PRBS_EADDR_MASK_POS = (C_P2_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_PRBS_EADDR_MASK_POS : 
                                                                     C_PORT_ENABLE[1] ? C_p1_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_PRBS_EADDR_MASK_POS : 
			  					     C_p2_PRBS_EADDR_MASK_POS
								   : C_p2_PRBS_EADDR_MASK_POS;
   localparam P2_BEGIN_ADDRESS       = (C_P2_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_BEGIN_ADDRESS: 
                                                                     C_PORT_ENABLE[1] ? C_p1_BEGIN_ADDRESS: 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_BEGIN_ADDRESS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_BEGIN_ADDRESS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_BEGIN_ADDRESS : 
			  					     C_p2_BEGIN_ADDRESS 
								   : C_p2_BEGIN_ADDRESS;
   localparam P2_END_ADDRESS         = (C_P2_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_END_ADDRESS: 
                                                                     C_PORT_ENABLE[1] ? C_p1_END_ADDRESS: 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_END_ADDRESS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_END_ADDRESS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_END_ADDRESS : 
			  					     C_p2_END_ADDRESS 
								   : C_p2_END_ADDRESS;
   localparam P2_DATA_MODE           = (C_P2_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_DATA_MODE: 
                                                                     C_PORT_ENABLE[1] ? C_p1_DATA_MODE: 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_DATA_MODE : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_DATA_MODE : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_DATA_MODE : 
			  					     C_p2_DATA_MODE 
								   : C_p2_DATA_MODE;


   localparam P3_PRBS_SADDR_MASK_POS = (C_P3_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_PRBS_SADDR_MASK_POS : 
                                                                     C_PORT_ENABLE[1] ? C_p1_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_PRBS_SADDR_MASK_POS : 
			  					     C_p3_PRBS_SADDR_MASK_POS
								   : C_p3_PRBS_SADDR_MASK_POS;
   localparam P3_PRBS_EADDR_MASK_POS = (C_P3_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_PRBS_EADDR_MASK_POS : 
                                                                     C_PORT_ENABLE[1] ? C_p1_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_PRBS_EADDR_MASK_POS : 
			  					     C_p3_PRBS_EADDR_MASK_POS
								   : C_p3_PRBS_EADDR_MASK_POS;
   localparam P3_BEGIN_ADDRESS       = (C_P3_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_BEGIN_ADDRESS: 
                                                                     C_PORT_ENABLE[1] ? C_p1_BEGIN_ADDRESS: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_BEGIN_ADDRESS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_BEGIN_ADDRESS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_BEGIN_ADDRESS : 
			  					     C_p3_BEGIN_ADDRESS 
								   : C_p3_BEGIN_ADDRESS;
   localparam P3_END_ADDRESS         = (C_P3_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_END_ADDRESS: 
                                                                     C_PORT_ENABLE[1] ? C_p1_END_ADDRESS: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_END_ADDRESS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_END_ADDRESS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_END_ADDRESS : 
			  					     C_p3_END_ADDRESS 
								   : C_p3_END_ADDRESS;
   localparam P3_DATA_MODE           = (C_P3_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_DATA_MODE: 
                                                                     C_PORT_ENABLE[1] ? C_p1_DATA_MODE: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_DATA_MODE : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_DATA_MODE : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_DATA_MODE : 
			  					     C_p3_DATA_MODE 
								   : C_p3_DATA_MODE;


   localparam P4_PRBS_SADDR_MASK_POS = (C_P4_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_PRBS_SADDR_MASK_POS : 
                                                                     C_PORT_ENABLE[1] ? C_p1_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_PRBS_SADDR_MASK_POS : 
			  					     C_p4_PRBS_SADDR_MASK_POS
								   : C_p4_PRBS_SADDR_MASK_POS;
   localparam P4_PRBS_EADDR_MASK_POS = (C_P4_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_PRBS_EADDR_MASK_POS : 
                                                                     C_PORT_ENABLE[1] ? C_p1_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_PRBS_EADDR_MASK_POS : 
			  					     C_p4_PRBS_EADDR_MASK_POS
								   : C_p4_PRBS_EADDR_MASK_POS;
   localparam P4_BEGIN_ADDRESS       = (C_P4_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_BEGIN_ADDRESS: 
                                                                     C_PORT_ENABLE[1] ? C_p1_BEGIN_ADDRESS: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_BEGIN_ADDRESS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_BEGIN_ADDRESS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_BEGIN_ADDRESS : 
			  					     C_p4_BEGIN_ADDRESS 
								   : C_p4_BEGIN_ADDRESS;
   localparam P4_END_ADDRESS         = (C_P4_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_END_ADDRESS: 
                                                                     C_PORT_ENABLE[1] ? C_p1_END_ADDRESS: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_END_ADDRESS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_END_ADDRESS : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_END_ADDRESS : 
			  					     C_p4_END_ADDRESS 
								   : C_p4_END_ADDRESS;
   localparam P4_DATA_MODE           = (C_P4_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_DATA_MODE: 
                                                                     C_PORT_ENABLE[1] ? C_p1_DATA_MODE: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_DATA_MODE : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_DATA_MODE : 
                                                                     (C_PORT_ENABLE[5] && (C_P5_PORT_MODE == "WR_MODE")) ? C_p5_DATA_MODE : 
			  					     C_p4_DATA_MODE 
								   : C_p4_DATA_MODE;


   localparam P5_PRBS_SADDR_MASK_POS = (C_P5_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_PRBS_SADDR_MASK_POS : 
                                                                     C_PORT_ENABLE[1] ? C_p1_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_PRBS_SADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_PRBS_SADDR_MASK_POS : 
			  					     C_p5_PRBS_SADDR_MASK_POS
								   : C_p5_PRBS_SADDR_MASK_POS;
   localparam P5_PRBS_EADDR_MASK_POS = (C_P5_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_PRBS_EADDR_MASK_POS : 
                                                                     C_PORT_ENABLE[1] ? C_p1_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_PRBS_EADDR_MASK_POS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_PRBS_EADDR_MASK_POS : 
			  					     C_p5_PRBS_EADDR_MASK_POS
								   : C_p5_PRBS_EADDR_MASK_POS;
   localparam P5_BEGIN_ADDRESS       = (C_P5_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_BEGIN_ADDRESS: 
                                                                     C_PORT_ENABLE[1] ? C_p1_BEGIN_ADDRESS: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_BEGIN_ADDRESS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_BEGIN_ADDRESS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_BEGIN_ADDRESS : 
			  					     C_p5_BEGIN_ADDRESS 
								   : C_p5_BEGIN_ADDRESS;
   localparam P5_END_ADDRESS         = (C_P5_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_END_ADDRESS: 
                                                                     C_PORT_ENABLE[1] ? C_p1_END_ADDRESS: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_END_ADDRESS : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_END_ADDRESS : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_END_ADDRESS : 
			  					     C_p5_END_ADDRESS 
								   : C_p5_END_ADDRESS;
   localparam P5_DATA_MODE           = (C_P5_PORT_MODE == "RD_MODE") ? C_PORT_ENABLE[0] ? C_p0_DATA_MODE: 
                                                                     C_PORT_ENABLE[1] ? C_p1_DATA_MODE: 
                                                                     (C_PORT_ENABLE[2] && (C_P2_PORT_MODE == "WR_MODE")) ? C_p2_DATA_MODE : 
                                                                     (C_PORT_ENABLE[3] && (C_P3_PORT_MODE == "WR_MODE")) ? C_p3_DATA_MODE : 
                                                                     (C_PORT_ENABLE[4] && (C_P4_PORT_MODE == "WR_MODE")) ? C_p4_DATA_MODE : 
			  					     C_p5_DATA_MODE 
								   : C_p5_DATA_MODE;


//p0 wire declarations
   wire            p0_tg_run_traffic; 
   wire [31:0]     p0_tg_start_addr;
   wire [31:0]     p0_tg_end_addr;
   wire [31:0]     p0_tg_cmd_seed; 
   wire [31:0]     p0_tg_data_seed;
   wire            p0_tg_load_seed;
   wire [2:0]      p0_tg_addr_mode;
   wire [3:0]      p0_tg_instr_mode;
   wire [1:0]      p0_tg_bl_mode;
   wire [3:0]      p0_tg_data_mode;
   wire            p0_tg_mode_load;
   wire [5:0]      p0_tg_fixed_bl;
   wire [2:0]      p0_tg_fixed_instr;
   wire [31:0]     p0_tg_fixed_addr;
   wire            p0_error;
   wire            p0_cmp_error;
   wire [C_P0_DATA_PORT_SIZE-1 :0] p0_cmp_data;
   wire           p0_cmp_data_valid;
          
//p1 wire declarations
   wire            p1_tg_run_traffic; 
   wire [31:0]     p1_tg_start_addr;
   wire [31:0]     p1_tg_end_addr;
   wire [31:0]     p1_tg_cmd_seed; 
   wire [31:0]     p1_tg_data_seed;
   wire            p1_tg_load_seed;
   wire [2:0]      p1_tg_addr_mode;
   wire [3:0]      p1_tg_instr_mode;
   wire [1:0]      p1_tg_bl_mode;
   wire [3:0]      p1_tg_data_mode;
   wire            p1_tg_mode_load;
   wire [5:0]      p1_tg_fixed_bl;
   wire [2:0]      p1_tg_fixed_instr;
   wire [31:0]     p1_tg_fixed_addr;
   wire            p1_error;
   wire            p1_cmp_error;
   wire [C_P1_DATA_PORT_SIZE-1 :0] p1_cmp_data;
   wire           p1_cmp_data_valid;
          
//p2 wire declarations
   wire            p2_tg_run_traffic; 
   wire [31:0]     p2_tg_start_addr;
   wire [31:0]     p2_tg_end_addr;
   wire [31:0]     p2_tg_cmd_seed; 
   wire [31:0]     p2_tg_data_seed;
   wire            p2_tg_load_seed;
   wire [2:0]      p2_tg_addr_mode;
   wire [3:0]      p2_tg_instr_mode;
   wire [1:0]      p2_tg_bl_mode;
   wire [3:0]      p2_tg_data_mode;
   wire            p2_tg_mode_load;
   wire [5:0]      p2_tg_fixed_bl;
   wire [2:0]      p2_tg_fixed_instr;
   wire [31:0]     p2_tg_fixed_addr;
   wire            p2_error;
   wire            p2_cmp_error;
   wire [P2_DWIDTH-1 :0] p2_cmp_data;
   wire           p2_cmp_data_valid;
          
//p3 wire declarations
   wire            p3_tg_run_traffic; 
   wire [31:0]     p3_tg_start_addr;
   wire [31:0]     p3_tg_end_addr;
   wire [31:0]     p3_tg_cmd_seed; 
   wire [31:0]     p3_tg_data_seed;
   wire            p3_tg_load_seed;
   wire [2:0]      p3_tg_addr_mode;
   wire [3:0]      p3_tg_instr_mode;
   wire [1:0]      p3_tg_bl_mode;
   wire [3:0]      p3_tg_data_mode;
   wire            p3_tg_mode_load;
   wire [5:0]      p3_tg_fixed_bl;
   wire [2:0]      p3_tg_fixed_instr;
   wire [31:0]     p3_tg_fixed_addr;
   wire            p3_error;
   wire            p3_cmp_error;
   wire [P3_DWIDTH-1 :0] p3_cmp_data;
   wire           p3_cmp_data_valid;
          
//p4 wire declarations
   wire            p4_tg_run_traffic; 
   wire [31:0]     p4_tg_start_addr;
   wire [31:0]     p4_tg_end_addr;
   wire [31:0]     p4_tg_cmd_seed; 
   wire [31:0]     p4_tg_data_seed;
   wire            p4_tg_load_seed;
   wire [2:0]      p4_tg_addr_mode;
   wire [3:0]      p4_tg_instr_mode;
   wire [1:0]      p4_tg_bl_mode;
   wire [3:0]      p4_tg_data_mode;
   wire            p4_tg_mode_load;
   wire [5:0]      p4_tg_fixed_bl;
   wire [2:0]      p4_tg_fixed_instr;
   wire [31:0]     p4_tg_fixed_addr;
   wire            p4_error;
   wire            p4_cmp_error;
   wire [P4_DWIDTH-1 :0] p4_cmp_data;
   wire           p4_cmp_data_valid;
          
//p5 wire declarations
   wire            p5_tg_run_traffic; 
   wire [31:0]     p5_tg_start_addr;
   wire [31:0]     p5_tg_end_addr;
   wire [31:0]     p5_tg_cmd_seed; 
   wire [31:0]     p5_tg_data_seed;
   wire            p5_tg_load_seed;
   wire [2:0]      p5_tg_addr_mode;
   wire [3:0]      p5_tg_instr_mode;
   wire [1:0]      p5_tg_bl_mode;
   wire [3:0]      p5_tg_data_mode;
   wire            p5_tg_mode_load;
   wire [5:0]      p5_tg_fixed_bl;
   wire [2:0]      p5_tg_fixed_instr;
   wire [31:0]     p5_tg_fixed_addr;
   wire            p5_error;
   wire            p5_cmp_error;
   wire [P5_DWIDTH-1 :0] p5_cmp_data;
   wire           p5_cmp_data_valid;
  
   wire 	  p2_mcb_cmd_en_sig; 
   wire [2:0] 	  p2_mcb_cmd_instr_sig;
   wire [5:0] 	  p2_mcb_cmd_bl_sig;
   wire [29:0]	  p2_mcb_cmd_addr_sig;
   wire 	  p2_mcb_wr_en_sig;
   wire 	  p3_mcb_cmd_en_sig; 
   wire [2:0] 	  p3_mcb_cmd_instr_sig;
   wire [5:0] 	  p3_mcb_cmd_bl_sig;
   wire [29:0]	  p3_mcb_cmd_addr_sig;
   wire 	  p3_mcb_wr_en_sig;
   wire 	  p4_mcb_cmd_en_sig; 
   wire [2:0] 	  p4_mcb_cmd_instr_sig;
   wire [5:0] 	  p4_mcb_cmd_bl_sig;
   wire [29:0]	  p4_mcb_cmd_addr_sig;
   wire 	  p4_mcb_wr_en_sig;
   wire 	  p5_mcb_cmd_en_sig; 
   wire [2:0] 	  p5_mcb_cmd_instr_sig;
   wire [5:0] 	  p5_mcb_cmd_bl_sig;
   wire [29:0]	  p5_mcb_cmd_addr_sig;
   wire 	  p5_mcb_wr_en_sig;


   assign cmp_error      = p0_cmp_error | p1_cmp_error | p2_cmp_error | p3_cmp_error | p4_cmp_error | p5_cmp_error;
   assign error          = p0_error | p1_error | p2_error | p3_error | p4_error | p5_error;


// The following 'generate' statement captures data for cmp_data and cmp_data_valid
// ports from the corresponding signals of the first enabled traffic generator. 
generate
   if (C_PORT_ENABLE[0] == 1) begin: port0_status 
      assign cmp_data       = p0_cmp_data[31:0];
      assign cmp_data_valid = p0_cmp_data_valid;
   end
   else if (C_PORT_ENABLE[1] == 1) begin: port1_status   
      assign cmp_data       = p1_cmp_data[31:0];
      assign cmp_data_valid = p1_cmp_data_valid;
   end
   else if (C_PORT_ENABLE[2] == 1) begin: port2_status   
      assign cmp_data       = p2_cmp_data[31:0];
      assign cmp_data_valid = p2_cmp_data_valid;
   end
   else if (C_PORT_ENABLE[3] == 1) begin: port3_status   
      assign cmp_data       = p3_cmp_data[31:0];
      assign cmp_data_valid = p3_cmp_data_valid;
   end
   else if (C_PORT_ENABLE[4] == 1) begin: port4_status   
      assign cmp_data       = p4_cmp_data[31:0];
      assign cmp_data_valid = p4_cmp_data_valid;
   end
   else if (C_PORT_ENABLE[5] == 1) begin: port5_status   
      assign cmp_data       = p5_cmp_data[31:0];
      assign cmp_data_valid = p5_cmp_data_valid;
   end
endgenerate   


// The following 'generate' statement activates the traffic generator for
// Port-0 if it is enabled
generate
   if (C_PORT_ENABLE[0] == 1'b1)
   begin : PORT0_TG    
   // init_mem_pattern_ctr module instantiation for Port-0
   init_mem_pattern_ctr #
     (
      .DWIDTH                        (C_P0_DATA_PORT_SIZE), 
      .FAMILY                        (FAMILY),
      .BEGIN_ADDRESS                 (C_p0_BEGIN_ADDRESS),
      .END_ADDRESS                   (C_p0_END_ADDRESS),
      .CMD_SEED_VALUE                (32'h56456783),
      .DATA_SEED_VALUE               (32'h12345678),  
      .DATA_MODE                     (C_p0_DATA_MODE), 
      .PORT_MODE                     (C_P0_PORT_MODE) 
    )
   init_mem_pattern_ctr_p0
     (
      .clk_i                         (clk0),   
      .rst_i                         (rst0),     
   
      .mcb_cmd_en_i                  (p0_mcb_cmd_en),   
      .mcb_cmd_instr_i               (p0_mcb_cmd_instr),
      .mcb_cmd_addr_i                (p0_mcb_cmd_addr), 
      .mcb_cmd_bl_i                  (p0_mcb_cmd_bl),  
      .mcb_wr_en_i                   (p0_mcb_wr_en), 
   
      .vio_modify_enable	     (vio_modify_enable),   
      .vio_data_mode_value           (vio_data_mode_value),  
      .vio_addr_mode_value           (vio_addr_mode_value),
      .vio_bl_mode_value             (2'b10),  // always set to PRBS_BL mode
      .vio_fixed_bl_value            (6'd64),  // always set to 64 in order to run PRBS data pattern
      .mcb_init_done_i               (calib_done),
      .cmp_error                     (p0_error),
      .run_traffic_o                 (p0_tg_run_traffic),  
      .start_addr_o                  (p0_tg_start_addr),
      .end_addr_o                    (p0_tg_end_addr), 
      .cmd_seed_o                    (p0_tg_cmd_seed),  
      .data_seed_o                   (p0_tg_data_seed), 
      .load_seed_o                   (p0_tg_load_seed), 
      .addr_mode_o                   (p0_tg_addr_mode), 
      .instr_mode_o                  (p0_tg_instr_mode), 
      .bl_mode_o                     (p0_tg_bl_mode), 
      .data_mode_o                   (p0_tg_data_mode), 
      .mode_load_o                   (p0_tg_mode_load), 
      .fixed_bl_o                    (p0_tg_fixed_bl), 
      .fixed_instr_o                 (p0_tg_fixed_instr), 
      .fixed_addr_o                  (p0_tg_fixed_addr) 
     );
   
   // traffic generator instantiation for Port-0
   mcb_traffic_gen #
     (  
      .MEM_BURST_LEN                 (C_MEM_BURST_LEN),  
      .MEM_COL_WIDTH                 (C_MEM_NUM_COL_BITS),  
      .NUM_DQ_PINS                   (C_NUM_DQ_PINS), 
      .DQ_ERROR_WIDTH                (DQ_ERROR_WIDTH),  
      .PORT_MODE                     (C_P0_PORT_MODE),     
      .DWIDTH                        (C_P0_DATA_PORT_SIZE),
      .CMP_DATA_PIPE_STAGES          (CMP_DATA_PIPE_STAGES),   
      .FAMILY                        (FAMILY),    
      .SIMULATION                    ("FALSE"),   
      .DATA_PATTERN                  (TG_DATA_PATTERN),  
      .CMD_PATTERN                   ("CGEN_ALL"),  
      .ADDR_WIDTH                    (30),  
      .PRBS_SADDR_MASK_POS           (C_p0_PRBS_SADDR_MASK_POS), 
      .PRBS_EADDR_MASK_POS           (C_p0_PRBS_EADDR_MASK_POS),
      .PRBS_SADDR                    (C_p0_BEGIN_ADDRESS), 
      .PRBS_EADDR                    (C_p0_END_ADDRESS)
     )  
   m_traffic_gen_p0 
     (  
      .clk_i                         (clk0),     
      .rst_i                         (rst0),     
      .run_traffic_i                 (p0_tg_run_traffic),                  
      .manual_clear_error            (rst0),     
      // runtime parameter  
      .start_addr_i                  (p0_tg_start_addr),                  
      .end_addr_i                    (p0_tg_end_addr),                  
      .cmd_seed_i                    (p0_tg_cmd_seed),                  
      .data_seed_i                   (p0_tg_data_seed),                  
      .load_seed_i                   (p0_tg_load_seed),                
      .addr_mode_i                   (p0_tg_addr_mode),                
      .instr_mode_i                  (p0_tg_instr_mode),                  
      .bl_mode_i                     (p0_tg_bl_mode),                  
      .data_mode_i                   (p0_tg_data_mode),                  
      .mode_load_i                   (p0_tg_mode_load),                  
      // fixed pattern inputs interface  
      .fixed_bl_i                    (p0_tg_fixed_bl),                     
      .fixed_instr_i                 (p0_tg_fixed_instr),                     
      .fixed_addr_i                  (p0_tg_fixed_addr),                 
      .fixed_data_i                  (), 
      // BRAM interface. 
      .bram_cmd_i                    (), 
      .bram_valid_i                  (), 
      .bram_rdy_o                    (),  
      
      //  MCB INTERFACE  
      .mcb_cmd_en_o		     (p0_mcb_cmd_en),                 
      .mcb_cmd_instr_o		     (p0_mcb_cmd_instr),                    
      .mcb_cmd_bl_o		     (p0_mcb_cmd_bl),                 
      .mcb_cmd_addr_o		     (p0_mcb_cmd_addr),                   
      .mcb_cmd_full_i		     (p0_mcb_cmd_full),                   
   
      .mcb_wr_en_o		     (p0_mcb_wr_en),                
      .mcb_wr_mask_o		     (p0_mcb_wr_mask),                  
      .mcb_wr_data_o		     (p0_mcb_wr_data),                 
      .mcb_wr_data_end_o             (), 
      .mcb_wr_full_i		     (p0_mcb_wr_full),                  
      .mcb_wr_fifo_counts	     (p0_mcb_wr_fifo_counts),                       
   
      .mcb_rd_en_o		     (p0_mcb_rd_en),                
      .mcb_rd_data_i		     (p0_mcb_rd_data),                  
      .mcb_rd_empty_i		     (p0_mcb_rd_empty),                   
      .mcb_rd_fifo_counts	     (p0_mcb_rd_fifo_counts),                       
   
      // status feedback  
      .counts_rst                    (rst0),     
      .wr_data_counts                (), 
      .rd_data_counts                (), 
      .error                         (p0_error),  // asserted whenever the read back data is not correct.  
      .error_status                  (p0_error_status),  // TBD how signals mapped  
      .cmp_data                      (p0_cmp_data),            
      .cmp_data_valid                (p0_cmp_data_valid),                  
      .cmp_error                     (p0_cmp_error),             
      .mem_rd_data                   (), 
      .dq_error_bytelane_cmp         (), 
      .cumlative_dq_lane_error       ()
     );
   end     
   else begin: PORT0_NO_TG
      assign p0_error          = 'b0;
      assign p0_error_status   = 'b0;
      assign p0_cmp_data       = 'b0;
      assign p0_cmp_data_valid = 'b0;
      assign p0_cmp_error      = 'b0;
   end   
endgenerate


// The following 'generate' statement activates the traffic generator for
// Port-1 if it is enabled
generate
   if (C_PORT_ENABLE[1] == 1'b1) 
   begin : PORT1_TG    
   // init_mem_pattern_ctr module instantiation for Port-1
   init_mem_pattern_ctr #
     (
      .DWIDTH                        (C_P1_DATA_PORT_SIZE), 
      .FAMILY                        (FAMILY),
      .BEGIN_ADDRESS                 (C_p1_BEGIN_ADDRESS),
      .END_ADDRESS                   (C_p1_END_ADDRESS),
      .CMD_SEED_VALUE                (32'h56456783),
      .DATA_SEED_VALUE               (32'h12345678),  
      .DATA_MODE                     (C_p1_DATA_MODE), 
      .PORT_MODE                     (C_P1_PORT_MODE) 
     )
   init_mem_pattern_ctr_p1
     (
      .clk_i                         (clk0),   
      .rst_i                         (rst0),     
   
      .mcb_cmd_en_i                  (p1_mcb_cmd_en),   
      .mcb_cmd_instr_i               (p1_mcb_cmd_instr),
      .mcb_cmd_addr_i                (p1_mcb_cmd_addr), 
      .mcb_cmd_bl_i                  (p1_mcb_cmd_bl),  
      .mcb_wr_en_i                   (p1_mcb_wr_en), 
   
      .vio_modify_enable	     (vio_modify_enable),   
      .vio_data_mode_value           (vio_data_mode_value),  
      .vio_addr_mode_value           (vio_addr_mode_value),
      .vio_bl_mode_value             (2'b10),
      .vio_fixed_bl_value            (6'd64),
      .mcb_init_done_i               (calib_done),
      .cmp_error                     (p1_error),
      .run_traffic_o                 (p1_tg_run_traffic),  
      .start_addr_o                  (p1_tg_start_addr),
      .end_addr_o                    (p1_tg_end_addr), 
      .cmd_seed_o                    (p1_tg_cmd_seed),  
      .data_seed_o                   (p1_tg_data_seed), 
      .load_seed_o                   (p1_tg_load_seed), 
      .addr_mode_o                   (p1_tg_addr_mode), 
      .instr_mode_o                  (p1_tg_instr_mode), 
      .bl_mode_o                     (p1_tg_bl_mode), 
      .data_mode_o                   (p1_tg_data_mode), 
      .mode_load_o                   (p1_tg_mode_load), 
      .fixed_bl_o                    (p1_tg_fixed_bl), 
      .fixed_instr_o                 (p1_tg_fixed_instr), 
      .fixed_addr_o                  (p1_tg_fixed_addr) 
     );
   
   // traffic generator instantiation for Port-1
   mcb_traffic_gen #
     (  
      .MEM_BURST_LEN                 (C_MEM_BURST_LEN),  
      .MEM_COL_WIDTH                 (C_MEM_NUM_COL_BITS),  
      .NUM_DQ_PINS                   (C_NUM_DQ_PINS), 
      .DQ_ERROR_WIDTH                (DQ_ERROR_WIDTH),  
      .PORT_MODE                     (C_P1_PORT_MODE),     
      .DWIDTH                        (C_P1_DATA_PORT_SIZE),   
      .CMP_DATA_PIPE_STAGES          (CMP_DATA_PIPE_STAGES),   
      .FAMILY                        (FAMILY),    
      .SIMULATION                    ("FALSE"),   
      .DATA_PATTERN                  (TG_DATA_PATTERN),  
      .CMD_PATTERN                   ("CGEN_ALL"),  
      .ADDR_WIDTH                    (30),  
      .PRBS_SADDR_MASK_POS           (C_p1_PRBS_SADDR_MASK_POS), 
      .PRBS_EADDR_MASK_POS           (C_p1_PRBS_EADDR_MASK_POS),
      .PRBS_SADDR                    (C_p1_BEGIN_ADDRESS), 
      .PRBS_EADDR                    (C_p1_END_ADDRESS)
     )  
   m_traffic_gen_p1 
     (  
      .clk_i                         (clk0),     
      .rst_i                         (rst0),     
      .run_traffic_i                 (p1_tg_run_traffic),                  
      .manual_clear_error            (rst0),     
      // runtime parameter  
      .start_addr_i                  (p1_tg_start_addr),                  
      .end_addr_i                    (p1_tg_end_addr),                  
      .cmd_seed_i                    (p1_tg_cmd_seed),                  
      .data_seed_i                   (p1_tg_data_seed),                  
      .load_seed_i                   (p1_tg_load_seed),                
      .addr_mode_i                   (p1_tg_addr_mode),                
      .instr_mode_i                  (p1_tg_instr_mode),                  
      .bl_mode_i                     (p1_tg_bl_mode),                  
      .data_mode_i                   (p1_tg_data_mode),                  
      .mode_load_i                   (p1_tg_mode_load),                  
      // fixed pattern inputs interface  
      .fixed_bl_i                    (p1_tg_fixed_bl),                     
      .fixed_instr_i                 (p1_tg_fixed_instr),                     
      .fixed_addr_i                  (p1_tg_fixed_addr),                 
      .fixed_data_i                  (), 
      // BRAM interface. 
      .bram_cmd_i                    (), 
      .bram_valid_i                  (), 
      .bram_rdy_o                    (),  
      
      //  MCB INTERFACE  
      .mcb_cmd_en_o		     (p1_mcb_cmd_en),                 
      .mcb_cmd_instr_o		     (p1_mcb_cmd_instr),                    
      .mcb_cmd_bl_o		     (p1_mcb_cmd_bl),                 
      .mcb_cmd_addr_o		     (p1_mcb_cmd_addr),                   
      .mcb_cmd_full_i		     (p1_mcb_cmd_full),                   
   
      .mcb_wr_en_o		     (p1_mcb_wr_en),                
      .mcb_wr_mask_o		     (p1_mcb_wr_mask),                  
      .mcb_wr_data_o		     (p1_mcb_wr_data),                 
      .mcb_wr_data_end_o             (), 
      .mcb_wr_full_i		     (p1_mcb_wr_full),                  
      .mcb_wr_fifo_counts	     (p1_mcb_wr_fifo_counts),                       
   
      .mcb_rd_en_o		     (p1_mcb_rd_en),                
      .mcb_rd_data_i		     (p1_mcb_rd_data),                  
      .mcb_rd_empty_i		     (p1_mcb_rd_empty),                   
      .mcb_rd_fifo_counts	     (p1_mcb_rd_fifo_counts),                       
   
      // status feedback  
      .counts_rst                    (rst0),     
      .wr_data_counts                (), 
      .rd_data_counts                (), 
      .error                         (p1_error),
      .error_status                  (p1_error_status),
      .cmp_data                      (p1_cmp_data),            
      .cmp_data_valid                (p1_cmp_data_valid),                  
      .cmp_error                     (p1_cmp_error),             
      .mem_rd_data                   (), 
      .dq_error_bytelane_cmp         (), 
      .cumlative_dq_lane_error       ()
     );     
   end
   else begin: PORT1_NO_TG
      assign p1_error          = 'b0;
      assign p1_error_status   = 'b0;
      assign p1_cmp_data       = 'b0;
      assign p1_cmp_data_valid = 'b0;
      assign p1_cmp_error      = 'b0;
   end   
endgenerate


// The following 'generate' statement activates the traffic generator for
// Port-2 if it is enabled
generate
   if (C_PORT_ENABLE[2] == 1'b1)
   begin : PORT2_TG    
   // init_mem_pattern_ctr module instantiation for Port-2
   init_mem_pattern_ctr #
     (
      .DWIDTH                        (P2_DWIDTH), 
      .FAMILY                        (FAMILY),
      .BEGIN_ADDRESS                 (P2_BEGIN_ADDRESS),
      .END_ADDRESS                   (P2_END_ADDRESS),
      .CMD_SEED_VALUE                (32'h56456783),
      .DATA_SEED_VALUE               (32'h12345678),  
      .DATA_MODE                     (P2_DATA_MODE), 
      .PORT_MODE                     (C_P2_PORT_MODE) 
     )
   init_mem_pattern_ctr_p2
     (
      .clk_i                         (clk0),   
      .rst_i                         (rst0),     
   
      .mcb_cmd_en_i                  (p2_mcb_cmd_en_sig),   
      .mcb_cmd_instr_i               (p2_mcb_cmd_instr_sig),
      .mcb_cmd_addr_i                (p2_mcb_cmd_addr_sig), 
      .mcb_cmd_bl_i                  (p2_mcb_cmd_bl_sig),  
      .mcb_wr_en_i                   (p2_mcb_wr_en_sig), 
   
      .vio_modify_enable	     (vio_modify_enable),   
      .vio_data_mode_value           (vio_data_mode_value),  
      .vio_addr_mode_value           (vio_addr_mode_value),
      .vio_bl_mode_value             (2'b10),
      .vio_fixed_bl_value            (6'd64),
      .mcb_init_done_i               (calib_done),
      .cmp_error                     (p2_error),
      .run_traffic_o                 (p2_tg_run_traffic),  
      .start_addr_o                  (p2_tg_start_addr),
      .end_addr_o                    (p2_tg_end_addr), 
      .cmd_seed_o                    (p2_tg_cmd_seed),  
      .data_seed_o                   (p2_tg_data_seed), 
      .load_seed_o                   (p2_tg_load_seed), 
      .addr_mode_o                   (p2_tg_addr_mode), 
      .instr_mode_o                  (p2_tg_instr_mode), 
      .bl_mode_o                     (p2_tg_bl_mode), 
      .data_mode_o                   (p2_tg_data_mode), 
      .mode_load_o                   (p2_tg_mode_load), 
      .fixed_bl_o                    (p2_tg_fixed_bl), 
      .fixed_instr_o                 (p2_tg_fixed_instr), 
      .fixed_addr_o                  (p2_tg_fixed_addr) 
     );
   
   // traffic generator instantiation for Port-1
   mcb_traffic_gen #
     (  
      .MEM_BURST_LEN                 (C_MEM_BURST_LEN),  
      .MEM_COL_WIDTH                 (C_MEM_NUM_COL_BITS),  
      .NUM_DQ_PINS                   (C_NUM_DQ_PINS), 
      .DQ_ERROR_WIDTH                (DQ_ERROR_WIDTH),  
      .PORT_MODE                     (C_P2_PORT_MODE),     
      .DWIDTH                        (P2_DWIDTH),   
      .CMP_DATA_PIPE_STAGES          (CMP_DATA_PIPE_STAGES),   
      .FAMILY                        (FAMILY),    
      .SIMULATION                    ("FALSE"),   
      .DATA_PATTERN                  (TG_DATA_PATTERN),  
      .CMD_PATTERN                   ("CGEN_ALL"),  
      .ADDR_WIDTH                    (30),  
      .PRBS_SADDR_MASK_POS           (P2_PRBS_SADDR_MASK_POS), 
      .PRBS_EADDR_MASK_POS           (P2_PRBS_EADDR_MASK_POS),
      .PRBS_SADDR                    (P2_BEGIN_ADDRESS), 
      .PRBS_EADDR                    (P2_END_ADDRESS)
     )  
   m_traffic_gen_p2 
     (  
      .clk_i                         (clk0),     
      .rst_i                         (rst0),     
      .run_traffic_i                 (p2_tg_run_traffic),                  
      .manual_clear_error            (rst0),     
      // runtime parameter  
      .start_addr_i                  (p2_tg_start_addr),                  
      .end_addr_i                    (p2_tg_end_addr),                  
      .cmd_seed_i                    (p2_tg_cmd_seed),                  
      .data_seed_i                   (p2_tg_data_seed),                  
      .load_seed_i                   (p2_tg_load_seed),                
      .addr_mode_i                   (p2_tg_addr_mode),                
      .instr_mode_i                  (p2_tg_instr_mode),                  
      .bl_mode_i                     (p2_tg_bl_mode),                  
      .data_mode_i                   (p2_tg_data_mode),                  
      .mode_load_i                   (p2_tg_mode_load),                  
      // fixed pattern inputs interface  
      .fixed_bl_i                    (p2_tg_fixed_bl),                     
      .fixed_instr_i                 (p2_tg_fixed_instr),                     
      .fixed_addr_i                  (p2_tg_fixed_addr),                 
      .fixed_data_i                  (), 
      // BRAM interface. 
      .bram_cmd_i                    (), 
      .bram_valid_i                  (), 
      .bram_rdy_o                    (),  
      
      //  MCB INTERFACE  
      .mcb_cmd_en_o		     (p2_mcb_cmd_en),                 
      .mcb_cmd_instr_o		     (p2_mcb_cmd_instr),                    
      .mcb_cmd_bl_o		     (p2_mcb_cmd_bl),                 
      .mcb_cmd_addr_o		     (p2_mcb_cmd_addr),                   
      .mcb_cmd_full_i		     (p2_mcb_cmd_full),                   
   
      .mcb_wr_en_o		     (p2_mcb_wr_en),                
      .mcb_wr_mask_o		     (p2_mcb_wr_mask),                  
      .mcb_wr_data_o		     (p2_mcb_wr_data),                 
      .mcb_wr_data_end_o             (), 
      .mcb_wr_full_i		     (p2_mcb_wr_full),                  
      .mcb_wr_fifo_counts	     (p2_mcb_wr_fifo_counts),                       
   
      .mcb_rd_en_o		     (p2_mcb_rd_en),                
      .mcb_rd_data_i		     (p2_mcb_rd_data),                  
      .mcb_rd_empty_i		     (p2_mcb_rd_empty),                   
      .mcb_rd_fifo_counts	     (p2_mcb_rd_fifo_counts),                       
   
      // status feedback  
      .counts_rst                    (rst0),     
      .wr_data_counts                (), 
      .rd_data_counts                (), 
      .error                         (p2_error),
      .error_status                  (p2_error_status),
      .cmp_data                      (p2_cmp_data),            
      .cmp_data_valid                (p2_cmp_data_valid),                  
      .cmp_error                     (p2_cmp_error),             
      .mem_rd_data                   (), 
      .dq_error_bytelane_cmp         (), 
      .cumlative_dq_lane_error       ()
     );     
   end  
   else begin: PORT2_NO_TG
      assign p2_error          = 'b0;
      assign p2_error_status   = 'b0;
      assign p2_cmp_data       = 'b0;
      assign p2_cmp_data_valid = 'b0;
      assign p2_cmp_error      = 'b0;
   end   
endgenerate


// The following 'generate' statement activates the traffic generator for
// Port-3 if it is enabled
generate
   if (C_PORT_ENABLE[3] == 1'b1) 
   begin : PORT3_TG    
   // init_mem_pattern_ctr module instantiation for Port-3
   init_mem_pattern_ctr #
     (
      .DWIDTH                        (P3_DWIDTH), 
      .FAMILY                        (FAMILY),
      .BEGIN_ADDRESS                 (P3_BEGIN_ADDRESS),
      .END_ADDRESS                   (P3_END_ADDRESS),
      .CMD_SEED_VALUE                (32'h56456783),
      .DATA_SEED_VALUE               (32'h12345678),  
      .DATA_MODE                     (P3_DATA_MODE), 
      .PORT_MODE                     (C_P3_PORT_MODE) 
     )
   init_mem_pattern_ctr_p3
     (
      .clk_i                         (clk0),   
      .rst_i                         (rst0),     
   
      .mcb_cmd_en_i                  (p3_mcb_cmd_en_sig),   
      .mcb_cmd_instr_i               (p3_mcb_cmd_instr_sig),
      .mcb_cmd_addr_i                (p3_mcb_cmd_addr_sig), 
      .mcb_cmd_bl_i                  (p3_mcb_cmd_bl_sig),  
      .mcb_wr_en_i                   (p3_mcb_wr_en_sig), 
   
      .vio_modify_enable	     (vio_modify_enable),   
      .vio_data_mode_value           (vio_data_mode_value),  
      .vio_addr_mode_value           (vio_addr_mode_value),
      .vio_bl_mode_value             (2'b10),
      .vio_fixed_bl_value            (6'd64),
      .mcb_init_done_i               (calib_done),
      .cmp_error                     (p3_error),
      .run_traffic_o                 (p3_tg_run_traffic),  
      .start_addr_o                  (p3_tg_start_addr),
      .end_addr_o                    (p3_tg_end_addr), 
      .cmd_seed_o                    (p3_tg_cmd_seed),  
      .data_seed_o                   (p3_tg_data_seed), 
      .load_seed_o                   (p3_tg_load_seed), 
      .addr_mode_o                   (p3_tg_addr_mode), 
      .instr_mode_o                  (p3_tg_instr_mode), 
      .bl_mode_o                     (p3_tg_bl_mode), 
      .data_mode_o                   (p3_tg_data_mode), 
      .mode_load_o                   (p3_tg_mode_load), 
      .fixed_bl_o                    (p3_tg_fixed_bl), 
      .fixed_instr_o                 (p3_tg_fixed_instr), 
      .fixed_addr_o                  (p3_tg_fixed_addr) 
     );
   
   // traffic generator instantiation for Port-1
   mcb_traffic_gen #
     (  
      .MEM_BURST_LEN                 (C_MEM_BURST_LEN),  
      .MEM_COL_WIDTH                 (C_MEM_NUM_COL_BITS),  
      .NUM_DQ_PINS                   (C_NUM_DQ_PINS), 
      .DQ_ERROR_WIDTH                (DQ_ERROR_WIDTH),  
      .PORT_MODE                     (C_P3_PORT_MODE),     
      .DWIDTH                        (P3_DWIDTH),   
      .CMP_DATA_PIPE_STAGES          (CMP_DATA_PIPE_STAGES),   
      .FAMILY                        (FAMILY),    
      .SIMULATION                    ("FALSE"),   
      .DATA_PATTERN                  (TG_DATA_PATTERN),  
      .CMD_PATTERN                   ("CGEN_ALL"),  
      .ADDR_WIDTH                    (30),  
      .PRBS_SADDR_MASK_POS           (P3_PRBS_SADDR_MASK_POS), 
      .PRBS_EADDR_MASK_POS           (P3_PRBS_EADDR_MASK_POS),
      .PRBS_SADDR                    (P3_BEGIN_ADDRESS), 
      .PRBS_EADDR                    (P3_END_ADDRESS)
     )  
   m_traffic_gen_p3 
     (  
      .clk_i                         (clk0),     
      .rst_i                         (rst0),     
      .run_traffic_i                 (p3_tg_run_traffic),                  
      .manual_clear_error            (rst0),     
      // runtime parameter  
      .start_addr_i                  (p3_tg_start_addr),                  
      .end_addr_i                    (p3_tg_end_addr),                  
      .cmd_seed_i                    (p3_tg_cmd_seed),                  
      .data_seed_i                   (p3_tg_data_seed),                  
      .load_seed_i                   (p3_tg_load_seed),                
      .addr_mode_i                   (p3_tg_addr_mode),                
      .instr_mode_i                  (p3_tg_instr_mode),                  
      .bl_mode_i                     (p3_tg_bl_mode),                  
      .data_mode_i                   (p3_tg_data_mode),                  
      .mode_load_i                   (p3_tg_mode_load),                  
      // fixed pattern inputs interface  
      .fixed_bl_i                    (p3_tg_fixed_bl),                     
      .fixed_instr_i                 (p3_tg_fixed_instr),                     
      .fixed_addr_i                  (p3_tg_fixed_addr),                 
      .fixed_data_i                  (), 
      // BRAM interface. 
      .bram_cmd_i                    (), 
      .bram_valid_i                  (), 
      .bram_rdy_o                    (),  
      
      //  MCB INTERFACE  
      .mcb_cmd_en_o		     (p3_mcb_cmd_en),                 
      .mcb_cmd_instr_o		     (p3_mcb_cmd_instr),                    
      .mcb_cmd_bl_o		     (p3_mcb_cmd_bl),                 
      .mcb_cmd_addr_o		     (p3_mcb_cmd_addr),                   
      .mcb_cmd_full_i		     (p3_mcb_cmd_full),                   
   
      .mcb_wr_en_o		     (p3_mcb_wr_en),                
      .mcb_wr_mask_o		     (p3_mcb_wr_mask),                  
      .mcb_wr_data_o		     (p3_mcb_wr_data),                 
      .mcb_wr_data_end_o             (), 
      .mcb_wr_full_i		     (p3_mcb_wr_full),                  
      .mcb_wr_fifo_counts	     (p3_mcb_wr_fifo_counts),                       
   
      .mcb_rd_en_o		     (p3_mcb_rd_en),                
      .mcb_rd_data_i		     (p3_mcb_rd_data),                  
      .mcb_rd_empty_i		     (p3_mcb_rd_empty),                   
      .mcb_rd_fifo_counts	     (p3_mcb_rd_fifo_counts),                       
   
      // status feedback  
      .counts_rst                    (rst0),     
      .wr_data_counts                (), 
      .rd_data_counts                (), 
      .error                         (p3_error),
      .error_status                  (p3_error_status),
      .cmp_data                      (p3_cmp_data),            
      .cmp_data_valid                (p3_cmp_data_valid),                  
      .cmp_error                     (p3_cmp_error),             
      .mem_rd_data                   (), 
      .dq_error_bytelane_cmp         (), 
      .cumlative_dq_lane_error       ()
     );     
   end  
   else begin: PORT3_NO_TG
      assign p3_error          = 'b0;
      assign p3_error_status   = 'b0;
      assign p3_cmp_data       = 'b0;
      assign p3_cmp_data_valid = 'b0;
      assign p3_cmp_error      = 'b0;
   end   
endgenerate


// The following 'generate' statement activates the traffic generator for
// Port-4 if it is enabled
generate
   if (C_PORT_ENABLE[4] == 1'b1) 
   begin : PORT4_TG    
   // init_mem_pattern_ctr module instantiation for Port-4
   init_mem_pattern_ctr #
     (
      .DWIDTH                        (P4_DWIDTH), 
      .FAMILY                        (FAMILY),
      .BEGIN_ADDRESS                 (P4_BEGIN_ADDRESS),
      .END_ADDRESS                   (P4_END_ADDRESS),
      .CMD_SEED_VALUE                (32'h56456783),
      .DATA_SEED_VALUE               (32'h12345678),  
      .DATA_MODE                     (P4_DATA_MODE), 
      .PORT_MODE                     (C_P4_PORT_MODE) 
     )
   init_mem_pattern_ctr_p4
     (
      .clk_i                         (clk0),   
      .rst_i                         (rst0),     
   
      .mcb_cmd_en_i                  (p4_mcb_cmd_en_sig),   
      .mcb_cmd_instr_i               (p4_mcb_cmd_instr_sig),
      .mcb_cmd_addr_i                (p4_mcb_cmd_addr_sig), 
      .mcb_cmd_bl_i                  (p4_mcb_cmd_bl_sig),  
      .mcb_wr_en_i                   (p4_mcb_wr_en_sig), 
   
      .vio_modify_enable	     (vio_modify_enable),   
      .vio_data_mode_value           (vio_data_mode_value),  
      .vio_addr_mode_value           (vio_addr_mode_value),
      .vio_bl_mode_value             (2'b10),
      .vio_fixed_bl_value            (6'd64),
      .mcb_init_done_i               (calib_done),
      .cmp_error                     (p4_error),
      .run_traffic_o                 (p4_tg_run_traffic),  
      .start_addr_o                  (p4_tg_start_addr),
      .end_addr_o                    (p4_tg_end_addr), 
      .cmd_seed_o                    (p4_tg_cmd_seed),  
      .data_seed_o                   (p4_tg_data_seed), 
      .load_seed_o                   (p4_tg_load_seed), 
      .addr_mode_o                   (p4_tg_addr_mode), 
      .instr_mode_o                  (p4_tg_instr_mode), 
      .bl_mode_o                     (p4_tg_bl_mode), 
      .data_mode_o                   (p4_tg_data_mode), 
      .mode_load_o                   (p4_tg_mode_load), 
      .fixed_bl_o                    (p4_tg_fixed_bl), 
      .fixed_instr_o                 (p4_tg_fixed_instr), 
      .fixed_addr_o                  (p4_tg_fixed_addr) 
     );
   
   // traffic generator instantiation for Port-1
   mcb_traffic_gen #
     (  
      .MEM_BURST_LEN                 (C_MEM_BURST_LEN),  
      .MEM_COL_WIDTH                 (C_MEM_NUM_COL_BITS),  
      .NUM_DQ_PINS                   (C_NUM_DQ_PINS), 
      .DQ_ERROR_WIDTH                (DQ_ERROR_WIDTH),  
      .PORT_MODE                     (C_P4_PORT_MODE),     
      .DWIDTH                        (P4_DWIDTH),   
      .CMP_DATA_PIPE_STAGES          (CMP_DATA_PIPE_STAGES),   
      .FAMILY                        (FAMILY),    
      .SIMULATION                    ("FALSE"),   
      .DATA_PATTERN                  (TG_DATA_PATTERN),  
      .CMD_PATTERN                   ("CGEN_ALL"),  
      .ADDR_WIDTH                    (30),  
      .PRBS_SADDR_MASK_POS           (P4_PRBS_SADDR_MASK_POS), 
      .PRBS_EADDR_MASK_POS           (P4_PRBS_EADDR_MASK_POS),
      .PRBS_SADDR                    (P4_BEGIN_ADDRESS), 
      .PRBS_EADDR                    (P4_END_ADDRESS)
     )  
   m_traffic_gen_p4 
     (  
      .clk_i                         (clk0),     
      .rst_i                         (rst0),     
      .run_traffic_i                 (p4_tg_run_traffic),                  
      .manual_clear_error            (rst0),     
      // runtime parameter  
      .start_addr_i                  (p4_tg_start_addr),                  
      .end_addr_i                    (p4_tg_end_addr),                  
      .cmd_seed_i                    (p4_tg_cmd_seed),                  
      .data_seed_i                   (p4_tg_data_seed),                  
      .load_seed_i                   (p4_tg_load_seed),                
      .addr_mode_i                   (p4_tg_addr_mode),                
      .instr_mode_i                  (p4_tg_instr_mode),                  
      .bl_mode_i                     (p4_tg_bl_mode),                  
      .data_mode_i                   (p4_tg_data_mode),                  
      .mode_load_i                   (p4_tg_mode_load),                  
      // fixed pattern inputs interface  
      .fixed_bl_i                    (p4_tg_fixed_bl),                     
      .fixed_instr_i                 (p4_tg_fixed_instr),                     
      .fixed_addr_i                  (p4_tg_fixed_addr),                 
      .fixed_data_i                  (), 
      // BRAM interface. 
      .bram_cmd_i                    (), 
      .bram_valid_i                  (), 
      .bram_rdy_o                    (),  
      
      //  MCB INTERFACE  
      .mcb_cmd_en_o		     (p4_mcb_cmd_en),                 
      .mcb_cmd_instr_o		     (p4_mcb_cmd_instr),                    
      .mcb_cmd_bl_o		     (p4_mcb_cmd_bl),                 
      .mcb_cmd_addr_o		     (p4_mcb_cmd_addr),                   
      .mcb_cmd_full_i		     (p4_mcb_cmd_full),                   
   
      .mcb_wr_en_o		     (p4_mcb_wr_en),                
      .mcb_wr_mask_o		     (p4_mcb_wr_mask),                  
      .mcb_wr_data_o		     (p4_mcb_wr_data),                 
      .mcb_wr_data_end_o             (), 
      .mcb_wr_full_i		     (p4_mcb_wr_full),                  
      .mcb_wr_fifo_counts	     (p4_mcb_wr_fifo_counts),                       
   
      .mcb_rd_en_o		     (p4_mcb_rd_en),                
      .mcb_rd_data_i		     (p4_mcb_rd_data),                  
      .mcb_rd_empty_i		     (p4_mcb_rd_empty),                   
      .mcb_rd_fifo_counts	     (p4_mcb_rd_fifo_counts),                       
   
      // status feedback  
      .counts_rst                    (rst0),     
      .wr_data_counts                (), 
      .rd_data_counts                (), 
      .error                         (p4_error),
      .error_status                  (p4_error_status),
      .cmp_data                      (p4_cmp_data),            
      .cmp_data_valid                (p4_cmp_data_valid),                  
      .cmp_error                     (p4_cmp_error),             
      .mem_rd_data                   (), 
      .dq_error_bytelane_cmp         (), 
      .cumlative_dq_lane_error       ()
     );     
   end  
   else begin: PORT4_NO_TG
      assign p4_error          = 'b0;
      assign p4_error_status   = 'b0;
      assign p4_cmp_data       = 'b0;
      assign p4_cmp_data_valid = 'b0;
      assign p4_cmp_error      = 'b0;
   end   
endgenerate


// The following 'generate' statement activates the traffic generator for
// Port-5 if it is enabled
generate
   if (C_PORT_ENABLE[5] == 1'b1) 
   begin : PORT5_TG    
   // init_mem_pattern_ctr module instantiation for Port-5
   init_mem_pattern_ctr #
     (
      .DWIDTH                        (P5_DWIDTH), 
      .FAMILY                        (FAMILY),
      .BEGIN_ADDRESS                 (P5_BEGIN_ADDRESS),
      .END_ADDRESS                   (P5_END_ADDRESS),
      .CMD_SEED_VALUE                (32'h56456783),
      .DATA_SEED_VALUE               (32'h12345678),  
      .DATA_MODE                     (P5_DATA_MODE), 
      .PORT_MODE                     (C_P5_PORT_MODE) 
     )
   init_mem_pattern_ctr_p5
     (
      .clk_i                         (clk0),   
      .rst_i                         (rst0),     
   
      .mcb_cmd_en_i                  (p5_mcb_cmd_en_sig),   
      .mcb_cmd_instr_i               (p5_mcb_cmd_instr_sig),
      .mcb_cmd_addr_i                (p5_mcb_cmd_addr_sig), 
      .mcb_cmd_bl_i                  (p5_mcb_cmd_bl_sig),  
      .mcb_wr_en_i                   (p5_mcb_wr_en_sig), 
   
      .vio_modify_enable	     (vio_modify_enable),   
      .vio_data_mode_value           (vio_data_mode_value),  
      .vio_addr_mode_value           (vio_addr_mode_value),
      .vio_bl_mode_value             (2'b10),
      .vio_fixed_bl_value            (6'd64),
      .mcb_init_done_i               (calib_done),
      .cmp_error                     (p5_error),
      .run_traffic_o                 (p5_tg_run_traffic),  
      .start_addr_o                  (p5_tg_start_addr),
      .end_addr_o                    (p5_tg_end_addr), 
      .cmd_seed_o                    (p5_tg_cmd_seed),  
      .data_seed_o                   (p5_tg_data_seed), 
      .load_seed_o                   (p5_tg_load_seed), 
      .addr_mode_o                   (p5_tg_addr_mode), 
      .instr_mode_o                  (p5_tg_instr_mode), 
      .bl_mode_o                     (p5_tg_bl_mode), 
      .data_mode_o                   (p5_tg_data_mode), 
      .mode_load_o                   (p5_tg_mode_load), 
      .fixed_bl_o                    (p5_tg_fixed_bl), 
      .fixed_instr_o                 (p5_tg_fixed_instr), 
      .fixed_addr_o                  (p5_tg_fixed_addr) 
     );
   
   // traffic generator instantiation for Port-1
   mcb_traffic_gen #
     (  
      .MEM_BURST_LEN                 (C_MEM_BURST_LEN),  
      .MEM_COL_WIDTH                 (C_MEM_NUM_COL_BITS),  
      .NUM_DQ_PINS                   (C_NUM_DQ_PINS), 
      .DQ_ERROR_WIDTH                (DQ_ERROR_WIDTH),  
      .PORT_MODE                     (C_P5_PORT_MODE),     
      .DWIDTH                        (P5_DWIDTH),   
      .CMP_DATA_PIPE_STAGES          (CMP_DATA_PIPE_STAGES),   
      .FAMILY                        (FAMILY),    
      .SIMULATION                    ("FALSE"),   
      .DATA_PATTERN                  (TG_DATA_PATTERN),  
      .CMD_PATTERN                   ("CGEN_ALL"),  
      .ADDR_WIDTH                    (30),  
      .PRBS_SADDR_MASK_POS           (P5_PRBS_SADDR_MASK_POS), 
      .PRBS_EADDR_MASK_POS           (P5_PRBS_EADDR_MASK_POS),
      .PRBS_SADDR                    (P5_BEGIN_ADDRESS), 
      .PRBS_EADDR                    (P5_END_ADDRESS)
     )  
   m_traffic_gen_p5 
     (  
      .clk_i                         (clk0),     
      .rst_i                         (rst0),     
      .run_traffic_i                 (p5_tg_run_traffic),                  
      .manual_clear_error            (rst0),     
      // runtime parameter  
      .start_addr_i                  (p5_tg_start_addr),                  
      .end_addr_i                    (p5_tg_end_addr),                  
      .cmd_seed_i                    (p5_tg_cmd_seed),                  
      .data_seed_i                   (p5_tg_data_seed),                  
      .load_seed_i                   (p5_tg_load_seed),                
      .addr_mode_i                   (p5_tg_addr_mode),                
      .instr_mode_i                  (p5_tg_instr_mode),                  
      .bl_mode_i                     (p5_tg_bl_mode),                  
      .data_mode_i                   (p5_tg_data_mode),                  
      .mode_load_i                   (p5_tg_mode_load),                  
      // fixed pattern inputs interface  
      .fixed_bl_i                    (p5_tg_fixed_bl),                     
      .fixed_instr_i                 (p5_tg_fixed_instr),                     
      .fixed_addr_i                  (p5_tg_fixed_addr),                 
      .fixed_data_i                  (), 
      // BRAM interface. 
      .bram_cmd_i                    (), 
      .bram_valid_i                  (), 
      .bram_rdy_o                    (),  
      
      //  MCB INTERFACE  
      .mcb_cmd_en_o		     (p5_mcb_cmd_en),                 
      .mcb_cmd_instr_o		     (p5_mcb_cmd_instr),                    
      .mcb_cmd_bl_o		     (p5_mcb_cmd_bl),                 
      .mcb_cmd_addr_o		     (p5_mcb_cmd_addr),                   
      .mcb_cmd_full_i		     (p5_mcb_cmd_full),                   
   
      .mcb_wr_en_o		     (p5_mcb_wr_en),                
      .mcb_wr_mask_o		     (p5_mcb_wr_mask),                  
      .mcb_wr_data_o		     (p5_mcb_wr_data),                 
      .mcb_wr_data_end_o             (), 
      .mcb_wr_full_i		     (p5_mcb_wr_full),                  
      .mcb_wr_fifo_counts	     (p5_mcb_wr_fifo_counts),                       
   
      .mcb_rd_en_o		     (p5_mcb_rd_en),                
      .mcb_rd_data_i		     (p5_mcb_rd_data),                  
      .mcb_rd_empty_i		     (p5_mcb_rd_empty),                   
      .mcb_rd_fifo_counts	     (p5_mcb_rd_fifo_counts),                       
   
      // status feedback  
      .counts_rst                    (rst0),     
      .wr_data_counts                (), 
      .rd_data_counts                (), 
      .error                         (p5_error),
      .error_status                  (p5_error_status),
      .cmp_data                      (p5_cmp_data),            
      .cmp_data_valid                (p5_cmp_data_valid),                  
      .cmp_error                     (p5_cmp_error),             
      .mem_rd_data                   (), 
      .dq_error_bytelane_cmp         (), 
      .cumlative_dq_lane_error       ()
     );
   end
   else begin: PORT5_NO_TG
      assign p5_error          = 'b0;
      assign p5_error_status   = 'b0;
      assign p5_cmp_data       = 'b0;
      assign p5_cmp_data_valid = 'b0;
      assign p5_cmp_error      = 'b0;
   end   
endgenerate    


// The following 'generate' statement captures data for the command field signals
// which should be fedback to init_mem_pattern_ctr module from mcb_traffic_gen module
generate
if (C_PORT_ENABLE[2] == 1'b1) begin: P2_cmd_field_mapping

   if (C_P2_PORT_MODE == "RD_MODE") begin: RD_P2_cmd_field_mapping
      if (C_PORT_ENABLE[0] == 1'b1) begin: RD_P2_equal_P0_cmd_field
         assign p2_mcb_cmd_en_sig          = p0_mcb_cmd_en; 
         assign p2_mcb_cmd_instr_sig       = p0_mcb_cmd_instr;
         assign p2_mcb_cmd_addr_sig        = p0_mcb_cmd_addr;
         assign p2_mcb_cmd_bl_sig          = p0_mcb_cmd_bl;
         assign p2_mcb_wr_en_sig           = p0_mcb_wr_en;
      end	 
      else if (C_PORT_ENABLE[1] == 1'b1) begin: RD_P2_equal_P1_cmd_field
         assign p2_mcb_cmd_en_sig          = p1_mcb_cmd_en; 
         assign p2_mcb_cmd_instr_sig       = p1_mcb_cmd_instr;
         assign p2_mcb_cmd_addr_sig        = p1_mcb_cmd_addr;
         assign p2_mcb_cmd_bl_sig          = p1_mcb_cmd_bl;
         assign p2_mcb_wr_en_sig           = p1_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[3] == 1'b1) && (C_P3_PORT_MODE == "WR_MODE"))  begin: RD_P2_equal_P3_cmd_field
         assign p2_mcb_cmd_en_sig          = p3_mcb_cmd_en; 
         assign p2_mcb_cmd_instr_sig       = p3_mcb_cmd_instr;
         assign p2_mcb_cmd_addr_sig        = p3_mcb_cmd_addr;
         assign p2_mcb_cmd_bl_sig          = p3_mcb_cmd_bl;
         assign p2_mcb_wr_en_sig           = p3_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[4] == 1'b1) && (C_P4_PORT_MODE == "WR_MODE")) begin: RD_P2_equal_P4_cmd_field
         assign p2_mcb_cmd_en_sig          = p4_mcb_cmd_en; 
         assign p2_mcb_cmd_instr_sig       = p4_mcb_cmd_instr;
         assign p2_mcb_cmd_addr_sig        = p4_mcb_cmd_addr;
         assign p2_mcb_cmd_bl_sig          = p4_mcb_cmd_bl;
         assign p2_mcb_wr_en_sig           = p4_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[5] == 1'b1) && (C_P5_PORT_MODE == "WR_MODE")) begin: RD_P2_equal_P5_cmd_field
         assign p2_mcb_cmd_en_sig          = p5_mcb_cmd_en; 
         assign p2_mcb_cmd_instr_sig       = p5_mcb_cmd_instr;
         assign p2_mcb_cmd_addr_sig        = p5_mcb_cmd_addr;
         assign p2_mcb_cmd_bl_sig          = p5_mcb_cmd_bl;
         assign p2_mcb_wr_en_sig           = p5_mcb_wr_en;
      end
        else begin: RD_P2_equal_P2_cmd_field
         assign p2_mcb_cmd_en_sig          = p2_mcb_cmd_en; 
         assign p2_mcb_cmd_instr_sig       = p2_mcb_cmd_instr;
         assign p2_mcb_cmd_addr_sig        = p2_mcb_cmd_addr;
         assign p2_mcb_cmd_bl_sig          = p2_mcb_cmd_bl;
         assign p2_mcb_wr_en_sig           = p2_mcb_wr_en;
      end
   end   
   else begin: WR_P2_cmd_field_mapping
      assign p2_mcb_cmd_en_sig          = p2_mcb_cmd_en; 
      assign p2_mcb_cmd_instr_sig       = p2_mcb_cmd_instr;
      assign p2_mcb_cmd_addr_sig        = p2_mcb_cmd_addr;
      assign p2_mcb_cmd_bl_sig          = p2_mcb_cmd_bl;
      assign p2_mcb_wr_en_sig           = p2_mcb_wr_en;
   end
end 

if (C_PORT_ENABLE[3] == 1'b1) begin: P3_cmd_field_mapping

   if (C_P3_PORT_MODE == "RD_MODE") begin: RD_P3_cmd_field_mapping
      if (C_PORT_ENABLE[0] == 1'b1) begin: RD_P3_equal_P0_cmd_field
         assign p3_mcb_cmd_en_sig          = p0_mcb_cmd_en; 
         assign p3_mcb_cmd_instr_sig       = p0_mcb_cmd_instr;
         assign p3_mcb_cmd_addr_sig        = p0_mcb_cmd_addr;
         assign p3_mcb_cmd_bl_sig          = p0_mcb_cmd_bl;
         assign p3_mcb_wr_en_sig           = p0_mcb_wr_en;
      end	 
      else if (C_PORT_ENABLE[1] == 1'b1) begin: RD_P3_equal_P1_cmd_field
         assign p3_mcb_cmd_en_sig          = p1_mcb_cmd_en; 
         assign p3_mcb_cmd_instr_sig       = p1_mcb_cmd_instr;
         assign p3_mcb_cmd_addr_sig        = p1_mcb_cmd_addr;
         assign p3_mcb_cmd_bl_sig          = p1_mcb_cmd_bl;
         assign p3_mcb_wr_en_sig           = p1_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[2] == 1'b1) && (C_P2_PORT_MODE == "WR_MODE"))  begin: RD_P3_equal_P2_cmd_field
         assign p3_mcb_cmd_en_sig          = p2_mcb_cmd_en; 
         assign p3_mcb_cmd_instr_sig       = p2_mcb_cmd_instr;
         assign p3_mcb_cmd_addr_sig        = p2_mcb_cmd_addr;
         assign p3_mcb_cmd_bl_sig          = p2_mcb_cmd_bl;
         assign p3_mcb_wr_en_sig           = p2_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[4] == 1'b1) && (C_P4_PORT_MODE == "WR_MODE")) begin: RD_P3_equal_P4_cmd_field
         assign p3_mcb_cmd_en_sig          = p4_mcb_cmd_en; 
         assign p3_mcb_cmd_instr_sig       = p4_mcb_cmd_instr;
         assign p3_mcb_cmd_addr_sig        = p4_mcb_cmd_addr;
         assign p3_mcb_cmd_bl_sig          = p4_mcb_cmd_bl;
         assign p3_mcb_wr_en_sig           = p4_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[5] == 1'b1) && (C_P5_PORT_MODE == "WR_MODE")) begin: RD_P3_equal_P5_cmd_field
         assign p3_mcb_cmd_en_sig          = p5_mcb_cmd_en; 
         assign p3_mcb_cmd_instr_sig       = p5_mcb_cmd_instr;
         assign p3_mcb_cmd_addr_sig        = p5_mcb_cmd_addr;
         assign p3_mcb_cmd_bl_sig          = p5_mcb_cmd_bl;
         assign p3_mcb_wr_en_sig           = p5_mcb_wr_en;
      end
        else begin: RD_P3_equal_P3_cmd_field
         assign p3_mcb_cmd_en_sig          = p3_mcb_cmd_en; 
         assign p3_mcb_cmd_instr_sig       = p3_mcb_cmd_instr;
         assign p3_mcb_cmd_addr_sig        = p3_mcb_cmd_addr;
         assign p3_mcb_cmd_bl_sig          = p3_mcb_cmd_bl;
         assign p3_mcb_wr_en_sig           = p3_mcb_wr_en;
      end
   end   
   else begin: WR_P3_cmd_field_mapping
      assign p3_mcb_cmd_en_sig          = p3_mcb_cmd_en; 
      assign p3_mcb_cmd_instr_sig       = p3_mcb_cmd_instr;
      assign p3_mcb_cmd_addr_sig        = p3_mcb_cmd_addr;
      assign p3_mcb_cmd_bl_sig          = p3_mcb_cmd_bl;
      assign p3_mcb_wr_en_sig           = p3_mcb_wr_en;
   end
end 

if (C_PORT_ENABLE[4] == 1'b1) begin: P4_cmd_field_mapping

   if (C_P4_PORT_MODE == "RD_MODE") begin: RD_P4_cmd_field_mapping
      if (C_PORT_ENABLE[0] == 1'b1) begin: RD_P4_equal_P0_cmd_field
         assign p4_mcb_cmd_en_sig          = p0_mcb_cmd_en; 
         assign p4_mcb_cmd_instr_sig       = p0_mcb_cmd_instr;
         assign p4_mcb_cmd_addr_sig        = p0_mcb_cmd_addr;
         assign p4_mcb_cmd_bl_sig          = p0_mcb_cmd_bl;
         assign p4_mcb_wr_en_sig           = p0_mcb_wr_en;
      end	 
      else if (C_PORT_ENABLE[1] == 1'b1) begin: RD_P4_equal_P1_cmd_field
         assign p4_mcb_cmd_en_sig          = p1_mcb_cmd_en; 
         assign p4_mcb_cmd_instr_sig       = p1_mcb_cmd_instr;
         assign p4_mcb_cmd_addr_sig        = p1_mcb_cmd_addr;
         assign p4_mcb_cmd_bl_sig          = p1_mcb_cmd_bl;
         assign p4_mcb_wr_en_sig           = p1_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[2] == 1'b1) && (C_P2_PORT_MODE == "WR_MODE"))  begin: RD_P4_equal_P2_cmd_field
         assign p4_mcb_cmd_en_sig          = p2_mcb_cmd_en; 
         assign p4_mcb_cmd_instr_sig       = p2_mcb_cmd_instr;
         assign p4_mcb_cmd_addr_sig        = p2_mcb_cmd_addr;
         assign p4_mcb_cmd_bl_sig          = p2_mcb_cmd_bl;
         assign p4_mcb_wr_en_sig           = p2_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[3] == 1'b1) && (C_P3_PORT_MODE == "WR_MODE")) begin: RD_P4_equal_P3_cmd_field
         assign p4_mcb_cmd_en_sig          = p3_mcb_cmd_en; 
         assign p4_mcb_cmd_instr_sig       = p3_mcb_cmd_instr;
         assign p4_mcb_cmd_addr_sig        = p3_mcb_cmd_addr;
         assign p4_mcb_cmd_bl_sig          = p3_mcb_cmd_bl;
         assign p4_mcb_wr_en_sig           = p3_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[5] == 1'b1) && (C_P5_PORT_MODE == "WR_MODE")) begin: RD_P4_equal_P5_cmd_field
         assign p4_mcb_cmd_en_sig          = p5_mcb_cmd_en; 
         assign p4_mcb_cmd_instr_sig       = p5_mcb_cmd_instr;
         assign p4_mcb_cmd_addr_sig        = p5_mcb_cmd_addr;
         assign p4_mcb_cmd_bl_sig          = p5_mcb_cmd_bl;
         assign p4_mcb_wr_en_sig           = p5_mcb_wr_en;
      end
        else begin: RD_P4_equal_P4_cmd_field
         assign p4_mcb_cmd_en_sig          = p4_mcb_cmd_en; 
         assign p4_mcb_cmd_instr_sig       = p4_mcb_cmd_instr;
         assign p4_mcb_cmd_addr_sig        = p4_mcb_cmd_addr;
         assign p4_mcb_cmd_bl_sig          = p4_mcb_cmd_bl;
         assign p4_mcb_wr_en_sig           = p4_mcb_wr_en;
      end
   end   
   else begin: WR_P4_cmd_field_mapping
      assign p4_mcb_cmd_en_sig          = p4_mcb_cmd_en; 
      assign p4_mcb_cmd_instr_sig       = p4_mcb_cmd_instr;
      assign p4_mcb_cmd_addr_sig        = p4_mcb_cmd_addr;
      assign p4_mcb_cmd_bl_sig          = p4_mcb_cmd_bl;
      assign p4_mcb_wr_en_sig           = p4_mcb_wr_en;
   end
end 

if (C_PORT_ENABLE[5] == 1'b1) begin: P5_cmd_field_mapping

   if (C_P5_PORT_MODE == "RD_MODE") begin: RD_P5_cmd_field_mapping
      if (C_PORT_ENABLE[0] == 1'b1) begin: RD_P5_equal_P0_cmd_field
         assign p5_mcb_cmd_en_sig          = p0_mcb_cmd_en; 
         assign p5_mcb_cmd_instr_sig       = p0_mcb_cmd_instr;
         assign p5_mcb_cmd_addr_sig        = p0_mcb_cmd_addr;
         assign p5_mcb_cmd_bl_sig          = p0_mcb_cmd_bl;
         assign p5_mcb_wr_en_sig           = p0_mcb_wr_en;
      end	 
      else if (C_PORT_ENABLE[1] == 1'b1) begin: RD_P5_equal_P1_cmd_field
         assign p5_mcb_cmd_en_sig          = p1_mcb_cmd_en; 
         assign p5_mcb_cmd_instr_sig       = p1_mcb_cmd_instr;
         assign p5_mcb_cmd_addr_sig        = p1_mcb_cmd_addr;
         assign p5_mcb_cmd_bl_sig          = p1_mcb_cmd_bl;
         assign p5_mcb_wr_en_sig           = p1_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[2] == 1'b1) && (C_P2_PORT_MODE == "WR_MODE"))  begin: RD_P5_equal_P2_cmd_field
         assign p5_mcb_cmd_en_sig          = p2_mcb_cmd_en; 
         assign p5_mcb_cmd_instr_sig       = p2_mcb_cmd_instr;
         assign p5_mcb_cmd_addr_sig        = p2_mcb_cmd_addr;
         assign p5_mcb_cmd_bl_sig          = p2_mcb_cmd_bl;
         assign p5_mcb_wr_en_sig           = p2_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[3] == 1'b1) && (C_P3_PORT_MODE == "WR_MODE")) begin: RD_P5_equal_P3_cmd_field
         assign p5_mcb_cmd_en_sig          = p3_mcb_cmd_en; 
         assign p5_mcb_cmd_instr_sig       = p3_mcb_cmd_instr;
         assign p5_mcb_cmd_addr_sig        = p3_mcb_cmd_addr;
         assign p5_mcb_cmd_bl_sig          = p3_mcb_cmd_bl;
         assign p5_mcb_wr_en_sig           = p3_mcb_wr_en;
      end	 
        else if ((C_PORT_ENABLE[4] == 1'b1) && (C_P4_PORT_MODE == "WR_MODE")) begin: RD_P5_equal_P4_cmd_field
         assign p5_mcb_cmd_en_sig          = p4_mcb_cmd_en; 
         assign p5_mcb_cmd_instr_sig       = p4_mcb_cmd_instr;
         assign p5_mcb_cmd_addr_sig        = p4_mcb_cmd_addr;
         assign p5_mcb_cmd_bl_sig          = p4_mcb_cmd_bl;
         assign p5_mcb_wr_en_sig           = p4_mcb_wr_en;
      end
        else begin: RD_P5_equal_P5_cmd_field
         assign p5_mcb_cmd_en_sig          = p5_mcb_cmd_en; 
         assign p5_mcb_cmd_instr_sig       = p5_mcb_cmd_instr;
         assign p5_mcb_cmd_addr_sig        = p5_mcb_cmd_addr;
         assign p5_mcb_cmd_bl_sig          = p5_mcb_cmd_bl;
         assign p5_mcb_wr_en_sig           = p5_mcb_wr_en;
      end
   end   
   else begin: WR_P5_cmd_field_mapping
      assign p5_mcb_cmd_en_sig          = p5_mcb_cmd_en; 
      assign p5_mcb_cmd_instr_sig       = p5_mcb_cmd_instr;
      assign p5_mcb_cmd_addr_sig        = p5_mcb_cmd_addr;
      assign p5_mcb_cmd_bl_sig          = p5_mcb_cmd_bl;
      assign p5_mcb_wr_en_sig           = p5_mcb_wr_en;
   end
end 
endgenerate

endmodule
