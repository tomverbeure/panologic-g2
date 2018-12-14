
package spartan6

import spinal.core._

class PLL_BASE(
        compensation            : String = "SYSTEM_SYNCHRONOUS",
        bandwidth               : String = "Optimized",
        clkout0_divide          : Int = 1,
        clkout1_divide          : Int = 1,
        clkout2_divide          : Int = 1,
        clkout3_divide          : Int = 1,
        clkout4_divide          : Int = 1,
        clkout5_divide          : Int = 1,
        clkout0_phase           : Double = 0.0,
        clkout1_phase           : Double = 0.0,
        clkout2_phase           : Double = 0.0,
        clkout3_phase           : Double = 0.0,
        clkout4_phase           : Double = 0.0,
        clkout5_phase           : Double = 0.0,
        clkout0_duty_cycle      : Double = 0.50,
        clkout1_duty_cycle      : Double = 0.50,
        clkout2_duty_cycle      : Double = 0.50,
        clkout3_duty_cycle      : Double = 0.50,
        clkout4_duty_cycle      : Double = 0.50,
        clkout5_duty_cycle      : Double = 0.50,
        clkfbout_mult           : Int = 1,
        divclk_divide           : Int = 1,
        clkfbout_phase          : Double = 0.0,
        ref_jitter              : Double = 0.1,
        clkin_period            : Double = 0.0
    ) extends BlackBox {

    val generic = new Generic {
        val COMPENSATION        = compensation
        val BANDWIDTH           = bandwidth
        val CLKOUT0_DIVIDE      = clkout0_divide
        val CLKOUT1_DIVIDE      = clkout1_divide
        val CLKOUT2_DIVIDE      = clkout2_divide
        val CLKOUT3_DIVIDE      = clkout3_divide
        val CLKOUT4_DIVIDE      = clkout4_divide
        val CLKOUT5_DIVIDE      = clkout5_divide
        val CLKOUT0_PHASE       = clkout0_phase
        val CLKOUT1_PHASE       = clkout1_phase
        val CLKOUT2_PHASE       = clkout2_phase
        val CLKOUT3_PHASE       = clkout3_phase
        val CLKOUT4_PHASE       = clkout4_phase
        val CLKOUT5_PHASE       = clkout5_phase
        val CLKOUT0_DUTY_CYCLE  = clkout0_duty_cycle
        val CLKOUT1_DUTY_CYCLE  = clkout1_duty_cycle
        val CLKOUT2_DUTY_CYCLE  = clkout2_duty_cycle
        val CLKOUT3_DUTY_CYCLE  = clkout3_duty_cycle
        val CLKOUT4_DUTY_CYCLE  = clkout4_duty_cycle
        val CLKOUT5_DUTY_CYCLE  = clkout5_duty_cycle
        val CLKFBOUT_MULT       = clkfbout_mult
        val DIVCLK_DIVIDE       = divclk_divide
        val CLKFBOUT_PHASE      = clkfbout_phase
        val REF_JITTER          = ref_jitter
        val CLKIN_PERIOD        = clkin_period
    }

    val io = new Bundle {
        val RST          = in(Bool)
        val CLKIN        = in(Bool)
        val CLKFBIN      = in(Bool)

        val CLKOUT0      = out(Bool)
        val CLKOUT1      = out(Bool)
        val CLKOUT2      = out(Bool)
        val CLKOUT3      = out(Bool)
        val CLKOUT4      = out(Bool)
        val CLKOUT5      = out(Bool)
        val CLKFBOUT     = out(Bool)

        val LOCKED       = out(Bool)
    }

    noIoPrefix()
}
