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
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: %version
//  \   \         Application: MIG
//  /   /         Filename: read_data_path.v
// /___/   /\     Date Last Modified: 
// \   \  /  \    Date Created: 
//  \___\/\___\
//
//Device: Spartan6
//Design Name: DDR/DDR2/DDR3/LPDDR 
//Purpose: This is top level of read path and also consist of comparison logic
//         for read data. 
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ps/1ps

module read_data_path #(
   parameter TCQ           = 100,

   parameter FAMILY = "VIRTEX6",
   parameter MEM_BURST_LEN = 8,
   parameter ADDR_WIDTH = 32,
   parameter CMP_DATA_PIPE_STAGES = 3,
   parameter DWIDTH = 32,
   parameter DATA_PATTERN = "DGEN_ALL", //"DGEN__HAMMER", "DGEN_WALING1","DGEN_WALING0","DGEN_ADDR","DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"  
   parameter NUM_DQ_PINS   = 8,
   parameter DQ_ERROR_WIDTH = 1,
   parameter SEL_VICTIM_LINE = 3,  // VICTIM LINE is one of the DQ pins is selected to be different than hammer pattern
   
   parameter MEM_COL_WIDTH = 10
   
    )
    (
      
   
   input                  clk_i, 
   input [9:0]                 rst_i,
   input                  manual_clear_error,
   output                 cmd_rdy_o, 
   input                  cmd_valid_i, 
   input [31:0]           prbs_fseed_i,
   
   input [3:0]            data_mode_i,
   input [2:0]           cmd_sent, 
   input [5:0]           bl_sent  ,
   input                 cmd_en_i ,
//   input [31:0]           m_addr_i, 
   input [DWIDTH-1:0]     fixed_data_i,    
   input [31:0]           addr_i, 
   input [5:0]            bl_i,
   
   
   output                 data_rdy_o, 
   input                  data_valid_i,
   input [DWIDTH-1:0]     data_i,
   output                 last_word_rd_o,
   output                 data_error_o,                  //data_error on user data bus side
   output [DWIDTH-1:0]    cmp_data_o,
   output [DWIDTH-1:0]    rd_mdata_o ,
   output                 cmp_data_valid,
   output [31:0]          cmp_addr_o,
   output [5 :0]          cmp_bl_o,
   output                 force_wrcmd_gen_o,
   output [6:0]           rd_buff_avail_o,
   output [DQ_ERROR_WIDTH - 1:0] dq_error_bytelane_cmp,   // V6: real time compare error byte lane
   output  [DQ_ERROR_WIDTH - 1:0] cumlative_dq_lane_error_r  // V6: latched error byte lane that occure on
                                                       //     first error
    
   );

   wire                   gen_rdy; 
   wire                   gen_valid; 
   wire [31:0]  gen_addr; 
   wire [5:0]    gen_bl;

   wire                   cmp_rdy; 
   wire                   cmp_valid; 
   wire [31:0]  cmp_addr; 
   wire [5:0]    cmp_bl;

   reg                    data_error;
   wire [DWIDTH-1:0]      cmp_data;
   reg  [DWIDTH-1:0]      cmp_data_r;
   reg  [DWIDTH-1:0]      cmp_data_r2;
   reg  [DWIDTH-1:0]      cmp_data_r3;
   reg  [DWIDTH-1:0]      cmp_data_r4;
   reg                    last_word_rd;
   reg [5:0]              bl_counter;
   wire                   cmd_rdy;
   wire                   user_bl_cnt_is_1;
   wire                   data_rdy;
   reg [DWIDTH:0] delayed_data;
   wire                  rd_mdata_en;
   reg [DWIDTH-1:0]      rd_data_r;
   reg [DWIDTH-1:0]      rd_data_r2;
   reg [DWIDTH-1:0]      rd_data_r3;
   reg [DWIDTH-1:0]      rd_data_r4;
   reg                   force_wrcmd_gen;
   reg                   wait_bl_end;
   reg                   wait_bl_end_r1;
reg l_data_error ;
reg u_data_error;
reg v6_data_cmp_valid;
wire [DWIDTH -1 :0] rd_v6_mdata;
reg [DWIDTH -1 :0] rd_v6_mdata_r1;
reg [DWIDTH -1 :0] rd_v6_mdata_r2;
reg [DWIDTH -1 :0] rd_v6_mdata_r3;
reg [DWIDTH -1 :0] rd_v6_mdata_r4;
reg [DWIDTH -1 :0] cmpdata_r;
wire [DWIDTH -1 :0] rd_mdata;
wire                rd_mdata_fifo_empty;
 reg cmp_data_en;


