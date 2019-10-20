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
//  /   /         Filename: init_mem_pattern_ctr.v
// /___/   /\     Date Last Modified: $Date: 2011/06/02 07:16:33 $
// \   \  /  \    Date Created: Fri Sep 01 2006
//  \___\/\___\
//
//Device: Spartan6
//Design Name: DDR/DDR2/DDR3/LPDDR 
//Purpose: This moduel has a small FSM to control the operation of 
//         mcb_traffic_gen module.It first fill up the memory with a selected 
//         DATA pattern and then starts the memory testing state.
//Reference:
//Revision History: 1.1 Modify to allow data_mode_o to be controlled by parameter DATA_MODE
//                      and the fixed_bl_o is fixed at 64 if data_mode_o == PRBA and FAMILY == "SPARTAN6"
//                      The fixed_bl_o in Virtex6 is determined by the MEM_BURST_LENGTH.
//                  1.2 10-1-2009 Added parameter TST_MEM_INSTR_MODE to select instruction pattern during 
//                      memory testing phase.	   
//                  1.3    05/19/2010 If MEM_BURST_LEN value is passed with value of zero, it is treated as
//                                    "OTF" Burst Mode and TG will only generate BL 8 traffic.


//*****************************************************************************

`timescale 1ps/1ps





module init_mem_pattern_ctr #
  (
   parameter TCQ           = 100,  
   parameter FAMILY         = "SPARTAN6",      // VIRTEX6, SPARTAN6
   parameter TST_MEM_INSTR_MODE = "R_W_INSTR_MODE", // Spartan6 Available commands: 
                                                    // "FIXED_INSTR_R_MODE", "FIXED_INSTR_W_MODE"
                                                    // "R_W_INSTR_MODE", "RP_WP_INSTR_MODE 
                                                    // "R_RP_W_WP_INSTR_MODE", "R_RP_W_WP_REF_INSTR_MODE"
                                                    // Virtex 6 Available commands:
                                                    // "FIXED_INSTR_R_MODE" - Only Read commands will be generated.
                                                    // "FIXED_INSTR_W_MODE" -- Only Write commands will be generated.
                                                    // "R_W_INSTR_MODE"     - Random Read/Write commands will be generated.
   parameter MEM_BURST_LEN  = 8,                    // VIRTEX 6 Option. 
   parameter CMD_PATTERN    = "CGEN_ALL",           // "CGEN_ALL" option generates all available
                                                    // commands pattern.
   parameter BEGIN_ADDRESS  = 32'h00000000, 
   parameter END_ADDRESS  = 32'h00000fff,   
   parameter ADDR_WIDTH     = 30,
   parameter DWIDTH        = 32,
   parameter CMD_SEED_VALUE   = 32'h12345678,
   parameter DATA_SEED_VALUE  = 32'hca345675,
   parameter DATA_MODE     = 4'b0010,
   parameter PORT_MODE     = "BI_MODE", // V6 Option: "BI_MODE"; SP6 Option: "WR_MODE", "RD_MODE", "BI_MODE"
   parameter EYE_TEST      = "FALSE"  // set EYE_TEST = "TRUE" to probe memory signals.
                                      // Traffic Generator will only write to one single location and no
                                      // read transactions will be generated.
   
   )
  (
   input           clk_i,
   input           rst_i,
   
   input [ADDR_WIDTH-1:0]   mcb_cmd_addr_i,
   input [5:0]    mcb_cmd_bl_i,
   input          mcb_cmd_en_i,
   input [2:0]    mcb_cmd_instr_i,        
   input          mcb_wr_en_i,
   input          vio_modify_enable,            // 0: default to ADDR as DATA PATTERN. No runtime change in data mode.
                                                // 1: enable exteral VIO to control the data_mode pattern
                                                //    and address mode pattern during runtime.
   input [2:0]    vio_data_mode_value,
   input [2:0]    vio_addr_mode_value,
   input [1:0]    vio_bl_mode_value,
   input [5:0]    vio_fixed_bl_value,  // valid range is:  from 1 to 64.
   
   input           mcb_init_done_i,
   input           cmp_error,
   output reg          run_traffic_o,
  // runtime parameter
   output [31:0]             start_addr_o,   // define the start of address
   output [31:0]             end_addr_o,
   output [31:0]             cmd_seed_o,    // same seed apply to all addr_prbs_gen, bl_prbs_gen, instr_prbs_gen
   output [31:0]             data_seed_o,
   output  reg                  load_seed_o,   // 
   // upper layer inputs to determine the command bus and data pattern
   // internal traffic generator initialize the memory with 
   output reg [2:0]              addr_mode_o,  // "00" = bram; takes the address from bram output
                                          // "001" = fixed address from the fixed_addr input
                                          // "010" = psuedo ramdom pattern; generated from internal 64 bit LFSR
                                          // "011" = sequential
  
  
  // for each instr_mode, traffic gen fill up with a predetermined pattern before starting the instr_pattern that defined
  // in the instr_mode input. The runtime mode will be automatically loaded inside when it is in 
   output reg [3:0]              instr_mode_o, // "0000" = Fixed
                                              // "0001" = bram; takes instruction from bram output
                                              // "0010" = R/W
                                              // "0011" = RP/WP
                                              // "0100" = R/RP/W/WP
                                              // "0101" = R/RP/W/WP/REF
                                       
                                        
   output reg [1:0]              bl_mode_o,    // "00" = bram;   takes the burst length from bram output
                                        // "01" = fixed , takes the burst length from the fixed_bl input
                                        // "10" = psuedo ramdom pattern; generated from internal 16 bit LFSR
   
   output reg [3:0]              data_mode_o,   // "00" = bram; 
                                         // "01" = fixed data from the fixed_data input
                                         // "10" = psuedo ramdom pattern; generated from internal 32 bit LFSR
                                         // "11" = sequential using the addrs as the starting data pattern
   output reg                   mode_load_o,
 
   // fixed pattern inputs interface
   output reg [5:0]              fixed_bl_o,      // range from 1 to 64
   output reg [2:0]              fixed_instr_o,   //RD              3'b001
                                            //RDP             3'b011
                                            //WR              3'b000
                                            //WRP             3'b010
                                            //REFRESH         3'b100
   output  [31:0]             fixed_addr_o // only upper 30 bits will be used
   
  );

   //FSM State Defination
parameter IDLE           = 5'b00001,
          INIT_MEM_WRITE = 5'b00010,
          INIT_MEM_READ  = 5'b00100,
          TEST_MEM       = 5'b01000,
          CMP_ERROR      = 5'b10000;


localparam BRAM_ADDR       = 2'b00;
localparam FIXED_ADDR      = 2'b01;
localparam PRBS_ADDR       = 2'b10;
localparam SEQUENTIAL_ADDR = 2'b11;

localparam  BRAM_INSTR_MODE        =    4'b0000;
localparam  FIXED_INSTR_MODE         =   4'b0001;
localparam  R_W_INSTR_MODE          =   4'b0010;
localparam  RP_WP_INSTR_MODE        =   4'b0011;
localparam R_RP_W_WP_INSTR_MODE     =   4'b0100;
localparam R_RP_W_WP_REF_INSTR_MODE =   4'b0101;
                                     
localparam BRAM_BL_MODE          =   2'b00;
localparam FIXED_BL_MODE         =   2'b01;
localparam PRBS_BL_MODE          =   2'b10;

localparam BRAM_DATAL_MODE       =    4'b0000;
localparam FIXED_DATA_MODE       =    4'b0001;
localparam ADDR_DATA_MODE        =    4'b0010;                                     
localparam HAMMER_DATA_MODE      =    4'b0011;
localparam NEIGHBOR_DATA_MODE    =    4'b0100;
localparam WALKING1_DATA_MODE    =    4'b0101;
localparam WALKING0_DATA_MODE    =    4'b0110;
localparam PRBS_DATA_MODE        =    4'b0111;

// type fixed instruction
localparam  RD_INSTR       =  3'b001;
localparam  RDP_INSTR      =  3'b011;
localparam  WR_INSTR       =  3'b000;

localparam  WRP_INSTR      =  3'b010;
localparam  REFRESH_INSTR  =  3'b100;
localparam  NOP_WR_INSTR   =  3'b101;


reg [4:0] current_state;
reg [4:0] next_state;
reg       mcb_init_done_reg;
reg       mcb_init_done_reg1;
reg AC2_G_E2,AC1_G_E1,AC3_G_E3;
reg upper_end_matched;
reg [31:0] end_boundary_addr;     
reg [31:0] mcb_cmd_addr_r;

reg mcb_cmd_en_r;
//reg [ADDR_WIDTH-1:0] mcb_cmd_addr_r;
reg [5:0] mcb_cmd_bl_r;
reg lower_end_matched;   
reg end_addr_reached;
reg run_traffic;
reg bram_mode_enable;
wire tst_matched;
reg [31:0] current_address;
reg [5:0]  fix_bl_value;
reg [3:0] data_mode_sel;
reg [2:0] addr_mode_sel;
reg [1:0] bl_mode_sel;
reg [2:0] addr_mode;
reg [10:0] INC_COUNTS;
wire [5:0] FIXEDBL;
wire [3:0] test_mem_instr_mode;

assign test_mem_instr_mode = (TST_MEM_INSTR_MODE == "BRAM_INSTR_MODE")               ? 4'b0000:
                             (TST_MEM_INSTR_MODE == "FIXED_INSTR_R_MODE"  ||
                              TST_MEM_INSTR_MODE == "FIXED_INSTR_W_MODE")              ? 4'b0001:
                             (TST_MEM_INSTR_MODE == "R_W_INSTR_MODE")                                    ? 4'b0010:
                             (TST_MEM_INSTR_MODE == "RP_WP_INSTR_MODE"         && FAMILY == "SPARTAN6")  ? 4'b0011:
                             (TST_MEM_INSTR_MODE == "R_RP_W_WP_INSTR_MODE"     && FAMILY == "SPARTAN6")  ? 4'b0100:
                             (TST_MEM_INSTR_MODE == "R_RP_W_WP_REF_INSTR_MODE" && FAMILY == "SPARTAN6")  ? 4'b0101:
                             4'b0010;




assign FIXEDBL = 64; // This is fixed for current Spartan 6 Example Design














generate
if (FAMILY == "SPARTAN6" ) begin : INC_COUNTS_S
    
always @ (posedge clk_i)
    INC_COUNTS <= (DWIDTH/8);
    
end
endgenerate






generate
if (FAMILY == "VIRTEX6" ) begin : INC_COUNTS_V
always @ (posedge clk_i)
begin
if ( (DWIDTH >= 256 && DWIDTH <= 576))          // 64  144
     INC_COUNTS <= 32  ;
else if ((DWIDTH >= 128) && (DWIDTH <= 224))    // 32 dq pins or 566 dq pins
     INC_COUNTS <= 16     ;
else if ((DWIDTH == 64) || (DWIDTH == 96))      // 16 dq pins or 24 dqpins
     INC_COUNTS <= 8  ;
else if ((DWIDTH == 32) )      // 8 dq pins 
     INC_COUNTS <= 4 ;
end
end
endgenerate


always @ (posedge clk_i)
begin
if (rst_i)
    current_address <= BEGIN_ADDRESS;
else if (mcb_wr_en_i && (current_state == INIT_MEM_WRITE && (PORT_MODE == "WR_MODE" || PORT_MODE == "BI_MODE"))
         || (mcb_wr_en_i && (current_state == IDLE && PORT_MODE == "RD_MODE")) )
    current_address <= current_address + INC_COUNTS;
else
    current_address <= current_address;

end    


always @ (posedge clk_i)
begin
  if (current_address[29:24] >= end_boundary_addr[29:24])
      AC3_G_E3 <= 1'b1;
  else
      AC3_G_E3 <= 1'b0;
  
  
    if (current_address[23:16] >= end_boundary_addr[23:16])
      AC2_G_E2 <= 1'b1;
  else
      AC2_G_E2 <= 1'b0;
  
  if (current_address[15:8] >= end_boundary_addr[15:8])
      AC1_G_E1 <= 1'b1;
else
      AC1_G_E1 <= 1'b0;
  
  
end
always @(posedge clk_i)
begin
if (rst_i)
     upper_end_matched <= 1'b0;
 
 else if (mcb_cmd_en_i)
     upper_end_matched <= AC3_G_E3 & AC2_G_E2 & AC1_G_E1;
end   

wire [6:0] FIXED_BL_VALUE;
assign FIXED_BL_VALUE = (FAMILY == "VIRTEX6" && (MEM_BURST_LEN == 8 || MEM_BURST_LEN == 0)) ? 2 :
                        (FAMILY == "VIRTEX6" && MEM_BURST_LEN == 4) ? 1 :
                         FIXEDBL;

always @(posedge clk_i)
begin
//   end_boundary_addr <= (END_ADDRESS[31:0] - (DWIDTH/8)*FIXEDBL +1) ;
     end_boundary_addr <= (END_ADDRESS[31:0] - (DWIDTH/8) +1) ;

end   



always @(posedge clk_i)
begin
  if (current_address[7:0] >= end_boundary_addr[7:0])

   lower_end_matched <= 1'b1;
  else
   lower_end_matched <= 1'b0;
  
end   


always @(posedge clk_i)
begin
  if (mcb_cmd_en_i )
   mcb_cmd_addr_r <= mcb_cmd_addr_i;
end   


always @(posedge clk_i)
begin
  if (mcb_cmd_en_i)
   mcb_cmd_bl_r <= mcb_cmd_bl_i;
end   

always @(posedge clk_i)
begin
   if ((upper_end_matched && lower_end_matched && FAMILY == "SPARTAN6" && DWIDTH == 32) ||
      (upper_end_matched && lower_end_matched && FAMILY == "SPARTAN6" && DWIDTH == 64) ||   
      (upper_end_matched && DWIDTH == 128 && FAMILY == "SPARTAN6") ||
      (upper_end_matched && lower_end_matched && FAMILY == "VIRTEX6"))
      end_addr_reached <= 1'b1;
   else    
      end_addr_reached <= 1'b0;

end 

 
assign tst_matched = upper_end_matched & lower_end_matched;

assign   fixed_addr_o = 32'h00001234;



 always @ (posedge clk_i)
 begin
      mcb_init_done_reg1 <= mcb_init_done_i;
      mcb_init_done_reg <= mcb_init_done_reg1;
end

 always @ (posedge clk_i)
       run_traffic_o <= run_traffic;


 
 always @ (posedge clk_i)
 begin
    if (rst_i)
        current_state <= 5'b00001;
    else
        current_state <= next_state;
 end

   assign          start_addr_o  = BEGIN_ADDRESS;//BEGIN_ADDRESS;
   assign          end_addr_o    = END_ADDRESS;
   assign          cmd_seed_o    = CMD_SEED_VALUE;
   assign          data_seed_o   = DATA_SEED_VALUE;


reg [2:0] syn1_vio_data_mode_value;
reg [2:0] syn1_vio_addr_mode_value;


 always @ (posedge clk_i)
 begin
   if (rst_i) begin
        syn1_vio_data_mode_value <= 3'b011;
        syn1_vio_addr_mode_value <= 2'b11;
       end        
 else if (vio_modify_enable == 1'b1) begin
   syn1_vio_data_mode_value <= vio_data_mode_value;
   syn1_vio_addr_mode_value <= vio_addr_mode_value;
   end
 end
 

 always @ (posedge clk_i)
 begin
 if (rst_i) begin
       data_mode_sel <= DATA_MODE;//ADDR_DATA_MODE;
       addr_mode_sel <= 2'b11;
       end
 else if (vio_modify_enable == 1'b1) begin
       data_mode_sel <= syn1_vio_data_mode_value[2:0];
       addr_mode_sel <= vio_addr_mode_value;
       end
 end

 always @ (posedge clk_i)
 begin
 if (rst_i  || FAMILY == "VIRTEX6") 
       fix_bl_value <= FIXED_BL_VALUE;//ADDR_DATA_MODE;

 else if (vio_modify_enable == 1'b1) begin
       fix_bl_value <= vio_fixed_bl_value;
       end
 end

 always @ (posedge clk_i)
 begin
 if (rst_i || (FAMILY == "VIRTEX6")) 
      if  (FAMILY == "VIRTEX6")
         bl_mode_sel <= FIXED_BL_MODE;
      else
       bl_mode_sel <= PRBS_BL_MODE;
 else if (vio_modify_enable == 1'b1) begin
       bl_mode_sel <= vio_bl_mode_value;
       end
 end





always @ (posedge clk_i)
begin
    data_mode_o   <= data_mode_sel;
    addr_mode_o   <= addr_mode;
    
    // assuming if vio_modify_enable is enabled and vio_addr_mode_value is set to zero
    // user wants to have bram interface.
    if (syn1_vio_addr_mode_value == 0 && vio_modify_enable == 1'b1)
        bram_mode_enable <=  1'b1;
    else
        bram_mode_enable <=  1'b0;
    
 end
 

always @ (*)
begin
             load_seed_o   = 1'b0;
             if (CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                 addr_mode = 'b0;
             else
                 addr_mode   = SEQUENTIAL_ADDR;

             if (CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                 instr_mode_o = 'b0;
             else
                 instr_mode_o   = FIXED_INSTR_MODE;


             if (CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                 bl_mode_o = 'b0;
             else
                 bl_mode_o   = FIXED_BL_MODE;

           
             
             if (FAMILY == "VIRTEX6")
                 fixed_bl_o = FIXED_BL_VALUE;
                                                 // PRBS mode
             else if (data_mode_o[2:0] == 3'b111 && FAMILY == "SPARTAN6")
                 fixed_bl_o = 64;  // Our current PRBS algorithm wants to maximize the range bl from 1 to 64.
             else
                  fixed_bl_o    = fix_bl_value;
                 
                 
                 
             mode_load_o   = 1'b0;
             run_traffic = 1'b0;   
             next_state = IDLE;

             if (PORT_MODE == "RD_MODE") begin
               fixed_instr_o = RD_INSTR;
             end
              else if( PORT_MODE == "WR_MODE" || PORT_MODE == "BI_MODE") begin
               fixed_instr_o = WR_INSTR;
             end
             
case(current_state)
   IDLE:  
        begin
         if(mcb_init_done_reg )   //rdp_rdy_i comes from read_data path
            begin
              if (PORT_MODE == "WR_MODE" || PORT_MODE == "BI_MODE") begin
                 next_state = INIT_MEM_WRITE;
              mode_load_o = 1'b1;
              run_traffic = 1'b0;
              load_seed_o   = 1'b1;
             end
              else if (PORT_MODE == "RD_MODE" && end_addr_reached) begin
                    next_state = TEST_MEM;
                    mode_load_o = 1'b1;
                    run_traffic = 1'b1;
              load_seed_o   = 1'b1;
                    
              end
            end
         else
              begin
              next_state = IDLE;
              run_traffic = 1'b0;
              load_seed_o   = 1'b0;
              
              end
         
         end
   INIT_MEM_WRITE:  begin
   
         if (end_addr_reached  && EYE_TEST == "FALSE"  )
            begin
               next_state = TEST_MEM;
               mode_load_o = 1'b1;
               load_seed_o   = 1'b1;
               run_traffic = 1'b1;
               
            end   
          else
             begin
               next_state = INIT_MEM_WRITE;
              run_traffic = 1'b1; 
              mode_load_o = 1'b0;
              load_seed_o   = 1'b0;
              if (EYE_TEST == "TRUE")  
                addr_mode   = FIXED_ADDR;
              else if (CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                addr_mode = 'b0;
              else
                addr_mode   = SEQUENTIAL_ADDR;
              
             end  
         
        end
      
   INIT_MEM_READ:  begin
   
         if (end_addr_reached  )
            begin
               next_state = TEST_MEM;
               mode_load_o = 1'b1;
              load_seed_o   = 1'b1;
               
            end   
          else
             begin
               next_state = INIT_MEM_READ;
              run_traffic = 1'b0; 
              mode_load_o = 1'b0;
              load_seed_o   = 1'b0;
              
             end  
         
        end
   TEST_MEM: begin  
         if (cmp_error)
               next_state = CMP_ERROR;
               
         else
           next_state = TEST_MEM;
           run_traffic = 1'b1;
       

           if (PORT_MODE == "BI_MODE" && TST_MEM_INSTR_MODE == "FIXED_INSTR_W_MODE")
                fixed_instr_o = WR_INSTR;
           else if (PORT_MODE == "BI_MODE" && TST_MEM_INSTR_MODE == "FIXED_INSTR_R_MODE")
                fixed_instr_o = RD_INSTR;                
           else if (PORT_MODE == "RD_MODE")
              fixed_instr_o = RD_INSTR;
           
           else if( PORT_MODE == "WR_MODE") 
              fixed_instr_o = WR_INSTR;
           
        
             if (FAMILY == "VIRTEX6")
                 fixed_bl_o = fix_bl_value;
             else if ((data_mode_o == 3'b111) && (FAMILY == "SPARTAN6"))
                 fixed_bl_o = 64;  // Our current PRBS algorithm wants to maximize the range bl from 1 to 64.
             else
            fixed_bl_o    = fix_bl_value;
                 
           bl_mode_o     = bl_mode_sel;//FIXED_BL_MODE;//PRBS_BL_MODE;//PRBS_BL_MODE; //FIXED_BL_MODE;

              if (bl_mode_o == PRBS_BL_MODE)  
                addr_mode   = PRBS_ADDR;
              else
                addr_mode   = addr_mode_sel;

           
           
           if(PORT_MODE == "BI_MODE") begin
               if(CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                   instr_mode_o  = BRAM_INSTR_MODE;
               else
                   instr_mode_o  = test_mem_instr_mode;//R_RP_W_WP_REF_INSTR_MODE;//FIXED_INSTR_MODE;//R_W_INSTR_MODE;//R_RP_W_WP_INSTR_MODE;//R_W_INSTR_MODE;//R_W_INSTR_MODE; //FIXED_INSTR_MODE;//
              end
           else if (PORT_MODE == "RD_MODE" || PORT_MODE == "WR_MODE") begin
               instr_mode_o  = FIXED_INSTR_MODE;
           end
              
         end
   
   
   

   
   CMP_ERROR: 
        begin
               next_state = CMP_ERROR;
               bl_mode_o     = bl_mode_sel;//PRBS_BL_MODE;//PRBS_BL_MODE; //FIXED_BL_MODE;
               fixed_instr_o = RD_INSTR;
               addr_mode   = SEQUENTIAL_ADDR;//PRBS_ADDR;//PRBS_ADDR;//PRBS_ADDR;//SEQUENTIAL_ADDR;   
               if(CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                   instr_mode_o  = BRAM_INSTR_MODE;//
               else
                   instr_mode_o  = test_mem_instr_mode;//FIXED_INSTR_MODE;//R_W_INSTR_MODE;//R_RP_W_WP_INSTR_MODE;//R_W_INSTR_MODE;//R_W_INSTR_MODE; //FIXED_INSTR_MODE;//
               
               run_traffic = 1'b1;       // ?? keep it running or stop if error happened

        end
   default:
          begin
            next_state = IDLE;       
           //run_traffic = 1'b0;              

        end
  
 endcase
 end




endmodule
