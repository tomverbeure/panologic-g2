
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.simple._
import spinal.lib.bus.misc._
import spinal.lib.bus.amba3.apb._


object UsbHost {
    // 8 bits -> 64 registers
    // We need 32 registers for MAX3421E compatibility. The other registers are for
    // additional status and debug.
    def getApb3Config() = Apb3Config(addressWidth = 7, dataWidth=32)

    // RX:      2x 64 bytes. Address: 0, 64
    // TX:      2x 64 bytes. Address: 128, 192
    // Setup:   8 bytes.     ADdress: 256
    def getFifoMemoryBusConfig() = PipelinedMemoryBusConfig(addressWidth = 9, dataWidth = 8)

    // Supported host-only registers as defined by MAX3421E SPI-to-USB chip
    def RCVFIFO_ADDR                = 1
    def SNDFIFO_ADDR                = 2
    def SUDFIFO_ADDR                = 4
    def RCVBC_ADDR                  = 6
    def SNDBC_ADDR                  = 7

    def USBIRQ_ADDR                 = 13
    def USBIEN_ADDR                 = 14
    def USBCTL_ADDR                 = 15
    def CPUCTL_ADDR                 = 16
    def PINCTL_ADDR                 = 17
    def REVISION_ADDR               = 18
    def HIRQ_ADDR                   = 25
    def HIEN_ADDR                   = 26
    def MODE_ADDR                   = 27
    def PERADDR_ADDR                = 28
    def HCTL_ADDR                   = 29
    def HXFR_ADDR                   = 30
    def HRSL_ADDR                   = 31

    // HIRQ bits
    def HXFRDNIRQ_BIT               = 7
    def FRAMEIRQ_BIT                = 6
    def CONDETIRQ_BIT               = 5
    def SUSDNIRQ_BIT                = 4
    def SNDBAVIRQ_BIT               = 3
    def RCVDAVIRQ_BIT               = 2
    def RWUIRQ_BIT                  = 1
    def BUSEVENTIRQ_BIT             = 0

    // HCTL bits
    def SNDTOG1_BIT                 = 7
    def SNDTOG0_BIT                 = 6
    def RCVTOG1_BIT                 = 5
    def RCVTOG0_BIT                 = 4
    def SIGRSM_BIT                  = 3
    def SAMPLEBUS_BIT               = 2
    def FRMRST_BIT                  = 1
    def BUSRST_BIT                  = 0

    // HXFR bits
    def XFER_TYPE_BIT               = 4
    def EP_BIT                      = 0

    // HRSL bits
    def JSTATUS_BIT                 = 7
    def KSTATUS_BIT                 = 6
    def SNDTOGRD_BIT                = 5
    def RCVTOGRD_BIT                = 4
    def HRSLT_BIT                   = 0

    def TX_FIFO_SIZE                = 64
    def RX_FIFO_SIZE                = 64
    def SU_FIFO_SIZE                = 8

    object HostXferType extends SpinalEnum {
        val SETUP, BULK_IN, BULK_OUT, HS_IN, HS_OUT, ISO_IN, ISO_OUT = newElement()
        defaultEncoding = SpinalEnumEncoding("staticEncoding")(
            SETUP       -> 0x1,
            BULK_IN     -> 0x0,
            BULK_OUT    -> 0x2,
            HS_IN       -> 0x8,     // Handshake reply packet after control DATA OUT
            HS_OUT      -> 0xa,     // Handshake reply packet after control DATA IN
            ISO_IN      -> 0x4,
            ISO_OUT     -> 0x6
        )
    }

    object HostXferResult extends SpinalEnum {
        val SUCCESS     = newElement()
        val BUSY        = newElement()
        val BADREQ      = newElement()
        val UNDEF       = newElement()
        val NAK         = newElement()
        val STALL       = newElement()
        val TOGERR      = newElement()
        val WRONGPID    = newElement()
        val BADBC       = newElement()
        val PIDERR      = newElement()
        val PKTERR      = newElement()
        val CRCERR      = newElement()
        val KERR        = newElement()
        val JERR        = newElement()
        val TIMEOUT     = newElement()
        val BABBLE      = newElement()
    }

    object PidType extends SpinalEnum {
        val NULL = newElement()
        val OUT, IN, SOF, SETUP = newElement()
        val DATA0, DATA1, DATA2, MDATA = newElement()
        val ACK, NAK, STALL, NYET = newElement()
        val PRE_ERR, SPLIT, PING = newElement()

