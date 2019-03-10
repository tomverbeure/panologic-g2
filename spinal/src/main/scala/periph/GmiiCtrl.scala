
package gmii

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._

case class GmiiRxCtrl() extends Component {

    val io = new Bundle {
        val rx                  = slave(GmiiRx())
        val rx_fifo_rd          = master(Stream(Bits(10 bits)))
        val rx_fifo_rd_count    = out(UInt(16 bits))
    }

    val gmiiRxDomain = ClockDomain(
        clock       = io.rx.clk,
        frequency   = FixedFrequency(125 MHz),
        config      = ClockDomainConfig(
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

object GmiiCtrl {
    def getApb3Config() = Apb3Config(addressWidth = 5,dataWidth = 32)
}

case class GmiiCtrl() extends Component {

    val io = new Bundle {
        val apb             = slave(Apb3(GmiiCtrl.getApb3Config()))

        val gmii            = master(Gmii())
    }

    //============================================================
    // GMII RX
    //============================================================
    val u_gmii_rx = GmiiRxCtrl()
    u_gmii_rx.io.rx                 <> io.gmii.rx

    //============================================================
    // GMII TX
    //============================================================
    val u_gmii_tx = GmiiTxCtrl()
    u_gmii_tx.io.tx         <> io.gmii.tx

    //============================================================
    // APB
    //============================================================
    val ctrl = Apb3SlaveFactory(io.apb)

    val mdio_ctrl = new Area {
        // MDIO bit bang control is just 1 register for everything
        io.gmii.mdio.mdc                := ctrl.createReadAndWrite(Bool, 0x0000, 0) init(False)
        io.gmii.mdio.mdio.write         := ctrl.createReadAndWrite(Bool, 0x0000, 1) init(False)
        io.gmii.mdio.mdio.writeEnable   := ctrl.createReadAndWrite(Bool, 0x0000, 2) init(False)
        ctrl.read(io.gmii.mdio.mdio.read, 0x0000, 3)
    }

    val cpu_rx_fifo_rd = Stream(Bits(10 bits))

    val rx_fifo_rd = new Area {
        ctrl.read(u_gmii_rx.io.rx_fifo_rd.valid,   0x0004, 16)
        ctrl.read(u_gmii_rx.io.rx_fifo_rd.payload, 0x0004, 0)
        ctrl.read(u_gmii_rx.io.rx_fifo_rd_count,   0x0008, 0)

        u_gmii_rx.io.rx_fifo_rd.ready  := ctrl.isReading(0x0004) && u_gmii_rx.io.rx_fifo_rd.valid
    }

}
