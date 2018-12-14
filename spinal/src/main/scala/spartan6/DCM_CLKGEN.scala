
package spartan6

import spinal.core._

class DCM_CLKGEN(
        clkfx_divide            : Int = 1,
        clkdv_divide            : Int = 2,
        clkfx_md_max            : Double = 0.0,
        clkfx_multiply          : Int = 4,
        clkin_period            : String = "10.0",
        dfs_bandwidth           : String = "OPTIMIZED",
        prog_md_bandwidth       : String = "OPTIMIZED",
        spread_spectrum         : String = "NONE",
        startup_wait            : Boolean = false
    ) extends BlackBox {

    val generic = new Generic {
        val CLKFX_DIVIDE            = clkfx_divide
        val CLKDV_DIVIDE            = clkdv_divide
        val CLKFX_MD_MAc            = clkfx_md_max
        val CLKFX_MULTIPLY          = clkfx_multiply
        val CLKIN_PERIOD            = clkin_period
        val DFS_BANDWIDTH           = dfs_bandwidth
        val PROG_MD_BANDWIDTH       = prog_md_bandwidth
        val SPREAD_SPECTRUM         = spread_spectrum
        val STARTUP_WAIT            = if (startup_wait) True else False
    }

    val io = new Bundle {
        val CLKIN        = in(Bool)

        val CLKFX        = out(Bool)
        val CLKFXDV      = out(Bool)
        val CLK180       = out(Bool)

        val RST          = in(Bool)
        val FREEZEDCM    = in(Bool)
        val LOCKED       = out(Bool)
        //val STATUS       = out(Bits(2 downto 1))

        val PROGCLK      = in(Bool)
        val PROGDATA     = in(Bool)
        val PROGEN       = in(Bool)
        val PROGDONE     = out(Bool)
    }

    noIoPrefix()
}
