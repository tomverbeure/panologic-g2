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
//  /   /         Filename: read_posted_fifo.v
// /___/   /\     Date Last Modified: 
// \   \  /  \    Date Created: 
//  \___\/\___\
//
//Device: Spartan6
//Design Name: DDR/DDR2/DDR3/LPDDR 
//Purpose: This module instantiated by read_data_path module and sits between 
//         mcb_flow_control module and read_data_gen module to buffer up the 
//         commands that has sent to memory controller.
//Reference:
//Revision History:
//                  2010/01/09/   Corrected dfifo_has_enough_room threshold logic.
//                                It has to set higher in Read Only port.
//*****************************************************************************
`timescale 1ps/1ps
   
  module read_posted_fifo #
  (
   parameter TCQ           = 100,  
   parameter FAMILY     = "SPARTAN6",  
   parameter MEM_BURST_LEN = 4,

   parameter ADDR_WIDTH = 32,
   parameter BL_WIDTH = 6
  )
  (
   input                   clk_i, 
   input                   rst_i,
   output reg                 cmd_rdy_o, 
   input                   cmd_valid_i, 
   input                   data_valid_i,
   input [ADDR_WIDTH-1:0]  addr_i, 
   input [BL_WIDTH-1:0]    bl_i,
   input                   user_bl_cnt_is_1,
   input [2:0]           cmd_sent, 
   input [5:0]           bl_sent  ,
   input                 cmd_en_i ,
   
   
   input                   gen_rdy_i, 
   output                  gen_valid_o, 
   output [ADDR_WIDTH-1:0] gen_addr_o, 
   output [BL_WIDTH-1:0]   gen_bl_o,
   output [6:0]           rd_buff_avail_o,
   input                   rd_mdata_fifo_empty,
   output                  rd_mdata_en

   ); 
  
reg empty_r;
reg rd_first_data;
  
   wire full;
   wire empty;
   wire wr_en;
   reg rd_en;
   reg data_valid_r;
   reg user_bl_cnt_not_1;
    reg [6:0] buf_avail_r;
    reg [6:0] rd_data_received_counts;
    reg [6:0] rd_data_counts_asked;
    
      reg dfifo_has_enough_room;
    reg [1:0] wait_cnt;
    reg wait_done;

  assign rd_mdata_en = rd_en;

   assign rd_buff_avail_o = buf_avail_r;
   always @ (posedge clk_i)
       cmd_rdy_o <= #TCQ !full  & dfifo_has_enough_room & wait_done;

   always @ (posedge clk_i)
   begin
   if (rst_i)
       wait_cnt <= #TCQ 'b0;
   else if (cmd_rdy_o && cmd_valid_i)
       wait_cnt <= #TCQ 2'b10;
   else if (wait_cnt > 0)
         wait_cnt <= #TCQ wait_cnt - 1;
       
   end
   
   always @(posedge clk_i)
   begin
   if (rst_i)
      wait_done <= #TCQ 1'b1;
   else if (cmd_rdy_o && cmd_valid_i)
      wait_done <= #TCQ 1'b0;
   else if (wait_cnt == 0)
      wait_done <= #TCQ 1'b1;
   else
      wait_done <= #TCQ 1'b0;
   
   end
   
   reg dfifo_has_enough_room_d1;
   always @ (posedge clk_i)
   begin // prbs_blen from cmd_gen is random, it can be two 64 in consecutive
         // the logic here to prevent cmd_gen send any further read command if
         // any large bl command has been sent.
         
       dfifo_has_enough_room <= #TCQ (buf_avail_r >= 62  ) ? 1'b1: 1'b0;

       dfifo_has_enough_room_d1 <= #TCQ dfifo_has_enough_room ;
   end
   
   
   assign wr_en    = cmd_valid_i & !full  & dfifo_has_enough_room_d1 & wait_done;

   
   always @ (posedge clk_i)
       data_valid_r <= #TCQ data_valid_i;
  
  
  always @ (posedge clk_i)
  begin
  if (data_valid_i && user_bl_cnt_is_1)  // current count is 1 and data_is_valie, then next cycle is not 1
     user_bl_cnt_not_1 <= #TCQ 1'b1;
  else     
     user_bl_cnt_not_1 <= #TCQ 1'b0;
  end  
 
 always @ (posedge clk_i)
 begin
 if (rst_i) begin
    rd_data_counts_asked <= #TCQ 'b0;
    end
 else if (cmd_en_i && cmd_sent[0] == 1) begin

    rd_data_counts_asked <= #TCQ rd_data_counts_asked + (bl_sent + 7'b0000001) ;

    end
 end

 always @ (posedge clk_i)
 begin
 if (rst_i) begin
     rd_data_received_counts <= #TCQ 'b0;
     end
 else if (data_valid_i) begin
     rd_data_received_counts <= #TCQ rd_data_received_counts + 1;
     end     
 end
 
 // calculate how many buf still available
 always @ (posedge clk_i)
                  // MCB FIFO size is 64.
                  // buf_available is calculated by:
                  // FIFO DEPTH - ( Write Poitner - Read Pointer)
     buf_avail_r <= #TCQ 64 - (rd_data_counts_asked - rd_data_received_counts);
 
 
   
   always @(gen_rdy_i, empty,empty_r,rd_mdata_fifo_empty,rd_first_data ,data_valid_i,data_valid_r,user_bl_cnt_not_1)
   begin
        if (FAMILY == "SPARTAN6")
            rd_en = gen_rdy_i & !empty;
        else 
             if ( MEM_BURST_LEN == 4)
                   rd_en = (~empty & empty_r & ~rd_first_data) | (~rd_mdata_fifo_empty & ~empty ) | (user_bl_cnt_not_1 & data_valid_i);
             else
                   rd_en = (data_valid_i & ~data_valid_r) | (user_bl_cnt_not_1 & data_valid_i);
   
        end
   
   always @ (posedge clk_i)
        empty_r <= #TCQ empty;
        
   always @ (posedge clk_i)
   begin 
   if (rst_i)
       rd_first_data <= #TCQ 1'b0;
   else if (~empty && empty_r)
       rd_first_data <= #TCQ 1'b1;
   end   

       
   
   assign gen_valid_o = !empty;
   afifo #
   (
    .TCQ               (TCQ),
    .DSIZE         (BL_WIDTH+ADDR_WIDTH),
    .FIFO_DEPTH    (16),
    .ASIZE         (4),
    .SYNC          (1)  // set the SYNC to 1 because rd_clk = wr_clk to reduce latency 
   
   
   )
   rd_fifo
   (
    .wr_clk        (clk_i),
    .rst           (rst_i),
    .wr_en         (wr_en),
    .wr_data       ({bl_i,addr_i}),
    .rd_en         (rd_en),
    .rd_clk        (clk_i),
    .rd_data       ({gen_bl_o,gen_addr_o}),
    .full          (full),
    .empty         (empty),
    .almost_full   ()
   
   );
   
   
   
   
   
endmodule 
