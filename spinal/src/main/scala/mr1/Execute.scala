
package mr1

import spinal.core._

case class Execute2Writeback(config: MR1Config) extends Bundle {

    val valid           = Bool
    val ld_active       = Bool
    val ld_addr_lsb     = UInt(2 bits)
    val ld_data_size    = Bits(2 bits)
    val ld_data_signed  = Bool

    val rd_wr           = Bool
    val rd_waddr        = UInt(5 bits)
    val rd_wdata        = Bits(32 bits)

    def init() : Execute2Writeback = {
        valid init(False)
        this
    }
}

case class Writeback2Execute(config: MR1Config) extends Bundle {
    val stall           = Bool
}

class Execute(config: MR1Config) extends Component {

    val hasMul   = config.hasMul
    val hasDiv   = config.hasDiv
    val hasCsr   = config.hasCsr
    val hasFence = config.hasFence

    val io = new Bundle {
        val d2e         = in(Decode2Execute(config))
        val e2d         = out(Execute2Decode(config))

        val rd_update   = out(RegRdUpdate(config))

        val e2w         = out(Reg(Execute2Writeback(config)) init)
        val w2e         = in(Writeback2Execute(config))

        val data_req    = DataReqIntfc(config)

        val d2e_rvfi    = if (config.hasFormal) in(     RVFI(config)      )                        else null
        val e2w_rvfi    = if (config.hasFormal) out(Reg(RVFI(config)) init).setName("io_e2w_rvfi") else null
    }

    val e2d_stall_d = RegNext(io.e2d.stall, False)

    val exe_start = io.d2e.valid && !e2d_stall_d
    val exe_end   = io.d2e.valid && !io.e2d.stall && !io.w2e.stall

    val itype           = InstrType()
    val instr           = Bits(32 bits)
    val funct3          = Bits(3 bits)

    itype           := io.d2e.itype
    instr           := io.d2e.instr
    funct3          := instr(14 downto 12)

    val op1_33      = S(io.d2e.op1_33)
    val op2_33      = S(io.d2e.op2_33)
    val op1_op2_lsb = S(io.d2e.op1_op2_lsb)
    val op1         = S(io.d2e.op1_33)(31 downto 0)
    val op2         = S(io.d2e.op2_33)(31 downto 0)
    val rs2         = io.d2e.rs2_imm
    val imm         = S(io.d2e.rs2_imm(20 downto 0))
    val rd_addr     = io.d2e.rd_addr

    val alu = new Area {
        val rd_wr    = False
        val rd_wdata = UInt(32 bits)

        // Decode stage already op1 + op2 for lower 8 bits. Now do the upper part.
        val op_cin = op1_op2_lsb(8)

        val alu_add_33 = U((op1_33(32 downto 8) @@ op_cin) + (op2_33(32 downto 8) @@ op_cin))(25 downto 1) @@ U(op1_op2_lsb(7 downto 0))

        val rd_wdata_alu_add = alu_add_33(31 downto 0)
        val rd_wdata_alu_lt  = U(alu_add_33(32)).resize(32)

        rd_wdata := rd_wdata_alu_add

        switch(itype){
            is(InstrType.ALU_ADD){
                rd_wr    := True
                rd_wdata := rd_wdata_alu_add
            }
            is(InstrType.ALU){
                switch(funct3){
                    is(B"010",B"011"){  // SLT, SLTU
                        rd_wr    := True
                        rd_wdata := rd_wdata_alu_lt
                    }
                    is(B"100"){         // XOR
                        rd_wr    := True
                        rd_wdata := U(op1 ^ op2)
                    }
                    is(B"110"){         // OR
                        rd_wr    := True
                        rd_wdata := U(op1 | op2)
                    }
                    is(B"111"){         // AND
                        rd_wr    := True
                        rd_wdata := U(op1 & op2)
                    }
                }
            }
            is(InstrType.MULDIV){
                if (config.hasMul) {
                    val op1_33 = op1.resize(33)
                    val op2_33 = op2.resize(33)
                    val upper = False

                    switch(funct3){
                        is(B"000"){         // MUL
                            rd_wr   := True
                            upper   := False
                            op1_33 := S(U(op1).resize(33))
                            op2_33 := S(U(op2).resize(33))
                        }
                        is(B"001"){         // MULH
                            rd_wr   := True
                            upper   := True
                        }
                        is(B"010"){         // MULHSU
                            rd_wr   := True
                            upper   := True
                            op2_33 := S(U(op2).resize(33))
                        }
                        is(B"011"){         // MULHU
                            rd_wr   := True
                            upper   := True
                            op1_33 := S(U(op1).resize(33))
                            op2_33 := S(U(op2).resize(33))
                        }
                    }

                    val result = op1_33 * op2_33
                    rd_wdata := upper ? U(result(63 downto 32)) | U(result(31 downto 0))
                }
            }
        }
    }

