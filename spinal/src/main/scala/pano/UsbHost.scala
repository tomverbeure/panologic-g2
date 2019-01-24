
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.Reverse
import spinal.lib.io._
import spinal.lib.bus.simple._
import spinal.lib.bus.misc._
import spinal.lib.bus.amba3.apb._

import spinal_local.crypto.checksum._

object UsbHost {
    // 8 bits -> 64 registers
    // We need 32 registers for MAX3421E compatibility. The other registers are for
    // additional status and debug.
    def getApb3Config() = Apb3Config(addressWidth = 7, dataWidth=32)

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
    def FIFO_RAM_SIZE               = (2*RX_FIFO_SIZE + 2*TX_FIFO_SIZE + SU_FIFO_SIZE)
    def FIFO_RAM_BITS               = log2Up(FIFO_RAM_SIZE)

    // RX:      2x 64 bytes. Address: 0, 64
    // TX:      2x 64 bytes. Address: 128, 192
    // Setup:   8 bytes.     Address: 256
    def getFifoMemoryBusConfig() = PipelinedMemoryBusConfig(addressWidth = FIFO_RAM_BITS, dataWidth = 8)

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

    def crc5(data_in: Bits): Bits = {
        //-----------------------------------------------------------------------------
        //// Copyright (C) 2009 OutputLogic.com
        //// This source file may be used and distributed without restriction
        //// provided that this copyright statement is not removed from the file
        //// and that any derivative work contains the original copyright notice
        //// and the associated disclaimer.
        ////
        //// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
        //// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
        //// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
        ////-----------------------------------------------------------------------------
        //// CRC module for data[10:0] ,   crc[4:0]=1+x^2+x^5;
        ////-----------------------------------------------------------------------------

        val lfsr_q = Bits(5 bits).setAll      // Full CRC5 is calculated in 1 step, so init value is constant.
        val lfsr_c = Bits(5 bits)

        lfsr_c(0) := lfsr_q(0) ^ lfsr_q(3) ^ lfsr_q(4) ^ data_in(0) ^ data_in(3) ^ data_in(5) ^ data_in(6) ^ data_in(9) ^ data_in(10)
        lfsr_c(1) := lfsr_q(0) ^ lfsr_q(1) ^ lfsr_q(4) ^ data_in(1) ^ data_in(4) ^ data_in(6) ^ data_in(7) ^ data_in(10)
        lfsr_c(2) := lfsr_q(0) ^ lfsr_q(1) ^ lfsr_q(2) ^ lfsr_q(3) ^ lfsr_q(4) ^ data_in(0) ^ data_in(2) ^ data_in(3) ^ data_in(6) ^ data_in(7) ^ data_in(8) ^ data_in(9) ^ data_in(10)
        lfsr_c(3) := lfsr_q(1) ^ lfsr_q(2) ^ lfsr_q(3) ^ lfsr_q(4) ^ data_in(1) ^ data_in(3) ^ data_in(4) ^ data_in(7) ^ data_in(8) ^ data_in(9) ^ data_in(10)
        lfsr_c(4) := lfsr_q(2) ^ lfsr_q(3) ^ lfsr_q(4) ^ data_in(2) ^ data_in(4) ^ data_in(5) ^ data_in(8) ^ data_in(9) ^ data_in(10)

        lfsr_c
    }

