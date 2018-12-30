
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc.SizeMapping

import vexriscv.demo.MuraxApb3Timer

import scala.collection.mutable.ArrayBuffer

import cc._

case class CpuTop() extends Component {

    val io = new Bundle {

        val led_ctrl_apb        = master(Apb3(Apb3Gpio.getApb3Config()))
        val dvi_ctrl_apb        = master(Apb3(CCGpio.getApb3Config()))
        val gmii_ctrl_apb       = master(Apb3(GmiiCtrl.getApb3Config()))
        val test_patt_apb       = master(Apb3(VideoTestPattern.getApb3Config()))
        val txt_gen_apb         = master(Apb3(VideoTxtGen.getApb3Config()))

        val switch_             = in(Bool)
    }

//    val u_cpu = CpuComplex(CpuComplexConfig.default.copy(onChipRamSize = 8 kB, onChipRamHexFile = "sw/progmem.hex"))
    val u_cpu = CpuComplex(CpuComplexConfig.default)
    u_cpu.io.externalInterrupt <> False

    val apbMapping = ArrayBuffer[(Apb3, SizeMapping)]()

    apbMapping += io.led_ctrl_apb       -> (0x00000, 256 Byte)
    apbMapping += io.dvi_ctrl_apb       -> (0x00100, 256 Byte)
    apbMapping += io.test_patt_apb      -> (0x00200, 256 Byte)
    apbMapping += io.gmii_ctrl_apb      -> (0x10000, 4 kB)
    apbMapping += io.txt_gen_apb        -> (0x20000, 64 kB)

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