    val shift = new Area {
        val rd_wr       = (itype === InstrType.SHIFT)
        val rd_wdata    = UInt(32 bits)
        val shamt       = U(op2(4 downto 0))
        val shleft      = !funct3(2)
        val op1_33      = instr(30) ? S(op1(31) ## op1) | S(B"0" ## op1)

        rd_wdata := U(shleft ? (op1_33 |<< shamt) | (op1_33 |>> shamt))(31 downto 0)
    }

    val jump = new Area {

        val take_jump     = False
        val pc_jump_valid = False
        val pc_jump       = UInt(config.pcSize bits)

        val clr_lsb = False

        val pc       = UInt(config.pcSize bits)
        val pc_op1   = SInt(config.pcSize bits)

        pc          := io.d2e.pc
        pc_op1      := S(pc)

        val pc_plus4 = pc + 4


        val rd_wr    = False
        val rd_wdata = pc_plus4.resize(32)

        switch(itype){
            is(InstrType.B){

                val op1_eq_op2 = (op1 === op2)
                val op1_lt_op2 = alu.rd_wdata_alu_lt(0)

                val branch_cond = False
                switch(funct3){
                    is(B"000")       { branch_cond :=  op1_eq_op2 } // BEQ
                    is(B"001")       { branch_cond := !op1_eq_op2 } // BNE
                    is(B"100",B"110"){ branch_cond :=  op1_lt_op2 } // BLT, BLTU
                    is(B"101",B"111"){ branch_cond := !op1_lt_op2 } // BGE, BGEU
                }

                pc_jump_valid := True
                take_jump     := branch_cond
            }
            is(InstrType.JAL){
                pc_jump_valid := True
                take_jump     := True

                rd_wr    := True
            }
            is(InstrType.JALR){
                pc_jump_valid := True
                pc_op1        := op1
                take_jump     := True

                clr_lsb  := True
                rd_wr    := True
            }
        }

        // Clear LSB for JALR ops
        pc_jump := (take_jump ? U(pc_op1 + imm)  |
                                pc_plus4         ) & ~(U(clr_lsb).resize(config.pcSize))

    }

    val lsu = new Area {

        val lsu_stall = Bool

        val rd_wr    = False
        val size     = funct3(1 downto 0)

        val lsu_addr = UInt(32 bits)
        lsu_addr    := alu.rd_wdata_alu_add

        io.data_req.valid   := io.d2e.valid && (itype === InstrType.L || itype === InstrType.S) && !io.w2e.stall
        io.data_req.addr    := lsu_addr.resize(config.dataAddrSize)
        io.data_req.wr      := (itype === InstrType.S)
        io.data_req.size    := size
        io.data_req.data    := size.mux(
                                B"00"   -> rs2( 7 downto 0) ## rs2( 7 downto 0) ## rs2( 7 downto 0) ## rs2( 7 downto 0),
                                B"01"   -> rs2(15 downto 0) ## rs2(15 downto 0),
                                default -> rs2)

        lsu_stall := io.data_req.valid && !io.data_req.ready
    }

    val rd_wr    = io.d2e.valid && (alu.rd_wr | jump.rd_wr | shift.rd_wr) && (rd_addr =/= 0)
    val rd_waddr = rd_addr
    val rd_wdata = B((alu.rd_wdata.range   -> alu.rd_wr))   & B(alu.rd_wdata)   |
                   B((jump.rd_wdata.range  -> jump.rd_wr))  & B(jump.rd_wdata)  |
                   B((shift.rd_wdata.range -> shift.rd_wr)) & B(shift.rd_wdata)

    io.e2d.stall         := lsu.lsu_stall || io.w2e.stall
    io.e2d.pc_jump_valid := io.d2e.valid && jump.pc_jump_valid
    io.e2d.pc_jump       := jump.pc_jump

    // Feedback for RAW testing and bypass
    io.rd_update.rd_waddr_valid := io.d2e.valid && io.d2e.rd_valid
    io.rd_update.rd_waddr       := rd_addr
    io.rd_update.rd_wdata_valid := rd_wr
    io.rd_update.rd_wdata       := rd_wdata

    val formal = if (config.hasFormal) new Area {

        val rvfi = io.e2w_rvfi

        rvfi.valid := exe_end

        when(exe_start){
            rvfi.order     := io.d2e_rvfi.order
            rvfi.pc_rdata  := io.d2e_rvfi.pc_rdata
            rvfi.insn      := io.d2e_rvfi.insn
            rvfi.trap      := io.d2e_rvfi.trap
            rvfi.halt      := io.d2e_rvfi.halt
            rvfi.intr      := io.d2e_rvfi.intr

            rvfi.rs1_addr  := io.d2e_rvfi.rs1_addr
            rvfi.rs2_addr  := io.d2e_rvfi.rs2_addr
            rvfi.rd_addr   := io.d2e_rvfi.rd_addr

            rvfi.rs1_rdata := io.d2e_rvfi.rs1_rdata
            rvfi.rs2_rdata := io.d2e_rvfi.rs2_rdata
            rvfi.rd_wdata  := 0

            rvfi.mem_addr  := 0
            rvfi.mem_rmask := 0
            rvfi.mem_rdata := 0
            rvfi.mem_wmask := 0
            rvfi.mem_wdata := 0
        }

        when(exe_end){
            when(io.e2d.pc_jump_valid){
                rvfi.pc_wdata  := io.e2d.pc_jump.resize(32)
            }
            .otherwise{
                rvfi.pc_wdata  := io.d2e_rvfi.pc_rdata + 4
            }
        }

        switch(itype){
            is(InstrType.B, InstrType.JAL, InstrType.JALR){
                when(exe_end && io.e2d.pc_jump_valid && io.e2d.pc_jump(1 downto 0) =/= "00"){
                    rvfi.trap := True
                }
            }
            is(InstrType.L){
                when(io.data_req.valid && io.data_req.ready){
                    rvfi.mem_addr  := lsu.lsu_addr(31 downto 2) @@ U"00"
                    rvfi.mem_rmask := ((io.data_req.size === B"00") ? B"0001" |
                                      ((io.data_req.size === B"01") ? B"0011" |
                                                                      B"1111")) |<< lsu.lsu_addr(1 downto 0)

                    rvfi.trap      := (io.data_req.size === B"01" && lsu.lsu_addr(0)) |
                                             (io.data_req.size === B"10" && lsu.lsu_addr(1 downto 0) =/= "00")
                }
            }
            is(InstrType.S){
                when(io.data_req.valid && io.data_req.ready){
                    rvfi.mem_addr  := lsu.lsu_addr(31 downto 2) @@ U"00"
                    rvfi.mem_wmask := ((io.data_req.size === B"00") ? B"0001" |
                                      ((io.data_req.size === B"01") ? B"0011" |
                                                                      B"1111")) |<< lsu.lsu_addr(1 downto 0)

                    rvfi.mem_wdata := io.data_req.data

                    rvfi.trap      := (io.data_req.size === B"01" && lsu.lsu_addr(0)) |
                                      (io.data_req.size === B"10" && lsu.lsu_addr(1 downto 0) =/= "00")

                }
            }
        }

    } else null

    val e2w = new Area {
        val e2w_nxt     = Execute2Writeback(config).setName("e2w_nxt")

        e2w_nxt.valid           := io.d2e.valid 

        e2w_nxt.ld_active       := io.data_req.valid && !io.data_req.wr
        e2w_nxt.ld_addr_lsb     := io.data_req.addr(1 downto 0)
        e2w_nxt.ld_data_size    := io.data_req.size
        e2w_nxt.ld_data_signed  := !funct3(2)

        e2w_nxt.rd_wr           := rd_wr
        e2w_nxt.rd_waddr        := rd_waddr
        e2w_nxt.rd_wdata        := rd_wdata

        when(io.d2e.valid && !io.e2d.stall){
            io.e2w          := e2w_nxt
        }
        .elsewhen(!io.w2e.stall && io.e2w.valid){
            io.e2w.valid    := False
        }

    }

}


