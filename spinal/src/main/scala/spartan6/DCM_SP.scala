
package spartan6

import spinal.core._

class DCM_SP(
        clkdv_divide            : Double = 2.0,
        clk_feedback            : String = "1X",
        clkfx_divide            : Int = 1,
        clkfx_multiply          : Int = 4,
        clkin_divide_by_2       : Boolean = false,
        clkin_period            : String = "10.0",
        clkout_phase_shift      : String = "NONE",
        deskew_adjust           : String = "SYSTEM_SYNCHRONOUS",
        dll_frequency_mode      : String = "LOW",
        dss_mode                : String = "NONE",
        duty_cycle_correction   : Boolean = false,
        phase_shift             : Int = 0,
        startup_wait            : Boolean = false
    ) extends BlackBox {

    val generic = new Generic {
        val CLKDV_DIVIDE            = clkdv_divide
        val CLK_FEEDBACK            = clk_feedback
        val CLKFX_DIVIDE            = clkfx_divide
        val CLKFX_MULTIPLY          = clkfx_multiply
        val CLKIN_DIVIDE_BY_2       = if (clkin_divide_by_2) True else False
        val CLKIN_PERIOD            = clkin_period
        val CLKOUT_PHASE_SHIFT      = clkout_phase_shift
        val DESKEW_ADJUST           = deskew_adjust
        val DLL_FREQUENCY_MODE      = dll_frequency_mode
        val DSS_MODE                = dss_mode
        val DUTY_CYCLE_CORRECTION   = if (duty_cycle_correction) True else False
        val PHASE_SHIFT             = phase_shift
        val STARTUP_WAIT            = if (startup_wait) True else False
    }

    val io = new Bundle {
        val RST          = in(Bool)
        val CLKIN        = in(Bool)
        val CLKFB        = in(Bool)
        val DSSEN        = in(Bool)

        val PSCLK        = in(Bool)
        val PSINCDEC     = in(Bool)
        val PSEN         = in(Bool)
        val PSDONE       = in(Bool)

        val CLK0         = out(Bool)
        val CLK90        = out(Bool)
        val CLK180       = out(Bool)
        val CLK270       = out(Bool)
        val CLK2X        = out(Bool)
        val CLK2X180     = out(Bool)
        val CLKDV        = out(Bool)
        val CLKFX        = out(Bool)
        val CLKFX180     = out(Bool)
        val LOCKED       = out(Bool)
        val STATUS       = out(Bits(8 bits))
    }

    noIoPrefix()
}
