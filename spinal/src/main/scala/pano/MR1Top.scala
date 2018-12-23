
package pano

import java.nio.file.{Files, Paths}
import spinal.core._
import spinal.lib._
import spinal.lib.io._

import mr1._

class MR1Top(config: MR1Config) extends Component {

    val io = new Bundle {
        val led1    = out(Bool)
        val led2    = out(Bool)
        val led3    = out(Bool)

        val switch_ = in(Bool)

        val dvi_ctrl_scl        = master(TriState(Bool))
        val dvi_ctrl_sda        = master(TriState(Bool))

        val test_pattern_nr             = out(UInt(4 bits))
        val test_pattern_const_color    = out(Pixel())

        val txt_buf_wr      = out(Bool)
        val txt_buf_rd      = out(Bool)
        val txt_buf_addr    = out(UInt(13 bits))
        val txt_buf_wr_data = out(Bits(8 bits))
        val txt_buf_rd_data = in(Bits(8 bits))

        val mii_mdio        = master(GmiiMdio())
    }

    val mr1 = new MR1(config)

    val wmask = mr1.io.data_req.size.mux(

                    B"00"   -> B"0001",
                    B"01"   -> B"0011",
                    default -> B"1111") |<< mr1.io.data_req.addr(1 downto 0)

    mr1.io.instr_req.ready := True
    mr1.io.instr_rsp.valid := RegNext(mr1.io.instr_req.valid) init(False)

    val cpu_ram_rd_data = Bits(32 bits)
    val reg_rd_data     = Bits(32 bits)

    mr1.io.data_req.ready := True
    mr1.io.data_rsp.valid := RegNext(mr1.io.data_req.valid && !mr1.io.data_req.wr) init(False)
    mr1.io.data_rsp.data  := RegNext(mr1.io.data_req.addr(19)) ? reg_rd_data | cpu_ram_rd_data


    val ramSize = 8192

    val ram = if (true) new Area{

        val byteArray = Files.readAllBytes(Paths.get("sw/progmem8k.bin"))
        val cpuRamContent = for(i <- 0 until ramSize/4) yield {
                B( (byteArray(4*i).toLong & 0xff) + ((byteArray(4*i+1).toLong & 0xff)<<8) + ((byteArray(4*i+2).toLong & 0xff)<<16) + ((byteArray(4*i+3).toLong & 0xff)<<24), 32 bits)
        }

        val cpu_ram = Mem(Bits(32 bits), initialContent = cpuRamContent)

        mr1.io.instr_rsp.data := cpu_ram.readSync(
                enable  = mr1.io.instr_req.valid,
                address = (mr1.io.instr_req.addr >> 2).resized
            )

        cpu_ram_rd_data := cpu_ram.readWriteSync(
                enable  = mr1.io.data_req.valid && !mr1.io.data_req.addr(19),
                address = (mr1.io.data_req.addr >> 2).resized,
                write   = mr1.io.data_req.wr,
                data    = mr1.io.data_req.data,
                mask    = wmask
            )
    }
    else new Area{
        val cpu_ram = new cpu_ram()

        cpu_ram.io.address_a     := (mr1.io.instr_req.addr >> 2).resized
        cpu_ram.io.wren_a        := False
        cpu_ram.io.data_a        := 0
        mr1.io.instr_rsp.data    := cpu_ram.io.q_a


        cpu_ram.io.address_b     := (mr1.io.data_req.addr >> 2).resized
        cpu_ram.io.wren_b        := mr1.io.data_req.valid && mr1.io.data_req.wr && !mr1.io.data_req.addr(19)
        cpu_ram.io.byteena_b     := wmask
        cpu_ram.io.data_b        := mr1.io.data_req.data
        mr1.io.data_rsp.data     := cpu_ram.io.q_b
    }

    //============================================================
    // LEDs
    //============================================================

    val update_leds = mr1.io.data_req.valid && mr1.io.data_req.wr && (mr1.io.data_req.addr === U"32'h00080000")

    io.led1 := RegNextWhen(mr1.io.data_req.data(0), update_leds) init(False)
    io.led2 := RegNextWhen(mr1.io.data_req.data(1), update_leds) init(False)
    io.led3 := RegNextWhen(mr1.io.data_req.data(2), update_leds) init(False)

    //============================================================
    // BUTTON
    //============================================================

    val button_addr  = (mr1.io.data_req.addr === U"32'h00080004")

    val button = Reg(Bool) init(False)
    button := !io.switch_


    //============================================================
    // DVI_CTRL I2C
    //============================================================

    val dvi_ctrl_addr     = (mr1.io.data_req.addr === U"32'h00080010")
    val dvi_ctrl_set_addr = (mr1.io.data_req.addr === U"32'h00080014")
    val dvi_ctrl_clr_addr = (mr1.io.data_req.addr === U"32'h00080018")
    val dvi_ctrl_rd_addr  = (mr1.io.data_req.addr === U"32'h0008001c")

    val update_dvi_ctrl     = mr1.io.data_req.valid && mr1.io.data_req.wr && dvi_ctrl_addr
    val update_dvi_ctrl_set = mr1.io.data_req.valid && mr1.io.data_req.wr && dvi_ctrl_set_addr
    val update_dvi_ctrl_clr = mr1.io.data_req.valid && mr1.io.data_req.wr && dvi_ctrl_clr_addr

    val dvi_ctrl_scl = Reg(Bool) init(True)
    val dvi_ctrl_sda = Reg(Bool) init(True)

    dvi_ctrl_scl :=  update_dvi_ctrl                                  ? mr1.io.data_req.data(0) |
                    ((update_dvi_ctrl_set && mr1.io.data_req.data(0)) ? True                    |
                    ((update_dvi_ctrl_clr && mr1.io.data_req.data(0)) ? False                   |
                                                                        dvi_ctrl_scl))

