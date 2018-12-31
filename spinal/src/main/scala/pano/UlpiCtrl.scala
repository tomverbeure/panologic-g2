
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.misc._
import spinal.lib.bus.amba3.apb._

object UlpiCtrl {
    def getApb3Config() = Apb3Config(addressWidth = 6,dataWidth = 32)
}

case class UlpiCtrl() extends Component {

    val io = new Bundle {
        val ulpi        = slave(Ulpi())

        val tx_start    = in(Bool)
        val tx_data     = slave(Stream(Bits(8 bits)))

        val rx_data     = master(Flow(Bits(9 bits)))

        val reg_rd      = in(Bool)
        val reg_wr      = in(Bool)
        val reg_addr    = in(UInt(6 bits))
        val reg_wr_data = in(Bits(8 bits))
        val reg_rd_data = out(Bits(8 bits))
        val reg_done    = out(Bool)
    }

    val rawUlpiDomain = ClockDomain(
        clock       = io.ulpi.clk,
        frequency   = FixedFrequency(60 MHz),
        config      = ClockDomainConfig(
                        resetKind = BOOT
        )
    )

    val ulpi_reset_ = rawUlpiDomain(RegNext(True) init(False))

    val ulpiDomain = ClockDomain(
        clock = io.ulpi.clk,
        reset = ulpi_reset_,
        config = ClockDomainConfig(
                    resetKind = SYNC,
                    resetActiveLevel = LOW
        )
    )

    object UlpiState extends SpinalEnum {
        val WaitIdle        = newElement()
        val Idle            = newElement()
        val Rx              = newElement()
        val Tx              = newElement()
        val RegWrAddr       = newElement()
        val RegWrData       = newElement()
        val RegWrStp        = newElement()
        val RegRdAddr       = newElement()
        val RegRdTurn       = newElement()
        val RegRdData       = newElement()
    }

    val ulpi_domain = new ClockingArea(ulpiDomain) {

        // FIXME: Make register controllable?
        io.ulpi.reset   := False

        // Combinational path from dir input to data tri-state.
        io.ulpi.data.writeEnable    := B(8 bits, default -> !io.ulpi.direction)

        val cur_state = Reg(UlpiState()) init(UlpiState.WaitIdle)

        // Default FSM outputs
        val ulpi_stp        = Reg(Bool) init(False)
        val ulpi_data_out   = Reg(Bits(8 bits)) init(0)

        io.ulpi.stp         := ulpi_stp
        io.ulpi.data.write  := ulpi_data_out

        // RX CMD
        val rx_cmd  = Reg(Bits(8 bits)) init(0)

        val direction_d = RegNext(io.ulpi.direction) init(True)
        val turn_around = (direction_d != io.ulpi.direction)

        val reg_done        = Reg(Bool) init(False)
        val reg_rd_data     = Reg(Bits(8 bits)) init(0)

        io.reg_done    := reg_done
        io.reg_rd_data := reg_rd_data

        io.rx_data.valid    := False
        io.rx_data.payload  := 0

        io.tx_data.ready    := False

        val rx_data_seen    = Reg(Bool) init(False)

        switch(cur_state){
            is(UlpiState.WaitIdle){
                ulpi_data_out   := 0

                when(!io.ulpi.direction){
                    cur_state   := UlpiState.Idle
                }
            }

            is(UlpiState.Idle){
                ulpi_data_out   := 0
                ulpi_stp        := False

                when(io.ulpi.direction){
                    cur_state       := UlpiState.Rx
                    rx_data_seen    := False
                }
                .elsewhen(io.reg_wr){
                    ulpi_data_out   := B"10" ## io.reg_addr.asBits

                    cur_state       := UlpiState.RegWrAddr
                }
                .elsewhen(io.reg_rd){
                    ulpi_data_out   := B"11" ## io.reg_addr.asBits

                    cur_state       := UlpiState.RegRdAddr
                }
                .elsewhen(io.tx_start && io.tx_data.valid){
                    ulpi_data_out       := B"01" ## io.tx_data.payload(5 downto 0)
                    io.tx_data.ready    := True

                    cur_state       := UlpiState.Tx
                }
            }

            //============================================================
            // Data Transmit
            //============================================================

            is(UlpiState.Tx){
                when(io.ulpi.direction){
                    // Abort packet
                    cur_state       := UlpiState.Rx         // FIXME?
                }
                .elsewhen(io.ulpi.nxt){
                    when(!io.tx_data.valid){
                        ulpi_data_out   := 0
                        ulpi_stp        := True

                        cur_state   := UlpiState.Idle
                    }
                    .otherwise{
                        ulpi_data_out       := io.tx_data.payload
                        ulpi_stp            := False
                        io.tx_data.ready    := True
                    }
                }
            }

            //============================================================
            // Data Receive
            //============================================================
            is(UlpiState.Rx){
                when(!io.ulpi.direction){
                    cur_state       := UlpiState.Idle

                    io.rx_data.valid   := rx_data_seen
                    io.rx_data.payload := rx_data_seen ## B"00000000"
                }
                .elsewhen(!io.ulpi.nxt){
                    rx_cmd          := io.ulpi.data.read

                    when(io.ulpi.data.read(5 downto 0) === 0){
                        // RxActive == 0
                        io.rx_data.valid   := rx_data_seen
                        io.rx_data.payload := rx_data_seen ## B"00000000"
                    }
                }
                .otherwise{
                    rx_data_seen       := True
                    io.rx_data.valid   := True
                    io.rx_data.payload := False ## io.ulpi.data.read
                }
            }

            //============================================================
            // Register Write
            //============================================================
            is(UlpiState.RegWrAddr){
                when(io.ulpi.direction){
                    // Abort register access...
                    cur_state       := UlpiState.Rx
                }
                .elsewhen(io.ulpi.nxt){
                    ulpi_data_out   := io.reg_wr_data

                    cur_state       := UlpiState.RegWrData
                }
            }

            is(UlpiState.RegWrData){
                when(io.ulpi.direction){
                    // Abort register access...
                    cur_state   := UlpiState.Rx
                }
                .elsewhen(io.ulpi.nxt){
                    ulpi_data_out   := 0
                    ulpi_stp        := True

                    cur_state       := UlpiState.RegWrStp
                }
            }

            is(UlpiState.RegWrStp){
                when(io.ulpi.direction){
                    // Abort register access...
                    cur_state   := UlpiState.Rx
                }
                .otherwise{
                    ulpi_data_out   := 0
                    ulpi_stp        := False
                    reg_done        := True

                    cur_state       := UlpiState.Idle
                }
            }

            //============================================================
            // Register Read
            //============================================================
            is(UlpiState.RegRdAddr){
                when(io.ulpi.direction){
                    // Abort register access...
                    cur_state       := UlpiState.Rx
                }
                .elsewhen(io.ulpi.nxt){
                    cur_state       := UlpiState.RegRdTurn
                }
            }

            is (UlpiState.RegRdTurn){
                //when(io.ulpi.direction){          // This shouldn't be needed?
                    cur_state       := UlpiState.RegRdData
                //}
            }

            is(UlpiState.RegRdData){
                //when(io.ulpi.direction){          // This shouldn't be needed?
                    reg_done        := True
                    reg_rd_data     := io.ulpi.data.read

                    cur_state       := UlpiState.Idle
                //}
            }
        }

    }

    def driveFrom(busCtrl: BusSlaveFactory, baseAddress: BigInt) = new Area {

        val reg_addr    = busCtrl.createReadAndWrite(UInt(6 bits), 0x0000,  0) init(0)
        val reg_wr_data = busCtrl.createReadAndWrite(Bits(8 bits), 0x0000,  8) init(0)
        val reg_wr      = busCtrl.createReadAndWrite(Bool,         0x0000, 31) init(False)

        io.reg_addr     := reg_addr.addTag(crossClockDomain)
        io.reg_wr_data  := reg_wr_data.addTag(crossClockDomain)

        val reg_cmd_fifo_wr, reg_cmd_fifo_rd = Stream(Bool)
        reg_cmd_fifo_wr.valid   := RegNext(busCtrl.isWriting(0x0000)) init(False)
        reg_cmd_fifo_wr.payload := reg_wr

        val u_reg_cmd_fifo = StreamFifoCC(Bool, 2, ClockDomain.current, ulpiDomain)
        u_reg_cmd_fifo.io.push  << reg_cmd_fifo_wr
        u_reg_cmd_fifo.io.pop   >> reg_cmd_fifo_rd

        io.reg_wr   := reg_cmd_fifo_rd.valid &&  reg_cmd_fifo_rd.payload
        io.reg_rd   := reg_cmd_fifo_rd.valid && !reg_cmd_fifo_rd.payload

        reg_cmd_fifo_rd.ready   := io.reg_done

        val status = reg_cmd_fifo_rd.valid.addTag(crossClockDomain) ## io.reg_rd_data.addTag(crossClockDomain)

        busCtrl.read(status, 0x0004)

        io.tx_start         := False
        io.tx_data.valid    := False
        io.tx_data.payload  := 0
    }
}

