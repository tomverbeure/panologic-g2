
package ulpi

import spinal.core._
import spinal.lib._
import spinal.lib.io._

case class Ulpi() extends Bundle with IMasterSlave
{
    val clk         = Bool
    val data        = TriStateArray(8)
    val direction   = Bool
    val stp         = Bool
    val nxt         = Bool
    val reset       = Bool

    // Master = Phy, since that's how it's defined in the spec.
    override def asMaster: Unit = {
        out(clk)
        master(data)
        out(direction)
        in(stp)
        out(nxt)
        in(reset)
    }

    override def asSlave: Unit = {
        super.asSlave()
        master(data)        // Tri-state signals should always be master
    }
}