    dvi_ctrl_sda :=  update_dvi_ctrl                                  ? mr1.io.data_req.data(1) |
                    ((update_dvi_ctrl_set && mr1.io.data_req.data(1)) ? True                    |
                    ((update_dvi_ctrl_clr && mr1.io.data_req.data(1)) ? False                   |
                                                                        dvi_ctrl_sda))

    io.dvi_ctrl_scl.writeEnable := (dvi_ctrl_scl === False)
    io.dvi_ctrl_scl.write       := dvi_ctrl_scl

    io.dvi_ctrl_sda.writeEnable := (dvi_ctrl_sda === False)
    io.dvi_ctrl_sda.write       := dvi_ctrl_sda


    //============================================================
    // TEST PATTERN
    //============================================================

    val test_pattern_nr_addr          = (mr1.io.data_req.addr === U"32'h00080020")
    val test_pattern_const_color_addr = (mr1.io.data_req.addr === U"32'h00080024")

    val update_test_pattern_nr          = mr1.io.data_req.valid && mr1.io.data_req.wr && test_pattern_nr_addr
    val update_test_pattern_const_color = mr1.io.data_req.valid && mr1.io.data_req.wr && test_pattern_const_color_addr

    io.test_pattern_nr            := RegNextWhen(mr1.io.data_req.data(3 downto 0).asUInt, update_test_pattern_nr) init(0)

    io.test_pattern_const_color.r := RegNextWhen(mr1.io.data_req.data( 7 downto  0).asUInt, update_test_pattern_const_color) init(0)
    io.test_pattern_const_color.g := RegNextWhen(mr1.io.data_req.data(15 downto  8).asUInt, update_test_pattern_const_color) init(0)
    io.test_pattern_const_color.b := RegNextWhen(mr1.io.data_req.data(23 downto 16).asUInt, update_test_pattern_const_color) init(0)

    //============================================================
    // Txt Buf RAM
    //============================================================

    val txt_buf_addr = (mr1.io.data_req.addr(15, 17 bits) === U"32'h00088000"(15, 17 bits))

    val txt_buf_wr = mr1.io.data_req.valid &&  mr1.io.data_req.wr && txt_buf_addr
    val txt_buf_rd = mr1.io.data_req.valid && ~mr1.io.data_req.wr && txt_buf_addr

    io.txt_buf_wr       <> txt_buf_wr
    io.txt_buf_rd       <> txt_buf_rd
    io.txt_buf_addr     <> mr1.io.data_req.addr(2, 13 bits)
    io.txt_buf_wr_data  <> mr1.io.data_req.data(0, 8 bits)

    //============================================================
    // Ethernet MDIO
    //============================================================

    val mii_addr     = (mr1.io.data_req.addr === U"32'h00080030")
    val mii_set_addr = (mr1.io.data_req.addr === U"32'h00080034")
    val mii_clr_addr = (mr1.io.data_req.addr === U"32'h00080038")
    val mii_rd_addr  = (mr1.io.data_req.addr === U"32'h0008003c")

    val update_mii     = mr1.io.data_req.valid && mr1.io.data_req.wr && mii_addr
    val update_mii_set = mr1.io.data_req.valid && mr1.io.data_req.wr && mii_set_addr
    val update_mii_clr = mr1.io.data_req.valid && mr1.io.data_req.wr && mii_clr_addr

    val mii_vec     = Reg(Bits(6 bits)) init(0)

    mii_vec :=  update_mii     ? (           mr1.io.data_req.data(0, mii_vec.getWidth bits)) |
               (update_mii_set ? (mii_vec |  mr1.io.data_req.data(0, mii_vec.getWidth bits)) |
               (update_mii_clr ? (mii_vec & ~mr1.io.data_req.data(0, mii_vec.getWidth bits)) |
                                  mii_vec    ))

    io.mii_mdio.mdc           := mii_vec(3)

    io.mii_mdio.mdio.writeEnable   := mii_vec(4)
    io.mii_mdio.mdio.write         := mii_vec(5)

    val mii_vec_rd = io.mii_mdio.mdio.read ## mii_vec(4 downto 0)

    //============================================================
    // READ DATA MUX
    //============================================================

    reg_rd_data :=  (RegNext(button_addr)       ? (B(0, 31 bits) ## button) |

                    (RegNext(dvi_ctrl_addr)     ? (B(0, 30 bits) ## dvi_ctrl_sda ## dvi_ctrl_scl) |
                    (RegNext(dvi_ctrl_set_addr) ? (B(0, 30 bits) ## dvi_ctrl_sda ## dvi_ctrl_scl) |
                    (RegNext(dvi_ctrl_clr_addr) ? (B(0, 30 bits) ## dvi_ctrl_sda ## dvi_ctrl_scl) |
                    (RegNext(dvi_ctrl_rd_addr)  ? (B(0, 30 bits) ## io.dvi_ctrl_sda.read ## io.dvi_ctrl_scl.read) |

                    (RegNext(mii_addr)          ? (B(0, 26 bits) ## mii_vec) |
                    (RegNext(mii_set_addr)      ? (B(0, 26 bits) ## mii_vec) |
                    (RegNext(mii_clr_addr)      ? (B(0, 26 bits) ## mii_vec) |
                    (RegNext(mii_rd_addr)       ? (B(0, 26 bits) ## mii_vec_rd) |

                    (RegNext(txt_buf_addr)      ? (B(0, 24 bits) ## io.txt_buf_rd_data) |

                                                   B(0, 32 bits)))))))))))
}

