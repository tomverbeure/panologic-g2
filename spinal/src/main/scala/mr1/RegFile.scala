
package mr1

import spinal.core._

case class Read2RegFile(config: MR1Config) extends Bundle {
    val rs1_rd      = Bool
    val rs1_rd_addr = UInt(5 bits)

    val rs2_rd      = Bool
    val rs2_rd_addr = UInt(5 bits)
}

case class RegFile2Read(config: MR1Config) extends Bundle {
    val stall       = Bool
}

case class RegFile2ReadResult(config: MR1Config) extends Bundle {
    val rs1_data    = Bits(32 bits)
    val rs2_data    = Bits(32 bits)
}

case class Write2RegFile(config: MR1Config) extends Bundle {
    val rd_wr       = Bool
    val rd_wr_addr  = UInt(5 bits)
    val rd_wr_data  = Bits(32 bits)
}

class RegFile(config: MR1Config) extends Component {

    val io = new Bundle {
        val rd2r        = in(Read2RegFile(config))
        val r2rd        = out(RegFile2Read(config))

        val r2rr        = out(RegFile2ReadResult(config))

        val w2r         = in(Write2RegFile(config))

    }

    val mem = Mem(Bits(32 bits), 32)

    io.r2rr.rs1_data := mem.readSync(io.rd2r.rs1_rd_addr, io.rd2r.rs1_rd)
    io.r2rr.rs2_data := mem.readSync(io.rd2r.rs2_rd_addr, io.rd2r.rs2_rd)

    val reg_init =
        if (config.hasRegInit){
            new Area {
                val cntr = Reg(UInt(6 bits)) init(0)
                cntr := cntr(5) ? cntr | cntr + 1

                val initR = !cntr(5)
                io.r2rd.stall := initR
            }
        } else {
            new Area {
                val cntr = U"5'D0"
                val initR = RegNext(False) init(True)
                io.r2rd.stall := initR
            }
        }


    val rd_wr      = Bool
    val rd_wr_addr = UInt(5 bits)
    val rd_wr_data = Bits(32 bits)

    // Write 0 to r0 after reset
    rd_wr      := reg_init.initR ? True                       | io.w2r.rd_wr
    rd_wr_addr := reg_init.initR ? reg_init.cntr(4 downto 0)  | io.w2r.rd_wr_addr
    rd_wr_data := reg_init.initR ? B"32'd0"                   | io.w2r.rd_wr_data

    mem.write(rd_wr_addr, rd_wr_data, rd_wr)

}


