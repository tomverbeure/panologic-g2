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
//  /   /         Filename: cmd_gen.v
// /___/   /\     Date Last Modified: $Date: 2011/05/27 15:50:26 $
// \   \  /  \    Date Created: Oct 21 2008
//  \___\/\___\
//
//Device: Spartan6
//Design Name: DDR/DDR2/DDR3/LPDDR
//Purpose:  This module genreates different type of commands, address,
//          burst_length to mcb_flow_control module.
//Reference:
//Revision History:
//                  Nov14 2008. Added constraints  for generating PRBS_BL when
//                         generated address is too close to end of address space.
//                         The BL will be force to 1 to avoid across other port's space.
//                  April 2 2009 Fixed Sequential Address Circuit to avoide generate any address
//                               beyond the allowed address range.		  
//                  Oct 22 2009  Fixed BRAM interface.
//                               Fixed run_traffic stop and go problem.
//                               Merged V6 and SP6 specific requirements.
//								 Modified syntax for VHDL Formality comparison.
//*****************************************************************************

`timescale 1ps/1ps

`define RD              3'b001;
`define RDP             3'b011;
`define WR              3'b000;
`define WRP             3'b010;
`define REFRESH         3'b100;


module cmd_gen #
  (
   parameter TCQ           = 100,

   parameter FAMILY = "SPARTAN6",
   parameter MEM_BURST_LEN = 8,
   parameter PORT_MODE = "BI_MODE",
   parameter NUM_DQ_PINS   = 8,
   parameter DATA_PATTERN  = "DGEN_ALL", // "DGEN__HAMMER", "DGEN_WALING1","DGEN_WALING0","DGEN_ADDR","DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter CMD_PATTERN  = "CGEN_ALL",    // "CGEN_RPBS","CGEN_FIXED",  "CGEN_BRAM", "CGEN_SEQUENTIAL", "CGEN_ALL",
   parameter ADDR_WIDTH    = 30,
   parameter DWIDTH        = 32,
   parameter PIPE_STAGES   = 0,
   parameter MEM_COL_WIDTH = 10,       // memory column width
   parameter PRBS_EADDR_MASK_POS = 32'hFFFFD000,
   parameter PRBS_SADDR_MASK_POS =  32'h00002000,
   parameter PRBS_EADDR = 32'h00002000,
   parameter PRBS_SADDR  = 32'h00002000
   )
  (
   input           clk_i,
   input [9:0]          rst_i,
   input           run_traffic_i,
  // runtime parameter
  input [6:0]               rd_buff_avail_i,
  input                     force_wrcmd_gen_i,
   input [31:0]             start_addr_i,   // define the start of address
   input [31:0]             end_addr_i,
   input [31:0]             cmd_seed_i,    // same seed apply to all addr_prbs_gen, bl_prbs_gen, instr_prbs_gen
   input [31:0]             data_seed_i,
   input                    load_seed_i,   //
   // upper layer inputs to determine the command bus and data pattern
   // internal traffic generator initialize the memory with
   input [2:0]              addr_mode_i,  // "00" = bram; takes the address from bram output
                                          // "01" = fixed address from the fixed_addr input
                                          // "10" = psuedo ramdom pattern; generated from internal 64 bit LFSR
                                          // "11" = sequential

   input [3:0]              data_mode_i,  // 4'b0010:address as data
                                          // 4'b0011:DGEN_HAMMER
                                          // 4'b0100:DGEN_NEIGHBOUR
                                          // 4'b0101:DGEN_WALKING1
                                          // 4'b0110:DGEN_WALKING0
                                          // 4'b0111:PRBS_DATA

  // for each instr_mode, traffic gen fill up with a predetermined pattern before starting the instr_pattern that defined
  // in the instr_mode input. The runtime mode will be automatically loaded inside when it is in
   input [3:0]              instr_mode_i, // "0000" = bram; takes instruction from bram output
                                          // "0001" = fixed instr from fixed instr input
                                          // "0010" = R/W
                                          // "0011" = RP/WP
                                          // "0100" = R/RP/W/WP
                                          // "0101" = R/RP/W/WP/REF
                                          // "0110" = PRBS


   input [1:0]              bl_mode_i,  // "00" = bram;   takes the burst length from bram output
                                        // "01" = fixed , takes the burst length from the fixed_bl input
                                        // "10" = psuedo ramdom pattern; generated from internal 16 bit LFSR

   input                    mode_load_i,

   // fixed pattern inputs interface
   input [5:0]              fixed_bl_i,      // range from 1 to 64
   input [2:0]              fixed_instr_i,   //RD              3'b001
                                            //RDP             3'b011
                                            //WR              3'b000
                                            //WRP             3'b010
                                            //REFRESH         3'b100
   input [31:0]             fixed_addr_i, // only upper 30 bits will be used
   // BRAM FIFO input
   input [31:0]             bram_addr_i,  //
   input [2:0]              bram_instr_i,
   input [5:0]              bram_bl_i,
   input                    bram_valid_i,
   output                   bram_rdy_o,

   input                    reading_rd_data_i,
   // mcb_flow_control interface
   input           rdy_i,

   output  [31:0]  addr_o,     // generated address
   output  [2:0]   instr_o,    // generated instruction
   output  [5:0]   bl_o,       // generated instruction
//   output reg [31:0]  m_addr_o,
   output          cmd_o_vld      // valid commands when asserted
  );

   localparam PRBS_ADDR_WIDTH = 32;
   localparam INSTR_PRBS_WIDTH = 16;
   localparam BL_PRBS_WIDTH    = 16;