case class UlpiCtrlTop() extends Component 
{
    val io = new Bundle {
        val apb         = slave(Apb3(UlpiCtrl.getApb3Config()))

        val ulpi        = slave(Ulpi())
    }

    val u_ulpi_ctrl = UlpiCtrl()
    u_ulpi_ctrl.io.ulpi             <> io.ulpi

    val ulpi_ctrl = new ClockingArea(ClockDomain.current) {
        val busCtrl = Apb3SlaveFactory(io.apb)

        val apb_regs = u_ulpi_ctrl.driveFrom(busCtrl, 0x0)
    }

}

case class UlpiCtrlFormalTb() extends Component
{

    val io = new Bundle {
        val apb     = slave(Apb3(UlpiCtrl.getApb3Config()))

        val ulpi    = slave(Ulpi())
    }

    val rawClkDomain = ClockDomain(
        clock = io.ulpi.clk,
        frequency = FixedFrequency(100 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )

    val reset_ = rawClkDomain(RegNext(True) init(False))

    val clkDomain = ClockDomain(
        clock = io.ulpi.clk,
        reset = reset_,
        config = ClockDomainConfig(
                    resetKind = SYNC,
                    resetActiveLevel = LOW
        )
    )

    val core = new ClockingArea(clkDomain) {

        val u_ulpi_ctrl = new UlpiCtrl()
        u_ulpi_ctrl.io.ulpi             <> io.ulpi

        val ulpi_ctrl_regs = new ClockingArea(ClockDomain.current) {
            val busCtrl = Apb3SlaveFactory(io.apb)

            val apb_regs = u_ulpi_ctrl.driveFrom(busCtrl, 0x0)
        }

        import spinal.core.GenerationFlags._
        import spinal.core.Formal._

        GenerationFlags.formal{
            assume(!(stable(io.apb.PENABLE) && !stable(io.apb.PSEL)))
            assume(!(stable(io.apb.PENABLE) && !stable(io.apb.PADDR)))
            assume(!(stable(io.apb.PENABLE) && !stable(io.apb.PWDATA)))
            assume(io.apb.PADDR(1 downto 0) === 0)
            assume(ulpi_ctrl_regs.apb_regs.u_reg_cmd_fifo.io.pushOccupancy <= 1)
            assume(ulpi_ctrl_regs.apb_regs.u_reg_cmd_fifo.io.popOccupancy  <= 1)

            cover(!initstate() && reset_ && u_ulpi_ctrl.io.reg_done === True && io.apb.PRDATA(31 downto 0) === 0x55)
        }
    }
}


object UlpiCtrlVerilog{
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)
        config.includeFormal.generateSystemVerilog({
            val toplevel = new UlpiCtrlFormalTb()
            toplevel
        })
        println("DONE")
    }
}