        defaultEncoding = SpinalEnumEncoding("staticEncoding")(
            NULL        -> 0x0,
            // Tokens
            OUT         -> 0x1,
            IN          -> 0x9,
            SOF         -> 0x5,
            SETUP       -> 0xd,
            // Data
            DATA0       -> 0x3,
            DATA1       -> 0xb,
            DATA2       -> 0x7,
            MDATA       -> 0xf,
            // Handshake
            ACK         -> 0x2,
            NAK         -> 0xa,
            STALL       -> 0xe,
            NYET        -> 0x6,
            // Special
            PRE_ERR     -> 0xc,
            SPLIT       -> 0x8,
            PING        -> 0x4
        )
    }
}

case class UsbHost() extends Component {

    import UsbHost._

    // Everything in this block runs at ULPI 60MHz clock speed.
    // If the APB is running at a different clock speed, use Apb3CC which is a clock crossing
    // APB bridge.

    val io = new Bundle {
        // Interface into RAM that contains all the FIFOs.
        // So instead of a 'real' FIFO, it's just a RAM.
        val cpu_fifo_bus            = slave(PipelinedMemoryBus(UsbHost.getFifoMemoryBusConfig()))

        // Used for transmit and receive operations

        // Peripheral address to be used for next transaction. Static value.
        val periph_addr             = in(UInt(7 bits))
        // Endpoint nr for next transaction. Static value.
        val endpoint                = in(UInt(4 bits))

        // When high, the CPU is allowed to write to the send FIFO.
        // Value goes to false when a transmit is requested and both TX FIFOs are full.
        // Value goes to true when a transmit was successful with no low-level errors.
        val send_buf_avail          = out(Bool)

        // Indicates which one of the double-buffered FIFOs should be used to write a packet to.
        // Value changes after a transmit is started.
        val send_buf_avail_nr       = out(UInt(1 bits))

        // Number of bytes that were written in the currently available send buffer
        val send_byte_count         = slave(Flow(UInt(log2Up(TX_FIFO_SIZE) bits)))

        // Type of transfer that's initiated. Determines the PID as well as
        // the number of global state machine steps
        // The valid field signals the start of the transfer.
        val xfer_type               = slave(Flow(HostXferType()))

        // The current status of a host transfer.
        val xfer_result             = out(HostXferResult)

        // Current data toggle values
        val cur_send_data_toggle    = out(Bool)
        val cur_rcv_data_toggle     = out(Bool)

        // Force new receive and send toggle values
        val set_send_data_toggle    = slave(Flow(Bool))
        val set_rcv_data_toggle     = slave(Flow(Bool))

        //============================================================
        // Interface with ULPI
        //============================================================
        val ulpi_rx_cmd_changed     = out(Bool)
        val ulpi_rx_cmd             = out(Bits(8 bits))

        val ulpi_tx_start           = out(Bool)
        val ulpi_tx_data            = master(Stream(Bits(8 bits)))
    }

    // 2x64 deep double-buffered RX FIFOs
    // 2x64 deep double-buffered TX FIFOs
    // 8 deep setup TX FIFO.

    // "000xxxxxx" : RX FIFO 0
    // "001xxxxxx" : RX FIFO 1
    // "010xxxxxx" : TX FIFO 0
    // "011xxxxxx" : TX FIFO 1
    // "100000xxx" : SU FIFO
    val fifo_ram = Mem(Bits(8 bits), (2*RX_FIFO_SIZE) + (2*TX_FIFO_SIZE) + SU_FIFO_SIZE)

    val cpu_ram_access = new Area {
        io.cpu_fifo_bus.cmd.ready := True

        io.cpu_fifo_bus.rsp.data := fifo_ram.readWriteSync(
                    enable              = io.cpu_fifo_bus.cmd.valid,
                    write               = io.cpu_fifo_bus.cmd.write,
                    address             = io.cpu_fifo_bus.cmd.address,
                    mask                = B(True),
                    data                = io.cpu_fifo_bus.cmd.data
            )
        io.cpu_fifo_bus.rsp.valid := RegNext(io.cpu_fifo_bus.cmd.valid && !io.cpu_fifo_bus.cmd.write) init(False)
    }

    object UsbHostState extends SpinalEnum {
        val Idle            = newElement()
        val TxStart         = newElement()
    }

    val tx_buf = new Area {
        // Currently active buffer. Either being transmitted right now, or the first
        // one to be transmitted right now.
        val cur_buf   = Reg(UInt(1 bits)) init(0)

        val buf_primed      = Reg(Bits(2 bits)) init(0)
        val byte_count0     = Reg(UInt(log2Up(TX_FIFO_SIZE) bits)) init(0)
        val byte_count1     = Reg(UInt(log2Up(TX_FIFO_SIZE) bits)) init(0)

        io.send_buf_avail     := !buf_primed(cur_buf) || !buf_primed(~cur_buf)
        io.send_buf_avail_nr  := !buf_primed(cur_buf) ? cur_buf | ~cur_buf

        when(io.send_byte_count.valid){
            when(cur_buf === 0){
                when(!buf_primed(0)){
                    byte_count0   := io.send_byte_count.payload
                    buf_primed(0) := True
                }
                .elsewhen(!buf_primed(1)){
                    byte_count1   := io.send_byte_count.payload
                    buf_primed(1) := True
                }
                .otherwise{
                    // Both buffers have already been primed. Overwrite the one that is not current?
                    byte_count1   := io.send_byte_count.payload
                    buf_primed(1) := True
                }
            }
            .elsewhen(cur_buf === 1){
                when(!buf_primed(1)){
                    byte_count1   := io.send_byte_count.payload
                    buf_primed(1) := True
                }
                .elsewhen(!buf_primed(0)){
                    byte_count0   := io.send_byte_count.payload
                    buf_primed(0) := True
                }
                .otherwise{
                    // Both buffers have already been primed. Overwrite the one that is not current?
                    byte_count0   := io.send_byte_count.payload
                    buf_primed(0) := True
                }
            }
        }
    }

    val data_toggle = new Area {

        val toggle_send   = Bool
        val toggle_rcv    = Bool

        toggle_send   := False
        toggle_rcv    := False

        val cur_send_data_toggle = RegInit(False)
        val cur_rcv_data_toggle = RegInit(False)

        io.cur_send_data_toggle := cur_send_data_toggle
        io.cur_rcv_data_toggle  := cur_rcv_data_toggle

        when(io.set_send_data_toggle.valid){
            cur_send_data_toggle    := io.set_send_data_toggle.payload
        }

        when(io.set_rcv_data_toggle.valid){
            cur_rcv_data_toggle     := io.set_rcv_data_toggle.payload
        }

        when(toggle_send){
            cur_send_data_toggle  := ~cur_send_data_toggle
        }

        when(toggle_rcv){
            cur_rcv_data_toggle   := ~cur_rcv_data_toggle
        }
    }

    val tx = new Area {

        val start_tx      = False
        val pid           = PidType()

        pid     := PidType.NULL

        object TxState extends SpinalEnum {
            val Idle    = newElement()
        }

        val tx_state = Reg(TxState()) init(TxState.Idle)
    }

    val top_fsm = new Area {

        when(io.xfer_type.valid){
        }

        object HostState extends SpinalEnum {
            val Idle    = newElement()
        }

        val cur_state = Reg(HostState()) init(HostState.Idle)
    }

    def driveFrom(busCtrl: BusSlaveFactory, baseAddress: BigInt) = new Area {

        //============================================================
        // PERADDR - Peripheral Address
        //============================================================
        val periph_addr = new Area {
            val periph_addr = busCtrl.createReadAndWrite(io.periph_addr, PERADDR_ADDR << 2, 0)

            io.periph_addr := periph_addr
        }

        //============================================================
        // SNDFIFO - Send FIFO
        //============================================================
        //
        io.cpu_fifo_bus.cmd.valid   := False
        io.cpu_fifo_bus.cmd.write   := False
        io.cpu_fifo_bus.cmd.address := 0
        busCtrl.nonStopWrite(io.cpu_fifo_bus.cmd.data, 0)

        val send_fifo = new Area {

            val wr_ptr  = Reg(UInt(log2Up(TX_FIFO_SIZE) bits)) init(0)
            val wr_addr = U"2'b01" @@ io.send_buf_avail_nr @@ wr_ptr

            busCtrl.onWrite(SNDFIFO_ADDR << 2){
                io.cpu_fifo_bus.cmd.valid   := True
                io.cpu_fifo_bus.cmd.write   := True
                io.cpu_fifo_bus.cmd.address := wr_addr

                wr_ptr := wr_ptr + 1
            }
        }

        //============================================================
        // SNDBC - Send FIFO Byte Count
        //============================================================
        val send_byte_count = new Area {
            // Right now, this register is write only. It should probably be made r/w?
            val send_byte_count = busCtrl.createAndDriveFlow(io.send_byte_count.payload, SNDBC_ADDR << 2, 0)

            io.send_byte_count  << send_byte_count
        }

        //============================================================
        // HIRQ - Host IRQ - Various status registers
        //============================================================
        val hirq = new Area {
            val sndbavirq = busCtrl.createReadOnly(io.send_buf_avail, HIRQ_ADDR << 2, SNDBAVIRQ_BIT)

            sndbavirq   := io.send_buf_avail
        }

        //============================================================
        // HCTL - Host Transfer Control
        //============================================================
        val hctl = new Area {
            val rcv_tog = busCtrl.createAndDriveFlow(Bits(2 bits), HCTL_ADDR << 2,  RCVTOG0_BIT)
            io.set_rcv_data_toggle.valid      := rcv_tog.valid && rcv_tog.payload =/= B"2'b00" && rcv_tog.payload =/= B"2'b11"
            io.set_rcv_data_toggle.payload    := rcv_tog.payload(1)

            val send_tog = busCtrl.createAndDriveFlow(Bits(2 bits), HCTL_ADDR << 2,  SNDTOG0_BIT)
            io.set_send_data_toggle.valid     := send_tog.valid && send_tog.payload =/= B"2'b00" && send_tog.payload =/= B"2'b11"
            io.set_send_data_toggle.payload   := send_tog.payload(1)
        }


        //============================================================
        // HXFR - Launch Host Transfer
        //============================================================
        val hxfr = new Area {
            val endpoint = busCtrl.createWriteOnly(io.endpoint, HXFR_ADDR << 2, EP_BIT)
            io.endpoint := endpoint

            val xfer_type = busCtrl.createAndDriveFlow(io.xfer_type.payload, HXFR_ADDR << 2, XFER_TYPE_BIT)
            io.xfer_type << xfer_type
        }

        //============================================================
        // HRSL - Host Transfer Result
        //============================================================
        val hrsl = new Area {
            val xfer_result = busCtrl.createReadOnly(io.xfer_result, HRSL_ADDR << 2, HRSLT_BIT)
            xfer_result := io.xfer_result

            val send_data_toggle = busCtrl.createReadOnly(io.cur_send_data_toggle, HRSL_ADDR << 2, SNDTOGRD_BIT)
            send_data_toggle := io.cur_send_data_toggle

            val rcv_data_toggle = busCtrl.createReadOnly(io.cur_rcv_data_toggle, HRSL_ADDR << 2, RCVTOGRD_BIT)
            rcv_data_toggle := io.cur_rcv_data_toggle
        }

    }

}


