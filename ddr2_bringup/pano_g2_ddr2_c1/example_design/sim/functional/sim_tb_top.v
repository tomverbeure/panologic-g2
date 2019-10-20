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
   parameter C1_CALIB_SOFT_IP      = "TRUE";
   parameter C1_SIMULATION      = "TRUE";
   parameter C1_HW_TESTING      = "FALSE";
// ========================================================================== //
// Signal Declarations                                                        //
// ========================================================================== //

 // Clocks
   reg                              c1_sys_clk;
   wire                             c1_sys_clk_p;
   wire                             c1_sys_clk_n;
// System Reset
   reg                              c1_sys_rst;
   wire                             c1_sys_rst_i;

// Design-Top Port Map   
   wire [C1_MEM_ADDR_WIDTH-1:0]    mcb1_dram_a;
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
   wire                             mcb1_dram_odt;

   wire                             mcb1_dram_udqs;    // for X16 parts
   wire                             mcb1_dram_udqs_n;  // for X16 parts
   wire                             mcb1_dram_udm;     // for X16 parts

// Error & Calib Signals
   wire                             error;
   wire                             calib_done;
   wire				    rzq1;
        wire				    zio1;
     
   
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



   

   
   // The PULLDOWN component is connected to the ZIO signal primarily to avoid the
// unknown state in simulation. In real hardware, ZIO should be a no connect(NC) pin.
   PULLDOWN zio_pulldown1 (.O(zio1));   PULLDOWN rzq_pulldown1 (.O(rzq1));
   

// ========================================================================== //
// DESIGN TOP INSTANTIATION                                                    //
// ========================================================================== //



example_top #(

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

.C1_HW_TESTING         (C1_HW_TESTING),
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
    .calib_done                               (calib_done),
  .error                                    (error),	
  .mcb1_dram_dqs_n        (mcb1_dram_dqs_n),
  .mcb1_dram_udqs         (mcb1_dram_udqs),    // for X16 parts                        
  .mcb1_dram_udqs_n       (mcb1_dram_udqs_n),  // for X16 parts
  .mcb1_dram_udm          (mcb1_dram_udm),     // for X16 parts
  .mcb1_dram_dm           (mcb1_dram_dm),
     .mcb1_rzq               (rzq1),
               
     .mcb1_zio               (zio1),
               
  .mcb1_dram_dqs          (mcb1_dram_dqs)
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