wire [ DQ_ERROR_WIDTH-1:0] dq_lane_error;
reg [ DQ_ERROR_WIDTH-1:0] dq_lane_error_r1;
reg [ DQ_ERROR_WIDTH-1:0] dq_lane_error_r2;
wire [ DQ_ERROR_WIDTH-1:0] cum_dq_lane_error_mask;
wire [ DQ_ERROR_WIDTH-1:0] cumlative_dq_lane_error_c;
reg [ DQ_ERROR_WIDTH-1:0] cumlative_dq_lane_error_reg;

reg data_valid_r;

  
      always @ (posedge clk_i) begin
             wait_bl_end_r1 <= #TCQ wait_bl_end;
             rd_data_r <= #TCQ data_i;
             rd_data_r2 <= #TCQ rd_data_r;
             rd_data_r3 <= #TCQ rd_data_r2;
             rd_data_r4 <= #TCQ rd_data_r3;
      end
  
   assign force_wrcmd_gen_o = force_wrcmd_gen;
  reg [7:0]         force_wrcmd_timeout_cnts ;

   always @ (posedge clk_i) begin
    if (rst_i[0])
         force_wrcmd_gen <= #TCQ 1'b0;
    else if ((wait_bl_end == 1'b0 &&  wait_bl_end_r1 == 1'b1) || force_wrcmd_timeout_cnts == 8'b11111111)
         force_wrcmd_gen <= #TCQ 1'b0;
   
    else if ((cmd_valid_i && bl_i > 16) || wait_bl_end )
         force_wrcmd_gen <= #TCQ 1'b1;
    end

  
   always @ (posedge clk_i) begin
    if (rst_i[0])
        force_wrcmd_timeout_cnts <= #TCQ 'b0;
    else if (wait_bl_end == 1'b0 &&  wait_bl_end_r1 == 1'b1)
        force_wrcmd_timeout_cnts <= #TCQ 'b0;
        
    else if (force_wrcmd_gen)
        force_wrcmd_timeout_cnts <= #TCQ force_wrcmd_timeout_cnts + 1;
   end
   
   always @ (posedge clk_i)
    if (rst_i[0])
         wait_bl_end <= #TCQ 1'b0;
    else if (force_wrcmd_timeout_cnts == 8'b11111111)
         wait_bl_end <= #TCQ 1'b0;
    
    else if (gen_rdy && gen_valid && gen_bl > 16)
         wait_bl_end <= #TCQ 1'b1;
    else if (wait_bl_end && user_bl_cnt_is_1)
         wait_bl_end <= #TCQ 1'b0;
   
   
   assign cmd_rdy_o = cmd_rdy;
   read_posted_fifo #(
           .TCQ               (TCQ),
           .FAMILY    (FAMILY),
           .MEM_BURST_LEN (MEM_BURST_LEN),
           .ADDR_WIDTH(32),
           .BL_WIDTH(6)
           )
   read_postedfifo(
                    .clk_i              (clk_i),
                    .rst_i                (rst_i[0]),
                    .cmd_rdy_o          (cmd_rdy      ),
                    .cmd_valid_i        (cmd_valid_i    ),
                    .data_valid_i         (data_rdy        ),  // input to
                    .addr_i             (addr_i         ),
                    .bl_i               (bl_i           ),
                    
                    .cmd_sent           (cmd_sent),
                    .bl_sent            (bl_sent ),
                    .cmd_en_i           (cmd_en_i),
                    
                    .user_bl_cnt_is_1   (user_bl_cnt_is_1),
                    .gen_rdy_i          (gen_rdy        ),
                    .gen_valid_o        (gen_valid      ),
                    .gen_addr_o         (gen_addr       ),
                    .gen_bl_o           (gen_bl         ),
                    .rd_buff_avail_o      (rd_buff_avail_o),
                    .rd_mdata_fifo_empty    (rd_mdata_fifo_empty),
                    .rd_mdata_en            (rd_mdata_en)
                    );


 
   
   rd_data_gen #(
              .TCQ               (TCQ),
              .FAMILY  (FAMILY),
              .MEM_BURST_LEN    (MEM_BURST_LEN),
              .NUM_DQ_PINS (NUM_DQ_PINS), 
              .SEL_VICTIM_LINE   (SEL_VICTIM_LINE),
   
              .DATA_PATTERN  (DATA_PATTERN),
              .DWIDTH(DWIDTH),
              .COLUMN_WIDTH     (MEM_COL_WIDTH)
              
              )
   rd_datagen(
            .clk_i              (clk_i          ),
            .rst_i              (rst_i[4:0]),            
            .prbs_fseed_i       (prbs_fseed_i),
            .data_mode_i        (data_mode_i    ),            
            .cmd_rdy_o          (gen_rdy        ),
            .cmd_valid_i        (gen_valid      ),  
            .last_word_o        (last_word_rd_o ),  
            
//            .m_addr_i           (m_addr_i       ),
            .fixed_data_i         (fixed_data_i),
            
            .addr_i             (gen_addr       ),
            .bl_i               (gen_bl         ),
            .user_bl_cnt_is_1_o   (user_bl_cnt_is_1),
            .data_rdy_i         (data_valid_i        ),  // input to
            .data_valid_o       (cmp_valid      ),
            .data_o             (cmp_data       ),
            .rd_mdata_en          (rd_mdata_en)
            );


   afifo #
   (
    .TCQ           (TCQ),
    .DSIZE         (DWIDTH),
    .FIFO_DEPTH    (32),
    .ASIZE         (5),
    .SYNC          (1)  // set the SYNC to 1 because rd_clk = wr_clk to reduce latency 
   
   
   )
   rd_mdata_fifo
   (
    .wr_clk        (clk_i),
    .rst           (rst_i[0]),
    .wr_en         (data_valid_i),
    .wr_data       (data_i),
    .rd_en         (rd_mdata_en),
    .rd_clk        (clk_i),
    .rd_data       (rd_v6_mdata),
    .full          (),
    .empty         (rd_mdata_fifo_empty),
    .almost_full   ()
   );

