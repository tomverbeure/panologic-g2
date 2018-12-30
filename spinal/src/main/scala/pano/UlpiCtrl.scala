
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.misc._
import spinal.lib.bus.amba3.apb._

object UlpiCtrl {
    def getApb3Config() = Apb3Config(addressWidth = 16,dataWidth = 32)
}

class UlpiCtrl(cpuDomain: ClockDomain) extends Component {

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
        val reg_wr_done = out(Bool)
        val reg_rd_done = out(Bool)
    }

    val ulpiDomain = ClockDomain(
        clock       = io.ulpi.clk,
        frequency   = FixedFrequency(60 MHz),
        config      = ClockDomainConfig(
                        resetKind = BOOT
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

        io.reg_wr_done      := False
        io.reg_rd_done      := False
        io.reg_rd_data      := 0

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
                    io.reg_wr_done  := True

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
                cur_state       := UlpiState.RegRdData
            }

            is(UlpiState.RegRdData){
                io.reg_rd_done  := True
                io.reg_rd_data  := io.ulpi.data.read

                cur_state       := UlpiState.Idle
            }
        }

    }
}

object UlpiCtrlVerilog{
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)
        config.generateVerilog({
            val toplevel = new UlpiCtrl(ClockDomain.current)
            InOutWrapper(toplevel)
        })
        println("DONE")
    }
}

