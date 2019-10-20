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
//  \   \         Application: MIG
//  /   /         Filename: wr_data_gen.v
// /___/   /\     Date Last Modified: 
// \   \  /  \    Date Created: 
//  \___\/\___\
//
//Device: Spartan6
//Design Name: DDR/DDR2/DDR3/LPDDR 
//Purpose:
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ps/1ps

module wr_data_gen #
 
(  
   parameter TCQ           = 100,  
   parameter FAMILY = "SPARTAN6", // "SPARTAN6", "VIRTEX6"
   parameter MEM_BURST_LEN = 8,

   parameter MODE  = "WR", //"WR", "RD"
   parameter ADDR_WIDTH = 32,
   parameter BL_WIDTH = 6,
   parameter DWIDTH = 32,
   parameter DATA_PATTERN = "DGEN_PRBS", //"DGEN__HAMMER", "DGEN_WALING1","DGEN_WALING0","DGEN_ADDR","DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"  
   parameter NUM_DQ_PINS   = 8,
   parameter SEL_VICTIM_LINE = 3,  // VICTIM LINE is one of the DQ pins is selected to be different than hammer pattern
   
   parameter COLUMN_WIDTH = 10,
   parameter EYE_TEST   = "FALSE"
   
 )
 (
   input   clk_i,                 //
   input [4:0]  rst_i, 
   input [31:0] prbs_fseed_i,
   
   input [3:0]  data_mode_i,   // "00" = bram; 
   
   output  cmd_rdy_o,             // ready to receive command. It should assert when data_port is ready at the                                        // beginning and will be deasserted once see the cmd_valid_i is asserted. 
                                  // And then it should reasserted when 
                                  // it is generating the last_word.
   input   cmd_valid_i,           // when both cmd_valid_i and cmd_rdy_o is high, the command  is valid.
   input   cmd_validB_i, 
   input   cmd_validC_i, 
   
   output  last_word_o,   
   
 //  input [5:0] port_data_counts_i,// connect to data port fifo counts
//   input [ADDR_WIDTH-1:0] m_addr_i,
   input [DWIDTH-1:0] fixed_data_i,   

   input [ADDR_WIDTH-1:0] addr_i, // generated address used to determine data pattern.
   input [BL_WIDTH-1:0]   bl_i,   // generated burst length for control the burst data
   
   input   data_rdy_i,          // connect from mcb_wr_full when used as wr_data_gen
                                 // connect from mcb_rd_empty when used as rd_data_gen
                                 // When both data_rdy and data_valid is asserted, the ouput data is valid.
   output    data_valid_o,        // connect to wr_en or rd_en and is asserted whenever the 
                                 // pattern is available.
   output  [DWIDTH-1:0] data_o, // generated data pattern   
   output  reg          data_wr_end_o
   
   
);  
// 


reg [DWIDTH-1:0] data;



(*EQUIVALENT_REGISTER_REMOVAL="NO"*) reg   cmd_rdy,cmd_rdyB, cmd_rdyC,cmd_rdyD,cmd_rdyE,cmd_rdyF;
(*EQUIVALENT_REGISTER_REMOVAL="NO"*) reg   cmd_start,cmd_startB,cmd_startC,cmd_startD,cmd_startE,cmd_startF;




reg burst_count_reached2;

reg               data_valid;
reg [6:0]user_burst_cnt;
reg [2:0] walk_cnt;

wire fifo_not_full;
integer i,j;
reg [31:0] w3data;

assign fifo_not_full = data_rdy_i;

always @( posedge clk_i)
begin
if ((user_burst_cnt == 2 || (cmd_start && bl_i == 1 && FAMILY == "VIRTEX6")) && (fifo_not_full))
    data_wr_end_o <= #TCQ  1'b1;
else
    data_wr_end_o <= #TCQ  1'b0;
end

