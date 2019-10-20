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
//  /   /         Filename: data_gen.v
// /___/   /\     Date Last Modified: 
// \   \  /  \    Date Created: 
//  \___\/\___\
//
//Device: Spartan6
//Design Name: DDR/DDR2/DDR3/LPDDR 
//Purpose: This module generates different data pattern as described in 
//         parameter DATA_PATTERN and is set up for Spartan 6 family.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ps/1ps

module sp6_data_gen #
 
( 
   parameter TCQ           = 100,  
   parameter ADDR_WIDTH = 32,
   parameter BL_WIDTH = 6,
   parameter DWIDTH = 32,
   parameter DATA_PATTERN = "DGEN_ALL", //"DGEN__HAMMER", "DGEN_WALING1","DGEN_WALING0","DGEN_ADDR","DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"  
   parameter NUM_DQ_PINS   = 8,
   parameter COLUMN_WIDTH = 10
   
 )
 (
   input   clk_i,                 //
   input   rst_i, 
   input [31:0] prbs_fseed_i,
   
   input [3:0]  data_mode_i,   // "00" = bram; 
   input        data_rdy_i,
   input   cmd_startA,  
   input   cmd_startB,         
   input   cmd_startC,         
   input   cmd_startD,         
   input   cmd_startE,         
   input [DWIDTH-1:0]     fixed_data_i,    

   input [ADDR_WIDTH-1:0]  addr_i,          // generated address used to determine data pattern.
   input [6:0]    user_burst_cnt,   // generated burst length for control the burst data
   
   input   fifo_rdy_i,           // connect from mcb_wr_full when used as wr_data_gen
                                 // connect from mcb_rd_empty when used as rd_data_gen
                                 // When both data_rdy and data_valid is asserted, the ouput data is valid.
   output  [DWIDTH-1:0] data_o   // generated data pattern   
);  
// 
wire [31:0]       prbs_data; 

reg [31:0]         adata; 
reg [DWIDTH-1:0]   hdata; 
reg [DWIDTH-1:0]   ndata; 
reg [DWIDTH - 1:0] w1data; 
reg [DWIDTH-1:0] data;
reg burst_count_reached2;

reg               data_valid;
reg [2:0] walk_cnt;
reg [ADDR_WIDTH-1:0] user_address;


integer i,j;
reg [BL_WIDTH-1:0] user_bl;
reg [7:0] BLANK;

reg [7:0] SHIFT_0;
reg [7:0] SHIFT_1;
reg [7:0] SHIFT_2;
reg [7:0] SHIFT_3;
reg [7:0] SHIFT_4;
reg [7:0] SHIFT_5;
reg [7:0] SHIFT_6;
reg [7:0] SHIFT_7;
reg [31:0] SHIFTB_0 ; 
reg [31:0] SHIFTB_1;
reg [31:0] SHIFTB_2;
reg [31:0] SHIFTB_3;
reg [31:0] SHIFTB_4;
reg [31:0] SHIFTB_5;
reg [31:0] SHIFTB_6;
reg [31:0] SHIFTB_7;
reg [3:0] TSTB;
//*********************************************************************************************





assign data_o = data;

generate 

if (DWIDTH==32) begin: data_out32
always @ (adata,hdata,ndata,w1data,prbs_data,data_mode_i,fixed_data_i)
begin
   case(data_mode_i)
       //  4'b0000: data = 32'b0;       //reserved
         4'b0001: data = fixed_data_i;       // fixed
         4'b0010: data = adata;  // address as data
         4'b0011: data = hdata;  // DGEN_HAMMER
         4'b0100: data = ndata;  // DGEN_NEIGHBOUR
         4'b0101: data = w1data; // DGEN_WALKING1
         4'b0110: data = w1data; // DGEN_WALKING0
         4'b0111: data = prbs_data;
         default : data = 'b0;
   endcase
end        
end

endgenerate

