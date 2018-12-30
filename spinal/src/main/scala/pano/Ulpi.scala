
package pano

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
        slave(data)
        out(direction)
        in(stp)
        out(nxt)
        in(reset)
    }
}

