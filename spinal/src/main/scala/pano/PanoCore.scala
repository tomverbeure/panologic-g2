
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc.SizeMapping
import scala.collection.mutable.ArrayBuffer
import spinal.lib.com.uart._

import cc._
import gmii._
import ulpi._

class PanoCore(voClkDomain: ClockDomain, panoConfig: PanoConfig) extends Component {

    val io = new Bundle {
        val clk_125             = in(Bool)

        val led_red             = out(Bool)
        val led_green           = out(Bool)
        val led_blue            = out(Bool)

        val switch_             = in(Bool)

        val dvi_ctrl_scl        = if (panoConfig.includeDviI2C) master(TriState(Bool)) else null
        val dvi_ctrl_sda        = if (panoConfig.includeDviI2C) master(TriState(Bool)) else null

        val gmii                = if (panoConfig.includeGmii)   master(Gmii())         else null

        val ulpi                = if (panoConfig.includeUlpi)   slave(Ulpi())          else null

        val vo                  = out(VgaData())
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

    val u_cpu_top = CpuTop(panoConfig)
    u_cpu_top.io.switch_                <> io.switch_

    var cpuDomain = ClockDomain.current

    var ulpiDomain: ClockDomain = null

    if (panoConfig.includeUlpi){
        val rawUlpiDomain = ClockDomain(
            clock       = io.ulpi.clk,
            frequency   = FixedFrequency(60 MHz),
            config      = ClockDomainConfig(
                            resetKind = BOOT
            )
        )

        val ulpi_reset_ = rawUlpiDomain(RegNext(True) init(False))

        ulpiDomain = ClockDomain(
            clock = io.ulpi.clk,
            reset = ulpi_reset_,
            config = ClockDomainConfig(
                        resetKind = SYNC,
                        resetActiveLevel = LOW
            )
        )
    }


    val vo_area = new ClockingArea(voClkDomain) {

        // http://tinyvga.com/vga-timing
        val timings = VideoTimings()
        timings.timing_1080p_60

        val vi_gen_pixel_out = PixelStream()

        val u_vi_gen = new VideoTimingGen()
        u_vi_gen.io.timings         <> timings
        u_vi_gen.io.pixel_out       <> vi_gen_pixel_out

        //============================================================
        // Test pattern
        //============================================================

        val test_patt_pixel_out = PixelStream()

        val u_test_patt = new VideoTestPattern()
        u_test_patt.io.timings      <> timings
        u_test_patt.io.pixel_in     <> vi_gen_pixel_out
        u_test_patt.io.pixel_out    <> test_patt_pixel_out

        val test_patt_ctrl = new ClockingArea(cpuDomain) {
            val busCtrl = Apb3SlaveFactory(u_cpu_top.io.test_patt_apb)

            val apb_regs = u_test_patt.driveFrom(busCtrl, 0x0)
        }

        //============================================================
        // Text Gen
        //============================================================

        val txt_gen_pixel_out = PixelStream()

        val u_txt_gen = new VideoTxtGen(cpuDomain)
        u_txt_gen.io.pixel_in       <> test_patt_pixel_out
        u_txt_gen.io.pixel_out      <> txt_gen_pixel_out

        val txt_gen_ctrl = new ClockingArea(cpuDomain) {
            val busCtrl = Apb3SlaveFactory(u_cpu_top.io.txt_gen_apb)

            val apb_regs = u_txt_gen.driveFrom(busCtrl, 0x0)
        }

        //============================================================
        // Video Out
        //============================================================

        val u_vo = new VideoOut()
        u_vo.io.timings             <> timings
        u_vo.io.pixel_in            <> txt_gen_pixel_out
        u_vo.io.vga_out             <> io.vo
    }

    if (panoConfig.includeGmii){
        //============================================================
        // GMII
        //============================================================

        val u_gmii_ctrl = GmiiCtrl()
        u_gmii_ctrl.io.apb              <> u_cpu_top.io.gmii_ctrl_apb
        u_gmii_ctrl.io.gmii             <> io.gmii
        u_gmii_ctrl.io.clk_125          <> io.clk_125
    }

    if (panoConfig.includeUlpi){
        //============================================================
        // ULPI
        //============================================================

        val u_ulpi_ctrl = UlpiCtrl()
        u_ulpi_ctrl.io.ulpi             <> io.ulpi

        val ulpi_ctrl = new ClockingArea(cpuDomain) {
            val busCtrl = Apb3SlaveFactory(u_cpu_top.io.ulpi_apb)

            val apb_regs = u_ulpi_ctrl.driveFrom(busCtrl, 0x0)
        }

        //============================================================
        // USB Host
        //============================================================

        val usb_host_apb = Apb3(UsbHost.getApb3Config())

        val u_apb2usb_host = new Apb3CC(UsbHost.getApb3Config, ClockDomain.current, ulpiDomain)
        u_apb2usb_host.io.src           <> u_cpu_top.io.usb_host_apb
        u_apb2usb_host.io.dest          <> usb_host_apb

        val usb_host_domain = new ClockingArea(ulpiDomain) {
            val u_usb_host = UsbHost()

            val busCtrl = Apb3SlaveFactory(usb_host_apb)

            val apb_regs = u_usb_host.driveFrom(busCtrl, 0x0)
        }
    }

    //============================================================
    // LED control
    //============================================================

    val u_led_ctrl = Apb3Gpio(3, withReadSync = true)
    u_led_ctrl.io.apb                       <> u_cpu_top.io.led_ctrl_apb
    u_led_ctrl.io.gpio.write(0)             <> io.led_green
    u_led_ctrl.io.gpio.read(0)              := io.led_green

    if (!panoConfig.includeUart){
        u_led_ctrl.io.gpio.write(1)         <> io.led_blue
        u_led_ctrl.io.gpio.read(1)          := io.led_blue
    }

    u_led_ctrl.io.gpio.read(2)              := False


    if (panoConfig.includeDviI2C){
        //============================================================
        // DVI Config I2C control
        //============================================================

        val u_dvi_ctrl = CCGpio(2)
        u_dvi_ctrl.io.apb               <> u_cpu_top.io.dvi_ctrl_apb

        io.dvi_ctrl_scl.writeEnable     <> !u_dvi_ctrl.io.gpio.write(0)
        io.dvi_ctrl_scl.write           <> u_dvi_ctrl.io.gpio.write(0)
        io.dvi_ctrl_scl.read            <> u_dvi_ctrl.io.gpio.read(0)

        io.dvi_ctrl_sda.writeEnable     <> !u_dvi_ctrl.io.gpio.write(1)
        io.dvi_ctrl_sda.write           <> u_dvi_ctrl.io.gpio.write(1)
        io.dvi_ctrl_sda.read            <> u_dvi_ctrl.io.gpio.read(1)
    }

    if (panoConfig.includeUart){
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
        uartCtrl.io.apb         <> u_cpu_top.io.uart_ctrl_apb
        uartCtrl.io.uart.txd    <> io.led_blue
        uartCtrl.io.uart.rxd    := True
    }

}


