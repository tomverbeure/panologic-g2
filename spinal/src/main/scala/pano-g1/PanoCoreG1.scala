
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc.SizeMapping
import scala.collection.mutable.ArrayBuffer

import cc._

class PanoCoreG1(voClkDomain: ClockDomain) extends Component {

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

        io.led_red  := led_cntr.msb
    }

    val u_cpu_top = CpuTopG1()
    u_cpu_top.io.switch_                <> io.switch_

    var cpuDomain = ClockDomain.current

    //============================================================
    // GPIO control, bits:
    // 0 - Green LED
    // 1 - Blue LED
    // 2 - Red LED
    // 3 - Pano button
    //============================================================

    val u_led_ctrl = Apb3Gpio(4)
    u_led_ctrl.io.apb                       <> u_cpu_top.io.led_ctrl_apb
    u_led_ctrl.io.gpio.write(0)             <> io.led_green
    u_led_ctrl.io.gpio.write(1)             <> io.led_blue
    // u_led_ctrl.io.gpio.write(2)          <> io.led_red
    u_led_ctrl.io.gpio.read(0)              := io.led_green
    u_led_ctrl.io.gpio.read(1)              := io.led_blue
    u_led_ctrl.io.gpio.read(2)              := False
    u_led_ctrl.io.gpio.read(3)              := io.switch_

}


