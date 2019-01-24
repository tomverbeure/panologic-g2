
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc.SizeMapping

import vexriscv.demo.MuraxApb3Timer

import scala.collection.mutable.ArrayBuffer
import spinal.lib.com.uart._

import cc._

case class CpuTopG1() extends Component {

    val io = new Bundle {
        val led_ctrl_apb        = master(Apb3(Apb3Gpio.getApb3Config()))
        val uart_ctrl_apb       = master(Apb3(Apb3UartCtrl.getApb3Config))
    }

    val u_cpu = CpuComplex(CpuComplexConfig.default)
    u_cpu.io.externalInterrupt <> False

    val apbMapping = ArrayBuffer[(Apb3, SizeMapping)]()

    apbMapping += io.led_ctrl_apb       -> (0x0, 256 Byte)
    apbMapping += io.uart_ctrl_apb      -> (0x100, 256 Byte)

    //============================================================
    // Timer
    //============================================================

    val u_timer = new MuraxApb3Timer()
    u_timer.io.interrupt        <> u_cpu.io.timerInterrupt
    apbMapping += u_timer.io.apb -> (0x30000, 4 kB)


    //============================================================
    // Local APB decoder
    //============================================================
    val apbDecoder = Apb3Decoder(
      master = u_cpu.io.apb,
      slaves = apbMapping
    )

}