case class UsbHostTop() extends Component
{
    val io = new Bundle {
        val apb         = slave(Apb3(UsbHost.getApb3Config()))
    }

    val u_usb_host = UsbHost()

    val busCtrl = Apb3SlaveFactory(io.apb)
    val apb_regs = u_usb_host.driveFrom(busCtrl, 0x0)

}


case class UsbHostFormalTb() extends Component
{
    val io = new Bundle {
        val clk             = in(Bool)
        val reset_          = in(Bool)
    }


    val domain = new ClockingArea(ClockDomain(io.clk, io.reset_,
                                                config = ClockDomainConfig(resetKind = SYNC, resetActiveLevel = LOW)))
    {
        val apb = Apb3(UsbHost.getApb3Config())

        val u_usb_host_top = new UsbHostTop()
        u_usb_host_top.io.apb           <> apb

       import spinal.core.GenerationFlags._
       import spinal.core.Formal._

       GenerationFlags.formal{
            import pano.lib._

            assume(io.reset_ === !initstate())

            assume(rose(apb.PENABLE)    |-> stable(apb.PSEL))
            assume(rose(apb.PENABLE)    |-> stable(apb.PADDR))
            assume(rose(apb.PENABLE)    |-> stable(apb.PWRITE))
            assume(rose(apb.PENABLE)    |-> stable(apb.PWDATA))

            assume(apb.PREADY           |-> stable(apb.PENABLE))
            assume(apb.PREADY           |-> stable(apb.PSEL))
            assume(apb.PREADY           |-> stable(apb.PADDR))
            assume(apb.PREADY           |-> stable(apb.PWRITE))
            assume(apb.PREADY           |-> stable(apb.PWDATA))

            assume(fell(apb.PENABLE)    |-> apb.PREADY)
            assume(fell(apb.PSEL.orR)   |-> apb.PREADY)

            assume(!stable(apb.PSEL)    |=> (fell(apb.PENABLE) || !apb.PENABLE))
            assume(!stable(apb.PADDR)   |=> (fell(apb.PENABLE) || !apb.PENABLE))
            assume(!stable(apb.PWRITE)  |=> (fell(apb.PENABLE) || !apb.PENABLE))
            assume(!stable(apb.PWDATA)  |=> (fell(apb.PENABLE) || !apb.PENABLE))

            when(!initstate()){
            }
        }
    }.setName("")
}

object UsbHostVerilog{
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)
        config.includeFormal.generateSystemVerilog({
            val toplevel = new UsbHostFormalTb()
            toplevel
        })
        println("DONE")
    }
}