always @ (posedge clk_i)
begin
cmd_start  <= #TCQ  cmd_validC_i & cmd_rdyC ;
cmd_startB <= #TCQ  cmd_valid_i & cmd_rdyB;
cmd_startC <= #TCQ  cmd_validB_i & cmd_rdyC;
cmd_startD <= #TCQ  cmd_validB_i & cmd_rdyD;  
cmd_startE <= #TCQ  cmd_validB_i & cmd_rdyE;  
cmd_startF <= #TCQ  cmd_validB_i & cmd_rdyF;  
end


// counter to count user burst length
always @( posedge clk_i)
begin
  if ( rst_i[0] )
    user_burst_cnt <= #TCQ 'd0;
  else if(cmd_start) 
    if (FAMILY == "SPARTAN6") begin
       if (bl_i == 6'b000000)
          user_burst_cnt <= #TCQ 7'b1000000;
       else
     user_burst_cnt <= #TCQ bl_i;
       
       end
        else
     user_burst_cnt <= #TCQ bl_i;
  else if(fifo_not_full) 
     if (user_burst_cnt != 6'd0)
       user_burst_cnt <= #TCQ user_burst_cnt - 1'b1;
     else
        user_burst_cnt <=#TCQ 'd0;
        
end

reg u_bcount_2;
wire last_word_t;
always @ (posedge clk_i)
begin
if ((user_burst_cnt == 2  && fifo_not_full )|| (cmd_startC && bl_i == 1))
    u_bcount_2 <= #TCQ 1'b1;
else if (last_word_o)
    u_bcount_2 <= #TCQ 1'b0;
end    



assign  last_word_o = u_bcount_2 & fifo_not_full;

// cmd_rdy_o assert when the dat fifo is not full and deassert once cmd_valid_i
// is assert and reassert during the last data

assign cmd_rdy_o = cmd_rdy & fifo_not_full;


always @( posedge clk_i)
begin
  if ( rst_i[0] )
    cmd_rdy <= #TCQ 1'b1;
  else if (cmd_start)
     if (bl_i == 1)
        cmd_rdy <= #TCQ 1'b1;
     else
       cmd_rdy <= #TCQ 1'b0;
  else if  ((user_burst_cnt == 6'd2 && fifo_not_full ) )

      cmd_rdy <= #TCQ 1'b1;
  

end

always @( posedge clk_i)
begin
  if ( rst_i [0])
    cmd_rdyB <= #TCQ 1'b1;
  else if (cmd_startB)
     if (bl_i == 1)
        cmd_rdyB <= #TCQ 1'b1;
     else
       cmd_rdyB <= #TCQ 1'b0;
  else if  ((user_burst_cnt == 6'd2 && fifo_not_full ) )


      cmd_rdyB <= #TCQ 1'b1;
  

end

always @( posedge clk_i)
begin
  if ( rst_i[0] )
    cmd_rdyC <= #TCQ 1'b1;
  else if (cmd_startC)
     if (bl_i == 1)
        cmd_rdyC <= #TCQ 1'b1;
     else
       cmd_rdyC <= #TCQ 1'b0;
  else if  ((user_burst_cnt == 6'd2 && fifo_not_full ) )


      cmd_rdyC <= #TCQ 1'b1;
  

end

always @( posedge clk_i)
begin
  if ( rst_i[0] )
    cmd_rdyD <= #TCQ 1'b1;
  else if (cmd_startD)
     if (bl_i == 1)
        cmd_rdyD <= #TCQ  1'b1;
     else
       cmd_rdyD <= #TCQ 1'b0;
  else if  ((user_burst_cnt == 6'd2 && fifo_not_full ) ) 


      cmd_rdyD <= #TCQ 1'b1;
  

end

always @( posedge clk_i)
begin
  if ( rst_i[0] )
    cmd_rdyE <= #TCQ 1'b1;
  else if (cmd_startE)
     if (bl_i == 1)
        cmd_rdyE <= #TCQ 1'b1;
     else
       cmd_rdyE <= #TCQ 1'b0;
  else if  ((user_burst_cnt == 6'd2 && fifo_not_full ) ) 


      cmd_rdyE <= #TCQ 1'b1;
  

end



always @( posedge clk_i)
begin
  if ( rst_i[0] )
    cmd_rdyF <= #TCQ 1'b1;
  else if (cmd_startF)
     if (bl_i == 1)
        cmd_rdyF <= #TCQ 1'b1;
     else
       cmd_rdyF <= #TCQ 1'b0;
  else if  ((user_burst_cnt == 6'd2 && fifo_not_full ) )

      cmd_rdyF <= #TCQ 1'b1;
  

end



always @ (posedge clk_i)
begin
  if (rst_i[1])  
    data_valid <= #TCQ 'd0;
  else if(cmd_start) 
    data_valid <= #TCQ 1'b1;
  else if (fifo_not_full && user_burst_cnt <= 6'd1)  
    data_valid <= #TCQ 1'b0;
end

assign data_valid_o = data_valid & fifo_not_full;


generate
if (FAMILY == "SPARTAN6")  begin : SP6_WDGEN

sp6_data_gen #
 
( 
   .TCQ             (TCQ),
   .ADDR_WIDTH      (32 ),
   
   .BL_WIDTH        (BL_WIDTH       ),
   .DWIDTH          (DWIDTH       ),
   .DATA_PATTERN    (DATA_PATTERN  ),
   .NUM_DQ_PINS      (NUM_DQ_PINS  ),
   .COLUMN_WIDTH     (COLUMN_WIDTH)
   
 )
 sp6_data_gen
 (
   .clk_i              (clk_i         ),        
   .rst_i              (rst_i[1]         ), 
   .data_rdy_i         (data_rdy_i    ),
   .prbs_fseed_i       (prbs_fseed_i),
   
   .data_mode_i        (data_mode_i   ),  
   .cmd_startA         (cmd_start    ),  
   .cmd_startB         (cmd_startB    ),   
   .cmd_startC         (cmd_startC    ),   
   .cmd_startD         (cmd_startD    ),   
   .cmd_startE         (cmd_startE    ),   
   .fixed_data_i         (fixed_data_i),
   
   .addr_i             (addr_i        ),       
   .user_burst_cnt     (user_burst_cnt),
   .fifo_rdy_i         (fifo_not_full    ),   
   .data_o             (data_o        )  
  );
end


endgenerate

generate
if (FAMILY ==  "VIRTEX6")  begin : V6_WDGEN

v6_data_gen #                                 
 
(  
   .TCQ               (TCQ),
   .ADDR_WIDTH      (32 ),
   .BL_WIDTH        (BL_WIDTH       ),
   .DWIDTH          (DWIDTH       ),
   .MEM_BURST_LEN     (MEM_BURST_LEN),
   
   .DATA_PATTERN    (DATA_PATTERN  ),
   .NUM_DQ_PINS      (NUM_DQ_PINS  ),
   .SEL_VICTIM_LINE   (SEL_VICTIM_LINE),
   
   .COLUMN_WIDTH     (COLUMN_WIDTH),
    .EYE_TEST   (EYE_TEST)
   
 )                 
 v6_data_gen
 (
   .clk_i              (clk_i         ),        
   .rst_i              (rst_i[1]      ),
   .data_rdy_i         (data_rdy_i    ),
   .prbs_fseed_i       (prbs_fseed_i),
   
   .data_mode_i        (data_mode_i   ),  
   .cmd_startA         (cmd_start    ),  
   .cmd_startB         (cmd_startB    ),   
   .cmd_startC         (cmd_startC    ),   
   .cmd_startD         (cmd_startD    ),   
   .cmd_startE         (cmd_startE    ),   
   .m_addr_i           (addr_i/*m_addr_i*/),          
   .fixed_data_i         (fixed_data_i),

   .addr_i             (addr_i        ),       
   .user_burst_cnt     (user_burst_cnt),
   .fifo_rdy_i         (fifo_not_full    ),   
   .data_o             (data_o        )
  );
end
endgenerate

 
endmodule 
