
package pano

import spinal.core._

import spinal.lib._
import spinal.lib.io._

class PanoG1 extends Component {

    val io = new Bundle {
        val osc_clk             = in(Bool)

        val led_red             = out(Bool)
        val led_green           = out(Bool)
        val led_blue            = out(Bool)

        val pano_button         = in(Bool)

        val usb_a   = out(UInt(17 bits))
        val usb_d   = master(TriStateArray(16 bits))
        val usb_cs_ = out(Bool)
        val usb_rd_ = out(Bool)
        val usb_wr_ = out(Bool)
        val usb_clkin = out(Bool)
        val usb_reset_n = out(Bool)
        val usb_hub_reset_n = out(Bool)
        val usb_hub_clkin = out(Bool)
    }

    noIoPrefix()

//  USB controller clock
    val usb_clk = new Usb_clk()
    usb_clk.io.CLKIN_IN  <> io.osc_clk
    usb_clk.io.CLKFX_OUT <> io.usb_hub_clkin


    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val usbClkDomain = ClockDomain(
        clock = usb_clk.io.CLKFX_OUT,
        frequency = FixedFrequency(24 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )


    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val clkDividerUsb = new ClockingArea(usbClkDomain) {
        // Create div2 clock
        val clk_cntr = Reg(Bool)
        clk_cntr := !clk_cntr
        io.usb_clkin := clk_cntr
    }


    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val oscClkDomain = ClockDomain(
        clock = usb_clk.io.CLK0_OUT,
        frequency = FixedFrequency(100 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )


    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val clkDivider = new ClockingArea(oscClkDomain) {
        // Create div4 clock
        val clk_cntr = Reg(UInt(2 bits)) init(0)
        clk_cntr := clk_cntr + 1
        val main_clk_raw = RegNext(clk_cntr(1))
    }

    //============================================================
    // Create raw main clock
    //============================================================

    val mainClkRawDomain = ClockDomain(
        clock = clkDivider.main_clk_raw,
        frequency = FixedFrequency(25 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )

    //============================================================
    // Create main clock reset
    //============================================================
    val main_reset_ = Bool

    val main_reset_gen = new ClockingArea(mainClkRawDomain) {
        val reset_unbuffered_ = True

        val reset_cntr = Reg(UInt(5 bits)) init(0)
        when(reset_cntr =/= U(reset_cntr.range -> true)){
            reset_cntr := reset_cntr + 1
            reset_unbuffered_ := False
        }

        main_reset_ := RegNext(reset_unbuffered_)

    }

    io.usb_reset_n := main_reset_
    io.usb_hub_reset_n := main_reset_

    val main_clk    = Bool
    main_clk       := clkDivider.main_clk_raw

    val clkMainDomain = ClockDomain(
        clock = main_clk,
        reset = main_reset_,
        config = ClockDomainConfig(
            resetKind = SYNC,
            resetActiveLevel = LOW
        )
    )


    //============================================================
    // Core logic
    //============================================================

    val core = new ClockingArea(clkMainDomain) {

        val u_pano_core = new PanoCoreG1(clkMainDomain)

        u_pano_core.io.led_red      <> io.led_red
        u_pano_core.io.led_green    <> io.led_green
        u_pano_core.io.led_blue     <> io.led_blue

        u_pano_core.io.switch_      <> io.pano_button

        u_pano_core.io.usb_a <> io.usb_a
        u_pano_core.io.usb_d <> io.usb_d
        u_pano_core.io.usb_cs_ <> io.usb_cs_
        u_pano_core.io.usb_rd_ <> io.usb_rd_
        u_pano_core.io.usb_wr_ <> io.usb_wr_

    }

}

class Usb_clk() extends BlackBox {
val io = new Bundle {
    val CLKIN_IN = in  Bool 
    val CLKFX_OUT = out Bool 
    var CLK0_OUT = out Bool
  }

  // Remove io_ prefix 
  noIoPrefix() 
}

object PanoG1Verilog{
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)
        config.generateVerilog({
            val toplevel = new PanoG1()
            InOutWrapper(toplevel)
        })
        println("DONE")
    }
}

