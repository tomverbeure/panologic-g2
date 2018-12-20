
package pano

import spinal.core._

import spinal.lib._
import spinal.lib.io._

import spartan6._

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

        val dvi                 = out(ChrontelIntfc(includeXClkN = true))
        val hdmi                = out(ChrontelIntfc(includeXClkN = false))
    }

    noIoPrefix()

    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val oscClkDomain = ClockDomain(
        clock = io.osc_clk,
        frequency = FixedFrequency(25 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )

    //============================================================
    // Create global reset clock domain
    //============================================================
    val osc_reset_ = Bool

    val osc_reset_gen = new ClockingArea(oscClkDomain) {
        val reset_unbuffered_ = True

        val reset_cntr = Reg(UInt(5 bits)) init(0)
        when(reset_cntr =/= U(reset_cntr.range -> true)){
            reset_cntr := reset_cntr + 1
            reset_unbuffered_ := False
        }

        osc_reset_ := RegNext(reset_unbuffered_)
    }


    val clk25    = Bool
    val reset25_ = Bool
    clk25       := io.osc_clk
    reset25_    := osc_reset_

    val clkMainDomain = ClockDomain(
        clock = clk25,
        reset = reset25_,
        config = ClockDomainConfig(
            resetKind = SYNC,
            resetActiveLevel = LOW
        )
    )

    //============================================================
    // vo_clk and vo clock domain
    //============================================================

    val vo_clk      = Bool
    val vo_reset_   = Bool

    val u_vo_clk_gen = new DCM_CLKGEN(
            clkfx_divide    = 25,
            clkfx_multiply  = 25,
            clkin_period    = "40.0"
        )
    u_vo_clk_gen.io.CLKIN       <> io.osc_clk
    u_vo_clk_gen.io.CLKFX       <> vo_clk
    u_vo_clk_gen.io.RST         <> False
    u_vo_clk_gen.io.FREEZEDCM   <> False
    u_vo_clk_gen.io.PROGCLK     <> False
    u_vo_clk_gen.io.PROGDATA    <> False
    u_vo_clk_gen.io.PROGEN      <> False

    val voClkRawDomain = ClockDomain(
        clock = vo_clk,
        frequency = FixedFrequency(148.5 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )

    val vo_reset_gen = new ClockingArea(voClkRawDomain) {
        val reset_unbuffered_ = True

        val reset_cntr = Reg(UInt(5 bits)) init(0)
        when(reset_cntr =/= U(reset_cntr.range -> true)){
            reset_cntr := reset_cntr + 1
            reset_unbuffered_ := False
        }

        vo_reset_ := RegNext(reset_unbuffered_)
    }

    val voClkDomain = ClockDomain(
            clock = vo_clk,
            reset = vo_reset_,
            config = ClockDomainConfig(
                resetKind = SYNC,
                resetActiveLevel = LOW
            )
        )

    //============================================================
    // Core logic
    //============================================================

    val core = new ClockingArea(clkMainDomain) {

        val vo = VgaData()

        //============================================================
        // Core logic
        //============================================================

        val u_pano_core = new PanoCore(voClkDomain)

        u_pano_core.io.led_red      <> io.led_red
        u_pano_core.io.led_green    <> io.led_green
        u_pano_core.io.led_blue     <> io.led_blue

        u_pano_core.io.switch_      <> io.pano_button

        u_pano_core.io.dvi_ctrl_scl <> io.dvi_spc
        u_pano_core.io.dvi_ctrl_sda <> io.dvi_spd

        u_pano_core.io.vo           <> vo

        //============================================================
        // Chrontel Pads DVI
        //============================================================
    
        val u_dvi = new ChrontelPads(voClkDomain, includeXClkN = true)
        u_dvi.io.pads             <> io.dvi
        u_dvi.io.vsync            <> vo.vsync
        u_dvi.io.hsync            <> vo.hsync
        u_dvi.io.de               <> vo.de
        u_dvi.io.r                <> vo.r
        u_dvi.io.g                <> vo.g
        u_dvi.io.b                <> vo.b

        //============================================================
        // Chrontel Pads HDMI
        //============================================================
    
        val u_hdmi = new ChrontelPads(voClkDomain, includeXClkN = false)
        u_hdmi.io.pads            <> io.hdmi
        u_hdmi.io.vsync           <> vo.vsync
        u_hdmi.io.hsync           <> vo.hsync
        u_hdmi.io.de              <> vo.de
        u_hdmi.io.r               <> vo.r
        u_hdmi.io.g               <> vo.g
        u_hdmi.io.b               <> vo.b

    }

}

object PanoVerilog{
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)
        config.generateVerilog({
            val toplevel = new Pano()
            InOutWrapper(toplevel)
        })
        println("DONE")
    }
}

