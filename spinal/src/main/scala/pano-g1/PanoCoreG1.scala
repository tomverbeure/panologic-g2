
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc.SizeMapping
import scala.collection.mutable.ArrayBuffer
import spinal.lib.com.uart._

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

    var cpuDomain = ClockDomain.current

    //============================================================
    // GPIO control, bits:
    // 0 - Green LED
    // 1 - Blue LED
    // 2 - Red LED  (write only: hardware limitation)
    // 3 - Pano button
    //============================================================

    val u_led_ctrl = Apb3Gpio(4, withReadSync = true)
    u_led_ctrl.io.apb                       <> u_cpu_top.io.led_ctrl_apb
    u_led_ctrl.io.gpio.write(0)             <> io.led_green
    // u_led_ctrl.io.gpio.write(1)             <> io.led_blue
    // u_led_ctrl.io.gpio.write(2)          <> io.led_red
    u_led_ctrl.io.gpio.read(0)              := io.led_green
    u_led_ctrl.io.gpio.read(1)              := io.led_blue
    u_led_ctrl.io.gpio.read(2)              := False
    u_led_ctrl.io.gpio.read(3)              := io.switch_
    //============================================================
    // UART 
    //============================================================

    val uartCtrlConfig = UartCtrlMemoryMappedConfig(
      uartCtrlConfig = UartCtrlGenerics(
        dataWidthMax      = 9,
        clockDividerWidth = 20,
        preSamplingSize   = 1,
        samplingSize      = 5,
        postSamplingSize  = 2
      ),
      txFifoDepth = 255,        // Uart is for debugging, max size fifo
      rxFifoDepth = 2           // Rx is a human
    )
    val uartCtrl = Apb3UartCtrl(uartCtrlConfig)
    uartCtrl.io.apb <> u_cpu_top.io.uart_ctrl_apb
    uartCtrl.io.uart.rxd := True
    uartCtrl.io.uart.txd <> io.led_blue
}


