
package pano

import spinal.core._

import spinal.lib._
import spinal.lib.io._

import mii._

class PanoG1 extends Component {

    val io = new Bundle {
        val osc_clk             = in(Bool)

        val led_red             = out(Bool)
        val led_green           = out(Bool)
        val led_blue            = out(Bool)

        val pano_button         = in(Bool)

        // MII interface
        val mii_rst_           = out(Bool)
        val mii                = master(Mii())
    }

    noIoPrefix()

    io.mii_rst_     := True
    io.mii.tx.er    := False
    io.mii.tx.en    := False
    io.mii.tx.d     := 0
    io.mii.mdio.mdc := False
    io.mii.mdio.mdio.write        := False
    io.mii.mdio.mdio.writeEnable  := False

    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val oscClkDomain = ClockDomain(
        clock = io.osc_clk,
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
    // MII RX CLK
    //============================================================

    val miiRxClkDomain = ClockDomain(
            clock = io.mii.rx.clk,
            config = ClockDomainConfig(
                resetKind = BOOT
            )
        )

    val mii_rx = new ClockingArea(miiRxClkDomain) {
        val green_counter   = Reg(UInt(22 bits))
        green_counter     := green_counter + 1
        io.led_green      := green_counter.msb
    }

    //============================================================
    // Core logic
    //============================================================

    val core = new ClockingArea(clkMainDomain) {

        val u_pano_core = new PanoCoreG1(clkMainDomain)

        u_pano_core.io.led_red      <> io.led_red
//        u_pano_core.io.led_green    <> io.led_green
        u_pano_core.io.led_blue     <> io.led_blue

        u_pano_core.io.switch_      <> io.pano_button

    }

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