generate 
if (DWIDTH==64) begin: data_out64
always @ (adata,hdata,ndata,w1data,prbs_data,data_mode_i,fixed_data_i)
begin
   case(data_mode_i) 
         4'b0000: data = 'b0;                 //reserved
         4'b0001: data = fixed_data_i;                 // fixed
         4'b0010: data = {adata,adata};       // address as data
         4'b0011: data = hdata;       // DGEN_HAMMER
         4'b0100: data = ndata;       // DGEN_NEIGHBOUR
         4'b0101: data = w1data;     // DGEN_WALKING1
         4'b0110: data = w1data;     // DGEN_WALKING0
         4'b0111: data = {prbs_data,prbs_data};
         default : data = 'b0;
   endcase
end        
end
endgenerate

generate 
if (DWIDTH==128) begin: data_out128
always @ (adata,hdata,ndata,w1data,prbs_data,data_mode_i,fixed_data_i)
begin
   case(data_mode_i)
         4'b0000: data = 'b0;       //reserved
         4'b0001: data = fixed_data_i;       // fixed
         4'b0010: data = {adata,adata,adata,adata};       // address as data
         4'b0011: data = hdata;       // DGEN_HAMMER
         4'b0100: data = ndata;       // DGEN_NEIGHBOUR
         4'b0101: data = w1data;   // DGEN_WALKING1
         4'b0110: data = w1data;   // DGEN_WALKING0
         4'b0111: data = {prbs_data,prbs_data,prbs_data,prbs_data};
         default : data = 'b0;
   endcase
end        
end
endgenerate


// WALKING ONES:

generate
if ((DWIDTH == 64) ||(DWIDTH == 128))  begin: SHIFT_VALUE
   
