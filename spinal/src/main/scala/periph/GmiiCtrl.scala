
package gmii

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._
import spinal.lib.bus.amba3.apb._
import spartan6._

case class GmiiRxCtrl() extends Component {

    val io = new Bundle {
        val rx                  = slave(GmiiRx())
        val rx_fifo_rd          = master(Stream(Bits(10 bits)))
        val rx_fifo_rd_count    = out(UInt(16 bits))
    }

    val rx_bufg = new BUFH()
    rx_bufg.io.I <> io.rx.clk

    val gmiiRxDomain = ClockDomain(
        clock       = rx_bufg.io.O,
        frequency   = FixedFrequency(125 MHz),
        config      = ClockDomainConfig(
                        resetKind = BOOT
        )
    )

    val rx_domain = new ClockingArea(gmiiRxDomain) {

        val rxDv = Reg(Bool)
        val rxEr = Reg(Bool)
        val rxD  = Reg(Bits(8 bits))
        val pktErr = Reg(Bool)
        val pktEnd = Reg(Bool)

        rxDv := io.rx.dv
        rxEr := io.rx.er
        rxD  := io.rx.d

        val rx_fifo_wr = Stream(Bits(10 bits))
        rx_fifo_wr.valid    := (rxDv | rxEr | pktEnd) & rx_fifo_wr.ready
        rx_fifo_wr.payload  := rxDv ## (rxEr | pktErr) ## rxD

        when (rxDv && (rxEr || !rx_fifo_wr.ready)) {
            pktErr := True
        }

        when (rxDv.fall()) {
            pktEnd := True
        }.elsewhen (rx_fifo_wr.ready) {
            pktEnd := False
            pktErr := False
        }
    }

    val u_rx_fifo = StreamFifoCC(Bits(10 bits), 2048, gmiiRxDomain, ClockDomain.current)
    u_rx_fifo.io.push << rx_domain.rx_fifo_wr
    u_rx_fifo.io.pop  >> io.rx_fifo_rd

    io.rx_fifo_rd_count := u_rx_fifo.io.popOccupancy.resize(16 bits)

}

case class GmiiTxCtrl() extends Component {

    val io = new Bundle {
        val tx  = master(GmiiTx())
        val tx_fifo_wr = slave(Stream(Bits(9 bits)))
        val clk_125 = in(Bool)
    }

    // TODO: Clock mux between io.clk_125 and io.tx.clk (for gigabit vs not)
    val gmiiTxDomain = ClockDomain(
        clock       = io.clk_125,
        frequency   = FixedFrequency(125 MHz),
        config      = ClockDomainConfig(
                        resetKind = BOOT
        )
    )

    val txEndToggle = Reg(Bool) init(False)

    when (io.tx_fifo_wr.valid && io.tx_fifo_wr.payload(8)) { txEndToggle := !txEndToggle }

    val tx_domain = new ClockingArea(gmiiTxDomain) {
        val tx_fifo_rd = Stream(Bits(9 bits))

        val txEndBuf       = BufferCC(txEndToggle, False)
        val packetCount    = Reg(UInt(8 bits)) init(0)
        val txFinishPacket = Reg(Bool)         init(False)

        when (txEndBuf.edge() && !txFinishPacket) {
            packetCount := packetCount + 1
        }.elsewhen(txFinishPacket) {
            packetCount := packetCount - 1
        }

        txFinishPacket   := False

        tx_fifo_rd.ready := False

        val txEn = Reg(Bool)         init(False)
        val txD  = Reg(Bits(8 bits)) init(0)

        val txClkOut = new ODDR2()

        txClkOut.io.D0 := False // Clock inverted to guarantee >2ns setup on the data
        txClkOut.io.D1 := True
        txClkOut.io.C0 := io.clk_125
        txClkOut.io.C1 := !io.clk_125
        txClkOut.io.CE := True
        txClkOut.io.R  := False
        txClkOut.io.S  := False

        io.tx.gclk := txClkOut.io.Q

        io.tx.en   := txEn
        io.tx.d    := txD
        io.tx.er   := False

        txEn := False
        txD  := 0

        val txFsm = new StateMachine {
            val counter = Reg(UInt(4 bits)) init(0)

            val stateIdle = new State with EntryPoint {
                whenIsActive(
                    when(packetCount > 0) {
                        goto(statePacket)
                    }
                )
            }

            val statePacket = new State {
                whenIsActive {
                    txEn             := True
                    tx_fifo_rd.ready := True
                    txD              := tx_fifo_rd.payload(7 downto 0)
                    when(tx_fifo_rd.payload(8)) {
                        goto(stateIFG)
                    }
                }
            }

            val stateIFG = new State {
                onEntry(counter := 12)
                whenIsActive {
                    counter := counter - 1
                    when(counter === 0) {
                        txFinishPacket := True
                        exit()
                    }
                }
            }
        }
    }

    val u_tx_fifo = StreamFifoCC(Bits(9 bits), 2048, ClockDomain.current, gmiiTxDomain)
    u_tx_fifo.io.push << io.tx_fifo_wr;
    u_tx_fifo.io.pop >> tx_domain.tx_fifo_rd;
}

object GmiiCtrl {
    def getApb3Config() = Apb3Config(addressWidth = 5,dataWidth = 32)
}

case class GmiiCtrl() extends Component {

    val io = new Bundle {
        val apb             = slave(Apb3(GmiiCtrl.getApb3Config()))

        val gmii            = master(Gmii())
        val clk_125         = in(Bool)
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
    u_gmii_tx.io.clk_125    <> io.clk_125

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

    val tx_fifo_wr = new Area {
        ctrl.createAndDriveFlow(Bits(9 bits), address = 0x000c).toStream >> u_gmii_tx.io.tx_fifo_wr
    }

}
