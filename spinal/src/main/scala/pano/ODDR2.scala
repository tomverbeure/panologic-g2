
package pano

import spinal.core._

class ODDR2(ddr_alignment: String = "NONE", init: Boolean = false, srtype: String = "SYNC") extends BlackBox {

    val generic = new Generic {
        val DDR_ALIGNMENT = ddr_alignment
        val INIT          = if (init) True else False
        val SRTYPE        = srtype
    }

    val io = new Bundle {
        val D0      = in(Bool)
        val D1      = in(Bool)
        val C0      = in(Bool)
        val C1      = in(Bool)
        val CE      = in(Bool)
        val R       = in(Bool)
        val S       = in(Bool)
        val Q       = out(Bool)
    }

    noIoPrefix()
}
