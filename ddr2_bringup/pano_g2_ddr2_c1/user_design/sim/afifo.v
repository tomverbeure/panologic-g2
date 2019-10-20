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
//  /   /         Filename: afifo.v
// /___/   /\     Date Last Modified: $Date: 2011/06/02 07:16:32 $
// \   \  /  \    Date Created: Oct 21 2008
//  \___\/\___\
//
//Device: Spartan6
//Design Name: DDR/DDR2/DDR3/LPDDR 
//Purpose:  A generic synchronous fifo.
//Reference:
//Revision History:

//*****************************************************************************

`timescale 1ps/1ps

module afifo #
(
 parameter TCQ           = 100,
 parameter DSIZE = 32,
 parameter FIFO_DEPTH = 16,
 parameter ASIZE = 4,
 parameter SYNC = 1   // only has always '1' logic.
)
(
input              wr_clk, 
input              rst,
input              wr_en,
input [DSIZE-1:0]  wr_data,
input              rd_en, 
input              rd_clk, 
output [DSIZE-1:0] rd_data,
output reg         full,
output reg         empty,
output reg         almost_full
);

// memory array
reg [DSIZE-1:0] mem [0:FIFO_DEPTH-1];

//Read Capture Logic
// if Sync = 1, then no need to remove metastability logic because wrclk = rdclk
reg [ASIZE:0] rd_gray_nxt;
reg [ASIZE:0]    rd_gray;
reg [ASIZE:0]    rd_capture_ptr;
reg [ASIZE:0]    pre_rd_capture_gray_ptr;
reg [ASIZE:0]    rd_capture_gray_ptr;
reg [ASIZE:0]    wr_gray;
reg [ASIZE:0] wr_gray_nxt;

reg [ASIZE:0] wr_capture_ptr;
reg [ASIZE:0] pre_wr_capture_gray_ptr;
reg [ASIZE:0] wr_capture_gray_ptr;
wire [ASIZE:0] buf_avail;
wire [ASIZE:0] buf_filled;
wire [ASIZE-1:0] wr_addr, rd_addr;

reg [ASIZE:0]   wr_ptr, rd_ptr;
integer i,j,k;


// for design that use the same clock for both read and write
generate
if (SYNC == 1) begin: RDSYNC
   always @ (rd_ptr)
     rd_capture_ptr = rd_ptr;
end
endgenerate



//capture the wr_gray_pointers to rd_clk domains and convert the gray pointers to binary pointers 
// before do comparison.


  
// if Sync = 1, then no need to remove metastability logic because wrclk = rdclk
generate
if (SYNC == 1) begin: WRSYNC
always @ (wr_ptr)
    wr_capture_ptr = wr_ptr;
end
endgenerate

// dualport ram 
// Memory (RAM) that holds the contents of the FIFO


assign wr_addr = wr_ptr;
assign rd_data = mem[rd_addr];
always @(posedge wr_clk)
begin
if (wr_en && !full)
  mem[wr_addr] <= #TCQ wr_data;

end


// Read Side Logic


assign rd_addr = rd_ptr[ASIZE-1:0];
assign rd_strobe = rd_en && !empty;

integer n;
reg [ASIZE:0] rd_ptr_tmp;
    // change the binary pointer to gray pointer
always @ (rd_ptr)
begin
//  rd_gray_nxt[ASIZE] = rd_ptr_tmp[ASIZE];
//  for (n=0; n < ASIZE; n=n+1) 
//       rd_gray_nxt[n] = rd_ptr_tmp[n] ^ rd_ptr_tmp[n+1];

  rd_gray_nxt[ASIZE] = rd_ptr[ASIZE];
  for (n=0; n < ASIZE; n=n+1) 
       rd_gray_nxt[n] = rd_ptr[n] ^ rd_ptr[n+1];

    
    
end       


always @(posedge rd_clk)
begin
if (rst)
   begin
        rd_ptr <= #TCQ 'b0;
        rd_gray <= #TCQ 'b0;
   end
else begin
    if (rd_strobe)
        rd_ptr <= #TCQ rd_ptr + 1;
        
    rd_ptr_tmp <= #TCQ rd_ptr;
        
    // change the binary pointer to gray pointer
    rd_gray <= #TCQ rd_gray_nxt;
end

end

//generate empty signal
assign buf_filled = wr_capture_ptr - rd_ptr;
               
always @ (posedge rd_clk )
begin
   if (rst)
        empty <= #TCQ 1'b1;
   else if ((buf_filled == 0) || (buf_filled == 1 && rd_strobe))
        empty <= #TCQ 1'b1;
   else
        empty <= #TCQ 1'b0;
end        


// write side logic;

reg [ASIZE:0] wbin;
wire [ASIZE:0] wgraynext, wbinnext;



always @(posedge rd_clk)
begin
if (rst)
   begin
        wr_ptr <= #TCQ 'b0;
        wr_gray <= #TCQ 'b0;
   end
else begin
    if (wr_en)
        wr_ptr <= #TCQ wr_ptr + 1;
        
    // change the binary pointer to gray pointer
    wr_gray <= #TCQ wr_gray_nxt;
end

end


// change the write pointer to gray pointer
always @ (wr_ptr)
begin
    wr_gray_nxt[ASIZE] = wr_ptr[ASIZE];
    for (n=0; n < ASIZE; n=n+1)
       wr_gray_nxt[n] = wr_ptr[n] ^ wr_ptr[n+1];
end       
// calculate how many buf still available
assign buf_avail = (rd_capture_ptr + FIFO_DEPTH) - wr_ptr;

always @ (posedge wr_clk )
begin
   if (rst) 
        full <= #TCQ 1'b0;
   else if ((buf_avail == 0) || (buf_avail == 1 && wr_en))
        full <= #TCQ 1'b1;
   else
        full <= #TCQ 1'b0;
end        


always @ (posedge wr_clk )
begin
   if (rst) 
        almost_full <= #TCQ 1'b0;
   else if ((buf_avail == FIFO_DEPTH - 2 ) || ((buf_avail == FIFO_DEPTH -3) && wr_en))
        almost_full <= #TCQ 1'b1;
   else
        almost_full <= #TCQ 1'b0;
end        

endmodule


