
package mr1

import spinal.core._


class Writeback(config: MR1Config) extends Component {

    val io = new Bundle {
        val e2w         = in(Execute2Writeback(config))
        val w2e         = out(Writeback2Execute(config))

        val rd_update   = out(RegRdUpdate(config))

        val w2r         = out(Write2RegFile(config))

        val data_rsp    = DataRspIntfc(config)

        val e2w_rvfi    = in(RVFI(config))
        val rvfi        = if (config.hasFormal) out(Reg(RVFI(config)) init) else null
    }

    val w2e_stall_d = RegNext(io.w2e.stall, False)

    val wb_start = io.e2w.valid && !w2e_stall_d
    val wb_end   = io.e2w.valid && !io.w2e.stall

    val ld = new Area {

        val data_rsp_valid = if (config.reflopDataRsp) RegNext(io.data_rsp.valid) else io.data_rsp.valid
        val data_rsp_data  = if (config.reflopDataRsp) RegNext(io.data_rsp.data)  else io.data_rsp.data

        val rsp_data_shift_adj = Bits(32 bits)
        rsp_data_shift_adj := data_rsp_data >> (io.e2w.ld_addr_lsb(1 downto 0) * 8)

        val rd_wdata = Bits(32 bits)
        rd_wdata := io.e2w.ld_data_size.mux(
                            B"00"   -> (io.e2w.ld_data_signed ? B(S(rsp_data_shift_adj( 7 downto 0)).resize(32)) | 
                                                                B(U(rsp_data_shift_adj( 7 downto 0)).resize(32)) ),
                            B"01"   -> (io.e2w.ld_data_signed ? B(S(rsp_data_shift_adj(15 downto 0)).resize(32)) | 
                                                                B(U(rsp_data_shift_adj(15 downto 0)).resize(32)) ),
                            default ->                              rsp_data_shift_adj
                    )

        val ld_stall = io.e2w.valid && io.e2w.ld_active && !data_rsp_valid
        val rd_wr    = io.e2w.valid && io.e2w.ld_active && !ld_stall
    }

    val rd_wr    = io.e2w.valid && (io.e2w.rd_wr | ld.rd_wr) && (io.e2w.rd_waddr =/= 0)
    val rd_waddr = rd_wr ? io.e2w.rd_waddr | U"5'd0"
    val rd_wdata = B((io.e2w.rd_wdata.range -> io.e2w.rd_wr))   & B(io.e2w.rd_wdata)   |
                   B((ld.rd_wdata.range     -> ld.rd_wr    ))   & B(ld.rd_wdata)

    io.w2e.stall         := ld.ld_stall

    // Write to RegFile
    io.w2r.rd_wr        := rd_wr
    io.w2r.rd_wr_addr   := rd_waddr
    io.w2r.rd_wr_data   := rd_wdata

    // Feedback for RAW testing and bypass
    io.rd_update.rd_waddr_valid := io.e2w.valid && rd_wr
    io.rd_update.rd_waddr       := io.e2w.rd_waddr
    io.rd_update.rd_wdata_valid := io.e2w.valid && rd_wr
    io.rd_update.rd_wdata       := rd_wdata


    val formal = if (config.hasFormal) new Area {

        io.rvfi.valid := wb_end

        when(wb_start){
            io.rvfi.order     := io.e2w_rvfi.order
            io.rvfi.pc_rdata  := io.e2w_rvfi.pc_rdata
            io.rvfi.pc_wdata  := io.e2w_rvfi.pc_wdata
            io.rvfi.insn      := io.e2w_rvfi.insn
            io.rvfi.trap      := io.e2w_rvfi.trap
            io.rvfi.halt      := io.e2w_rvfi.halt
            io.rvfi.intr      := io.e2w_rvfi.intr

            io.rvfi.rs1_addr  := io.e2w_rvfi.rs1_addr
            io.rvfi.rs2_addr  := io.e2w_rvfi.rs2_addr
            io.rvfi.rd_addr   := io.e2w_rvfi.rd_addr

            io.rvfi.rs1_rdata := io.e2w_rvfi.rs1_rdata
            io.rvfi.rs2_rdata := io.e2w_rvfi.rs2_rdata
            io.rvfi.rd_wdata  := 0

            io.rvfi.mem_addr  := io.e2w_rvfi.mem_addr
            io.rvfi.mem_rmask := io.e2w_rvfi.mem_rmask
            io.rvfi.mem_rdata := 0
            io.rvfi.mem_wmask := io.e2w_rvfi.mem_wmask
            io.rvfi.mem_wdata := io.e2w_rvfi.mem_wdata
        }

        when(rd_wr){
            io.rvfi.rd_wdata  := rd_wdata
        }

        when(io.e2w.ld_active && ld.data_rsp_valid){
            io.rvfi.mem_rdata := ld.data_rsp_data
        }

    } else null

}


