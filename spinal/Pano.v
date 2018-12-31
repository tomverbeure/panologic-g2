// Generator : SpinalHDL v1.3.0    git head : a4aa217960e9fd6394cc93913205fac49fac47d4
// Date      : 30/12/2018, 22:48:07
// Component : Pano


`define BranchCtrlEnum_defaultEncoding_type [1:0]
`define BranchCtrlEnum_defaultEncoding_INC 2'b00
`define BranchCtrlEnum_defaultEncoding_B 2'b01
`define BranchCtrlEnum_defaultEncoding_JAL 2'b10
`define BranchCtrlEnum_defaultEncoding_JALR 2'b11

`define AluCtrlEnum_defaultEncoding_type [1:0]
`define AluCtrlEnum_defaultEncoding_ADD_SUB 2'b00
`define AluCtrlEnum_defaultEncoding_SLT_SLTU 2'b01
`define AluCtrlEnum_defaultEncoding_BITWISE 2'b10

`define EnvCtrlEnum_defaultEncoding_type [0:0]
`define EnvCtrlEnum_defaultEncoding_NONE 1'b0
`define EnvCtrlEnum_defaultEncoding_XRET 1'b1

`define ShiftCtrlEnum_defaultEncoding_type [1:0]
`define ShiftCtrlEnum_defaultEncoding_DISABLE_1 2'b00
`define ShiftCtrlEnum_defaultEncoding_SLL_1 2'b01
`define ShiftCtrlEnum_defaultEncoding_SRL_1 2'b10
`define ShiftCtrlEnum_defaultEncoding_SRA_1 2'b11

`define AluBitwiseCtrlEnum_defaultEncoding_type [1:0]
`define AluBitwiseCtrlEnum_defaultEncoding_XOR_1 2'b00
`define AluBitwiseCtrlEnum_defaultEncoding_OR_1 2'b01
`define AluBitwiseCtrlEnum_defaultEncoding_AND_1 2'b10
`define AluBitwiseCtrlEnum_defaultEncoding_SRC1 2'b11

`define Src2CtrlEnum_defaultEncoding_type [1:0]
`define Src2CtrlEnum_defaultEncoding_RS 2'b00
`define Src2CtrlEnum_defaultEncoding_IMI 2'b01
`define Src2CtrlEnum_defaultEncoding_IMS 2'b10
`define Src2CtrlEnum_defaultEncoding_PC 2'b11

`define Src1CtrlEnum_defaultEncoding_type [1:0]
`define Src1CtrlEnum_defaultEncoding_RS 2'b00
`define Src1CtrlEnum_defaultEncoding_IMU 2'b01
`define Src1CtrlEnum_defaultEncoding_PC_INCREMENT 2'b10
`define Src1CtrlEnum_defaultEncoding_URS1 2'b11

`define UlpiState_defaultEncoding_type [3:0]
`define UlpiState_defaultEncoding_WaitIdle 4'b0000
`define UlpiState_defaultEncoding_Idle 4'b0001
`define UlpiState_defaultEncoding_Rx 4'b0010
`define UlpiState_defaultEncoding_Tx 4'b0011
`define UlpiState_defaultEncoding_RegWrAddr 4'b0100
`define UlpiState_defaultEncoding_RegWrData 4'b0101
`define UlpiState_defaultEncoding_RegWrStp 4'b0110
`define UlpiState_defaultEncoding_RegRdAddr 4'b0111
`define UlpiState_defaultEncoding_RegRdTurn 4'b1000
`define UlpiState_defaultEncoding_RegRdData 4'b1001

module StreamFifoLowLatency (
      input   io_push_valid,
      output  io_push_ready,
      input   io_push_payload_error,
      input  [31:0] io_push_payload_inst,
      output reg  io_pop_valid,
      input   io_pop_ready,
      output reg  io_pop_payload_error,
      output reg [31:0] io_pop_payload_inst,
      input   io_flush,
      output [0:0] io_occupancy,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire [0:0] _zz_StreamFifoLowLatency_5_;
  reg  _zz_StreamFifoLowLatency_1_;
  reg  pushPtr_willIncrement;
  reg  pushPtr_willClear;
  wire  pushPtr_willOverflowIfInc;
  wire  pushPtr_willOverflow;
  reg  popPtr_willIncrement;
  reg  popPtr_willClear;
  wire  popPtr_willOverflowIfInc;
  wire  popPtr_willOverflow;
  wire  ptrMatch;
  reg  risingOccupancy;
  wire  empty;
  wire  full;
  wire  pushing;
  wire  popping;
  wire [32:0] _zz_StreamFifoLowLatency_2_;
  wire [32:0] _zz_StreamFifoLowLatency_3_;
  reg [32:0] _zz_StreamFifoLowLatency_4_;
  assign _zz_StreamFifoLowLatency_5_ = _zz_StreamFifoLowLatency_2_[0 : 0];
  always @ (*) begin
    _zz_StreamFifoLowLatency_1_ = 1'b0;
    pushPtr_willIncrement = 1'b0;
    if(pushing)begin
      _zz_StreamFifoLowLatency_1_ = 1'b1;
      pushPtr_willIncrement = 1'b1;
    end
  end

  always @ (*) begin
    pushPtr_willClear = 1'b0;
    popPtr_willClear = 1'b0;
    if(io_flush)begin
      pushPtr_willClear = 1'b1;
      popPtr_willClear = 1'b1;
    end
  end

  assign pushPtr_willOverflowIfInc = 1'b1;
  assign pushPtr_willOverflow = (pushPtr_willOverflowIfInc && pushPtr_willIncrement);
  always @ (*) begin
    popPtr_willIncrement = 1'b0;
    if(popping)begin
      popPtr_willIncrement = 1'b1;
    end
  end

  assign popPtr_willOverflowIfInc = 1'b1;
  assign popPtr_willOverflow = (popPtr_willOverflowIfInc && popPtr_willIncrement);
  assign ptrMatch = 1'b1;
  assign empty = (ptrMatch && (! risingOccupancy));
  assign full = (ptrMatch && risingOccupancy);
  assign pushing = (io_push_valid && io_push_ready);
  assign popping = (io_pop_valid && io_pop_ready);
  assign io_push_ready = (! full);
  always @ (*) begin
    if((! empty))begin
      io_pop_valid = 1'b1;
      io_pop_payload_error = _zz_StreamFifoLowLatency_5_[0];
      io_pop_payload_inst = _zz_StreamFifoLowLatency_2_[32 : 1];
    end else begin
      io_pop_valid = io_push_valid;
      io_pop_payload_error = io_push_payload_error;
      io_pop_payload_inst = io_push_payload_inst;
    end
  end

  assign _zz_StreamFifoLowLatency_2_ = _zz_StreamFifoLowLatency_3_;
  assign io_occupancy = (risingOccupancy && ptrMatch);
  assign _zz_StreamFifoLowLatency_3_ = _zz_StreamFifoLowLatency_4_;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      risingOccupancy <= 1'b0;
    end else begin
      if((pushing != popping))begin
        risingOccupancy <= pushing;
      end
      if(io_flush)begin
        risingOccupancy <= 1'b0;
      end
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(_zz_StreamFifoLowLatency_1_)begin
      _zz_StreamFifoLowLatency_4_ <= {io_push_payload_inst,io_push_payload_error};
    end
  end

endmodule

module BufferCC (
      input  [11:0] io_initial,
      input  [11:0] io_dataIn,
      output [11:0] io_dataOut,
      input   u_gmii_rx_io_rx_clk);
  reg [11:0] buffers_0 = (12'b000000000000);
  reg [11:0] buffers_1 = (12'b000000000000);
  assign io_dataOut = buffers_1;
  always @ (posedge u_gmii_rx_io_rx_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end

endmodule

module BufferCC_1_ (
      input  [11:0] io_initial,
      input  [11:0] io_dataIn,
      output [11:0] io_dataOut,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg [11:0] buffers_0;
  reg [11:0] buffers_1;
  assign io_dataOut = buffers_1;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      buffers_0 <= io_initial;
      buffers_1 <= io_initial;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end

endmodule

module MuraxMasterArbiter (
      input   io_iBus_cmd_valid,
      output reg  io_iBus_cmd_ready,
      input  [31:0] io_iBus_cmd_payload_pc,
      output  io_iBus_rsp_valid,
      output  io_iBus_rsp_payload_error,
      output [31:0] io_iBus_rsp_payload_inst,
      input   io_dBus_cmd_valid,
      output reg  io_dBus_cmd_ready,
      input   io_dBus_cmd_payload_wr,
      input  [31:0] io_dBus_cmd_payload_address,
      input  [31:0] io_dBus_cmd_payload_data,
      input  [1:0] io_dBus_cmd_payload_size,
      output  io_dBus_rsp_ready,
      output  io_dBus_rsp_error,
      output [31:0] io_dBus_rsp_data,
      output reg  io_masterBus_cmd_valid,
      input   io_masterBus_cmd_ready,
      output  io_masterBus_cmd_payload_write,
      output [31:0] io_masterBus_cmd_payload_address,
      output [31:0] io_masterBus_cmd_payload_data,
      output [3:0] io_masterBus_cmd_payload_mask,
      input   io_masterBus_rsp_valid,
      input  [31:0] io_masterBus_rsp_payload_data,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg [3:0] _zz_MuraxMasterArbiter_1_;
  reg  rspPending;
  reg  rspTarget;
  always @ (*) begin
    io_masterBus_cmd_valid = (io_iBus_cmd_valid || io_dBus_cmd_valid);
    io_iBus_cmd_ready = (io_masterBus_cmd_ready && (! io_dBus_cmd_valid));
    io_dBus_cmd_ready = io_masterBus_cmd_ready;
    if((rspPending && (! io_masterBus_rsp_valid)))begin
      io_iBus_cmd_ready = 1'b0;
      io_dBus_cmd_ready = 1'b0;
      io_masterBus_cmd_valid = 1'b0;
    end
  end

  assign io_masterBus_cmd_payload_write = (io_dBus_cmd_valid && io_dBus_cmd_payload_wr);
  assign io_masterBus_cmd_payload_address = (io_dBus_cmd_valid ? io_dBus_cmd_payload_address : io_iBus_cmd_payload_pc);
  assign io_masterBus_cmd_payload_data = io_dBus_cmd_payload_data;
  always @ (*) begin
    case(io_dBus_cmd_payload_size)
      2'b00 : begin
        _zz_MuraxMasterArbiter_1_ = (4'b0001);
      end
      2'b01 : begin
        _zz_MuraxMasterArbiter_1_ = (4'b0011);
      end
      default : begin
        _zz_MuraxMasterArbiter_1_ = (4'b1111);
      end
    endcase
  end

  assign io_masterBus_cmd_payload_mask = (_zz_MuraxMasterArbiter_1_ <<< io_dBus_cmd_payload_address[1 : 0]);
  assign io_iBus_rsp_valid = (io_masterBus_rsp_valid && (! rspTarget));
  assign io_iBus_rsp_payload_inst = io_masterBus_rsp_payload_data;
  assign io_iBus_rsp_payload_error = 1'b0;
  assign io_dBus_rsp_ready = (io_masterBus_rsp_valid && rspTarget);
  assign io_dBus_rsp_data = io_masterBus_rsp_payload_data;
  assign io_dBus_rsp_error = 1'b0;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      rspPending <= 1'b0;
      rspTarget <= 1'b0;
    end else begin
      if(io_masterBus_rsp_valid)begin
        rspPending <= 1'b0;
      end
      if(((io_masterBus_cmd_valid && io_masterBus_cmd_ready) && (! io_masterBus_cmd_payload_write)))begin
        rspTarget <= io_dBus_cmd_valid;
        rspPending <= 1'b1;
      end
    end
  end

endmodule

module VexRiscv (
      output  iBus_cmd_valid,
      input   iBus_cmd_ready,
      output [31:0] iBus_cmd_payload_pc,
      input   iBus_rsp_valid,
      input   iBus_rsp_payload_error,
      input  [31:0] iBus_rsp_payload_inst,
      input   timerInterrupt,
      input   externalInterrupt,
      output  dBus_cmd_valid,
      input   dBus_cmd_ready,
      output  dBus_cmd_payload_wr,
      output [31:0] dBus_cmd_payload_address,
      output [31:0] dBus_cmd_payload_data,
      output [1:0] dBus_cmd_payload_size,
      input   dBus_rsp_ready,
      input   dBus_rsp_error,
      input  [31:0] dBus_rsp_data,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire  _zz_VexRiscv_142_;
  reg [31:0] _zz_VexRiscv_143_;
  reg [31:0] _zz_VexRiscv_144_;
  wire  IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready;
  wire  IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid;
  wire  IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error;
  wire [31:0] IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst;
  wire [0:0] IBusSimplePlugin_rspJoin_rspBuffer_c_io_occupancy;
  wire  _zz_VexRiscv_145_;
  wire  _zz_VexRiscv_146_;
  wire  _zz_VexRiscv_147_;
  wire  _zz_VexRiscv_148_;
  wire  _zz_VexRiscv_149_;
  wire [1:0] _zz_VexRiscv_150_;
  wire [1:0] _zz_VexRiscv_151_;
  wire  _zz_VexRiscv_152_;
  wire [1:0] _zz_VexRiscv_153_;
  wire [1:0] _zz_VexRiscv_154_;
  wire [2:0] _zz_VexRiscv_155_;
  wire [31:0] _zz_VexRiscv_156_;
  wire [2:0] _zz_VexRiscv_157_;
  wire [0:0] _zz_VexRiscv_158_;
  wire [2:0] _zz_VexRiscv_159_;
  wire [0:0] _zz_VexRiscv_160_;
  wire [2:0] _zz_VexRiscv_161_;
  wire [0:0] _zz_VexRiscv_162_;
  wire [2:0] _zz_VexRiscv_163_;
  wire [0:0] _zz_VexRiscv_164_;
  wire [0:0] _zz_VexRiscv_165_;
  wire [0:0] _zz_VexRiscv_166_;
  wire [0:0] _zz_VexRiscv_167_;
  wire [0:0] _zz_VexRiscv_168_;
  wire [0:0] _zz_VexRiscv_169_;
  wire [0:0] _zz_VexRiscv_170_;
  wire [0:0] _zz_VexRiscv_171_;
  wire [0:0] _zz_VexRiscv_172_;
  wire [0:0] _zz_VexRiscv_173_;
  wire [2:0] _zz_VexRiscv_174_;
  wire [4:0] _zz_VexRiscv_175_;
  wire [11:0] _zz_VexRiscv_176_;
  wire [11:0] _zz_VexRiscv_177_;
  wire [31:0] _zz_VexRiscv_178_;
  wire [31:0] _zz_VexRiscv_179_;
  wire [31:0] _zz_VexRiscv_180_;
  wire [31:0] _zz_VexRiscv_181_;
  wire [1:0] _zz_VexRiscv_182_;
  wire [31:0] _zz_VexRiscv_183_;
  wire [1:0] _zz_VexRiscv_184_;
  wire [1:0] _zz_VexRiscv_185_;
  wire [31:0] _zz_VexRiscv_186_;
  wire [32:0] _zz_VexRiscv_187_;
  wire [19:0] _zz_VexRiscv_188_;
  wire [11:0] _zz_VexRiscv_189_;
  wire [11:0] _zz_VexRiscv_190_;
  wire [0:0] _zz_VexRiscv_191_;
  wire [0:0] _zz_VexRiscv_192_;
  wire [0:0] _zz_VexRiscv_193_;
  wire [0:0] _zz_VexRiscv_194_;
  wire [0:0] _zz_VexRiscv_195_;
  wire [0:0] _zz_VexRiscv_196_;
  wire  _zz_VexRiscv_197_;
  wire  _zz_VexRiscv_198_;
  wire  _zz_VexRiscv_199_;
  wire [0:0] _zz_VexRiscv_200_;
  wire [2:0] _zz_VexRiscv_201_;
  wire [4:0] _zz_VexRiscv_202_;
  wire [4:0] _zz_VexRiscv_203_;
  wire  _zz_VexRiscv_204_;
  wire [0:0] _zz_VexRiscv_205_;
  wire [16:0] _zz_VexRiscv_206_;
  wire [31:0] _zz_VexRiscv_207_;
  wire [31:0] _zz_VexRiscv_208_;
  wire [31:0] _zz_VexRiscv_209_;
  wire  _zz_VexRiscv_210_;
  wire [0:0] _zz_VexRiscv_211_;
  wire [1:0] _zz_VexRiscv_212_;
  wire  _zz_VexRiscv_213_;
  wire  _zz_VexRiscv_214_;
  wire [0:0] _zz_VexRiscv_215_;
  wire [0:0] _zz_VexRiscv_216_;
  wire [0:0] _zz_VexRiscv_217_;
  wire [0:0] _zz_VexRiscv_218_;
  wire  _zz_VexRiscv_219_;
  wire [0:0] _zz_VexRiscv_220_;
  wire [13:0] _zz_VexRiscv_221_;
  wire [31:0] _zz_VexRiscv_222_;
  wire [31:0] _zz_VexRiscv_223_;
  wire [31:0] _zz_VexRiscv_224_;
  wire  _zz_VexRiscv_225_;
  wire [31:0] _zz_VexRiscv_226_;
  wire [31:0] _zz_VexRiscv_227_;
  wire [31:0] _zz_VexRiscv_228_;
  wire [31:0] _zz_VexRiscv_229_;
  wire [31:0] _zz_VexRiscv_230_;
  wire [31:0] _zz_VexRiscv_231_;
  wire [31:0] _zz_VexRiscv_232_;
  wire [31:0] _zz_VexRiscv_233_;
  wire [0:0] _zz_VexRiscv_234_;
  wire [0:0] _zz_VexRiscv_235_;
  wire [2:0] _zz_VexRiscv_236_;
  wire [2:0] _zz_VexRiscv_237_;
  wire  _zz_VexRiscv_238_;
  wire [0:0] _zz_VexRiscv_239_;
  wire [11:0] _zz_VexRiscv_240_;
  wire [31:0] _zz_VexRiscv_241_;
  wire  _zz_VexRiscv_242_;
  wire  _zz_VexRiscv_243_;
  wire [0:0] _zz_VexRiscv_244_;
  wire [0:0] _zz_VexRiscv_245_;
  wire [1:0] _zz_VexRiscv_246_;
  wire [1:0] _zz_VexRiscv_247_;
  wire  _zz_VexRiscv_248_;
  wire [0:0] _zz_VexRiscv_249_;
  wire [8:0] _zz_VexRiscv_250_;
  wire [31:0] _zz_VexRiscv_251_;
  wire [31:0] _zz_VexRiscv_252_;
  wire [31:0] _zz_VexRiscv_253_;
  wire  _zz_VexRiscv_254_;
  wire [2:0] _zz_VexRiscv_255_;
  wire [2:0] _zz_VexRiscv_256_;
  wire  _zz_VexRiscv_257_;
  wire [0:0] _zz_VexRiscv_258_;
  wire [5:0] _zz_VexRiscv_259_;
  wire [31:0] _zz_VexRiscv_260_;
  wire [31:0] _zz_VexRiscv_261_;
  wire  _zz_VexRiscv_262_;
  wire  _zz_VexRiscv_263_;
  wire  _zz_VexRiscv_264_;
  wire  _zz_VexRiscv_265_;
  wire [0:0] _zz_VexRiscv_266_;
  wire [0:0] _zz_VexRiscv_267_;
  wire  _zz_VexRiscv_268_;
  wire [0:0] _zz_VexRiscv_269_;
  wire [2:0] _zz_VexRiscv_270_;
  wire [31:0] _zz_VexRiscv_271_;
  wire  _zz_VexRiscv_272_;
  wire [0:0] _zz_VexRiscv_273_;
  wire [0:0] _zz_VexRiscv_274_;
  wire [1:0] _zz_VexRiscv_275_;
  wire [1:0] _zz_VexRiscv_276_;
  wire  _zz_VexRiscv_277_;
  wire  _zz_VexRiscv_278_;
  wire [31:0] _zz_VexRiscv_279_;
  wire [31:0] _zz_VexRiscv_280_;
  wire [31:0] _zz_VexRiscv_281_;
  wire [31:0] _zz_VexRiscv_282_;
  wire [31:0] _zz_VexRiscv_283_;
  wire [31:0] _zz_VexRiscv_284_;
  wire [31:0] _zz_VexRiscv_285_;
  wire [31:0] execute_BRANCH_CALC;
  wire [31:0] decode_RS2;
  wire [31:0] memory_MEMORY_READ_DATA;
  wire  execute_BYPASSABLE_MEMORY_STAGE;
  wire  decode_BYPASSABLE_MEMORY_STAGE;
  wire [1:0] memory_MEMORY_ADDRESS_LOW;
  wire [1:0] execute_MEMORY_ADDRESS_LOW;
  wire [31:0] decode_SRC1;
  wire  decode_SRC_LESS_UNSIGNED;
  wire [31:0] memory_PC;
  wire  decode_CSR_WRITE_OPCODE;
  wire  decode_IS_CSR;
  wire `BranchCtrlEnum_defaultEncoding_type decode_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_VexRiscv_1_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_VexRiscv_2_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_VexRiscv_3_;
  wire [31:0] writeBack_FORMAL_PC_NEXT;
  wire [31:0] memory_FORMAL_PC_NEXT;
  wire [31:0] execute_FORMAL_PC_NEXT;
  wire [31:0] decode_FORMAL_PC_NEXT;
  wire  decode_CSR_READ_OPCODE;
  wire `AluCtrlEnum_defaultEncoding_type decode_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_VexRiscv_4_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_VexRiscv_5_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_VexRiscv_6_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_7_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_8_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_9_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_10_;
  wire `EnvCtrlEnum_defaultEncoding_type decode_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_11_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_12_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_13_;
  wire [31:0] decode_RS1;
  wire `ShiftCtrlEnum_defaultEncoding_type decode_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_VexRiscv_14_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_VexRiscv_15_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_VexRiscv_16_;
  wire  execute_BRANCH_DO;
  wire  decode_BYPASSABLE_EXECUTE_STAGE;
  wire  decode_MEMORY_ENABLE;
  wire [31:0] writeBack_REGFILE_WRITE_DATA;
  wire [31:0] execute_REGFILE_WRITE_DATA;
  wire [31:0] decode_SRC2;
  wire  decode_SRC_USE_SUB_LESS;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type decode_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_VexRiscv_17_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_VexRiscv_18_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_VexRiscv_19_;
  wire [31:0] memory_BRANCH_CALC;
  wire  memory_BRANCH_DO;
  wire [31:0] _zz_VexRiscv_20_;
  wire [31:0] execute_PC;
  wire [31:0] execute_RS1;
  wire `BranchCtrlEnum_defaultEncoding_type execute_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_VexRiscv_21_;
  wire  _zz_VexRiscv_22_;
  wire  decode_RS2_USE;
  wire  decode_RS1_USE;
  wire  execute_REGFILE_WRITE_VALID;
  wire  execute_BYPASSABLE_EXECUTE_STAGE;
  wire  memory_REGFILE_WRITE_VALID;
  wire  memory_BYPASSABLE_MEMORY_STAGE;
  wire  writeBack_REGFILE_WRITE_VALID;
  wire [31:0] memory_REGFILE_WRITE_DATA;
  wire `ShiftCtrlEnum_defaultEncoding_type execute_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_VexRiscv_23_;
  wire  _zz_VexRiscv_24_;
  wire [31:0] _zz_VexRiscv_25_;
  wire [31:0] _zz_VexRiscv_26_;
  wire  execute_SRC_LESS_UNSIGNED;
  wire  execute_SRC_USE_SUB_LESS;
  wire [31:0] _zz_VexRiscv_27_;
  wire [31:0] _zz_VexRiscv_28_;
  wire `Src2CtrlEnum_defaultEncoding_type decode_SRC2_CTRL;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_VexRiscv_29_;
  wire [31:0] _zz_VexRiscv_30_;
  wire [31:0] _zz_VexRiscv_31_;
  wire `Src1CtrlEnum_defaultEncoding_type decode_SRC1_CTRL;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_VexRiscv_32_;
  wire [31:0] _zz_VexRiscv_33_;
  wire [31:0] execute_SRC_ADD_SUB;
  wire  execute_SRC_LESS;
  wire `AluCtrlEnum_defaultEncoding_type execute_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_VexRiscv_34_;
  wire [31:0] _zz_VexRiscv_35_;
  wire [31:0] execute_SRC2;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type execute_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_VexRiscv_36_;
  wire [31:0] _zz_VexRiscv_37_;
  wire  _zz_VexRiscv_38_;
  reg  _zz_VexRiscv_39_;
  wire [31:0] _zz_VexRiscv_40_;
  wire [31:0] _zz_VexRiscv_41_;
  wire [31:0] decode_INSTRUCTION_ANTICIPATED;
  reg  decode_REGFILE_WRITE_VALID;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_VexRiscv_42_;
  wire  _zz_VexRiscv_43_;
  wire  _zz_VexRiscv_44_;
  wire  _zz_VexRiscv_45_;
  wire  _zz_VexRiscv_46_;
  wire  _zz_VexRiscv_47_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_VexRiscv_48_;
  wire  _zz_VexRiscv_49_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_VexRiscv_50_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_51_;
  wire  _zz_VexRiscv_52_;
  wire  _zz_VexRiscv_53_;
  wire  _zz_VexRiscv_54_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_VexRiscv_55_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_VexRiscv_56_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_VexRiscv_57_;
  reg [31:0] _zz_VexRiscv_58_;
  wire [31:0] execute_SRC1;
  wire  execute_CSR_READ_OPCODE;
  wire  execute_CSR_WRITE_OPCODE;
  wire  execute_IS_CSR;
  wire `EnvCtrlEnum_defaultEncoding_type memory_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_59_;
  wire `EnvCtrlEnum_defaultEncoding_type execute_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_60_;
  wire  _zz_VexRiscv_61_;
  wire  _zz_VexRiscv_62_;
  wire `EnvCtrlEnum_defaultEncoding_type writeBack_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_63_;
  reg [31:0] _zz_VexRiscv_64_;
  wire  writeBack_MEMORY_ENABLE;
  wire [1:0] writeBack_MEMORY_ADDRESS_LOW;
  wire [31:0] writeBack_MEMORY_READ_DATA;
  wire [31:0] memory_INSTRUCTION;
  wire  memory_MEMORY_ENABLE;
  wire [31:0] _zz_VexRiscv_65_;
  wire [1:0] _zz_VexRiscv_66_;
  wire [31:0] execute_RS2;
  wire [31:0] execute_SRC_ADD;
  wire [31:0] execute_INSTRUCTION;
  wire  execute_ALIGNEMENT_FAULT;
  wire  execute_MEMORY_ENABLE;
  reg [31:0] _zz_VexRiscv_67_;
  wire [31:0] _zz_VexRiscv_68_;
  wire [31:0] _zz_VexRiscv_69_;
  wire [31:0] _zz_VexRiscv_70_;
  wire [31:0] _zz_VexRiscv_71_;
  wire [31:0] writeBack_PC /* verilator public */ ;
  wire [31:0] writeBack_INSTRUCTION /* verilator public */ ;
  wire [31:0] decode_PC /* verilator public */ ;
  wire [31:0] decode_INSTRUCTION /* verilator public */ ;
  wire  decode_arbitration_haltItself /* verilator public */ ;
  reg  decode_arbitration_haltByOther;
  reg  decode_arbitration_removeIt;
  wire  decode_arbitration_flushAll /* verilator public */ ;
  wire  decode_arbitration_redoIt;
  wire  decode_arbitration_isValid /* verilator public */ ;
  wire  decode_arbitration_isStuck;
  wire  decode_arbitration_isStuckByOthers;
  wire  decode_arbitration_isFlushed;
  wire  decode_arbitration_isMoving;
  wire  decode_arbitration_isFiring;
  reg  execute_arbitration_haltItself;
  wire  execute_arbitration_haltByOther;
  reg  execute_arbitration_removeIt;
  reg  execute_arbitration_flushAll;
  wire  execute_arbitration_redoIt;
  reg  execute_arbitration_isValid;
  wire  execute_arbitration_isStuck;
  wire  execute_arbitration_isStuckByOthers;
  wire  execute_arbitration_isFlushed;
  wire  execute_arbitration_isMoving;
  wire  execute_arbitration_isFiring;
  reg  memory_arbitration_haltItself;
  wire  memory_arbitration_haltByOther;
  reg  memory_arbitration_removeIt;
  reg  memory_arbitration_flushAll;
  wire  memory_arbitration_redoIt;
  reg  memory_arbitration_isValid;
  wire  memory_arbitration_isStuck;
  wire  memory_arbitration_isStuckByOthers;
  wire  memory_arbitration_isFlushed;
  wire  memory_arbitration_isMoving;
  wire  memory_arbitration_isFiring;
  wire  writeBack_arbitration_haltItself;
  wire  writeBack_arbitration_haltByOther;
  reg  writeBack_arbitration_removeIt;
  wire  writeBack_arbitration_flushAll;
  wire  writeBack_arbitration_redoIt;
  reg  writeBack_arbitration_isValid /* verilator public */ ;
  wire  writeBack_arbitration_isStuck;
  wire  writeBack_arbitration_isStuckByOthers;
  wire  writeBack_arbitration_isFlushed;
  wire  writeBack_arbitration_isMoving;
  wire  writeBack_arbitration_isFiring /* verilator public */ ;
  wire  _zz_VexRiscv_72_;
  reg  _zz_VexRiscv_73_;
  reg [31:0] _zz_VexRiscv_74_;
  wire  contextSwitching;
  reg [1:0] CsrPlugin_privilege;
  wire  _zz_VexRiscv_75_;
  wire [31:0] _zz_VexRiscv_76_;
  wire  IBusSimplePlugin_jump_pcLoad_valid;
  wire [31:0] IBusSimplePlugin_jump_pcLoad_payload;
  wire [1:0] _zz_VexRiscv_77_;
  wire  IBusSimplePlugin_fetchPc_preOutput_valid;
  wire  IBusSimplePlugin_fetchPc_preOutput_ready;
  wire [31:0] IBusSimplePlugin_fetchPc_preOutput_payload;
  wire  _zz_VexRiscv_78_;
  wire  IBusSimplePlugin_fetchPc_output_valid;
  wire  IBusSimplePlugin_fetchPc_output_ready;
  wire [31:0] IBusSimplePlugin_fetchPc_output_payload;
  reg [31:0] IBusSimplePlugin_fetchPc_pcReg /* verilator public */ ;
  reg  IBusSimplePlugin_fetchPc_inc;
  reg  IBusSimplePlugin_fetchPc_propagatePc;
  reg [31:0] IBusSimplePlugin_fetchPc_pc;
  reg  IBusSimplePlugin_fetchPc_samplePcNext;
  reg  _zz_VexRiscv_79_;
  wire  IBusSimplePlugin_iBusRsp_stages_0_input_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_input_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_0_output_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_0_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_output_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_0_halt;
  wire  IBusSimplePlugin_iBusRsp_stages_0_inputSample;
  wire  IBusSimplePlugin_iBusRsp_stages_1_input_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_1_input_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_input_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_1_output_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_1_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_output_payload;
  reg  IBusSimplePlugin_iBusRsp_stages_1_halt;
  wire  IBusSimplePlugin_iBusRsp_stages_1_inputSample;
  wire  IBusSimplePlugin_iBusRsp_stages_2_input_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_2_input_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_2_input_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_2_output_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_2_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_2_output_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_2_halt;
  wire  IBusSimplePlugin_iBusRsp_stages_2_inputSample;
  wire  _zz_VexRiscv_80_;
  wire  _zz_VexRiscv_81_;
  wire  _zz_VexRiscv_82_;
  wire  _zz_VexRiscv_83_;
  wire  _zz_VexRiscv_84_;
  reg  _zz_VexRiscv_85_;
  wire  _zz_VexRiscv_86_;
  reg  _zz_VexRiscv_87_;
  reg [31:0] _zz_VexRiscv_88_;
  reg  IBusSimplePlugin_iBusRsp_readyForError;
  wire  IBusSimplePlugin_iBusRsp_inputBeforeStage_valid;
  wire  IBusSimplePlugin_iBusRsp_inputBeforeStage_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_pc;
  wire  IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw;
  wire  IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_isRvc;
  wire  IBusSimplePlugin_injector_decodeInput_valid;
  wire  IBusSimplePlugin_injector_decodeInput_ready;
  wire [31:0] IBusSimplePlugin_injector_decodeInput_payload_pc;
  wire  IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
  wire  IBusSimplePlugin_injector_decodeInput_payload_isRvc;
  reg  _zz_VexRiscv_89_;
  reg [31:0] _zz_VexRiscv_90_;
  reg  _zz_VexRiscv_91_;
  reg [31:0] _zz_VexRiscv_92_;
  reg  _zz_VexRiscv_93_;
  reg  IBusSimplePlugin_injector_nextPcCalc_valids_0;
  reg  IBusSimplePlugin_injector_nextPcCalc_valids_1;
  reg  IBusSimplePlugin_injector_nextPcCalc_0;
  reg  IBusSimplePlugin_injector_nextPcCalc_1;
  reg  IBusSimplePlugin_injector_nextPcCalc_2;
  reg  IBusSimplePlugin_injector_nextPcCalc_3;
  reg  IBusSimplePlugin_injector_decodeRemoved;
  reg [31:0] IBusSimplePlugin_injector_formal_rawInDecode;
  wire  IBusSimplePlugin_cmd_valid;
  wire  IBusSimplePlugin_cmd_ready;
  wire [31:0] IBusSimplePlugin_cmd_payload_pc;
  reg [2:0] IBusSimplePlugin_pendingCmd;
  wire [2:0] IBusSimplePlugin_pendingCmdNext;
  reg [2:0] IBusSimplePlugin_rspJoin_discardCounter;
  wire  IBusSimplePlugin_rspJoin_rspBufferOutput_valid;
  wire  IBusSimplePlugin_rspJoin_rspBufferOutput_ready;
  wire  IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error;
  wire [31:0] IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst;
  wire  iBus_rsp_takeWhen_valid;
  wire  iBus_rsp_takeWhen_payload_error;
  wire [31:0] iBus_rsp_takeWhen_payload_inst;
  wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_pc;
  reg  IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
  wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
  wire  IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
  wire  IBusSimplePlugin_rspJoin_issueDetected;
  wire  IBusSimplePlugin_rspJoin_join_valid;
  wire  IBusSimplePlugin_rspJoin_join_ready;
  wire [31:0] IBusSimplePlugin_rspJoin_join_payload_pc;
  wire  IBusSimplePlugin_rspJoin_join_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
  wire  IBusSimplePlugin_rspJoin_join_payload_isRvc;
  wire  _zz_VexRiscv_94_;
  wire  execute_DBusSimplePlugin_cmdSent;
  reg [31:0] _zz_VexRiscv_95_;
  reg [3:0] _zz_VexRiscv_96_;
  wire [3:0] execute_DBusSimplePlugin_formalMask;
  reg [31:0] writeBack_DBusSimplePlugin_rspShifted;
  wire  _zz_VexRiscv_97_;
  reg [31:0] _zz_VexRiscv_98_;
  wire  _zz_VexRiscv_99_;
  reg [31:0] _zz_VexRiscv_100_;
  reg [31:0] writeBack_DBusSimplePlugin_rspFormated;
  wire [1:0] CsrPlugin_misa_base;
  wire [25:0] CsrPlugin_misa_extensions;
  wire [1:0] CsrPlugin_mtvec_mode;
  wire [29:0] CsrPlugin_mtvec_base;
  reg [31:0] CsrPlugin_mepc;
  reg  CsrPlugin_mstatus_MIE;
  reg  CsrPlugin_mstatus_MPIE;
  reg [1:0] CsrPlugin_mstatus_MPP;
  reg  CsrPlugin_mip_MEIP;
  reg  CsrPlugin_mip_MTIP;
  reg  CsrPlugin_mip_MSIP;
  reg  CsrPlugin_mie_MEIE;
  reg  CsrPlugin_mie_MTIE;
  reg  CsrPlugin_mie_MSIE;
  reg  CsrPlugin_mcause_interrupt;
  reg [3:0] CsrPlugin_mcause_exceptionCode;
  reg [31:0] CsrPlugin_mtval;
  reg [63:0] CsrPlugin_mcycle = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  reg [63:0] CsrPlugin_minstret = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  wire [31:0] CsrPlugin_medeleg;
  wire [31:0] CsrPlugin_mideleg;
  wire  _zz_VexRiscv_101_;
  wire  _zz_VexRiscv_102_;
  wire  _zz_VexRiscv_103_;
  reg  CsrPlugin_interrupt;
  reg [3:0] CsrPlugin_interruptCode /* verilator public */ ;
  wire [1:0] CsrPlugin_interruptTargetPrivilege;
  wire  CsrPlugin_exception;
  wire  CsrPlugin_lastStageWasWfi;
  reg  CsrPlugin_pipelineLiberator_done;
  wire  CsrPlugin_interruptJump /* verilator public */ ;
  reg  CsrPlugin_hadException;
  wire [1:0] CsrPlugin_targetPrivilege;
  wire [3:0] CsrPlugin_trapCause;
  wire  execute_CsrPlugin_blockedBySideEffects;
  reg  execute_CsrPlugin_illegalAccess;
  reg  execute_CsrPlugin_illegalInstruction;
  reg [31:0] execute_CsrPlugin_readData;
  wire  execute_CsrPlugin_writeInstruction;
  wire  execute_CsrPlugin_readInstruction;
  wire  execute_CsrPlugin_writeEnable;
  wire  execute_CsrPlugin_readEnable;
  reg [31:0] execute_CsrPlugin_writeData;
  wire [11:0] execute_CsrPlugin_csrAddress;
  wire [22:0] _zz_VexRiscv_104_;
  wire  _zz_VexRiscv_105_;
  wire  _zz_VexRiscv_106_;
  wire  _zz_VexRiscv_107_;
  wire  _zz_VexRiscv_108_;
  wire  _zz_VexRiscv_109_;
  wire  _zz_VexRiscv_110_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_VexRiscv_111_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_VexRiscv_112_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_VexRiscv_113_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_VexRiscv_114_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_VexRiscv_115_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_VexRiscv_116_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_VexRiscv_117_;
  wire [4:0] decode_RegFilePlugin_regFileReadAddress1;
  wire [4:0] decode_RegFilePlugin_regFileReadAddress2;
  wire [31:0] decode_RegFilePlugin_rs1Data;
  wire [31:0] decode_RegFilePlugin_rs2Data;
  reg  writeBack_RegFilePlugin_regFileWrite_valid /* verilator public */ ;
  wire [4:0] writeBack_RegFilePlugin_regFileWrite_payload_address /* verilator public */ ;
  wire [31:0] writeBack_RegFilePlugin_regFileWrite_payload_data /* verilator public */ ;
  reg  _zz_VexRiscv_118_;
  reg [31:0] execute_IntAluPlugin_bitwise;
  reg [31:0] _zz_VexRiscv_119_;
  reg [31:0] _zz_VexRiscv_120_;
  wire  _zz_VexRiscv_121_;
  reg [19:0] _zz_VexRiscv_122_;
  wire  _zz_VexRiscv_123_;
  reg [19:0] _zz_VexRiscv_124_;
  reg [31:0] _zz_VexRiscv_125_;
  wire [31:0] execute_SrcPlugin_addSub;
  wire  execute_SrcPlugin_less;
  reg  execute_LightShifterPlugin_isActive;
  wire  execute_LightShifterPlugin_isShift;
  reg [4:0] execute_LightShifterPlugin_amplitudeReg;
  wire [4:0] execute_LightShifterPlugin_amplitude;
  wire [31:0] execute_LightShifterPlugin_shiftInput;
  wire  execute_LightShifterPlugin_done;
  reg [31:0] _zz_VexRiscv_126_;
  reg  _zz_VexRiscv_127_;
  reg  _zz_VexRiscv_128_;
  wire  _zz_VexRiscv_129_;
  reg  _zz_VexRiscv_130_;
  reg [4:0] _zz_VexRiscv_131_;
  wire  execute_BranchPlugin_eq;
  wire [2:0] _zz_VexRiscv_132_;
  reg  _zz_VexRiscv_133_;
  reg  _zz_VexRiscv_134_;
  wire [31:0] execute_BranchPlugin_branch_src1;
  wire  _zz_VexRiscv_135_;
  reg [10:0] _zz_VexRiscv_136_;
  wire  _zz_VexRiscv_137_;
  reg [19:0] _zz_VexRiscv_138_;
  wire  _zz_VexRiscv_139_;
  reg [18:0] _zz_VexRiscv_140_;
  reg [31:0] _zz_VexRiscv_141_;
  wire [31:0] execute_BranchPlugin_branch_src2;
  wire [31:0] execute_BranchPlugin_branchAdder;
  reg `AluBitwiseCtrlEnum_defaultEncoding_type decode_to_execute_ALU_BITWISE_CTRL;
  reg  decode_to_execute_SRC_USE_SUB_LESS;
  reg [31:0] decode_to_execute_INSTRUCTION;
  reg [31:0] execute_to_memory_INSTRUCTION;
  reg [31:0] memory_to_writeBack_INSTRUCTION;
  reg [31:0] decode_to_execute_SRC2;
  reg [31:0] execute_to_memory_REGFILE_WRITE_DATA;
  reg [31:0] memory_to_writeBack_REGFILE_WRITE_DATA;
  reg  decode_to_execute_MEMORY_ENABLE;
  reg  execute_to_memory_MEMORY_ENABLE;
  reg  memory_to_writeBack_MEMORY_ENABLE;
  reg  decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  reg  execute_to_memory_BRANCH_DO;
  reg `ShiftCtrlEnum_defaultEncoding_type decode_to_execute_SHIFT_CTRL;
  reg [31:0] decode_to_execute_RS1;
  reg `EnvCtrlEnum_defaultEncoding_type decode_to_execute_ENV_CTRL;
  reg `EnvCtrlEnum_defaultEncoding_type execute_to_memory_ENV_CTRL;
  reg `EnvCtrlEnum_defaultEncoding_type memory_to_writeBack_ENV_CTRL;
  reg `AluCtrlEnum_defaultEncoding_type decode_to_execute_ALU_CTRL;
  reg  decode_to_execute_CSR_READ_OPCODE;
  reg [31:0] decode_to_execute_FORMAL_PC_NEXT;
  reg [31:0] execute_to_memory_FORMAL_PC_NEXT;
  reg [31:0] memory_to_writeBack_FORMAL_PC_NEXT;
  reg `BranchCtrlEnum_defaultEncoding_type decode_to_execute_BRANCH_CTRL;
  reg  decode_to_execute_IS_CSR;
  reg  decode_to_execute_CSR_WRITE_OPCODE;
  reg [31:0] decode_to_execute_PC;
  reg [31:0] execute_to_memory_PC;
  reg [31:0] memory_to_writeBack_PC;
  reg  decode_to_execute_REGFILE_WRITE_VALID;
  reg  execute_to_memory_REGFILE_WRITE_VALID;
  reg  memory_to_writeBack_REGFILE_WRITE_VALID;
  reg  decode_to_execute_SRC_LESS_UNSIGNED;
  reg [31:0] decode_to_execute_SRC1;
  reg [1:0] execute_to_memory_MEMORY_ADDRESS_LOW;
  reg [1:0] memory_to_writeBack_MEMORY_ADDRESS_LOW;
  reg  decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  reg  execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  reg [31:0] memory_to_writeBack_MEMORY_READ_DATA;
  reg [31:0] decode_to_execute_RS2;
  reg [31:0] execute_to_memory_BRANCH_CALC;
  reg [31:0] RegFilePlugin_regFile [0:31] /* verilator public */ ;
  assign _zz_VexRiscv_145_ = ((execute_arbitration_isValid && execute_LightShifterPlugin_isShift) && (execute_SRC2[4 : 0] != (5'b00000)));
  assign _zz_VexRiscv_146_ = (! execute_arbitration_isStuckByOthers);
  assign _zz_VexRiscv_147_ = (CsrPlugin_hadException || CsrPlugin_interruptJump);
  assign _zz_VexRiscv_148_ = (writeBack_arbitration_isValid && (writeBack_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET));
  assign _zz_VexRiscv_149_ = (IBusSimplePlugin_fetchPc_preOutput_valid && IBusSimplePlugin_fetchPc_preOutput_ready);
  assign _zz_VexRiscv_150_ = writeBack_INSTRUCTION[13 : 12];
  assign _zz_VexRiscv_151_ = writeBack_INSTRUCTION[29 : 28];
  assign _zz_VexRiscv_152_ = execute_INSTRUCTION[13];
  assign _zz_VexRiscv_153_ = (_zz_VexRiscv_77_ & (~ _zz_VexRiscv_154_));
  assign _zz_VexRiscv_154_ = (_zz_VexRiscv_77_ - (2'b01));
  assign _zz_VexRiscv_155_ = {IBusSimplePlugin_fetchPc_inc,(2'b00)};
  assign _zz_VexRiscv_156_ = {29'd0, _zz_VexRiscv_155_};
  assign _zz_VexRiscv_157_ = (IBusSimplePlugin_pendingCmd + _zz_VexRiscv_159_);
  assign _zz_VexRiscv_158_ = (IBusSimplePlugin_cmd_valid && IBusSimplePlugin_cmd_ready);
  assign _zz_VexRiscv_159_ = {2'd0, _zz_VexRiscv_158_};
  assign _zz_VexRiscv_160_ = iBus_rsp_valid;
  assign _zz_VexRiscv_161_ = {2'd0, _zz_VexRiscv_160_};
  assign _zz_VexRiscv_162_ = (iBus_rsp_valid && (IBusSimplePlugin_rspJoin_discardCounter != (3'b000)));
  assign _zz_VexRiscv_163_ = {2'd0, _zz_VexRiscv_162_};
  assign _zz_VexRiscv_164_ = _zz_VexRiscv_104_[7 : 7];
  assign _zz_VexRiscv_165_ = _zz_VexRiscv_104_[8 : 8];
  assign _zz_VexRiscv_166_ = _zz_VexRiscv_104_[9 : 9];
  assign _zz_VexRiscv_167_ = _zz_VexRiscv_104_[13 : 13];
  assign _zz_VexRiscv_168_ = _zz_VexRiscv_104_[16 : 16];
  assign _zz_VexRiscv_169_ = _zz_VexRiscv_104_[17 : 17];
  assign _zz_VexRiscv_170_ = _zz_VexRiscv_104_[18 : 18];
  assign _zz_VexRiscv_171_ = _zz_VexRiscv_104_[19 : 19];
  assign _zz_VexRiscv_172_ = _zz_VexRiscv_104_[20 : 20];
  assign _zz_VexRiscv_173_ = execute_SRC_LESS;
  assign _zz_VexRiscv_174_ = (3'b100);
  assign _zz_VexRiscv_175_ = decode_INSTRUCTION[19 : 15];
  assign _zz_VexRiscv_176_ = decode_INSTRUCTION[31 : 20];
  assign _zz_VexRiscv_177_ = {decode_INSTRUCTION[31 : 25],decode_INSTRUCTION[11 : 7]};
  assign _zz_VexRiscv_178_ = ($signed(_zz_VexRiscv_179_) + $signed(_zz_VexRiscv_183_));
  assign _zz_VexRiscv_179_ = ($signed(_zz_VexRiscv_180_) + $signed(_zz_VexRiscv_181_));
  assign _zz_VexRiscv_180_ = execute_SRC1;
  assign _zz_VexRiscv_181_ = (execute_SRC_USE_SUB_LESS ? (~ execute_SRC2) : execute_SRC2);
  assign _zz_VexRiscv_182_ = (execute_SRC_USE_SUB_LESS ? _zz_VexRiscv_184_ : _zz_VexRiscv_185_);
  assign _zz_VexRiscv_183_ = {{30{_zz_VexRiscv_182_[1]}}, _zz_VexRiscv_182_};
  assign _zz_VexRiscv_184_ = (2'b01);
  assign _zz_VexRiscv_185_ = (2'b00);
  assign _zz_VexRiscv_186_ = (_zz_VexRiscv_187_ >>> 1);
  assign _zz_VexRiscv_187_ = {((execute_SHIFT_CTRL == `ShiftCtrlEnum_defaultEncoding_SRA_1) && execute_LightShifterPlugin_shiftInput[31]),execute_LightShifterPlugin_shiftInput};
  assign _zz_VexRiscv_188_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz_VexRiscv_189_ = execute_INSTRUCTION[31 : 20];
  assign _zz_VexRiscv_190_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_VexRiscv_191_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_VexRiscv_192_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_VexRiscv_193_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_VexRiscv_194_ = execute_CsrPlugin_writeData[11 : 11];
  assign _zz_VexRiscv_195_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_VexRiscv_196_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_VexRiscv_197_ = 1'b1;
  assign _zz_VexRiscv_198_ = 1'b1;
  assign _zz_VexRiscv_199_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001000100)) == (32'b00000000000000000000000000000100));
  assign _zz_VexRiscv_200_ = ((decode_INSTRUCTION & _zz_VexRiscv_207_) == (32'b00000000000000000000000000000000));
  assign _zz_VexRiscv_201_ = {(_zz_VexRiscv_208_ == _zz_VexRiscv_209_),{_zz_VexRiscv_105_,_zz_VexRiscv_210_}};
  assign _zz_VexRiscv_202_ = {_zz_VexRiscv_108_,{_zz_VexRiscv_107_,{_zz_VexRiscv_211_,_zz_VexRiscv_212_}}};
  assign _zz_VexRiscv_203_ = (5'b00000);
  assign _zz_VexRiscv_204_ = ({_zz_VexRiscv_213_,_zz_VexRiscv_214_} != (2'b00));
  assign _zz_VexRiscv_205_ = ({_zz_VexRiscv_215_,_zz_VexRiscv_216_} != (2'b00));
  assign _zz_VexRiscv_206_ = {(_zz_VexRiscv_217_ != _zz_VexRiscv_218_),{_zz_VexRiscv_219_,{_zz_VexRiscv_220_,_zz_VexRiscv_221_}}};
  assign _zz_VexRiscv_207_ = (32'b00000000000000000000000001000100);
  assign _zz_VexRiscv_208_ = (decode_INSTRUCTION & (32'b00000000000000000000000000011000));
  assign _zz_VexRiscv_209_ = (32'b00000000000000000000000000000000);
  assign _zz_VexRiscv_210_ = ((decode_INSTRUCTION & _zz_VexRiscv_222_) == (32'b00000000000000000001000000000000));
  assign _zz_VexRiscv_211_ = (_zz_VexRiscv_223_ == _zz_VexRiscv_224_);
  assign _zz_VexRiscv_212_ = {_zz_VexRiscv_225_,_zz_VexRiscv_109_};
  assign _zz_VexRiscv_213_ = ((decode_INSTRUCTION & _zz_VexRiscv_226_) == (32'b00000000000000000001000001010000));
  assign _zz_VexRiscv_214_ = ((decode_INSTRUCTION & _zz_VexRiscv_227_) == (32'b00000000000000000010000001010000));
  assign _zz_VexRiscv_215_ = (_zz_VexRiscv_228_ == _zz_VexRiscv_229_);
  assign _zz_VexRiscv_216_ = (_zz_VexRiscv_230_ == _zz_VexRiscv_231_);
  assign _zz_VexRiscv_217_ = (_zz_VexRiscv_232_ == _zz_VexRiscv_233_);
  assign _zz_VexRiscv_218_ = (1'b0);
  assign _zz_VexRiscv_219_ = ({_zz_VexRiscv_234_,_zz_VexRiscv_235_} != (2'b00));
  assign _zz_VexRiscv_220_ = (_zz_VexRiscv_236_ != _zz_VexRiscv_237_);
  assign _zz_VexRiscv_221_ = {_zz_VexRiscv_238_,{_zz_VexRiscv_239_,_zz_VexRiscv_240_}};
  assign _zz_VexRiscv_222_ = (32'b00000000000000000101000000000100);
  assign _zz_VexRiscv_223_ = (decode_INSTRUCTION & (32'b00000000000000000001000000010000));
  assign _zz_VexRiscv_224_ = (32'b00000000000000000001000000010000);
  assign _zz_VexRiscv_225_ = ((decode_INSTRUCTION & (32'b00000000000000000010000000010000)) == (32'b00000000000000000010000000010000));
  assign _zz_VexRiscv_226_ = (32'b00000000000000000001000001010000);
  assign _zz_VexRiscv_227_ = (32'b00000000000000000010000001010000);
  assign _zz_VexRiscv_228_ = (decode_INSTRUCTION & (32'b00000000000000000000000000110100));
  assign _zz_VexRiscv_229_ = (32'b00000000000000000000000000100000);
  assign _zz_VexRiscv_230_ = (decode_INSTRUCTION & (32'b00000000000000000000000001100100));
  assign _zz_VexRiscv_231_ = (32'b00000000000000000000000000100000);
  assign _zz_VexRiscv_232_ = (decode_INSTRUCTION & (32'b00000000000000000000000001010000));
  assign _zz_VexRiscv_233_ = (32'b00000000000000000000000000000000);
  assign _zz_VexRiscv_234_ = ((decode_INSTRUCTION & _zz_VexRiscv_241_) == (32'b00000000000000000001000000000000));
  assign _zz_VexRiscv_235_ = _zz_VexRiscv_108_;
  assign _zz_VexRiscv_236_ = {_zz_VexRiscv_108_,{_zz_VexRiscv_242_,_zz_VexRiscv_243_}};
  assign _zz_VexRiscv_237_ = (3'b000);
  assign _zz_VexRiscv_238_ = (_zz_VexRiscv_109_ != (1'b0));
  assign _zz_VexRiscv_239_ = ({_zz_VexRiscv_244_,_zz_VexRiscv_245_} != (2'b00));
  assign _zz_VexRiscv_240_ = {(_zz_VexRiscv_246_ != _zz_VexRiscv_247_),{_zz_VexRiscv_248_,{_zz_VexRiscv_249_,_zz_VexRiscv_250_}}};
  assign _zz_VexRiscv_241_ = (32'b00000000000000000001000000000000);
  assign _zz_VexRiscv_242_ = ((decode_INSTRUCTION & (32'b00000000000000000011000000000000)) == (32'b00000000000000000001000000000000));
  assign _zz_VexRiscv_243_ = ((decode_INSTRUCTION & (32'b00000000000000000011000000000000)) == (32'b00000000000000000010000000000000));
  assign _zz_VexRiscv_244_ = _zz_VexRiscv_108_;
  assign _zz_VexRiscv_245_ = ((decode_INSTRUCTION & _zz_VexRiscv_251_) == (32'b00000000000000000000000000100000));
  assign _zz_VexRiscv_246_ = {_zz_VexRiscv_108_,_zz_VexRiscv_107_};
  assign _zz_VexRiscv_247_ = (2'b00);
  assign _zz_VexRiscv_248_ = ((_zz_VexRiscv_252_ == _zz_VexRiscv_253_) != (1'b0));
  assign _zz_VexRiscv_249_ = (_zz_VexRiscv_254_ != (1'b0));
  assign _zz_VexRiscv_250_ = {(_zz_VexRiscv_255_ != _zz_VexRiscv_256_),{_zz_VexRiscv_257_,{_zz_VexRiscv_258_,_zz_VexRiscv_259_}}};
  assign _zz_VexRiscv_251_ = (32'b00000000000000000000000001110000);
  assign _zz_VexRiscv_252_ = (decode_INSTRUCTION & (32'b00000000000000000011000001010000));
  assign _zz_VexRiscv_253_ = (32'b00000000000000000000000001010000);
  assign _zz_VexRiscv_254_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000010000)) == (32'b00000000000000000000000000010000));
  assign _zz_VexRiscv_255_ = {(_zz_VexRiscv_260_ == _zz_VexRiscv_261_),{_zz_VexRiscv_262_,_zz_VexRiscv_263_}};
  assign _zz_VexRiscv_256_ = (3'b000);
  assign _zz_VexRiscv_257_ = ({_zz_VexRiscv_264_,_zz_VexRiscv_265_} != (2'b00));
  assign _zz_VexRiscv_258_ = (_zz_VexRiscv_106_ != (1'b0));
  assign _zz_VexRiscv_259_ = {(_zz_VexRiscv_266_ != _zz_VexRiscv_267_),{_zz_VexRiscv_268_,{_zz_VexRiscv_269_,_zz_VexRiscv_270_}}};
  assign _zz_VexRiscv_260_ = (decode_INSTRUCTION & (32'b00000000000000000000000001000100));
  assign _zz_VexRiscv_261_ = (32'b00000000000000000000000001000000);
  assign _zz_VexRiscv_262_ = ((decode_INSTRUCTION & (32'b01000000000000000000000000110000)) == (32'b01000000000000000000000000110000));
  assign _zz_VexRiscv_263_ = ((decode_INSTRUCTION & (32'b00000000000000000010000000010100)) == (32'b00000000000000000010000000010000));
  assign _zz_VexRiscv_264_ = ((decode_INSTRUCTION & (32'b00000000000000000010000000010000)) == (32'b00000000000000000010000000000000));
  assign _zz_VexRiscv_265_ = ((decode_INSTRUCTION & (32'b00000000000000000101000000000000)) == (32'b00000000000000000001000000000000));
  assign _zz_VexRiscv_266_ = ((decode_INSTRUCTION & _zz_VexRiscv_271_) == (32'b00000000000000000000000001000000));
  assign _zz_VexRiscv_267_ = (1'b0);
  assign _zz_VexRiscv_268_ = ({_zz_VexRiscv_272_,{_zz_VexRiscv_273_,_zz_VexRiscv_274_}} != (3'b000));
  assign _zz_VexRiscv_269_ = (_zz_VexRiscv_105_ != (1'b0));
  assign _zz_VexRiscv_270_ = {(_zz_VexRiscv_275_ != _zz_VexRiscv_276_),{_zz_VexRiscv_277_,_zz_VexRiscv_278_}};
  assign _zz_VexRiscv_271_ = (32'b00000000000000000000000001011000);
  assign _zz_VexRiscv_272_ = ((decode_INSTRUCTION & (32'b00000000000000000100000000000100)) == (32'b00000000000000000100000000000000));
  assign _zz_VexRiscv_273_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001100100)) == (32'b00000000000000000000000000100100));
  assign _zz_VexRiscv_274_ = ((decode_INSTRUCTION & (32'b00000000000000000011000000000100)) == (32'b00000000000000000001000000000000));
  assign _zz_VexRiscv_275_ = {((decode_INSTRUCTION & _zz_VexRiscv_279_) == (32'b00000000000000000000000001000000)),((decode_INSTRUCTION & _zz_VexRiscv_280_) == (32'b00000000000000000000000001000000))};
  assign _zz_VexRiscv_276_ = (2'b00);
  assign _zz_VexRiscv_277_ = (((decode_INSTRUCTION & _zz_VexRiscv_281_) == (32'b00000000000000000101000000010000)) != (1'b0));
  assign _zz_VexRiscv_278_ = ({(_zz_VexRiscv_282_ == _zz_VexRiscv_283_),(_zz_VexRiscv_284_ == _zz_VexRiscv_285_)} != (2'b00));
  assign _zz_VexRiscv_279_ = (32'b00000000000000000000000001010000);
  assign _zz_VexRiscv_280_ = (32'b00000000000000000011000001000000);
  assign _zz_VexRiscv_281_ = (32'b00000000000000000111000001010100);
  assign _zz_VexRiscv_282_ = (decode_INSTRUCTION & (32'b01000000000000000011000001010100));
  assign _zz_VexRiscv_283_ = (32'b01000000000000000001000000010000);
  assign _zz_VexRiscv_284_ = (decode_INSTRUCTION & (32'b00000000000000000111000001010100));
  assign _zz_VexRiscv_285_ = (32'b00000000000000000001000000010000);
  always @ (posedge toplevel_main_clk) begin
    if(_zz_VexRiscv_39_) begin
      RegFilePlugin_regFile[writeBack_RegFilePlugin_regFileWrite_payload_address] <= writeBack_RegFilePlugin_regFileWrite_payload_data;
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(_zz_VexRiscv_197_) begin
      _zz_VexRiscv_143_ <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress1];
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(_zz_VexRiscv_198_) begin
      _zz_VexRiscv_144_ <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress2];
    end
  end

  StreamFifoLowLatency IBusSimplePlugin_rspJoin_rspBuffer_c ( 
    .io_push_valid(iBus_rsp_takeWhen_valid),
    .io_push_ready(IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready),
    .io_push_payload_error(iBus_rsp_takeWhen_payload_error),
    .io_push_payload_inst(iBus_rsp_takeWhen_payload_inst),
    .io_pop_valid(IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid),
    .io_pop_ready(IBusSimplePlugin_rspJoin_rspBufferOutput_ready),
    .io_pop_payload_error(IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error),
    .io_pop_payload_inst(IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst),
    .io_flush(_zz_VexRiscv_142_),
    .io_occupancy(IBusSimplePlugin_rspJoin_rspBuffer_c_io_occupancy),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  assign execute_BRANCH_CALC = _zz_VexRiscv_20_;
  assign decode_RS2 = _zz_VexRiscv_40_;
  assign memory_MEMORY_READ_DATA = _zz_VexRiscv_65_;
  assign execute_BYPASSABLE_MEMORY_STAGE = decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  assign decode_BYPASSABLE_MEMORY_STAGE = _zz_VexRiscv_52_;
  assign memory_MEMORY_ADDRESS_LOW = execute_to_memory_MEMORY_ADDRESS_LOW;
  assign execute_MEMORY_ADDRESS_LOW = _zz_VexRiscv_66_;
  assign decode_SRC1 = _zz_VexRiscv_33_;
  assign decode_SRC_LESS_UNSIGNED = _zz_VexRiscv_54_;
  assign memory_PC = execute_to_memory_PC;
  assign decode_CSR_WRITE_OPCODE = _zz_VexRiscv_62_;
  assign decode_IS_CSR = _zz_VexRiscv_45_;
  assign decode_BRANCH_CTRL = _zz_VexRiscv_1_;
  assign _zz_VexRiscv_2_ = _zz_VexRiscv_3_;
  assign writeBack_FORMAL_PC_NEXT = memory_to_writeBack_FORMAL_PC_NEXT;
  assign memory_FORMAL_PC_NEXT = execute_to_memory_FORMAL_PC_NEXT;
  assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
  assign decode_FORMAL_PC_NEXT = _zz_VexRiscv_68_;
  assign decode_CSR_READ_OPCODE = _zz_VexRiscv_61_;
  assign decode_ALU_CTRL = _zz_VexRiscv_4_;
  assign _zz_VexRiscv_5_ = _zz_VexRiscv_6_;
  assign _zz_VexRiscv_7_ = _zz_VexRiscv_8_;
  assign _zz_VexRiscv_9_ = _zz_VexRiscv_10_;
  assign decode_ENV_CTRL = _zz_VexRiscv_11_;
  assign _zz_VexRiscv_12_ = _zz_VexRiscv_13_;
  assign decode_RS1 = _zz_VexRiscv_41_;
  assign decode_SHIFT_CTRL = _zz_VexRiscv_14_;
  assign _zz_VexRiscv_15_ = _zz_VexRiscv_16_;
  assign execute_BRANCH_DO = _zz_VexRiscv_22_;
  assign decode_BYPASSABLE_EXECUTE_STAGE = _zz_VexRiscv_49_;
  assign decode_MEMORY_ENABLE = _zz_VexRiscv_47_;
  assign writeBack_REGFILE_WRITE_DATA = memory_to_writeBack_REGFILE_WRITE_DATA;
  assign execute_REGFILE_WRITE_DATA = _zz_VexRiscv_35_;
  assign decode_SRC2 = _zz_VexRiscv_30_;
  assign decode_SRC_USE_SUB_LESS = _zz_VexRiscv_53_;
  assign decode_ALU_BITWISE_CTRL = _zz_VexRiscv_17_;
  assign _zz_VexRiscv_18_ = _zz_VexRiscv_19_;
  assign memory_BRANCH_CALC = execute_to_memory_BRANCH_CALC;
  assign memory_BRANCH_DO = execute_to_memory_BRANCH_DO;
  assign execute_PC = decode_to_execute_PC;
  assign execute_RS1 = decode_to_execute_RS1;
  assign execute_BRANCH_CTRL = _zz_VexRiscv_21_;
  assign decode_RS2_USE = _zz_VexRiscv_46_;
  assign decode_RS1_USE = _zz_VexRiscv_43_;
  assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
  assign execute_BYPASSABLE_EXECUTE_STAGE = decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  assign memory_REGFILE_WRITE_VALID = execute_to_memory_REGFILE_WRITE_VALID;
  assign memory_BYPASSABLE_MEMORY_STAGE = execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  assign writeBack_REGFILE_WRITE_VALID = memory_to_writeBack_REGFILE_WRITE_VALID;
  assign memory_REGFILE_WRITE_DATA = execute_to_memory_REGFILE_WRITE_DATA;
  assign execute_SHIFT_CTRL = _zz_VexRiscv_23_;
  assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
  assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
  assign _zz_VexRiscv_27_ = decode_PC;
  assign _zz_VexRiscv_28_ = decode_RS2;
  assign decode_SRC2_CTRL = _zz_VexRiscv_29_;
  assign _zz_VexRiscv_31_ = decode_RS1;
  assign decode_SRC1_CTRL = _zz_VexRiscv_32_;
  assign execute_SRC_ADD_SUB = _zz_VexRiscv_26_;
  assign execute_SRC_LESS = _zz_VexRiscv_24_;
  assign execute_ALU_CTRL = _zz_VexRiscv_34_;
  assign execute_SRC2 = decode_to_execute_SRC2;
  assign execute_ALU_BITWISE_CTRL = _zz_VexRiscv_36_;
  assign _zz_VexRiscv_37_ = writeBack_INSTRUCTION;
  assign _zz_VexRiscv_38_ = writeBack_REGFILE_WRITE_VALID;
  always @ (*) begin
    _zz_VexRiscv_39_ = 1'b0;
    if(writeBack_RegFilePlugin_regFileWrite_valid)begin
      _zz_VexRiscv_39_ = 1'b1;
    end
  end

  assign decode_INSTRUCTION_ANTICIPATED = _zz_VexRiscv_71_;
  always @ (*) begin
    decode_REGFILE_WRITE_VALID = _zz_VexRiscv_44_;
    if((decode_INSTRUCTION[11 : 7] == (5'b00000)))begin
      decode_REGFILE_WRITE_VALID = 1'b0;
    end
  end

  always @ (*) begin
    _zz_VexRiscv_58_ = execute_REGFILE_WRITE_DATA;
    execute_arbitration_haltItself = 1'b0;
    if(((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! dBus_cmd_ready)) && (! execute_ALIGNEMENT_FAULT)) && (! execute_DBusSimplePlugin_cmdSent)))begin
      execute_arbitration_haltItself = 1'b1;
    end
    if((execute_arbitration_isValid && execute_IS_CSR))begin
      _zz_VexRiscv_58_ = execute_CsrPlugin_readData;
      if(execute_CsrPlugin_blockedBySideEffects)begin
        execute_arbitration_haltItself = 1'b1;
      end
    end
    if(_zz_VexRiscv_145_)begin
      _zz_VexRiscv_58_ = _zz_VexRiscv_126_;
      if(_zz_VexRiscv_146_)begin
        if(! execute_LightShifterPlugin_done) begin
          execute_arbitration_haltItself = 1'b1;
        end
      end
    end
  end

  assign execute_SRC1 = decode_to_execute_SRC1;
  assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
  assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
  assign execute_IS_CSR = decode_to_execute_IS_CSR;
  assign memory_ENV_CTRL = _zz_VexRiscv_59_;
  assign execute_ENV_CTRL = _zz_VexRiscv_60_;
  assign writeBack_ENV_CTRL = _zz_VexRiscv_63_;
  always @ (*) begin
    _zz_VexRiscv_64_ = writeBack_REGFILE_WRITE_DATA;
    if((writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE))begin
      _zz_VexRiscv_64_ = writeBack_DBusSimplePlugin_rspFormated;
    end
  end

  assign writeBack_MEMORY_ENABLE = memory_to_writeBack_MEMORY_ENABLE;
  assign writeBack_MEMORY_ADDRESS_LOW = memory_to_writeBack_MEMORY_ADDRESS_LOW;
  assign writeBack_MEMORY_READ_DATA = memory_to_writeBack_MEMORY_READ_DATA;
  assign memory_INSTRUCTION = execute_to_memory_INSTRUCTION;
  assign memory_MEMORY_ENABLE = execute_to_memory_MEMORY_ENABLE;
  assign execute_RS2 = decode_to_execute_RS2;
  assign execute_SRC_ADD = _zz_VexRiscv_25_;
  assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
  assign execute_ALIGNEMENT_FAULT = 1'b0;
  assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
  always @ (*) begin
    _zz_VexRiscv_67_ = memory_FORMAL_PC_NEXT;
    if(_zz_VexRiscv_75_)begin
      _zz_VexRiscv_67_ = _zz_VexRiscv_76_;
    end
  end

  assign writeBack_PC = memory_to_writeBack_PC;
  assign writeBack_INSTRUCTION = memory_to_writeBack_INSTRUCTION;
  assign decode_PC = _zz_VexRiscv_70_;
  assign decode_INSTRUCTION = _zz_VexRiscv_69_;
  assign decode_arbitration_haltItself = 1'b0;
  always @ (*) begin
    decode_arbitration_haltByOther = 1'b0;
    if((CsrPlugin_interrupt && decode_arbitration_isValid))begin
      decode_arbitration_haltByOther = 1'b1;
    end
    if(({(memory_arbitration_isValid && (memory_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET)),(execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET))} != (2'b00)))begin
      decode_arbitration_haltByOther = 1'b1;
    end
    if((decode_arbitration_isValid && (_zz_VexRiscv_127_ || _zz_VexRiscv_128_)))begin
      decode_arbitration_haltByOther = 1'b1;
    end
  end

  always @ (*) begin
    decode_arbitration_removeIt = 1'b0;
    if(decode_arbitration_isFlushed)begin
      decode_arbitration_removeIt = 1'b1;
    end
  end

  assign decode_arbitration_flushAll = 1'b0;
  assign decode_arbitration_redoIt = 1'b0;
  assign execute_arbitration_haltByOther = 1'b0;
  always @ (*) begin
    execute_arbitration_removeIt = 1'b0;
    if(execute_arbitration_isFlushed)begin
      execute_arbitration_removeIt = 1'b1;
    end
  end

  always @ (*) begin
    execute_arbitration_flushAll = 1'b0;
    if(_zz_VexRiscv_75_)begin
      execute_arbitration_flushAll = 1'b1;
    end
  end

  assign execute_arbitration_redoIt = 1'b0;
  always @ (*) begin
    memory_arbitration_haltItself = 1'b0;
    if((((memory_arbitration_isValid && memory_MEMORY_ENABLE) && (! memory_INSTRUCTION[5])) && (! dBus_rsp_ready)))begin
      memory_arbitration_haltItself = 1'b1;
    end
  end

  assign memory_arbitration_haltByOther = 1'b0;
  always @ (*) begin
    memory_arbitration_removeIt = 1'b0;
    if(memory_arbitration_isFlushed)begin
      memory_arbitration_removeIt = 1'b1;
    end
  end

  always @ (*) begin
    memory_arbitration_flushAll = 1'b0;
    _zz_VexRiscv_73_ = 1'b0;
    _zz_VexRiscv_74_ = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    if(_zz_VexRiscv_147_)begin
      _zz_VexRiscv_73_ = 1'b1;
      _zz_VexRiscv_74_ = {CsrPlugin_mtvec_base,(2'b00)};
      memory_arbitration_flushAll = 1'b1;
    end
    if(_zz_VexRiscv_148_)begin
      _zz_VexRiscv_74_ = CsrPlugin_mepc;
      _zz_VexRiscv_73_ = 1'b1;
      memory_arbitration_flushAll = 1'b1;
    end
  end

  assign memory_arbitration_redoIt = 1'b0;
  assign writeBack_arbitration_haltItself = 1'b0;
  assign writeBack_arbitration_haltByOther = 1'b0;
  always @ (*) begin
    writeBack_arbitration_removeIt = 1'b0;
    if(writeBack_arbitration_isFlushed)begin
      writeBack_arbitration_removeIt = 1'b1;
    end
  end

  assign writeBack_arbitration_flushAll = 1'b0;
  assign writeBack_arbitration_redoIt = 1'b0;
  assign _zz_VexRiscv_72_ = 1'b0;
  assign IBusSimplePlugin_jump_pcLoad_valid = ({_zz_VexRiscv_75_,_zz_VexRiscv_73_} != (2'b00));
  assign _zz_VexRiscv_77_ = {_zz_VexRiscv_75_,_zz_VexRiscv_73_};
  assign IBusSimplePlugin_jump_pcLoad_payload = (_zz_VexRiscv_153_[0] ? _zz_VexRiscv_74_ : _zz_VexRiscv_76_);
  assign _zz_VexRiscv_78_ = (! 1'b0);
  assign IBusSimplePlugin_fetchPc_output_valid = (IBusSimplePlugin_fetchPc_preOutput_valid && _zz_VexRiscv_78_);
  assign IBusSimplePlugin_fetchPc_preOutput_ready = (IBusSimplePlugin_fetchPc_output_ready && _zz_VexRiscv_78_);
  assign IBusSimplePlugin_fetchPc_output_payload = IBusSimplePlugin_fetchPc_preOutput_payload;
  always @ (*) begin
    IBusSimplePlugin_fetchPc_propagatePc = 1'b0;
    if((IBusSimplePlugin_iBusRsp_stages_1_input_valid && IBusSimplePlugin_iBusRsp_stages_1_input_ready))begin
      IBusSimplePlugin_fetchPc_propagatePc = 1'b1;
    end
  end

  always @ (*) begin
    IBusSimplePlugin_fetchPc_pc = (IBusSimplePlugin_fetchPc_pcReg + _zz_VexRiscv_156_);
    IBusSimplePlugin_fetchPc_samplePcNext = 1'b0;
    if(IBusSimplePlugin_fetchPc_propagatePc)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
    end
    if(IBusSimplePlugin_jump_pcLoad_valid)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
      IBusSimplePlugin_fetchPc_pc = IBusSimplePlugin_jump_pcLoad_payload;
    end
    if(_zz_VexRiscv_149_)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
    end
    IBusSimplePlugin_fetchPc_pc[0] = 1'b0;
    IBusSimplePlugin_fetchPc_pc[1] = 1'b0;
  end

  assign IBusSimplePlugin_fetchPc_preOutput_valid = _zz_VexRiscv_79_;
  assign IBusSimplePlugin_fetchPc_preOutput_payload = IBusSimplePlugin_fetchPc_pc;
  assign IBusSimplePlugin_iBusRsp_stages_0_input_valid = IBusSimplePlugin_fetchPc_output_valid;
  assign IBusSimplePlugin_fetchPc_output_ready = IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  assign IBusSimplePlugin_iBusRsp_stages_0_input_payload = IBusSimplePlugin_fetchPc_output_payload;
  assign IBusSimplePlugin_iBusRsp_stages_0_inputSample = 1'b1;
  assign IBusSimplePlugin_iBusRsp_stages_0_halt = 1'b0;
  assign _zz_VexRiscv_80_ = (! IBusSimplePlugin_iBusRsp_stages_0_halt);
  assign IBusSimplePlugin_iBusRsp_stages_0_input_ready = (IBusSimplePlugin_iBusRsp_stages_0_output_ready && _zz_VexRiscv_80_);
  assign IBusSimplePlugin_iBusRsp_stages_0_output_valid = (IBusSimplePlugin_iBusRsp_stages_0_input_valid && _zz_VexRiscv_80_);
  assign IBusSimplePlugin_iBusRsp_stages_0_output_payload = IBusSimplePlugin_iBusRsp_stages_0_input_payload;
  always @ (*) begin
    IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b0;
    if((IBusSimplePlugin_iBusRsp_stages_1_input_valid && ((! IBusSimplePlugin_cmd_valid) || (! IBusSimplePlugin_cmd_ready))))begin
      IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b1;
    end
  end

  assign _zz_VexRiscv_81_ = (! IBusSimplePlugin_iBusRsp_stages_1_halt);
  assign IBusSimplePlugin_iBusRsp_stages_1_input_ready = (IBusSimplePlugin_iBusRsp_stages_1_output_ready && _zz_VexRiscv_81_);
  assign IBusSimplePlugin_iBusRsp_stages_1_output_valid = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && _zz_VexRiscv_81_);
  assign IBusSimplePlugin_iBusRsp_stages_1_output_payload = IBusSimplePlugin_iBusRsp_stages_1_input_payload;
  assign IBusSimplePlugin_iBusRsp_stages_2_halt = 1'b0;
  assign _zz_VexRiscv_82_ = (! IBusSimplePlugin_iBusRsp_stages_2_halt);
  assign IBusSimplePlugin_iBusRsp_stages_2_input_ready = (IBusSimplePlugin_iBusRsp_stages_2_output_ready && _zz_VexRiscv_82_);
  assign IBusSimplePlugin_iBusRsp_stages_2_output_valid = (IBusSimplePlugin_iBusRsp_stages_2_input_valid && _zz_VexRiscv_82_);
  assign IBusSimplePlugin_iBusRsp_stages_2_output_payload = IBusSimplePlugin_iBusRsp_stages_2_input_payload;
  assign IBusSimplePlugin_iBusRsp_stages_0_output_ready = _zz_VexRiscv_83_;
  assign _zz_VexRiscv_83_ = ((1'b0 && (! _zz_VexRiscv_84_)) || IBusSimplePlugin_iBusRsp_stages_1_input_ready);
  assign _zz_VexRiscv_84_ = _zz_VexRiscv_85_;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_valid = _zz_VexRiscv_84_;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_payload = IBusSimplePlugin_fetchPc_pcReg;
  assign IBusSimplePlugin_iBusRsp_stages_1_output_ready = ((1'b0 && (! _zz_VexRiscv_86_)) || IBusSimplePlugin_iBusRsp_stages_2_input_ready);
  assign _zz_VexRiscv_86_ = _zz_VexRiscv_87_;
  assign IBusSimplePlugin_iBusRsp_stages_2_input_valid = _zz_VexRiscv_86_;
  assign IBusSimplePlugin_iBusRsp_stages_2_input_payload = _zz_VexRiscv_88_;
  always @ (*) begin
    IBusSimplePlugin_iBusRsp_readyForError = 1'b1;
    if(IBusSimplePlugin_injector_decodeInput_valid)begin
      IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
    end
  end

  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_ready = ((1'b0 && (! IBusSimplePlugin_injector_decodeInput_valid)) || IBusSimplePlugin_injector_decodeInput_ready);
  assign IBusSimplePlugin_injector_decodeInput_valid = _zz_VexRiscv_89_;
  assign IBusSimplePlugin_injector_decodeInput_payload_pc = _zz_VexRiscv_90_;
  assign IBusSimplePlugin_injector_decodeInput_payload_rsp_error = _zz_VexRiscv_91_;
  assign IBusSimplePlugin_injector_decodeInput_payload_rsp_inst = _zz_VexRiscv_92_;
  assign IBusSimplePlugin_injector_decodeInput_payload_isRvc = _zz_VexRiscv_93_;
  assign _zz_VexRiscv_71_ = (decode_arbitration_isStuck ? decode_INSTRUCTION : IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw);
  assign IBusSimplePlugin_injector_decodeInput_ready = (! decode_arbitration_isStuck);
  assign decode_arbitration_isValid = (IBusSimplePlugin_injector_decodeInput_valid && (! IBusSimplePlugin_injector_decodeRemoved));
  assign _zz_VexRiscv_70_ = IBusSimplePlugin_injector_decodeInput_payload_pc;
  assign _zz_VexRiscv_69_ = IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
  assign _zz_VexRiscv_68_ = (decode_PC + (32'b00000000000000000000000000000100));
  assign iBus_cmd_valid = IBusSimplePlugin_cmd_valid;
  assign IBusSimplePlugin_cmd_ready = iBus_cmd_ready;
  assign iBus_cmd_payload_pc = IBusSimplePlugin_cmd_payload_pc;
  assign IBusSimplePlugin_pendingCmdNext = (_zz_VexRiscv_157_ - _zz_VexRiscv_161_);
  assign IBusSimplePlugin_cmd_valid = ((IBusSimplePlugin_iBusRsp_stages_1_input_valid && IBusSimplePlugin_iBusRsp_stages_1_output_ready) && (IBusSimplePlugin_pendingCmd != (3'b111)));
  assign IBusSimplePlugin_cmd_payload_pc = {IBusSimplePlugin_iBusRsp_stages_1_input_payload[31 : 2],(2'b00)};
  assign iBus_rsp_takeWhen_valid = (iBus_rsp_valid && (! (IBusSimplePlugin_rspJoin_discardCounter != (3'b000))));
  assign iBus_rsp_takeWhen_payload_error = iBus_rsp_payload_error;
  assign iBus_rsp_takeWhen_payload_inst = iBus_rsp_payload_inst;
  assign _zz_VexRiscv_142_ = (IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_);
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_valid = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid;
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error;
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst;
  assign IBusSimplePlugin_rspJoin_fetchRsp_pc = IBusSimplePlugin_iBusRsp_stages_2_output_payload;
  always @ (*) begin
    IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error;
    if((! IBusSimplePlugin_rspJoin_rspBufferOutput_valid))begin
      IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = 1'b0;
    end
  end

  assign IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst = IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst;
  assign IBusSimplePlugin_rspJoin_issueDetected = 1'b0;
  assign IBusSimplePlugin_rspJoin_join_valid = (IBusSimplePlugin_iBusRsp_stages_2_output_valid && IBusSimplePlugin_rspJoin_rspBufferOutput_valid);
  assign IBusSimplePlugin_rspJoin_join_payload_pc = IBusSimplePlugin_rspJoin_fetchRsp_pc;
  assign IBusSimplePlugin_rspJoin_join_payload_rsp_error = IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
  assign IBusSimplePlugin_rspJoin_join_payload_rsp_inst = IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
  assign IBusSimplePlugin_rspJoin_join_payload_isRvc = IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
  assign IBusSimplePlugin_iBusRsp_stages_2_output_ready = (IBusSimplePlugin_iBusRsp_stages_2_output_valid ? (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready) : IBusSimplePlugin_rspJoin_join_ready);
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_ready = (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready);
  assign _zz_VexRiscv_94_ = (! IBusSimplePlugin_rspJoin_issueDetected);
  assign IBusSimplePlugin_rspJoin_join_ready = (IBusSimplePlugin_iBusRsp_inputBeforeStage_ready && _zz_VexRiscv_94_);
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_valid = (IBusSimplePlugin_rspJoin_join_valid && _zz_VexRiscv_94_);
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_pc = IBusSimplePlugin_rspJoin_join_payload_pc;
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_error = IBusSimplePlugin_rspJoin_join_payload_rsp_error;
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw = IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_isRvc = IBusSimplePlugin_rspJoin_join_payload_isRvc;
  assign execute_DBusSimplePlugin_cmdSent = 1'b0;
  assign dBus_cmd_valid = (((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_arbitration_isStuckByOthers)) && (! execute_arbitration_isFlushed)) && (! execute_ALIGNEMENT_FAULT)) && (! execute_DBusSimplePlugin_cmdSent));
  assign dBus_cmd_payload_wr = execute_INSTRUCTION[5];
  assign dBus_cmd_payload_address = execute_SRC_ADD;
  assign dBus_cmd_payload_size = execute_INSTRUCTION[13 : 12];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_VexRiscv_95_ = {{{execute_RS2[7 : 0],execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]};
      end
      2'b01 : begin
        _zz_VexRiscv_95_ = {execute_RS2[15 : 0],execute_RS2[15 : 0]};
      end
      default : begin
        _zz_VexRiscv_95_ = execute_RS2[31 : 0];
      end
    endcase
  end

  assign dBus_cmd_payload_data = _zz_VexRiscv_95_;
  assign _zz_VexRiscv_66_ = dBus_cmd_payload_address[1 : 0];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_VexRiscv_96_ = (4'b0001);
      end
      2'b01 : begin
        _zz_VexRiscv_96_ = (4'b0011);
      end
      default : begin
        _zz_VexRiscv_96_ = (4'b1111);
      end
    endcase
  end

  assign execute_DBusSimplePlugin_formalMask = (_zz_VexRiscv_96_ <<< dBus_cmd_payload_address[1 : 0]);
  assign _zz_VexRiscv_65_ = dBus_rsp_data;
  always @ (*) begin
    writeBack_DBusSimplePlugin_rspShifted = writeBack_MEMORY_READ_DATA;
    case(writeBack_MEMORY_ADDRESS_LOW)
      2'b01 : begin
        writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[15 : 8];
      end
      2'b10 : begin
        writeBack_DBusSimplePlugin_rspShifted[15 : 0] = writeBack_MEMORY_READ_DATA[31 : 16];
      end
      2'b11 : begin
        writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[31 : 24];
      end
      default : begin
      end
    endcase
  end

  assign _zz_VexRiscv_97_ = (writeBack_DBusSimplePlugin_rspShifted[7] && (! writeBack_INSTRUCTION[14]));
  always @ (*) begin
    _zz_VexRiscv_98_[31] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[30] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[29] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[28] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[27] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[26] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[25] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[24] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[23] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[22] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[21] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[20] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[19] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[18] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[17] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[16] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[15] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[14] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[13] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[12] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[11] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[10] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[9] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[8] = _zz_VexRiscv_97_;
    _zz_VexRiscv_98_[7 : 0] = writeBack_DBusSimplePlugin_rspShifted[7 : 0];
  end

  assign _zz_VexRiscv_99_ = (writeBack_DBusSimplePlugin_rspShifted[15] && (! writeBack_INSTRUCTION[14]));
  always @ (*) begin
    _zz_VexRiscv_100_[31] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[30] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[29] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[28] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[27] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[26] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[25] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[24] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[23] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[22] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[21] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[20] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[19] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[18] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[17] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[16] = _zz_VexRiscv_99_;
    _zz_VexRiscv_100_[15 : 0] = writeBack_DBusSimplePlugin_rspShifted[15 : 0];
  end

  always @ (*) begin
    case(_zz_VexRiscv_150_)
      2'b00 : begin
        writeBack_DBusSimplePlugin_rspFormated = _zz_VexRiscv_98_;
      end
      2'b01 : begin
        writeBack_DBusSimplePlugin_rspFormated = _zz_VexRiscv_100_;
      end
      default : begin
        writeBack_DBusSimplePlugin_rspFormated = writeBack_DBusSimplePlugin_rspShifted;
      end
    endcase
  end

  assign CsrPlugin_misa_base = (2'b01);
  assign CsrPlugin_misa_extensions = (26'b00000000000000000001000010);
  assign CsrPlugin_mtvec_mode = (2'b00);
  assign CsrPlugin_mtvec_base = (30'b000000000000000000000000001000);
  assign CsrPlugin_medeleg = (32'b00000000000000000000000000000000);
  assign CsrPlugin_mideleg = (32'b00000000000000000000000000000000);
  assign _zz_VexRiscv_101_ = (CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE);
  assign _zz_VexRiscv_102_ = (CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE);
  assign _zz_VexRiscv_103_ = (CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE);
  always @ (*) begin
    CsrPlugin_interrupt = 1'b0;
    CsrPlugin_interruptCode = (4'bxxxx);
    if(CsrPlugin_mstatus_MIE)begin
      if(({_zz_VexRiscv_103_,{_zz_VexRiscv_102_,_zz_VexRiscv_101_}} != (3'b000)))begin
        CsrPlugin_interrupt = 1'b1;
      end
      if(_zz_VexRiscv_101_)begin
        CsrPlugin_interruptCode = (4'b0111);
      end
      if(_zz_VexRiscv_102_)begin
        CsrPlugin_interruptCode = (4'b0011);
      end
      if(_zz_VexRiscv_103_)begin
        CsrPlugin_interruptCode = (4'b1011);
      end
    end
    if((! 1'b1))begin
      CsrPlugin_interrupt = 1'b0;
    end
  end

  assign CsrPlugin_interruptTargetPrivilege = (2'b11);
  assign CsrPlugin_exception = 1'b0;
  assign CsrPlugin_lastStageWasWfi = 1'b0;
  always @ (*) begin
    CsrPlugin_pipelineLiberator_done = ((! ({writeBack_arbitration_isValid,{memory_arbitration_isValid,execute_arbitration_isValid}} != (3'b000))) && IBusSimplePlugin_injector_nextPcCalc_0);
    if(CsrPlugin_hadException)begin
      CsrPlugin_pipelineLiberator_done = 1'b0;
    end
  end

  assign CsrPlugin_interruptJump = (CsrPlugin_interrupt && CsrPlugin_pipelineLiberator_done);
  assign CsrPlugin_targetPrivilege = CsrPlugin_interruptTargetPrivilege;
  assign CsrPlugin_trapCause = CsrPlugin_interruptCode;
  assign contextSwitching = _zz_VexRiscv_73_;
  assign _zz_VexRiscv_62_ = (! (((decode_INSTRUCTION[14 : 13] == (2'b01)) && (decode_INSTRUCTION[19 : 15] == (5'b00000))) || ((decode_INSTRUCTION[14 : 13] == (2'b11)) && (decode_INSTRUCTION[19 : 15] == (5'b00000)))));
  assign _zz_VexRiscv_61_ = (decode_INSTRUCTION[13 : 7] != (7'b0100000));
  assign execute_CsrPlugin_blockedBySideEffects = ({writeBack_arbitration_isValid,memory_arbitration_isValid} != (2'b00));
  always @ (*) begin
    execute_CsrPlugin_illegalAccess = 1'b1;
    execute_CsrPlugin_readData = (32'b00000000000000000000000000000000);
    case(execute_CsrPlugin_csrAddress)
      12'b001100000000 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[12 : 11] = CsrPlugin_mstatus_MPP;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mstatus_MPIE;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mstatus_MIE;
      end
      12'b001101000100 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[11 : 11] = CsrPlugin_mip_MEIP;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mip_MTIP;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mip_MSIP;
      end
      12'b001100000100 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[11 : 11] = CsrPlugin_mie_MEIE;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mie_MTIE;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mie_MSIE;
      end
      12'b001101000010 : begin
        if(execute_CSR_READ_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
        execute_CsrPlugin_readData[31 : 31] = CsrPlugin_mcause_interrupt;
        execute_CsrPlugin_readData[3 : 0] = CsrPlugin_mcause_exceptionCode;
      end
      default : begin
      end
    endcase
    if((CsrPlugin_privilege < execute_CsrPlugin_csrAddress[9 : 8]))begin
      execute_CsrPlugin_illegalAccess = 1'b1;
    end
    if(((! execute_arbitration_isValid) || (! execute_IS_CSR)))begin
      execute_CsrPlugin_illegalAccess = 1'b0;
    end
  end

  always @ (*) begin
    execute_CsrPlugin_illegalInstruction = 1'b0;
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET)))begin
      if((execute_INSTRUCTION[29 : 28] != CsrPlugin_privilege))begin
        execute_CsrPlugin_illegalInstruction = 1'b1;
      end
    end
  end

  assign execute_CsrPlugin_writeInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_WRITE_OPCODE);
  assign execute_CsrPlugin_readInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_READ_OPCODE);
  assign execute_CsrPlugin_writeEnable = ((execute_CsrPlugin_writeInstruction && (! execute_CsrPlugin_blockedBySideEffects)) && (! execute_arbitration_isStuckByOthers));
  assign execute_CsrPlugin_readEnable = ((execute_CsrPlugin_readInstruction && (! execute_CsrPlugin_blockedBySideEffects)) && (! execute_arbitration_isStuckByOthers));
  always @ (*) begin
    case(_zz_VexRiscv_152_)
      1'b0 : begin
        execute_CsrPlugin_writeData = execute_SRC1;
      end
      default : begin
        execute_CsrPlugin_writeData = (execute_INSTRUCTION[12] ? (execute_CsrPlugin_readData & (~ execute_SRC1)) : (execute_CsrPlugin_readData | execute_SRC1));
      end
    endcase
  end

  assign execute_CsrPlugin_csrAddress = execute_INSTRUCTION[31 : 20];
  assign _zz_VexRiscv_105_ = ((decode_INSTRUCTION & (32'b00000000000000000110000000000100)) == (32'b00000000000000000010000000000000));
  assign _zz_VexRiscv_106_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000010100)) == (32'b00000000000000000000000000000100));
  assign _zz_VexRiscv_107_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000100000)) == (32'b00000000000000000000000000000000));
  assign _zz_VexRiscv_108_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000000100)) == (32'b00000000000000000000000000000100));
  assign _zz_VexRiscv_109_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001010000)) == (32'b00000000000000000000000000010000));
  assign _zz_VexRiscv_110_ = ((decode_INSTRUCTION & (32'b00000000000000000100000001010000)) == (32'b00000000000000000100000001010000));
  assign _zz_VexRiscv_104_ = {({_zz_VexRiscv_106_,_zz_VexRiscv_110_} != (2'b00)),{({_zz_VexRiscv_199_,_zz_VexRiscv_110_} != (2'b00)),{({_zz_VexRiscv_200_,_zz_VexRiscv_201_} != (4'b0000)),{(_zz_VexRiscv_202_ != _zz_VexRiscv_203_),{_zz_VexRiscv_204_,{_zz_VexRiscv_205_,_zz_VexRiscv_206_}}}}}};
  assign _zz_VexRiscv_111_ = _zz_VexRiscv_104_[1 : 0];
  assign _zz_VexRiscv_57_ = _zz_VexRiscv_111_;
  assign _zz_VexRiscv_112_ = _zz_VexRiscv_104_[4 : 3];
  assign _zz_VexRiscv_56_ = _zz_VexRiscv_112_;
  assign _zz_VexRiscv_113_ = _zz_VexRiscv_104_[6 : 5];
  assign _zz_VexRiscv_55_ = _zz_VexRiscv_113_;
  assign _zz_VexRiscv_54_ = _zz_VexRiscv_164_[0];
  assign _zz_VexRiscv_53_ = _zz_VexRiscv_165_[0];
  assign _zz_VexRiscv_52_ = _zz_VexRiscv_166_[0];
  assign _zz_VexRiscv_114_ = _zz_VexRiscv_104_[10 : 10];
  assign _zz_VexRiscv_51_ = _zz_VexRiscv_114_;
  assign _zz_VexRiscv_115_ = _zz_VexRiscv_104_[12 : 11];
  assign _zz_VexRiscv_50_ = _zz_VexRiscv_115_;
  assign _zz_VexRiscv_49_ = _zz_VexRiscv_167_[0];
  assign _zz_VexRiscv_116_ = _zz_VexRiscv_104_[15 : 14];
  assign _zz_VexRiscv_48_ = _zz_VexRiscv_116_;
  assign _zz_VexRiscv_47_ = _zz_VexRiscv_168_[0];
  assign _zz_VexRiscv_46_ = _zz_VexRiscv_169_[0];
  assign _zz_VexRiscv_45_ = _zz_VexRiscv_170_[0];
  assign _zz_VexRiscv_44_ = _zz_VexRiscv_171_[0];
  assign _zz_VexRiscv_43_ = _zz_VexRiscv_172_[0];
  assign _zz_VexRiscv_117_ = _zz_VexRiscv_104_[22 : 21];
  assign _zz_VexRiscv_42_ = _zz_VexRiscv_117_;
  assign decode_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION_ANTICIPATED[19 : 15];
  assign decode_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION_ANTICIPATED[24 : 20];
  assign decode_RegFilePlugin_rs1Data = _zz_VexRiscv_143_;
  assign decode_RegFilePlugin_rs2Data = _zz_VexRiscv_144_;
  assign _zz_VexRiscv_41_ = decode_RegFilePlugin_rs1Data;
  assign _zz_VexRiscv_40_ = decode_RegFilePlugin_rs2Data;
  always @ (*) begin
    writeBack_RegFilePlugin_regFileWrite_valid = (_zz_VexRiscv_38_ && writeBack_arbitration_isFiring);
    if(_zz_VexRiscv_118_)begin
      writeBack_RegFilePlugin_regFileWrite_valid = 1'b1;
    end
  end

  assign writeBack_RegFilePlugin_regFileWrite_payload_address = _zz_VexRiscv_37_[11 : 7];
  assign writeBack_RegFilePlugin_regFileWrite_payload_data = _zz_VexRiscv_64_;
  always @ (*) begin
    case(execute_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 & execute_SRC2);
      end
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 | execute_SRC2);
      end
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 ^ execute_SRC2);
      end
      default : begin
        execute_IntAluPlugin_bitwise = execute_SRC1;
      end
    endcase
  end

  always @ (*) begin
    case(execute_ALU_CTRL)
      `AluCtrlEnum_defaultEncoding_BITWISE : begin
        _zz_VexRiscv_119_ = execute_IntAluPlugin_bitwise;
      end
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : begin
        _zz_VexRiscv_119_ = {31'd0, _zz_VexRiscv_173_};
      end
      default : begin
        _zz_VexRiscv_119_ = execute_SRC_ADD_SUB;
      end
    endcase
  end

  assign _zz_VexRiscv_35_ = _zz_VexRiscv_119_;
  always @ (*) begin
    case(decode_SRC1_CTRL)
      `Src1CtrlEnum_defaultEncoding_RS : begin
        _zz_VexRiscv_120_ = _zz_VexRiscv_31_;
      end
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : begin
        _zz_VexRiscv_120_ = {29'd0, _zz_VexRiscv_174_};
      end
      `Src1CtrlEnum_defaultEncoding_IMU : begin
        _zz_VexRiscv_120_ = {decode_INSTRUCTION[31 : 12],(12'b000000000000)};
      end
      default : begin
        _zz_VexRiscv_120_ = {27'd0, _zz_VexRiscv_175_};
      end
    endcase
  end

  assign _zz_VexRiscv_33_ = _zz_VexRiscv_120_;
  assign _zz_VexRiscv_121_ = _zz_VexRiscv_176_[11];
  always @ (*) begin
    _zz_VexRiscv_122_[19] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[18] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[17] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[16] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[15] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[14] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[13] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[12] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[11] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[10] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[9] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[8] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[7] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[6] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[5] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[4] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[3] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[2] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[1] = _zz_VexRiscv_121_;
    _zz_VexRiscv_122_[0] = _zz_VexRiscv_121_;
  end

  assign _zz_VexRiscv_123_ = _zz_VexRiscv_177_[11];
  always @ (*) begin
    _zz_VexRiscv_124_[19] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[18] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[17] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[16] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[15] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[14] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[13] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[12] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[11] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[10] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[9] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[8] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[7] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[6] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[5] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[4] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[3] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[2] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[1] = _zz_VexRiscv_123_;
    _zz_VexRiscv_124_[0] = _zz_VexRiscv_123_;
  end

  always @ (*) begin
    case(decode_SRC2_CTRL)
      `Src2CtrlEnum_defaultEncoding_RS : begin
        _zz_VexRiscv_125_ = _zz_VexRiscv_28_;
      end
      `Src2CtrlEnum_defaultEncoding_IMI : begin
        _zz_VexRiscv_125_ = {_zz_VexRiscv_122_,decode_INSTRUCTION[31 : 20]};
      end
      `Src2CtrlEnum_defaultEncoding_IMS : begin
        _zz_VexRiscv_125_ = {_zz_VexRiscv_124_,{decode_INSTRUCTION[31 : 25],decode_INSTRUCTION[11 : 7]}};
      end
      default : begin
        _zz_VexRiscv_125_ = _zz_VexRiscv_27_;
      end
    endcase
  end

  assign _zz_VexRiscv_30_ = _zz_VexRiscv_125_;
  assign execute_SrcPlugin_addSub = _zz_VexRiscv_178_;
  assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_addSub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
  assign _zz_VexRiscv_26_ = execute_SrcPlugin_addSub;
  assign _zz_VexRiscv_25_ = execute_SrcPlugin_addSub;
  assign _zz_VexRiscv_24_ = execute_SrcPlugin_less;
  assign execute_LightShifterPlugin_isShift = (execute_SHIFT_CTRL != `ShiftCtrlEnum_defaultEncoding_DISABLE_1);
  assign execute_LightShifterPlugin_amplitude = (execute_LightShifterPlugin_isActive ? execute_LightShifterPlugin_amplitudeReg : execute_SRC2[4 : 0]);
  assign execute_LightShifterPlugin_shiftInput = (execute_LightShifterPlugin_isActive ? memory_REGFILE_WRITE_DATA : execute_SRC1);
  assign execute_LightShifterPlugin_done = (execute_LightShifterPlugin_amplitude[4 : 1] == (4'b0000));
  always @ (*) begin
    case(execute_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : begin
        _zz_VexRiscv_126_ = (execute_LightShifterPlugin_shiftInput <<< 1);
      end
      default : begin
        _zz_VexRiscv_126_ = _zz_VexRiscv_186_;
      end
    endcase
  end

  always @ (*) begin
    _zz_VexRiscv_127_ = 1'b0;
    _zz_VexRiscv_128_ = 1'b0;
    if(_zz_VexRiscv_130_)begin
      if((_zz_VexRiscv_131_ == decode_INSTRUCTION[19 : 15]))begin
        _zz_VexRiscv_127_ = 1'b1;
      end
      if((_zz_VexRiscv_131_ == decode_INSTRUCTION[24 : 20]))begin
        _zz_VexRiscv_128_ = 1'b1;
      end
    end
    if((writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID))begin
      if((1'b1 || (! 1'b1)))begin
        if((writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]))begin
          _zz_VexRiscv_127_ = 1'b1;
        end
        if((writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]))begin
          _zz_VexRiscv_128_ = 1'b1;
        end
      end
    end
    if((memory_arbitration_isValid && memory_REGFILE_WRITE_VALID))begin
      if((1'b1 || (! memory_BYPASSABLE_MEMORY_STAGE)))begin
        if((memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]))begin
          _zz_VexRiscv_127_ = 1'b1;
        end
        if((memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]))begin
          _zz_VexRiscv_128_ = 1'b1;
        end
      end
    end
    if((execute_arbitration_isValid && execute_REGFILE_WRITE_VALID))begin
      if((1'b1 || (! execute_BYPASSABLE_EXECUTE_STAGE)))begin
        if((execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]))begin
          _zz_VexRiscv_127_ = 1'b1;
        end
        if((execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]))begin
          _zz_VexRiscv_128_ = 1'b1;
        end
      end
    end
    if((! decode_RS1_USE))begin
      _zz_VexRiscv_127_ = 1'b0;
    end
    if((! decode_RS2_USE))begin
      _zz_VexRiscv_128_ = 1'b0;
    end
  end

  assign _zz_VexRiscv_129_ = (_zz_VexRiscv_38_ && writeBack_arbitration_isFiring);
  assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
  assign _zz_VexRiscv_132_ = execute_INSTRUCTION[14 : 12];
  always @ (*) begin
    if((_zz_VexRiscv_132_ == (3'b000))) begin
        _zz_VexRiscv_133_ = execute_BranchPlugin_eq;
    end else if((_zz_VexRiscv_132_ == (3'b001))) begin
        _zz_VexRiscv_133_ = (! execute_BranchPlugin_eq);
    end else if((((_zz_VexRiscv_132_ & (3'b101)) == (3'b101)))) begin
        _zz_VexRiscv_133_ = (! execute_SRC_LESS);
    end else begin
        _zz_VexRiscv_133_ = execute_SRC_LESS;
    end
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_INC : begin
        _zz_VexRiscv_134_ = 1'b0;
      end
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_VexRiscv_134_ = 1'b1;
      end
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_VexRiscv_134_ = 1'b1;
      end
      default : begin
        _zz_VexRiscv_134_ = _zz_VexRiscv_133_;
      end
    endcase
  end

  assign _zz_VexRiscv_22_ = _zz_VexRiscv_134_;
  assign execute_BranchPlugin_branch_src1 = ((execute_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JALR) ? execute_RS1 : execute_PC);
  assign _zz_VexRiscv_135_ = _zz_VexRiscv_188_[19];
  always @ (*) begin
    _zz_VexRiscv_136_[10] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[9] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[8] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[7] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[6] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[5] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[4] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[3] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[2] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[1] = _zz_VexRiscv_135_;
    _zz_VexRiscv_136_[0] = _zz_VexRiscv_135_;
  end

  assign _zz_VexRiscv_137_ = _zz_VexRiscv_189_[11];
  always @ (*) begin
    _zz_VexRiscv_138_[19] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[18] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[17] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[16] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[15] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[14] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[13] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[12] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[11] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[10] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[9] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[8] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[7] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[6] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[5] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[4] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[3] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[2] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[1] = _zz_VexRiscv_137_;
    _zz_VexRiscv_138_[0] = _zz_VexRiscv_137_;
  end

  assign _zz_VexRiscv_139_ = _zz_VexRiscv_190_[11];
  always @ (*) begin
    _zz_VexRiscv_140_[18] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[17] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[16] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[15] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[14] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[13] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[12] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[11] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[10] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[9] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[8] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[7] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[6] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[5] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[4] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[3] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[2] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[1] = _zz_VexRiscv_139_;
    _zz_VexRiscv_140_[0] = _zz_VexRiscv_139_;
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_VexRiscv_141_ = {{_zz_VexRiscv_136_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0};
      end
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_VexRiscv_141_ = {_zz_VexRiscv_138_,execute_INSTRUCTION[31 : 20]};
      end
      default : begin
        _zz_VexRiscv_141_ = {{_zz_VexRiscv_140_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0};
      end
    endcase
  end

  assign execute_BranchPlugin_branch_src2 = _zz_VexRiscv_141_;
  assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
  assign _zz_VexRiscv_20_ = {execute_BranchPlugin_branchAdder[31 : 1],(1'b0)};
  assign _zz_VexRiscv_75_ = ((memory_arbitration_isValid && (! memory_arbitration_isStuckByOthers)) && memory_BRANCH_DO);
  assign _zz_VexRiscv_76_ = memory_BRANCH_CALC;
  assign _zz_VexRiscv_19_ = decode_ALU_BITWISE_CTRL;
  assign _zz_VexRiscv_17_ = _zz_VexRiscv_48_;
  assign _zz_VexRiscv_36_ = decode_to_execute_ALU_BITWISE_CTRL;
  assign _zz_VexRiscv_16_ = decode_SHIFT_CTRL;
  assign _zz_VexRiscv_14_ = _zz_VexRiscv_57_;
  assign _zz_VexRiscv_23_ = decode_to_execute_SHIFT_CTRL;
  assign _zz_VexRiscv_13_ = decode_ENV_CTRL;
  assign _zz_VexRiscv_10_ = execute_ENV_CTRL;
  assign _zz_VexRiscv_8_ = memory_ENV_CTRL;
  assign _zz_VexRiscv_11_ = _zz_VexRiscv_51_;
  assign _zz_VexRiscv_60_ = decode_to_execute_ENV_CTRL;
  assign _zz_VexRiscv_59_ = execute_to_memory_ENV_CTRL;
  assign _zz_VexRiscv_63_ = memory_to_writeBack_ENV_CTRL;
  assign _zz_VexRiscv_29_ = _zz_VexRiscv_50_;
  assign _zz_VexRiscv_6_ = decode_ALU_CTRL;
  assign _zz_VexRiscv_4_ = _zz_VexRiscv_56_;
  assign _zz_VexRiscv_34_ = decode_to_execute_ALU_CTRL;
  assign _zz_VexRiscv_3_ = decode_BRANCH_CTRL;
  assign _zz_VexRiscv_1_ = _zz_VexRiscv_55_;
  assign _zz_VexRiscv_21_ = decode_to_execute_BRANCH_CTRL;
  assign _zz_VexRiscv_32_ = _zz_VexRiscv_42_;
  assign decode_arbitration_isFlushed = ({writeBack_arbitration_flushAll,{memory_arbitration_flushAll,{execute_arbitration_flushAll,decode_arbitration_flushAll}}} != (4'b0000));
  assign execute_arbitration_isFlushed = ({writeBack_arbitration_flushAll,{memory_arbitration_flushAll,execute_arbitration_flushAll}} != (3'b000));
  assign memory_arbitration_isFlushed = ({writeBack_arbitration_flushAll,memory_arbitration_flushAll} != (2'b00));
  assign writeBack_arbitration_isFlushed = (writeBack_arbitration_flushAll != (1'b0));
  assign decode_arbitration_isStuckByOthers = (decode_arbitration_haltByOther || (((1'b0 || execute_arbitration_isStuck) || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign decode_arbitration_isStuck = (decode_arbitration_haltItself || decode_arbitration_isStuckByOthers);
  assign decode_arbitration_isMoving = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
  assign decode_arbitration_isFiring = ((decode_arbitration_isValid && (! decode_arbitration_isStuck)) && (! decode_arbitration_removeIt));
  assign execute_arbitration_isStuckByOthers = (execute_arbitration_haltByOther || ((1'b0 || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign execute_arbitration_isStuck = (execute_arbitration_haltItself || execute_arbitration_isStuckByOthers);
  assign execute_arbitration_isMoving = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
  assign execute_arbitration_isFiring = ((execute_arbitration_isValid && (! execute_arbitration_isStuck)) && (! execute_arbitration_removeIt));
  assign memory_arbitration_isStuckByOthers = (memory_arbitration_haltByOther || (1'b0 || writeBack_arbitration_isStuck));
  assign memory_arbitration_isStuck = (memory_arbitration_haltItself || memory_arbitration_isStuckByOthers);
  assign memory_arbitration_isMoving = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
  assign memory_arbitration_isFiring = ((memory_arbitration_isValid && (! memory_arbitration_isStuck)) && (! memory_arbitration_removeIt));
  assign writeBack_arbitration_isStuckByOthers = (writeBack_arbitration_haltByOther || 1'b0);
  assign writeBack_arbitration_isStuck = (writeBack_arbitration_haltItself || writeBack_arbitration_isStuckByOthers);
  assign writeBack_arbitration_isMoving = ((! writeBack_arbitration_isStuck) && (! writeBack_arbitration_removeIt));
  assign writeBack_arbitration_isFiring = ((writeBack_arbitration_isValid && (! writeBack_arbitration_isStuck)) && (! writeBack_arbitration_removeIt));
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      CsrPlugin_privilege <= (2'b11);
      IBusSimplePlugin_fetchPc_pcReg <= (32'b00000000000000000000000000000000);
      IBusSimplePlugin_fetchPc_inc <= 1'b0;
      _zz_VexRiscv_79_ <= 1'b0;
      _zz_VexRiscv_85_ <= 1'b0;
      _zz_VexRiscv_87_ <= 1'b0;
      _zz_VexRiscv_89_ <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_0 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_1 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_2 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_3 <= 1'b0;
      IBusSimplePlugin_injector_decodeRemoved <= 1'b0;
      IBusSimplePlugin_pendingCmd <= (3'b000);
      IBusSimplePlugin_rspJoin_discardCounter <= (3'b000);
      CsrPlugin_mstatus_MIE <= 1'b0;
      CsrPlugin_mstatus_MPIE <= 1'b0;
      CsrPlugin_mstatus_MPP <= (2'b11);
      CsrPlugin_mip_MEIP <= 1'b0;
      CsrPlugin_mip_MTIP <= 1'b0;
      CsrPlugin_mip_MSIP <= 1'b0;
      CsrPlugin_mie_MEIE <= 1'b0;
      CsrPlugin_mie_MTIE <= 1'b0;
      CsrPlugin_mie_MSIE <= 1'b0;
      CsrPlugin_hadException <= 1'b0;
      _zz_VexRiscv_118_ <= 1'b1;
      execute_LightShifterPlugin_isActive <= 1'b0;
      _zz_VexRiscv_130_ <= 1'b0;
      execute_arbitration_isValid <= 1'b0;
      memory_arbitration_isValid <= 1'b0;
      writeBack_arbitration_isValid <= 1'b0;
      memory_to_writeBack_REGFILE_WRITE_DATA <= (32'b00000000000000000000000000000000);
      memory_to_writeBack_INSTRUCTION <= (32'b00000000000000000000000000000000);
    end else begin
      if(IBusSimplePlugin_fetchPc_propagatePc)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b0;
      end
      if(IBusSimplePlugin_jump_pcLoad_valid)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b0;
      end
      if(_zz_VexRiscv_149_)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b1;
      end
      if(IBusSimplePlugin_fetchPc_samplePcNext)begin
        IBusSimplePlugin_fetchPc_pcReg <= IBusSimplePlugin_fetchPc_pc;
      end
      _zz_VexRiscv_79_ <= 1'b1;
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        _zz_VexRiscv_85_ <= 1'b0;
      end
      if(_zz_VexRiscv_83_)begin
        _zz_VexRiscv_85_ <= IBusSimplePlugin_iBusRsp_stages_0_output_valid;
      end
      if(IBusSimplePlugin_iBusRsp_stages_1_output_ready)begin
        _zz_VexRiscv_87_ <= IBusSimplePlugin_iBusRsp_stages_1_output_valid;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        _zz_VexRiscv_87_ <= 1'b0;
      end
      if(IBusSimplePlugin_iBusRsp_inputBeforeStage_ready)begin
        _zz_VexRiscv_89_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_valid;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        _zz_VexRiscv_89_ <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      end
      if((! (! IBusSimplePlugin_iBusRsp_stages_1_input_ready)))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if((! (! IBusSimplePlugin_iBusRsp_stages_2_input_ready)))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= IBusSimplePlugin_injector_nextPcCalc_valids_0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_0 <= 1'b0;
      end
      if((! (! IBusSimplePlugin_injector_decodeInput_ready)))begin
        IBusSimplePlugin_injector_nextPcCalc_0 <= IBusSimplePlugin_injector_nextPcCalc_valids_1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_0 <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_1 <= 1'b0;
      end
      if((! execute_arbitration_isStuck))begin
        IBusSimplePlugin_injector_nextPcCalc_1 <= IBusSimplePlugin_injector_nextPcCalc_0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_1 <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_2 <= 1'b0;
      end
      if((! memory_arbitration_isStuck))begin
        IBusSimplePlugin_injector_nextPcCalc_2 <= IBusSimplePlugin_injector_nextPcCalc_1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_2 <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_3 <= 1'b0;
      end
      if((! writeBack_arbitration_isStuck))begin
        IBusSimplePlugin_injector_nextPcCalc_3 <= IBusSimplePlugin_injector_nextPcCalc_2;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_nextPcCalc_3 <= 1'b0;
      end
      if(decode_arbitration_removeIt)begin
        IBusSimplePlugin_injector_decodeRemoved <= 1'b1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_injector_decodeRemoved <= 1'b0;
      end
      IBusSimplePlugin_pendingCmd <= IBusSimplePlugin_pendingCmdNext;
      IBusSimplePlugin_rspJoin_discardCounter <= (IBusSimplePlugin_rspJoin_discardCounter - _zz_VexRiscv_163_);
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_VexRiscv_72_))begin
        IBusSimplePlugin_rspJoin_discardCounter <= IBusSimplePlugin_pendingCmdNext;
      end
      CsrPlugin_mip_MEIP <= externalInterrupt;
      CsrPlugin_mip_MTIP <= timerInterrupt;
      CsrPlugin_hadException <= CsrPlugin_exception;
      if(_zz_VexRiscv_147_)begin
        CsrPlugin_privilege <= CsrPlugin_targetPrivilege;
        case(CsrPlugin_targetPrivilege)
          2'b11 : begin
            CsrPlugin_mstatus_MIE <= 1'b0;
            CsrPlugin_mstatus_MPIE <= CsrPlugin_mstatus_MIE;
            CsrPlugin_mstatus_MPP <= CsrPlugin_privilege;
          end
          default : begin
          end
        endcase
      end
      if(_zz_VexRiscv_148_)begin
        case(_zz_VexRiscv_151_)
          2'b11 : begin
            CsrPlugin_mstatus_MIE <= CsrPlugin_mstatus_MPIE;
            CsrPlugin_mstatus_MPP <= (2'b00);
            CsrPlugin_mstatus_MPIE <= 1'b1;
            CsrPlugin_privilege <= CsrPlugin_mstatus_MPP;
          end
          default : begin
          end
        endcase
      end
      _zz_VexRiscv_118_ <= 1'b0;
      if(_zz_VexRiscv_145_)begin
        if(_zz_VexRiscv_146_)begin
          execute_LightShifterPlugin_isActive <= 1'b1;
          if(execute_LightShifterPlugin_done)begin
            execute_LightShifterPlugin_isActive <= 1'b0;
          end
        end
      end
      if(execute_arbitration_removeIt)begin
        execute_LightShifterPlugin_isActive <= 1'b0;
      end
      _zz_VexRiscv_130_ <= _zz_VexRiscv_129_;
      if((! writeBack_arbitration_isStuck))begin
        memory_to_writeBack_INSTRUCTION <= memory_INSTRUCTION;
      end
      if((! writeBack_arbitration_isStuck))begin
        memory_to_writeBack_REGFILE_WRITE_DATA <= memory_REGFILE_WRITE_DATA;
      end
      if(((! execute_arbitration_isStuck) || execute_arbitration_removeIt))begin
        execute_arbitration_isValid <= 1'b0;
      end
      if(((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt)))begin
        execute_arbitration_isValid <= decode_arbitration_isValid;
      end
      if(((! memory_arbitration_isStuck) || memory_arbitration_removeIt))begin
        memory_arbitration_isValid <= 1'b0;
      end
      if(((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt)))begin
        memory_arbitration_isValid <= execute_arbitration_isValid;
      end
      if(((! writeBack_arbitration_isStuck) || writeBack_arbitration_removeIt))begin
        writeBack_arbitration_isValid <= 1'b0;
      end
      if(((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt)))begin
        writeBack_arbitration_isValid <= memory_arbitration_isValid;
      end
      case(execute_CsrPlugin_csrAddress)
        12'b001100000000 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mstatus_MPP <= execute_CsrPlugin_writeData[12 : 11];
            CsrPlugin_mstatus_MPIE <= _zz_VexRiscv_191_[0];
            CsrPlugin_mstatus_MIE <= _zz_VexRiscv_192_[0];
          end
        end
        12'b001101000100 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mip_MSIP <= _zz_VexRiscv_193_[0];
          end
        end
        12'b001100000100 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mie_MEIE <= _zz_VexRiscv_194_[0];
            CsrPlugin_mie_MTIE <= _zz_VexRiscv_195_[0];
            CsrPlugin_mie_MSIE <= _zz_VexRiscv_196_[0];
          end
        end
        12'b001101000010 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(IBusSimplePlugin_iBusRsp_stages_1_output_ready)begin
      _zz_VexRiscv_88_ <= IBusSimplePlugin_iBusRsp_stages_1_output_payload;
    end
    if(IBusSimplePlugin_iBusRsp_inputBeforeStage_ready)begin
      _zz_VexRiscv_90_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_pc;
      _zz_VexRiscv_91_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_error;
      _zz_VexRiscv_92_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw;
      _zz_VexRiscv_93_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_isRvc;
    end
    if(IBusSimplePlugin_injector_decodeInput_ready)begin
      IBusSimplePlugin_injector_formal_rawInDecode <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw;
    end
    if(!(! (((dBus_rsp_ready && memory_MEMORY_ENABLE) && memory_arbitration_isValid) && memory_arbitration_isStuck))) begin
      $display("ERROR DBusSimplePlugin doesn't allow memory stage stall when read happend");
    end
    if(!(! (((writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE) && (! writeBack_INSTRUCTION[5])) && writeBack_arbitration_isStuck))) begin
      $display("ERROR DBusSimplePlugin doesn't allow writeback stage stall when read happend");
    end
    CsrPlugin_mcycle <= (CsrPlugin_mcycle + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    if(writeBack_arbitration_isFiring)begin
      CsrPlugin_minstret <= (CsrPlugin_minstret + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    end
    if((CsrPlugin_exception || CsrPlugin_interruptJump))begin
      case(CsrPlugin_privilege)
        2'b11 : begin
          CsrPlugin_mepc <= decode_PC;
        end
        default : begin
        end
      endcase
    end
    if(_zz_VexRiscv_147_)begin
      case(CsrPlugin_targetPrivilege)
        2'b11 : begin
          CsrPlugin_mcause_interrupt <= (! CsrPlugin_hadException);
          CsrPlugin_mcause_exceptionCode <= CsrPlugin_trapCause;
        end
        default : begin
        end
      endcase
    end
    if(_zz_VexRiscv_145_)begin
      if(_zz_VexRiscv_146_)begin
        execute_LightShifterPlugin_amplitudeReg <= (execute_LightShifterPlugin_amplitude - (5'b00001));
      end
    end
    if(_zz_VexRiscv_129_)begin
      _zz_VexRiscv_131_ <= _zz_VexRiscv_37_[11 : 7];
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_BITWISE_CTRL <= _zz_VexRiscv_18_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_INSTRUCTION <= execute_INSTRUCTION;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC2 <= decode_SRC2;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_REGFILE_WRITE_DATA <= _zz_VexRiscv_58_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_MEMORY_ENABLE <= execute_MEMORY_ENABLE;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_MEMORY_ENABLE <= memory_MEMORY_ENABLE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BYPASSABLE_EXECUTE_STAGE <= decode_BYPASSABLE_EXECUTE_STAGE;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_BRANCH_DO <= execute_BRANCH_DO;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SHIFT_CTRL <= _zz_VexRiscv_15_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_RS1 <= _zz_VexRiscv_31_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ENV_CTRL <= _zz_VexRiscv_12_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_ENV_CTRL <= _zz_VexRiscv_9_;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_ENV_CTRL <= _zz_VexRiscv_7_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_CTRL <= _zz_VexRiscv_5_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_FORMAL_PC_NEXT <= decode_FORMAL_PC_NEXT;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_FORMAL_PC_NEXT <= execute_FORMAL_PC_NEXT;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_FORMAL_PC_NEXT <= _zz_VexRiscv_67_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BRANCH_CTRL <= _zz_VexRiscv_2_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_CSR <= decode_IS_CSR;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_PC <= _zz_VexRiscv_27_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_PC <= execute_PC;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_PC <= memory_PC;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC1 <= decode_SRC1;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_MEMORY_ADDRESS_LOW <= execute_MEMORY_ADDRESS_LOW;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_MEMORY_ADDRESS_LOW <= memory_MEMORY_ADDRESS_LOW;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BYPASSABLE_MEMORY_STAGE <= decode_BYPASSABLE_MEMORY_STAGE;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_BYPASSABLE_MEMORY_STAGE <= execute_BYPASSABLE_MEMORY_STAGE;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_MEMORY_READ_DATA <= memory_MEMORY_READ_DATA;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_RS2 <= _zz_VexRiscv_28_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_BRANCH_CALC <= execute_BRANCH_CALC;
    end
  end

endmodule

module MuraxPipelinedMemoryBusRam (
      input   io_bus_cmd_valid,
      output  io_bus_cmd_ready,
      input   io_bus_cmd_payload_write,
      input  [31:0] io_bus_cmd_payload_address,
      input  [31:0] io_bus_cmd_payload_data,
      input  [3:0] io_bus_cmd_payload_mask,
      output  io_bus_rsp_valid,
      output [31:0] io_bus_rsp_0_data,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg [31:0] _zz_MuraxPipelinedMemoryBusRam_4_;
  wire [10:0] _zz_MuraxPipelinedMemoryBusRam_5_;
  reg  _zz_MuraxPipelinedMemoryBusRam_1_;
  wire [29:0] _zz_MuraxPipelinedMemoryBusRam_2_;
  wire [31:0] _zz_MuraxPipelinedMemoryBusRam_3_;
  reg [7:0] ram_symbol0 [0:2047];
  reg [7:0] ram_symbol1 [0:2047];
  reg [7:0] ram_symbol2 [0:2047];
  reg [7:0] ram_symbol3 [0:2047];
  reg [7:0] _zz_MuraxPipelinedMemoryBusRam_6_;
  reg [7:0] _zz_MuraxPipelinedMemoryBusRam_7_;
  reg [7:0] _zz_MuraxPipelinedMemoryBusRam_8_;
  reg [7:0] _zz_MuraxPipelinedMemoryBusRam_9_;
  assign _zz_MuraxPipelinedMemoryBusRam_5_ = _zz_MuraxPipelinedMemoryBusRam_2_[10:0];
  always @ (*) begin
    _zz_MuraxPipelinedMemoryBusRam_4_ = {_zz_MuraxPipelinedMemoryBusRam_9_, _zz_MuraxPipelinedMemoryBusRam_8_, _zz_MuraxPipelinedMemoryBusRam_7_, _zz_MuraxPipelinedMemoryBusRam_6_};
  end
  always @ (posedge toplevel_main_clk) begin
    if(io_bus_cmd_payload_mask[0] && io_bus_cmd_valid && io_bus_cmd_payload_write ) begin
      ram_symbol0[_zz_MuraxPipelinedMemoryBusRam_5_] <= _zz_MuraxPipelinedMemoryBusRam_3_[7 : 0];
    end
    if(io_bus_cmd_payload_mask[1] && io_bus_cmd_valid && io_bus_cmd_payload_write ) begin
      ram_symbol1[_zz_MuraxPipelinedMemoryBusRam_5_] <= _zz_MuraxPipelinedMemoryBusRam_3_[15 : 8];
    end
    if(io_bus_cmd_payload_mask[2] && io_bus_cmd_valid && io_bus_cmd_payload_write ) begin
      ram_symbol2[_zz_MuraxPipelinedMemoryBusRam_5_] <= _zz_MuraxPipelinedMemoryBusRam_3_[23 : 16];
    end
    if(io_bus_cmd_payload_mask[3] && io_bus_cmd_valid && io_bus_cmd_payload_write ) begin
      ram_symbol3[_zz_MuraxPipelinedMemoryBusRam_5_] <= _zz_MuraxPipelinedMemoryBusRam_3_[31 : 24];
    end
    if(io_bus_cmd_valid) begin
      _zz_MuraxPipelinedMemoryBusRam_6_ <= ram_symbol0[_zz_MuraxPipelinedMemoryBusRam_5_];
      _zz_MuraxPipelinedMemoryBusRam_7_ <= ram_symbol1[_zz_MuraxPipelinedMemoryBusRam_5_];
      _zz_MuraxPipelinedMemoryBusRam_8_ <= ram_symbol2[_zz_MuraxPipelinedMemoryBusRam_5_];
      _zz_MuraxPipelinedMemoryBusRam_9_ <= ram_symbol3[_zz_MuraxPipelinedMemoryBusRam_5_];
    end
  end

  assign io_bus_rsp_valid = _zz_MuraxPipelinedMemoryBusRam_1_;
  assign _zz_MuraxPipelinedMemoryBusRam_2_ = (io_bus_cmd_payload_address >>> 2);
  assign _zz_MuraxPipelinedMemoryBusRam_3_ = io_bus_cmd_payload_data;
  assign io_bus_rsp_0_data = _zz_MuraxPipelinedMemoryBusRam_4_;
  assign io_bus_cmd_ready = 1'b1;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      _zz_MuraxPipelinedMemoryBusRam_1_ <= 1'b0;
    end else begin
      _zz_MuraxPipelinedMemoryBusRam_1_ <= ((io_bus_cmd_valid && io_bus_cmd_ready) && (! io_bus_cmd_payload_write));
    end
  end

endmodule

module PipelinedMemoryBusToApbBridge (
      input   io_pipelinedMemoryBus_cmd_valid,
      output  io_pipelinedMemoryBus_cmd_ready,
      input   io_pipelinedMemoryBus_cmd_payload_write,
      input  [31:0] io_pipelinedMemoryBus_cmd_payload_address,
      input  [31:0] io_pipelinedMemoryBus_cmd_payload_data,
      input  [3:0] io_pipelinedMemoryBus_cmd_payload_mask,
      output  io_pipelinedMemoryBus_rsp_valid,
      output [31:0] io_pipelinedMemoryBus_rsp_1_data,
      output [19:0] io_apb_PADDR,
      output [0:0] io_apb_PSEL,
      output  io_apb_PENABLE,
      input   io_apb_PREADY,
      output  io_apb_PWRITE,
      output [31:0] io_apb_PWDATA,
      input  [31:0] io_apb_PRDATA,
      input   io_apb_PSLVERROR,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire  _zz_PipelinedMemoryBusToApbBridge_1_;
  wire  _zz_PipelinedMemoryBusToApbBridge_2_;
  wire  pipelinedMemoryBusStage_cmd_valid;
  reg  pipelinedMemoryBusStage_cmd_ready;
  wire  pipelinedMemoryBusStage_cmd_payload_write;
  wire [31:0] pipelinedMemoryBusStage_cmd_payload_address;
  wire [31:0] pipelinedMemoryBusStage_cmd_payload_data;
  wire [3:0] pipelinedMemoryBusStage_cmd_payload_mask;
  reg  pipelinedMemoryBusStage_rsp_valid;
  wire [31:0] pipelinedMemoryBusStage_rsp_payload_data;
  wire  io_pipelinedMemoryBus_cmd_halfPipe_valid;
  wire  io_pipelinedMemoryBus_cmd_halfPipe_ready;
  wire  io_pipelinedMemoryBus_cmd_halfPipe_payload_write;
  wire [31:0] io_pipelinedMemoryBus_cmd_halfPipe_payload_address;
  wire [31:0] io_pipelinedMemoryBus_cmd_halfPipe_payload_data;
  wire [3:0] io_pipelinedMemoryBus_cmd_halfPipe_payload_mask;
  reg  io_pipelinedMemoryBus_cmd_halfPipe_regs_valid;
  reg  io_pipelinedMemoryBus_cmd_halfPipe_regs_ready;
  reg  io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_write;
  reg [31:0] io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_address;
  reg [31:0] io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_data;
  reg [3:0] io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_mask;
  reg  pipelinedMemoryBusStage_rsp_m2sPipe_valid;
  reg [31:0] pipelinedMemoryBusStage_rsp_m2sPipe_payload_data;
  reg  state;
  assign _zz_PipelinedMemoryBusToApbBridge_1_ = (! state);
  assign _zz_PipelinedMemoryBusToApbBridge_2_ = (! io_pipelinedMemoryBus_cmd_halfPipe_regs_valid);
  assign io_pipelinedMemoryBus_cmd_halfPipe_valid = io_pipelinedMemoryBus_cmd_halfPipe_regs_valid;
  assign io_pipelinedMemoryBus_cmd_halfPipe_payload_write = io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_write;
  assign io_pipelinedMemoryBus_cmd_halfPipe_payload_address = io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_address;
  assign io_pipelinedMemoryBus_cmd_halfPipe_payload_data = io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_data;
  assign io_pipelinedMemoryBus_cmd_halfPipe_payload_mask = io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_mask;
  assign io_pipelinedMemoryBus_cmd_ready = io_pipelinedMemoryBus_cmd_halfPipe_regs_ready;
  assign pipelinedMemoryBusStage_cmd_valid = io_pipelinedMemoryBus_cmd_halfPipe_valid;
  assign io_pipelinedMemoryBus_cmd_halfPipe_ready = pipelinedMemoryBusStage_cmd_ready;
  assign pipelinedMemoryBusStage_cmd_payload_write = io_pipelinedMemoryBus_cmd_halfPipe_payload_write;
  assign pipelinedMemoryBusStage_cmd_payload_address = io_pipelinedMemoryBus_cmd_halfPipe_payload_address;
  assign pipelinedMemoryBusStage_cmd_payload_data = io_pipelinedMemoryBus_cmd_halfPipe_payload_data;
  assign pipelinedMemoryBusStage_cmd_payload_mask = io_pipelinedMemoryBus_cmd_halfPipe_payload_mask;
  assign io_pipelinedMemoryBus_rsp_valid = pipelinedMemoryBusStage_rsp_m2sPipe_valid;
  assign io_pipelinedMemoryBus_rsp_1_data = pipelinedMemoryBusStage_rsp_m2sPipe_payload_data;
  always @ (*) begin
    pipelinedMemoryBusStage_cmd_ready = 1'b0;
    pipelinedMemoryBusStage_rsp_valid = 1'b0;
    if(! _zz_PipelinedMemoryBusToApbBridge_1_) begin
      if(io_apb_PREADY)begin
        pipelinedMemoryBusStage_rsp_valid = (! pipelinedMemoryBusStage_cmd_payload_write);
        pipelinedMemoryBusStage_cmd_ready = 1'b1;
      end
    end
  end

  assign io_apb_PSEL[0] = pipelinedMemoryBusStage_cmd_valid;
  assign io_apb_PENABLE = state;
  assign io_apb_PWRITE = pipelinedMemoryBusStage_cmd_payload_write;
  assign io_apb_PADDR = pipelinedMemoryBusStage_cmd_payload_address[19:0];
  assign io_apb_PWDATA = pipelinedMemoryBusStage_cmd_payload_data;
  assign pipelinedMemoryBusStage_rsp_payload_data = io_apb_PRDATA;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      io_pipelinedMemoryBus_cmd_halfPipe_regs_valid <= 1'b0;
      io_pipelinedMemoryBus_cmd_halfPipe_regs_ready <= 1'b1;
      pipelinedMemoryBusStage_rsp_m2sPipe_valid <= 1'b0;
      state <= 1'b0;
    end else begin
      if(_zz_PipelinedMemoryBusToApbBridge_2_)begin
        io_pipelinedMemoryBus_cmd_halfPipe_regs_valid <= io_pipelinedMemoryBus_cmd_valid;
        io_pipelinedMemoryBus_cmd_halfPipe_regs_ready <= (! io_pipelinedMemoryBus_cmd_valid);
      end else begin
        io_pipelinedMemoryBus_cmd_halfPipe_regs_valid <= (! io_pipelinedMemoryBus_cmd_halfPipe_ready);
        io_pipelinedMemoryBus_cmd_halfPipe_regs_ready <= io_pipelinedMemoryBus_cmd_halfPipe_ready;
      end
      pipelinedMemoryBusStage_rsp_m2sPipe_valid <= pipelinedMemoryBusStage_rsp_valid;
      if(_zz_PipelinedMemoryBusToApbBridge_1_)begin
        state <= pipelinedMemoryBusStage_cmd_valid;
      end else begin
        if(io_apb_PREADY)begin
          state <= 1'b0;
        end
      end
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(_zz_PipelinedMemoryBusToApbBridge_2_)begin
      io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_write <= io_pipelinedMemoryBus_cmd_payload_write;
      io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_address <= io_pipelinedMemoryBus_cmd_payload_address;
      io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_data <= io_pipelinedMemoryBus_cmd_payload_data;
      io_pipelinedMemoryBus_cmd_halfPipe_regs_payload_mask <= io_pipelinedMemoryBus_cmd_payload_mask;
    end
    if(pipelinedMemoryBusStage_rsp_valid)begin
      pipelinedMemoryBusStage_rsp_m2sPipe_payload_data <= pipelinedMemoryBusStage_rsp_payload_data;
    end
  end

endmodule

module Prescaler (
      input   io_clear,
      input  [15:0] io_limit,
      output  io_overflow,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg [15:0] counter;
  assign io_overflow = (counter == io_limit);
  always @ (posedge toplevel_main_clk) begin
    counter <= (counter + (16'b0000000000000001));
    if((io_clear || io_overflow))begin
      counter <= (16'b0000000000000000);
    end
  end

endmodule

module Timer (
      input   io_tick,
      input   io_clear,
      input  [15:0] io_limit,
      output  io_full,
      output [15:0] io_value,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire [0:0] _zz_Timer_1_;
  wire [15:0] _zz_Timer_2_;
  reg [15:0] counter;
  wire  limitHit;
  reg  inhibitFull;
  assign _zz_Timer_1_ = (! limitHit);
  assign _zz_Timer_2_ = {15'd0, _zz_Timer_1_};
  assign limitHit = (counter == io_limit);
  assign io_full = ((limitHit && io_tick) && (! inhibitFull));
  assign io_value = counter;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      inhibitFull <= 1'b0;
    end else begin
      if(io_tick)begin
        inhibitFull <= limitHit;
      end
      if(io_clear)begin
        inhibitFull <= 1'b0;
      end
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(io_tick)begin
      counter <= (counter + _zz_Timer_2_);
    end
    if(io_clear)begin
      counter <= (16'b0000000000000000);
    end
  end

endmodule

module Timer_1_ (
      input   io_tick,
      input   io_clear,
      input  [15:0] io_limit,
      output  io_full,
      output [15:0] io_value,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire [0:0] _zz_Timer_1__1_;
  wire [15:0] _zz_Timer_1__2_;
  reg [15:0] counter;
  wire  limitHit;
  reg  inhibitFull;
  assign _zz_Timer_1__1_ = (! limitHit);
  assign _zz_Timer_1__2_ = {15'd0, _zz_Timer_1__1_};
  assign limitHit = (counter == io_limit);
  assign io_full = ((limitHit && io_tick) && (! inhibitFull));
  assign io_value = counter;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      inhibitFull <= 1'b0;
    end else begin
      if(io_tick)begin
        inhibitFull <= limitHit;
      end
      if(io_clear)begin
        inhibitFull <= 1'b0;
      end
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(io_tick)begin
      counter <= (counter + _zz_Timer_1__2_);
    end
    if(io_clear)begin
      counter <= (16'b0000000000000000);
    end
  end

endmodule

module InterruptCtrl (
      input  [1:0] io_inputs,
      input  [1:0] io_clears,
      input  [1:0] io_masks,
      output [1:0] io_pendings,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg [1:0] pendings;
  assign io_pendings = (pendings & io_masks);
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      pendings <= (2'b00);
    end else begin
      pendings <= ((pendings & (~ io_clears)) | io_inputs);
    end
  end

endmodule

module StreamFifoCC (
      input   io_push_valid,
      output  io_push_ready,
      input  [9:0] io_push_payload,
      output  io_pop_valid,
      input   io_pop_ready,
      output [9:0] io_pop_payload,
      output [11:0] io_pushOccupancy,
      output [11:0] io_popOccupancy,
      input   u_gmii_rx_io_rx_clk,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire [11:0] _zz_StreamFifoCC_25_;
  wire [11:0] _zz_StreamFifoCC_26_;
  reg [9:0] _zz_StreamFifoCC_27_;
  wire [11:0] bufferCC_4__io_dataOut;
  wire [11:0] bufferCC_5__io_dataOut;
  wire [0:0] _zz_StreamFifoCC_28_;
  wire [11:0] _zz_StreamFifoCC_29_;
  wire [11:0] _zz_StreamFifoCC_30_;
  wire [10:0] _zz_StreamFifoCC_31_;
  wire [0:0] _zz_StreamFifoCC_32_;
  wire [11:0] _zz_StreamFifoCC_33_;
  wire [11:0] _zz_StreamFifoCC_34_;
  wire [10:0] _zz_StreamFifoCC_35_;
  wire  _zz_StreamFifoCC_36_;
  wire [0:0] _zz_StreamFifoCC_37_;
  wire [1:0] _zz_StreamFifoCC_38_;
  wire [0:0] _zz_StreamFifoCC_39_;
  wire [1:0] _zz_StreamFifoCC_40_;
  reg  _zz_StreamFifoCC_1_;
  wire [11:0] popToPushGray;
  wire [11:0] pushToPopGray;
  reg  pushCC_pushPtr_willIncrement;
  wire  pushCC_pushPtr_willClear;
  reg [11:0] pushCC_pushPtr_valueNext;
  reg [11:0] pushCC_pushPtr_value = (12'b000000000000);
  wire  pushCC_pushPtr_willOverflowIfInc;
  wire  pushCC_pushPtr_willOverflow;
  reg [11:0] pushCC_pushPtrGray = (12'b000000000000);
  wire [11:0] pushCC_popPtrGray;
  wire  pushCC_full;
  wire  _zz_StreamFifoCC_2_;
  wire  _zz_StreamFifoCC_3_;
  wire  _zz_StreamFifoCC_4_;
  wire  _zz_StreamFifoCC_5_;
  wire  _zz_StreamFifoCC_6_;
  wire  _zz_StreamFifoCC_7_;
  wire  _zz_StreamFifoCC_8_;
  wire  _zz_StreamFifoCC_9_;
  wire  _zz_StreamFifoCC_10_;
  wire  _zz_StreamFifoCC_11_;
  wire  _zz_StreamFifoCC_12_;
  reg  popCC_popPtr_willIncrement;
  wire  popCC_popPtr_willClear;
  reg [11:0] popCC_popPtr_valueNext;
  reg [11:0] popCC_popPtr_value;
  wire  popCC_popPtr_willOverflowIfInc;
  wire  popCC_popPtr_willOverflow;
  reg [11:0] popCC_popPtrGray;
  wire [11:0] popCC_pushPtrGray;
  wire  popCC_empty;
  wire [11:0] _zz_StreamFifoCC_13_;
  wire  _zz_StreamFifoCC_14_;
  wire  _zz_StreamFifoCC_15_;
  wire  _zz_StreamFifoCC_16_;
  wire  _zz_StreamFifoCC_17_;
  wire  _zz_StreamFifoCC_18_;
  wire  _zz_StreamFifoCC_19_;
  wire  _zz_StreamFifoCC_20_;
  wire  _zz_StreamFifoCC_21_;
  wire  _zz_StreamFifoCC_22_;
  wire  _zz_StreamFifoCC_23_;
  wire  _zz_StreamFifoCC_24_;
  reg [9:0] ram [0:2047];
  assign _zz_StreamFifoCC_28_ = pushCC_pushPtr_willIncrement;
  assign _zz_StreamFifoCC_29_ = {11'd0, _zz_StreamFifoCC_28_};
  assign _zz_StreamFifoCC_30_ = (pushCC_pushPtr_valueNext >>> (1'b1));
  assign _zz_StreamFifoCC_31_ = pushCC_pushPtr_value[10:0];
  assign _zz_StreamFifoCC_32_ = popCC_popPtr_willIncrement;
  assign _zz_StreamFifoCC_33_ = {11'd0, _zz_StreamFifoCC_32_};
  assign _zz_StreamFifoCC_34_ = (popCC_popPtr_valueNext >>> (1'b1));
  assign _zz_StreamFifoCC_35_ = _zz_StreamFifoCC_13_[10:0];
  assign _zz_StreamFifoCC_36_ = 1'b1;
  assign _zz_StreamFifoCC_37_ = _zz_StreamFifoCC_3_;
  assign _zz_StreamFifoCC_38_ = {_zz_StreamFifoCC_2_,(pushCC_popPtrGray[0] ^ _zz_StreamFifoCC_2_)};
  assign _zz_StreamFifoCC_39_ = _zz_StreamFifoCC_15_;
  assign _zz_StreamFifoCC_40_ = {_zz_StreamFifoCC_14_,(popCC_pushPtrGray[0] ^ _zz_StreamFifoCC_14_)};
  always @ (posedge u_gmii_rx_io_rx_clk) begin
    if(_zz_StreamFifoCC_1_) begin
      ram[_zz_StreamFifoCC_31_] <= io_push_payload;
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(_zz_StreamFifoCC_36_) begin
      _zz_StreamFifoCC_27_ <= ram[_zz_StreamFifoCC_35_];
    end
  end

  BufferCC bufferCC_4_ ( 
    .io_initial(_zz_StreamFifoCC_25_),
    .io_dataIn(popToPushGray),
    .io_dataOut(bufferCC_4__io_dataOut),
    .u_gmii_rx_io_rx_clk(u_gmii_rx_io_rx_clk) 
  );
  BufferCC_1_ bufferCC_5_ ( 
    .io_initial(_zz_StreamFifoCC_26_),
    .io_dataIn(pushToPopGray),
    .io_dataOut(bufferCC_5__io_dataOut),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  always @ (*) begin
    _zz_StreamFifoCC_1_ = 1'b0;
    pushCC_pushPtr_willIncrement = 1'b0;
    if((io_push_valid && io_push_ready))begin
      _zz_StreamFifoCC_1_ = 1'b1;
      pushCC_pushPtr_willIncrement = 1'b1;
    end
  end

  assign pushCC_pushPtr_willClear = 1'b0;
  assign pushCC_pushPtr_willOverflowIfInc = (pushCC_pushPtr_value == (12'b111111111111));
  assign pushCC_pushPtr_willOverflow = (pushCC_pushPtr_willOverflowIfInc && pushCC_pushPtr_willIncrement);
  always @ (*) begin
    pushCC_pushPtr_valueNext = (pushCC_pushPtr_value + _zz_StreamFifoCC_29_);
    if(pushCC_pushPtr_willClear)begin
      pushCC_pushPtr_valueNext = (12'b000000000000);
    end
  end

  assign _zz_StreamFifoCC_25_ = (12'b000000000000);
  assign pushCC_popPtrGray = bufferCC_4__io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[11 : 10] == (~ pushCC_popPtrGray[11 : 10])) && (pushCC_pushPtrGray[9 : 0] == pushCC_popPtrGray[9 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_StreamFifoCC_2_ = (pushCC_popPtrGray[1] ^ _zz_StreamFifoCC_3_);
  assign _zz_StreamFifoCC_3_ = (pushCC_popPtrGray[2] ^ _zz_StreamFifoCC_4_);
  assign _zz_StreamFifoCC_4_ = (pushCC_popPtrGray[3] ^ _zz_StreamFifoCC_5_);
  assign _zz_StreamFifoCC_5_ = (pushCC_popPtrGray[4] ^ _zz_StreamFifoCC_6_);
  assign _zz_StreamFifoCC_6_ = (pushCC_popPtrGray[5] ^ _zz_StreamFifoCC_7_);
  assign _zz_StreamFifoCC_7_ = (pushCC_popPtrGray[6] ^ _zz_StreamFifoCC_8_);
  assign _zz_StreamFifoCC_8_ = (pushCC_popPtrGray[7] ^ _zz_StreamFifoCC_9_);
  assign _zz_StreamFifoCC_9_ = (pushCC_popPtrGray[8] ^ _zz_StreamFifoCC_10_);
  assign _zz_StreamFifoCC_10_ = (pushCC_popPtrGray[9] ^ _zz_StreamFifoCC_11_);
  assign _zz_StreamFifoCC_11_ = (pushCC_popPtrGray[10] ^ _zz_StreamFifoCC_12_);
  assign _zz_StreamFifoCC_12_ = pushCC_popPtrGray[11];
  assign io_pushOccupancy = (pushCC_pushPtr_value - {_zz_StreamFifoCC_12_,{_zz_StreamFifoCC_11_,{_zz_StreamFifoCC_10_,{_zz_StreamFifoCC_9_,{_zz_StreamFifoCC_8_,{_zz_StreamFifoCC_7_,{_zz_StreamFifoCC_6_,{_zz_StreamFifoCC_5_,{_zz_StreamFifoCC_4_,{_zz_StreamFifoCC_37_,_zz_StreamFifoCC_38_}}}}}}}}}});
  always @ (*) begin
    popCC_popPtr_willIncrement = 1'b0;
    if((io_pop_valid && io_pop_ready))begin
      popCC_popPtr_willIncrement = 1'b1;
    end
  end

  assign popCC_popPtr_willClear = 1'b0;
  assign popCC_popPtr_willOverflowIfInc = (popCC_popPtr_value == (12'b111111111111));
  assign popCC_popPtr_willOverflow = (popCC_popPtr_willOverflowIfInc && popCC_popPtr_willIncrement);
  always @ (*) begin
    popCC_popPtr_valueNext = (popCC_popPtr_value + _zz_StreamFifoCC_33_);
    if(popCC_popPtr_willClear)begin
      popCC_popPtr_valueNext = (12'b000000000000);
    end
  end

  assign _zz_StreamFifoCC_26_ = (12'b000000000000);
  assign popCC_pushPtrGray = bufferCC_5__io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign io_pop_valid = (! popCC_empty);
  assign _zz_StreamFifoCC_13_ = popCC_popPtr_valueNext;
  assign io_pop_payload = _zz_StreamFifoCC_27_;
  assign _zz_StreamFifoCC_14_ = (popCC_pushPtrGray[1] ^ _zz_StreamFifoCC_15_);
  assign _zz_StreamFifoCC_15_ = (popCC_pushPtrGray[2] ^ _zz_StreamFifoCC_16_);
  assign _zz_StreamFifoCC_16_ = (popCC_pushPtrGray[3] ^ _zz_StreamFifoCC_17_);
  assign _zz_StreamFifoCC_17_ = (popCC_pushPtrGray[4] ^ _zz_StreamFifoCC_18_);
  assign _zz_StreamFifoCC_18_ = (popCC_pushPtrGray[5] ^ _zz_StreamFifoCC_19_);
  assign _zz_StreamFifoCC_19_ = (popCC_pushPtrGray[6] ^ _zz_StreamFifoCC_20_);
  assign _zz_StreamFifoCC_20_ = (popCC_pushPtrGray[7] ^ _zz_StreamFifoCC_21_);
  assign _zz_StreamFifoCC_21_ = (popCC_pushPtrGray[8] ^ _zz_StreamFifoCC_22_);
  assign _zz_StreamFifoCC_22_ = (popCC_pushPtrGray[9] ^ _zz_StreamFifoCC_23_);
  assign _zz_StreamFifoCC_23_ = (popCC_pushPtrGray[10] ^ _zz_StreamFifoCC_24_);
  assign _zz_StreamFifoCC_24_ = popCC_pushPtrGray[11];
  assign io_popOccupancy = ({_zz_StreamFifoCC_24_,{_zz_StreamFifoCC_23_,{_zz_StreamFifoCC_22_,{_zz_StreamFifoCC_21_,{_zz_StreamFifoCC_20_,{_zz_StreamFifoCC_19_,{_zz_StreamFifoCC_18_,{_zz_StreamFifoCC_17_,{_zz_StreamFifoCC_16_,{_zz_StreamFifoCC_39_,_zz_StreamFifoCC_40_}}}}}}}}}} - popCC_popPtr_value);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_popPtrGray;
  always @ (posedge u_gmii_rx_io_rx_clk) begin
    pushCC_pushPtr_value <= pushCC_pushPtr_valueNext;
    pushCC_pushPtrGray <= (_zz_StreamFifoCC_30_ ^ pushCC_pushPtr_valueNext);
  end

  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      popCC_popPtr_value <= (12'b000000000000);
      popCC_popPtrGray <= (12'b000000000000);
    end else begin
      popCC_popPtr_value <= popCC_popPtr_valueNext;
      popCC_popPtrGray <= (_zz_StreamFifoCC_34_ ^ popCC_popPtr_valueNext);
    end
  end

endmodule

module CpuComplex (
      output [19:0] io_apb_PADDR,
      output [0:0] io_apb_PSEL,
      output  io_apb_PENABLE,
      input   io_apb_PREADY,
      output  io_apb_PWRITE,
      output [31:0] io_apb_PWDATA,
      input  [31:0] io_apb_PRDATA,
      input   io_apb_PSLVERROR,
      input   io_externalInterrupt,
      input   io_timerInterrupt,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire  _zz_CpuComplex_8_;
  reg  _zz_CpuComplex_9_;
  reg  _zz_CpuComplex_10_;
  reg [31:0] _zz_CpuComplex_11_;
  wire  mainBusArbiter_io_iBus_cmd_ready;
  wire  mainBusArbiter_io_iBus_rsp_valid;
  wire  mainBusArbiter_io_iBus_rsp_payload_error;
  wire [31:0] mainBusArbiter_io_iBus_rsp_payload_inst;
  wire  mainBusArbiter_io_dBus_cmd_ready;
  wire  mainBusArbiter_io_dBus_rsp_ready;
  wire  mainBusArbiter_io_dBus_rsp_error;
  wire [31:0] mainBusArbiter_io_dBus_rsp_data;
  wire  mainBusArbiter_io_masterBus_cmd_valid;
  wire  mainBusArbiter_io_masterBus_cmd_payload_write;
  wire [31:0] mainBusArbiter_io_masterBus_cmd_payload_address;
  wire [31:0] mainBusArbiter_io_masterBus_cmd_payload_data;
  wire [3:0] mainBusArbiter_io_masterBus_cmd_payload_mask;
  wire  cpu_iBus_cmd_valid;
  wire [31:0] cpu_iBus_cmd_payload_pc;
  wire  cpu_dBus_cmd_valid;
  wire  cpu_dBus_cmd_payload_wr;
  wire [31:0] cpu_dBus_cmd_payload_address;
  wire [31:0] cpu_dBus_cmd_payload_data;
  wire [1:0] cpu_dBus_cmd_payload_size;
  wire  ram_io_bus_cmd_ready;
  wire  ram_io_bus_rsp_valid;
  wire [31:0] ram_io_bus_rsp_0_data;
  wire  apbBridge_io_pipelinedMemoryBus_cmd_ready;
  wire  apbBridge_io_pipelinedMemoryBus_rsp_valid;
  wire [31:0] apbBridge_io_pipelinedMemoryBus_rsp_1_data;
  wire [19:0] apbBridge_io_apb_PADDR;
  wire [0:0] apbBridge_io_apb_PSEL;
  wire  apbBridge_io_apb_PENABLE;
  wire  apbBridge_io_apb_PWRITE;
  wire [31:0] apbBridge_io_apb_PWDATA;
  wire  _zz_CpuComplex_12_;
  wire [31:0] _zz_CpuComplex_13_;
  wire [31:0] _zz_CpuComplex_14_;
  wire  cpu_dBus_cmd_halfPipe_valid;
  wire  cpu_dBus_cmd_halfPipe_ready;
  wire  cpu_dBus_cmd_halfPipe_payload_wr;
  wire [31:0] cpu_dBus_cmd_halfPipe_payload_address;
  wire [31:0] cpu_dBus_cmd_halfPipe_payload_data;
  wire [1:0] cpu_dBus_cmd_halfPipe_payload_size;
  reg  cpu_dBus_cmd_halfPipe_regs_valid;
  reg  cpu_dBus_cmd_halfPipe_regs_ready;
  reg  cpu_dBus_cmd_halfPipe_regs_payload_wr;
  reg [31:0] cpu_dBus_cmd_halfPipe_regs_payload_address;
  reg [31:0] cpu_dBus_cmd_halfPipe_regs_payload_data;
  reg [1:0] cpu_dBus_cmd_halfPipe_regs_payload_size;
  wire  mainBusDecoder_logic_masterPipelined_cmd_valid;
  reg  mainBusDecoder_logic_masterPipelined_cmd_ready;
  wire  mainBusDecoder_logic_masterPipelined_cmd_payload_write;
  wire [31:0] mainBusDecoder_logic_masterPipelined_cmd_payload_address;
  wire [31:0] mainBusDecoder_logic_masterPipelined_cmd_payload_data;
  wire [3:0] mainBusDecoder_logic_masterPipelined_cmd_payload_mask;
  wire  mainBusDecoder_logic_masterPipelined_rsp_valid;
  wire [31:0] mainBusDecoder_logic_masterPipelined_rsp_payload_data;
  wire  mainBusArbiter_io_masterBus_cmd_m2sPipe_valid;
  wire  mainBusArbiter_io_masterBus_cmd_m2sPipe_ready;
  wire  mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_write;
  wire [31:0] mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_address;
  wire [31:0] mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_data;
  wire [3:0] mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_mask;
  reg  _zz_CpuComplex_1_;
  reg  _zz_CpuComplex_2_;
  reg [31:0] _zz_CpuComplex_3_;
  reg [31:0] _zz_CpuComplex_4_;
  reg [3:0] _zz_CpuComplex_5_;
  wire  mainBusDecoder_logic_hits_0;
  wire  _zz_CpuComplex_6_;
  wire  mainBusDecoder_logic_hits_1;
  wire  _zz_CpuComplex_7_;
  wire  mainBusDecoder_logic_noHit;
  reg  mainBusDecoder_logic_rspPending;
  reg  mainBusDecoder_logic_rspNoHit;
  reg [0:0] mainBusDecoder_logic_rspSourceId;
  assign _zz_CpuComplex_12_ = (! cpu_dBus_cmd_halfPipe_regs_valid);
  assign _zz_CpuComplex_13_ = (32'b11111111111111111110000000000000);
  assign _zz_CpuComplex_14_ = (32'b11111111111100000000000000000000);
  MuraxMasterArbiter mainBusArbiter ( 
    .io_iBus_cmd_valid(cpu_iBus_cmd_valid),
    .io_iBus_cmd_ready(mainBusArbiter_io_iBus_cmd_ready),
    .io_iBus_cmd_payload_pc(cpu_iBus_cmd_payload_pc),
    .io_iBus_rsp_valid(mainBusArbiter_io_iBus_rsp_valid),
    .io_iBus_rsp_payload_error(mainBusArbiter_io_iBus_rsp_payload_error),
    .io_iBus_rsp_payload_inst(mainBusArbiter_io_iBus_rsp_payload_inst),
    .io_dBus_cmd_valid(cpu_dBus_cmd_halfPipe_valid),
    .io_dBus_cmd_ready(mainBusArbiter_io_dBus_cmd_ready),
    .io_dBus_cmd_payload_wr(cpu_dBus_cmd_halfPipe_payload_wr),
    .io_dBus_cmd_payload_address(cpu_dBus_cmd_halfPipe_payload_address),
    .io_dBus_cmd_payload_data(cpu_dBus_cmd_halfPipe_payload_data),
    .io_dBus_cmd_payload_size(cpu_dBus_cmd_halfPipe_payload_size),
    .io_dBus_rsp_ready(mainBusArbiter_io_dBus_rsp_ready),
    .io_dBus_rsp_error(mainBusArbiter_io_dBus_rsp_error),
    .io_dBus_rsp_data(mainBusArbiter_io_dBus_rsp_data),
    .io_masterBus_cmd_valid(mainBusArbiter_io_masterBus_cmd_valid),
    .io_masterBus_cmd_ready(_zz_CpuComplex_8_),
    .io_masterBus_cmd_payload_write(mainBusArbiter_io_masterBus_cmd_payload_write),
    .io_masterBus_cmd_payload_address(mainBusArbiter_io_masterBus_cmd_payload_address),
    .io_masterBus_cmd_payload_data(mainBusArbiter_io_masterBus_cmd_payload_data),
    .io_masterBus_cmd_payload_mask(mainBusArbiter_io_masterBus_cmd_payload_mask),
    .io_masterBus_rsp_valid(mainBusDecoder_logic_masterPipelined_rsp_valid),
    .io_masterBus_rsp_payload_data(mainBusDecoder_logic_masterPipelined_rsp_payload_data),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  VexRiscv cpu ( 
    .iBus_cmd_valid(cpu_iBus_cmd_valid),
    .iBus_cmd_ready(mainBusArbiter_io_iBus_cmd_ready),
    .iBus_cmd_payload_pc(cpu_iBus_cmd_payload_pc),
    .iBus_rsp_valid(mainBusArbiter_io_iBus_rsp_valid),
    .iBus_rsp_payload_error(mainBusArbiter_io_iBus_rsp_payload_error),
    .iBus_rsp_payload_inst(mainBusArbiter_io_iBus_rsp_payload_inst),
    .timerInterrupt(io_timerInterrupt),
    .externalInterrupt(io_externalInterrupt),
    .dBus_cmd_valid(cpu_dBus_cmd_valid),
    .dBus_cmd_ready(cpu_dBus_cmd_halfPipe_regs_ready),
    .dBus_cmd_payload_wr(cpu_dBus_cmd_payload_wr),
    .dBus_cmd_payload_address(cpu_dBus_cmd_payload_address),
    .dBus_cmd_payload_data(cpu_dBus_cmd_payload_data),
    .dBus_cmd_payload_size(cpu_dBus_cmd_payload_size),
    .dBus_rsp_ready(mainBusArbiter_io_dBus_rsp_ready),
    .dBus_rsp_error(mainBusArbiter_io_dBus_rsp_error),
    .dBus_rsp_data(mainBusArbiter_io_dBus_rsp_data),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  MuraxPipelinedMemoryBusRam ram ( 
    .io_bus_cmd_valid(_zz_CpuComplex_9_),
    .io_bus_cmd_ready(ram_io_bus_cmd_ready),
    .io_bus_cmd_payload_write(_zz_CpuComplex_6_),
    .io_bus_cmd_payload_address(mainBusDecoder_logic_masterPipelined_cmd_payload_address),
    .io_bus_cmd_payload_data(mainBusDecoder_logic_masterPipelined_cmd_payload_data),
    .io_bus_cmd_payload_mask(mainBusDecoder_logic_masterPipelined_cmd_payload_mask),
    .io_bus_rsp_valid(ram_io_bus_rsp_valid),
    .io_bus_rsp_0_data(ram_io_bus_rsp_0_data),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  PipelinedMemoryBusToApbBridge apbBridge ( 
    .io_pipelinedMemoryBus_cmd_valid(_zz_CpuComplex_10_),
    .io_pipelinedMemoryBus_cmd_ready(apbBridge_io_pipelinedMemoryBus_cmd_ready),
    .io_pipelinedMemoryBus_cmd_payload_write(_zz_CpuComplex_7_),
    .io_pipelinedMemoryBus_cmd_payload_address(mainBusDecoder_logic_masterPipelined_cmd_payload_address),
    .io_pipelinedMemoryBus_cmd_payload_data(mainBusDecoder_logic_masterPipelined_cmd_payload_data),
    .io_pipelinedMemoryBus_cmd_payload_mask(mainBusDecoder_logic_masterPipelined_cmd_payload_mask),
    .io_pipelinedMemoryBus_rsp_valid(apbBridge_io_pipelinedMemoryBus_rsp_valid),
    .io_pipelinedMemoryBus_rsp_1_data(apbBridge_io_pipelinedMemoryBus_rsp_1_data),
    .io_apb_PADDR(apbBridge_io_apb_PADDR),
    .io_apb_PSEL(apbBridge_io_apb_PSEL),
    .io_apb_PENABLE(apbBridge_io_apb_PENABLE),
    .io_apb_PREADY(io_apb_PREADY),
    .io_apb_PWRITE(apbBridge_io_apb_PWRITE),
    .io_apb_PWDATA(apbBridge_io_apb_PWDATA),
    .io_apb_PRDATA(io_apb_PRDATA),
    .io_apb_PSLVERROR(io_apb_PSLVERROR),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  always @(*) begin
    case(mainBusDecoder_logic_rspSourceId)
      1'b0 : begin
        _zz_CpuComplex_11_ = ram_io_bus_rsp_0_data;
      end
      default : begin
        _zz_CpuComplex_11_ = apbBridge_io_pipelinedMemoryBus_rsp_1_data;
      end
    endcase
  end

  assign cpu_dBus_cmd_halfPipe_valid = cpu_dBus_cmd_halfPipe_regs_valid;
  assign cpu_dBus_cmd_halfPipe_payload_wr = cpu_dBus_cmd_halfPipe_regs_payload_wr;
  assign cpu_dBus_cmd_halfPipe_payload_address = cpu_dBus_cmd_halfPipe_regs_payload_address;
  assign cpu_dBus_cmd_halfPipe_payload_data = cpu_dBus_cmd_halfPipe_regs_payload_data;
  assign cpu_dBus_cmd_halfPipe_payload_size = cpu_dBus_cmd_halfPipe_regs_payload_size;
  assign cpu_dBus_cmd_halfPipe_ready = mainBusArbiter_io_dBus_cmd_ready;
  assign io_apb_PADDR = apbBridge_io_apb_PADDR;
  assign io_apb_PSEL = apbBridge_io_apb_PSEL;
  assign io_apb_PENABLE = apbBridge_io_apb_PENABLE;
  assign io_apb_PWRITE = apbBridge_io_apb_PWRITE;
  assign io_apb_PWDATA = apbBridge_io_apb_PWDATA;
  assign _zz_CpuComplex_8_ = ((1'b1 && (! mainBusArbiter_io_masterBus_cmd_m2sPipe_valid)) || mainBusArbiter_io_masterBus_cmd_m2sPipe_ready);
  assign mainBusArbiter_io_masterBus_cmd_m2sPipe_valid = _zz_CpuComplex_1_;
  assign mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_write = _zz_CpuComplex_2_;
  assign mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_address = _zz_CpuComplex_3_;
  assign mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_data = _zz_CpuComplex_4_;
  assign mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_mask = _zz_CpuComplex_5_;
  assign mainBusDecoder_logic_masterPipelined_cmd_valid = mainBusArbiter_io_masterBus_cmd_m2sPipe_valid;
  assign mainBusArbiter_io_masterBus_cmd_m2sPipe_ready = mainBusDecoder_logic_masterPipelined_cmd_ready;
  assign mainBusDecoder_logic_masterPipelined_cmd_payload_write = mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_write;
  assign mainBusDecoder_logic_masterPipelined_cmd_payload_address = mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_address;
  assign mainBusDecoder_logic_masterPipelined_cmd_payload_data = mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_data;
  assign mainBusDecoder_logic_masterPipelined_cmd_payload_mask = mainBusArbiter_io_masterBus_cmd_m2sPipe_payload_mask;
  assign mainBusDecoder_logic_hits_0 = ((mainBusDecoder_logic_masterPipelined_cmd_payload_address & _zz_CpuComplex_13_) == (32'b00000000000000000000000000000000));
  always @ (*) begin
    _zz_CpuComplex_9_ = (mainBusDecoder_logic_masterPipelined_cmd_valid && mainBusDecoder_logic_hits_0);
    _zz_CpuComplex_10_ = (mainBusDecoder_logic_masterPipelined_cmd_valid && mainBusDecoder_logic_hits_1);
    mainBusDecoder_logic_masterPipelined_cmd_ready = (({(mainBusDecoder_logic_hits_1 && apbBridge_io_pipelinedMemoryBus_cmd_ready),(mainBusDecoder_logic_hits_0 && ram_io_bus_cmd_ready)} != (2'b00)) || mainBusDecoder_logic_noHit);
    if((mainBusDecoder_logic_rspPending && (! mainBusDecoder_logic_masterPipelined_rsp_valid)))begin
      mainBusDecoder_logic_masterPipelined_cmd_ready = 1'b0;
      _zz_CpuComplex_9_ = 1'b0;
      _zz_CpuComplex_10_ = 1'b0;
    end
  end

  assign _zz_CpuComplex_6_ = mainBusDecoder_logic_masterPipelined_cmd_payload_write;
  assign mainBusDecoder_logic_hits_1 = ((mainBusDecoder_logic_masterPipelined_cmd_payload_address & _zz_CpuComplex_14_) == (32'b10000000000000000000000000000000));
  assign _zz_CpuComplex_7_ = mainBusDecoder_logic_masterPipelined_cmd_payload_write;
  assign mainBusDecoder_logic_noHit = (! ({mainBusDecoder_logic_hits_1,mainBusDecoder_logic_hits_0} != (2'b00)));
  assign mainBusDecoder_logic_masterPipelined_rsp_valid = (({apbBridge_io_pipelinedMemoryBus_rsp_valid,ram_io_bus_rsp_valid} != (2'b00)) || (mainBusDecoder_logic_rspPending && mainBusDecoder_logic_rspNoHit));
  assign mainBusDecoder_logic_masterPipelined_rsp_payload_data = _zz_CpuComplex_11_;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      cpu_dBus_cmd_halfPipe_regs_valid <= 1'b0;
      cpu_dBus_cmd_halfPipe_regs_ready <= 1'b1;
      _zz_CpuComplex_1_ <= 1'b0;
      mainBusDecoder_logic_rspPending <= 1'b0;
      mainBusDecoder_logic_rspNoHit <= 1'b0;
    end else begin
      if(_zz_CpuComplex_12_)begin
        cpu_dBus_cmd_halfPipe_regs_valid <= cpu_dBus_cmd_valid;
        cpu_dBus_cmd_halfPipe_regs_ready <= (! cpu_dBus_cmd_valid);
      end else begin
        cpu_dBus_cmd_halfPipe_regs_valid <= (! cpu_dBus_cmd_halfPipe_ready);
        cpu_dBus_cmd_halfPipe_regs_ready <= cpu_dBus_cmd_halfPipe_ready;
      end
      if(_zz_CpuComplex_8_)begin
        _zz_CpuComplex_1_ <= mainBusArbiter_io_masterBus_cmd_valid;
      end
      if(mainBusDecoder_logic_masterPipelined_rsp_valid)begin
        mainBusDecoder_logic_rspPending <= 1'b0;
      end
      if(((mainBusDecoder_logic_masterPipelined_cmd_valid && mainBusDecoder_logic_masterPipelined_cmd_ready) && (! mainBusDecoder_logic_masterPipelined_cmd_payload_write)))begin
        mainBusDecoder_logic_rspPending <= 1'b1;
      end
      mainBusDecoder_logic_rspNoHit <= 1'b0;
      if(mainBusDecoder_logic_noHit)begin
        mainBusDecoder_logic_rspNoHit <= 1'b1;
      end
    end
  end

  always @ (posedge toplevel_main_clk) begin
    if(_zz_CpuComplex_12_)begin
      cpu_dBus_cmd_halfPipe_regs_payload_wr <= cpu_dBus_cmd_payload_wr;
      cpu_dBus_cmd_halfPipe_regs_payload_address <= cpu_dBus_cmd_payload_address;
      cpu_dBus_cmd_halfPipe_regs_payload_data <= cpu_dBus_cmd_payload_data;
      cpu_dBus_cmd_halfPipe_regs_payload_size <= cpu_dBus_cmd_payload_size;
    end
    if(_zz_CpuComplex_8_)begin
      _zz_CpuComplex_2_ <= mainBusArbiter_io_masterBus_cmd_payload_write;
      _zz_CpuComplex_3_ <= mainBusArbiter_io_masterBus_cmd_payload_address;
      _zz_CpuComplex_4_ <= mainBusArbiter_io_masterBus_cmd_payload_data;
      _zz_CpuComplex_5_ <= mainBusArbiter_io_masterBus_cmd_payload_mask;
    end
    if((mainBusDecoder_logic_masterPipelined_cmd_valid && mainBusDecoder_logic_masterPipelined_cmd_ready))begin
      mainBusDecoder_logic_rspSourceId <= mainBusDecoder_logic_hits_1;
    end
  end

endmodule

module MuraxApb3Timer (
      input  [7:0] io_apb_PADDR,
      input  [0:0] io_apb_PSEL,
      input   io_apb_PENABLE,
      output  io_apb_PREADY,
      input   io_apb_PWRITE,
      input  [31:0] io_apb_PWDATA,
      output reg [31:0] io_apb_PRDATA,
      output  io_apb_PSLVERROR,
      output  io_interrupt,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire  _zz_MuraxApb3Timer_10_;
  wire  _zz_MuraxApb3Timer_11_;
  wire  _zz_MuraxApb3Timer_12_;
  wire  _zz_MuraxApb3Timer_13_;
  reg [1:0] _zz_MuraxApb3Timer_14_;
  reg [1:0] _zz_MuraxApb3Timer_15_;
  wire  prescaler_1__io_overflow;
  wire  timerA_io_full;
  wire [15:0] timerA_io_value;
  wire  timerB_io_full;
  wire [15:0] timerB_io_value;
  wire [1:0] interruptCtrl_1__io_pendings;
  wire  busCtrl_askWrite;
  wire  busCtrl_askRead;
  wire  busCtrl_doWrite;
  wire  busCtrl_doRead;
  reg [15:0] _zz_MuraxApb3Timer_1_;
  reg  _zz_MuraxApb3Timer_2_;
  reg [1:0] timerABridge_ticksEnable;
  reg [0:0] timerABridge_clearsEnable;
  reg  timerABridge_busClearing;
  reg [15:0] _zz_MuraxApb3Timer_3_;
  reg  _zz_MuraxApb3Timer_4_;
  reg  _zz_MuraxApb3Timer_5_;
  reg [1:0] timerBBridge_ticksEnable;
  reg [0:0] timerBBridge_clearsEnable;
  reg  timerBBridge_busClearing;
  reg [15:0] _zz_MuraxApb3Timer_6_;
  reg  _zz_MuraxApb3Timer_7_;
  reg  _zz_MuraxApb3Timer_8_;
  reg [1:0] _zz_MuraxApb3Timer_9_;
  Prescaler prescaler_1_ ( 
    .io_clear(_zz_MuraxApb3Timer_2_),
    .io_limit(_zz_MuraxApb3Timer_1_),
    .io_overflow(prescaler_1__io_overflow),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  Timer timerA ( 
    .io_tick(_zz_MuraxApb3Timer_10_),
    .io_clear(_zz_MuraxApb3Timer_11_),
    .io_limit(_zz_MuraxApb3Timer_3_),
    .io_full(timerA_io_full),
    .io_value(timerA_io_value),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  Timer_1_ timerB ( 
    .io_tick(_zz_MuraxApb3Timer_12_),
    .io_clear(_zz_MuraxApb3Timer_13_),
    .io_limit(_zz_MuraxApb3Timer_6_),
    .io_full(timerB_io_full),
    .io_value(timerB_io_value),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  InterruptCtrl interruptCtrl_1_ ( 
    .io_inputs(_zz_MuraxApb3Timer_14_),
    .io_clears(_zz_MuraxApb3Timer_15_),
    .io_masks(_zz_MuraxApb3Timer_9_),
    .io_pendings(interruptCtrl_1__io_pendings),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  assign io_apb_PREADY = 1'b1;
  always @ (*) begin
    io_apb_PRDATA = (32'b00000000000000000000000000000000);
    _zz_MuraxApb3Timer_2_ = 1'b0;
    _zz_MuraxApb3Timer_4_ = 1'b0;
    _zz_MuraxApb3Timer_5_ = 1'b0;
    _zz_MuraxApb3Timer_7_ = 1'b0;
    _zz_MuraxApb3Timer_8_ = 1'b0;
    _zz_MuraxApb3Timer_15_ = (2'b00);
    case(io_apb_PADDR)
      8'b00000000 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_2_ = 1'b1;
        end
        io_apb_PRDATA[15 : 0] = _zz_MuraxApb3Timer_1_;
      end
      8'b01000000 : begin
        io_apb_PRDATA[1 : 0] = timerABridge_ticksEnable;
        io_apb_PRDATA[16 : 16] = timerABridge_clearsEnable;
      end
      8'b01000100 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_4_ = 1'b1;
        end
        io_apb_PRDATA[15 : 0] = _zz_MuraxApb3Timer_3_;
      end
      8'b01001000 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_5_ = 1'b1;
        end
        io_apb_PRDATA[15 : 0] = timerA_io_value;
      end
      8'b01010000 : begin
        io_apb_PRDATA[1 : 0] = timerBBridge_ticksEnable;
        io_apb_PRDATA[16 : 16] = timerBBridge_clearsEnable;
      end
      8'b01010100 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_7_ = 1'b1;
        end
        io_apb_PRDATA[15 : 0] = _zz_MuraxApb3Timer_6_;
      end
      8'b01011000 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_8_ = 1'b1;
        end
        io_apb_PRDATA[15 : 0] = timerB_io_value;
      end
      8'b00010000 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_15_ = io_apb_PWDATA[1 : 0];
        end
        io_apb_PRDATA[1 : 0] = interruptCtrl_1__io_pendings;
      end
      8'b00010100 : begin
        io_apb_PRDATA[1 : 0] = _zz_MuraxApb3Timer_9_;
      end
      default : begin
      end
    endcase
  end

  assign io_apb_PSLVERROR = 1'b0;
  assign busCtrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
  assign busCtrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (! io_apb_PWRITE));
  assign busCtrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
  assign busCtrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
  always @ (*) begin
    timerABridge_busClearing = 1'b0;
    if(_zz_MuraxApb3Timer_4_)begin
      timerABridge_busClearing = 1'b1;
    end
    if(_zz_MuraxApb3Timer_5_)begin
      timerABridge_busClearing = 1'b1;
    end
  end

  assign _zz_MuraxApb3Timer_11_ = (((timerABridge_clearsEnable & timerA_io_full) != (1'b0)) || timerABridge_busClearing);
  assign _zz_MuraxApb3Timer_10_ = ((timerABridge_ticksEnable & {prescaler_1__io_overflow,1'b1}) != (2'b00));
  always @ (*) begin
    timerBBridge_busClearing = 1'b0;
    if(_zz_MuraxApb3Timer_7_)begin
      timerBBridge_busClearing = 1'b1;
    end
    if(_zz_MuraxApb3Timer_8_)begin
      timerBBridge_busClearing = 1'b1;
    end
  end

  assign _zz_MuraxApb3Timer_13_ = (((timerBBridge_clearsEnable & timerB_io_full) != (1'b0)) || timerBBridge_busClearing);
  assign _zz_MuraxApb3Timer_12_ = ((timerBBridge_ticksEnable & {prescaler_1__io_overflow,1'b1}) != (2'b00));
  always @ (*) begin
    _zz_MuraxApb3Timer_14_[0] = timerA_io_full;
    _zz_MuraxApb3Timer_14_[1] = timerB_io_full;
  end

  assign io_interrupt = (interruptCtrl_1__io_pendings != (2'b00));
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      timerABridge_ticksEnable <= (2'b00);
      timerABridge_clearsEnable <= (1'b0);
      timerBBridge_ticksEnable <= (2'b00);
      timerBBridge_clearsEnable <= (1'b0);
      _zz_MuraxApb3Timer_9_ <= (2'b00);
    end else begin
      case(io_apb_PADDR)
        8'b00000000 : begin
        end
        8'b01000000 : begin
          if(busCtrl_doWrite)begin
            timerABridge_ticksEnable <= io_apb_PWDATA[1 : 0];
            timerABridge_clearsEnable <= io_apb_PWDATA[16 : 16];
          end
        end
        8'b01000100 : begin
        end
        8'b01001000 : begin
        end
        8'b01010000 : begin
          if(busCtrl_doWrite)begin
            timerBBridge_ticksEnable <= io_apb_PWDATA[1 : 0];
            timerBBridge_clearsEnable <= io_apb_PWDATA[16 : 16];
          end
        end
        8'b01010100 : begin
        end
        8'b01011000 : begin
        end
        8'b00010000 : begin
        end
        8'b00010100 : begin
          if(busCtrl_doWrite)begin
            _zz_MuraxApb3Timer_9_ <= io_apb_PWDATA[1 : 0];
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @ (posedge toplevel_main_clk) begin
    case(io_apb_PADDR)
      8'b00000000 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_1_ <= io_apb_PWDATA[15 : 0];
        end
      end
      8'b01000000 : begin
      end
      8'b01000100 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_3_ <= io_apb_PWDATA[15 : 0];
        end
      end
      8'b01001000 : begin
      end
      8'b01010000 : begin
      end
      8'b01010100 : begin
        if(busCtrl_doWrite)begin
          _zz_MuraxApb3Timer_6_ <= io_apb_PWDATA[15 : 0];
        end
      end
      8'b01011000 : begin
      end
      8'b00010000 : begin
      end
      8'b00010100 : begin
      end
      default : begin
      end
    endcase
  end

endmodule

module Apb3Decoder (
      input  [19:0] io_input_PADDR,
      input  [0:0] io_input_PSEL,
      input   io_input_PENABLE,
      output reg  io_input_PREADY,
      input   io_input_PWRITE,
      input  [31:0] io_input_PWDATA,
      output [31:0] io_input_PRDATA,
      output reg  io_input_PSLVERROR,
      output [19:0] io_output_PADDR,
      output reg [6:0] io_output_PSEL,
      output  io_output_PENABLE,
      input   io_output_PREADY,
      output  io_output_PWRITE,
      output [31:0] io_output_PWDATA,
      input  [31:0] io_output_PRDATA,
      input   io_output_PSLVERROR);
  wire [19:0] _zz_Apb3Decoder_1_;
  wire [19:0] _zz_Apb3Decoder_2_;
  wire [19:0] _zz_Apb3Decoder_3_;
  wire [19:0] _zz_Apb3Decoder_4_;
  wire [19:0] _zz_Apb3Decoder_5_;
  wire [19:0] _zz_Apb3Decoder_6_;
  wire [19:0] _zz_Apb3Decoder_7_;
  assign _zz_Apb3Decoder_1_ = (20'b11111111111100000000);
  assign _zz_Apb3Decoder_2_ = (20'b11111111111100000000);
  assign _zz_Apb3Decoder_3_ = (20'b11111111111100000000);
  assign _zz_Apb3Decoder_4_ = (20'b11111111111100000000);
  assign _zz_Apb3Decoder_5_ = (20'b11111111000000000000);
  assign _zz_Apb3Decoder_6_ = (20'b11110000000000000000);
  assign _zz_Apb3Decoder_7_ = (20'b11111111000000000000);
  assign io_output_PADDR = io_input_PADDR;
  assign io_output_PENABLE = io_input_PENABLE;
  assign io_output_PWRITE = io_input_PWRITE;
  assign io_output_PWDATA = io_input_PWDATA;
  always @ (*) begin
    io_output_PSEL[0] = (((io_input_PADDR & _zz_Apb3Decoder_1_) == (20'b00000000000000000000)) && io_input_PSEL[0]);
    io_output_PSEL[1] = (((io_input_PADDR & _zz_Apb3Decoder_2_) == (20'b00000000000100000000)) && io_input_PSEL[0]);
    io_output_PSEL[2] = (((io_input_PADDR & _zz_Apb3Decoder_3_) == (20'b00000000001000000000)) && io_input_PSEL[0]);
    io_output_PSEL[3] = (((io_input_PADDR & _zz_Apb3Decoder_4_) == (20'b00000000001100000000)) && io_input_PSEL[0]);
    io_output_PSEL[4] = (((io_input_PADDR & _zz_Apb3Decoder_5_) == (20'b00010000000000000000)) && io_input_PSEL[0]);
    io_output_PSEL[5] = (((io_input_PADDR & _zz_Apb3Decoder_6_) == (20'b00100000000000000000)) && io_input_PSEL[0]);
    io_output_PSEL[6] = (((io_input_PADDR & _zz_Apb3Decoder_7_) == (20'b00110000000000000000)) && io_input_PSEL[0]);
  end

  always @ (*) begin
    io_input_PREADY = io_output_PREADY;
    io_input_PSLVERROR = io_output_PSLVERROR;
    if((io_input_PSEL[0] && (io_output_PSEL == (7'b0000000))))begin
      io_input_PREADY = 1'b1;
      io_input_PSLVERROR = 1'b1;
    end
  end

  assign io_input_PRDATA = io_output_PRDATA;
endmodule

module Apb3Router (
      input  [19:0] io_input_PADDR,
      input  [6:0] io_input_PSEL,
      input   io_input_PENABLE,
      output  io_input_PREADY,
      input   io_input_PWRITE,
      input  [31:0] io_input_PWDATA,
      output [31:0] io_input_PRDATA,
      output  io_input_PSLVERROR,
      output [19:0] io_outputs_0_PADDR,
      output [0:0] io_outputs_0_PSEL,
      output  io_outputs_0_PENABLE,
      input   io_outputs_0_PREADY,
      output  io_outputs_0_PWRITE,
      output [31:0] io_outputs_0_PWDATA,
      input  [31:0] io_outputs_0_PRDATA,
      input   io_outputs_0_PSLVERROR,
      output [19:0] io_outputs_1_PADDR,
      output [0:0] io_outputs_1_PSEL,
      output  io_outputs_1_PENABLE,
      input   io_outputs_1_PREADY,
      output  io_outputs_1_PWRITE,
      output [31:0] io_outputs_1_PWDATA,
      input  [31:0] io_outputs_1_PRDATA,
      input   io_outputs_1_PSLVERROR,
      output [19:0] io_outputs_2_PADDR,
      output [0:0] io_outputs_2_PSEL,
      output  io_outputs_2_PENABLE,
      input   io_outputs_2_PREADY,
      output  io_outputs_2_PWRITE,
      output [31:0] io_outputs_2_PWDATA,
      input  [31:0] io_outputs_2_PRDATA,
      input   io_outputs_2_PSLVERROR,
      output [19:0] io_outputs_3_PADDR,
      output [0:0] io_outputs_3_PSEL,
      output  io_outputs_3_PENABLE,
      input   io_outputs_3_PREADY,
      output  io_outputs_3_PWRITE,
      output [31:0] io_outputs_3_PWDATA,
      input  [31:0] io_outputs_3_PRDATA,
      input   io_outputs_3_PSLVERROR,
      output [19:0] io_outputs_4_PADDR,
      output [0:0] io_outputs_4_PSEL,
      output  io_outputs_4_PENABLE,
      input   io_outputs_4_PREADY,
      output  io_outputs_4_PWRITE,
      output [31:0] io_outputs_4_PWDATA,
      input  [31:0] io_outputs_4_PRDATA,
      input   io_outputs_4_PSLVERROR,
      output [19:0] io_outputs_5_PADDR,
      output [0:0] io_outputs_5_PSEL,
      output  io_outputs_5_PENABLE,
      input   io_outputs_5_PREADY,
      output  io_outputs_5_PWRITE,
      output [31:0] io_outputs_5_PWDATA,
      input  [31:0] io_outputs_5_PRDATA,
      input   io_outputs_5_PSLVERROR,
      output [19:0] io_outputs_6_PADDR,
      output [0:0] io_outputs_6_PSEL,
      output  io_outputs_6_PENABLE,
      input   io_outputs_6_PREADY,
      output  io_outputs_6_PWRITE,
      output [31:0] io_outputs_6_PWDATA,
      input  [31:0] io_outputs_6_PRDATA,
      input   io_outputs_6_PSLVERROR,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg  _zz_Apb3Router_7_;
  reg [31:0] _zz_Apb3Router_8_;
  reg  _zz_Apb3Router_9_;
  wire  _zz_Apb3Router_1_;
  wire  _zz_Apb3Router_2_;
  wire  _zz_Apb3Router_3_;
  wire  _zz_Apb3Router_4_;
  wire  _zz_Apb3Router_5_;
  wire  _zz_Apb3Router_6_;
  reg [2:0] selIndex;
  always @(*) begin
    case(selIndex)
      3'b000 : begin
        _zz_Apb3Router_7_ = io_outputs_0_PREADY;
        _zz_Apb3Router_8_ = io_outputs_0_PRDATA;
        _zz_Apb3Router_9_ = io_outputs_0_PSLVERROR;
      end
      3'b001 : begin
        _zz_Apb3Router_7_ = io_outputs_1_PREADY;
        _zz_Apb3Router_8_ = io_outputs_1_PRDATA;
        _zz_Apb3Router_9_ = io_outputs_1_PSLVERROR;
      end
      3'b010 : begin
        _zz_Apb3Router_7_ = io_outputs_2_PREADY;
        _zz_Apb3Router_8_ = io_outputs_2_PRDATA;
        _zz_Apb3Router_9_ = io_outputs_2_PSLVERROR;
      end
      3'b011 : begin
        _zz_Apb3Router_7_ = io_outputs_3_PREADY;
        _zz_Apb3Router_8_ = io_outputs_3_PRDATA;
        _zz_Apb3Router_9_ = io_outputs_3_PSLVERROR;
      end
      3'b100 : begin
        _zz_Apb3Router_7_ = io_outputs_4_PREADY;
        _zz_Apb3Router_8_ = io_outputs_4_PRDATA;
        _zz_Apb3Router_9_ = io_outputs_4_PSLVERROR;
      end
      3'b101 : begin
        _zz_Apb3Router_7_ = io_outputs_5_PREADY;
        _zz_Apb3Router_8_ = io_outputs_5_PRDATA;
        _zz_Apb3Router_9_ = io_outputs_5_PSLVERROR;
      end
      default : begin
        _zz_Apb3Router_7_ = io_outputs_6_PREADY;
        _zz_Apb3Router_8_ = io_outputs_6_PRDATA;
        _zz_Apb3Router_9_ = io_outputs_6_PSLVERROR;
      end
    endcase
  end

  assign io_outputs_0_PADDR = io_input_PADDR;
  assign io_outputs_0_PENABLE = io_input_PENABLE;
  assign io_outputs_0_PSEL[0] = io_input_PSEL[0];
  assign io_outputs_0_PWRITE = io_input_PWRITE;
  assign io_outputs_0_PWDATA = io_input_PWDATA;
  assign io_outputs_1_PADDR = io_input_PADDR;
  assign io_outputs_1_PENABLE = io_input_PENABLE;
  assign io_outputs_1_PSEL[0] = io_input_PSEL[1];
  assign io_outputs_1_PWRITE = io_input_PWRITE;
  assign io_outputs_1_PWDATA = io_input_PWDATA;
  assign io_outputs_2_PADDR = io_input_PADDR;
  assign io_outputs_2_PENABLE = io_input_PENABLE;
  assign io_outputs_2_PSEL[0] = io_input_PSEL[2];
  assign io_outputs_2_PWRITE = io_input_PWRITE;
  assign io_outputs_2_PWDATA = io_input_PWDATA;
  assign io_outputs_3_PADDR = io_input_PADDR;
  assign io_outputs_3_PENABLE = io_input_PENABLE;
  assign io_outputs_3_PSEL[0] = io_input_PSEL[3];
  assign io_outputs_3_PWRITE = io_input_PWRITE;
  assign io_outputs_3_PWDATA = io_input_PWDATA;
  assign io_outputs_4_PADDR = io_input_PADDR;
  assign io_outputs_4_PENABLE = io_input_PENABLE;
  assign io_outputs_4_PSEL[0] = io_input_PSEL[4];
  assign io_outputs_4_PWRITE = io_input_PWRITE;
  assign io_outputs_4_PWDATA = io_input_PWDATA;
  assign io_outputs_5_PADDR = io_input_PADDR;
  assign io_outputs_5_PENABLE = io_input_PENABLE;
  assign io_outputs_5_PSEL[0] = io_input_PSEL[5];
  assign io_outputs_5_PWRITE = io_input_PWRITE;
  assign io_outputs_5_PWDATA = io_input_PWDATA;
  assign io_outputs_6_PADDR = io_input_PADDR;
  assign io_outputs_6_PENABLE = io_input_PENABLE;
  assign io_outputs_6_PSEL[0] = io_input_PSEL[6];
  assign io_outputs_6_PWRITE = io_input_PWRITE;
  assign io_outputs_6_PWDATA = io_input_PWDATA;
  assign _zz_Apb3Router_1_ = io_input_PSEL[3];
  assign _zz_Apb3Router_2_ = io_input_PSEL[5];
  assign _zz_Apb3Router_3_ = io_input_PSEL[6];
  assign _zz_Apb3Router_4_ = ((io_input_PSEL[1] || _zz_Apb3Router_1_) || _zz_Apb3Router_2_);
  assign _zz_Apb3Router_5_ = ((io_input_PSEL[2] || _zz_Apb3Router_1_) || _zz_Apb3Router_3_);
  assign _zz_Apb3Router_6_ = ((io_input_PSEL[4] || _zz_Apb3Router_2_) || _zz_Apb3Router_3_);
  assign io_input_PREADY = _zz_Apb3Router_7_;
  assign io_input_PRDATA = _zz_Apb3Router_8_;
  assign io_input_PSLVERROR = _zz_Apb3Router_9_;
  always @ (posedge toplevel_main_clk) begin
    selIndex <= {_zz_Apb3Router_6_,{_zz_Apb3Router_5_,_zz_Apb3Router_4_}};
  end

endmodule

module GmiiRxCtrl (
      input   io_rx_clk,
      input   io_rx_dv,
      input   io_rx_er,
      input  [7:0] io_rx_d,
      output  io_rx_fifo_rd_valid,
      input   io_rx_fifo_rd_ready,
      output [9:0] io_rx_fifo_rd_payload,
      output [15:0] io_rx_fifo_rd_count,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire  u_rx_fifo_io_push_ready;
  wire  u_rx_fifo_io_pop_valid;
  wire [9:0] u_rx_fifo_io_pop_payload;
  wire [11:0] u_rx_fifo_io_pushOccupancy;
  wire [11:0] u_rx_fifo_io_popOccupancy;
  wire  rx_domain_rx_fifo_wr_valid;
  wire  rx_domain_rx_fifo_wr_ready;
  wire [9:0] rx_domain_rx_fifo_wr_payload;
  StreamFifoCC u_rx_fifo ( 
    .io_push_valid(rx_domain_rx_fifo_wr_valid),
    .io_push_ready(u_rx_fifo_io_push_ready),
    .io_push_payload(rx_domain_rx_fifo_wr_payload),
    .io_pop_valid(u_rx_fifo_io_pop_valid),
    .io_pop_ready(io_rx_fifo_rd_ready),
    .io_pop_payload(u_rx_fifo_io_pop_payload),
    .io_pushOccupancy(u_rx_fifo_io_pushOccupancy),
    .io_popOccupancy(u_rx_fifo_io_popOccupancy),
    .u_gmii_rx_io_rx_clk(io_rx_clk),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  assign rx_domain_rx_fifo_wr_valid = ((io_rx_dv || io_rx_er) && rx_domain_rx_fifo_wr_ready);
  assign rx_domain_rx_fifo_wr_payload = {{io_rx_dv,io_rx_er},io_rx_d};
  assign rx_domain_rx_fifo_wr_ready = u_rx_fifo_io_push_ready;
  assign io_rx_fifo_rd_valid = u_rx_fifo_io_pop_valid;
  assign io_rx_fifo_rd_payload = u_rx_fifo_io_pop_payload;
  assign io_rx_fifo_rd_count = {4'd0, u_rx_fifo_io_popOccupancy};
endmodule

module GmiiTxCtrl (
      input   io_tx_gclk,
      input   io_tx_clk,
      output  io_tx_en,
      output  io_tx_er,
      output [7:0] io_tx_d);
  assign io_tx_en = 1'b0;
  assign io_tx_er = 1'b0;
  assign io_tx_d = (8'b00000000);
endmodule

module BufferCC_2_ (
      input  [1:0] io_initial,
      input  [1:0] io_dataIn,
      output [1:0] io_dataOut,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg [1:0] buffers_0;
  reg [1:0] buffers_1;
  assign io_dataOut = buffers_1;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      buffers_0 <= io_initial;
      buffers_1 <= io_initial;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end

endmodule

module BufferCC_3_ (
      input  [1:0] io_initial,
      input  [1:0] io_dataIn,
      output [1:0] io_dataOut,
      input   u_ulpi_ctrl_io_ulpi_clk);
  reg [1:0] buffers_0 = (2'b00);
  reg [1:0] buffers_1 = (2'b00);
  assign io_dataOut = buffers_1;
  always @ (posedge u_ulpi_ctrl_io_ulpi_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end

endmodule

module CpuTop (
      output [3:0] io_led_ctrl_apb_PADDR,
      output [0:0] io_led_ctrl_apb_PSEL,
      output  io_led_ctrl_apb_PENABLE,
      input   io_led_ctrl_apb_PREADY,
      output  io_led_ctrl_apb_PWRITE,
      output [31:0] io_led_ctrl_apb_PWDATA,
      input  [31:0] io_led_ctrl_apb_PRDATA,
      input   io_led_ctrl_apb_PSLVERROR,
      output [4:0] io_dvi_ctrl_apb_PADDR,
      output [0:0] io_dvi_ctrl_apb_PSEL,
      output  io_dvi_ctrl_apb_PENABLE,
      input   io_dvi_ctrl_apb_PREADY,
      output  io_dvi_ctrl_apb_PWRITE,
      output [31:0] io_dvi_ctrl_apb_PWDATA,
      input  [31:0] io_dvi_ctrl_apb_PRDATA,
      input   io_dvi_ctrl_apb_PSLVERROR,
      output [4:0] io_gmii_ctrl_apb_PADDR,
      output [0:0] io_gmii_ctrl_apb_PSEL,
      output  io_gmii_ctrl_apb_PENABLE,
      input   io_gmii_ctrl_apb_PREADY,
      output  io_gmii_ctrl_apb_PWRITE,
      output [31:0] io_gmii_ctrl_apb_PWDATA,
      input  [31:0] io_gmii_ctrl_apb_PRDATA,
      input   io_gmii_ctrl_apb_PSLVERROR,
      output [4:0] io_test_patt_apb_PADDR,
      output [0:0] io_test_patt_apb_PSEL,
      output  io_test_patt_apb_PENABLE,
      input   io_test_patt_apb_PREADY,
      output  io_test_patt_apb_PWRITE,
      output [31:0] io_test_patt_apb_PWDATA,
      input  [31:0] io_test_patt_apb_PRDATA,
      input   io_test_patt_apb_PSLVERROR,
      output [15:0] io_txt_gen_apb_PADDR,
      output [0:0] io_txt_gen_apb_PSEL,
      output  io_txt_gen_apb_PENABLE,
      input   io_txt_gen_apb_PREADY,
      output  io_txt_gen_apb_PWRITE,
      output [31:0] io_txt_gen_apb_PWDATA,
      input  [31:0] io_txt_gen_apb_PRDATA,
      input   io_txt_gen_apb_PSLVERROR,
      output [5:0] io_ulpi_apb_PADDR,
      output [0:0] io_ulpi_apb_PSEL,
      output  io_ulpi_apb_PENABLE,
      input   io_ulpi_apb_PREADY,
      output  io_ulpi_apb_PWRITE,
      output [31:0] io_ulpi_apb_PWDATA,
      input  [31:0] io_ulpi_apb_PRDATA,
      input   io_ulpi_apb_PSLVERROR,
      input   io_switch_,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire  _zz_CpuTop_1_;
  wire [7:0] _zz_CpuTop_2_;
  wire [19:0] u_cpu_io_apb_PADDR;
  wire [0:0] u_cpu_io_apb_PSEL;
  wire  u_cpu_io_apb_PENABLE;
  wire  u_cpu_io_apb_PWRITE;
  wire [31:0] u_cpu_io_apb_PWDATA;
  wire  u_timer_io_apb_PREADY;
  wire [31:0] u_timer_io_apb_PRDATA;
  wire  u_timer_io_apb_PSLVERROR;
  wire  u_timer_io_interrupt;
  wire  io_apb_decoder_io_input_PREADY;
  wire [31:0] io_apb_decoder_io_input_PRDATA;
  wire  io_apb_decoder_io_input_PSLVERROR;
  wire [19:0] io_apb_decoder_io_output_PADDR;
  wire [6:0] io_apb_decoder_io_output_PSEL;
  wire  io_apb_decoder_io_output_PENABLE;
  wire  io_apb_decoder_io_output_PWRITE;
  wire [31:0] io_apb_decoder_io_output_PWDATA;
  wire  apb3Router_1__io_input_PREADY;
  wire [31:0] apb3Router_1__io_input_PRDATA;
  wire  apb3Router_1__io_input_PSLVERROR;
  wire [19:0] apb3Router_1__io_outputs_0_PADDR;
  wire [0:0] apb3Router_1__io_outputs_0_PSEL;
  wire  apb3Router_1__io_outputs_0_PENABLE;
  wire  apb3Router_1__io_outputs_0_PWRITE;
  wire [31:0] apb3Router_1__io_outputs_0_PWDATA;
  wire [19:0] apb3Router_1__io_outputs_1_PADDR;
  wire [0:0] apb3Router_1__io_outputs_1_PSEL;
  wire  apb3Router_1__io_outputs_1_PENABLE;
  wire  apb3Router_1__io_outputs_1_PWRITE;
  wire [31:0] apb3Router_1__io_outputs_1_PWDATA;
  wire [19:0] apb3Router_1__io_outputs_2_PADDR;
  wire [0:0] apb3Router_1__io_outputs_2_PSEL;
  wire  apb3Router_1__io_outputs_2_PENABLE;
  wire  apb3Router_1__io_outputs_2_PWRITE;
  wire [31:0] apb3Router_1__io_outputs_2_PWDATA;
  wire [19:0] apb3Router_1__io_outputs_3_PADDR;
  wire [0:0] apb3Router_1__io_outputs_3_PSEL;
  wire  apb3Router_1__io_outputs_3_PENABLE;
  wire  apb3Router_1__io_outputs_3_PWRITE;
  wire [31:0] apb3Router_1__io_outputs_3_PWDATA;
  wire [19:0] apb3Router_1__io_outputs_4_PADDR;
  wire [0:0] apb3Router_1__io_outputs_4_PSEL;
  wire  apb3Router_1__io_outputs_4_PENABLE;
  wire  apb3Router_1__io_outputs_4_PWRITE;
  wire [31:0] apb3Router_1__io_outputs_4_PWDATA;
  wire [19:0] apb3Router_1__io_outputs_5_PADDR;
  wire [0:0] apb3Router_1__io_outputs_5_PSEL;
  wire  apb3Router_1__io_outputs_5_PENABLE;
  wire  apb3Router_1__io_outputs_5_PWRITE;
  wire [31:0] apb3Router_1__io_outputs_5_PWDATA;
  wire [19:0] apb3Router_1__io_outputs_6_PADDR;
  wire [0:0] apb3Router_1__io_outputs_6_PSEL;
  wire  apb3Router_1__io_outputs_6_PENABLE;
  wire  apb3Router_1__io_outputs_6_PWRITE;
  wire [31:0] apb3Router_1__io_outputs_6_PWDATA;
  CpuComplex u_cpu ( 
    .io_apb_PADDR(u_cpu_io_apb_PADDR),
    .io_apb_PSEL(u_cpu_io_apb_PSEL),
    .io_apb_PENABLE(u_cpu_io_apb_PENABLE),
    .io_apb_PREADY(io_apb_decoder_io_input_PREADY),
    .io_apb_PWRITE(u_cpu_io_apb_PWRITE),
    .io_apb_PWDATA(u_cpu_io_apb_PWDATA),
    .io_apb_PRDATA(io_apb_decoder_io_input_PRDATA),
    .io_apb_PSLVERROR(io_apb_decoder_io_input_PSLVERROR),
    .io_externalInterrupt(_zz_CpuTop_1_),
    .io_timerInterrupt(u_timer_io_interrupt),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  MuraxApb3Timer u_timer ( 
    .io_apb_PADDR(_zz_CpuTop_2_),
    .io_apb_PSEL(apb3Router_1__io_outputs_6_PSEL),
    .io_apb_PENABLE(apb3Router_1__io_outputs_6_PENABLE),
    .io_apb_PREADY(u_timer_io_apb_PREADY),
    .io_apb_PWRITE(apb3Router_1__io_outputs_6_PWRITE),
    .io_apb_PWDATA(apb3Router_1__io_outputs_6_PWDATA),
    .io_apb_PRDATA(u_timer_io_apb_PRDATA),
    .io_apb_PSLVERROR(u_timer_io_apb_PSLVERROR),
    .io_interrupt(u_timer_io_interrupt),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  Apb3Decoder io_apb_decoder ( 
    .io_input_PADDR(u_cpu_io_apb_PADDR),
    .io_input_PSEL(u_cpu_io_apb_PSEL),
    .io_input_PENABLE(u_cpu_io_apb_PENABLE),
    .io_input_PREADY(io_apb_decoder_io_input_PREADY),
    .io_input_PWRITE(u_cpu_io_apb_PWRITE),
    .io_input_PWDATA(u_cpu_io_apb_PWDATA),
    .io_input_PRDATA(io_apb_decoder_io_input_PRDATA),
    .io_input_PSLVERROR(io_apb_decoder_io_input_PSLVERROR),
    .io_output_PADDR(io_apb_decoder_io_output_PADDR),
    .io_output_PSEL(io_apb_decoder_io_output_PSEL),
    .io_output_PENABLE(io_apb_decoder_io_output_PENABLE),
    .io_output_PREADY(apb3Router_1__io_input_PREADY),
    .io_output_PWRITE(io_apb_decoder_io_output_PWRITE),
    .io_output_PWDATA(io_apb_decoder_io_output_PWDATA),
    .io_output_PRDATA(apb3Router_1__io_input_PRDATA),
    .io_output_PSLVERROR(apb3Router_1__io_input_PSLVERROR) 
  );
  Apb3Router apb3Router_1_ ( 
    .io_input_PADDR(io_apb_decoder_io_output_PADDR),
    .io_input_PSEL(io_apb_decoder_io_output_PSEL),
    .io_input_PENABLE(io_apb_decoder_io_output_PENABLE),
    .io_input_PREADY(apb3Router_1__io_input_PREADY),
    .io_input_PWRITE(io_apb_decoder_io_output_PWRITE),
    .io_input_PWDATA(io_apb_decoder_io_output_PWDATA),
    .io_input_PRDATA(apb3Router_1__io_input_PRDATA),
    .io_input_PSLVERROR(apb3Router_1__io_input_PSLVERROR),
    .io_outputs_0_PADDR(apb3Router_1__io_outputs_0_PADDR),
    .io_outputs_0_PSEL(apb3Router_1__io_outputs_0_PSEL),
    .io_outputs_0_PENABLE(apb3Router_1__io_outputs_0_PENABLE),
    .io_outputs_0_PREADY(io_led_ctrl_apb_PREADY),
    .io_outputs_0_PWRITE(apb3Router_1__io_outputs_0_PWRITE),
    .io_outputs_0_PWDATA(apb3Router_1__io_outputs_0_PWDATA),
    .io_outputs_0_PRDATA(io_led_ctrl_apb_PRDATA),
    .io_outputs_0_PSLVERROR(io_led_ctrl_apb_PSLVERROR),
    .io_outputs_1_PADDR(apb3Router_1__io_outputs_1_PADDR),
    .io_outputs_1_PSEL(apb3Router_1__io_outputs_1_PSEL),
    .io_outputs_1_PENABLE(apb3Router_1__io_outputs_1_PENABLE),
    .io_outputs_1_PREADY(io_dvi_ctrl_apb_PREADY),
    .io_outputs_1_PWRITE(apb3Router_1__io_outputs_1_PWRITE),
    .io_outputs_1_PWDATA(apb3Router_1__io_outputs_1_PWDATA),
    .io_outputs_1_PRDATA(io_dvi_ctrl_apb_PRDATA),
    .io_outputs_1_PSLVERROR(io_dvi_ctrl_apb_PSLVERROR),
    .io_outputs_2_PADDR(apb3Router_1__io_outputs_2_PADDR),
    .io_outputs_2_PSEL(apb3Router_1__io_outputs_2_PSEL),
    .io_outputs_2_PENABLE(apb3Router_1__io_outputs_2_PENABLE),
    .io_outputs_2_PREADY(io_test_patt_apb_PREADY),
    .io_outputs_2_PWRITE(apb3Router_1__io_outputs_2_PWRITE),
    .io_outputs_2_PWDATA(apb3Router_1__io_outputs_2_PWDATA),
    .io_outputs_2_PRDATA(io_test_patt_apb_PRDATA),
    .io_outputs_2_PSLVERROR(io_test_patt_apb_PSLVERROR),
    .io_outputs_3_PADDR(apb3Router_1__io_outputs_3_PADDR),
    .io_outputs_3_PSEL(apb3Router_1__io_outputs_3_PSEL),
    .io_outputs_3_PENABLE(apb3Router_1__io_outputs_3_PENABLE),
    .io_outputs_3_PREADY(io_ulpi_apb_PREADY),
    .io_outputs_3_PWRITE(apb3Router_1__io_outputs_3_PWRITE),
    .io_outputs_3_PWDATA(apb3Router_1__io_outputs_3_PWDATA),
    .io_outputs_3_PRDATA(io_ulpi_apb_PRDATA),
    .io_outputs_3_PSLVERROR(io_ulpi_apb_PSLVERROR),
    .io_outputs_4_PADDR(apb3Router_1__io_outputs_4_PADDR),
    .io_outputs_4_PSEL(apb3Router_1__io_outputs_4_PSEL),
    .io_outputs_4_PENABLE(apb3Router_1__io_outputs_4_PENABLE),
    .io_outputs_4_PREADY(io_gmii_ctrl_apb_PREADY),
    .io_outputs_4_PWRITE(apb3Router_1__io_outputs_4_PWRITE),
    .io_outputs_4_PWDATA(apb3Router_1__io_outputs_4_PWDATA),
    .io_outputs_4_PRDATA(io_gmii_ctrl_apb_PRDATA),
    .io_outputs_4_PSLVERROR(io_gmii_ctrl_apb_PSLVERROR),
    .io_outputs_5_PADDR(apb3Router_1__io_outputs_5_PADDR),
    .io_outputs_5_PSEL(apb3Router_1__io_outputs_5_PSEL),
    .io_outputs_5_PENABLE(apb3Router_1__io_outputs_5_PENABLE),
    .io_outputs_5_PREADY(io_txt_gen_apb_PREADY),
    .io_outputs_5_PWRITE(apb3Router_1__io_outputs_5_PWRITE),
    .io_outputs_5_PWDATA(apb3Router_1__io_outputs_5_PWDATA),
    .io_outputs_5_PRDATA(io_txt_gen_apb_PRDATA),
    .io_outputs_5_PSLVERROR(io_txt_gen_apb_PSLVERROR),
    .io_outputs_6_PADDR(apb3Router_1__io_outputs_6_PADDR),
    .io_outputs_6_PSEL(apb3Router_1__io_outputs_6_PSEL),
    .io_outputs_6_PENABLE(apb3Router_1__io_outputs_6_PENABLE),
    .io_outputs_6_PREADY(u_timer_io_apb_PREADY),
    .io_outputs_6_PWRITE(apb3Router_1__io_outputs_6_PWRITE),
    .io_outputs_6_PWDATA(apb3Router_1__io_outputs_6_PWDATA),
    .io_outputs_6_PRDATA(u_timer_io_apb_PRDATA),
    .io_outputs_6_PSLVERROR(u_timer_io_apb_PSLVERROR),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  assign _zz_CpuTop_1_ = 1'b0;
  assign io_led_ctrl_apb_PADDR = apb3Router_1__io_outputs_0_PADDR[3:0];
  assign io_led_ctrl_apb_PSEL = apb3Router_1__io_outputs_0_PSEL;
  assign io_led_ctrl_apb_PENABLE = apb3Router_1__io_outputs_0_PENABLE;
  assign io_led_ctrl_apb_PWRITE = apb3Router_1__io_outputs_0_PWRITE;
  assign io_led_ctrl_apb_PWDATA = apb3Router_1__io_outputs_0_PWDATA;
  assign io_dvi_ctrl_apb_PADDR = apb3Router_1__io_outputs_1_PADDR[4:0];
  assign io_dvi_ctrl_apb_PSEL = apb3Router_1__io_outputs_1_PSEL;
  assign io_dvi_ctrl_apb_PENABLE = apb3Router_1__io_outputs_1_PENABLE;
  assign io_dvi_ctrl_apb_PWRITE = apb3Router_1__io_outputs_1_PWRITE;
  assign io_dvi_ctrl_apb_PWDATA = apb3Router_1__io_outputs_1_PWDATA;
  assign io_test_patt_apb_PADDR = apb3Router_1__io_outputs_2_PADDR[4:0];
  assign io_test_patt_apb_PSEL = apb3Router_1__io_outputs_2_PSEL;
  assign io_test_patt_apb_PENABLE = apb3Router_1__io_outputs_2_PENABLE;
  assign io_test_patt_apb_PWRITE = apb3Router_1__io_outputs_2_PWRITE;
  assign io_test_patt_apb_PWDATA = apb3Router_1__io_outputs_2_PWDATA;
  assign io_ulpi_apb_PADDR = apb3Router_1__io_outputs_3_PADDR[5:0];
  assign io_ulpi_apb_PSEL = apb3Router_1__io_outputs_3_PSEL;
  assign io_ulpi_apb_PENABLE = apb3Router_1__io_outputs_3_PENABLE;
  assign io_ulpi_apb_PWRITE = apb3Router_1__io_outputs_3_PWRITE;
  assign io_ulpi_apb_PWDATA = apb3Router_1__io_outputs_3_PWDATA;
  assign io_gmii_ctrl_apb_PADDR = apb3Router_1__io_outputs_4_PADDR[4:0];
  assign io_gmii_ctrl_apb_PSEL = apb3Router_1__io_outputs_4_PSEL;
  assign io_gmii_ctrl_apb_PENABLE = apb3Router_1__io_outputs_4_PENABLE;
  assign io_gmii_ctrl_apb_PWRITE = apb3Router_1__io_outputs_4_PWRITE;
  assign io_gmii_ctrl_apb_PWDATA = apb3Router_1__io_outputs_4_PWDATA;
  assign io_txt_gen_apb_PADDR = apb3Router_1__io_outputs_5_PADDR[15:0];
  assign io_txt_gen_apb_PSEL = apb3Router_1__io_outputs_5_PSEL;
  assign io_txt_gen_apb_PENABLE = apb3Router_1__io_outputs_5_PENABLE;
  assign io_txt_gen_apb_PWRITE = apb3Router_1__io_outputs_5_PWRITE;
  assign io_txt_gen_apb_PWDATA = apb3Router_1__io_outputs_5_PWDATA;
  assign _zz_CpuTop_2_ = apb3Router_1__io_outputs_6_PADDR[7:0];
endmodule

module VideoTimingGen (
      input  [11:0] io_timings_h_active,
      input  [8:0] io_timings_h_fp,
      input  [8:0] io_timings_h_sync,
      input  [8:0] io_timings_h_bp,
      input   io_timings_h_sync_positive,
      input  [11:0] io_timings_h_total_m1,
      input  [10:0] io_timings_v_active,
      input  [8:0] io_timings_v_fp,
      input  [8:0] io_timings_v_sync,
      input  [8:0] io_timings_v_bp,
      input   io_timings_v_sync_positive,
      input  [11:0] io_timings_v_total_m1,
      output reg  io_pixel_out_vsync,
      output reg  io_pixel_out_req,
      output reg  io_pixel_out_eol,
      output reg  io_pixel_out_eof,
      output reg [7:0] io_pixel_out_pixel_r,
      output reg [7:0] io_pixel_out_pixel_g,
      output reg [7:0] io_pixel_out_pixel_b,
      input   toplevel_vo_clk,
      input   toplevel_vo_reset_);
  wire [11:0] _zz_VideoTimingGen_1_;
  wire [8:0] _zz_VideoTimingGen_2_;
  wire [8:0] _zz_VideoTimingGen_3_;
  wire [11:0] _zz_VideoTimingGen_4_;
  wire [10:0] _zz_VideoTimingGen_5_;
  reg [11:0] col_cntr;
  reg [10:0] line_cntr;
  wire  last_col;
  wire  last_line;
  wire [8:0] h_blank;
  wire [8:0] v_blank;
  wire  pixel_active;
  assign _zz_VideoTimingGen_1_ = {1'd0, line_cntr};
  assign _zz_VideoTimingGen_2_ = (io_timings_h_fp + io_timings_h_sync);
  assign _zz_VideoTimingGen_3_ = (io_timings_v_fp + io_timings_v_sync);
  assign _zz_VideoTimingGen_4_ = {3'd0, h_blank};
  assign _zz_VideoTimingGen_5_ = {2'd0, v_blank};
  assign last_col = (col_cntr == io_timings_h_total_m1);
  assign last_line = (_zz_VideoTimingGen_1_ == io_timings_v_total_m1);
  assign h_blank = (_zz_VideoTimingGen_2_ + io_timings_h_bp);
  assign v_blank = (_zz_VideoTimingGen_3_ + io_timings_v_bp);
  assign pixel_active = ((_zz_VideoTimingGen_4_ <= col_cntr) && (_zz_VideoTimingGen_5_ <= line_cntr));
  always @ (posedge toplevel_vo_clk) begin
    if(!toplevel_vo_reset_) begin
      col_cntr <= (12'b000000000000);
      line_cntr <= (11'b00000000000);
    end else begin
      if((! last_col))begin
        col_cntr <= (col_cntr + (12'b000000000001));
      end else begin
        col_cntr <= (12'b000000000000);
        if((! last_line))begin
          line_cntr <= (line_cntr + (11'b00000000001));
        end else begin
          line_cntr <= (11'b00000000000);
        end
      end
    end
  end

  always @ (posedge toplevel_vo_clk) begin
    io_pixel_out_vsync <= ((col_cntr == (12'b000000000000)) && (line_cntr == (11'b00000000000)));
    io_pixel_out_req <= pixel_active;
    io_pixel_out_eol <= (pixel_active ? last_col : 1'b0);
    io_pixel_out_eof <= (pixel_active ? (last_col && last_line) : 1'b0);
    io_pixel_out_pixel_r <= (8'b10000000);
    io_pixel_out_pixel_g <= (8'b10000000);
    io_pixel_out_pixel_b <= (8'b10000000);
  end

endmodule

module VideoTestPattern (
      input  [11:0] io_timings_h_active,
      input  [8:0] io_timings_h_fp,
      input  [8:0] io_timings_h_sync,
      input  [8:0] io_timings_h_bp,
      input   io_timings_h_sync_positive,
      input  [11:0] io_timings_h_total_m1,
      input  [10:0] io_timings_v_active,
      input  [8:0] io_timings_v_fp,
      input  [8:0] io_timings_v_sync,
      input  [8:0] io_timings_v_bp,
      input   io_timings_v_sync_positive,
      input  [11:0] io_timings_v_total_m1,
      input   io_pixel_in_vsync,
      input   io_pixel_in_req,
      input   io_pixel_in_eol,
      input   io_pixel_in_eof,
      input  [7:0] io_pixel_in_pixel_r,
      input  [7:0] io_pixel_in_pixel_g,
      input  [7:0] io_pixel_in_pixel_b,
      output reg  io_pixel_out_vsync,
      output reg  io_pixel_out_req,
      output reg  io_pixel_out_eol,
      output reg  io_pixel_out_eof,
      output reg [7:0] io_pixel_out_pixel_r,
      output reg [7:0] io_pixel_out_pixel_g,
      output reg [7:0] io_pixel_out_pixel_b,
      input  [3:0] io_pattern_nr,
      input  [7:0] io_const_color_r,
      input  [7:0] io_const_color_g,
      input  [7:0] io_const_color_b,
      input   toplevel_vo_clk,
      input   toplevel_vo_reset_);
  wire [13:0] _zz_VideoTestPattern_1_;
  wire [13:0] _zz_VideoTestPattern_2_;
  wire [13:0] _zz_VideoTestPattern_3_;
  wire [13:0] _zz_VideoTestPattern_4_;
  wire [14:0] _zz_VideoTestPattern_5_;
  wire [14:0] _zz_VideoTestPattern_6_;
  wire [12:0] _zz_VideoTestPattern_7_;
  wire [12:0] _zz_VideoTestPattern_8_;
  wire [12:0] _zz_VideoTestPattern_9_;
  wire [12:0] _zz_VideoTestPattern_10_;
  wire [13:0] _zz_VideoTestPattern_11_;
  wire [13:0] _zz_VideoTestPattern_12_;
  wire [7:0] _zz_VideoTestPattern_13_;
  wire [7:0] _zz_VideoTestPattern_14_;
  wire [7:0] _zz_VideoTestPattern_15_;
  wire [10:0] _zz_VideoTestPattern_16_;
  wire [11:0] _zz_VideoTestPattern_17_;
  reg [11:0] col_cntr;
  reg [10:0] line_cntr;
  wire [11:0] h_active_div4;
  wire [10:0] v_active_div4;
  wire  h1;
  wire  h2;
  wire  h3;
  wire  h4;
  wire  v1;
  wire  v2;
  wire  v3;
  wire  v4;
  assign _zz_VideoTestPattern_1_ = {2'd0, col_cntr};
  assign _zz_VideoTestPattern_2_ = (h_active_div4 * (2'b10));
  assign _zz_VideoTestPattern_3_ = {2'd0, col_cntr};
  assign _zz_VideoTestPattern_4_ = (h_active_div4 * (2'b11));
  assign _zz_VideoTestPattern_5_ = {3'd0, col_cntr};
  assign _zz_VideoTestPattern_6_ = (h_active_div4 * (3'b100));
  assign _zz_VideoTestPattern_7_ = {2'd0, line_cntr};
  assign _zz_VideoTestPattern_8_ = (v_active_div4 * (2'b10));
  assign _zz_VideoTestPattern_9_ = {2'd0, line_cntr};
  assign _zz_VideoTestPattern_10_ = (v_active_div4 * (2'b11));
  assign _zz_VideoTestPattern_11_ = {3'd0, line_cntr};
  assign _zz_VideoTestPattern_12_ = (v_active_div4 * (3'b100));
  assign _zz_VideoTestPattern_13_ = (col_cntr[7 : 0] + line_cntr[7 : 0]);
  assign _zz_VideoTestPattern_14_ = (col_cntr[7 : 0] + line_cntr[7 : 0]);
  assign _zz_VideoTestPattern_15_ = (col_cntr[7 : 0] + line_cntr[7 : 0]);
  assign _zz_VideoTestPattern_16_ = (line_cntr <<< 3);
  assign _zz_VideoTestPattern_17_ = (col_cntr <<< 3);
  assign h_active_div4 = (io_timings_h_active >>> 2);
  assign v_active_div4 = (io_timings_v_active >>> 2);
  assign h1 = (col_cntr < h_active_div4);
  assign h2 = (_zz_VideoTestPattern_1_ < _zz_VideoTestPattern_2_);
  assign h3 = (_zz_VideoTestPattern_3_ < _zz_VideoTestPattern_4_);
  assign h4 = (_zz_VideoTestPattern_5_ < _zz_VideoTestPattern_6_);
  assign v1 = (line_cntr < v_active_div4);
  assign v2 = (_zz_VideoTestPattern_7_ < _zz_VideoTestPattern_8_);
  assign v3 = (_zz_VideoTestPattern_9_ < _zz_VideoTestPattern_10_);
  assign v4 = (_zz_VideoTestPattern_11_ < _zz_VideoTestPattern_12_);
  always @ (posedge toplevel_vo_clk) begin
    if(!toplevel_vo_reset_) begin
      col_cntr <= (12'b000000000000);
      line_cntr <= (11'b00000000000);
    end else begin
      if(io_pixel_in_vsync)begin
        line_cntr <= (11'b00000000000);
        col_cntr <= (12'b000000000000);
      end else begin
        if(io_pixel_in_req)begin
          if(io_pixel_in_eof)begin
            line_cntr <= (11'b00000000000);
            col_cntr <= (12'b000000000000);
          end else begin
            if(io_pixel_in_eol)begin
              line_cntr <= (line_cntr + (11'b00000000001));
              col_cntr <= (12'b000000000000);
            end else begin
              col_cntr <= (col_cntr + (12'b000000000001));
            end
          end
        end
      end
    end
  end

  always @ (posedge toplevel_vo_clk) begin
    io_pixel_out_vsync <= io_pixel_in_vsync;
    io_pixel_out_req <= io_pixel_in_req;
    io_pixel_out_eol <= io_pixel_in_eol;
    io_pixel_out_eof <= io_pixel_in_eof;
    io_pixel_out_pixel_r <= io_pixel_in_pixel_r;
    io_pixel_out_pixel_g <= io_pixel_in_pixel_g;
    io_pixel_out_pixel_b <= io_pixel_in_pixel_b;
    case(io_pattern_nr)
      4'b0000 : begin
        io_pixel_out_pixel_r <= io_const_color_r;
        io_pixel_out_pixel_g <= io_const_color_g;
        io_pixel_out_pixel_b <= io_const_color_b;
      end
      4'b0001 : begin
        io_pixel_out_pixel_r <= _zz_VideoTestPattern_13_;
        io_pixel_out_pixel_g <= (8'b00000000);
        io_pixel_out_pixel_b <= (8'b00000000);
      end
      4'b0010 : begin
        io_pixel_out_pixel_r <= (8'b00000000);
        io_pixel_out_pixel_g <= _zz_VideoTestPattern_14_;
        io_pixel_out_pixel_b <= (8'b00000000);
      end
      4'b0011 : begin
        io_pixel_out_pixel_r <= (8'b00000000);
        io_pixel_out_pixel_g <= (8'b00000000);
        io_pixel_out_pixel_b <= _zz_VideoTestPattern_15_;
      end
      4'b0100 : begin
        if(h1)begin
          io_pixel_out_pixel_r <= (8'b11111111);
          io_pixel_out_pixel_g <= (8'b00000000);
          io_pixel_out_pixel_b <= (8'b00000000);
        end else begin
          if(h2)begin
            io_pixel_out_pixel_r <= (8'b00000000);
            io_pixel_out_pixel_g <= (8'b11111111);
            io_pixel_out_pixel_b <= (8'b00000000);
          end else begin
            if(h3)begin
              io_pixel_out_pixel_r <= (8'b00000000);
              io_pixel_out_pixel_g <= (8'b00000000);
              io_pixel_out_pixel_b <= (8'b11111111);
            end else begin
              io_pixel_out_pixel_r <= (8'b11111111);
              io_pixel_out_pixel_g <= (8'b11111111);
              io_pixel_out_pixel_b <= (8'b11111111);
            end
          end
        end
      end
      4'b0101 : begin
        if(v1)begin
          io_pixel_out_pixel_r <= (8'b11111111);
          io_pixel_out_pixel_g <= (8'b00000000);
          io_pixel_out_pixel_b <= (8'b00000000);
        end else begin
          if(v2)begin
            io_pixel_out_pixel_r <= (8'b00000000);
            io_pixel_out_pixel_g <= (8'b11111111);
            io_pixel_out_pixel_b <= (8'b00000000);
          end else begin
            if(v3)begin
              io_pixel_out_pixel_r <= (8'b00000000);
              io_pixel_out_pixel_g <= (8'b00000000);
              io_pixel_out_pixel_b <= (8'b11111111);
            end else begin
              io_pixel_out_pixel_r <= (8'b11111111);
              io_pixel_out_pixel_g <= (8'b11111111);
              io_pixel_out_pixel_b <= (8'b11111111);
            end
          end
        end
      end
      4'b0110 : begin
        io_pixel_out_pixel_r <= {line_cntr[3 : 0],col_cntr[3 : 0]};
        io_pixel_out_pixel_g <= _zz_VideoTestPattern_16_[7 : 0];
        io_pixel_out_pixel_b <= _zz_VideoTestPattern_17_[7 : 0];
      end
      default : begin
      end
    endcase
  end

endmodule

module VideoTxtGen (
      input   io_pixel_in_vsync,
      input   io_pixel_in_req,
      input   io_pixel_in_eol,
      input   io_pixel_in_eof,
      input  [7:0] io_pixel_in_pixel_r,
      input  [7:0] io_pixel_in_pixel_g,
      input  [7:0] io_pixel_in_pixel_b,
      output  io_pixel_out_vsync,
      output  io_pixel_out_req,
      output  io_pixel_out_eol,
      output  io_pixel_out_eof,
      output reg [7:0] io_pixel_out_pixel_r,
      output reg [7:0] io_pixel_out_pixel_g,
      output reg [7:0] io_pixel_out_pixel_b,
      input   io_txt_buf_wr,
      input   io_txt_buf_rd,
      input  [12:0] io_txt_buf_addr,
      input  [7:0] io_txt_buf_wr_data,
      output [7:0] io_txt_buf_rd_data,
      input   toplevel_vo_clk,
      input   toplevel_vo_reset_,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg [7:0] _zz_VideoTxtGen_5_;
  reg [7:0] _zz_VideoTxtGen_6_;
  reg [7:0] _zz_VideoTxtGen_7_;
  wire [12:0] _zz_VideoTxtGen_8_;
  wire [7:0] _zz_VideoTxtGen_9_;
  wire [11:0] _zz_VideoTxtGen_10_;
  wire [8:0] _zz_VideoTxtGen_11_;
  wire [11:0] _zz_VideoTxtGen_12_;
  wire [12:0] _zz_VideoTxtGen_13_;
  wire [3:0] _zz_VideoTxtGen_14_;
  wire [7:0] _zz_VideoTxtGen_15_;
  reg [11:0] pix_x;
  reg [10:0] pix_y;
  reg [7:0] char_x;
  reg [6:0] char_y;
  reg [3:0] char_sub_x;
  reg [3:0] char_sub_y;
  reg [12:0] txt_buf_addr_sol;
  wire [12:0] txt_buf_addr;
  wire  txt_buf_rd_p0;
  wire [12:0] _zz_VideoTxtGen_1_;
  wire [7:0] cur_char;
  wire  _zz_VideoTxtGen_2_;
  wire [12:0] _zz_VideoTxtGen_3_;
  wire [7:0] _zz_VideoTxtGen_4_;
  reg  txt_buf_rd_p1;
  reg [3:0] char_sub_x_p1;
  wire [11:0] bitmap_lsb_addr;
  wire [11:0] bitmap_msb_addr;
  wire [11:0] bitmap_addr;
  wire [7:0] bitmap_byte;
  reg  txt_buf_rd_p2;
  reg [3:0] char_sub_x_p2;
  wire  bitmap_pixel;
  reg  io_pixel_in_regNext_vsync;
  reg  io_pixel_in_regNext_req;
  reg  io_pixel_in_regNext_eol;
  reg  io_pixel_in_regNext_eof;
  reg [7:0] io_pixel_in_regNext_pixel_r;
  reg [7:0] io_pixel_in_regNext_pixel_g;
  reg [7:0] io_pixel_in_regNext_pixel_b;
  reg  pixel_in_p2_vsync;
  reg  pixel_in_p2_req;
  reg  pixel_in_p2_eol;
  reg  pixel_in_p2_eof;
  reg [7:0] pixel_in_p2_pixel_r;
  reg [7:0] pixel_in_p2_pixel_g;
  reg [7:0] pixel_in_p2_pixel_b;
  reg [7:0] u_txt_buf [0:8191];
  reg [7:0] u_font_bitmap_ram [0:4095];
  assign _zz_VideoTxtGen_8_ = {5'd0, char_x};
  assign _zz_VideoTxtGen_9_ = (cur_char & (8'b00001111));
  assign _zz_VideoTxtGen_10_ = {4'd0, _zz_VideoTxtGen_9_};
  assign _zz_VideoTxtGen_11_ = (char_sub_y[3 : 0] * (5'b10000));
  assign _zz_VideoTxtGen_12_ = {3'd0, _zz_VideoTxtGen_11_};
  assign _zz_VideoTxtGen_13_ = (_zz_VideoTxtGen_14_ * (9'b100000000));
  assign _zz_VideoTxtGen_14_ = (cur_char >>> 4);
  assign _zz_VideoTxtGen_15_ = (bitmap_byte >>> ((3'b111) ^ char_sub_x_p2[2 : 0]));
  always @ (posedge toplevel_main_clk) begin
    if(_zz_VideoTxtGen_2_ && io_txt_buf_wr ) begin
      u_txt_buf[_zz_VideoTxtGen_3_] <= _zz_VideoTxtGen_4_;
    end
    if(_zz_VideoTxtGen_2_) begin
      _zz_VideoTxtGen_6_ <= u_txt_buf[_zz_VideoTxtGen_3_];
    end
  end

  always @ (posedge toplevel_vo_clk) begin
    if(txt_buf_rd_p0) begin
      _zz_VideoTxtGen_5_ <= u_txt_buf[_zz_VideoTxtGen_1_];
    end
  end

  initial begin
    $readmemb("Pano.v_toplevel_core_u_pano_core_vo_area_u_txt_gen_u_font_bitmap_ram.bin",u_font_bitmap_ram);
  end
  always @ (posedge toplevel_vo_clk) begin
    if(txt_buf_rd_p1) begin
      _zz_VideoTxtGen_7_ <= u_font_bitmap_ram[bitmap_addr];
    end
  end

  assign txt_buf_addr = (txt_buf_addr_sol + _zz_VideoTxtGen_8_);
  assign txt_buf_rd_p0 = (((char_x < (8'b10000010)) && (char_y < (7'b0111100))) && io_pixel_in_req);
  assign _zz_VideoTxtGen_1_ = txt_buf_addr;
  assign cur_char = _zz_VideoTxtGen_5_;
  assign _zz_VideoTxtGen_2_ = (io_txt_buf_wr || io_txt_buf_rd);
  assign _zz_VideoTxtGen_3_ = io_txt_buf_addr;
  assign _zz_VideoTxtGen_4_ = io_txt_buf_wr_data;
  assign io_txt_buf_rd_data = _zz_VideoTxtGen_6_;
  assign bitmap_lsb_addr = (_zz_VideoTxtGen_10_ + _zz_VideoTxtGen_12_);
  assign bitmap_msb_addr = _zz_VideoTxtGen_13_[11:0];
  assign bitmap_addr = (bitmap_msb_addr + bitmap_lsb_addr);
  assign bitmap_byte = _zz_VideoTxtGen_7_;
  assign bitmap_pixel = (_zz_VideoTxtGen_15_[0] && (! char_sub_x_p2[3]));
  assign io_pixel_out_vsync = pixel_in_p2_vsync;
  assign io_pixel_out_req = pixel_in_p2_req;
  assign io_pixel_out_eol = pixel_in_p2_eol;
  assign io_pixel_out_eof = pixel_in_p2_eof;
  always @ (*) begin
    io_pixel_out_pixel_r = pixel_in_p2_pixel_r;
    io_pixel_out_pixel_g = pixel_in_p2_pixel_g;
    io_pixel_out_pixel_b = pixel_in_p2_pixel_b;
    if((bitmap_pixel && txt_buf_rd_p2))begin
      io_pixel_out_pixel_r = (8'b11111111);
      io_pixel_out_pixel_g = (8'b11111111);
      io_pixel_out_pixel_b = (8'b11111111);
    end
  end

  always @ (posedge toplevel_vo_clk) begin
    if(!toplevel_vo_reset_) begin
      pix_x <= (12'b000000000000);
      pix_y <= (11'b00000000000);
      char_x <= (8'b00000000);
      char_y <= (7'b0000000);
      char_sub_x <= (4'b0000);
      char_sub_y <= (4'b0000);
      txt_buf_addr_sol <= (13'b0000000000000);
    end else begin
      if((io_pixel_in_vsync || (io_pixel_in_req && io_pixel_in_eof)))begin
        pix_x <= (12'b000000000000);
        pix_y <= (11'b00000000000);
        char_x <= (8'b00000000);
        char_y <= (7'b0000000);
        char_sub_x <= (4'b0000);
        char_sub_y <= (4'b0000);
        txt_buf_addr_sol <= (13'b0000000000000);
      end else begin
        if(io_pixel_in_req)begin
          if(io_pixel_in_eol)begin
            pix_x <= (12'b000000000000);
            pix_y <= (pix_y + (11'b00000000001));
            char_x <= (8'b00000000);
            char_sub_x <= (4'b0000);
            if((char_sub_y == (4'b1111)))begin
              char_y <= (char_y + (7'b0000001));
              char_sub_y <= (4'b0000);
              txt_buf_addr_sol <= (txt_buf_addr_sol + (13'b0000010000010));
            end else begin
              char_sub_y <= (char_sub_y + (4'b0001));
            end
          end else begin
            pix_x <= (pix_x + (12'b000000000001));
            if((char_sub_x == (4'b1000)))begin
              char_x <= (char_x + (8'b00000001));
              char_sub_x <= (4'b0000);
            end else begin
              char_sub_x <= (char_sub_x + (4'b0001));
            end
          end
        end
      end
    end
  end

  always @ (posedge toplevel_vo_clk) begin
    txt_buf_rd_p1 <= txt_buf_rd_p0;
    char_sub_x_p1 <= char_sub_x;
    txt_buf_rd_p2 <= txt_buf_rd_p1;
    char_sub_x_p2 <= char_sub_x_p1;
    io_pixel_in_regNext_vsync <= io_pixel_in_vsync;
    io_pixel_in_regNext_req <= io_pixel_in_req;
    io_pixel_in_regNext_eol <= io_pixel_in_eol;
    io_pixel_in_regNext_eof <= io_pixel_in_eof;
    io_pixel_in_regNext_pixel_r <= io_pixel_in_pixel_r;
    io_pixel_in_regNext_pixel_g <= io_pixel_in_pixel_g;
    io_pixel_in_regNext_pixel_b <= io_pixel_in_pixel_b;
    pixel_in_p2_vsync <= io_pixel_in_regNext_vsync;
    pixel_in_p2_req <= io_pixel_in_regNext_req;
    pixel_in_p2_eol <= io_pixel_in_regNext_eol;
    pixel_in_p2_eof <= io_pixel_in_regNext_eof;
    pixel_in_p2_pixel_r <= io_pixel_in_regNext_pixel_r;
    pixel_in_p2_pixel_g <= io_pixel_in_regNext_pixel_g;
    pixel_in_p2_pixel_b <= io_pixel_in_regNext_pixel_b;
  end

endmodule

module VideoOut (
      input  [11:0] io_timings_h_active,
      input  [8:0] io_timings_h_fp,
      input  [8:0] io_timings_h_sync,
      input  [8:0] io_timings_h_bp,
      input   io_timings_h_sync_positive,
      input  [11:0] io_timings_h_total_m1,
      input  [10:0] io_timings_v_active,
      input  [8:0] io_timings_v_fp,
      input  [8:0] io_timings_v_sync,
      input  [8:0] io_timings_v_bp,
      input   io_timings_v_sync_positive,
      input  [11:0] io_timings_v_total_m1,
      input   io_pixel_in_vsync,
      input   io_pixel_in_req,
      input   io_pixel_in_eol,
      input   io_pixel_in_eof,
      input  [7:0] io_pixel_in_pixel_r,
      input  [7:0] io_pixel_in_pixel_g,
      input  [7:0] io_pixel_in_pixel_b,
      output reg  io_vga_out_vsync,
      output reg  io_vga_out_hsync,
      output reg  io_vga_out_blank_,
      output reg  io_vga_out_de,
      output reg [7:0] io_vga_out_r,
      output reg [7:0] io_vga_out_g,
      output reg [7:0] io_vga_out_b,
      input   toplevel_vo_clk,
      input   toplevel_vo_reset_);
  wire [8:0] _zz_VideoOut_1_;
  wire [8:0] _zz_VideoOut_2_;
  wire [10:0] _zz_VideoOut_3_;
  wire [11:0] _zz_VideoOut_4_;
  wire [11:0] _zz_VideoOut_5_;
  wire [8:0] _zz_VideoOut_6_;
  wire [11:0] _zz_VideoOut_7_;
  wire [10:0] _zz_VideoOut_8_;
  wire [8:0] _zz_VideoOut_9_;
  wire [10:0] _zz_VideoOut_10_;
  reg [11:0] h_cntr;
  reg [10:0] v_cntr;
  wire [8:0] h_blank;
  wire [8:0] v_blank;
  wire  blank;
  assign _zz_VideoOut_1_ = (io_timings_h_fp + io_timings_h_sync);
  assign _zz_VideoOut_2_ = (io_timings_v_fp + io_timings_v_sync);
  assign _zz_VideoOut_3_ = {2'd0, v_blank};
  assign _zz_VideoOut_4_ = {3'd0, h_blank};
  assign _zz_VideoOut_5_ = {3'd0, io_timings_h_fp};
  assign _zz_VideoOut_6_ = (io_timings_h_fp + io_timings_h_sync);
  assign _zz_VideoOut_7_ = {3'd0, _zz_VideoOut_6_};
  assign _zz_VideoOut_8_ = {2'd0, io_timings_v_fp};
  assign _zz_VideoOut_9_ = (io_timings_v_fp + io_timings_v_sync);
  assign _zz_VideoOut_10_ = {2'd0, _zz_VideoOut_9_};
  assign h_blank = (_zz_VideoOut_1_ + io_timings_h_bp);
  assign v_blank = (_zz_VideoOut_2_ + io_timings_v_bp);
  assign blank = ((v_cntr < _zz_VideoOut_3_) || (h_cntr < _zz_VideoOut_4_));
  always @ (posedge toplevel_vo_clk) begin
    if(!toplevel_vo_reset_) begin
      io_vga_out_vsync <= 1'b0;
      io_vga_out_hsync <= 1'b0;
      io_vga_out_blank_ <= 1'b0;
      io_vga_out_de <= 1'b0;
      io_vga_out_r <= (8'b00000000);
      io_vga_out_g <= (8'b00000000);
      io_vga_out_b <= (8'b00000000);
      h_cntr <= (12'b000000000000);
      v_cntr <= (11'b00000000000);
    end else begin
      if((io_pixel_in_req && io_pixel_in_eof))begin
        h_cntr <= (12'b000000000000);
        v_cntr <= (11'b00000000000);
      end else begin
        if((h_cntr == io_timings_h_total_m1))begin
          h_cntr <= (12'b000000000000);
          v_cntr <= (v_cntr + (11'b00000000001));
        end else begin
          h_cntr <= (h_cntr + (12'b000000000001));
        end
      end
      io_vga_out_blank_ <= (! blank);
      io_vga_out_de <= (! blank);
      io_vga_out_hsync <= (((_zz_VideoOut_5_ <= h_cntr) && (h_cntr < _zz_VideoOut_7_)) ^ (! io_timings_h_sync_positive));
      io_vga_out_vsync <= (((_zz_VideoOut_8_ <= v_cntr) && (v_cntr < _zz_VideoOut_10_)) ^ (! io_timings_v_sync_positive));
      io_vga_out_r <= (blank ? (8'b00000000) : io_pixel_in_pixel_r);
      io_vga_out_g <= (blank ? (8'b00000000) : io_pixel_in_pixel_g);
      io_vga_out_b <= (blank ? (8'b00000000) : io_pixel_in_pixel_b);
    end
  end

endmodule

module GmiiCtrl (
      input  [4:0] io_apb_PADDR,
      input  [0:0] io_apb_PSEL,
      input   io_apb_PENABLE,
      output  io_apb_PREADY,
      input   io_apb_PWRITE,
      input  [31:0] io_apb_PWDATA,
      output reg [31:0] io_apb_PRDATA,
      output  io_apb_PSLVERROR,
      input   io_gmii_rx_clk,
      input   io_gmii_rx_dv,
      input   io_gmii_rx_er,
      input  [7:0] io_gmii_rx_d,
      input   io_gmii_tx_gclk,
      input   io_gmii_tx_clk,
      output  io_gmii_tx_en,
      output  io_gmii_tx_er,
      output [7:0] io_gmii_tx_d,
      input   io_gmii_col,
      input   io_gmii_crs,
      output  io_gmii_mdio_mdc,
      input   io_gmii_mdio_mdio_read,
      output  io_gmii_mdio_mdio_write,
      output  io_gmii_mdio_mdio_writeEnable,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire  _zz_GmiiCtrl_5_;
  wire  u_gmii_rx_io_rx_fifo_rd_valid;
  wire [9:0] u_gmii_rx_io_rx_fifo_rd_payload;
  wire [15:0] u_gmii_rx_io_rx_fifo_rd_count;
  wire  u_gmii_tx_io_tx_en;
  wire  u_gmii_tx_io_tx_er;
  wire [7:0] u_gmii_tx_io_tx_d;
  wire [0:0] _zz_GmiiCtrl_6_;
  wire [0:0] _zz_GmiiCtrl_7_;
  wire [0:0] _zz_GmiiCtrl_8_;
  wire  ctrl_askWrite;
  wire  ctrl_askRead;
  wire  ctrl_doWrite;
  wire  ctrl_doRead;
  reg  _zz_GmiiCtrl_1_;
  reg  _zz_GmiiCtrl_2_;
  reg  _zz_GmiiCtrl_3_;
  wire  cpu_rx_fifo_rd_valid;
  wire  cpu_rx_fifo_rd_ready;
  wire [9:0] cpu_rx_fifo_rd_payload;
  reg  _zz_GmiiCtrl_4_;
  assign _zz_GmiiCtrl_6_ = io_apb_PWDATA[0 : 0];
  assign _zz_GmiiCtrl_7_ = io_apb_PWDATA[1 : 1];
  assign _zz_GmiiCtrl_8_ = io_apb_PWDATA[2 : 2];
  GmiiRxCtrl u_gmii_rx ( 
    .io_rx_clk(io_gmii_rx_clk),
    .io_rx_dv(io_gmii_rx_dv),
    .io_rx_er(io_gmii_rx_er),
    .io_rx_d(io_gmii_rx_d),
    .io_rx_fifo_rd_valid(u_gmii_rx_io_rx_fifo_rd_valid),
    .io_rx_fifo_rd_ready(_zz_GmiiCtrl_5_),
    .io_rx_fifo_rd_payload(u_gmii_rx_io_rx_fifo_rd_payload),
    .io_rx_fifo_rd_count(u_gmii_rx_io_rx_fifo_rd_count),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  GmiiTxCtrl u_gmii_tx ( 
    .io_tx_gclk(io_gmii_tx_gclk),
    .io_tx_clk(io_gmii_tx_clk),
    .io_tx_en(u_gmii_tx_io_tx_en),
    .io_tx_er(u_gmii_tx_io_tx_er),
    .io_tx_d(u_gmii_tx_io_tx_d) 
  );
  assign io_gmii_tx_en = u_gmii_tx_io_tx_en;
  assign io_gmii_tx_er = u_gmii_tx_io_tx_er;
  assign io_gmii_tx_d = u_gmii_tx_io_tx_d;
  assign io_apb_PREADY = 1'b1;
  always @ (*) begin
    io_apb_PRDATA = (32'b00000000000000000000000000000000);
    _zz_GmiiCtrl_4_ = 1'b0;
    case(io_apb_PADDR)
      5'b00000 : begin
        io_apb_PRDATA[0 : 0] = _zz_GmiiCtrl_1_;
        io_apb_PRDATA[1 : 1] = _zz_GmiiCtrl_2_;
        io_apb_PRDATA[2 : 2] = _zz_GmiiCtrl_3_;
        io_apb_PRDATA[3 : 3] = io_gmii_mdio_mdio_read;
      end
      5'b00100 : begin
        if(ctrl_doRead)begin
          _zz_GmiiCtrl_4_ = 1'b1;
        end
        io_apb_PRDATA[16 : 16] = u_gmii_rx_io_rx_fifo_rd_valid;
        io_apb_PRDATA[9 : 0] = u_gmii_rx_io_rx_fifo_rd_payload;
      end
      5'b01000 : begin
        io_apb_PRDATA[15 : 0] = u_gmii_rx_io_rx_fifo_rd_count;
      end
      default : begin
      end
    endcase
  end

  assign io_apb_PSLVERROR = 1'b0;
  assign ctrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
  assign ctrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (! io_apb_PWRITE));
  assign ctrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
  assign ctrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
  assign io_gmii_mdio_mdc = _zz_GmiiCtrl_1_;
  assign io_gmii_mdio_mdio_write = _zz_GmiiCtrl_2_;
  assign io_gmii_mdio_mdio_writeEnable = _zz_GmiiCtrl_3_;
  assign _zz_GmiiCtrl_5_ = (_zz_GmiiCtrl_4_ && u_gmii_rx_io_rx_fifo_rd_valid);
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      _zz_GmiiCtrl_1_ <= 1'b0;
      _zz_GmiiCtrl_2_ <= 1'b0;
      _zz_GmiiCtrl_3_ <= 1'b0;
    end else begin
      case(io_apb_PADDR)
        5'b00000 : begin
          if(ctrl_doWrite)begin
            _zz_GmiiCtrl_1_ <= _zz_GmiiCtrl_6_[0];
            _zz_GmiiCtrl_2_ <= _zz_GmiiCtrl_7_[0];
            _zz_GmiiCtrl_3_ <= _zz_GmiiCtrl_8_[0];
          end
        end
        5'b00100 : begin
        end
        5'b01000 : begin
        end
        default : begin
        end
      endcase
    end
  end

endmodule

module UlpiCtrl (
      input   io_ulpi_clk,
      input  [7:0] io_ulpi_data_read,
      output [7:0] io_ulpi_data_write,
      output [7:0] io_ulpi_data_writeEnable,
      input   io_ulpi_direction,
      output  io_ulpi_stp,
      input   io_ulpi_nxt,
      output  io_ulpi_reset,
      input   io_tx_start,
      input   io_tx_data_valid,
      output reg  io_tx_data_ready,
      input  [7:0] io_tx_data_payload,
      output reg  io_rx_data_valid,
      output reg [8:0] io_rx_data_payload,
      input   io_reg_rd,
      input   io_reg_wr,
      input  [5:0] io_reg_addr,
      input  [7:0] io_reg_wr_data,
      output reg [7:0] io_reg_rd_data,
      output reg  io_reg_done);
  wire  _zz_UlpiCtrl_1_;
  wire  _zz_UlpiCtrl_2_;
  wire  _zz_UlpiCtrl_3_;
  wire  _zz_UlpiCtrl_4_;
  reg `UlpiState_defaultEncoding_type ulpi_domain_cur_state = `UlpiState_defaultEncoding_WaitIdle;
  reg  ulpi_domain_ulpi_stp = 1'b0;
  reg [7:0] ulpi_domain_ulpi_data_out = (8'b00000000);
  reg [7:0] ulpi_domain_rx_cmd = (8'b00000000);
  reg  ulpi_domain_direction_d = 1'b1;
  reg  ulpi_domain_rx_data_seen = 1'b0;
  assign _zz_UlpiCtrl_1_ = (io_tx_start && io_tx_data_valid);
  assign _zz_UlpiCtrl_2_ = (! io_tx_data_valid);
  assign _zz_UlpiCtrl_3_ = (! io_ulpi_direction);
  assign _zz_UlpiCtrl_4_ = (! io_ulpi_nxt);
  assign io_ulpi_reset = 1'b0;
  assign io_ulpi_data_writeEnable = ((! io_ulpi_direction) ? (8'b11111111) : (8'b00000000));
  assign io_ulpi_stp = ulpi_domain_ulpi_stp;
  assign io_ulpi_data_write = ulpi_domain_ulpi_data_out;
  always @ (*) begin
    io_reg_done = 1'b0;
    io_reg_rd_data = (8'b00000000);
    io_rx_data_valid = 1'b0;
    io_rx_data_payload = (9'b000000000);
    io_tx_data_ready = 1'b0;
    case(ulpi_domain_cur_state)
      `UlpiState_defaultEncoding_WaitIdle : begin
      end
      `UlpiState_defaultEncoding_Idle : begin
        if(! io_ulpi_direction) begin
          if(! io_reg_wr) begin
            if(! io_reg_rd) begin
              if(_zz_UlpiCtrl_1_)begin
                io_tx_data_ready = 1'b1;
              end
            end
          end
        end
      end
      `UlpiState_defaultEncoding_Tx : begin
        if(! io_ulpi_direction) begin
          if(io_ulpi_nxt)begin
            if(! _zz_UlpiCtrl_2_) begin
              io_tx_data_ready = 1'b1;
            end
          end
        end
      end
      `UlpiState_defaultEncoding_Rx : begin
        if(_zz_UlpiCtrl_3_)begin
          io_rx_data_valid = ulpi_domain_rx_data_seen;
          io_rx_data_payload = {ulpi_domain_rx_data_seen,(8'b00000000)};
        end else begin
          if(_zz_UlpiCtrl_4_)begin
            if((io_ulpi_data_read[5 : 0] == (6'b000000)))begin
              io_rx_data_valid = ulpi_domain_rx_data_seen;
              io_rx_data_payload = {ulpi_domain_rx_data_seen,(8'b00000000)};
            end
          end else begin
            io_rx_data_valid = 1'b1;
            io_rx_data_payload = {1'b0,io_ulpi_data_read};
          end
        end
      end
      `UlpiState_defaultEncoding_RegWrAddr : begin
      end
      `UlpiState_defaultEncoding_RegWrData : begin
      end
      `UlpiState_defaultEncoding_RegWrStp : begin
        if(! io_ulpi_direction) begin
          io_reg_done = 1'b1;
        end
      end
      `UlpiState_defaultEncoding_RegRdAddr : begin
      end
      `UlpiState_defaultEncoding_RegRdTurn : begin
      end
      default : begin
        io_reg_done = 1'b1;
        io_reg_rd_data = io_ulpi_data_read;
      end
    endcase
  end

  always @ (posedge io_ulpi_clk) begin
    ulpi_domain_direction_d <= io_ulpi_direction;
    case(ulpi_domain_cur_state)
      `UlpiState_defaultEncoding_WaitIdle : begin
        ulpi_domain_ulpi_data_out <= (8'b00000000);
        if((! io_ulpi_direction))begin
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Idle;
        end
      end
      `UlpiState_defaultEncoding_Idle : begin
        ulpi_domain_ulpi_data_out <= (8'b00000000);
        ulpi_domain_ulpi_stp <= 1'b0;
        if(io_ulpi_direction)begin
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Rx;
          ulpi_domain_rx_data_seen <= 1'b0;
        end else begin
          if(io_reg_wr)begin
            ulpi_domain_ulpi_data_out <= {(2'b10),io_reg_addr};
            ulpi_domain_cur_state <= `UlpiState_defaultEncoding_RegWrAddr;
          end else begin
            if(io_reg_rd)begin
              ulpi_domain_ulpi_data_out <= {(2'b11),io_reg_addr};
              ulpi_domain_cur_state <= `UlpiState_defaultEncoding_RegRdAddr;
            end else begin
              if(_zz_UlpiCtrl_1_)begin
                ulpi_domain_ulpi_data_out <= {(2'b01),io_tx_data_payload[5 : 0]};
                ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Tx;
              end
            end
          end
        end
      end
      `UlpiState_defaultEncoding_Tx : begin
        if(io_ulpi_direction)begin
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Rx;
        end else begin
          if(io_ulpi_nxt)begin
            if(_zz_UlpiCtrl_2_)begin
              ulpi_domain_ulpi_data_out <= (8'b00000000);
              ulpi_domain_ulpi_stp <= 1'b1;
              ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Idle;
            end else begin
              ulpi_domain_ulpi_data_out <= io_tx_data_payload;
              ulpi_domain_ulpi_stp <= 1'b0;
            end
          end
        end
      end
      `UlpiState_defaultEncoding_Rx : begin
        if(_zz_UlpiCtrl_3_)begin
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Idle;
        end else begin
          if(_zz_UlpiCtrl_4_)begin
            ulpi_domain_rx_cmd <= io_ulpi_data_read;
          end else begin
            ulpi_domain_rx_data_seen <= 1'b1;
          end
        end
      end
      `UlpiState_defaultEncoding_RegWrAddr : begin
        if(io_ulpi_direction)begin
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Rx;
        end else begin
          if(io_ulpi_nxt)begin
            ulpi_domain_ulpi_data_out <= io_reg_wr_data;
            ulpi_domain_cur_state <= `UlpiState_defaultEncoding_RegWrData;
          end
        end
      end
      `UlpiState_defaultEncoding_RegWrData : begin
        if(io_ulpi_direction)begin
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Rx;
        end else begin
          if(io_ulpi_nxt)begin
            ulpi_domain_ulpi_data_out <= (8'b00000000);
            ulpi_domain_ulpi_stp <= 1'b1;
            ulpi_domain_cur_state <= `UlpiState_defaultEncoding_RegWrStp;
          end
        end
      end
      `UlpiState_defaultEncoding_RegWrStp : begin
        if(io_ulpi_direction)begin
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Rx;
        end else begin
          ulpi_domain_ulpi_data_out <= (8'b00000000);
          ulpi_domain_ulpi_stp <= 1'b0;
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Idle;
        end
      end
      `UlpiState_defaultEncoding_RegRdAddr : begin
        if(io_ulpi_direction)begin
          ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Rx;
        end else begin
          if(io_ulpi_nxt)begin
            ulpi_domain_cur_state <= `UlpiState_defaultEncoding_RegRdTurn;
          end
        end
      end
      `UlpiState_defaultEncoding_RegRdTurn : begin
        ulpi_domain_cur_state <= `UlpiState_defaultEncoding_RegRdData;
      end
      default : begin
        ulpi_domain_cur_state <= `UlpiState_defaultEncoding_Idle;
      end
    endcase
  end

endmodule

module StreamFifoCC_1_ (
      input   io_push_valid,
      output  io_push_ready,
      input   io_push_payload,
      output  io_pop_valid,
      input   io_pop_ready,
      output  io_pop_payload,
      output [1:0] io_pushOccupancy,
      output [1:0] io_popOccupancy,
      input   toplevel_main_clk,
      input   toplevel_main_reset_,
      input   u_ulpi_ctrl_io_ulpi_clk);
  wire [1:0] _zz_StreamFifoCC_1__5_;
  wire [1:0] _zz_StreamFifoCC_1__6_;
  reg [0:0] _zz_StreamFifoCC_1__7_;
  wire [1:0] bufferCC_4__io_dataOut;
  wire [1:0] bufferCC_5__io_dataOut;
  wire [0:0] _zz_StreamFifoCC_1__8_;
  wire [1:0] _zz_StreamFifoCC_1__9_;
  wire [1:0] _zz_StreamFifoCC_1__10_;
  wire [0:0] _zz_StreamFifoCC_1__11_;
  wire [0:0] _zz_StreamFifoCC_1__12_;
  wire [1:0] _zz_StreamFifoCC_1__13_;
  wire [1:0] _zz_StreamFifoCC_1__14_;
  wire [0:0] _zz_StreamFifoCC_1__15_;
  wire [0:0] _zz_StreamFifoCC_1__16_;
  wire  _zz_StreamFifoCC_1__17_;
  reg  _zz_StreamFifoCC_1__1_;
  wire [1:0] popToPushGray;
  wire [1:0] pushToPopGray;
  reg  pushCC_pushPtr_willIncrement;
  wire  pushCC_pushPtr_willClear;
  reg [1:0] pushCC_pushPtr_valueNext;
  reg [1:0] pushCC_pushPtr_value;
  wire  pushCC_pushPtr_willOverflowIfInc;
  wire  pushCC_pushPtr_willOverflow;
  reg [1:0] pushCC_pushPtrGray;
  wire [1:0] pushCC_popPtrGray;
  wire  pushCC_full;
  wire  _zz_StreamFifoCC_1__2_;
  reg  popCC_popPtr_willIncrement;
  wire  popCC_popPtr_willClear;
  reg [1:0] popCC_popPtr_valueNext;
  reg [1:0] popCC_popPtr_value = (2'b00);
  wire  popCC_popPtr_willOverflowIfInc;
  wire  popCC_popPtr_willOverflow;
  reg [1:0] popCC_popPtrGray = (2'b00);
  wire [1:0] popCC_pushPtrGray;
  wire  popCC_empty;
  wire [1:0] _zz_StreamFifoCC_1__3_;
  wire  _zz_StreamFifoCC_1__4_;
  reg [0:0] ram [0:1];
  assign _zz_StreamFifoCC_1__8_ = pushCC_pushPtr_willIncrement;
  assign _zz_StreamFifoCC_1__9_ = {1'd0, _zz_StreamFifoCC_1__8_};
  assign _zz_StreamFifoCC_1__10_ = (pushCC_pushPtr_valueNext >>> (1'b1));
  assign _zz_StreamFifoCC_1__11_ = pushCC_pushPtr_value[0:0];
  assign _zz_StreamFifoCC_1__12_ = popCC_popPtr_willIncrement;
  assign _zz_StreamFifoCC_1__13_ = {1'd0, _zz_StreamFifoCC_1__12_};
  assign _zz_StreamFifoCC_1__14_ = (popCC_popPtr_valueNext >>> (1'b1));
  assign _zz_StreamFifoCC_1__15_ = _zz_StreamFifoCC_1__3_[0:0];
  assign _zz_StreamFifoCC_1__16_ = io_push_payload;
  assign _zz_StreamFifoCC_1__17_ = 1'b1;
  always @ (posedge toplevel_main_clk) begin
    if(_zz_StreamFifoCC_1__1_) begin
      ram[_zz_StreamFifoCC_1__11_] <= _zz_StreamFifoCC_1__16_;
    end
  end

  always @ (posedge u_ulpi_ctrl_io_ulpi_clk) begin
    if(_zz_StreamFifoCC_1__17_) begin
      _zz_StreamFifoCC_1__7_ <= ram[_zz_StreamFifoCC_1__15_];
    end
  end

  BufferCC_2_ bufferCC_4_ ( 
    .io_initial(_zz_StreamFifoCC_1__5_),
    .io_dataIn(popToPushGray),
    .io_dataOut(bufferCC_4__io_dataOut),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  BufferCC_3_ bufferCC_5_ ( 
    .io_initial(_zz_StreamFifoCC_1__6_),
    .io_dataIn(pushToPopGray),
    .io_dataOut(bufferCC_5__io_dataOut),
    .u_ulpi_ctrl_io_ulpi_clk(u_ulpi_ctrl_io_ulpi_clk) 
  );
  always @ (*) begin
    _zz_StreamFifoCC_1__1_ = 1'b0;
    pushCC_pushPtr_willIncrement = 1'b0;
    if((io_push_valid && io_push_ready))begin
      _zz_StreamFifoCC_1__1_ = 1'b1;
      pushCC_pushPtr_willIncrement = 1'b1;
    end
  end

  assign pushCC_pushPtr_willClear = 1'b0;
  assign pushCC_pushPtr_willOverflowIfInc = (pushCC_pushPtr_value == (2'b11));
  assign pushCC_pushPtr_willOverflow = (pushCC_pushPtr_willOverflowIfInc && pushCC_pushPtr_willIncrement);
  always @ (*) begin
    pushCC_pushPtr_valueNext = (pushCC_pushPtr_value + _zz_StreamFifoCC_1__9_);
    if(pushCC_pushPtr_willClear)begin
      pushCC_pushPtr_valueNext = (2'b00);
    end
  end

  assign _zz_StreamFifoCC_1__5_ = (2'b00);
  assign pushCC_popPtrGray = bufferCC_4__io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[1 : 0] == (~ pushCC_popPtrGray[1 : 0])) && 1'b1);
  assign io_push_ready = (! pushCC_full);
  assign _zz_StreamFifoCC_1__2_ = pushCC_popPtrGray[1];
  assign io_pushOccupancy = (pushCC_pushPtr_value - {_zz_StreamFifoCC_1__2_,(pushCC_popPtrGray[0] ^ _zz_StreamFifoCC_1__2_)});
  always @ (*) begin
    popCC_popPtr_willIncrement = 1'b0;
    if((io_pop_valid && io_pop_ready))begin
      popCC_popPtr_willIncrement = 1'b1;
    end
  end

  assign popCC_popPtr_willClear = 1'b0;
  assign popCC_popPtr_willOverflowIfInc = (popCC_popPtr_value == (2'b11));
  assign popCC_popPtr_willOverflow = (popCC_popPtr_willOverflowIfInc && popCC_popPtr_willIncrement);
  always @ (*) begin
    popCC_popPtr_valueNext = (popCC_popPtr_value + _zz_StreamFifoCC_1__13_);
    if(popCC_popPtr_willClear)begin
      popCC_popPtr_valueNext = (2'b00);
    end
  end

  assign _zz_StreamFifoCC_1__6_ = (2'b00);
  assign popCC_pushPtrGray = bufferCC_5__io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign io_pop_valid = (! popCC_empty);
  assign _zz_StreamFifoCC_1__3_ = popCC_popPtr_valueNext;
  assign io_pop_payload = _zz_StreamFifoCC_1__7_[0];
  assign _zz_StreamFifoCC_1__4_ = popCC_pushPtrGray[1];
  assign io_popOccupancy = ({_zz_StreamFifoCC_1__4_,(popCC_pushPtrGray[0] ^ _zz_StreamFifoCC_1__4_)} - popCC_popPtr_value);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_popPtrGray;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      pushCC_pushPtr_value <= (2'b00);
      pushCC_pushPtrGray <= (2'b00);
    end else begin
      pushCC_pushPtr_value <= pushCC_pushPtr_valueNext;
      pushCC_pushPtrGray <= (_zz_StreamFifoCC_1__10_ ^ pushCC_pushPtr_valueNext);
    end
  end

  always @ (posedge u_ulpi_ctrl_io_ulpi_clk) begin
    popCC_popPtr_value <= popCC_popPtr_valueNext;
    popCC_popPtrGray <= (_zz_StreamFifoCC_1__14_ ^ popCC_popPtr_valueNext);
  end

endmodule

module Apb3Gpio (
      input  [3:0] io_apb_PADDR,
      input  [0:0] io_apb_PSEL,
      input   io_apb_PENABLE,
      output  io_apb_PREADY,
      input   io_apb_PWRITE,
      input  [31:0] io_apb_PWDATA,
      output reg [31:0] io_apb_PRDATA,
      output  io_apb_PSLVERROR,
      input  [2:0] io_gpio_read,
      output [2:0] io_gpio_write,
      output [2:0] io_gpio_writeEnable,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  wire  ctrl_askWrite;
  wire  ctrl_askRead;
  wire  ctrl_doWrite;
  wire  ctrl_doRead;
  reg [2:0] _zz_Apb3Gpio_1_;
  reg [2:0] _zz_Apb3Gpio_2_;
  assign io_apb_PREADY = 1'b1;
  always @ (*) begin
    io_apb_PRDATA = (32'b00000000000000000000000000000000);
    case(io_apb_PADDR)
      4'b0000 : begin
        io_apb_PRDATA[2 : 0] = io_gpio_read;
      end
      4'b0100 : begin
        io_apb_PRDATA[2 : 0] = _zz_Apb3Gpio_1_;
      end
      4'b1000 : begin
        io_apb_PRDATA[2 : 0] = _zz_Apb3Gpio_2_;
      end
      default : begin
      end
    endcase
  end

  assign io_apb_PSLVERROR = 1'b0;
  assign ctrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
  assign ctrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (! io_apb_PWRITE));
  assign ctrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
  assign ctrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
  assign io_gpio_write = _zz_Apb3Gpio_1_;
  assign io_gpio_writeEnable = _zz_Apb3Gpio_2_;
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      _zz_Apb3Gpio_2_ <= (3'b000);
    end else begin
      case(io_apb_PADDR)
        4'b0000 : begin
        end
        4'b0100 : begin
        end
        4'b1000 : begin
          if(ctrl_doWrite)begin
            _zz_Apb3Gpio_2_ <= io_apb_PWDATA[2 : 0];
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @ (posedge toplevel_main_clk) begin
    case(io_apb_PADDR)
      4'b0000 : begin
      end
      4'b0100 : begin
        if(ctrl_doWrite)begin
          _zz_Apb3Gpio_1_ <= io_apb_PWDATA[2 : 0];
        end
      end
      4'b1000 : begin
      end
      default : begin
      end
    endcase
  end

endmodule

module CCGpio (
      input  [4:0] io_apb_PADDR,
      input  [0:0] io_apb_PSEL,
      input   io_apb_PENABLE,
      output  io_apb_PREADY,
      input   io_apb_PWRITE,
      input  [31:0] io_apb_PWDATA,
      output reg [31:0] io_apb_PRDATA,
      output  io_apb_PSLVERROR,
      input  [1:0] io_gpio_read,
      output [1:0] io_gpio_write,
      output [1:0] io_gpio_writeEnable,
      input   toplevel_main_clk,
      input   toplevel_main_reset_);
  reg [1:0] value;
  wire  ctrl_askWrite;
  wire  ctrl_askRead;
  wire  ctrl_doWrite;
  wire  ctrl_doRead;
  reg [1:0] _zz_CCGpio_1_;
  wire [1:0] wrBits;
  assign io_apb_PREADY = 1'b1;
  always @ (*) begin
    io_apb_PRDATA = (32'b00000000000000000000000000000000);
    case(io_apb_PADDR)
      5'b00000 : begin
        io_apb_PRDATA[1 : 0] = _zz_CCGpio_1_;
      end
      5'b00100 : begin
        io_apb_PRDATA[1 : 0] = value;
      end
      5'b01000 : begin
      end
      5'b01100 : begin
      end
      5'b10000 : begin
        io_apb_PRDATA[1 : 0] = io_gpio_read;
      end
      default : begin
      end
    endcase
  end

  assign io_apb_PSLVERROR = 1'b0;
  assign ctrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
  assign ctrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (! io_apb_PWRITE));
  assign ctrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
  assign ctrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
  assign io_gpio_writeEnable = _zz_CCGpio_1_;
  assign io_gpio_write = value;
  assign wrBits = io_apb_PWDATA[1 : 0];
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      value <= (2'b00);
      _zz_CCGpio_1_ <= (2'b00);
    end else begin
      case(io_apb_PADDR)
        5'b00000 : begin
          if(ctrl_doWrite)begin
            _zz_CCGpio_1_ <= io_apb_PWDATA[1 : 0];
          end
        end
        5'b00100 : begin
          if(ctrl_doWrite)begin
            value <= io_apb_PWDATA[1 : 0];
          end
        end
        5'b01000 : begin
          if(ctrl_doWrite)begin
            if(wrBits[0])begin
              value[0] <= 1'b1;
            end
            if(wrBits[1])begin
              value[1] <= 1'b1;
            end
          end
        end
        5'b01100 : begin
          if(ctrl_doWrite)begin
            if(wrBits[0])begin
              value[0] <= 1'b0;
            end
            if(wrBits[1])begin
              value[1] <= 1'b0;
            end
          end
        end
        5'b10000 : begin
        end
        default : begin
        end
      endcase
    end
  end

endmodule

module PanoCore (
      output  io_led_red,
      output  io_led_green,
      output  io_led_blue,
      input   io_switch_,
      input   io_dvi_ctrl_scl_read,
      output  io_dvi_ctrl_scl_write,
      output  io_dvi_ctrl_scl_writeEnable,
      input   io_dvi_ctrl_sda_read,
      output  io_dvi_ctrl_sda_write,
      output  io_dvi_ctrl_sda_writeEnable,
      input   io_gmii_rx_clk,
      input   io_gmii_rx_dv,
      input   io_gmii_rx_er,
      input  [7:0] io_gmii_rx_d,
      input   io_gmii_tx_gclk,
      input   io_gmii_tx_clk,
      output  io_gmii_tx_en,
      output  io_gmii_tx_er,
      output [7:0] io_gmii_tx_d,
      input   io_gmii_col,
      input   io_gmii_crs,
      output  io_gmii_mdio_mdc,
      input   io_gmii_mdio_mdio_read,
      output  io_gmii_mdio_mdio_write,
      output  io_gmii_mdio_mdio_writeEnable,
      input   io_ulpi_clk,
      input  [7:0] io_ulpi_data_read,
      output [7:0] io_ulpi_data_write,
      output [7:0] io_ulpi_data_writeEnable,
      input   io_ulpi_direction,
      output  io_ulpi_stp,
      input   io_ulpi_nxt,
      output  io_ulpi_reset,
      output  io_vo_vsync,
      output  io_vo_hsync,
      output  io_vo_blank_,
      output  io_vo_de,
      output [7:0] io_vo_r,
      output [7:0] io_vo_g,
      output [7:0] io_vo_b,
      input   toplevel_main_clk,
      input   toplevel_main_reset_,
      input   toplevel_vo_clk,
      input   toplevel_vo_reset_);
  wire  _zz_PanoCore_8_;
  reg [31:0] _zz_PanoCore_9_;
  wire  _zz_PanoCore_10_;
  reg  _zz_PanoCore_11_;
  reg [31:0] _zz_PanoCore_12_;
  wire  _zz_PanoCore_13_;
  wire  _zz_PanoCore_14_;
  reg [31:0] _zz_PanoCore_15_;
  wire  _zz_PanoCore_16_;
  reg  _zz_PanoCore_17_;
  reg  _zz_PanoCore_18_;
  reg [12:0] _zz_PanoCore_19_;
  wire [7:0] _zz_PanoCore_20_;
  wire  _zz_PanoCore_21_;
  wire  _zz_PanoCore_22_;
  wire [7:0] _zz_PanoCore_23_;
  wire  _zz_PanoCore_24_;
  wire  _zz_PanoCore_25_;
  reg [2:0] _zz_PanoCore_26_;
  reg [1:0] _zz_PanoCore_27_;
  wire [3:0] u_cpu_top_io_led_ctrl_apb_PADDR;
  wire [0:0] u_cpu_top_io_led_ctrl_apb_PSEL;
  wire  u_cpu_top_io_led_ctrl_apb_PENABLE;
  wire  u_cpu_top_io_led_ctrl_apb_PWRITE;
  wire [31:0] u_cpu_top_io_led_ctrl_apb_PWDATA;
  wire [4:0] u_cpu_top_io_dvi_ctrl_apb_PADDR;
  wire [0:0] u_cpu_top_io_dvi_ctrl_apb_PSEL;
  wire  u_cpu_top_io_dvi_ctrl_apb_PENABLE;
  wire  u_cpu_top_io_dvi_ctrl_apb_PWRITE;
  wire [31:0] u_cpu_top_io_dvi_ctrl_apb_PWDATA;
  wire [4:0] u_cpu_top_io_gmii_ctrl_apb_PADDR;
  wire [0:0] u_cpu_top_io_gmii_ctrl_apb_PSEL;
  wire  u_cpu_top_io_gmii_ctrl_apb_PENABLE;
  wire  u_cpu_top_io_gmii_ctrl_apb_PWRITE;
  wire [31:0] u_cpu_top_io_gmii_ctrl_apb_PWDATA;
  wire [4:0] u_cpu_top_io_test_patt_apb_PADDR;
  wire [0:0] u_cpu_top_io_test_patt_apb_PSEL;
  wire  u_cpu_top_io_test_patt_apb_PENABLE;
  wire  u_cpu_top_io_test_patt_apb_PWRITE;
  wire [31:0] u_cpu_top_io_test_patt_apb_PWDATA;
  wire [15:0] u_cpu_top_io_txt_gen_apb_PADDR;
  wire [0:0] u_cpu_top_io_txt_gen_apb_PSEL;
  wire  u_cpu_top_io_txt_gen_apb_PENABLE;
  wire  u_cpu_top_io_txt_gen_apb_PWRITE;
  wire [31:0] u_cpu_top_io_txt_gen_apb_PWDATA;
  wire [5:0] u_cpu_top_io_ulpi_apb_PADDR;
  wire [0:0] u_cpu_top_io_ulpi_apb_PSEL;
  wire  u_cpu_top_io_ulpi_apb_PENABLE;
  wire  u_cpu_top_io_ulpi_apb_PWRITE;
  wire [31:0] u_cpu_top_io_ulpi_apb_PWDATA;
  wire  vo_area_u_vi_gen_io_pixel_out_vsync;
  wire  vo_area_u_vi_gen_io_pixel_out_req;
  wire  vo_area_u_vi_gen_io_pixel_out_eol;
  wire  vo_area_u_vi_gen_io_pixel_out_eof;
  wire [7:0] vo_area_u_vi_gen_io_pixel_out_pixel_r;
  wire [7:0] vo_area_u_vi_gen_io_pixel_out_pixel_g;
  wire [7:0] vo_area_u_vi_gen_io_pixel_out_pixel_b;
  wire  vo_area_u_test_patt_io_pixel_out_vsync;
  wire  vo_area_u_test_patt_io_pixel_out_req;
  wire  vo_area_u_test_patt_io_pixel_out_eol;
  wire  vo_area_u_test_patt_io_pixel_out_eof;
  wire [7:0] vo_area_u_test_patt_io_pixel_out_pixel_r;
  wire [7:0] vo_area_u_test_patt_io_pixel_out_pixel_g;
  wire [7:0] vo_area_u_test_patt_io_pixel_out_pixel_b;
  wire  vo_area_u_txt_gen_io_pixel_out_vsync;
  wire  vo_area_u_txt_gen_io_pixel_out_req;
  wire  vo_area_u_txt_gen_io_pixel_out_eol;
  wire  vo_area_u_txt_gen_io_pixel_out_eof;
  wire [7:0] vo_area_u_txt_gen_io_pixel_out_pixel_r;
  wire [7:0] vo_area_u_txt_gen_io_pixel_out_pixel_g;
  wire [7:0] vo_area_u_txt_gen_io_pixel_out_pixel_b;
  wire [7:0] vo_area_u_txt_gen_io_txt_buf_rd_data;
  wire  vo_area_u_vo_io_vga_out_vsync;
  wire  vo_area_u_vo_io_vga_out_hsync;
  wire  vo_area_u_vo_io_vga_out_blank_;
  wire  vo_area_u_vo_io_vga_out_de;
  wire [7:0] vo_area_u_vo_io_vga_out_r;
  wire [7:0] vo_area_u_vo_io_vga_out_g;
  wire [7:0] vo_area_u_vo_io_vga_out_b;
  wire  u_gmii_ctrl_io_apb_PREADY;
  wire [31:0] u_gmii_ctrl_io_apb_PRDATA;
  wire  u_gmii_ctrl_io_apb_PSLVERROR;
  wire  u_gmii_ctrl_io_gmii_tx_en;
  wire  u_gmii_ctrl_io_gmii_tx_er;
  wire [7:0] u_gmii_ctrl_io_gmii_tx_d;
  wire  u_gmii_ctrl_io_gmii_mdio_mdc;
  wire  u_gmii_ctrl_io_gmii_mdio_mdio_write;
  wire  u_gmii_ctrl_io_gmii_mdio_mdio_writeEnable;
  wire [7:0] u_ulpi_ctrl_io_ulpi_data_write;
  wire [7:0] u_ulpi_ctrl_io_ulpi_data_writeEnable;
  wire  u_ulpi_ctrl_io_ulpi_stp;
  wire  u_ulpi_ctrl_io_ulpi_reset;
  wire  u_ulpi_ctrl_io_tx_data_ready;
  wire  u_ulpi_ctrl_io_rx_data_valid;
  wire [8:0] u_ulpi_ctrl_io_rx_data_payload;
  wire [7:0] u_ulpi_ctrl_io_reg_rd_data;
  wire  u_ulpi_ctrl_io_reg_done;
  wire  ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_push_ready;
  wire  ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_pop_valid;
  wire  ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_pop_payload;
  wire [1:0] ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_pushOccupancy;
  wire [1:0] ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_popOccupancy;
  wire  u_led_ctrl_io_apb_PREADY;
  wire [31:0] u_led_ctrl_io_apb_PRDATA;
  wire  u_led_ctrl_io_apb_PSLVERROR;
  wire [2:0] u_led_ctrl_io_gpio_write;
  wire [2:0] u_led_ctrl_io_gpio_writeEnable;
  wire  u_dvi_ctrl_io_apb_PREADY;
  wire [31:0] u_dvi_ctrl_io_apb_PRDATA;
  wire  u_dvi_ctrl_io_apb_PSLVERROR;
  wire [1:0] u_dvi_ctrl_io_gpio_write;
  wire [1:0] u_dvi_ctrl_io_gpio_writeEnable;
  wire [11:0] _zz_PanoCore_28_;
  wire [11:0] _zz_PanoCore_29_;
  wire [11:0] _zz_PanoCore_30_;
  wire [11:0] _zz_PanoCore_31_;
  wire [11:0] _zz_PanoCore_32_;
  wire [11:0] _zz_PanoCore_33_;
  wire [11:0] _zz_PanoCore_34_;
  wire [10:0] _zz_PanoCore_35_;
  wire [10:0] _zz_PanoCore_36_;
  wire [10:0] _zz_PanoCore_37_;
  wire [10:0] _zz_PanoCore_38_;
  wire [10:0] _zz_PanoCore_39_;
  wire [10:0] _zz_PanoCore_40_;
  wire [10:0] _zz_PanoCore_41_;
  wire [15:0] _zz_PanoCore_42_;
  wire [14:0] _zz_PanoCore_43_;
  wire [15:0] _zz_PanoCore_44_;
  wire [14:0] _zz_PanoCore_45_;
  wire [15:0] _zz_PanoCore_46_;
  wire [0:0] _zz_PanoCore_47_;
  reg [23:0] leds_led_cntr;
  wire [23:0] _zz_PanoCore_1_;
  wire [11:0] vo_area_timings_h_active;
  wire [8:0] vo_area_timings_h_fp;
  wire [8:0] vo_area_timings_h_sync;
  wire [8:0] vo_area_timings_h_bp;
  wire  vo_area_timings_h_sync_positive;
  wire [11:0] vo_area_timings_h_total_m1;
  wire [10:0] vo_area_timings_v_active;
  wire [8:0] vo_area_timings_v_fp;
  wire [8:0] vo_area_timings_v_sync;
  wire [8:0] vo_area_timings_v_bp;
  wire  vo_area_timings_v_sync_positive;
  wire [11:0] vo_area_timings_v_total_m1;
  wire  vo_area_vi_gen_pixel_out_vsync;
  wire  vo_area_vi_gen_pixel_out_req;
  wire  vo_area_vi_gen_pixel_out_eol;
  wire  vo_area_vi_gen_pixel_out_eof;
  wire [7:0] vo_area_vi_gen_pixel_out_pixel_r;
  wire [7:0] vo_area_vi_gen_pixel_out_pixel_g;
  wire [7:0] vo_area_vi_gen_pixel_out_pixel_b;
  wire  vo_area_test_patt_pixel_out_vsync;
  wire  vo_area_test_patt_pixel_out_req;
  wire  vo_area_test_patt_pixel_out_eol;
  wire  vo_area_test_patt_pixel_out_eof;
  wire [7:0] vo_area_test_patt_pixel_out_pixel_r;
  wire [7:0] vo_area_test_patt_pixel_out_pixel_g;
  wire [7:0] vo_area_test_patt_pixel_out_pixel_b;
  wire  vo_area_test_patt_ctrl_busCtrl_askWrite;
  wire  vo_area_test_patt_ctrl_busCtrl_askRead;
  wire  vo_area_test_patt_ctrl_busCtrl_doWrite;
  wire  vo_area_test_patt_ctrl_busCtrl_doRead;
  reg [3:0] vo_area_test_patt_ctrl_apb_regs_pattern_nr;
  reg [7:0] vo_area_test_patt_ctrl_apb_regs_const_color_r;
  reg [7:0] vo_area_test_patt_ctrl_apb_regs_const_color_g;
  reg [7:0] vo_area_test_patt_ctrl_apb_regs_const_color_b;
  wire  vo_area_txt_gen_pixel_out_vsync;
  wire  vo_area_txt_gen_pixel_out_req;
  wire  vo_area_txt_gen_pixel_out_eol;
  wire  vo_area_txt_gen_pixel_out_eof;
  wire [7:0] vo_area_txt_gen_pixel_out_pixel_r;
  wire [7:0] vo_area_txt_gen_pixel_out_pixel_g;
  wire [7:0] vo_area_txt_gen_pixel_out_pixel_b;
  wire  vo_area_txt_gen_ctrl_busCtrl_askWrite;
  wire  vo_area_txt_gen_ctrl_busCtrl_askRead;
  wire  vo_area_txt_gen_ctrl_busCtrl_doWrite;
  wire  vo_area_txt_gen_ctrl_busCtrl_doRead;
  wire [12:0] vo_area_txt_gen_ctrl_apb_regs_txt_buf_rd_addr;
  wire [12:0] vo_area_txt_gen_ctrl_apb_regs_txt_buf_wr_addr;
  reg  _zz_PanoCore_2_;
  reg [0:0] _zz_PanoCore_3_;
  reg [0:0] _zz_PanoCore_4_;
  wire  _zz_PanoCore_5_;
  wire  ulpi_ctrl_busCtrl_askWrite;
  wire  ulpi_ctrl_busCtrl_askRead;
  wire  ulpi_ctrl_busCtrl_doWrite;
  wire  ulpi_ctrl_busCtrl_doRead;
  reg [5:0] ulpi_ctrl_apb_regs_reg_addr;
  reg [7:0] ulpi_ctrl_apb_regs_reg_wr_data;
  reg  ulpi_ctrl_apb_regs_reg_wr;
  wire  ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_valid;
  wire  ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_ready;
  wire  ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_payload;
  wire  ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_valid;
  wire  ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_ready;
  wire  ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_payload;
  reg  _zz_PanoCore_6_;
  reg  _zz_PanoCore_6__regNext;
  wire [8:0] ulpi_ctrl_apb_regs_status;
  wire [23:0] _zz_PanoCore_7_;
  assign _zz_PanoCore_28_ = (_zz_PanoCore_29_ - (12'b000000000001));
  assign _zz_PanoCore_29_ = (_zz_PanoCore_30_ + _zz_PanoCore_34_);
  assign _zz_PanoCore_30_ = (_zz_PanoCore_31_ + _zz_PanoCore_33_);
  assign _zz_PanoCore_31_ = (vo_area_timings_h_active + _zz_PanoCore_32_);
  assign _zz_PanoCore_32_ = {3'd0, vo_area_timings_h_fp};
  assign _zz_PanoCore_33_ = {3'd0, vo_area_timings_h_sync};
  assign _zz_PanoCore_34_ = {3'd0, vo_area_timings_h_bp};
  assign _zz_PanoCore_35_ = (_zz_PanoCore_36_ - (11'b00000000001));
  assign _zz_PanoCore_36_ = (_zz_PanoCore_37_ + _zz_PanoCore_41_);
  assign _zz_PanoCore_37_ = (_zz_PanoCore_38_ + _zz_PanoCore_40_);
  assign _zz_PanoCore_38_ = (vo_area_timings_v_active + _zz_PanoCore_39_);
  assign _zz_PanoCore_39_ = {2'd0, vo_area_timings_v_fp};
  assign _zz_PanoCore_40_ = {2'd0, vo_area_timings_v_sync};
  assign _zz_PanoCore_41_ = {2'd0, vo_area_timings_v_bp};
  assign _zz_PanoCore_42_ = (u_cpu_top_io_txt_gen_apb_PADDR & (16'b0111111111111111));
  assign _zz_PanoCore_43_ = _zz_PanoCore_42_[14:0];
  assign _zz_PanoCore_44_ = (u_cpu_top_io_txt_gen_apb_PADDR & (16'b0111111111111111));
  assign _zz_PanoCore_45_ = _zz_PanoCore_44_[14:0];
  assign _zz_PanoCore_46_ = (16'b1000000000000000);
  assign _zz_PanoCore_47_ = u_cpu_top_io_ulpi_apb_PWDATA[31 : 31];
  CpuTop u_cpu_top ( 
    .io_led_ctrl_apb_PADDR(u_cpu_top_io_led_ctrl_apb_PADDR),
    .io_led_ctrl_apb_PSEL(u_cpu_top_io_led_ctrl_apb_PSEL),
    .io_led_ctrl_apb_PENABLE(u_cpu_top_io_led_ctrl_apb_PENABLE),
    .io_led_ctrl_apb_PREADY(u_led_ctrl_io_apb_PREADY),
    .io_led_ctrl_apb_PWRITE(u_cpu_top_io_led_ctrl_apb_PWRITE),
    .io_led_ctrl_apb_PWDATA(u_cpu_top_io_led_ctrl_apb_PWDATA),
    .io_led_ctrl_apb_PRDATA(u_led_ctrl_io_apb_PRDATA),
    .io_led_ctrl_apb_PSLVERROR(u_led_ctrl_io_apb_PSLVERROR),
    .io_dvi_ctrl_apb_PADDR(u_cpu_top_io_dvi_ctrl_apb_PADDR),
    .io_dvi_ctrl_apb_PSEL(u_cpu_top_io_dvi_ctrl_apb_PSEL),
    .io_dvi_ctrl_apb_PENABLE(u_cpu_top_io_dvi_ctrl_apb_PENABLE),
    .io_dvi_ctrl_apb_PREADY(u_dvi_ctrl_io_apb_PREADY),
    .io_dvi_ctrl_apb_PWRITE(u_cpu_top_io_dvi_ctrl_apb_PWRITE),
    .io_dvi_ctrl_apb_PWDATA(u_cpu_top_io_dvi_ctrl_apb_PWDATA),
    .io_dvi_ctrl_apb_PRDATA(u_dvi_ctrl_io_apb_PRDATA),
    .io_dvi_ctrl_apb_PSLVERROR(u_dvi_ctrl_io_apb_PSLVERROR),
    .io_gmii_ctrl_apb_PADDR(u_cpu_top_io_gmii_ctrl_apb_PADDR),
    .io_gmii_ctrl_apb_PSEL(u_cpu_top_io_gmii_ctrl_apb_PSEL),
    .io_gmii_ctrl_apb_PENABLE(u_cpu_top_io_gmii_ctrl_apb_PENABLE),
    .io_gmii_ctrl_apb_PREADY(u_gmii_ctrl_io_apb_PREADY),
    .io_gmii_ctrl_apb_PWRITE(u_cpu_top_io_gmii_ctrl_apb_PWRITE),
    .io_gmii_ctrl_apb_PWDATA(u_cpu_top_io_gmii_ctrl_apb_PWDATA),
    .io_gmii_ctrl_apb_PRDATA(u_gmii_ctrl_io_apb_PRDATA),
    .io_gmii_ctrl_apb_PSLVERROR(u_gmii_ctrl_io_apb_PSLVERROR),
    .io_test_patt_apb_PADDR(u_cpu_top_io_test_patt_apb_PADDR),
    .io_test_patt_apb_PSEL(u_cpu_top_io_test_patt_apb_PSEL),
    .io_test_patt_apb_PENABLE(u_cpu_top_io_test_patt_apb_PENABLE),
    .io_test_patt_apb_PREADY(_zz_PanoCore_8_),
    .io_test_patt_apb_PWRITE(u_cpu_top_io_test_patt_apb_PWRITE),
    .io_test_patt_apb_PWDATA(u_cpu_top_io_test_patt_apb_PWDATA),
    .io_test_patt_apb_PRDATA(_zz_PanoCore_9_),
    .io_test_patt_apb_PSLVERROR(_zz_PanoCore_10_),
    .io_txt_gen_apb_PADDR(u_cpu_top_io_txt_gen_apb_PADDR),
    .io_txt_gen_apb_PSEL(u_cpu_top_io_txt_gen_apb_PSEL),
    .io_txt_gen_apb_PENABLE(u_cpu_top_io_txt_gen_apb_PENABLE),
    .io_txt_gen_apb_PREADY(_zz_PanoCore_11_),
    .io_txt_gen_apb_PWRITE(u_cpu_top_io_txt_gen_apb_PWRITE),
    .io_txt_gen_apb_PWDATA(u_cpu_top_io_txt_gen_apb_PWDATA),
    .io_txt_gen_apb_PRDATA(_zz_PanoCore_12_),
    .io_txt_gen_apb_PSLVERROR(_zz_PanoCore_13_),
    .io_ulpi_apb_PADDR(u_cpu_top_io_ulpi_apb_PADDR),
    .io_ulpi_apb_PSEL(u_cpu_top_io_ulpi_apb_PSEL),
    .io_ulpi_apb_PENABLE(u_cpu_top_io_ulpi_apb_PENABLE),
    .io_ulpi_apb_PREADY(_zz_PanoCore_14_),
    .io_ulpi_apb_PWRITE(u_cpu_top_io_ulpi_apb_PWRITE),
    .io_ulpi_apb_PWDATA(u_cpu_top_io_ulpi_apb_PWDATA),
    .io_ulpi_apb_PRDATA(_zz_PanoCore_15_),
    .io_ulpi_apb_PSLVERROR(_zz_PanoCore_16_),
    .io_switch_(io_switch_),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  VideoTimingGen vo_area_u_vi_gen ( 
    .io_timings_h_active(vo_area_timings_h_active),
    .io_timings_h_fp(vo_area_timings_h_fp),
    .io_timings_h_sync(vo_area_timings_h_sync),
    .io_timings_h_bp(vo_area_timings_h_bp),
    .io_timings_h_sync_positive(vo_area_timings_h_sync_positive),
    .io_timings_h_total_m1(vo_area_timings_h_total_m1),
    .io_timings_v_active(vo_area_timings_v_active),
    .io_timings_v_fp(vo_area_timings_v_fp),
    .io_timings_v_sync(vo_area_timings_v_sync),
    .io_timings_v_bp(vo_area_timings_v_bp),
    .io_timings_v_sync_positive(vo_area_timings_v_sync_positive),
    .io_timings_v_total_m1(vo_area_timings_v_total_m1),
    .io_pixel_out_vsync(vo_area_u_vi_gen_io_pixel_out_vsync),
    .io_pixel_out_req(vo_area_u_vi_gen_io_pixel_out_req),
    .io_pixel_out_eol(vo_area_u_vi_gen_io_pixel_out_eol),
    .io_pixel_out_eof(vo_area_u_vi_gen_io_pixel_out_eof),
    .io_pixel_out_pixel_r(vo_area_u_vi_gen_io_pixel_out_pixel_r),
    .io_pixel_out_pixel_g(vo_area_u_vi_gen_io_pixel_out_pixel_g),
    .io_pixel_out_pixel_b(vo_area_u_vi_gen_io_pixel_out_pixel_b),
    .toplevel_vo_clk(toplevel_vo_clk),
    .toplevel_vo_reset_(toplevel_vo_reset_) 
  );
  VideoTestPattern vo_area_u_test_patt ( 
    .io_timings_h_active(vo_area_timings_h_active),
    .io_timings_h_fp(vo_area_timings_h_fp),
    .io_timings_h_sync(vo_area_timings_h_sync),
    .io_timings_h_bp(vo_area_timings_h_bp),
    .io_timings_h_sync_positive(vo_area_timings_h_sync_positive),
    .io_timings_h_total_m1(vo_area_timings_h_total_m1),
    .io_timings_v_active(vo_area_timings_v_active),
    .io_timings_v_fp(vo_area_timings_v_fp),
    .io_timings_v_sync(vo_area_timings_v_sync),
    .io_timings_v_bp(vo_area_timings_v_bp),
    .io_timings_v_sync_positive(vo_area_timings_v_sync_positive),
    .io_timings_v_total_m1(vo_area_timings_v_total_m1),
    .io_pixel_in_vsync(vo_area_vi_gen_pixel_out_vsync),
    .io_pixel_in_req(vo_area_vi_gen_pixel_out_req),
    .io_pixel_in_eol(vo_area_vi_gen_pixel_out_eol),
    .io_pixel_in_eof(vo_area_vi_gen_pixel_out_eof),
    .io_pixel_in_pixel_r(vo_area_vi_gen_pixel_out_pixel_r),
    .io_pixel_in_pixel_g(vo_area_vi_gen_pixel_out_pixel_g),
    .io_pixel_in_pixel_b(vo_area_vi_gen_pixel_out_pixel_b),
    .io_pixel_out_vsync(vo_area_u_test_patt_io_pixel_out_vsync),
    .io_pixel_out_req(vo_area_u_test_patt_io_pixel_out_req),
    .io_pixel_out_eol(vo_area_u_test_patt_io_pixel_out_eol),
    .io_pixel_out_eof(vo_area_u_test_patt_io_pixel_out_eof),
    .io_pixel_out_pixel_r(vo_area_u_test_patt_io_pixel_out_pixel_r),
    .io_pixel_out_pixel_g(vo_area_u_test_patt_io_pixel_out_pixel_g),
    .io_pixel_out_pixel_b(vo_area_u_test_patt_io_pixel_out_pixel_b),
    .io_pattern_nr(vo_area_test_patt_ctrl_apb_regs_pattern_nr),
    .io_const_color_r(vo_area_test_patt_ctrl_apb_regs_const_color_r),
    .io_const_color_g(vo_area_test_patt_ctrl_apb_regs_const_color_g),
    .io_const_color_b(vo_area_test_patt_ctrl_apb_regs_const_color_b),
    .toplevel_vo_clk(toplevel_vo_clk),
    .toplevel_vo_reset_(toplevel_vo_reset_) 
  );
  VideoTxtGen vo_area_u_txt_gen ( 
    .io_pixel_in_vsync(vo_area_test_patt_pixel_out_vsync),
    .io_pixel_in_req(vo_area_test_patt_pixel_out_req),
    .io_pixel_in_eol(vo_area_test_patt_pixel_out_eol),
    .io_pixel_in_eof(vo_area_test_patt_pixel_out_eof),
    .io_pixel_in_pixel_r(vo_area_test_patt_pixel_out_pixel_r),
    .io_pixel_in_pixel_g(vo_area_test_patt_pixel_out_pixel_g),
    .io_pixel_in_pixel_b(vo_area_test_patt_pixel_out_pixel_b),
    .io_pixel_out_vsync(vo_area_u_txt_gen_io_pixel_out_vsync),
    .io_pixel_out_req(vo_area_u_txt_gen_io_pixel_out_req),
    .io_pixel_out_eol(vo_area_u_txt_gen_io_pixel_out_eol),
    .io_pixel_out_eof(vo_area_u_txt_gen_io_pixel_out_eof),
    .io_pixel_out_pixel_r(vo_area_u_txt_gen_io_pixel_out_pixel_r),
    .io_pixel_out_pixel_g(vo_area_u_txt_gen_io_pixel_out_pixel_g),
    .io_pixel_out_pixel_b(vo_area_u_txt_gen_io_pixel_out_pixel_b),
    .io_txt_buf_wr(_zz_PanoCore_17_),
    .io_txt_buf_rd(_zz_PanoCore_18_),
    .io_txt_buf_addr(_zz_PanoCore_19_),
    .io_txt_buf_wr_data(_zz_PanoCore_20_),
    .io_txt_buf_rd_data(vo_area_u_txt_gen_io_txt_buf_rd_data),
    .toplevel_vo_clk(toplevel_vo_clk),
    .toplevel_vo_reset_(toplevel_vo_reset_),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  VideoOut vo_area_u_vo ( 
    .io_timings_h_active(vo_area_timings_h_active),
    .io_timings_h_fp(vo_area_timings_h_fp),
    .io_timings_h_sync(vo_area_timings_h_sync),
    .io_timings_h_bp(vo_area_timings_h_bp),
    .io_timings_h_sync_positive(vo_area_timings_h_sync_positive),
    .io_timings_h_total_m1(vo_area_timings_h_total_m1),
    .io_timings_v_active(vo_area_timings_v_active),
    .io_timings_v_fp(vo_area_timings_v_fp),
    .io_timings_v_sync(vo_area_timings_v_sync),
    .io_timings_v_bp(vo_area_timings_v_bp),
    .io_timings_v_sync_positive(vo_area_timings_v_sync_positive),
    .io_timings_v_total_m1(vo_area_timings_v_total_m1),
    .io_pixel_in_vsync(vo_area_txt_gen_pixel_out_vsync),
    .io_pixel_in_req(vo_area_txt_gen_pixel_out_req),
    .io_pixel_in_eol(vo_area_txt_gen_pixel_out_eol),
    .io_pixel_in_eof(vo_area_txt_gen_pixel_out_eof),
    .io_pixel_in_pixel_r(vo_area_txt_gen_pixel_out_pixel_r),
    .io_pixel_in_pixel_g(vo_area_txt_gen_pixel_out_pixel_g),
    .io_pixel_in_pixel_b(vo_area_txt_gen_pixel_out_pixel_b),
    .io_vga_out_vsync(vo_area_u_vo_io_vga_out_vsync),
    .io_vga_out_hsync(vo_area_u_vo_io_vga_out_hsync),
    .io_vga_out_blank_(vo_area_u_vo_io_vga_out_blank_),
    .io_vga_out_de(vo_area_u_vo_io_vga_out_de),
    .io_vga_out_r(vo_area_u_vo_io_vga_out_r),
    .io_vga_out_g(vo_area_u_vo_io_vga_out_g),
    .io_vga_out_b(vo_area_u_vo_io_vga_out_b),
    .toplevel_vo_clk(toplevel_vo_clk),
    .toplevel_vo_reset_(toplevel_vo_reset_) 
  );
  GmiiCtrl u_gmii_ctrl ( 
    .io_apb_PADDR(u_cpu_top_io_gmii_ctrl_apb_PADDR),
    .io_apb_PSEL(u_cpu_top_io_gmii_ctrl_apb_PSEL),
    .io_apb_PENABLE(u_cpu_top_io_gmii_ctrl_apb_PENABLE),
    .io_apb_PREADY(u_gmii_ctrl_io_apb_PREADY),
    .io_apb_PWRITE(u_cpu_top_io_gmii_ctrl_apb_PWRITE),
    .io_apb_PWDATA(u_cpu_top_io_gmii_ctrl_apb_PWDATA),
    .io_apb_PRDATA(u_gmii_ctrl_io_apb_PRDATA),
    .io_apb_PSLVERROR(u_gmii_ctrl_io_apb_PSLVERROR),
    .io_gmii_rx_clk(io_gmii_rx_clk),
    .io_gmii_rx_dv(io_gmii_rx_dv),
    .io_gmii_rx_er(io_gmii_rx_er),
    .io_gmii_rx_d(io_gmii_rx_d),
    .io_gmii_tx_gclk(io_gmii_tx_gclk),
    .io_gmii_tx_clk(io_gmii_tx_clk),
    .io_gmii_tx_en(u_gmii_ctrl_io_gmii_tx_en),
    .io_gmii_tx_er(u_gmii_ctrl_io_gmii_tx_er),
    .io_gmii_tx_d(u_gmii_ctrl_io_gmii_tx_d),
    .io_gmii_col(io_gmii_col),
    .io_gmii_crs(io_gmii_crs),
    .io_gmii_mdio_mdc(u_gmii_ctrl_io_gmii_mdio_mdc),
    .io_gmii_mdio_mdio_read(io_gmii_mdio_mdio_read),
    .io_gmii_mdio_mdio_write(u_gmii_ctrl_io_gmii_mdio_mdio_write),
    .io_gmii_mdio_mdio_writeEnable(u_gmii_ctrl_io_gmii_mdio_mdio_writeEnable),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  UlpiCtrl u_ulpi_ctrl ( 
    .io_ulpi_clk(io_ulpi_clk),
    .io_ulpi_data_read(io_ulpi_data_read),
    .io_ulpi_data_write(u_ulpi_ctrl_io_ulpi_data_write),
    .io_ulpi_data_writeEnable(u_ulpi_ctrl_io_ulpi_data_writeEnable),
    .io_ulpi_direction(io_ulpi_direction),
    .io_ulpi_stp(u_ulpi_ctrl_io_ulpi_stp),
    .io_ulpi_nxt(io_ulpi_nxt),
    .io_ulpi_reset(u_ulpi_ctrl_io_ulpi_reset),
    .io_tx_start(_zz_PanoCore_21_),
    .io_tx_data_valid(_zz_PanoCore_22_),
    .io_tx_data_ready(u_ulpi_ctrl_io_tx_data_ready),
    .io_tx_data_payload(_zz_PanoCore_23_),
    .io_rx_data_valid(u_ulpi_ctrl_io_rx_data_valid),
    .io_rx_data_payload(u_ulpi_ctrl_io_rx_data_payload),
    .io_reg_rd(_zz_PanoCore_24_),
    .io_reg_wr(_zz_PanoCore_25_),
    .io_reg_addr(ulpi_ctrl_apb_regs_reg_addr),
    .io_reg_wr_data(ulpi_ctrl_apb_regs_reg_wr_data),
    .io_reg_rd_data(u_ulpi_ctrl_io_reg_rd_data),
    .io_reg_done(u_ulpi_ctrl_io_reg_done) 
  );
  StreamFifoCC_1_ ulpi_ctrl_apb_regs_u_reg_cmd_fifo ( 
    .io_push_valid(ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_valid),
    .io_push_ready(ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_push_ready),
    .io_push_payload(ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_payload),
    .io_pop_valid(ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_pop_valid),
    .io_pop_ready(ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_ready),
    .io_pop_payload(ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_pop_payload),
    .io_pushOccupancy(ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_pushOccupancy),
    .io_popOccupancy(ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_popOccupancy),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_),
    .u_ulpi_ctrl_io_ulpi_clk(io_ulpi_clk) 
  );
  Apb3Gpio u_led_ctrl ( 
    .io_apb_PADDR(u_cpu_top_io_led_ctrl_apb_PADDR),
    .io_apb_PSEL(u_cpu_top_io_led_ctrl_apb_PSEL),
    .io_apb_PENABLE(u_cpu_top_io_led_ctrl_apb_PENABLE),
    .io_apb_PREADY(u_led_ctrl_io_apb_PREADY),
    .io_apb_PWRITE(u_cpu_top_io_led_ctrl_apb_PWRITE),
    .io_apb_PWDATA(u_cpu_top_io_led_ctrl_apb_PWDATA),
    .io_apb_PRDATA(u_led_ctrl_io_apb_PRDATA),
    .io_apb_PSLVERROR(u_led_ctrl_io_apb_PSLVERROR),
    .io_gpio_read(_zz_PanoCore_26_),
    .io_gpio_write(u_led_ctrl_io_gpio_write),
    .io_gpio_writeEnable(u_led_ctrl_io_gpio_writeEnable),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  CCGpio u_dvi_ctrl ( 
    .io_apb_PADDR(u_cpu_top_io_dvi_ctrl_apb_PADDR),
    .io_apb_PSEL(u_cpu_top_io_dvi_ctrl_apb_PSEL),
    .io_apb_PENABLE(u_cpu_top_io_dvi_ctrl_apb_PENABLE),
    .io_apb_PREADY(u_dvi_ctrl_io_apb_PREADY),
    .io_apb_PWRITE(u_cpu_top_io_dvi_ctrl_apb_PWRITE),
    .io_apb_PWDATA(u_cpu_top_io_dvi_ctrl_apb_PWDATA),
    .io_apb_PRDATA(u_dvi_ctrl_io_apb_PRDATA),
    .io_apb_PSLVERROR(u_dvi_ctrl_io_apb_PSLVERROR),
    .io_gpio_read(_zz_PanoCore_27_),
    .io_gpio_write(u_dvi_ctrl_io_gpio_write),
    .io_gpio_writeEnable(u_dvi_ctrl_io_gpio_writeEnable),
    .toplevel_main_clk(toplevel_main_clk),
    .toplevel_main_reset_(toplevel_main_reset_) 
  );
  assign _zz_PanoCore_1_[23 : 0] = (24'b111111111111111111111111);
  assign io_led_red = leds_led_cntr[23];
  assign vo_area_timings_h_active = (12'b011110000000);
  assign vo_area_timings_h_fp = (9'b001011000);
  assign vo_area_timings_h_sync = (9'b000101100);
  assign vo_area_timings_h_bp = (9'b010010100);
  assign vo_area_timings_h_sync_positive = 1'b1;
  assign vo_area_timings_h_total_m1 = _zz_PanoCore_28_;
  assign vo_area_timings_v_active = (11'b10000111000);
  assign vo_area_timings_v_fp = (9'b000000100);
  assign vo_area_timings_v_sync = (9'b000000101);
  assign vo_area_timings_v_bp = (9'b000100100);
  assign vo_area_timings_v_sync_positive = 1'b1;
  assign vo_area_timings_v_total_m1 = {1'd0, _zz_PanoCore_35_};
  assign vo_area_vi_gen_pixel_out_vsync = vo_area_u_vi_gen_io_pixel_out_vsync;
  assign vo_area_vi_gen_pixel_out_req = vo_area_u_vi_gen_io_pixel_out_req;
  assign vo_area_vi_gen_pixel_out_eol = vo_area_u_vi_gen_io_pixel_out_eol;
  assign vo_area_vi_gen_pixel_out_eof = vo_area_u_vi_gen_io_pixel_out_eof;
  assign vo_area_vi_gen_pixel_out_pixel_r = vo_area_u_vi_gen_io_pixel_out_pixel_r;
  assign vo_area_vi_gen_pixel_out_pixel_g = vo_area_u_vi_gen_io_pixel_out_pixel_g;
  assign vo_area_vi_gen_pixel_out_pixel_b = vo_area_u_vi_gen_io_pixel_out_pixel_b;
  assign vo_area_test_patt_pixel_out_vsync = vo_area_u_test_patt_io_pixel_out_vsync;
  assign vo_area_test_patt_pixel_out_req = vo_area_u_test_patt_io_pixel_out_req;
  assign vo_area_test_patt_pixel_out_eol = vo_area_u_test_patt_io_pixel_out_eol;
  assign vo_area_test_patt_pixel_out_eof = vo_area_u_test_patt_io_pixel_out_eof;
  assign vo_area_test_patt_pixel_out_pixel_r = vo_area_u_test_patt_io_pixel_out_pixel_r;
  assign vo_area_test_patt_pixel_out_pixel_g = vo_area_u_test_patt_io_pixel_out_pixel_g;
  assign vo_area_test_patt_pixel_out_pixel_b = vo_area_u_test_patt_io_pixel_out_pixel_b;
  assign _zz_PanoCore_8_ = 1'b1;
  always @ (*) begin
    _zz_PanoCore_9_ = (32'b00000000000000000000000000000000);
    case(u_cpu_top_io_test_patt_apb_PADDR)
      5'b00000 : begin
        _zz_PanoCore_9_[3 : 0] = vo_area_test_patt_ctrl_apb_regs_pattern_nr;
      end
      5'b00100 : begin
        _zz_PanoCore_9_[23 : 0] = {vo_area_test_patt_ctrl_apb_regs_const_color_b,{vo_area_test_patt_ctrl_apb_regs_const_color_g,vo_area_test_patt_ctrl_apb_regs_const_color_r}};
      end
      default : begin
      end
    endcase
  end

  assign _zz_PanoCore_10_ = 1'b0;
  assign vo_area_test_patt_ctrl_busCtrl_askWrite = ((u_cpu_top_io_test_patt_apb_PSEL[0] && u_cpu_top_io_test_patt_apb_PENABLE) && u_cpu_top_io_test_patt_apb_PWRITE);
  assign vo_area_test_patt_ctrl_busCtrl_askRead = ((u_cpu_top_io_test_patt_apb_PSEL[0] && u_cpu_top_io_test_patt_apb_PENABLE) && (! u_cpu_top_io_test_patt_apb_PWRITE));
  assign vo_area_test_patt_ctrl_busCtrl_doWrite = (((u_cpu_top_io_test_patt_apb_PSEL[0] && u_cpu_top_io_test_patt_apb_PENABLE) && _zz_PanoCore_8_) && u_cpu_top_io_test_patt_apb_PWRITE);
  assign vo_area_test_patt_ctrl_busCtrl_doRead = (((u_cpu_top_io_test_patt_apb_PSEL[0] && u_cpu_top_io_test_patt_apb_PENABLE) && _zz_PanoCore_8_) && (! u_cpu_top_io_test_patt_apb_PWRITE));
  assign vo_area_txt_gen_pixel_out_vsync = vo_area_u_txt_gen_io_pixel_out_vsync;
  assign vo_area_txt_gen_pixel_out_req = vo_area_u_txt_gen_io_pixel_out_req;
  assign vo_area_txt_gen_pixel_out_eol = vo_area_u_txt_gen_io_pixel_out_eol;
  assign vo_area_txt_gen_pixel_out_eof = vo_area_u_txt_gen_io_pixel_out_eof;
  assign vo_area_txt_gen_pixel_out_pixel_r = vo_area_u_txt_gen_io_pixel_out_pixel_r;
  assign vo_area_txt_gen_pixel_out_pixel_g = vo_area_u_txt_gen_io_pixel_out_pixel_g;
  assign vo_area_txt_gen_pixel_out_pixel_b = vo_area_u_txt_gen_io_pixel_out_pixel_b;
  always @ (*) begin
    _zz_PanoCore_11_ = 1'b1;
    _zz_PanoCore_12_ = (32'b00000000000000000000000000000000);
    _zz_PanoCore_17_ = 1'b0;
    _zz_PanoCore_18_ = 1'b0;
    _zz_PanoCore_19_ = vo_area_txt_gen_ctrl_apb_regs_txt_buf_wr_addr;
    _zz_PanoCore_2_ = 1'b0;
    if(((u_cpu_top_io_txt_gen_apb_PADDR & _zz_PanoCore_46_) == (16'b0000000000000000)))begin
      if(vo_area_txt_gen_ctrl_busCtrl_doWrite)begin
        _zz_PanoCore_17_ = 1'b1;
        _zz_PanoCore_19_ = vo_area_txt_gen_ctrl_apb_regs_txt_buf_wr_addr;
      end
      if(vo_area_txt_gen_ctrl_busCtrl_askRead)begin
        _zz_PanoCore_2_ = 1'b1;
        if((! _zz_PanoCore_5_))begin
          _zz_PanoCore_11_ = 1'b0;
        end
        _zz_PanoCore_18_ = 1'b1;
        _zz_PanoCore_19_ = vo_area_txt_gen_ctrl_apb_regs_txt_buf_rd_addr;
      end
      _zz_PanoCore_12_[7 : 0] = vo_area_u_txt_gen_io_txt_buf_rd_data;
    end
  end

  assign _zz_PanoCore_13_ = 1'b0;
  assign vo_area_txt_gen_ctrl_busCtrl_askWrite = ((u_cpu_top_io_txt_gen_apb_PSEL[0] && u_cpu_top_io_txt_gen_apb_PENABLE) && u_cpu_top_io_txt_gen_apb_PWRITE);
  assign vo_area_txt_gen_ctrl_busCtrl_askRead = ((u_cpu_top_io_txt_gen_apb_PSEL[0] && u_cpu_top_io_txt_gen_apb_PENABLE) && (! u_cpu_top_io_txt_gen_apb_PWRITE));
  assign vo_area_txt_gen_ctrl_busCtrl_doWrite = (((u_cpu_top_io_txt_gen_apb_PSEL[0] && u_cpu_top_io_txt_gen_apb_PENABLE) && _zz_PanoCore_11_) && u_cpu_top_io_txt_gen_apb_PWRITE);
  assign vo_area_txt_gen_ctrl_busCtrl_doRead = (((u_cpu_top_io_txt_gen_apb_PSEL[0] && u_cpu_top_io_txt_gen_apb_PENABLE) && _zz_PanoCore_11_) && (! u_cpu_top_io_txt_gen_apb_PWRITE));
  assign vo_area_txt_gen_ctrl_apb_regs_txt_buf_rd_addr = (_zz_PanoCore_43_ >>> 2);
  assign vo_area_txt_gen_ctrl_apb_regs_txt_buf_wr_addr = (_zz_PanoCore_45_ >>> 2);
  assign _zz_PanoCore_5_ = (_zz_PanoCore_4_ == (1'b1));
  always @ (*) begin
    _zz_PanoCore_3_ = (_zz_PanoCore_4_ + _zz_PanoCore_2_);
    if(1'b0)begin
      _zz_PanoCore_3_ = (1'b0);
    end
  end

  assign io_vo_vsync = vo_area_u_vo_io_vga_out_vsync;
  assign io_vo_hsync = vo_area_u_vo_io_vga_out_hsync;
  assign io_vo_blank_ = vo_area_u_vo_io_vga_out_blank_;
  assign io_vo_de = vo_area_u_vo_io_vga_out_de;
  assign io_vo_r = vo_area_u_vo_io_vga_out_r;
  assign io_vo_g = vo_area_u_vo_io_vga_out_g;
  assign io_vo_b = vo_area_u_vo_io_vga_out_b;
  assign io_gmii_tx_en = u_gmii_ctrl_io_gmii_tx_en;
  assign io_gmii_tx_er = u_gmii_ctrl_io_gmii_tx_er;
  assign io_gmii_tx_d = u_gmii_ctrl_io_gmii_tx_d;
  assign io_gmii_mdio_mdc = u_gmii_ctrl_io_gmii_mdio_mdc;
  assign io_gmii_mdio_mdio_write = u_gmii_ctrl_io_gmii_mdio_mdio_write;
  assign io_gmii_mdio_mdio_writeEnable = u_gmii_ctrl_io_gmii_mdio_mdio_writeEnable;
  assign io_ulpi_data_write = u_ulpi_ctrl_io_ulpi_data_write;
  assign io_ulpi_data_writeEnable = u_ulpi_ctrl_io_ulpi_data_writeEnable;
  assign io_ulpi_stp = u_ulpi_ctrl_io_ulpi_stp;
  assign io_ulpi_reset = u_ulpi_ctrl_io_ulpi_reset;
  assign _zz_PanoCore_14_ = 1'b1;
  always @ (*) begin
    _zz_PanoCore_15_ = (32'b00000000000000000000000000000000);
    _zz_PanoCore_6_ = 1'b0;
    case(u_cpu_top_io_ulpi_apb_PADDR)
      6'b000000 : begin
        if(ulpi_ctrl_busCtrl_doWrite)begin
          _zz_PanoCore_6_ = 1'b1;
        end
        _zz_PanoCore_15_[5 : 0] = ulpi_ctrl_apb_regs_reg_addr;
        _zz_PanoCore_15_[15 : 8] = ulpi_ctrl_apb_regs_reg_wr_data;
        _zz_PanoCore_15_[31 : 31] = ulpi_ctrl_apb_regs_reg_wr;
      end
      6'b000100 : begin
        _zz_PanoCore_15_[8 : 0] = ulpi_ctrl_apb_regs_status;
      end
      default : begin
      end
    endcase
  end

  assign _zz_PanoCore_16_ = 1'b0;
  assign ulpi_ctrl_busCtrl_askWrite = ((u_cpu_top_io_ulpi_apb_PSEL[0] && u_cpu_top_io_ulpi_apb_PENABLE) && u_cpu_top_io_ulpi_apb_PWRITE);
  assign ulpi_ctrl_busCtrl_askRead = ((u_cpu_top_io_ulpi_apb_PSEL[0] && u_cpu_top_io_ulpi_apb_PENABLE) && (! u_cpu_top_io_ulpi_apb_PWRITE));
  assign ulpi_ctrl_busCtrl_doWrite = (((u_cpu_top_io_ulpi_apb_PSEL[0] && u_cpu_top_io_ulpi_apb_PENABLE) && _zz_PanoCore_14_) && u_cpu_top_io_ulpi_apb_PWRITE);
  assign ulpi_ctrl_busCtrl_doRead = (((u_cpu_top_io_ulpi_apb_PSEL[0] && u_cpu_top_io_ulpi_apb_PENABLE) && _zz_PanoCore_14_) && (! u_cpu_top_io_ulpi_apb_PWRITE));
  assign ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_valid = _zz_PanoCore_6__regNext;
  assign ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_payload = ulpi_ctrl_apb_regs_reg_wr;
  assign ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_ready = ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_push_ready;
  assign ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_valid = ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_pop_valid;
  assign ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_payload = ulpi_ctrl_apb_regs_u_reg_cmd_fifo_io_pop_payload;
  assign _zz_PanoCore_25_ = (ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_valid && ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_payload);
  assign _zz_PanoCore_24_ = (ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_valid && (! ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_payload));
  assign ulpi_ctrl_apb_regs_reg_cmd_fifo_rd_ready = u_ulpi_ctrl_io_reg_done;
  assign ulpi_ctrl_apb_regs_status = {ulpi_ctrl_apb_regs_reg_cmd_fifo_wr_valid,u_ulpi_ctrl_io_reg_rd_data};
  assign _zz_PanoCore_21_ = 1'b0;
  assign _zz_PanoCore_22_ = 1'b0;
  assign _zz_PanoCore_23_ = (8'b00000000);
  assign io_led_green = u_led_ctrl_io_gpio_write[0];
  assign io_led_blue = u_led_ctrl_io_gpio_write[1];
  always @ (*) begin
    _zz_PanoCore_26_[0] = io_led_green;
    _zz_PanoCore_26_[1] = io_led_blue;
    _zz_PanoCore_26_[2] = 1'b0;
  end

  assign io_dvi_ctrl_scl_writeEnable = (! u_dvi_ctrl_io_gpio_write[0]);
  assign io_dvi_ctrl_scl_write = u_dvi_ctrl_io_gpio_write[0];
  always @ (*) begin
    _zz_PanoCore_27_[0] = io_dvi_ctrl_scl_read;
    _zz_PanoCore_27_[1] = io_dvi_ctrl_sda_read;
  end

  assign io_dvi_ctrl_sda_writeEnable = (! u_dvi_ctrl_io_gpio_write[1]);
  assign io_dvi_ctrl_sda_write = u_dvi_ctrl_io_gpio_write[1];
  assign _zz_PanoCore_7_ = u_cpu_top_io_test_patt_apb_PWDATA[23 : 0];
  assign _zz_PanoCore_20_ = u_cpu_top_io_txt_gen_apb_PWDATA[7 : 0];
  always @ (posedge toplevel_main_clk) begin
    if(!toplevel_main_reset_) begin
      leds_led_cntr <= (24'b000000000000000000000000);
      vo_area_test_patt_ctrl_apb_regs_pattern_nr <= (4'b0000);
      _zz_PanoCore_4_ <= (1'b0);
      ulpi_ctrl_apb_regs_reg_addr <= (6'b000000);
      ulpi_ctrl_apb_regs_reg_wr_data <= (8'b00000000);
      ulpi_ctrl_apb_regs_reg_wr <= 1'b0;
      _zz_PanoCore_6__regNext <= 1'b0;
    end else begin
      if((leds_led_cntr == _zz_PanoCore_1_))begin
        leds_led_cntr <= (24'b000000000000000000000000);
      end else begin
        leds_led_cntr <= (leds_led_cntr + (24'b000000000000000000000001));
      end
      _zz_PanoCore_4_ <= _zz_PanoCore_3_;
      _zz_PanoCore_6__regNext <= _zz_PanoCore_6_;
      case(u_cpu_top_io_test_patt_apb_PADDR)
        5'b00000 : begin
          if(vo_area_test_patt_ctrl_busCtrl_doWrite)begin
            vo_area_test_patt_ctrl_apb_regs_pattern_nr <= u_cpu_top_io_test_patt_apb_PWDATA[3 : 0];
          end
        end
        5'b00100 : begin
        end
        default : begin
        end
      endcase
      case(u_cpu_top_io_ulpi_apb_PADDR)
        6'b000000 : begin
          if(ulpi_ctrl_busCtrl_doWrite)begin
            ulpi_ctrl_apb_regs_reg_addr <= u_cpu_top_io_ulpi_apb_PWDATA[5 : 0];
            ulpi_ctrl_apb_regs_reg_wr_data <= u_cpu_top_io_ulpi_apb_PWDATA[15 : 8];
            ulpi_ctrl_apb_regs_reg_wr <= _zz_PanoCore_47_[0];
          end
        end
        6'b000100 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @ (posedge toplevel_main_clk) begin
    case(u_cpu_top_io_test_patt_apb_PADDR)
      5'b00000 : begin
      end
      5'b00100 : begin
        if(vo_area_test_patt_ctrl_busCtrl_doWrite)begin
          vo_area_test_patt_ctrl_apb_regs_const_color_r <= _zz_PanoCore_7_[7 : 0];
          vo_area_test_patt_ctrl_apb_regs_const_color_g <= _zz_PanoCore_7_[15 : 8];
          vo_area_test_patt_ctrl_apb_regs_const_color_b <= _zz_PanoCore_7_[23 : 16];
        end
      end
      default : begin
      end
    endcase
  end

endmodule

module ChrontelPads (
      output  io_pads_reset_,
      output  io_pads_xclk_p,
      output  io_pads_xclk_n,
      output  io_pads_v,
      output  io_pads_h,
      output  io_pads_de,
      output reg [11:0] io_pads_d,
      input   io_vsync,
      input   io_hsync,
      input   io_de,
      input  [7:0] io_r,
      input  [7:0] io_g,
      input  [7:0] io_b,
      input   clk,
      input   reset_);
  wire  _zz_ChrontelPads_1_;
  wire  _zz_ChrontelPads_2_;
  wire  _zz_ChrontelPads_3_;
  wire  _zz_ChrontelPads_4_;
  wire  _zz_ChrontelPads_5_;
  wire  _zz_ChrontelPads_6_;
  wire  _zz_ChrontelPads_7_;
  wire  _zz_ChrontelPads_8_;
  wire  _zz_ChrontelPads_9_;
  wire  _zz_ChrontelPads_10_;
  wire  _zz_ChrontelPads_11_;
  wire  _zz_ChrontelPads_12_;
  wire  _zz_ChrontelPads_13_;
  wire  _zz_ChrontelPads_14_;
  wire  _zz_ChrontelPads_15_;
  wire  _zz_ChrontelPads_16_;
  wire  _zz_ChrontelPads_17_;
  wire  _zz_ChrontelPads_18_;
  wire  _zz_ChrontelPads_19_;
  wire  _zz_ChrontelPads_20_;
  wire  _zz_ChrontelPads_21_;
  wire  _zz_ChrontelPads_22_;
  wire  _zz_ChrontelPads_23_;
  wire  _zz_ChrontelPads_24_;
  wire  _zz_ChrontelPads_25_;
  wire  _zz_ChrontelPads_26_;
  wire  _zz_ChrontelPads_27_;
  wire  _zz_ChrontelPads_28_;
  wire  _zz_ChrontelPads_29_;
  wire  _zz_ChrontelPads_30_;
  wire  _zz_ChrontelPads_31_;
  wire  _zz_ChrontelPads_32_;
  wire  _zz_ChrontelPads_33_;
  wire  _zz_ChrontelPads_34_;
  wire  _zz_ChrontelPads_35_;
  wire  _zz_ChrontelPads_36_;
  wire  _zz_ChrontelPads_37_;
  wire  _zz_ChrontelPads_38_;
  wire  _zz_ChrontelPads_39_;
  wire  _zz_ChrontelPads_40_;
  wire  _zz_ChrontelPads_41_;
  wire  _zz_ChrontelPads_42_;
  wire  _zz_ChrontelPads_43_;
  wire  _zz_ChrontelPads_44_;
  wire  _zz_ChrontelPads_45_;
  wire  _zz_ChrontelPads_46_;
  wire  _zz_ChrontelPads_47_;
  wire  _zz_ChrontelPads_48_;
  wire  _zz_ChrontelPads_49_;
  wire  _zz_ChrontelPads_50_;
  wire  _zz_ChrontelPads_51_;
  wire  _zz_ChrontelPads_52_;
  wire  _zz_ChrontelPads_53_;
  wire  _zz_ChrontelPads_54_;
  wire  _zz_ChrontelPads_55_;
  wire  _zz_ChrontelPads_56_;
  wire  _zz_ChrontelPads_57_;
  wire  _zz_ChrontelPads_58_;
  wire  _zz_ChrontelPads_59_;
  wire  _zz_ChrontelPads_60_;
  wire  _zz_ChrontelPads_61_;
  wire  _zz_ChrontelPads_62_;
  wire  _zz_ChrontelPads_63_;
  wire  _zz_ChrontelPads_64_;
  wire  _zz_ChrontelPads_65_;
  wire  _zz_ChrontelPads_66_;
  wire  _zz_ChrontelPads_67_;
  wire  u_dcm_CLK0;
  wire  u_dcm_CLK90;
  wire  u_dcm_CLK180;
  wire  u_dcm_CLK270;
  wire  u_dcm_CLK2X;
  wire  u_dcm_CLK2X180;
  wire  u_dcm_CLKDV;
  wire  u_dcm_CLKFX;
  wire  u_dcm_CLKFX180;
  wire  u_dcm_LOCKED;
  wire [7:0] u_dcm_STATUS;
  wire  u_pad_xclk_p_Q;
  wire  oDDR2_1__Q;
  wire  u_pad_vsync_Q;
  wire  u_pad_hsync_Q;
  wire  u_pad_de_Q;
  wire  oDDR2_2__Q;
  wire  oDDR2_3__Q;
  wire  oDDR2_4__Q;
  wire  oDDR2_5__Q;
  wire  oDDR2_6__Q;
  wire  oDDR2_7__Q;
  wire  oDDR2_8__Q;
  wire  oDDR2_9__Q;
  wire  oDDR2_10__Q;
  wire  oDDR2_11__Q;
  wire  oDDR2_12__Q;
  wire  oDDR2_13__Q;
  wire  vsync_p1;
  wire  hsync_p1;
  wire  de_p1;
  wire [7:0] r_p1;
  wire [7:0] g_p1;
  wire [7:0] b_p1;
  (* keep = "true" *) reg  io_vsync_regNext;
  (* keep = "true" *) reg  io_hsync_regNext;
  (* keep = "true" *) reg  io_de_regNext;
  (* keep = "true" *) reg [7:0] io_r_regNext;
  (* keep = "true" *) reg [7:0] io_g_regNext;
  (* keep = "true" *) reg [7:0] io_b_regNext;
  wire  clk0;
  wire  clk90;
  wire  clk180;
  wire  clk270;
  wire  pad_reset;
  wire [11:0] d_p;
  wire [11:0] d_n;
  DCM_SP #( 
    .CLKDV_DIVIDE(2.0),
    .CLK_FEEDBACK("1X"),
    .CLKFX_DIVIDE(1),
    .CLKFX_MULTIPLY(2),
    .CLKIN_DIVIDE_BY_2(1'b0),
    .CLKIN_PERIOD("10.0"),
    .CLKOUT_PHASE_SHIFT("NONE"),
    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
    .DLL_FREQUENCY_MODE("LOW"),
    .DSS_MODE("NONE"),
    .DUTY_CYCLE_CORRECTION(1'b0),
    .PHASE_SHIFT(0),
    .STARTUP_WAIT(1'b0) 
  ) u_dcm ( 
    .RST(pad_reset),
    .CLKIN(clk),
    .CLKFB(clk0),
    .DSSEN(_zz_ChrontelPads_1_),
    .PSCLK(_zz_ChrontelPads_2_),
    .PSINCDEC(_zz_ChrontelPads_3_),
    .PSEN(_zz_ChrontelPads_4_),
    .PSDONE(_zz_ChrontelPads_5_),
    .CLK0(u_dcm_CLK0),
    .CLK90(u_dcm_CLK90),
    .CLK180(u_dcm_CLK180),
    .CLK270(u_dcm_CLK270),
    .CLK2X(u_dcm_CLK2X),
    .CLK2X180(u_dcm_CLK2X180),
    .CLKDV(u_dcm_CLKDV),
    .CLKFX(u_dcm_CLKFX),
    .CLKFX180(u_dcm_CLKFX180),
    .LOCKED(u_dcm_LOCKED),
    .STATUS(u_dcm_STATUS) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) u_pad_xclk_p ( 
    .D0(_zz_ChrontelPads_6_),
    .D1(_zz_ChrontelPads_7_),
    .C0(clk90),
    .C1(clk270),
    .CE(_zz_ChrontelPads_8_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_9_),
    .Q(u_pad_xclk_p_Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_1_ ( 
    .D0(_zz_ChrontelPads_10_),
    .D1(_zz_ChrontelPads_11_),
    .C0(clk90),
    .C1(clk270),
    .CE(_zz_ChrontelPads_12_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_13_),
    .Q(oDDR2_1__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) u_pad_vsync ( 
    .D0(vsync_p1),
    .D1(vsync_p1),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_14_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_15_),
    .Q(u_pad_vsync_Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) u_pad_hsync ( 
    .D0(hsync_p1),
    .D1(hsync_p1),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_16_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_17_),
    .Q(u_pad_hsync_Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) u_pad_de ( 
    .D0(de_p1),
    .D1(de_p1),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_18_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_19_),
    .Q(u_pad_de_Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_2_ ( 
    .D0(_zz_ChrontelPads_20_),
    .D1(_zz_ChrontelPads_21_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_22_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_23_),
    .Q(oDDR2_2__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_3_ ( 
    .D0(_zz_ChrontelPads_24_),
    .D1(_zz_ChrontelPads_25_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_26_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_27_),
    .Q(oDDR2_3__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_4_ ( 
    .D0(_zz_ChrontelPads_28_),
    .D1(_zz_ChrontelPads_29_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_30_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_31_),
    .Q(oDDR2_4__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_5_ ( 
    .D0(_zz_ChrontelPads_32_),
    .D1(_zz_ChrontelPads_33_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_34_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_35_),
    .Q(oDDR2_5__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_6_ ( 
    .D0(_zz_ChrontelPads_36_),
    .D1(_zz_ChrontelPads_37_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_38_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_39_),
    .Q(oDDR2_6__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_7_ ( 
    .D0(_zz_ChrontelPads_40_),
    .D1(_zz_ChrontelPads_41_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_42_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_43_),
    .Q(oDDR2_7__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_8_ ( 
    .D0(_zz_ChrontelPads_44_),
    .D1(_zz_ChrontelPads_45_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_46_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_47_),
    .Q(oDDR2_8__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_9_ ( 
    .D0(_zz_ChrontelPads_48_),
    .D1(_zz_ChrontelPads_49_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_50_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_51_),
    .Q(oDDR2_9__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_10_ ( 
    .D0(_zz_ChrontelPads_52_),
    .D1(_zz_ChrontelPads_53_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_54_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_55_),
    .Q(oDDR2_10__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_11_ ( 
    .D0(_zz_ChrontelPads_56_),
    .D1(_zz_ChrontelPads_57_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_58_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_59_),
    .Q(oDDR2_11__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_12_ ( 
    .D0(_zz_ChrontelPads_60_),
    .D1(_zz_ChrontelPads_61_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_62_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_63_),
    .Q(oDDR2_12__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_13_ ( 
    .D0(_zz_ChrontelPads_64_),
    .D1(_zz_ChrontelPads_65_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_66_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_67_),
    .Q(oDDR2_13__Q) 
  );
  assign vsync_p1 = io_vsync_regNext;
  assign hsync_p1 = io_hsync_regNext;
  assign de_p1 = io_de_regNext;
  assign r_p1 = io_r_regNext;
  assign g_p1 = io_g_regNext;
  assign b_p1 = io_b_regNext;
  assign io_pads_reset_ = reset_;
  assign pad_reset = 1'b0;
  assign _zz_ChrontelPads_1_ = 1'b0;
  assign _zz_ChrontelPads_2_ = 1'b0;
  assign _zz_ChrontelPads_3_ = 1'b0;
  assign _zz_ChrontelPads_4_ = 1'b0;
  assign _zz_ChrontelPads_5_ = 1'b0;
  assign clk0 = u_dcm_CLK0;
  assign clk90 = u_dcm_CLK90;
  assign clk180 = u_dcm_CLK180;
  assign clk270 = u_dcm_CLK270;
  assign _zz_ChrontelPads_6_ = 1'b1;
  assign _zz_ChrontelPads_7_ = 1'b0;
  assign _zz_ChrontelPads_8_ = 1'b1;
  assign _zz_ChrontelPads_9_ = 1'b0;
  assign io_pads_xclk_p = u_pad_xclk_p_Q;
  assign _zz_ChrontelPads_10_ = 1'b0;
  assign _zz_ChrontelPads_11_ = 1'b1;
  assign _zz_ChrontelPads_12_ = 1'b1;
  assign _zz_ChrontelPads_13_ = 1'b0;
  assign io_pads_xclk_n = oDDR2_1__Q;
  assign _zz_ChrontelPads_14_ = 1'b1;
  assign _zz_ChrontelPads_15_ = 1'b0;
  assign io_pads_v = u_pad_vsync_Q;
  assign _zz_ChrontelPads_16_ = 1'b1;
  assign _zz_ChrontelPads_17_ = 1'b0;
  assign io_pads_h = u_pad_hsync_Q;
  assign _zz_ChrontelPads_18_ = 1'b1;
  assign _zz_ChrontelPads_19_ = 1'b0;
  assign io_pads_de = u_pad_de_Q;
  assign d_p = {g_p1[3 : 0],b_p1[7 : 0]};
  assign d_n = {r_p1[7 : 0],g_p1[7 : 4]};
  assign _zz_ChrontelPads_20_ = d_p[0];
  assign _zz_ChrontelPads_21_ = d_n[0];
  assign _zz_ChrontelPads_22_ = 1'b1;
  assign _zz_ChrontelPads_23_ = 1'b0;
  always @ (*) begin
    io_pads_d[0] = oDDR2_2__Q;
    io_pads_d[1] = oDDR2_3__Q;
    io_pads_d[2] = oDDR2_4__Q;
    io_pads_d[3] = oDDR2_5__Q;
    io_pads_d[4] = oDDR2_6__Q;
    io_pads_d[5] = oDDR2_7__Q;
    io_pads_d[6] = oDDR2_8__Q;
    io_pads_d[7] = oDDR2_9__Q;
    io_pads_d[8] = oDDR2_10__Q;
    io_pads_d[9] = oDDR2_11__Q;
    io_pads_d[10] = oDDR2_12__Q;
    io_pads_d[11] = oDDR2_13__Q;
  end

  assign _zz_ChrontelPads_24_ = d_p[1];
  assign _zz_ChrontelPads_25_ = d_n[1];
  assign _zz_ChrontelPads_26_ = 1'b1;
  assign _zz_ChrontelPads_27_ = 1'b0;
  assign _zz_ChrontelPads_28_ = d_p[2];
  assign _zz_ChrontelPads_29_ = d_n[2];
  assign _zz_ChrontelPads_30_ = 1'b1;
  assign _zz_ChrontelPads_31_ = 1'b0;
  assign _zz_ChrontelPads_32_ = d_p[3];
  assign _zz_ChrontelPads_33_ = d_n[3];
  assign _zz_ChrontelPads_34_ = 1'b1;
  assign _zz_ChrontelPads_35_ = 1'b0;
  assign _zz_ChrontelPads_36_ = d_p[4];
  assign _zz_ChrontelPads_37_ = d_n[4];
  assign _zz_ChrontelPads_38_ = 1'b1;
  assign _zz_ChrontelPads_39_ = 1'b0;
  assign _zz_ChrontelPads_40_ = d_p[5];
  assign _zz_ChrontelPads_41_ = d_n[5];
  assign _zz_ChrontelPads_42_ = 1'b1;
  assign _zz_ChrontelPads_43_ = 1'b0;
  assign _zz_ChrontelPads_44_ = d_p[6];
  assign _zz_ChrontelPads_45_ = d_n[6];
  assign _zz_ChrontelPads_46_ = 1'b1;
  assign _zz_ChrontelPads_47_ = 1'b0;
  assign _zz_ChrontelPads_48_ = d_p[7];
  assign _zz_ChrontelPads_49_ = d_n[7];
  assign _zz_ChrontelPads_50_ = 1'b1;
  assign _zz_ChrontelPads_51_ = 1'b0;
  assign _zz_ChrontelPads_52_ = d_p[8];
  assign _zz_ChrontelPads_53_ = d_n[8];
  assign _zz_ChrontelPads_54_ = 1'b1;
  assign _zz_ChrontelPads_55_ = 1'b0;
  assign _zz_ChrontelPads_56_ = d_p[9];
  assign _zz_ChrontelPads_57_ = d_n[9];
  assign _zz_ChrontelPads_58_ = 1'b1;
  assign _zz_ChrontelPads_59_ = 1'b0;
  assign _zz_ChrontelPads_60_ = d_p[10];
  assign _zz_ChrontelPads_61_ = d_n[10];
  assign _zz_ChrontelPads_62_ = 1'b1;
  assign _zz_ChrontelPads_63_ = 1'b0;
  assign _zz_ChrontelPads_64_ = d_p[11];
  assign _zz_ChrontelPads_65_ = d_n[11];
  assign _zz_ChrontelPads_66_ = 1'b1;
  assign _zz_ChrontelPads_67_ = 1'b0;
  always @ (posedge clk) begin
    io_vsync_regNext <= io_vsync;
    io_hsync_regNext <= io_hsync;
    io_de_regNext <= io_de;
    io_r_regNext <= io_r;
    io_g_regNext <= io_g;
    io_b_regNext <= io_b;
  end

endmodule

module ChrontelPads_1_ (
      output  io_pads_reset_,
      output  io_pads_xclk_p,
      output  io_pads_v,
      output  io_pads_h,
      output  io_pads_de,
      output reg [11:0] io_pads_d,
      input   io_vsync,
      input   io_hsync,
      input   io_de,
      input  [7:0] io_r,
      input  [7:0] io_g,
      input  [7:0] io_b,
      input   clk,
      input   reset_);
  wire  _zz_ChrontelPads_1__1_;
  wire  _zz_ChrontelPads_1__2_;
  wire  _zz_ChrontelPads_1__3_;
  wire  _zz_ChrontelPads_1__4_;
  wire  _zz_ChrontelPads_1__5_;
  wire  _zz_ChrontelPads_1__6_;
  wire  _zz_ChrontelPads_1__7_;
  wire  _zz_ChrontelPads_1__8_;
  wire  _zz_ChrontelPads_1__9_;
  wire  _zz_ChrontelPads_1__10_;
  wire  _zz_ChrontelPads_1__11_;
  wire  _zz_ChrontelPads_1__12_;
  wire  _zz_ChrontelPads_1__13_;
  wire  _zz_ChrontelPads_1__14_;
  wire  _zz_ChrontelPads_1__15_;
  wire  _zz_ChrontelPads_1__16_;
  wire  _zz_ChrontelPads_1__17_;
  wire  _zz_ChrontelPads_1__18_;
  wire  _zz_ChrontelPads_1__19_;
  wire  _zz_ChrontelPads_1__20_;
  wire  _zz_ChrontelPads_1__21_;
  wire  _zz_ChrontelPads_1__22_;
  wire  _zz_ChrontelPads_1__23_;
  wire  _zz_ChrontelPads_1__24_;
  wire  _zz_ChrontelPads_1__25_;
  wire  _zz_ChrontelPads_1__26_;
  wire  _zz_ChrontelPads_1__27_;
  wire  _zz_ChrontelPads_1__28_;
  wire  _zz_ChrontelPads_1__29_;
  wire  _zz_ChrontelPads_1__30_;
  wire  _zz_ChrontelPads_1__31_;
  wire  _zz_ChrontelPads_1__32_;
  wire  _zz_ChrontelPads_1__33_;
  wire  _zz_ChrontelPads_1__34_;
  wire  _zz_ChrontelPads_1__35_;
  wire  _zz_ChrontelPads_1__36_;
  wire  _zz_ChrontelPads_1__37_;
  wire  _zz_ChrontelPads_1__38_;
  wire  _zz_ChrontelPads_1__39_;
  wire  _zz_ChrontelPads_1__40_;
  wire  _zz_ChrontelPads_1__41_;
  wire  _zz_ChrontelPads_1__42_;
  wire  _zz_ChrontelPads_1__43_;
  wire  _zz_ChrontelPads_1__44_;
  wire  _zz_ChrontelPads_1__45_;
  wire  _zz_ChrontelPads_1__46_;
  wire  _zz_ChrontelPads_1__47_;
  wire  _zz_ChrontelPads_1__48_;
  wire  _zz_ChrontelPads_1__49_;
  wire  _zz_ChrontelPads_1__50_;
  wire  _zz_ChrontelPads_1__51_;
  wire  _zz_ChrontelPads_1__52_;
  wire  _zz_ChrontelPads_1__53_;
  wire  _zz_ChrontelPads_1__54_;
  wire  _zz_ChrontelPads_1__55_;
  wire  _zz_ChrontelPads_1__56_;
  wire  _zz_ChrontelPads_1__57_;
  wire  _zz_ChrontelPads_1__58_;
  wire  _zz_ChrontelPads_1__59_;
  wire  _zz_ChrontelPads_1__60_;
  wire  _zz_ChrontelPads_1__61_;
  wire  _zz_ChrontelPads_1__62_;
  wire  _zz_ChrontelPads_1__63_;
  wire  u_dcm_CLK0;
  wire  u_dcm_CLK90;
  wire  u_dcm_CLK180;
  wire  u_dcm_CLK270;
  wire  u_dcm_CLK2X;
  wire  u_dcm_CLK2X180;
  wire  u_dcm_CLKDV;
  wire  u_dcm_CLKFX;
  wire  u_dcm_CLKFX180;
  wire  u_dcm_LOCKED;
  wire [7:0] u_dcm_STATUS;
  wire  u_pad_xclk_p_Q;
  wire  u_pad_vsync_Q;
  wire  u_pad_hsync_Q;
  wire  u_pad_de_Q;
  wire  oDDR2_1__Q;
  wire  oDDR2_2__Q;
  wire  oDDR2_3__Q;
  wire  oDDR2_4__Q;
  wire  oDDR2_5__Q;
  wire  oDDR2_6__Q;
  wire  oDDR2_7__Q;
  wire  oDDR2_8__Q;
  wire  oDDR2_9__Q;
  wire  oDDR2_10__Q;
  wire  oDDR2_11__Q;
  wire  oDDR2_12__Q;
  wire  vsync_p1;
  wire  hsync_p1;
  wire  de_p1;
  wire [7:0] r_p1;
  wire [7:0] g_p1;
  wire [7:0] b_p1;
  (* keep = "true" *) reg  io_vsync_regNext;
  (* keep = "true" *) reg  io_hsync_regNext;
  (* keep = "true" *) reg  io_de_regNext;
  (* keep = "true" *) reg [7:0] io_r_regNext;
  (* keep = "true" *) reg [7:0] io_g_regNext;
  (* keep = "true" *) reg [7:0] io_b_regNext;
  wire  clk0;
  wire  clk90;
  wire  clk180;
  wire  clk270;
  wire  pad_reset;
  wire [11:0] d_p;
  wire [11:0] d_n;
  DCM_SP #( 
    .CLKDV_DIVIDE(2.0),
    .CLK_FEEDBACK("1X"),
    .CLKFX_DIVIDE(1),
    .CLKFX_MULTIPLY(2),
    .CLKIN_DIVIDE_BY_2(1'b0),
    .CLKIN_PERIOD("10.0"),
    .CLKOUT_PHASE_SHIFT("NONE"),
    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
    .DLL_FREQUENCY_MODE("LOW"),
    .DSS_MODE("NONE"),
    .DUTY_CYCLE_CORRECTION(1'b0),
    .PHASE_SHIFT(0),
    .STARTUP_WAIT(1'b0) 
  ) u_dcm ( 
    .RST(pad_reset),
    .CLKIN(clk),
    .CLKFB(clk0),
    .DSSEN(_zz_ChrontelPads_1__1_),
    .PSCLK(_zz_ChrontelPads_1__2_),
    .PSINCDEC(_zz_ChrontelPads_1__3_),
    .PSEN(_zz_ChrontelPads_1__4_),
    .PSDONE(_zz_ChrontelPads_1__5_),
    .CLK0(u_dcm_CLK0),
    .CLK90(u_dcm_CLK90),
    .CLK180(u_dcm_CLK180),
    .CLK270(u_dcm_CLK270),
    .CLK2X(u_dcm_CLK2X),
    .CLK2X180(u_dcm_CLK2X180),
    .CLKDV(u_dcm_CLKDV),
    .CLKFX(u_dcm_CLKFX),
    .CLKFX180(u_dcm_CLKFX180),
    .LOCKED(u_dcm_LOCKED),
    .STATUS(u_dcm_STATUS) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) u_pad_xclk_p ( 
    .D0(_zz_ChrontelPads_1__6_),
    .D1(_zz_ChrontelPads_1__7_),
    .C0(clk90),
    .C1(clk270),
    .CE(_zz_ChrontelPads_1__8_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__9_),
    .Q(u_pad_xclk_p_Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) u_pad_vsync ( 
    .D0(vsync_p1),
    .D1(vsync_p1),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__10_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__11_),
    .Q(u_pad_vsync_Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) u_pad_hsync ( 
    .D0(hsync_p1),
    .D1(hsync_p1),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__12_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__13_),
    .Q(u_pad_hsync_Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) u_pad_de ( 
    .D0(de_p1),
    .D1(de_p1),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__14_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__15_),
    .Q(u_pad_de_Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_1_ ( 
    .D0(_zz_ChrontelPads_1__16_),
    .D1(_zz_ChrontelPads_1__17_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__18_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__19_),
    .Q(oDDR2_1__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_2_ ( 
    .D0(_zz_ChrontelPads_1__20_),
    .D1(_zz_ChrontelPads_1__21_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__22_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__23_),
    .Q(oDDR2_2__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_3_ ( 
    .D0(_zz_ChrontelPads_1__24_),
    .D1(_zz_ChrontelPads_1__25_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__26_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__27_),
    .Q(oDDR2_3__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_4_ ( 
    .D0(_zz_ChrontelPads_1__28_),
    .D1(_zz_ChrontelPads_1__29_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__30_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__31_),
    .Q(oDDR2_4__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_5_ ( 
    .D0(_zz_ChrontelPads_1__32_),
    .D1(_zz_ChrontelPads_1__33_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__34_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__35_),
    .Q(oDDR2_5__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_6_ ( 
    .D0(_zz_ChrontelPads_1__36_),
    .D1(_zz_ChrontelPads_1__37_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__38_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__39_),
    .Q(oDDR2_6__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_7_ ( 
    .D0(_zz_ChrontelPads_1__40_),
    .D1(_zz_ChrontelPads_1__41_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__42_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__43_),
    .Q(oDDR2_7__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_8_ ( 
    .D0(_zz_ChrontelPads_1__44_),
    .D1(_zz_ChrontelPads_1__45_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__46_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__47_),
    .Q(oDDR2_8__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_9_ ( 
    .D0(_zz_ChrontelPads_1__48_),
    .D1(_zz_ChrontelPads_1__49_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__50_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__51_),
    .Q(oDDR2_9__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_10_ ( 
    .D0(_zz_ChrontelPads_1__52_),
    .D1(_zz_ChrontelPads_1__53_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__54_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__55_),
    .Q(oDDR2_10__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_11_ ( 
    .D0(_zz_ChrontelPads_1__56_),
    .D1(_zz_ChrontelPads_1__57_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__58_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__59_),
    .Q(oDDR2_11__Q) 
  );
  ODDR2 #( 
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC") 
  ) oDDR2_12_ ( 
    .D0(_zz_ChrontelPads_1__60_),
    .D1(_zz_ChrontelPads_1__61_),
    .C0(clk0),
    .C1(clk180),
    .CE(_zz_ChrontelPads_1__62_),
    .R(pad_reset),
    .S(_zz_ChrontelPads_1__63_),
    .Q(oDDR2_12__Q) 
  );
  assign vsync_p1 = io_vsync_regNext;
  assign hsync_p1 = io_hsync_regNext;
  assign de_p1 = io_de_regNext;
  assign r_p1 = io_r_regNext;
  assign g_p1 = io_g_regNext;
  assign b_p1 = io_b_regNext;
  assign io_pads_reset_ = reset_;
  assign pad_reset = 1'b0;
  assign _zz_ChrontelPads_1__1_ = 1'b0;
  assign _zz_ChrontelPads_1__2_ = 1'b0;
  assign _zz_ChrontelPads_1__3_ = 1'b0;
  assign _zz_ChrontelPads_1__4_ = 1'b0;
  assign _zz_ChrontelPads_1__5_ = 1'b0;
  assign clk0 = u_dcm_CLK0;
  assign clk90 = u_dcm_CLK90;
  assign clk180 = u_dcm_CLK180;
  assign clk270 = u_dcm_CLK270;
  assign _zz_ChrontelPads_1__6_ = 1'b1;
  assign _zz_ChrontelPads_1__7_ = 1'b0;
  assign _zz_ChrontelPads_1__8_ = 1'b1;
  assign _zz_ChrontelPads_1__9_ = 1'b0;
  assign io_pads_xclk_p = u_pad_xclk_p_Q;
  assign _zz_ChrontelPads_1__10_ = 1'b1;
  assign _zz_ChrontelPads_1__11_ = 1'b0;
  assign io_pads_v = u_pad_vsync_Q;
  assign _zz_ChrontelPads_1__12_ = 1'b1;
  assign _zz_ChrontelPads_1__13_ = 1'b0;
  assign io_pads_h = u_pad_hsync_Q;
  assign _zz_ChrontelPads_1__14_ = 1'b1;
  assign _zz_ChrontelPads_1__15_ = 1'b0;
  assign io_pads_de = u_pad_de_Q;
  assign d_p = {g_p1[3 : 0],b_p1[7 : 0]};
  assign d_n = {r_p1[7 : 0],g_p1[7 : 4]};
  assign _zz_ChrontelPads_1__16_ = d_p[0];
  assign _zz_ChrontelPads_1__17_ = d_n[0];
  assign _zz_ChrontelPads_1__18_ = 1'b1;
  assign _zz_ChrontelPads_1__19_ = 1'b0;
  always @ (*) begin
    io_pads_d[0] = oDDR2_1__Q;
    io_pads_d[1] = oDDR2_2__Q;
    io_pads_d[2] = oDDR2_3__Q;
    io_pads_d[3] = oDDR2_4__Q;
    io_pads_d[4] = oDDR2_5__Q;
    io_pads_d[5] = oDDR2_6__Q;
    io_pads_d[6] = oDDR2_7__Q;
    io_pads_d[7] = oDDR2_8__Q;
    io_pads_d[8] = oDDR2_9__Q;
    io_pads_d[9] = oDDR2_10__Q;
    io_pads_d[10] = oDDR2_11__Q;
    io_pads_d[11] = oDDR2_12__Q;
  end

  assign _zz_ChrontelPads_1__20_ = d_p[1];
  assign _zz_ChrontelPads_1__21_ = d_n[1];
  assign _zz_ChrontelPads_1__22_ = 1'b1;
  assign _zz_ChrontelPads_1__23_ = 1'b0;
  assign _zz_ChrontelPads_1__24_ = d_p[2];
  assign _zz_ChrontelPads_1__25_ = d_n[2];
  assign _zz_ChrontelPads_1__26_ = 1'b1;
  assign _zz_ChrontelPads_1__27_ = 1'b0;
  assign _zz_ChrontelPads_1__28_ = d_p[3];
  assign _zz_ChrontelPads_1__29_ = d_n[3];
  assign _zz_ChrontelPads_1__30_ = 1'b1;
  assign _zz_ChrontelPads_1__31_ = 1'b0;
  assign _zz_ChrontelPads_1__32_ = d_p[4];
  assign _zz_ChrontelPads_1__33_ = d_n[4];
  assign _zz_ChrontelPads_1__34_ = 1'b1;
  assign _zz_ChrontelPads_1__35_ = 1'b0;
  assign _zz_ChrontelPads_1__36_ = d_p[5];
  assign _zz_ChrontelPads_1__37_ = d_n[5];
  assign _zz_ChrontelPads_1__38_ = 1'b1;
  assign _zz_ChrontelPads_1__39_ = 1'b0;
  assign _zz_ChrontelPads_1__40_ = d_p[6];
  assign _zz_ChrontelPads_1__41_ = d_n[6];
  assign _zz_ChrontelPads_1__42_ = 1'b1;
  assign _zz_ChrontelPads_1__43_ = 1'b0;
  assign _zz_ChrontelPads_1__44_ = d_p[7];
  assign _zz_ChrontelPads_1__45_ = d_n[7];
  assign _zz_ChrontelPads_1__46_ = 1'b1;
  assign _zz_ChrontelPads_1__47_ = 1'b0;
  assign _zz_ChrontelPads_1__48_ = d_p[8];
  assign _zz_ChrontelPads_1__49_ = d_n[8];
  assign _zz_ChrontelPads_1__50_ = 1'b1;
  assign _zz_ChrontelPads_1__51_ = 1'b0;
  assign _zz_ChrontelPads_1__52_ = d_p[9];
  assign _zz_ChrontelPads_1__53_ = d_n[9];
  assign _zz_ChrontelPads_1__54_ = 1'b1;
  assign _zz_ChrontelPads_1__55_ = 1'b0;
  assign _zz_ChrontelPads_1__56_ = d_p[10];
  assign _zz_ChrontelPads_1__57_ = d_n[10];
  assign _zz_ChrontelPads_1__58_ = 1'b1;
  assign _zz_ChrontelPads_1__59_ = 1'b0;
  assign _zz_ChrontelPads_1__60_ = d_p[11];
  assign _zz_ChrontelPads_1__61_ = d_n[11];
  assign _zz_ChrontelPads_1__62_ = 1'b1;
  assign _zz_ChrontelPads_1__63_ = 1'b0;
  always @ (posedge clk) begin
    io_vsync_regNext <= io_vsync;
    io_hsync_regNext <= io_hsync;
    io_de_regNext <= io_de;
    io_r_regNext <= io_r;
    io_g_regNext <= io_g;
    io_b_regNext <= io_b;
  end

endmodule

module Pano (
      input   osc_clk,
      output  led_red,
      output  led_green,
      output  led_blue,
      input   pano_button,
      output  dvi_reset_,
      output  dvi_xclk_p,
      output  dvi_xclk_n,
      output  dvi_v,
      output  dvi_h,
      output  dvi_de,
      output [11:0] dvi_d,
      output  hdmi_reset_,
      output  hdmi_xclk_p,
      output  hdmi_v,
      output  hdmi_h,
      output  hdmi_de,
      output [11:0] hdmi_d,
      output  gmii_rst_,
      input   gmii_rx_clk,
      input   gmii_rx_dv,
      input   gmii_rx_er,
      input  [7:0] gmii_rx_d,
      input   gmii_tx_gclk,
      input   gmii_tx_clk,
      output  gmii_tx_en,
      output  gmii_tx_er,
      output [7:0] gmii_tx_d,
      input   gmii_col,
      input   gmii_crs,
      output  gmii_mdio_mdc,
      output  usb_reset_,
      output  usb_clk,
      input   ulpi_clk,
      input   ulpi_direction,
      output  ulpi_stp,
      input   ulpi_nxt,
      output  ulpi_reset,
      inout  dvi_spc,
      inout  dvi_spd,
      inout  gmii_mdio_mdio,
      inout [7:0] ulpi_data);
  wire  _zz_Pano_26_;
  wire  _zz_Pano_27_;
  wire  _zz_Pano_28_;
  wire  _zz_Pano_29_;
  wire  _zz_Pano_30_;
  wire  _zz_Pano_31_;
  wire  _zz_Pano_32_;
  wire  _zz_Pano_33_;
  wire  _zz_Pano_34_;
  wire  _zz_Pano_35_;
  wire  _zz_Pano_36_;
  wire  _zz_Pano_37_;
  wire  _zz_Pano_38_;
  wire  _zz_Pano_39_;
  wire  _zz_Pano_40_;
  wire  u_main_clk_gen_CLKFX;
  wire  u_main_clk_gen_CLKFX180;
  wire  u_main_clk_gen_CLKFXDV;
  wire  u_main_clk_gen_LOCKED;
  wire  u_main_clk_gen_PROGDONE;
  wire  u_vo_clk_gen_CLKFX;
  wire  u_vo_clk_gen_CLKFX180;
  wire  u_vo_clk_gen_CLKFXDV;
  wire  u_vo_clk_gen_LOCKED;
  wire  u_vo_clk_gen_PROGDONE;
  wire  u_usb_clk_gen_CLKFX;
  wire  u_usb_clk_gen_CLKFX180;
  wire  u_usb_clk_gen_CLKFXDV;
  wire  u_usb_clk_gen_LOCKED;
  wire  u_usb_clk_gen_PROGDONE;
  wire  core_u_pano_core_io_led_red;
  wire  core_u_pano_core_io_led_green;
  wire  core_u_pano_core_io_led_blue;
  wire  core_u_pano_core_io_dvi_ctrl_scl_write;
  wire  core_u_pano_core_io_dvi_ctrl_scl_writeEnable;
  wire  core_u_pano_core_io_dvi_ctrl_sda_write;
  wire  core_u_pano_core_io_dvi_ctrl_sda_writeEnable;
  wire  core_u_pano_core_io_gmii_tx_en;
  wire  core_u_pano_core_io_gmii_tx_er;
  wire [7:0] core_u_pano_core_io_gmii_tx_d;
  wire  core_u_pano_core_io_gmii_mdio_mdc;
  wire  core_u_pano_core_io_gmii_mdio_mdio_write;
  wire  core_u_pano_core_io_gmii_mdio_mdio_writeEnable;
  wire [7:0] core_u_pano_core_io_ulpi_data_write;
  wire [7:0] core_u_pano_core_io_ulpi_data_writeEnable;
  wire  core_u_pano_core_io_ulpi_stp;
  wire  core_u_pano_core_io_ulpi_reset;
  wire  core_u_pano_core_io_vo_vsync;
  wire  core_u_pano_core_io_vo_hsync;
  wire  core_u_pano_core_io_vo_blank_;
  wire  core_u_pano_core_io_vo_de;
  wire [7:0] core_u_pano_core_io_vo_r;
  wire [7:0] core_u_pano_core_io_vo_g;
  wire [7:0] core_u_pano_core_io_vo_b;
  wire  core_u_dvi_io_pads_reset_;
  wire  core_u_dvi_io_pads_xclk_p;
  wire  core_u_dvi_io_pads_xclk_n;
  wire  core_u_dvi_io_pads_v;
  wire  core_u_dvi_io_pads_h;
  wire  core_u_dvi_io_pads_de;
  wire [11:0] core_u_dvi_io_pads_d;
  wire  core_u_hdmi_io_pads_reset_;
  wire  core_u_hdmi_io_pads_xclk_p;
  wire  core_u_hdmi_io_pads_v;
  wire  core_u_hdmi_io_pads_h;
  wire  core_u_hdmi_io_pads_de;
  wire [11:0] core_u_hdmi_io_pads_d;
  wire  _zz_Pano_41_;
  wire  _zz_Pano_42_;
  reg  _zz_Pano_1_;
  reg  _zz_Pano_2_;
  reg  _zz_Pano_3_;
  reg  _zz_Pano_4_;
  reg  _zz_Pano_5_;
  reg  _zz_Pano_6_;
  reg  _zz_Pano_7_;
  reg  _zz_Pano_8_;
  reg  _zz_Pano_9_;
  reg  _zz_Pano_10_;
  reg  _zz_Pano_11_;
  wire  _zz_Pano_12_;
  wire  _zz_Pano_13_;
  wire  _zz_Pano_14_;
  wire  _zz_Pano_15_;
  wire  _zz_Pano_16_;
  wire  _zz_Pano_17_;
  wire  _zz_Pano_18_;
  wire  _zz_Pano_19_;
  wire  _zz_Pano_20_;
  wire [7:0] _zz_Pano_21_;
  wire [7:0] _zz_Pano_22_;
  wire [7:0] _zz_Pano_23_;
  wire  main_clk_raw;
  wire  main_reset_;
  reg  main_reset_gen_reset_unbuffered_;
  reg [4:0] main_reset_gen_reset_cntr = (5'b00000);
  wire [4:0] _zz_Pano_24_;
  reg  main_reset_gen_reset_unbuffered__regNext;
  wire  main_clk;
  wire  vo_clk;
  wire  vo_reset_;
  reg  vo_reset_gen_reset_unbuffered_;
  reg [4:0] vo_reset_gen_reset_cntr = (5'b00000);
  wire [4:0] _zz_Pano_25_;
  reg  vo_reset_gen_reset_unbuffered__regNext;
  reg [23:0] gmii_rx_green_counter;
  reg [23:0] core_red_counter;
  wire  core_vo_vsync;
  wire  core_vo_hsync;
  wire  core_vo_blank_;
  wire  core_vo_de;
  wire [7:0] core_vo_r;
  wire [7:0] core_vo_g;
  wire [7:0] core_vo_b;
  assign _zz_Pano_41_ = (main_reset_gen_reset_cntr != _zz_Pano_24_);
  assign _zz_Pano_42_ = (vo_reset_gen_reset_cntr != _zz_Pano_25_);
  DCM_CLKGEN #( 
    .CLKFX_DIVIDE(20),
    .CLKFXDV_DIVIDE(2),
    .CLKFX_MD_MAX(0.0),
    .CLKFX_MULTIPLY(4),
    .CLKIN_PERIOD("8.0"),
    .SPREAD_SPECTRUM("NONE"),
    .STARTUP_WAIT(1'b0) 
  ) u_main_clk_gen ( 
    .CLKIN(osc_clk),
    .CLKFX(u_main_clk_gen_CLKFX),
    .CLKFX180(u_main_clk_gen_CLKFX180),
    .CLKFXDV(u_main_clk_gen_CLKFXDV),
    .RST(_zz_Pano_26_),
    .FREEZEDCM(_zz_Pano_27_),
    .LOCKED(u_main_clk_gen_LOCKED),
    .PROGCLK(_zz_Pano_28_),
    .PROGDATA(_zz_Pano_29_),
    .PROGEN(_zz_Pano_30_),
    .PROGDONE(u_main_clk_gen_PROGDONE) 
  );
  DCM_CLKGEN #( 
    .CLKFX_DIVIDE(125),
    .CLKFXDV_DIVIDE(2),
    .CLKFX_MD_MAX(0.0),
    .CLKFX_MULTIPLY(148),
    .CLKIN_PERIOD("8.0"),
    .SPREAD_SPECTRUM("NONE"),
    .STARTUP_WAIT(1'b0) 
  ) u_vo_clk_gen ( 
    .CLKIN(osc_clk),
    .CLKFX(u_vo_clk_gen_CLKFX),
    .CLKFX180(u_vo_clk_gen_CLKFX180),
    .CLKFXDV(u_vo_clk_gen_CLKFXDV),
    .RST(_zz_Pano_31_),
    .FREEZEDCM(_zz_Pano_32_),
    .LOCKED(u_vo_clk_gen_LOCKED),
    .PROGCLK(_zz_Pano_33_),
    .PROGDATA(_zz_Pano_34_),
    .PROGEN(_zz_Pano_35_),
    .PROGDONE(u_vo_clk_gen_PROGDONE) 
  );
  DCM_CLKGEN #( 
    .CLKFX_DIVIDE(125),
    .CLKFXDV_DIVIDE(2),
    .CLKFX_MD_MAX(0.0),
    .CLKFX_MULTIPLY(24),
    .CLKIN_PERIOD("8.0"),
    .SPREAD_SPECTRUM("NONE"),
    .STARTUP_WAIT(1'b0) 
  ) u_usb_clk_gen ( 
    .CLKIN(osc_clk),
    .CLKFX(u_usb_clk_gen_CLKFX),
    .CLKFX180(u_usb_clk_gen_CLKFX180),
    .CLKFXDV(u_usb_clk_gen_CLKFXDV),
    .RST(_zz_Pano_36_),
    .FREEZEDCM(_zz_Pano_37_),
    .LOCKED(u_usb_clk_gen_LOCKED),
    .PROGCLK(_zz_Pano_38_),
    .PROGDATA(_zz_Pano_39_),
    .PROGEN(_zz_Pano_40_),
    .PROGDONE(u_usb_clk_gen_PROGDONE) 
  );
  PanoCore core_u_pano_core ( 
    .io_led_red(core_u_pano_core_io_led_red),
    .io_led_green(core_u_pano_core_io_led_green),
    .io_led_blue(core_u_pano_core_io_led_blue),
    .io_switch_(pano_button),
    .io_dvi_ctrl_scl_read(_zz_Pano_12_),
    .io_dvi_ctrl_scl_write(core_u_pano_core_io_dvi_ctrl_scl_write),
    .io_dvi_ctrl_scl_writeEnable(core_u_pano_core_io_dvi_ctrl_scl_writeEnable),
    .io_dvi_ctrl_sda_read(_zz_Pano_15_),
    .io_dvi_ctrl_sda_write(core_u_pano_core_io_dvi_ctrl_sda_write),
    .io_dvi_ctrl_sda_writeEnable(core_u_pano_core_io_dvi_ctrl_sda_writeEnable),
    .io_gmii_rx_clk(gmii_rx_clk),
    .io_gmii_rx_dv(gmii_rx_dv),
    .io_gmii_rx_er(gmii_rx_er),
    .io_gmii_rx_d(gmii_rx_d),
    .io_gmii_tx_gclk(gmii_tx_gclk),
    .io_gmii_tx_clk(gmii_tx_clk),
    .io_gmii_tx_en(core_u_pano_core_io_gmii_tx_en),
    .io_gmii_tx_er(core_u_pano_core_io_gmii_tx_er),
    .io_gmii_tx_d(core_u_pano_core_io_gmii_tx_d),
    .io_gmii_col(gmii_col),
    .io_gmii_crs(gmii_crs),
    .io_gmii_mdio_mdc(core_u_pano_core_io_gmii_mdio_mdc),
    .io_gmii_mdio_mdio_read(_zz_Pano_18_),
    .io_gmii_mdio_mdio_write(core_u_pano_core_io_gmii_mdio_mdio_write),
    .io_gmii_mdio_mdio_writeEnable(core_u_pano_core_io_gmii_mdio_mdio_writeEnable),
    .io_ulpi_clk(ulpi_clk),
    .io_ulpi_data_read(_zz_Pano_21_),
    .io_ulpi_data_write(core_u_pano_core_io_ulpi_data_write),
    .io_ulpi_data_writeEnable(core_u_pano_core_io_ulpi_data_writeEnable),
    .io_ulpi_direction(ulpi_direction),
    .io_ulpi_stp(core_u_pano_core_io_ulpi_stp),
    .io_ulpi_nxt(ulpi_nxt),
    .io_ulpi_reset(core_u_pano_core_io_ulpi_reset),
    .io_vo_vsync(core_u_pano_core_io_vo_vsync),
    .io_vo_hsync(core_u_pano_core_io_vo_hsync),
    .io_vo_blank_(core_u_pano_core_io_vo_blank_),
    .io_vo_de(core_u_pano_core_io_vo_de),
    .io_vo_r(core_u_pano_core_io_vo_r),
    .io_vo_g(core_u_pano_core_io_vo_g),
    .io_vo_b(core_u_pano_core_io_vo_b),
    .toplevel_main_clk(main_clk),
    .toplevel_main_reset_(main_reset_),
    .toplevel_vo_clk(vo_clk),
    .toplevel_vo_reset_(vo_reset_) 
  );
  ChrontelPads core_u_dvi ( 
    .io_pads_reset_(core_u_dvi_io_pads_reset_),
    .io_pads_xclk_p(core_u_dvi_io_pads_xclk_p),
    .io_pads_xclk_n(core_u_dvi_io_pads_xclk_n),
    .io_pads_v(core_u_dvi_io_pads_v),
    .io_pads_h(core_u_dvi_io_pads_h),
    .io_pads_de(core_u_dvi_io_pads_de),
    .io_pads_d(core_u_dvi_io_pads_d),
    .io_vsync(core_vo_vsync),
    .io_hsync(core_vo_hsync),
    .io_de(core_vo_de),
    .io_r(core_vo_r),
    .io_g(core_vo_g),
    .io_b(core_vo_b),
    .clk(vo_clk),
    .reset_(vo_reset_) 
  );
  ChrontelPads_1_ core_u_hdmi ( 
    .io_pads_reset_(core_u_hdmi_io_pads_reset_),
    .io_pads_xclk_p(core_u_hdmi_io_pads_xclk_p),
    .io_pads_v(core_u_hdmi_io_pads_v),
    .io_pads_h(core_u_hdmi_io_pads_h),
    .io_pads_de(core_u_hdmi_io_pads_de),
    .io_pads_d(core_u_hdmi_io_pads_d),
    .io_vsync(core_vo_vsync),
    .io_hsync(core_vo_hsync),
    .io_de(core_vo_de),
    .io_r(core_vo_r),
    .io_g(core_vo_g),
    .io_b(core_vo_b),
    .clk(vo_clk),
    .reset_(vo_reset_) 
  );
  assign dvi_spc = _zz_Pano_11_ ? _zz_Pano_13_ : 1'bz;
  assign dvi_spd = _zz_Pano_10_ ? _zz_Pano_16_ : 1'bz;
  assign gmii_mdio_mdio = _zz_Pano_9_ ? _zz_Pano_19_ : 1'bz;
  assign ulpi_data[0] = _zz_Pano_8_ ? _zz_Pano_22_[0] : 1'bz;
  assign ulpi_data[1] = _zz_Pano_7_ ? _zz_Pano_22_[1] : 1'bz;
  assign ulpi_data[2] = _zz_Pano_6_ ? _zz_Pano_22_[2] : 1'bz;
  assign ulpi_data[3] = _zz_Pano_5_ ? _zz_Pano_22_[3] : 1'bz;
  assign ulpi_data[4] = _zz_Pano_4_ ? _zz_Pano_22_[4] : 1'bz;
  assign ulpi_data[5] = _zz_Pano_3_ ? _zz_Pano_22_[5] : 1'bz;
  assign ulpi_data[6] = _zz_Pano_2_ ? _zz_Pano_22_[6] : 1'bz;
  assign ulpi_data[7] = _zz_Pano_1_ ? _zz_Pano_22_[7] : 1'bz;
  always @ (*) begin
    _zz_Pano_1_ = 1'b0;
    if(_zz_Pano_23_[7])begin
      _zz_Pano_1_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_2_ = 1'b0;
    if(_zz_Pano_23_[6])begin
      _zz_Pano_2_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_3_ = 1'b0;
    if(_zz_Pano_23_[5])begin
      _zz_Pano_3_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_4_ = 1'b0;
    if(_zz_Pano_23_[4])begin
      _zz_Pano_4_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_5_ = 1'b0;
    if(_zz_Pano_23_[3])begin
      _zz_Pano_5_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_6_ = 1'b0;
    if(_zz_Pano_23_[2])begin
      _zz_Pano_6_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_7_ = 1'b0;
    if(_zz_Pano_23_[1])begin
      _zz_Pano_7_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_8_ = 1'b0;
    if(_zz_Pano_23_[0])begin
      _zz_Pano_8_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_9_ = 1'b0;
    if(_zz_Pano_20_)begin
      _zz_Pano_9_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_10_ = 1'b0;
    if(_zz_Pano_17_)begin
      _zz_Pano_10_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_Pano_11_ = 1'b0;
    if(_zz_Pano_14_)begin
      _zz_Pano_11_ = 1'b1;
    end
  end

  assign gmii_rst_ = 1'b1;
  assign usb_reset_ = 1'b1;
  assign main_clk_raw = u_main_clk_gen_CLKFX;
  assign _zz_Pano_26_ = 1'b0;
  assign _zz_Pano_27_ = 1'b0;
  assign _zz_Pano_28_ = 1'b0;
  assign _zz_Pano_29_ = 1'b0;
  assign _zz_Pano_30_ = 1'b0;
  always @ (*) begin
    main_reset_gen_reset_unbuffered_ = 1'b1;
    if(_zz_Pano_41_)begin
      main_reset_gen_reset_unbuffered_ = 1'b0;
    end
  end

  assign _zz_Pano_24_[4 : 0] = (5'b11111);
  assign main_reset_ = main_reset_gen_reset_unbuffered__regNext;
  assign main_clk = main_clk_raw;
  assign vo_clk = u_vo_clk_gen_CLKFX;
  assign _zz_Pano_31_ = 1'b0;
  assign _zz_Pano_32_ = 1'b0;
  assign _zz_Pano_33_ = 1'b0;
  assign _zz_Pano_34_ = 1'b0;
  assign _zz_Pano_35_ = 1'b0;
  always @ (*) begin
    vo_reset_gen_reset_unbuffered_ = 1'b1;
    if(_zz_Pano_42_)begin
      vo_reset_gen_reset_unbuffered_ = 1'b0;
    end
  end

  assign _zz_Pano_25_[4 : 0] = (5'b11111);
  assign vo_reset_ = vo_reset_gen_reset_unbuffered__regNext;
  assign usb_clk = u_usb_clk_gen_CLKFX;
  assign _zz_Pano_36_ = 1'b0;
  assign _zz_Pano_37_ = 1'b0;
  assign _zz_Pano_38_ = 1'b0;
  assign _zz_Pano_39_ = 1'b0;
  assign _zz_Pano_40_ = 1'b0;
  assign led_red = core_u_pano_core_io_led_red;
  assign led_green = core_u_pano_core_io_led_green;
  assign led_blue = core_u_pano_core_io_led_blue;
  assign _zz_Pano_13_ = core_u_pano_core_io_dvi_ctrl_scl_write;
  assign _zz_Pano_14_ = core_u_pano_core_io_dvi_ctrl_scl_writeEnable;
  assign _zz_Pano_16_ = core_u_pano_core_io_dvi_ctrl_sda_write;
  assign _zz_Pano_17_ = core_u_pano_core_io_dvi_ctrl_sda_writeEnable;
  assign gmii_tx_en = core_u_pano_core_io_gmii_tx_en;
  assign gmii_tx_er = core_u_pano_core_io_gmii_tx_er;
  assign gmii_tx_d = core_u_pano_core_io_gmii_tx_d;
  assign gmii_mdio_mdc = core_u_pano_core_io_gmii_mdio_mdc;
  assign _zz_Pano_19_ = core_u_pano_core_io_gmii_mdio_mdio_write;
  assign _zz_Pano_20_ = core_u_pano_core_io_gmii_mdio_mdio_writeEnable;
  assign _zz_Pano_22_ = core_u_pano_core_io_ulpi_data_write;
  assign _zz_Pano_23_ = core_u_pano_core_io_ulpi_data_writeEnable;
  assign ulpi_stp = core_u_pano_core_io_ulpi_stp;
  assign ulpi_reset = core_u_pano_core_io_ulpi_reset;
  assign core_vo_vsync = core_u_pano_core_io_vo_vsync;
  assign core_vo_hsync = core_u_pano_core_io_vo_hsync;
  assign core_vo_blank_ = core_u_pano_core_io_vo_blank_;
  assign core_vo_de = core_u_pano_core_io_vo_de;
  assign core_vo_r = core_u_pano_core_io_vo_r;
  assign core_vo_g = core_u_pano_core_io_vo_g;
  assign core_vo_b = core_u_pano_core_io_vo_b;
  assign dvi_reset_ = core_u_dvi_io_pads_reset_;
  assign dvi_xclk_p = core_u_dvi_io_pads_xclk_p;
  assign dvi_xclk_n = core_u_dvi_io_pads_xclk_n;
  assign dvi_v = core_u_dvi_io_pads_v;
  assign dvi_h = core_u_dvi_io_pads_h;
  assign dvi_de = core_u_dvi_io_pads_de;
  assign dvi_d = core_u_dvi_io_pads_d;
  assign hdmi_reset_ = core_u_hdmi_io_pads_reset_;
  assign hdmi_xclk_p = core_u_hdmi_io_pads_xclk_p;
  assign hdmi_v = core_u_hdmi_io_pads_v;
  assign hdmi_h = core_u_hdmi_io_pads_h;
  assign hdmi_de = core_u_hdmi_io_pads_de;
  assign hdmi_d = core_u_hdmi_io_pads_d;
  assign _zz_Pano_12_ = dvi_spc;
  assign _zz_Pano_15_ = dvi_spd;
  assign _zz_Pano_18_ = gmii_mdio_mdio;
  assign _zz_Pano_21_ = ulpi_data;
  always @ (posedge main_clk_raw) begin
    if(_zz_Pano_41_)begin
      main_reset_gen_reset_cntr <= (main_reset_gen_reset_cntr + (5'b00001));
    end
  end

  always @ (posedge main_clk_raw) begin
    main_reset_gen_reset_unbuffered__regNext <= main_reset_gen_reset_unbuffered_;
  end

  always @ (posedge vo_clk) begin
    if(_zz_Pano_42_)begin
      vo_reset_gen_reset_cntr <= (vo_reset_gen_reset_cntr + (5'b00001));
    end
  end

  always @ (posedge vo_clk) begin
    vo_reset_gen_reset_unbuffered__regNext <= vo_reset_gen_reset_unbuffered_;
  end

  always @ (posedge gmii_rx_clk) begin
    gmii_rx_green_counter <= (gmii_rx_green_counter + (24'b000000000000000000000001));
  end

  always @ (posedge main_clk) begin
    core_red_counter <= (core_red_counter + (24'b000000000000000000000001));
  end

endmodule