    def crc16(data_in: Bits, lfsr_q: Bits): Bits = {
        //-----------------------------------------------------------------------------
        //// Copyright (C) 2009 OutputLogic.com
        //// This source file may be used and distributed without restriction
        //// provided that this copyright statement is not removed from the file
        //// and that any derivative work contains the original copyright notice
        //// and the associated disclaimer.
        ////
        //// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
        //// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
        //// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
        ////-----------------------------------------------------------------------------
        //// CRC module for data[7:0] ,   crc[15:0]=1+x^2+x^15+x^16;
        ////-----------------------------------------------------------------------------

        val lfsr_c = Bits(16 bits)

        lfsr_c(0)  := lfsr_q(8) ^ lfsr_q(9) ^ lfsr_q(10) ^ lfsr_q(11) ^ lfsr_q(12) ^ lfsr_q(13) ^ lfsr_q(14) ^ lfsr_q(15) ^ data_in(0) ^ data_in(1) ^ data_in(2) ^ data_in(3) ^ data_in(4) ^ data_in(5) ^ data_in(6) ^ data_in(7)
        lfsr_c(1)  := lfsr_q(9) ^ lfsr_q(10) ^ lfsr_q(11) ^ lfsr_q(12) ^ lfsr_q(13) ^ lfsr_q(14) ^ lfsr_q(15) ^ data_in(1) ^ data_in(2) ^ data_in(3) ^ data_in(4) ^ data_in(5) ^ data_in(6) ^ data_in(7)
        lfsr_c(2)  := lfsr_q(8) ^ lfsr_q(9) ^ data_in(0) ^ data_in(1)
        lfsr_c(3)  := lfsr_q(9) ^ lfsr_q(10) ^ data_in(1) ^ data_in(2)
        lfsr_c(4)  := lfsr_q(10) ^ lfsr_q(11) ^ data_in(2) ^ data_in(3)
        lfsr_c(5)  := lfsr_q(11) ^ lfsr_q(12) ^ data_in(3) ^ data_in(4)
        lfsr_c(6)  := lfsr_q(12) ^ lfsr_q(13) ^ data_in(4) ^ data_in(5)
        lfsr_c(7)  := lfsr_q(13) ^ lfsr_q(14) ^ data_in(5) ^ data_in(6)
        lfsr_c(8)  := lfsr_q(0) ^ lfsr_q(14) ^ lfsr_q(15) ^ data_in(6) ^ data_in(7)
        lfsr_c(9)  := lfsr_q(1) ^ lfsr_q(15) ^ data_in(7)
        lfsr_c(10) := lfsr_q(2)
        lfsr_c(11) := lfsr_q(3)
        lfsr_c(12) := lfsr_q(4)
        lfsr_c(13) := lfsr_q(5)
        lfsr_c(14) := lfsr_q(6)
        lfsr_c(15) := lfsr_q(7) ^ lfsr_q(8) ^ lfsr_q(9) ^ lfsr_q(10) ^ lfsr_q(11) ^ lfsr_q(12) ^ lfsr_q(13) ^ lfsr_q(14) ^ lfsr_q(15) ^ data_in(0) ^ data_in(1) ^ data_in(2) ^ data_in(3) ^ data_in(4) ^ data_in(5) ^ data_in(6) ^ data_in(7)

        lfsr_c
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
    val fifo_ram = Mem(Bits(8 bits), FIFO_RAM_SIZE)

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

    val rxtx_ram_access = new Area {
        val tx_rd_req   = Bool
        val tx_rd_addr  = UInt(FIFO_RAM_BITS bits)

        val rx_wr_req   = Bool
        val rx_wr_addr  = UInt(FIFO_RAM_BITS bits)
        val rx_wr_data  = Bits(8 bits)

        val rxtx_addr   = tx_rd_req ? tx_rd_addr | rx_wr_addr

        val tx_rd_data = fifo_ram.readWriteSync(
                    enable              = (tx_rd_req | rx_wr_req),
                    write               = rx_wr_req,
                    address             = rxtx_addr,
                    mask                = B(True),
                    data                = rx_wr_data
            )
    }

    val tx_buf = new Area {
        // Currently active buffer. Either being transmitted right now, or the first
        // one to be transmitted right now.
        val cur_buf   = Reg(UInt(1 bits)) init(0)

        val buf_primed      = Reg(Bits(2 bits)) init(0)
        val byte_count0     = Reg(UInt(log2Up(TX_FIFO_SIZE) bits)) init(0)
        val byte_count1     = Reg(UInt(log2Up(TX_FIFO_SIZE) bits)) init(0)

        var cur_byte_count        = (cur_buf === 0) ? byte_count0 | byte_count1
        var cur_first_byte_ptr    = U"2'b01" @@ cur_buf(0) @@ U(0, log2Up(TX_FIFO_SIZE) bits)
        var setup_first_byte_ptr  = U"2'b10" @@ 0          @@ U(0, log2Up(TX_FIFO_SIZE) bits)

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

    val tx_fsm = new Area {
        //============================================================
        // This FSM has control over the ULPI TX interface
        //============================================================
        // Kick off TX by setting pid != NULL
        val pid           = PidType()
        val setup         = Bool

        pid       := PidType.NULL
        setup     := False

        io.ulpi_tx_data.valid     := False
        io.ulpi_tx_data.payload   := 0

        object TxState extends SpinalEnum {
            val Idle          = newElement()
            val TokenPid      = newElement()
            val TokenAddr     = newElement()
            val TokenEndpoint = newElement()
            val DataPid       = newElement()
            val DataData      = newElement()
            val DataCRC0      = newElement()
            val DataCRC1      = newElement()
            val HandshakePid  = newElement()
            val SpecialPid    = newElement()
        }

        val cur_pid     = Reg(PidType()) init(PidType.NULL)
        val cur_setup   = Reg(Bool) init(False)

        val tx_state    = Reg(TxState()) init(TxState.Idle)
        val frame_cntr  = Reg(UInt(11 bits)) init(0)
        val rd_req      = Bool
        val rd_ptr      = Reg(UInt(FIFO_RAM_BITS bits)) init(0)
        val data_cntr   = Reg(UInt(log2Up(TX_FIFO_SIZE) bits)) init(0)

        rxtx_ram_access.tx_rd_req   := rd_req
        rxtx_ram_access.tx_rd_addr  := rd_ptr

        val crc16       = Reg(Bits(16 bits)) init(0)
        val crc16_nxt   = UsbHost.crc16(Reverse(rxtx_ram_access.tx_rd_data), crc16)

        //val crc_0 = B"16'hffff"
        //val crc_1 = UsbHost.crc16(Reverse(B"8'h00"), crc_0)
        //val crc_2 = UsbHost.crc16(Reverse(B"8'h01"), crc_1)
        //val crc_3 = UsbHost.crc16(Reverse(B"8'h02"), crc_2)
        //val crc_4 = RegNext(~Reverse(UsbHost.crc16(Reverse(B"8'h03"), crc_3)))
        //crc5 := ~UsbHost.crc5(Reverse(B("4'b1110") ## B("7'b0010101")))

        val crc5        = Reg(Bits(5 bits)) init(0)
        crc5 := ~UsbHost.crc5(Reverse((cur_pid === PidType.SOF) ? frame_cntr.asBits | (io.endpoint ## io.periph_addr)))

        rd_req  := False

        switch(tx_state){
            //============================================================
            // IDLE
            //============================================================
            is(TxState.Idle){
                when(pid =/= PidType.NULL){
                    cur_pid   := pid
                    cur_setup := setup
                }

                switch(pid){
                    is(PidType.NULL){
                        // Don't do anything...
                    }
                    is(PidType.OUT, PidType.IN, PidType.SOF, PidType.SETUP){
                        tx_state  := TxState.TokenPid
                    }
                    is(PidType.DATA0, PidType.DATA1, PidType.DATA2, PidType.MDATA){
                        tx_state  := TxState.DataPid
                        rd_ptr    := setup ? tx_buf.setup_first_byte_ptr | tx_buf.cur_first_byte_ptr
                    }
                    is(PidType.ACK, PidType.NAK, PidType.STALL, PidType.NYET){
                        tx_state  := TxState.HandshakePid
                    }
                    is(PidType.PRE_ERR, PidType.SPLIT, PidType.PING){
                        // None of these special packet are currently supported.
                        // PRE: automatically inserted by ULPI PHY when XcvrSelect is set to 2'b11
                        // ERR, SPLIT, PING: only used in HS mode
                        tx_state  := TxState.Idle
                    }
                }
            }
            //============================================================
            // TOKEN - USB 2.0 - 8.4.1
            //============================================================
            is(TxState.TokenPid){
                io.ulpi_tx_data.valid     := True
                io.ulpi_tx_data.payload   := B"4'b0100" ## cur_pid.asBits

                when(io.ulpi_tx_data.ready){
                    tx_state    := TxState.TokenAddr
                }
            }
            is(TxState.TokenAddr){
                io.ulpi_tx_data.valid     := True
                io.ulpi_tx_data.payload   := io.endpoint(0) ## io.periph_addr

                when(io.ulpi_tx_data.ready){
                    tx_state    := TxState.TokenEndpoint
                }
            }
            is(TxState.TokenEndpoint){
                io.ulpi_tx_data.valid     := True
                io.ulpi_tx_data.payload   := crc5 ## io.endpoint(3 downto 1)

                when(io.ulpi_tx_data.ready){
                    tx_state    := TxState.Idle
                }
            }
            //============================================================
            // DATA
            //============================================================
            is(TxState.DataPid){
                io.ulpi_tx_data.valid     := True
                io.ulpi_tx_data.payload   := B"4'b0100" ## cur_pid.asBits

                when(io.ulpi_tx_data.ready){
                    crc16.setAll

                    when(tx_buf.cur_byte_count >= 0){
                        tx_state      := TxState.DataData
                        data_cntr     := cur_setup ? U(8, log2Up(TX_FIFO_SIZE) bits) | tx_buf.cur_byte_count
                        rd_req        := True
                    }
                    .otherwise{
                        tx_state      := TxState.DataCRC0
                    }
                }
            }
            is(TxState.DataData){
                io.ulpi_tx_data.valid     := True
                io.ulpi_tx_data.payload   := rxtx_ram_access.tx_rd_data

                rd_req    := True
                when(io.ulpi_tx_data.ready){
                    crc16 := crc16_nxt

                    when(data_cntr > 1){
                        tx_state      := TxState.DataData
                        data_cntr     := data_cntr - 1
                        rd_ptr        := rd_ptr + 1
                    }
                    .otherwise{
                        tx_state      := TxState.DataCRC0
                    }
                }
            }
            is(TxState.DataCRC0){
                io.ulpi_tx_data.valid     := True
                io.ulpi_tx_data.payload   := ~crc16(7 downto 0)

                when(io.ulpi_tx_data.ready){
                    tx_state      := TxState.DataCRC1
                }
            }
            is(TxState.DataCRC1){
                io.ulpi_tx_data.valid     := True
                io.ulpi_tx_data.payload   := crc16(15 downto 8)

                when(io.ulpi_tx_data.ready){
                    tx_state      := TxState.Idle
                }
            }
            //============================================================
            // HANDSHAKE
            //============================================================
            is(TxState.HandshakePid){
                io.ulpi_tx_data.valid     := True
                io.ulpi_tx_data.payload   := B"4'b0100" ## cur_pid.asBits

                when(io.ulpi_tx_data.ready){
                    tx_state      := TxState.Idle
                }
            }

            //============================================================
            // SPECIAL
            //============================================================
            is(TxState.SpecialPid){
            }
        }
    }

    val rx = new Area {
        rxtx_ram_access.rx_wr_req   := False
        rxtx_ram_access.rx_wr_addr  := 0
        rxtx_ram_access.rx_wr_data  := 0
    }


    val top_fsm = new Area {

        object TopState extends SpinalEnum {
            val Idle                  = newElement()
            val SetupSendToken        = newElement()
            val SetupSendData0        = newElement()
            val SetupWaitHandshake    = newElement()
        }

        val top_state = Reg(TopState()) init(TopState.Idle)

        switch(top_state){
            //============================================================
            // IDLE
            //============================================================
            is(TopState.Idle){
                when(io.xfer_type.valid){
                    switch(io.xfer_type.payload){
                        is(HostXferType.SETUP){
                        }
                        is(HostXferType.BULK_IN, HostXferType.BULK_OUT, HostXferType.HS_IN, HostXferType.HS_OUT, HostXferType.ISO_IN, HostXferType.ISO_OUT){
                            top_state     := TopState.Idle
                        }
                    }
                }
            }
            //============================================================
            // SETUP
            //============================================================
            is(TopState.SetupSendToken){
                when(tx_fsm.tx_state === tx_fsm.TxState.Idle){
                    tx_fsm.pid        := PidType.SETUP
                    top_state         := TopState.SetupSendData0

                    // Check for error?
                }
            }
            is(TopState.SetupSendData0){
                when(tx_fsm.tx_state === tx_fsm.TxState.Idle){
                    tx_fsm.pid        := PidType.DATA0
                    tx_fsm.setup      := True
                    top_state         := TopState.SetupWaitHandshake

                    // Check for error?
                }
            }
            is(TopState.SetupWaitHandshake){
                when(tx_fsm.tx_state === tx_fsm.TxState.Idle){
                    // Check RX reply...
                }
            }

        }
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
        // SUDFIFO - Setup FIFO
        //============================================================
        val setup_fifo = new Area {

            val wr_ptr  = Reg(UInt(log2Up(SU_FIFO_SIZE) bits)) init(0)
            val wr_addr = U(FIFO_RAM_BITS bits,
                                (FIFO_RAM_BITS-1 downto FIFO_RAM_BITS-3) -> U"3'b100",
                                (log2Up(SU_FIFO_SIZE)-1 downto 0) -> wr_ptr,
                                default -> false)

            busCtrl.onWrite(SUDFIFO_ADDR << 2){
                io.cpu_fifo_bus.cmd.valid   := True
                io.cpu_fifo_bus.cmd.write   := True
                io.cpu_fifo_bus.cmd.address := wr_addr

                wr_ptr := wr_ptr + 1
            }
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
                cover(u_usb_host_top.io.apb.PREADY)
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

