
package mii

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._

case class MiiRxCtrl() extends Component {

    val io = new Bundle {
        val rx                  = slave(MiiRx())
        val rx_fifo_rd          = master(Stream(Bits(6 bits)))
        val rx_fifo_rd_count    = out(UInt(16 bits))
    }

    val miiRxDomain = ClockDomain(
        clock       = io.rx.clk,
        frequency   = FixedFrequency(25 MHz),
        config      = ClockDomainConfig(
                        resetKind = BOOT
        )
    )

    val rx_domain = new ClockingArea(miiRxDomain) {

        val rx_fifo_wr = Stream(Bits(10 bits))
        rx_fifo_wr.valid    := (io.rx.dv | io.rx.er) & rx_fifo_wr.ready
        rx_fifo_wr.payload  := io.rx.dv ## io.rx.er ## io.rx.d
    }

    val u_rx_fifo = StreamFifoCC(Bits(10 bits), 2048, miiRxDomain, ClockDomain.current)
    u_rx_fifo.io.push << rx_domain.rx_fifo_wr
    u_rx_fifo.io.pop  >> io.rx_fifo_rd

    io.rx_fifo_rd_count := u_rx_fifo.io.popOccupancy.resize(16 bits)

}

case class MiiTxCtrl() extends Component {

    val io = new Bundle {
        val tx  = master(MiiTx())
    }

    io.tx.en        := False
    io.tx.er        := False
    io.tx.d         := 0

}

object MiiCtrl {
    def getApb3Config() = Apb3Config(addressWidth = 5,dataWidth = 32)
}

case class MiiCtrl() extends Component {

    val io = new Bundle {
        val apb             = slave(Apb3(MiiCtrl.getApb3Config()))

        val mii            = master(Mii())
    }

    //============================================================
    // MII RX
    //============================================================
    val u_mii_rx = MiiRxCtrl()
    u_mii_rx.io.rx                <> io.mii.rx

    //============================================================
    // MII TX
    //============================================================
    val u_mii_tx = MiiTxCtrl()
    u_mii_tx.io.tx                <> io.mii.tx

    //============================================================
    // APB
    //============================================================
    val ctrl = Apb3SlaveFactory(io.apb)

    val mdio_ctrl = new Area {
        // MDIO bit bang control is just 1 register for everything
        io.mii.mdio.mdc                := ctrl.createReadAndWrite(Bool, 0x0000, 0) init(False)
        io.mii.mdio.mdio.write         := ctrl.createReadAndWrite(Bool, 0x0000, 1) init(False)
        io.mii.mdio.mdio.writeEnable   := ctrl.createReadAndWrite(Bool, 0x0000, 2) init(False)
        ctrl.read(io.mii.mdio.mdio.read, 0x0000, 3)
    }

    val cpu_rx_fifo_rd = Stream(Bits(10 bits))

    val rx_fifo_rd = new Area {
        ctrl.read(u_mii_rx.io.rx_fifo_rd.valid,   0x0004, 16)
        ctrl.read(u_mii_rx.io.rx_fifo_rd.payload, 0x0004, 0)
        ctrl.read(u_mii_rx.io.rx_fifo_rd_count,   0x0008, 0)

        u_mii_rx.io.rx_fifo_rd.ready  := ctrl.isReading(0x0004) && u_mii_rx.io.rx_fifo_rd.valid
    }

}
