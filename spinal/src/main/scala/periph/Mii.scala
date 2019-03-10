
package mii

import spinal.core._
import spinal.lib._
import spinal.lib.io._

case class MiiRx() extends Bundle with IMasterSlave
{
    val clk         = Bool
    val dv          = Bool
    val er          = Bool
    val d           = Bits(4 bits)

    override def asMaster: Unit = {
        out(clk)
        out(dv)
        out(er)
        out(d)
    }
}

case class MiiTx() extends Bundle with IMasterSlave
{
    val clk         = Bool
    val en          = Bool
    val er          = Bool
    val d           = Bits(4 bits)

    override def asMaster: Unit = {
        in(clk)
        out(en)
        out(er)
        out(d)
    }
}

case class MiiMdio() extends Bundle with IMasterSlave
{
    val mdc         = Bool
    val mdio        = TriState(Bool)

    override def asMaster: Unit = {
        out(mdc)
        master(mdio)
    }
}

case class Mii() extends Bundle with IMasterSlave
{
    val rx      = MiiRx()
    val tx      = MiiTx()

    val col     = Bool
    val crs     = Bool

    val mdio    = MiiMdio()

    override def asMaster: Unit = {
        slave(rx)
        master(tx)
        in(col)
        in(crs)
        master(mdio)
    }
}