always @ (posedge clk_i)
begin
//    delayed_data <= #TCQ {cmp_valid & data_valid_i,cmp_data};
    cmp_data_r <= #TCQ cmp_data;
    cmp_data_r2 <= #TCQ cmp_data_r;
    cmp_data_r3 <= #TCQ cmp_data_r2;
    cmp_data_r4 <= #TCQ cmp_data_r3;
end

assign rd_mdata_o = rd_mdata;

assign rd_mdata = (FAMILY == "SPARTAN6") ? rd_data_r3: 
                  (FAMILY == "VIRTEX6" && MEM_BURST_LEN == 4)? rd_v6_mdata_r2:
                  rd_data_r;

assign cmp_data_valid = (FAMILY == "SPARTAN6") ? cmp_data_en :
                        (FAMILY == "VIRTEX6" && MEM_BURST_LEN == 4)? v6_data_cmp_valid :data_valid_i;



   
assign        cmp_data_o  = (FAMILY == "SPARTAN6") ? cmp_data_r3 : cmp_data_r2;
assign        cmp_addr_o  = gen_addr;
assign        cmp_bl_o    = gen_bl;


   
assign data_rdy_o = data_rdy;
assign data_rdy = cmp_valid & data_valid_i;

 always @ (posedge clk_i)
    v6_data_cmp_valid <= #TCQ rd_mdata_en;


 always @ (posedge clk_i)
       cmp_data_en <= #TCQ data_rdy;

 generate
 if (FAMILY == "SPARTAN6") begin: gen_error_1
   always @ (posedge clk_i)
     begin
       if (cmp_data_en)
           l_data_error <= #TCQ (rd_data_r[DWIDTH/2-1:0] !== cmp_data_r[DWIDTH/2-1:0]);           
        else
           l_data_error <= #TCQ 1'b0;

       if (cmp_data_en)
           u_data_error <= #TCQ (rd_data_r[DWIDTH-1:DWIDTH/2] !== cmp_data_r[DWIDTH-1:DWIDTH/2]);           
        else
           u_data_error <= #TCQ 1'b0;

       data_error <= #TCQ l_data_error | u_data_error;
      //synthesis translate_off
      if (data_error)
        $display ("ERROR: Expected data=%h and recieved data= %h @ %t" ,cmp_data_r4, rd_data_r4, $time);
      //synthesis translate_on
        
     end

end
endgenerate
wire [NUM_DQ_PINS/2 - 1:0] error_byte;   
reg [NUM_DQ_PINS/2 - 1:0] error_byte_r1;   

genvar i;
 generate
 if (FAMILY == "VIRTEX6" && MEM_BURST_LEN == 4) begin: gen_error_2


    for (i = 0; i < NUM_DQ_PINS/2; i = i + 1) begin: gen_cmp
      assign error_byte[i] 
               = (~rd_mdata_fifo_empty && rd_mdata_en && (rd_v6_mdata[8*(i+1)-1:8*i] !== cmp_data[8*(i+1)-1:8*i]) );  


    end

