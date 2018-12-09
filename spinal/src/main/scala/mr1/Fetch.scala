
package mr1

import spinal.core._


case class Fetch2Decode(config: MR1Config) extends Bundle {

    val valid               = Bool
    val pc                  = UInt(config.pcSize bits)
    val instr               = Bits(32 bits)

    def init() : Fetch2Decode = {
        valid init(False)
        pc    init(0)
        instr init(0)
        this
    }
}

case class Decode2Fetch(config: MR1Config) extends Bundle {
    val stall               = Bool

    val pc_jump_valid       = Bool
    val pc_jump             = UInt(config.pcSize bits)
}

class Fetch(config: MR1Config) extends Component {

    val io = new Bundle {
        val instr_req       = InstrReqIntfc(config)
        val instr_rsp       = InstrRspIntfc(config)

        val f2d             =  out(Reg(Fetch2Decode(config)) init)
        val d2f             =  in(Decode2Fetch(config))

        val d_rd_update     = in(RegRdUpdate(config))
        val e_rd_update     = in(RegRdUpdate(config))
        val w_rd_update     = in(RegRdUpdate(config))

        val rd2r            = out(Read2RegFile(config))
        val r2rd            = in(RegFile2Read(config))
    }

    val fetch_halt = False

    val instr = io.instr_rsp.data
    val opcode = instr(6 downto 0)
    val down_stall = io.d2f.stall || io.r2rd.stall
    val raw_stall = Bool

    val instr_is_jump = (opcode === Opcodes.JAL)  ||
                        (opcode === Opcodes.JALR) ||
                        (opcode === Opcodes.B)    ||
                        ((opcode === Opcodes.SYS) && False)
    val instr_is_jump_r = Bool


    val pc = new Area {
        // Keeps track of real, confirmed PC
        val real_pc = Reg(UInt(config.pcSize bits)) init(0)
        val real_pc_incr = real_pc + 4

        val send_instr       = False

        object PcState extends SpinalEnum(binaryOneHot) {
            val Idle           = newElement()
            val WaitReqReady   = newElement()
            val WaitRsp        = newElement()
            val WaitJumpDone   = newElement()
            val WaitStallDone  = newElement()
        }

        val cur_state = Reg(PcState()) init(PcState.Idle)
        val capture_instr = False

        io.instr_req.valid := False
        io.instr_req.addr  := real_pc

        switch(cur_state){
            is(PcState.Idle){
                when (!fetch_halt && !down_stall){
                    io.instr_req.valid := True
                    io.instr_req.addr  := real_pc

                    when(io.instr_req.ready){
                        cur_state := PcState.WaitRsp
                    }
                    .otherwise{
                        cur_state := PcState.WaitReqReady
                    }
                }
            }
            is(PcState.WaitReqReady){
                io.instr_req.valid := True
                io.instr_req.addr  := real_pc

                when(io.instr_req.ready){
                    cur_state := PcState.WaitRsp
                }
            }
            is(PcState.WaitRsp){

                when(io.instr_rsp.valid){
                    capture_instr       := True
                    real_pc             := real_pc_incr
                    io.instr_req.addr   := real_pc_incr

                    when(down_stall || raw_stall){
                        cur_state           := PcState.WaitStallDone
                    }
                    .elsewhen(instr_is_jump){
                        send_instr          := True
                        cur_state           := PcState.WaitJumpDone
                    }
                    .otherwise{
                        send_instr          := True
                        io.instr_req.valid  := True

                        when(io.instr_req.ready){
                            cur_state       := PcState.WaitRsp
                        }
                        .otherwise{
                            cur_state       := PcState.WaitReqReady
                        }
                    }
                }
            }
            is(PcState.WaitStallDone){
                when(!(down_stall || raw_stall)){
                    send_instr              := True

                    when(instr_is_jump_r){
                        cur_state           := PcState.WaitJumpDone
                    }
                    .otherwise{
                        io.instr_req.valid  := True

                        when(io.instr_req.ready){
                            cur_state := PcState.WaitRsp
                        }
                        .otherwise{
                            cur_state := PcState.WaitReqReady
                        }
                    }
                }
            }
            is(PcState.WaitJumpDone){
                when(io.d2f.pc_jump_valid){
                    real_pc := io.d2f.pc_jump

                    when(fetch_halt){
                        cur_state := PcState.Idle
                    }
                    .otherwise{
                        io.instr_req.valid := True
                        io.instr_req.addr  := io.d2f.pc_jump

                        when(io.instr_req.ready){
                            cur_state := PcState.WaitRsp
                        }
                        .otherwise{
                            cur_state := PcState.WaitReqReady
                        }
                    }
                }
            }
        }
    }

    val instr_r         = RegNextWhen(instr,         pc.capture_instr) init(0)
    val pc_r            = RegNextWhen(pc.real_pc,    pc.capture_instr) init(0)
    instr_is_jump_r    := RegNextWhen(instr_is_jump, pc.capture_instr) init(False)

    val f2d_nxt = Fetch2Decode(config)

    f2d_nxt := io.f2d

    val instr_final = (pc.cur_state === pc.PcState.WaitStallDone) ? instr_r     | instr
    val pc_final    = (pc.cur_state === pc.PcState.WaitStallDone) ? pc_r        | pc.real_pc

    when(pc.send_instr){
        f2d_nxt.valid := True
        f2d_nxt.pc    := pc_final
        f2d_nxt.instr := instr_final
    }
    .elsewhen(!down_stall){
        f2d_nxt.valid := False
        if (false){
            // This makes debugging a bit easier, but it costs a few gates and timing
            f2d_nxt.pc    := 0
            f2d_nxt.instr := 0
        }
    }

    val fetch_active = f2d_nxt.valid && !(down_stall || raw_stall)

    io.f2d := f2d_nxt

    val rf = new Area {

        val rs1_valid = True
        val rs2_valid = True

        val rs1_addr    = U(instr_final(19 downto 15))
        val rs2_addr    = U(instr_final(24 downto 20))

        val raw_stall = (rs1_valid && ((io.d_rd_update.rd_waddr_valid && (rs1_addr === io.d_rd_update.rd_waddr && io.d_rd_update.rd_waddr =/= 0)) ||
                                       (io.e_rd_update.rd_waddr_valid && (rs1_addr === io.e_rd_update.rd_waddr && io.e_rd_update.rd_waddr =/= 0)) ||
                                       (io.w_rd_update.rd_waddr_valid && (rs1_addr === io.w_rd_update.rd_waddr && io.w_rd_update.rd_waddr =/= 0))    )) ||
                        (rs2_valid && ((io.d_rd_update.rd_waddr_valid && (rs2_addr === io.d_rd_update.rd_waddr && io.d_rd_update.rd_waddr =/= 0)) ||
                                       (io.e_rd_update.rd_waddr_valid && (rs2_addr === io.e_rd_update.rd_waddr && io.e_rd_update.rd_waddr =/= 0)) ||
                                       (io.w_rd_update.rd_waddr_valid && (rs2_addr === io.w_rd_update.rd_waddr && io.w_rd_update.rd_waddr =/= 0))    ))
    
        io.rd2r.rs1_rd := rs1_valid && !(down_stall || raw_stall)
        io.rd2r.rs2_rd := rs2_valid && !(down_stall || raw_stall)
        io.rd2r.rs1_rd_addr := rs1_valid ? rs1_addr | 0
        io.rd2r.rs2_rd_addr := rs2_valid ? rs2_addr | 0
    }

    raw_stall := rf.raw_stall

}


