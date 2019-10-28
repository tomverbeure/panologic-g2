
package pano

import spinal.core._

import spinal.lib._
import spinal.lib.io._

import spartan6._

import gmii._
import ulpi._

case class PanoConfig(
              isG1              : Boolean,
              isG2              : Boolean,
              includeDvi        : Boolean,
              includeHdmi       : Boolean,
              includeVga        : Boolean,
              includeGmii       : Boolean,
              includeUlpi       : Boolean,
              includeUart       : Boolean,
              includeCodec      : Boolean
      )
{
    def includeDviI2C = includeDvi || includeHdmi
}


class Pano(config : PanoConfig) extends Component {

    val io = new Bundle {
        val osc_clk             = in(Bool)

        val led_red             = out(Bool)
        val led_green           = out(Bool)
        val led_blue            = out(Bool)

        val pano_button         = in(Bool)

        // I2C control for both Chrontel chips
        val dvi_spc             = if (config.includeDviI2C) master(TriState(Bool)) else null
        val dvi_spd             = if (config.includeDviI2C) master(TriState(Bool)) else null

        val dvi                 = if (config.includeDvi)  out(ChrontelIntfc(includeXClkN = true))  else null
        val hdmi                = if (config.includeHdmi) out(ChrontelIntfc(includeXClkN = false)) else null

        // MII interface
        val gmii_rst_           = if (config.isG2) out(Bool)              else null
        val gmii                = if (config.includeGmii) master(Gmii())  else null

        // USB clock and reset
        val usb_reset_          = if (config.includeUlpi) out(Bool) else null
        val usb_clk             = if (config.includeUlpi) out(Bool) else null

        // ULPI Interface
        val ulpi                = if (config.includeUlpi) slave(Ulpi()) else null
    
        // Codec Interface
        val codec_scl           = if (config.includeCodec) master(TriState(Bool)) else null
        val codec_sda           = if (config.includeCodec) master(TriState(Bool)) else null
    }

    noIoPrefix()

    // This pin should always have a constant value.
    // When True, you will get a 125MHz fixed clock on io.osc_clk.
    // When False, you get 25MHz instead.
    // https://github.com/tomverbeure/panologic-g2#fpga-external-clocking-architecture
    if (config.isG2)
        io.gmii_rst_    := True

