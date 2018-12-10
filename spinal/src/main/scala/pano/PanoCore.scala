
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._

import mr1._

class PanoCore extends Component {

    val io = new Bundle {
        val led_red             = out(Bool)
        val led_green           = out(Bool)
        val led_blue            = out(Bool)

        val switch_             = in(Bool)

        val dvi_ctrl_scl        = master(TriState(Bool))
        val dvi_ctrl_sda        = master(TriState(Bool))
    }

    val leds = new Area {
        val led_cntr = Reg(UInt(24 bits)) init(0)

        when(led_cntr === U(led_cntr.range -> true)){
            led_cntr := 0
        }
        .otherwise {
            led_cntr := led_cntr +1
        }

        io.led_green    := led_cntr.msb
    }

    val mr1Config = MR1Config()
    val u_mr1_top = new MR1Top(mr1Config)
    u_mr1_top.io.led1       <> io.led_red
    u_mr1_top.io.led2       <> io.led_blue
    u_mr1_top.io.switch_    <> io.switch_
    u_mr1_top.io.dvi_ctrl_scl    <> io.dvi_ctrl_scl
    u_mr1_top.io.dvi_ctrl_sda    <> io.dvi_ctrl_sda

}


