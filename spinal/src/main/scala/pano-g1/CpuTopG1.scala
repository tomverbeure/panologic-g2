
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
        val usb_ctrl_apb        = master(Apb3(Apb3UsbCtrlG1.getApb3Config))
    }

    val CpuConfig = CpuComplexConfig.default.copy(onChipRamHexFile = "sw.g1/progmem.hex")

    val u_cpu = CpuComplex(CpuConfig)
    u_cpu.io.externalInterrupt <> False

    //============================================================
    // Timer
    //============================================================

    val u_timer = new MuraxApb3Timer()
    u_timer.io.interrupt        <> u_cpu.io.timerInterrupt

    val apbMapping = ArrayBuffer[(Apb3, SizeMapping)]()

    apbMapping += io.led_ctrl_apb       -> (0x000000, 256 Byte)
    apbMapping += io.uart_ctrl_apb      -> (0x000100, 256 Byte)
    apbMapping += u_timer.io.apb        -> (0x000200, 256 Byte)
    apbMapping += io.usb_ctrl_apb       -> (0x080000, 524288 Byte)


    //============================================================
    // Local APB decoder
    //============================================================
    val apbDecoder = Apb3Decoder(
      master = u_cpu.io.apb,
      slaves = apbMapping
    )

}