localparam BRAM_DATAL_MODE       =    4'b0000;
localparam FIXED_DATA_MODE       =    4'b0001;
localparam ADDR_DATA_MODE        =    4'b0010;
localparam HAMMER_DATA_MODE      =    4'b0011;
localparam NEIGHBOR_DATA_MODE    =    4'b0100;
localparam WALKING1_DATA_MODE    =    4'b0101;
localparam WALKING0_DATA_MODE    =    4'b0110;
localparam PRBS_DATA_MODE        =    4'b0111;

reg [10:0] INC_COUNTS;
reg [2:0]  addr_mode_reg;
reg [1:0]  bl_mode_reg;

reg [31:0] addr_counts;
reg [31:0] addr_counts_next_r;

wire  [14:0]  prbs_bl;
reg [2:0] instr_out;
wire [14:0] prbs_instr_a;
wire [14:0] prbs_instr_b;

reg  [5:0]   prbs_brlen;

wire [31:0] prbs_addr;
wire [31:0] seq_addr;
wire [31:0] fixed_addr;
reg [31:0] addr_out ;
reg [5:0]  bl_out;
reg [5:0] bl_out_reg;
reg mode_load_d1;
reg mode_load_d2;
reg mode_load_pulse;
wire [41:0] pipe_data_o;
wire     cmd_clk_en;

wire     pipe_out_vld;
reg [15:0] end_addr_range;

reg force_bl1;
reg A0_G_E0;
reg A1_G_E1;
reg A2_G_E2;
reg A3_G_E3;
reg AC3_G_E3;
reg AC2_G_E2;
reg AC1_G_E1;
reg bl_out_clk_en;
reg [41:0] pipe_data_in;
reg instr_vld;
reg bl_out_vld;
reg pipe_data_in_vld;
reg gen_addr_larger ;
    reg [6:0] buf_avail_r;
    reg [6:0] rd_data_received_counts;
    reg [6:0] rd_data_counts_asked;

    reg [15:0] rd_data_received_counts_total;
reg instr_vld_dly1;
reg first_load_pulse;
reg mem_init_done;
reg refresh_cmd_en ;
reg [9:0] refresh_timer;
reg       refresh_prbs;
reg       cmd_vld;
reg run_traffic_r;
reg run_traffic_pulse;
always @ (posedge clk_i)
begin
     run_traffic_r <= #TCQ run_traffic_i;
     if (  run_traffic_i &&   ~run_traffic_r )
          run_traffic_pulse <= #TCQ 1'b1;
     else
          run_traffic_pulse <= #TCQ 1'b0;
end     
     

// commands go through pipeline inserters
assign addr_o       = pipe_data_o[31:0];
assign instr_o      = pipe_data_o[34:32];
assign bl_o         = pipe_data_o[40:35];


assign cmd_o_vld    = pipe_data_o[41] & run_traffic_r;
assign pipe_out_vld = pipe_data_o[41] & run_traffic_r;


assign pipe_data_o = pipe_data_in;

always @(posedge clk_i) begin                    

     instr_vld        <=  #TCQ  (cmd_clk_en | (mode_load_pulse & first_load_pulse));
     bl_out_clk_en    <=  #TCQ  (cmd_clk_en | (mode_load_pulse & first_load_pulse));
     bl_out_vld       <=  #TCQ  bl_out_clk_en;
     pipe_data_in_vld <=  #TCQ  instr_vld;
 end

always @ (posedge clk_i) begin
 if (rst_i[0])
    first_load_pulse <= #TCQ 1'b1;
 else if (mode_load_pulse)
    first_load_pulse <= #TCQ 1'b0;
 else
    first_load_pulse <= #TCQ first_load_pulse;
 end
 
