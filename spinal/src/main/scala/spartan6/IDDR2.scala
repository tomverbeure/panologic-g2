
package spartan6

import spinal.core._

class IDDR2(
        ddr_alignment:    String      = "NONE", 
        init_q0:          Boolean     = false, 
        init_q1:          Boolean     = false, 
        srtype:           String      = "SYNC"
    ) extends BlackBox {

    val generic = new Generic {
        val DDR_ALIGNMENT = ddr_alignment
        val INIT_Q0       = if (init_q0) True else False
        val INIT_Q1       = if (init_q1) True else False
        val SRTYPE        = srtype
    }

    val io = new Bundle {
        val D       = in(Bool)
        val C0      = in(Bool)
        val C1      = in(Bool)
        val CE      = in(Bool)
        val R       = in(Bool)
        val S       = in(Bool)
        val Q0      = out(Bool)
        val Q1      = out(Bool)
    }

    noIoPrefix()
}
