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
//  /   /         Filename: mcb_flow_control.v
// /___/   /\     Date Last Modified: $Date: 2011/06/02 07:16:33 $
// \   \  /  \    Date Created: 
//  \___\/\___\
//
//Device: Spartan6
//Design Name: DDR/DDR2/DDR3/LPDDR 
//Purpose: This module is the main flow control between cmd_gen.v, 
//         write_data_path and read_data_path modules.
//Design Name: DDR/DDR2/DDR3/LPDDR 
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ps/1ps

module mcb_flow_control #
  (
    parameter TCQ           = 100,
    parameter FAMILY = "SPARTAN6"
  )
  ( 
   input     clk_i, 
   input [9:0]    rst_i,
   // interface to cmd_gen, pipeline inserter
   output  reg     cmd_rdy_o, 
   input        cmd_valid_i, 
   input [2:0]  cmd_i, 
   input [31:0] addr_i, 
   input [5:0]  bl_i,

   
   // interface to mcb_cmd port
   input                  mcb_cmd_full,
   output reg [2:0]           cmd_o, 
   output reg [31:0]          addr_o, 
   output reg [5:0]           bl_o,
   output                 cmd_en_o,   // interface to write data path module
   input                  last_word_wr_i,
   input                  wdp_rdy_i, 
   output                 wdp_valid_o, 
   output                 wdp_validB_o, 
   output                 wdp_validC_o,   
   
   output  [31:0]          wr_addr_o, 
   output  [5:0]           wr_bl_o,
   // interface to read data path module
   input                   last_word_rd_i,
   input                   rdp_rdy_i, 
   output                  rdp_valid_o, 
   output  [31:0]           rd_addr_o, 
   output [5:0]            rd_bl_o
   );
   
   //FSM State Defination
localparam READY    = 5'b00001,
          READ     = 5'b00010,
          WRITE    = 5'b00100,
          CMD_WAIT = 5'b01000,
          REFRESH_ST = 5'b10000; 

localparam RD     =         3'b001;
localparam RDP    =         3'b011;
localparam WR     =         3'b000;
localparam WRP    =         3'b010;
localparam REFRESH =        3'b100;
localparam NOP     =        3'b101;  // this defination is local to this traffic gen and is not defined


reg cmd_fifo_rdy;
wire cmd_rd;
wire cmd_wr;         // need equation
wire cmd_others;
reg  push_cmd;
reg  xfer_cmd;
reg  rd_vld  ;  
reg  wr_vld;
reg  cmd_rdy;
reg [2:0]   cmd_reg; 
reg [31:0]  addr_reg; 
reg [5:0]   bl_reg;

reg       rdp_valid;
(*EQUIVALENT_REGISTER_REMOVAL="NO"*) reg   wdp_valid,wdp_validB,wdp_validC;

reg [4:0] current_state;
reg [4:0] next_state;
reg [3:0] tstpointA;
reg push_cmd_r;
reg wait_done;
reg cmd_en_r1 ;
reg wr_in_progress;
reg tst_cmd_rdy_o;




//  mcb_command bus outputs
assign cmd_en_o = cmd_en_r1;

always @ (posedge clk_i) begin

    cmd_rdy_o <= #TCQ  cmd_rdy;
    tst_cmd_rdy_o <= #TCQ  cmd_rdy;
    
end

always @ (posedge clk_i)
begin
if (rst_i[8])
    cmd_en_r1 <= #TCQ  1'b0;
else if ( xfer_cmd)
    cmd_en_r1 <= #TCQ  1'b1;
 else if (!mcb_cmd_full)
    cmd_en_r1 <= #TCQ  1'b0;
 
 end

always @ (posedge clk_i)
begin
if (rst_i[9])
    cmd_fifo_rdy <= #TCQ  1'b1;
else if (xfer_cmd)
    cmd_fifo_rdy <= #TCQ  1'b0;
else if (!mcb_cmd_full)    
    cmd_fifo_rdy <= #TCQ  1'b1;
end

always @ (posedge clk_i)
begin
if (rst_i[9]) begin
    addr_o <= #TCQ  'b0;
    cmd_o  <= #TCQ  'b0;
    bl_o   <= #TCQ  'b0;