generate
if (CMD_PATTERN == "CGEN_BRAM")  begin: cv1

always @(posedge clk_i) begin 
    cmd_vld          <=  #TCQ (cmd_clk_en ); 
                   
end
end endgenerate


generate
if (CMD_PATTERN != "CGEN_BRAM")  begin: cv2

always @(posedge clk_i) begin 
    cmd_vld          <=  #TCQ (cmd_clk_en | (mode_load_pulse & first_load_pulse )); 
                   
end
end endgenerate

 
assign cmd_clk_en =  ( rdy_i & pipe_out_vld & run_traffic_i ||  mode_load_pulse && (CMD_PATTERN == "CGEN_BRAM"));
 

 
integer i;
generate
if (FAMILY == "SPARTAN6")  begin: pipe_in_s6
    always @ (posedge clk_i) begin
    if (rst_i[0])
       pipe_data_in[31:0] <= #TCQ    start_addr_i;
    else if (instr_vld)
         if (gen_addr_larger && (addr_mode_reg == 3'b100 || addr_mode_reg == 3'b010)) 
            if (DWIDTH == 32)
              pipe_data_in[31:0] <= #TCQ  {end_addr_i[31:8],8'h0};
            else if (DWIDTH == 64)
              pipe_data_in[31:0] <= #TCQ  {end_addr_i[31:9],9'h0};
            else
              pipe_data_in[31:0] <= #TCQ  {end_addr_i[31:10],10'h0};
            
         else begin
             if (DWIDTH == 32)
              pipe_data_in[31:0] <= #TCQ    {addr_out[31:2],2'b00} ;
             else if (DWIDTH == 64)
              pipe_data_in[31:0] <= #TCQ    {addr_out[31:3],3'b000} ;
             else if (DWIDTH == 128)
              pipe_data_in[31:0] <= #TCQ    {addr_out[31:4],4'b0000} ;
             end
end

end endgenerate

generate
if (FAMILY == "VIRTEX6")  begin: pipe_in_v6
    always @ (posedge clk_i) begin
    if (rst_i[1])
       pipe_data_in[31:0] <= #TCQ    start_addr_i;
    else if (instr_vld)
       // address
      if (gen_addr_larger && (addr_mode_reg == 3'b100 || addr_mode_reg == 3'b010)) //(AC3_G_E3 && AC2_G_E2 && AC1_G_E1  )
              pipe_data_in[31:0] <= #TCQ  {end_addr_i[31:8],8'h0};
      else if ((NUM_DQ_PINS >= 128) && (NUM_DQ_PINS <=  144))
      begin
         if (MEM_BURST_LEN == 8)
            pipe_data_in[31:0] <= #TCQ    {addr_out[31:7], 7'b0000000};
         else      
            pipe_data_in[31:0] <= #TCQ    {addr_out[31:6], 6'b000000};
       end
            
      else if ((NUM_DQ_PINS >= 64) && (NUM_DQ_PINS < 128))
            begin

         if (MEM_BURST_LEN == 8)
            pipe_data_in[31:0] <= #TCQ    {addr_out[31:6], 6'b000000};
         else
         pipe_data_in[31:0] <= #TCQ    {addr_out[31:5], 5'b00000};
       end
         
      else if ((NUM_DQ_PINS == 32) || (NUM_DQ_PINS == 40) || (NUM_DQ_PINS == 48) || (NUM_DQ_PINS == 56))
            begin

         if (MEM_BURST_LEN == 8)     
            pipe_data_in[31:0] <= #TCQ    {addr_out[31:5], 5'b00000};
         else
         pipe_data_in[31:0] <= #TCQ    {addr_out[31:4], 4'b0000};
       end
         
      else if ((NUM_DQ_PINS == 16) || (NUM_DQ_PINS == 24))
         if (MEM_BURST_LEN == 8)     
            pipe_data_in[31:0] <= #TCQ    {addr_out[31:4], 4'b0000};
         else
         pipe_data_in[31:0] <= #TCQ    {addr_out[31:3], 3'b000};
         
      else if ((NUM_DQ_PINS == 8) )
         if (MEM_BURST_LEN == 8)             
            pipe_data_in[31:0] <= #TCQ    {addr_out[31:3], 3'b000};
         else
         pipe_data_in[31:0] <= #TCQ    {addr_out[31:2], 2'b00};
         
end

end endgenerate