    if (config.includeUlpi)
        io.usb_reset_   := True

    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val oscClkDomain = ClockDomain(
        clock = io.osc_clk,
        frequency = FixedFrequency(if (config.isG2) 125 MHz else 100 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )

    //============================================================
    // Create raw main clock
    //============================================================

    val main_clk_raw = Bool

    val u_main_clk_gen = if (config.isG2) new Area {
        val u_main_clk_pll = new DCM_CLKGEN(
                clkfx_divide    = 20,
                clkfx_multiply  = 4,
                clkin_period    = "8.0"
            )
        u_main_clk_pll.io.CLKIN       <> io.osc_clk
        u_main_clk_pll.io.CLKFX       <> main_clk_raw
        u_main_clk_pll.io.RST         <> False
        u_main_clk_pll.io.FREEZEDCM   <> False
        u_main_clk_pll.io.PROGCLK     <> False
        u_main_clk_pll.io.PROGDATA    <> False
        u_main_clk_pll.io.PROGEN      <> False
    }
    else new ClockingArea(oscClkDomain) {
        // Create div4 clock
        val clk_cntr = Reg(UInt(2 bits)) init(0)
        clk_cntr      := clk_cntr + 1
        main_clk_raw  := RegNext(clk_cntr(1))
    }

    val mainClkRawDomain = ClockDomain(
        clock = main_clk_raw,
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
    main_clk       := main_clk_raw

    val clkMainDomain = ClockDomain(
        clock = main_clk,
        reset = main_reset_,
        config = ClockDomainConfig(
            resetKind = SYNC,
            resetActiveLevel = LOW
        )
    )

    //============================================================
    // vo_clk and vo clock domain
    //============================================================


    var voClkDomain : ClockDomain = null

    val u_vo_clk_gen = if (config.isG2) new Area {

        val vo_clk      = Bool
        val vo_reset_   = Bool

        val u_vo_clk_pll = new DCM_CLKGEN(
                clkfx_divide    = 125,
                clkfx_multiply  = 148,
                clkin_period    = "8.0"
            )

        u_vo_clk_pll.io.CLKIN       <> io.osc_clk
        u_vo_clk_pll.io.CLKFX       <> vo_clk
        u_vo_clk_pll.io.RST         <> False
        u_vo_clk_pll.io.FREEZEDCM   <> False
        u_vo_clk_pll.io.PROGCLK     <> False
        u_vo_clk_pll.io.PROGDATA    <> False
        u_vo_clk_pll.io.PROGEN      <> False

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

        voClkDomain = ClockDomain(
                clock = vo_clk,
                reset = vo_reset_,
                config = ClockDomainConfig(
                    resetKind = SYNC,
                    resetActiveLevel = LOW
                )
            )
    } else null

    //============================================================
    // GMII RX CLK
    //============================================================

    val gmiiRxClkDomain = if (config.includeGmii) ClockDomain(
            clock = io.gmii.rx.clk,
            config = ClockDomainConfig(
                resetKind = BOOT
            )
        ) else null

    val gmii_rx = if (config.includeGmii) new ClockingArea(gmiiRxClkDomain) {
        val green_counter   = Reg(UInt(24 bits))
        green_counter     := green_counter + 1
        //io.led_green      := green_counter.msb
    } else null

    //============================================================
    // USB 24MHz clock
    //============================================================

    val u_usb_clk_gen = if (config.includeUlpi) new Area {

        val u_usb_clk_pll = new DCM_CLKGEN(
                clkfx_divide    = 125,
                clkfx_multiply  = 24,
                clkin_period    = "8.0"
            )

        u_usb_clk_pll.io.CLKIN      <> io.osc_clk
        u_usb_clk_pll.io.CLKFX      <> io.usb_clk
        u_usb_clk_pll.io.RST        <> False
        u_usb_clk_pll.io.FREEZEDCM  <> False
        u_usb_clk_pll.io.PROGCLK    <> False
        u_usb_clk_pll.io.PROGDATA   <> False
        u_usb_clk_pll.io.PROGEN     <> False
    }

    //============================================================
    // Core logic
    //============================================================

    val core = new ClockingArea(clkMainDomain) {

        val red_counter   = Reg(UInt(24 bits))
        red_counter     := red_counter + 1
        //io.led_red      := red_counter.msb

        val vo = VgaData()

        //============================================================
        // Core logic
        //============================================================

        val u_pano_core = new PanoCore(voClkDomain, config)

        u_pano_core.io.led_red      <> io.led_red
        u_pano_core.io.led_green    <> io.led_green
        u_pano_core.io.led_blue     <> io.led_blue

        u_pano_core.io.switch_      <> io.pano_button

        if (config.includeDviI2C){
            u_pano_core.io.dvi_ctrl_scl <> io.dvi_spc
            u_pano_core.io.dvi_ctrl_sda <> io.dvi_spd
        }

        if (config.includeCodec){
            u_pano_core.io.codec_scl <> io.codec_scl
            u_pano_core.io.codec_sda <> io.codec_sda
        }

        if (config.includeGmii){
            u_pano_core.io.gmii         <> io.gmii
        }

        if (config.includeUlpi){
            u_pano_core.io.ulpi         <> io.ulpi
        }

        u_pano_core.io.vo           <> vo

        //============================================================
        // Chrontel Pads DVI
        //============================================================

        val u_dvi = if (config.includeDvi) new ChrontelPads(voClkDomain, includeXClkN = true) else null

        if (config.includeDvi) {
            u_dvi.io.pads             <> io.dvi
            u_dvi.io.vsync            <> vo.vsync
            u_dvi.io.hsync            <> vo.hsync
            u_dvi.io.de               <> vo.de
            u_dvi.io.r                <> vo.r
            u_dvi.io.g                <> vo.g
            u_dvi.io.b                <> vo.b
        }

        //============================================================
        // Chrontel Pads HDMI
        //============================================================

        val u_hdmi = if (config.includeHdmi) new ChrontelPads(voClkDomain, includeXClkN = false) else null

        if (config.includeHdmi) {
            u_hdmi.io.pads            <> io.hdmi
            u_hdmi.io.vsync           <> vo.vsync
            u_hdmi.io.hsync           <> vo.hsync
            u_hdmi.io.de              <> vo.de
            u_hdmi.io.r               <> vo.r
            u_hdmi.io.g               <> vo.g
            u_hdmi.io.b               <> vo.b
        }

    }

}

object PanoVerilog{
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)
        config.generateVerilog({

            def panoConfig = PanoConfig(
              isG1              = false,
              isG2              = true,
              includeDvi        = true,
              includeHdmi       = true,
              includeVga        = false,
              includeGmii       = true,
              includeUlpi       = true,
              includeUart       = false,
              includeCodec      = true
            )


            val toplevel = new Pano(panoConfig)
            InOutWrapper(toplevel)
        })
        println("DONE")
    }
}

