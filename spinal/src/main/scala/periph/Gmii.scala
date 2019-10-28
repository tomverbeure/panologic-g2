
package gmii

import spinal.core._
import spinal.lib._
import spinal.lib.io._

case class GmiiRx() extends Bundle with IMasterSlave
{
    val clk         = Bool
    val dv          = Bool
    val er          = Bool
    val d           = Bits(8 bits)

    override def asMaster: Unit = {
        out(clk)
        out(dv)
        out(er)
        out(d)
    }
}

case class GmiiTx() extends Bundle with IMasterSlave
{
    val gclk        = Bool
    val clk         = Bool
    val en          = Bool
    val er          = Bool
    val d           = Bits(8 bits)

    override def asMaster: Unit = {
        out(gclk)
        in(clk)
        out(en)
        out(er)
        out(d)
    }
}

case class GmiiMdio() extends Bundle with IMasterSlave
{
    val mdc         = Bool
    val mdio        = TriState(Bool)

    override def asMaster: Unit = {
        out(mdc)
        master(mdio)
    }
}

case class Gmii() extends Bundle with IMasterSlave
{
    val rx      = GmiiRx()
    val tx      = GmiiTx()

    val col     = Bool
    val crs     = Bool

    val mdio    = GmiiMdio()

    override def asMaster: Unit = {
        slave(rx)
        master(tx)
        in(col)
        in(crs)
        master(mdio)
    }
}


