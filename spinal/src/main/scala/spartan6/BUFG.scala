
package spartan6

import spinal.core._

class BUFG() extends BlackBox {

    val io = new Bundle {
        val I = in(Bool)
        val O = out(Bool)
    }

    noIoPrefix()
}

class BUFH() extends BlackBox {

    val io = new Bundle {
        val I = in(Bool)
        val O = out(Bool)
    }

    noIoPrefix()
}