end
else if (xfer_cmd ) begin
    addr_o <= #TCQ  addr_reg;           
    if (FAMILY == "SPARTAN6")
        cmd_o <= #TCQ  cmd_reg;
    else
        cmd_o  <= #TCQ  {2'b00,cmd_reg[0]};
    bl_o   <= #TCQ  bl_reg;
end

end

// go directly to wr_datapath and rd_datapath modules 
       assign  wr_addr_o = addr_i;
       assign  rd_addr_o = addr_i;
assign rd_bl_o   = bl_i ;
assign wr_bl_o   = bl_i ;

assign wdp_valid_o = wdp_valid;
assign wdp_validB_o = wdp_validB;
assign wdp_validC_o = wdp_validC;

assign rdp_valid_o = rdp_valid;


// internal control siganls

always @ (posedge clk_i)
begin
if (rst_i[8])
   wait_done <= #TCQ  1'b1;
else if (push_cmd_r)
   wait_done <=  #TCQ 1'b1;
else if (cmd_rdy_o && cmd_valid_i && FAMILY == "SPARTAN6")
   wait_done <=  #TCQ 1'b0;


end

//  


always @ (posedge clk_i)
     begin
     push_cmd_r  <= #TCQ push_cmd;
    // push_cmd_r2 <= #TCQ push_cmd_r;
     end
always @ (posedge clk_i)
 if (push_cmd)
   begin
        cmd_reg <=    #TCQ cmd_i;
        addr_reg <= #TCQ addr_i;
        bl_reg   <= #TCQ bl_i - 1;
        
end
 
 
   
