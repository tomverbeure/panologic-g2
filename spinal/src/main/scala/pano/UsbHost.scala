
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
    def PER_ADDR                    = 28
    def HCTL_ADDR                   = 29
    def HXFR_ADDR                   = 30
    def HRSL_ADDR                   = 31

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
}

case class UsbHost(ulpiDomain: ClockDomain) extends Component {

    val io = new Bundle {

        // Interface into RAM that contains all the FIFOs.
        // So instead of a 'real' FIFO, it's just a RAM.
        val cpu_fifo_bus            = slave(PipelinedMemoryBus(UsbHost.getFifoMemoryBusConfig()))

        // Used for transmit and receive operations

        // Peripheral address to be used for next transaction. Static value.
        val periph_addr             = in(UInt(7 bits))
        // Endpoint nr for next transaction. Static value.
        val endpoint                = in(UInt(4 bits))

        // When high, the CPU is allowed to write to the send FIFO. Value changes
        // after a transmit is started.
        val send_buf_avail          = out(Bool)
        // Indicates which one of the double-buffered FIFOs should be used to write a packet to.
        // Value changes after a transmit is started.
        val send_buf_avail_nr       = out(Bool)

        // Number of bytes that were written in the currently available send buffer
        // Static value.
        val send_byte_count         = in(UInt(6 bits)) 

        // Type of transfer that's initiated. Determines the PID as well as 
        // the number of global state machine steps
        // Static value.
        val xfer_type               = in(UsbHost.HostXferType)

        // Kick-off of a transfer. Pulse.
        val xfer_start              = in(Bool)

        val xfer_result             = out(UsbHost.HostXferResult)

    }

    val fifo_ram = Mem(Bits(8 bits), 256+8)

    io.cpu_fifo_bus.cmd.ready := True

    io.cpu_fifo_bus.rsp.data := fifo_ram.readWriteSync(
                enable              = io.cpu_fifo_bus.cmd.valid, 
                write               = io.cpu_fifo_bus.cmd.write,
                address             = io.cpu_fifo_bus.cmd.address,
                mask                = B(True),
                data                = io.cpu_fifo_bus.cmd.data
        )
    io.cpu_fifo_bus.rsp.valid := RegNext(io.cpu_fifo_bus.cmd.valid && !io.cpu_fifo_bus.cmd.write) init(False)

    val ulpi_domain = new ClockingArea(ulpiDomain) {
        
    }

    def driveFrom(busCtrl: BusSlaveFactory, baseAddress: BigInt) = new Area {

        //============================================================
        // RCVFIFO
        //============================================================
        // Read-only received data FIFO
    }

}


