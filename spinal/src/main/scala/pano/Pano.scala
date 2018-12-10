
package pano

import spinal.core._

import spinal.lib._
import spinal.lib.io._

class Pano extends Component {

    val io = new Bundle {
        val osc_clk             = in(Bool)

        val led_red             = out(Bool)
        val led_green           = out(Bool)
        val led_blue            = out(Bool)

        val pano_button         = in(Bool)

        // I2C control for both Chrontel chips
        val dvi_spc             = master(TriState(Bool))
        val dvi_spd             = master(TriState(Bool))

        val dvi0_clk            = out(Bool)
        val dvi0_reset_         = out(Bool)

        val dvi1_clk            = out(Bool)
        val dvi1_reset_         = out(Bool)
    }

    noIoPrefix()

    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val resetCtrlClockDomain = ClockDomain(
        clock = io.osc_clk,
        frequency = FixedFrequency(25 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )

    //============================================================
    // Create global reset clock domain
    //============================================================
    val resetCtrl = new ClockingArea(resetCtrlClockDomain) {
        val reset_unbuffered_ = True

        val reset_cntr = Reg(UInt(5 bits)) init(0)
        when(reset_cntr =/= U(reset_cntr.range -> true)){
            reset_cntr := reset_cntr + 1
            reset_unbuffered_ := False
        }

        val osc_reset_ = RegNext(reset_unbuffered_)
    }

    val clk25    = Bool
    val reset25_ = Bool
    clk25       := io.osc_clk
    reset25_    := resetCtrl.osc_reset_

    val clkMainClockDomain = ClockDomain(
        clock = clk25,
        reset = reset25_,
        config = ClockDomainConfig(
            resetKind = SYNC,
            resetActiveLevel = LOW
        )
    )

    io.dvi0_clk     := clk25
    io.dvi0_reset_  := True

    io.dvi1_clk     := clk25
    io.dvi1_reset_  := True

    val core = new ClockingArea(clkMainClockDomain) {

        val u_pano_core = new PanoCore()

        u_pano_core.io.led_red      <> io.led_red
        u_pano_core.io.led_green    <> io.led_green
        u_pano_core.io.led_blue     <> io.led_blue

        u_pano_core.io.switch_      <> io.pano_button

        u_pano_core.io.dvi_ctrl_scl <> io.dvi_spc
        u_pano_core.io.dvi_ctrl_sda <> io.dvi_spd
    }

}

object PanoVerilog{
    def main(args: Array[String]) {

        val config = SpinalConfig()
        config.generateVerilog({
            val toplevel = new Pano()
            InOutWrapper(toplevel)
        })
        println("DONE")
    }
}

