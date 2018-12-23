
package pano

import spinal.core._
import spinal.lib._

case class GmiiRxCtrl() extends Component {

    val io = new Bundle {
        val rx                  = slave(GmiiRx())
        val rx_fifo_rd          = master(Stream(Bits(10 bits)))
        val rx_fifo_rd_count    = out(UInt(16 bits))
    }

    val gmiiRxDomain = ClockDomain(
        clock       = io.rx.clk,
        frequency   = FixedFrequency(125 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )

    val rx_domain = new ClockingArea(gmiiRxDomain) {

        val rx_fifo_wr = Stream(Bits(10 bits))
        rx_fifo_wr.valid    := (io.rx.dv | io.rx.er) & rx_fifo_wr.ready
        rx_fifo_wr.payload  := io.rx.dv ## io.rx.er ## io.rx.d
    }

    val u_rx_fifo = StreamFifoCC(Bits(10 bits), 2048, gmiiRxDomain, ClockDomain.current)
    u_rx_fifo.io.push << rx_domain.rx_fifo_wr
    u_rx_fifo.io.pop  >> io.rx_fifo_rd

    io.rx_fifo_rd_count := u_rx_fifo.io.popOccupancy.resize(16 bits)
    
}

case class GmiiTxCtrl() extends Component {

    val io = new Bundle {
        val tx  = master(GmiiTx())
    }

    io.tx.en        := False
    io.tx.er        := False
    io.tx.d         := 0

}

case class GmiiCtrl() extends Component {

    val io = new Bundle {
        val gmii        = master(Gmii())

        val cpu_mdio        = slave(GmiiMdio())
        val cpu_rx_fifo_rd  = master(Stream(Bits(10 bits)))
    }

    io.gmii.mdio    <> io.cpu_mdio

    val u_gmii_rx = GmiiRxCtrl()
    u_gmii_rx.io.rx             <> io.gmii.rx
    u_gmii_rx.io.rx_fifo_rd     <> io.cpu_rx_fifo_rd

    val u_gmii_tx = GmiiTxCtrl()
    u_gmii_tx.io.tx         <> io.gmii.tx
}