always @ (data_mode_i) begin
  if (data_mode_i == 3'b101 || data_mode_i == 3'b100) begin // WALKING ONE
    BLANK   = 8'h00;
    SHIFT_0 = 8'h01;
    SHIFT_1 = 8'h02;    
    SHIFT_2 = 8'h04;    
    SHIFT_3 = 8'h08;    
    SHIFT_4 = 8'h10;    
    SHIFT_5 = 8'h20;    
    SHIFT_6 = 8'h40;    
    SHIFT_7 = 8'h80;    
    
    end
    else if (data_mode_i == 3'b100)begin // NEIGHBOR ONE
    BLANK   = 8'h00;
    SHIFT_0 = 8'h01;
    SHIFT_1 = 8'h02;    
    SHIFT_2 = 8'h04;    
    SHIFT_3 = 8'h08;    
    SHIFT_4 = 8'h10;    
    SHIFT_5 = 8'h20;    
    SHIFT_6 = 8'h40;    
    SHIFT_7 = 8'h80;    
    end       
    


    else if (data_mode_i == 3'b110) begin  // WALKING ZERO
    BLANK   = 8'hff;
    SHIFT_0 = 8'hfe;
    SHIFT_1 = 8'hfd;    
    SHIFT_2 = 8'hfb;    
    SHIFT_3 = 8'hf7;    
    SHIFT_4 = 8'hef;    
    SHIFT_5 = 8'hdf;    
    SHIFT_6 = 8'hbf;    
    SHIFT_7 = 8'h7f;    
    end   
    else begin
    BLANK   = 8'hff;
    SHIFT_0 = 8'hfe;
    SHIFT_1 = 8'hfd;    
    SHIFT_2 = 8'hfb;    
    SHIFT_3 = 8'hf7;    
    SHIFT_4 = 8'hef;    
    SHIFT_5 = 8'hdf;    
    SHIFT_6 = 8'hbf;    
    SHIFT_7 = 8'h7f;    
    end   

end
end
endgenerate

always @ (data_mode_i) begin

if (data_mode_i == 3'b101 ) begin // WALKING ONE
   
    SHIFTB_0 = 32'h0002_0001;
    SHIFTB_1 = 32'h0008_0004;    
    SHIFTB_2 = 32'h0020_0010;    
    SHIFTB_3 = 32'h0080_0040;    
    SHIFTB_4 = 32'h0200_0100;    
    SHIFTB_5 = 32'h0800_0400;    
    SHIFTB_6 = 32'h2000_1000;    
    SHIFTB_7 = 32'h8000_4000;    
    end
else if (data_mode_i == 3'b100)begin // NEIGHBOR ONE
   
    SHIFTB_0 = 32'h0000_0001;
    SHIFTB_1 = 32'h0000_0002;    
    SHIFTB_2 = 32'h0000_0004;    
    SHIFTB_3 = 32'h0000_0008;    
    SHIFTB_4 = 32'h0000_0010;    
    SHIFTB_5 = 32'h0000_0020;    
    SHIFTB_6 = 32'h0000_0040;    
    SHIFTB_7 = 32'h0000_0080;    
    end    
    
else begin  // WALKING ZERO
    SHIFTB_0 = 32'hfffd_fffe;
    SHIFTB_1 = 32'hfff7_fffb;    
    SHIFTB_2 = 32'hffdf_ffef;    
    SHIFTB_3 = 32'hff7f_ffbf;    
    SHIFTB_4 = 32'hfdff_feff;    
    SHIFTB_5 = 32'hf7ff_fbff;    
    SHIFTB_6 = 32'hdfff_efff;    
    SHIFTB_7 = 32'h7fff_bfff;    
    end

end





reg [DWIDTH-1:0] tmpdata ;
reg ndata_rising;
reg shift_en;
generate
if (DWIDTH == 32 && (DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_WALKING1" ||
    DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_32_PATTERN

  always @ (posedge clk_i)
  begin
   if (rst_i) begin
        w1data <= #TCQ  'b0;
        ndata_rising <= #TCQ  1'b1;
        shift_en <= #TCQ  1'b0;
        end
   else if((fifo_rdy_i && user_burst_cnt != 6'd0) || cmd_startC )
      if (NUM_DQ_PINS == 16) 
      begin
         if(cmd_startC) 
           begin
                      case (addr_i[4:2])
                      0: w1data <= #TCQ    SHIFTB_0;
                      1: w1data <= #TCQ    SHIFTB_1;
                      2: w1data <= #TCQ    SHIFTB_2;
                      3: w1data <= #TCQ    SHIFTB_3;
                      4: w1data <= #TCQ    SHIFTB_4;
                      5: w1data <= #TCQ    SHIFTB_5;
                      6: w1data <= #TCQ    SHIFTB_6;
                      7: w1data <= #TCQ    SHIFTB_7;
                      
                      default :w1data <= #TCQ    SHIFTB_0;
                      endcase   
                      
                      ndata_rising <= #TCQ  1'b0;
           end  //(NUM_DQ_PINS == 16) (cmd_startC)  
         else //shifting
            if (data_mode_i == 3'b100) 
              w1data <= #TCQ    {16'h0000,w1data[14:0],w1data[15]};
            else
              w1data <= #TCQ    {w1data[29:16],w1data[31:30],w1data[13:0],w1data[15:14]}; 
              
              
      end  //(DQ_PINS == 16 
      else if (NUM_DQ_PINS == 8) begin
         if(cmd_startC)  // loading data pattern according the incoming address
            begin
                       case (addr_i[2])
                        0: w1data <= #TCQ    SHIFTB_0;
                        1: w1data <= #TCQ    SHIFTB_1;
                        default :w1data <= #TCQ    SHIFTB_0;
                       endcase 
            end // (cmd_startC)   
        else  // Shifting
          // need neigbour pattern ********************
                w1data <= #TCQ    {w1data[27:24],w1data[31:28],w1data[19:16],w1data[23:20],
                                w1data[11:8] ,w1data[15:12],w1data[3:0]  ,w1data[7:4]}; 
                      
      end //(NUM_DQ_PINS == 8)
      else if (NUM_DQ_PINS == 4) begin   // NUM_DQ_PINS == 4   
          // need neigbour pattern ********************      
             if (data_mode_i == 3'b100) 
               w1data <= #TCQ    32'h0804_0201;
             else
               w1data <= #TCQ    32'h8421_8421;
      end // (NUM_DQ_PINS_4    
           
  end
end
endgenerate // DWIDTH == 32

generate
if (DWIDTH == 64 && (DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_WALKING1"
    || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_64_PATTERN

  always @ (posedge clk_i)
  begin
   if (rst_i)
        w1data <= #TCQ  'b0;
   
   else if((fifo_rdy_i && user_burst_cnt != 6'd0) || cmd_startC )

    
    
      if (NUM_DQ_PINS == 16) 
      begin
         if(cmd_startC)
           begin

             case (addr_i[4:3])

             
                 0: begin 
                    //  7:0
                    w1data[2*DWIDTH/4-1:0*DWIDTH/4]    <= #TCQ    SHIFTB_0; 
                    w1data[4*DWIDTH/4-1:2*DWIDTH/4]    <= #TCQ    SHIFTB_1;
 
                    end
                 1:  begin 
                    w1data[2*DWIDTH/4-1:0*DWIDTH/4]    <= #TCQ    SHIFTB_2; 
                    w1data[4*DWIDTH/4-1:2*DWIDTH/4]    <= #TCQ    SHIFTB_3;
                    end
                    
                 2: begin 
                    w1data[2*DWIDTH/4-1:0*DWIDTH/4]    <= #TCQ    SHIFTB_4; 
                    w1data[4*DWIDTH/4-1:2*DWIDTH/4]    <= #TCQ    SHIFTB_5;
                    end
                 3:  begin 
                    w1data[2*DWIDTH/4-1:0*DWIDTH/4]    <= #TCQ    SHIFTB_6; 
                    w1data[4*DWIDTH/4-1:2*DWIDTH/4]    <= #TCQ    SHIFTB_7;
                    
                    end
                     
                    
               default :begin
                    w1data <= #TCQ  BLANK;    //15:8 
                    end
                    
             endcase         

                      
           end  //(NUM_DQ_PINS == 16) (cmd_startC)      
         else begin  //shifting
             if (data_mode_i == 3'b100) 
               begin
                 w1data[63:48] <= #TCQ    {16'h0000};
                 w1data[47:32] <= #TCQ    {w1data[45:32],w1data[47:46]};
                 w1data[31:16] <= #TCQ    {16'h0000};
                 w1data[15:0]  <= #TCQ    {w1data[13:0],w1data[15:14]};
                 
               end
            else

              w1data[DWIDTH - 1:0] <= #TCQ    {
                                          w1data[4*DWIDTH/4 - 5:4*DWIDTH/4 - 16],
                                          w1data[4*DWIDTH/4 - 1 :4*DWIDTH/4 - 4],                                                    
                                                        
                                          w1data[3*DWIDTH/4 - 5:3*DWIDTH/4 - 16],
                                          w1data[3*DWIDTH/4 - 1 :3*DWIDTH/4 - 4],                                                                                                        

                                          w1data[2*DWIDTH/4 - 5:2*DWIDTH/4 - 16],
                                          w1data[2*DWIDTH/4 - 1 :2*DWIDTH/4 - 4],
 
                                          w1data[1*DWIDTH/4 - 5:1*DWIDTH/4 - 16],
                                          w1data[1*DWIDTH/4 - 1 :1*DWIDTH/4 - 4]                                                    
                                          
                                          };   
                                                    
              
         end    
              
      end  //(DQ_PINS == 16 
      else if (NUM_DQ_PINS == 8) begin
         if(cmd_startC)  // loading data pattern according the incoming address

                 if (data_mode_i == 3'b100)  
                 
                   case (addr_i[3])
                 
                   
                       0:  w1data <= #TCQ    {
                                   BLANK,SHIFT_3,BLANK,SHIFT_2,
                                   BLANK,SHIFT_1,BLANK,SHIFT_0
                                   };                        
                         
                       1:  w1data <= #TCQ    {
                                   BLANK,SHIFT_7,BLANK,SHIFT_6,
                                   BLANK,SHIFT_5,BLANK,SHIFT_4
                                   };                        
                    
                       default :begin
                         w1data <= #TCQ    'b0;    //15:8 
                    end
                    
                    endcase         

                  else
                  w1data <= #TCQ    {32'h8040_2010,32'h0804_0201};  //**** checked
         else  // Shifting
                 if (data_mode_i == 3'b100)  
         
               begin
                 w1data[63:56] <= #TCQ    {8'h00};
                 w1data[55:48] <= #TCQ    {w1data[51:48],w1data[55:52]};
                 
                 w1data[47:40] <= #TCQ    {8'h00};                 
                 w1data[39:32] <= #TCQ    {w1data[35:32],w1data[39:36]};
                 
                 w1data[31:24] <= #TCQ    {8'h00};
                 w1data[23:16] <= #TCQ    {w1data[19:16],w1data[23:20]};
                 
                 w1data[15:8]  <= #TCQ    {8'h00};
                 w1data[7:0]  <= #TCQ    {w1data[3:0],w1data[7:4]};
                 
               end
                 else
                      w1data <= #TCQ    w1data; 
      end //(NUM_DQ_PINS == 8)
      else if (NUM_DQ_PINS == 4) // NUM_DQ_PINS == 4   
            if (data_mode_i == 3'b100)  
               w1data <= #TCQ    64'h0804_0201_0804_0201;
            else
               w1data <= #TCQ    64'h8421_8421_8421_8421; 
           
  end
end
endgenerate

generate

if (DWIDTH == 128 && (DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_128_PATTERN

  always @ (posedge clk_i)
  begin
   if (rst_i)
        w1data <= #TCQ  'b0;
   
   else if((fifo_rdy_i && user_burst_cnt != 6'd0) || cmd_startC )

    
    
      if (NUM_DQ_PINS == 16) 
      begin
         if(cmd_startC)
           begin
             case (addr_i[4])

             
                 0: begin 
                    
                    w1data[1*DWIDTH/4-1:0*DWIDTH/4]    <= #TCQ  SHIFTB_0;
                    w1data[2*DWIDTH/4-1:1*DWIDTH/4]    <= #TCQ  SHIFTB_1;   //  32                                       
                    w1data[3*DWIDTH/4-1:2*DWIDTH/4]    <= #TCQ  SHIFTB_2;                    
                    w1data[4*DWIDTH/4-1:3*DWIDTH/4]    <= #TCQ  SHIFTB_3;
                    
                    
                    end
                 1:  begin 
                 
                    w1data[1*DWIDTH/4-1:0*DWIDTH/4]    <= #TCQ  SHIFTB_4;
                    w1data[2*DWIDTH/4-1:1*DWIDTH/4]    <= #TCQ  SHIFTB_5;   //  32                                       
                    w1data[3*DWIDTH/4-1:2*DWIDTH/4]    <= #TCQ  SHIFTB_6;                    
                    w1data[4*DWIDTH/4-1:3*DWIDTH/4]    <= #TCQ  SHIFTB_7;
                 
                    end
 
              default :begin
                    w1data <= #TCQ  BLANK;    //15:8 
                    
                    end
                    
             endcase         
                      
           end  //(NUM_DQ_PINS == 16) (cmd_startC)      
         else begin  //shifting
              if (data_mode_i == 3'b100) 
               begin
                 w1data[127:112] <= #TCQ    {16'h0000};
                 w1data[111:96] <= #TCQ    {w1data[107:96],w1data[111:108]};
                 w1data[95:80] <= #TCQ    {16'h0000};
                 w1data[79:64] <= #TCQ    {w1data[75:64],w1data[79:76]};


                 w1data[63:48] <= #TCQ    {16'h0000};
                 w1data[47:32] <= #TCQ    {w1data[43:32],w1data[47:44]};
                 w1data[31:16] <= #TCQ    {16'h0000};
                 w1data[15:0] <= #TCQ    {w1data[11:0],w1data[15:12]};
                 
               end
              else begin
              w1data[DWIDTH - 1:0]             <= #TCQ  {
                                                    w1data[4*DWIDTH/4 - 9:4*DWIDTH/4 - 16],
                                                    w1data[4*DWIDTH/4 - 1 :4*DWIDTH/4 - 8],                                                    
                                                    w1data[4*DWIDTH/4 - 25:4*DWIDTH/4 -32],
                                                    w1data[4*DWIDTH/4 - 17:4*DWIDTH/4 -24], 
                                                    
                                                    w1data[3*DWIDTH/4 - 9:3*DWIDTH/4 - 16],
                                                    w1data[3*DWIDTH/4 - 1 :3*DWIDTH/4 - 8],                                                                                                        
                                                    w1data[3*DWIDTH/4 - 25:3*DWIDTH/4 - 32],
                                                    w1data[3*DWIDTH/4 - 17:3*DWIDTH/4 - 24],

                                                    w1data[2*DWIDTH/4 - 9:2*DWIDTH/4 - 16],
                                                    w1data[2*DWIDTH/4 - 1 :2*DWIDTH/4 - 8],                                                                                                        
                                                    w1data[2*DWIDTH/4 - 25:2*DWIDTH/4 - 32],
                                                    w1data[2*DWIDTH/4 - 17:2*DWIDTH/4 - 24],


                                                    w1data[1*DWIDTH/4 - 9:1*DWIDTH/4 - 16],
                                                    w1data[1*DWIDTH/4 - 1 :1*DWIDTH/4 - 8],                                                    
                                                    w1data[1*DWIDTH/4 - 25:1*DWIDTH/4 - 32],
                                                    w1data[1*DWIDTH/4 - 17 :1*DWIDTH/4 - 24]
                                                    };
             end
            
         end    
              
      end  //(DQ_PINS == 16 
      else if (NUM_DQ_PINS == 8) begin
         if(cmd_startC)  // loading data pattern according the incoming address
            begin
                        if (data_mode_i == 3'b100)  
                         w1data <= #TCQ    {
                                          BLANK,SHIFT_7,BLANK,SHIFT_6,
                                          BLANK,SHIFT_5,BLANK,SHIFT_4,
                                          BLANK,SHIFT_3,BLANK,SHIFT_2,
                                          BLANK,SHIFT_1,BLANK,SHIFT_0
                                          };                        
                        else
                       //  w1data <= #TCQ    {32'h8040_2010,32'h0804_0201,32'h8040_2010,32'h0804_0201};
                         w1data <= #TCQ    {
                                          SHIFT_7,SHIFT_6,SHIFT_5,SHIFT_4,
                                          SHIFT_3,SHIFT_2,SHIFT_1,SHIFT_0,
                                          SHIFT_7,SHIFT_6,SHIFT_5,SHIFT_4,
                                          SHIFT_3,SHIFT_2,SHIFT_1,SHIFT_0
                                          };
                                          
                                          
            end // (cmd_startC)   
        else  // Shifting
         
                 begin
               
                      w1data <= #TCQ    w1data;//{w1data[96:64], w1data[127:97],w1data[31:0], w1data[63:32]}; 
                 end // else
      end //(NUM_DQ_PINS == 8)
      else  
         if (data_mode_i == 3'b100)  
          w1data <= #TCQ    128'h0804_0201_0804_0201_0804_0201_0804_0201;       
         else
          w1data <= #TCQ    128'h8421_8421_8421_8421_8421_8421_8421_8421; 
           
  end
end
endgenerate
 
// HAMMER_PATTERN: Alternating 1s and 0s on DQ pins 
//                 => the rsing data pattern will be    32'b11111111_11111111_11111111_11111111
//                 => the falling data pattern will be  32'b00000000_00000000_00000000_00000000
generate
if ( DWIDTH == 32 &&( DATA_PATTERN == "DGEN_HAMMER" || DATA_PATTERN == "DGEN_ALL"))  begin : HAMMER_PATTERN_32
  always @ (posedge clk_i)
  begin
    if (rst_i)  
      hdata <= #TCQ    'd0;
    else if((fifo_rdy_i && user_burst_cnt != 6'd0) || cmd_startC ) begin
      if (NUM_DQ_PINS == 16)
           hdata <= #TCQ    32'h0000_FFFF;
      else if (NUM_DQ_PINS == 8)
           hdata <= #TCQ    32'h00FF_00FF;
      else if (NUM_DQ_PINS == 4)     // NUM_DQ_PINS == 4    
           hdata <= #TCQ    32'h0F0F_0F0F;
    end
  end
end
endgenerate


generate
if ( DWIDTH == 64 && (DATA_PATTERN == "DGEN_HAMMER" || DATA_PATTERN == "DGEN_ALL"))  begin : HAMMER_PATTERN_64
  always @ (posedge clk_i)
  begin
    if (rst_i)  
      hdata <= #TCQ    'd0;
    else if((fifo_rdy_i && user_burst_cnt != 6'd0) || cmd_startC )
      if (NUM_DQ_PINS == 16)
           hdata <= #TCQ    64'h0000FFFF_0000FFFF;
      else if (NUM_DQ_PINS == 8)
           hdata <= #TCQ    64'h00FF00FF_00FF00FF;
      else if (NUM_DQ_PINS == 4)     // NUM_DQ_PINS == 4    
           hdata <= #TCQ    64'h0F0F_0F0F_0F0F_0F0F;
    
  end
end
endgenerate


generate
if ( DWIDTH == 128 && (DATA_PATTERN == "DGEN_HAMMER" || DATA_PATTERN == "DGEN_ALL"))  begin : HAMMER_PATTERN_128
  always @ (posedge clk_i)
  begin
    if (rst_i)  
      hdata <= #TCQ    'd0;
    else if((fifo_rdy_i && user_burst_cnt != 6'd0) || cmd_startC )
      if (NUM_DQ_PINS == 16)
           hdata <= #TCQ    128'h0000FFFF_0000FFFF_0000FFFF_0000FFFF;
      else if (NUM_DQ_PINS == 8)
           hdata <= #TCQ    128'h00FF00FF_00FF00FF_00FF00FF_00FF00FF;        
      else if (NUM_DQ_PINS == 4)     // NUM_DQ_PINS == 4    
           hdata <= #TCQ    128'h0F0F_0F0F_0F0F_0F0F_0F0F_0F0F_0F0F_0F0F;        
    
  end
end
endgenerate


always @ (w1data,hdata)
begin
for (i=0; i <= DWIDTH - 1; i= i+1)
   ndata[i] = hdata[i] ^ w1data[i];
   
         end




// HAMMER_PATTERN_MINUS: generate walking HAMMER  data pattern except 1 bit for the whole burst. The incoming addr_i[5:2] determine 
// the position of the pin driving oppsite polarity
//  addr_i[6:2] = 5'h0f ; 32 bit data port
//                 => the rsing data pattern will be    32'b11111111_11111111_01111111_11111111
//                 => the falling data pattern will be  32'b00000000_00000000_00000000_00000000

// ADDRESS_PATTERN: use the address as the 1st data pattern for the whole burst. For example
// Dataport 32 bit width with starting addr_i  = 30'h12345678, user burst length 4
//                 => the 1st data pattern :     32'h12345678
//                 => the 2nd data pattern :     32'h12345679
//                 => the 3rd data pattern :     32'h1234567a
//                 => the 4th data pattern :     32'h1234567b
generate

//data_rdy_i

if (DATA_PATTERN == "DGEN_ADDR"  || DATA_PATTERN == "DGEN_ALL")  begin : ADDRESS_PATTERN
//data_o logic
always @ (posedge clk_i)
begin
  if (cmd_startD) 
    adata <= #TCQ    addr_i;
  else if(fifo_rdy_i && data_rdy_i && user_burst_cnt > 6'd1) 
         if (DWIDTH == 128)
                 adata <= #TCQ    adata + 16;
         else if (DWIDTH == 64)
                 adata <= #TCQ    adata + 8;
         else     // DWIDTH == 32   
                 adata <= #TCQ    adata + 4;
end
end
endgenerate
 
 
// PRBS_PATTERN: use the address as the PRBS seed data pattern for the whole burst. For example
// Dataport 32 bit width with starting addr_i = 30'h12345678, user burst length 4
//                

generate
if (DATA_PATTERN == "DGEN_PRBS"  || DATA_PATTERN == "DGEN_ALL")  begin : PRBS_PATTERN
       
//   PRBS DATA GENERATION
// xor all the tap positions before feedback to 1st stage.



assign data_clk_en = fifo_rdy_i && data_rdy_i && user_burst_cnt > 6'd1;


data_prbs_gen #
  (
    .TCQ        (TCQ),
    .PRBS_WIDTH (32),  
    .SEED_WIDTH (32)
   )
   data_prbs_gen
  (
   .clk_i            (clk_i),
   .clk_en           (data_clk_en),
   .rst_i            (rst_i),
   .prbs_fseed_i     (prbs_fseed_i),
   .prbs_seed_init   (cmd_startE),
   .prbs_seed_i      (addr_i[31:0]),
   .prbs_o           (prbs_data)

  );       
end        
endgenerate

 
endmodule 
