
package pano

import spinal.core._
import spinal.lib.Counter
import spinal.lib.CounterFreeRun
import spinal.lib.GrayCounter

import mr1._

class PanoCore extends Component {

    val io = new Bundle {
        val led_red             = out(Bool)
        val led_green           = out(Bool)
        val led_blue            = out(Bool)

        val switch_             = in(Bool)
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
    val u_mr1_top = new MR1Top(mr1Config, rtConfig)
    u_mr1_top.io.led1       <> io.led_blue
    u_mr1_top.io.switch_    <> io.switch_

}