//generate
//if (FAMILY == "VIRTEX6")  begin: pipe_m_addr_o
//    always @ (posedge clk_i) begin
//    if (rst_i[1])
//       m_addr_o[31:0] <= #TCQ    start_addr_i;
//    else if (instr_vld)
//      if (gen_addr_larger && (addr_mode_reg == 3'b100 || addr_mode_reg == 3'b010)) //(AC3_G_E3 && AC2_G_E2 && AC1_G_E1  )
//              m_addr_o[31:0] <= #TCQ  {end_addr_i[31:8],8'h0};
//      else if ((NUM_DQ_PINS >= 128 && NUM_DQ_PINS < 256))  
//         m_addr_o <= #TCQ  {addr_out[31:6], 6'b00000} ;
//              
//      else if ((NUM_DQ_PINS >= 64 && NUM_DQ_PINS < 128))  
//         m_addr_o <= #TCQ  {addr_out[31:5], 5'b00000} ;
//         
//      else if ((NUM_DQ_PINS == 32) || (NUM_DQ_PINS == 40) || (NUM_DQ_PINS == 48) || (NUM_DQ_PINS == 56))
//         m_addr_o[31:0] <= #TCQ    {addr_out[31:4], 4'b0000};
//      else if ((NUM_DQ_PINS == 16) || (NUM_DQ_PINS == 24))
//         m_addr_o[31:0] <= #TCQ    {addr_out[31:3], 3'b000};
//      else if ((NUM_DQ_PINS == 8) )
//         m_addr_o[31:0] <= #TCQ    {addr_out[31:2], 2'b00};
//end
//
//end endgenerate
reg force_wrcmd_gen;
   always @ (posedge clk_i) begin
    if (rst_i[0])
         force_wrcmd_gen <= #TCQ  1'b0;
    else if (buf_avail_r == 63)
         force_wrcmd_gen <= #TCQ  1'b0;
    else if (instr_vld_dly1 && pipe_data_in[32]== 1 && pipe_data_in[41:35] > 16)
         force_wrcmd_gen <= #TCQ  1'b1;
    end

reg [3:0]instr_mode_reg;
 always @ (posedge clk_i)
 begin
      instr_mode_reg <= #TCQ  instr_mode_i;
 end 