always @ (posedge clk_i)
begin
  rd_v6_mdata_r1 <= rd_v6_mdata;
  rd_v6_mdata_r2 <= rd_v6_mdata_r1;
  rd_v6_mdata_r3 <= rd_v6_mdata_r2;
  rd_v6_mdata_r4 <= rd_v6_mdata_r3;
end

always @ (posedge clk_i)
begin
    if (rst_i[1] || manual_clear_error) begin
    
      error_byte_r1 <= #TCQ 'b0;
      data_error <= #TCQ 1'b0;
      end
    else begin
      error_byte_r1 <= #TCQ error_byte;
      data_error <= #TCQ | error_byte_r1;
    
    
      //synthesis translate_off
      if (data_error)
        $display ("ERROR: Expected data=%h and recieved data= %h @ %t" ,cmp_data_r2,rd_v6_mdata_r2,$time);
      //synthesis translate_on
    end

end

  // remap the app_rd_data error byte locastion to dq bus side.
    for ( i = 0; i < DQ_ERROR_WIDTH; i = i+1) begin: gen_dq_error_map
        assign dq_lane_error[i] = (error_byte_r1[i] | error_byte_r1[i+DQ_ERROR_WIDTH] |
                              error_byte_r1[i+ (NUM_DQ_PINS*2/8)] | 
                              error_byte_r1[i+ (NUM_DQ_PINS*3/8)]);
                              
        assign cumlative_dq_lane_error_c[i] =  cumlative_dq_lane_error_r[i] | dq_lane_error_r1[i];
    end                         

                    
always @ (posedge clk_i)
begin
    if (rst_i[1] || manual_clear_error) begin
    
      dq_lane_error_r1 <= #TCQ 'b0;
      dq_lane_error_r2 <= #TCQ 'b0;
      data_valid_r <= #TCQ 1'b0;
      cumlative_dq_lane_error_reg <= #TCQ 'b0;
      end
    else begin
      data_valid_r <= #TCQ data_valid_i;
    
      dq_lane_error_r1 <= #TCQ dq_lane_error;
      cumlative_dq_lane_error_reg <= #TCQ cumlative_dq_lane_error_c;
    end
end
end
//end
endgenerate
     
 generate
 if (FAMILY == "VIRTEX6" && MEM_BURST_LEN == 8) begin: gen_error_3
    for (i = 0; i < NUM_DQ_PINS/2; i = i + 1) begin: gen_cmp
      assign error_byte[i] 
               = (data_valid_i && (data_i[8*(i+1)-1:8*i] !== cmp_data[8*(i+1)-1:8*i]) );  
    end
    
    
    
    
always @ (posedge clk_i)
begin
    if (rst_i[1] || manual_clear_error) begin
    
      error_byte_r1 <= #TCQ 'b0;
      data_error <= #TCQ 1'b0;
      end
    else begin

    error_byte_r1 <= #TCQ error_byte;
    data_error <= #TCQ | error_byte_r1;
    
      //synthesis translate_off
    if (data_error)
        $display ("ERROR: Expected data=%h and recieved data= %h @ %t" ,cmp_data_r2,rd_data_r2,$time);
      //synthesis translate_on
      
    end
end


    for ( i = 0; i < DQ_ERROR_WIDTH; i = i+1) begin: gen_dq_error_map
        assign dq_lane_error[i] = (error_byte_r1[i] | error_byte_r1[i+DQ_ERROR_WIDTH] |
                              error_byte_r1[i+ (NUM_DQ_PINS*2/8)] | 
                              error_byte_r1[i+ (NUM_DQ_PINS*3/8)]);
                              
        assign cumlative_dq_lane_error_c[i] =  cumlative_dq_lane_error_r[i] | dq_lane_error_r1[i];
    end                         


always @ (posedge clk_i)
begin
    if (rst_i[1] || manual_clear_error) begin
    
      dq_lane_error_r1 <= #TCQ 'b0;
      dq_lane_error_r2 <= #TCQ 'b0;
      data_valid_r <= #TCQ 1'b0;
      cumlative_dq_lane_error_reg <= #TCQ 'b0;
      end
    else begin
      data_valid_r <= #TCQ data_valid_i;
      dq_lane_error_r1 <= #TCQ dq_lane_error;
      cumlative_dq_lane_error_reg <= #TCQ cumlative_dq_lane_error_c;
    end
end
end
//end
endgenerate
    
assign cumlative_dq_lane_error_r = cumlative_dq_lane_error_reg;     
assign dq_error_bytelane_cmp = dq_lane_error_r1;     
assign data_error_o = data_error;

     
endmodule 