//--Command Decodes--
assign  cmd_wr     = ((cmd_i == WR  | cmd_i == WRP) & cmd_valid_i )  ? 1'b1 : 1'b0;
assign  cmd_rd     = ((cmd_i == RD | cmd_i == RDP) & cmd_valid_i) ? 1'b1 : 1'b0;
assign  cmd_others = ((cmd_i[2] == 1'b1)& cmd_valid_i && (FAMILY == "SPARTAN6")) ? 1'b1 : 1'b0;

    
reg cmd_wr_pending_r1;  
reg cmd_rd_pending_r1;  

always @ (posedge clk_i)
begin
if (rst_i[0])
    cmd_wr_pending_r1 <= #TCQ 1'b0;

//else if (current_state == WRITE && last_word_wr_i && !cmd_fifo_rdy)
//else if ( last_word_wr_i && !cmd_fifo_rdy)
else if ( last_word_wr_i )


    cmd_wr_pending_r1 <= #TCQ 1'b1;
else if (push_cmd)//xfer_cmd)
    cmd_wr_pending_r1 <= #TCQ 1'b0;
end    


// corner case if fixed read command with fixed bl 64

always @ (posedge clk_i)
begin
if (cmd_rd & push_cmd)
    cmd_rd_pending_r1 <= #TCQ 1'b1;
else if (xfer_cmd)
    cmd_rd_pending_r1 <= #TCQ 1'b0;

end    

 always @ (posedge clk_i)
 begin
if (rst_i[0])
   wr_in_progress <= #TCQ  1'b0;
else if (last_word_wr_i)   
   wr_in_progress <= #TCQ  1'b0;   
else if (current_state == WRITE)   
   wr_in_progress <= #TCQ  1'b1;


end
 always @ (posedge clk_i)
 begin
    if (rst_i[0])
        current_state <= #TCQ  4'b0001;
    else
        current_state <= #TCQ next_state;
 end

// mcb_flow_control statemachine
always @ (*)
begin
               push_cmd  = 1'b0;
               xfer_cmd = 1'b0;
               
               wdp_valid = 1'b0;
               wdp_validB = 1'b0;
               wdp_validC = 1'b0;
               
               rdp_valid = 1'b0;
               cmd_rdy = 1'b0;
               next_state = current_state;
case(current_state)
   READY:  
        begin
         if(rdp_rdy_i & cmd_rd & cmd_fifo_rdy)   //rdp_rdy_i comes from read_data path

            begin
              next_state = READ;
              push_cmd = 1'b1;
              xfer_cmd = 1'b0;
              rdp_valid = 1'b1;
              
            end
         else if (wdp_rdy_i & cmd_wr & cmd_fifo_rdy)
             begin
              next_state = WRITE;
               push_cmd = 1'b1;
               wdp_valid     = 1'b1;
               wdp_validB = 1'b1;
               wdp_validC = 1'b1;
               
             end 
         else if ( cmd_others & cmd_fifo_rdy)
             begin
              next_state = REFRESH_ST;
               push_cmd = 1'b1;
               xfer_cmd = 1'b0;
               
             end 
             
         else
              begin
              next_state = READY;
              push_cmd = 1'b0;
              end
              
              
         if (cmd_fifo_rdy)
             cmd_rdy = 1'b1;
         else
             cmd_rdy = 1'b0;
         
         
         end
         
   REFRESH_ST : begin
   
         if (rdp_rdy_i && cmd_rd && cmd_fifo_rdy  )
            begin
               next_state = READ;
               push_cmd = 1'b1;
               rdp_valid = 1'b1;
               wdp_valid = 1'b0;
               xfer_cmd = 1'b1;
              // tstpointA    = 4'b0101;
               
            end   
          else if (cmd_fifo_rdy && cmd_wr && wdp_rdy_i )
             begin
               next_state = WRITE;
               push_cmd = 1'b1;
               xfer_cmd = 1'b1;
               
               wdp_valid     = 1'b1;
               wdp_validB    = 1'b1;
               wdp_validC    = 1'b1;
               
             //   tstpointA    = 4'b0110;
              
             end
            
          else if (cmd_fifo_rdy && cmd_others)
             begin
               push_cmd = 1'b1;
               xfer_cmd = 1'b1;
             end
          else if (!cmd_fifo_rdy)

             begin
               next_state = CMD_WAIT;
               tstpointA    = 4'b1001;
               
             end  
          else
               next_state = READ; 
 
 
               
          if (cmd_fifo_rdy && ((rdp_rdy_i && cmd_rd) || (wdp_rdy_i && cmd_wr) || (cmd_others)))
              cmd_rdy = 1'b1;
         else 
              cmd_rdy = 1'b0;
          
         
   
          end
   READ:  begin
   
         if (rdp_rdy_i && cmd_rd && cmd_fifo_rdy  )
            begin
               next_state = READ;
               push_cmd = 1'b1;
               rdp_valid = 1'b1;
               wdp_valid = 1'b0;
               xfer_cmd = 1'b1;
               tstpointA    = 4'b0101;
               
            end   
          else if (cmd_fifo_rdy && cmd_wr && wdp_rdy_i )
             begin
               next_state = WRITE;
               push_cmd = 1'b1;
               xfer_cmd = 1'b1;
               
               wdp_valid     = 1'b1;
               wdp_validB    = 1'b1;
               wdp_validC    = 1'b1;
               
                tstpointA    = 4'b0110;
              
             end
            
         else if (!rdp_rdy_i )
            begin
               next_state = READ; 
               push_cmd  = 1'b0;
                 xfer_cmd  = 1'b0;
              
               tstpointA    = 4'b0111;
              
               wdp_valid = 1'b0;
               wdp_validB = 1'b0;
               wdp_validC    = 1'b0;
               rdp_valid = 1'b0;
            end                       
          else if (last_word_rd_i && cmd_others && cmd_fifo_rdy )

             begin
               next_state = REFRESH_ST;
               push_cmd = 1'b1;
               xfer_cmd = 1'b1;
               wdp_valid = 1'b0;
               wdp_validB = 1'b0;
               wdp_validC    = 1'b0;
               rdp_valid = 1'b0;
               tstpointA    = 4'b1000;
              
             end
          else if (!cmd_fifo_rdy || !wdp_rdy_i)

             begin
               next_state = CMD_WAIT;
               tstpointA    = 4'b1001;
               
             end  
          else
               next_state = READ; 
 
 
               
          if ((rdp_rdy_i && cmd_rd || cmd_wr && wdp_rdy_i || cmd_others) && cmd_fifo_rdy)
             cmd_rdy = wait_done;//1'b1;
         else 
              cmd_rdy = 1'b0;
          
        
        end
   WRITE: begin  // for write, always wait until the last_word_wr 
         if (cmd_fifo_rdy &&  cmd_rd && rdp_rdy_i && last_word_wr_i)
               begin
               next_state = READ;
               push_cmd = 1'b1;
               xfer_cmd = 1'b1;
               rdp_valid     = 1'b1;
               tstpointA    = 4'b0000;
               end
          else if (!wdp_rdy_i || (wdp_rdy_i && cmd_wr && cmd_fifo_rdy && last_word_wr_i) )
               begin
               next_state = WRITE;
               tstpointA    = 4'b0001;
               
               if (cmd_wr && last_word_wr_i) begin
                  wdp_valid     = 1'b1;
                  wdp_validB = 1'b1;
                  wdp_validC    = 1'b1;
                  
               end
               else begin
                  wdp_valid     = 1'b0;
                  wdp_validB = 1'b0;
               wdp_validC    = 1'b0;
                  
               end
               
               if (last_word_wr_i ) begin
                  push_cmd = 1'b1;
                  xfer_cmd = 1'b1;
               end
               else begin
                  push_cmd = 1'b0;
                  xfer_cmd = 1'b0;
               end
                             
               end
          else if (last_word_wr_i && cmd_others && cmd_fifo_rdy)
             begin
               next_state = REFRESH_ST;
               push_cmd = 1'b1;
               xfer_cmd = 1'b1;
               tstpointA    = 4'b0010;
               
               wdp_valid = 1'b0;
               wdp_validB = 1'b0;
               wdp_validC    = 1'b0;
               
               rdp_valid = 1'b0;
               
             end
               
          else if (!cmd_fifo_rdy && last_word_wr_i || !rdp_rdy_i || (!cmd_valid_i && wait_done) )

               begin
               next_state = CMD_WAIT;
               push_cmd = 1'b0;
               xfer_cmd = 1'b0;
               tstpointA    = 4'b0011;
               
               end
          
          else begin
                  next_state = WRITE;
               tstpointA    = 4'b0100;
                  
               end

         // need to include rdp_rdy_i to prevent sending read command if
         // read_data_port fifo is full in MCB
   if (last_word_wr_i && (cmd_others || rdp_rdy_i && cmd_rd || cmd_wr && wdp_rdy_i) && cmd_fifo_rdy)
             cmd_rdy = wait_done;//1'b1;
         else 
             cmd_rdy = 1'b0;
         
              
         end
   
   
   

   
   CMD_WAIT: if (!cmd_fifo_rdy || wr_in_progress)
               begin
               next_state = CMD_WAIT;
               cmd_rdy = 1'b0;
               tstpointA    = 4'b1010;
               
               end
             else if (cmd_fifo_rdy && rdp_rdy_i && cmd_rd)
               begin
               next_state = READ;
               push_cmd = 1'b1;
               xfer_cmd = 1'b1;
               cmd_rdy = 1'b1;
               rdp_valid     = 1'b1;
               
               tstpointA    = 4'b1011;
               end
             else if (cmd_fifo_rdy  && cmd_wr && (wait_done || cmd_wr_pending_r1))

               begin
               next_state = WRITE;
               push_cmd = 1'b1;
               xfer_cmd = 1'b1;                                   
               wdp_valid     = 1'b1;
               wdp_validB = 1'b1;
               wdp_validC    = 1'b1;
               
               cmd_rdy = 1'b1;
               tstpointA    = 4'b1100;
               
               end
             else if (cmd_fifo_rdy &&  cmd_others)
               begin
               next_state = REFRESH_ST;
               push_cmd = 1'b1;  /////////////////
               xfer_cmd = 1'b1;   
               tstpointA    = 4'b1101;
               cmd_rdy = 1'b1;
               
               end
             else
               begin
               next_state = CMD_WAIT;
               tstpointA    = 4'b1110;
               
               if ((wdp_rdy_i && rdp_rdy_i))
                  cmd_rdy = 1'b1;
               else
                  cmd_rdy = 1'b0;
                  
                  
               end
     
               
   default:
          begin
           push_cmd = 1'b0;
           xfer_cmd = 1'b0;
           
           wdp_valid = 1'b0;
           wdp_validB = 1'b0;
           wdp_validC    = 1'b0;
           next_state = READY;              
         //  cmd_rdy = 1'b0;
                    
                         

         end
   
 endcase
 end
   
endmodule 