reg force_smallvalue;
 always @ (posedge clk_i)
 begin
    if (rst_i[2]) begin
       pipe_data_in[40:32] <= #TCQ    'b0;
       force_smallvalue <= #TCQ  1'b0;
       end
    else if (instr_vld) begin
      if (instr_mode_reg == 0) begin
              pipe_data_in[34:32] <= #TCQ    instr_out;
              end
      else if (instr_out[2]) begin
              pipe_data_in[34:32] <= #TCQ    3'b100;
              end
        //
      else if ( FAMILY == "SPARTAN6" && PORT_MODE == "RD_MODE")
      begin
            pipe_data_in[34:32] <= #TCQ  {instr_out[2:1],1'b1};
              end
            
      else if ((force_wrcmd_gen || buf_avail_r <=  15) && FAMILY == "SPARTAN6" &&  PORT_MODE != "RD_MODE")
      begin
            pipe_data_in[34:32] <= #TCQ    {instr_out[2],2'b00};
              end
      else begin
             pipe_data_in[34:32] <= #TCQ    instr_out; 
              end

   //********* condition the generated bl value except if TG is programmed for BRAM interface'
   // if the generated address is close to end address range, the bl_out will be altered to 1.
     if (bl_mode_i[1:0] == 2'b00)                                        // if programmed BRAM interface
          pipe_data_in[40:35] <=  #TCQ   bl_out;
     else if (FAMILY == "VIRTEX6")
              pipe_data_in[40:35] <=  #TCQ   bl_out;
     else if (force_bl1 && (bl_mode_reg == 2'b10 ) && FAMILY == "SPARTAN6") //PRBS_BL

      pipe_data_in[40:35] <=  #TCQ   6'b000001;
     else if ((buf_avail_r[5:0]  >= 6'b111100 && buf_avail_r[6] == 1'b0) && pipe_data_in[32] == 1'b1 && FAMILY == "SPARTAN6")         //read instructon


       begin
        if (bl_mode_reg == 2'b10)
            force_smallvalue    <= #TCQ  ~force_smallvalue;
      
        if ((buf_avail_r[6] && bl_mode_reg == 2'b10))


             pipe_data_in[40:35] <= #TCQ    {2'b0,bl_out[3:1],1'b1};
        else
            pipe_data_in[40:35] <=   #TCQ  bl_out;
        end
   else if (buf_avail_r  < 64 && rd_buff_avail_i >= 0 && instr_out[0] == 1'b1 && (bl_mode_reg == 2'b10 )) 
         if (FAMILY == "SPARTAN6")
         pipe_data_in[40:35] <=  #TCQ   {2'b0,bl_out[3:0] + 1};
         else
            pipe_data_in[40:35] <=   #TCQ  bl_out;

    end  //else instr_vld
 end // always

always @ (posedge clk_i) 
begin
     if (rst_i[2])
        pipe_data_in[41] <=  #TCQ   'b0;
     else if (cmd_vld)
        pipe_data_in[41] <=  #TCQ   instr_vld;//instr_vld;
     else if (rdy_i && pipe_out_vld)
        pipe_data_in[41] <=  #TCQ   1'b0;
 end

 always @ (posedge clk_i)
    instr_vld_dly1  <=  #TCQ instr_vld;

always @ (posedge clk_i) begin
 if (rst_i[0]) begin
    rd_data_counts_asked <= #TCQ  'b0;
  end else if (instr_vld_dly1 && pipe_data_in[32]== 1) begin
    if (pipe_data_in[40:35] == 0)
       rd_data_counts_asked <=  #TCQ rd_data_counts_asked + (64) ;
    else
       rd_data_counts_asked <=  #TCQ rd_data_counts_asked + (pipe_data_in[40:35]) ;

    end
 end

always @ (posedge clk_i) begin
 if (rst_i[0]) begin
     rd_data_received_counts <= #TCQ  'b0;
     rd_data_received_counts_total <= #TCQ  'b0;
  end else if(reading_rd_data_i) begin
     rd_data_received_counts <= #TCQ  rd_data_received_counts + 1;
     rd_data_received_counts_total <= #TCQ  rd_data_received_counts_total + 1;
     end
 end

 // calculate how many buf still available
 always @ (posedge clk_i)
     buf_avail_r <= #TCQ  (rd_data_received_counts + 64) - rd_data_counts_asked;

localparam BRAM_ADDR       = 2'b00;
localparam FIXED_ADDR      = 2'b01;
localparam PRBS_ADDR       = 2'b10;
localparam SEQUENTIAL_ADDR = 2'b11;

// registered the mode settings
always @ (posedge clk_i) begin
   if (rst_i[3])
        if (CMD_PATTERN == "CGEN_BRAM")
         addr_mode_reg  <= #TCQ    3'b000;
        else                                     
         addr_mode_reg  <= #TCQ    3'b011;
   else if (mode_load_pulse)
         addr_mode_reg  <= #TCQ    addr_mode_i;
end

always @ (posedge clk_i) begin
   if (mode_load_pulse) begin
        bl_mode_reg    <= #TCQ    bl_mode_i ;
   end
   mode_load_d1         <= #TCQ    mode_load_i;
   mode_load_d2         <= #TCQ    mode_load_d1;
end

always @ (posedge clk_i)
     mode_load_pulse <= #TCQ  mode_load_d1 & ~mode_load_d2;

// MUX the addr pattern out depending on the addr_mode setting

// "000" = bram; takes the address from bram output
// "001" = fixed address from the fixed_addr input
// "010" = psuedo ramdom pattern; generated from internal 64 bit LFSR
// "011" = sequential
// "100" = mode that used for prbs addr , prbs bl and prbs data
//always @(addr_mode_reg,prbs_addr,seq_addr,fixed_addr,bram_addr_i,data_mode_i)
always @ (posedge clk_i) begin
if (rst_i[3])
  addr_out <= #TCQ    start_addr_i;
else
   case({addr_mode_reg})
         3'b000: addr_out <= #TCQ    bram_addr_i;
         3'b001: addr_out <= #TCQ    fixed_addr;
         3'b010: addr_out <= #TCQ    prbs_addr;
         3'b011: addr_out <= #TCQ    {2'b0,seq_addr[29:0]};
         3'b100: addr_out <= #TCQ    {2'b00,seq_addr[6:2],seq_addr[23:0]};//{prbs_addr[31:6],6'b000000} ;
         3'b101: addr_out <= #TCQ    {prbs_addr[31:20],seq_addr[19:0]} ;

         default : addr_out <= #TCQ    'b0;
   endcase
end

//  ADDR PRBS GENERATION
generate
if (CMD_PATTERN == "CGEN_PRBS" || CMD_PATTERN == "CGEN_ALL" ) begin: gen_prbs_addr
cmd_prbs_gen #
  ( 
    .TCQ               (TCQ),
    .FAMILY      (FAMILY),
    .ADDR_WIDTH          (32),
    .DWIDTH     (DWIDTH),
    .PRBS_WIDTH (32),
    .SEED_WIDTH (32),
    .PRBS_EADDR_MASK_POS          (PRBS_EADDR_MASK_POS ),
    .PRBS_SADDR_MASK_POS           (PRBS_SADDR_MASK_POS  ),
    .PRBS_EADDR         (PRBS_EADDR),
    .PRBS_SADDR          (PRBS_SADDR )
   )
   addr_prbs_gen
  (
   .clk_i            (clk_i),
   .clk_en           (cmd_clk_en),
   .prbs_seed_init   (mode_load_pulse),
   .prbs_seed_i      (cmd_seed_i[31:0]),
   .prbs_o           (prbs_addr)
  );
end
endgenerate

always @ (posedge clk_i) begin
if (addr_out[31:8] >= end_addr_i[31:8])
    gen_addr_larger <=     1'b1;
else
    gen_addr_larger <=     1'b0;
end

generate
if (FAMILY == "SPARTAN6" ) begin : INC_COUNTS_S
always @ (posedge clk_i)
if (mem_init_done)
    INC_COUNTS <= #TCQ  (DWIDTH/8)*(bl_out_reg);
else  begin
    if (fixed_bl_i == 0)
       INC_COUNTS <= #TCQ  (DWIDTH/8)*(64);
    else
       INC_COUNTS <= #TCQ  (DWIDTH/8)*(fixed_bl_i);
    end
end
endgenerate
//converting string to integer
//localparam MEM_BURST_INT = (MEM_BURST_LEN == "8")? 8 : 4;
localparam MEM_BURST_INT = MEM_BURST_LEN ;


generate
if (FAMILY == "VIRTEX6" ) begin : INC_COUNTS_V
    always @ (posedge clk_i) begin
    
if ( (NUM_DQ_PINS >= 128 && NUM_DQ_PINS <= 144))       //256
     INC_COUNTS <= #TCQ  64 * (MEM_BURST_INT/4);
    
else if ( (NUM_DQ_PINS >= 64 && NUM_DQ_PINS < 128))       //256
     INC_COUNTS <= #TCQ  32 * (MEM_BURST_INT/4);
else if ((NUM_DQ_PINS >= 32) && (NUM_DQ_PINS < 64))   //128
     INC_COUNTS <= #TCQ  16 * (MEM_BURST_INT/4)   ;
else if ((NUM_DQ_PINS == 16) || (NUM_DQ_PINS == 24))  //64
     INC_COUNTS <= #TCQ  8 * (MEM_BURST_INT/4);
else if ((NUM_DQ_PINS == 8) )
     INC_COUNTS <= #TCQ  4 * (MEM_BURST_INT/4);
end
end
endgenerate

generate
// Sequential Address pattern
// It is generated when rdy_i is valid and write command is valid and bl_cmd is valid.
reg [31:0] end_addr_r;

always @ (posedge clk_i) begin
     end_addr_r <= #TCQ  end_addr_i - DWIDTH/8*fixed_bl_i +1;
end

always @ (posedge clk_i) begin
if (addr_out[31:24] >= end_addr_r[31:24])
    AC3_G_E3 <= #TCQ    1'b1;
else
    AC3_G_E3 <= #TCQ    1'b0;

if (addr_out[23:16] >= end_addr_r[23:16])
    AC2_G_E2 <= #TCQ    1'b1;
else
    AC2_G_E2 <= #TCQ    1'b0;

if (addr_out[15:8] >= end_addr_r[15:8])
    AC1_G_E1 <= #TCQ    1'b1;
else
    AC1_G_E1 <= #TCQ    1'b0;
end

//if (CMD_PATTERN == "CGEN_SEQUENTIAL" || CMD_PATTERN == "CGEN_ALL" ) begin : seq_addr_gen
    assign seq_addr = addr_counts;

reg mode_load_pulse_r1;

always @ (posedge clk_i)
begin
    mode_load_pulse_r1 <= #TCQ  mode_load_pulse;

end

always @ (posedge clk_i)
    end_addr_range <= #TCQ    end_addr_i[15:0] - (DWIDTH/8 *bl_out_reg) + 1   ;

always @ (posedge clk_i)
    addr_counts_next_r <= #TCQ    addr_counts  + INC_COUNTS   ;

reg cmd_clk_en_r;
always @ (posedge clk_i)
  cmd_clk_en_r <= #TCQ  cmd_clk_en;
always @ (posedge clk_i) begin
   if (rst_i[4]) begin
        addr_counts <= #TCQ    start_addr_i;
        mem_init_done <= #TCQ  1'b0;
  end else if (cmd_clk_en_r || mode_load_pulse_r1)
    if(addr_counts_next_r>= end_addr_i) begin
                addr_counts <= #TCQ    start_addr_i;
                mem_init_done <= #TCQ  1'b1;
    end else if(addr_counts < end_addr_r)  // address counts get incremented by burst_length and port size each wr command generated
                addr_counts <= #TCQ    addr_counts + INC_COUNTS;
end

 // end begin
//end
endgenerate

generate
// Fixed Address pattern
if (CMD_PATTERN == "CGEN_FIXED" || CMD_PATTERN == "CGEN_ALL" ) begin : fixed_addr_gen
    assign fixed_addr = (DWIDTH == 32)?  {fixed_addr_i[31:2],2'b0} :
                        (DWIDTH == 64)?  {fixed_addr_i[31:3],3'b0}:
                        (DWIDTH <= 128)? {fixed_addr_i[31:4],4'b0}:
                        (DWIDTH <= 256)? {fixed_addr_i[31:5],5'b0}:
                                         {fixed_addr_i[31:6],6'b0};
  end
endgenerate

generate
// BRAM Address pattern
if (CMD_PATTERN == "CGEN_BRAM" || CMD_PATTERN == "CGEN_ALL" ) begin : bram_addr_gen
assign bram_rdy_o = run_traffic_i & cmd_clk_en & bram_valid_i | mode_load_pulse;
end
endgenerate

///////////////////////////////////////////////////////////////////////////
//  INSTR COMMAND GENERATION

// tap points are 3,2
//`define RD              3'b001
//`define RDP             3'b011
//`define WR              3'b000
//`define WRP             3'b010
//`define REFRESH         3'b100
// use 14 stages  1 sr16; tap position 1,3,5,14

reg [9:0]force_rd_counts;
reg force_rd;
always @ (posedge clk_i) begin
if (rst_i[4])
    force_rd_counts <= #TCQ  'b0;
else if (instr_vld) begin
    force_rd_counts <= #TCQ  force_rd_counts + 1;
    end
end

always @ (posedge clk_i) begin
if (rst_i[4])
    force_rd <= #TCQ  1'b0;
else if (force_rd_counts[3])
    force_rd <= #TCQ  1'b1;
else
    force_rd <= #TCQ  1'b0;
end


// adding refresh timer to limit the amount of issuing refresh command.
always @ (posedge clk_i) begin
if (rst_i[4])
   refresh_timer <= #TCQ  'b0;
else
   refresh_timer <= #TCQ  refresh_timer + 1'b1;

end

always @ (posedge clk_i) begin
if (rst_i[4])
   refresh_cmd_en <= #TCQ  'b0;
//else if (refresh_timer >= 12'hff0 && refresh_timer <= 12'hfff)
else if (refresh_timer == 10'h3ff)

   refresh_cmd_en <= #TCQ  'b1;
else if (cmd_clk_en && refresh_cmd_en)
   refresh_cmd_en <= #TCQ  'b0;

end   

always @ (posedge clk_i) begin
if (FAMILY == "SPARTAN6")
    refresh_prbs <= #TCQ  prbs_instr_b[3] & refresh_cmd_en;
else
    refresh_prbs <= #TCQ  1'b0;
end    
  //synthesis translate_off
always @ (instr_mode_i)
  if(instr_mode_i  >2 && FAMILY == "VIRTEX6") begin
   $display("Error ! Not valid instruction mode");
   $stop;
   end
  //synthesis translate_on

always @ (posedge clk_i) begin
   case(instr_mode_i)
         0: instr_out <= #TCQ    bram_instr_i;
         1: instr_out <= #TCQ    fixed_instr_i;
         2: instr_out <= #TCQ    {2'b00,(prbs_instr_a[0] | force_rd)};
         3: instr_out <= #TCQ    {2'b0,prbs_instr_a[0]};  //:  WP/RP
         4: instr_out <= #TCQ    {1'b0,prbs_instr_b[0], prbs_instr_a[0]};  //  W/WP/R/RP.
         // may be add another PRBS for generating REFRESH
//         5: instr_out <= #TCQ    {prbs_instr_b[3],prbs_instr_b[0], prbs_instr_a[0]};  // W/WP/R/RP/REFRESH W/WP/R/RP/REFRESH
         5: instr_out <= #TCQ    {refresh_prbs ,prbs_instr_b[0], prbs_instr_a[0]};  // W/WP/R/RP/REFRESH W/WP/R/RP/REFRESH


         default : instr_out <= #TCQ    {2'b00,prbs_instr_a[0]};
   endcase
end

generate  // PRBS INSTRUCTION generation
// use two PRBS generators and tap off 1 bit from each to create more randomness for
// generating actual read/write commands
if (CMD_PATTERN == "CGEN_PRBS" || CMD_PATTERN == "CGEN_ALL" ) begin: gen_prbs_instr
cmd_prbs_gen #
  (
    .TCQ               (TCQ),
    .PRBS_CMD    ("INSTR"),
    .ADDR_WIDTH  (32),
    .SEED_WIDTH  (15),
    .PRBS_WIDTH  (20)
   )
   instr_prbs_gen_a
  (
   .clk_i              (clk_i),
   .clk_en             (cmd_clk_en),
   .prbs_seed_init     (load_seed_i),
   .prbs_seed_i        (cmd_seed_i[14:0]),
   .prbs_o             (prbs_instr_a)
  );

cmd_prbs_gen #
  (
    .PRBS_CMD    ("INSTR"),
    .SEED_WIDTH  (15),
    .PRBS_WIDTH  (20)
   )
   instr_prbs_gen_b
  (
   .clk_i              (clk_i),
   .clk_en             (cmd_clk_en),
   .prbs_seed_init     (load_seed_i),
   .prbs_seed_i        (cmd_seed_i[16:2]),
   .prbs_o             (prbs_instr_b)
  );
end
endgenerate

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BURST LENGTH GENERATION
// burst length code = user burst length input - 1
// mcb_flow_control does the minus before sending out to mcb\
// when filling up the memory, need to make sure bl doesn't go beyound its upper limit boundary
//assign force_bl1 = (addr_out[31:0] >= (end_addr_i[31:0] - 4*64)) ? 1'b1: 1'b0;
// for neighbour pattern, need to limit the bl to make sure it is within column size boundary.

// check bl validity

always @ (posedge clk_i) begin
if (addr_out[31:24] >= end_addr_i[31:24])
    A3_G_E3 <= #TCQ    1'b1;
else
    A3_G_E3 <= #TCQ    1'b0;

if (addr_out[23:16] >= end_addr_i[23:16])
    A2_G_E2 <= #TCQ    1'b1;
else
    A2_G_E2 <= #TCQ    1'b0;

if (addr_out[15:8] >= end_addr_i[15:8])
    A1_G_E1 <= #TCQ    1'b1;
else
    A1_G_E1 <= #TCQ    1'b0;

if (addr_out[7:0] > end_addr_i[7:0] - DWIDTH/8* bl_out + 1)
    A0_G_E0 <= #TCQ    1'b1;
else
    A0_G_E0 <= #TCQ    1'b0;
end

always @(addr_out,bl_out,end_addr_i,rst_i,buf_avail_r) begin
    if (rst_i[5])
        force_bl1 =   1'b0;
    else if (((addr_out + bl_out* (DWIDTH/8)) >= end_addr_i) || (buf_avail_r  <= 50 && PORT_MODE == "RD_MODE"))
        force_bl1 =   1'b1;
    else
        force_bl1 =   1'b0;
end

always @(posedge clk_i) begin
   if (rst_i[6])
       bl_out_reg <= #TCQ    fixed_bl_i;
   else if (bl_out_vld)
       bl_out_reg <= #TCQ    bl_out;
end

always @ (posedge clk_i) begin
   if (mode_load_pulse)
        bl_out <= #TCQ    fixed_bl_i ;
   else if (cmd_clk_en) begin
     case({bl_mode_reg})
         0: bl_out <= #TCQ    bram_bl_i  ;
         1: bl_out <= #TCQ    fixed_bl_i ;
         2: bl_out <= #TCQ    prbs_brlen;
         default : bl_out <= #TCQ    6'h1;
     endcase
   end
end

  //synthesis translate_off
always @ (bl_out)
  if(bl_out >2 && FAMILY == "VIRTEX6") begin
   $display("Error ! Not valid burst length");
   $stop;
   end
  //synthesis translate_on

generate
if (CMD_PATTERN == "CGEN_PRBS" || CMD_PATTERN == "CGEN_ALL" ) begin: gen_prbs_bl
cmd_prbs_gen #
      (
    .TCQ               (TCQ),      
    .FAMILY      (FAMILY),
    .PRBS_CMD    ("BLEN"),
    .ADDR_WIDTH  (32),
    .SEED_WIDTH  (15),
    .PRBS_WIDTH  (20)
   )
   bl_prbs_gen
  (
   .clk_i             (clk_i),
   .clk_en            (cmd_clk_en),
   .prbs_seed_init    (load_seed_i),
   .prbs_seed_i       (cmd_seed_i[16:2]),
   .prbs_o            (prbs_bl)
  );
end

always @ (prbs_bl)
if (FAMILY == "SPARTAN6")  // supports 1 throug 64
    prbs_brlen =  (prbs_bl[5:0] == 6'b000000) ? 6'b000001: prbs_bl[5:0];
else // VIRTEX6 only supports 1 or 2 burst on user ports
     prbs_brlen =  6'b000010;
endgenerate

endmodule
