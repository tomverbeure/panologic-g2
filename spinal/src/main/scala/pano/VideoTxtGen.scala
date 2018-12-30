
package pano

import java.nio.file.{Files, Paths}

import spinal.core._
import spinal.lib.bus.misc._
import spinal.lib.bus.amba3.apb._

object VideoTxtGen {
    def getApb3Config() = Apb3Config(addressWidth = 16,dataWidth = 32)
}

class VideoTxtGen(cpuDomain: ClockDomain) extends Component {

    val io = new Bundle {
        val pixel_in    = in(PixelStream())
        val pixel_out   = out(PixelStream())

        val txt_buf_wr       = in(Bool)
        val txt_buf_rd       = in(Bool)
        val txt_buf_addr     = in(UInt(13 bits))
        val txt_buf_wr_data  = in(Bits(8 bits))
        val txt_buf_rd_data  = out(Bits(8 bits))
    }

    val charWidth       = 9
    val charHeight      = 16

    val txtBufWidth     = 130
    val txtBufHeight    = 60

    var txtBufActiveWidth   = 130
    var txtBufActiveHeight  = 60

    //------------------------------------------------------------
    // pixel x,y coordinates and char coordinates
    //------------------------------------------------------------

    val pix_x = Reg(UInt(12 bits)) init(0)
    val pix_y = Reg(UInt(11 bits)) init(0)

    val char_x = Reg(UInt(8 bits)) init(0)
    val char_y = Reg(UInt(7 bits)) init(0)

    val char_sub_x = Reg(UInt(4 bits)) init(0)
    val char_sub_y = Reg(UInt(4 bits)) init(0)

    var txt_buf_addr_sol = Reg(UInt(13 bits)) init(0)

    when(io.pixel_in.vsync || (io.pixel_in.req && io.pixel_in.eof)){
        pix_x   := 0
        pix_y   := 0

        char_x  := 0
        char_y  := 0

        char_sub_x  := 0
        char_sub_y  := 0

        txt_buf_addr_sol := 0
    }
    .elsewhen(io.pixel_in.req){
        when(io.pixel_in.eol){
            pix_x   := 0
            pix_y   := pix_y + 1

            char_x      := 0
            char_sub_x  := 0

            when(char_sub_y === (charHeight-1)){
                char_y          := char_y + 1
                char_sub_y      := 0

                txt_buf_addr_sol    := txt_buf_addr_sol + txtBufWidth
            }
            .otherwise{
                char_sub_y  := char_sub_y + 1
            }
        }
        .otherwise{
            pix_x   := pix_x + 1

            when (char_sub_x === (charWidth-1)){
                char_x      := char_x + 1
                char_sub_x  := 0
            }
            .otherwise{
                char_sub_x  := char_sub_x + 1
            }
        }
    }

    // Fetch character to render
    val txt_buf_addr    = txt_buf_addr_sol + char_x.resize(txt_buf_addr_sol.getWidth)
    val txt_buf_rd_p0   = (char_x < txtBufActiveWidth) && (char_y < txtBufActiveHeight) && io.pixel_in.req
    val u_txt_buf       = Mem(UInt(8 bits), 8192)

    val cur_char = u_txt_buf.readSync(
                        enable  = txt_buf_rd_p0, 
                        address = txt_buf_addr.resize(13))

    var cpu_domain = new ClockingArea(cpuDomain) {
        io.txt_buf_rd_data := u_txt_buf.readWriteSync(
                            enable  = (io.txt_buf_wr || io.txt_buf_rd),
                            address = io.txt_buf_addr.resize(13),
                            write   = io.txt_buf_wr,
                            data    = io.txt_buf_wr_data.asUInt
                            ).asBits
    }

    val txt_buf_rd_p1 = RegNext(txt_buf_rd_p0)
    val char_sub_x_p1 = RegNext(char_sub_x)

    // Fetch bitmap of character

    // Bitmap Mapping:
    // Char row 0
    //  00  01  02  03  04  05  06  07  08  09  0a  0b  0c  0d  0e  0f
    //  10  11  12  13  14  15  16  17  18  19  1a  1b  1c  1d  1e  1f
    //   ...
    //  70  71  72  73  74  75  76  77  78  79  7a  7b  7c  7d  7e  7f
    // Char row 1
    //  80  81  82  83  84  85  86  87  88  89  8a  8b  8c  8d  8e  8f
    //  

    val bitmap_lsb_addr = UInt(12 bits)
    val bitmap_msb_addr = UInt(12 bits)
    val bitmap_addr     = UInt(12 bits)

    var bitmap_font_file = ""

    val bitmap = if (true) new Area {
        // FONT 8x12
        bitmap_lsb_addr := (cur_char & 0xf).resize(bitmap_lsb_addr.getWidth) + (char_sub_y(0, 4 bits) * 16).resize(bitmap_lsb_addr.getWidth)
        bitmap_msb_addr := ((cur_char >> 4) * 0x100).resize(bitmap_msb_addr.getWidth)

        bitmap_font_file = "fonts/vga8x12_font.rgb"
    }
    else new Area {
        // FONT 8x8
        bitmap_lsb_addr := (cur_char & 0xf).resize(bitmap_lsb_addr.getWidth) + (char_y(0, 4 bits) * 16).resize(bitmap_lsb_addr.getWidth)
        bitmap_msb_addr := ((cur_char >> 4) * 0x80).resize(bitmap_msb_addr.getWidth)

        bitmap_font_file = "fonts/c64_font.rgb"
    }

    bitmap_addr := bitmap_msb_addr + bitmap_lsb_addr

    val byteArray = Files.readAllBytes(Paths.get(bitmap_font_file))
    val fontBitmapRamContent = for(i <- 0 until byteArray.length) yield { B(byteArray(i).toLong & 0xff, 8 bits) }

    val u_font_bitmap_ram = Mem(Bits(8 bits), initialContent = fontBitmapRamContent)

    val bitmap_byte = u_font_bitmap_ram.readSync(
                        enable  = txt_buf_rd_p1, 
                        address = bitmap_addr)
        
    val txt_buf_rd_p2 = RegNext(txt_buf_rd_p1)
    val char_sub_x_p2 = RegNext(char_sub_x_p1)

    val bitmap_pixel = (bitmap_byte >> (7 ^ char_sub_x_p2(0, 3 bits)))(0) && !char_sub_x_p2(3)

    val pixel_in_p2 = RegNext(RegNext(io.pixel_in))

    io.pixel_out := pixel_in_p2
    when(bitmap_pixel && txt_buf_rd_p2){
        io.pixel_out.pixel.r := 0xff
        io.pixel_out.pixel.g := 0xff
        io.pixel_out.pixel.b := 0xff
    }

    def driveFrom(busCtrl: BusSlaveFactory, baseAddress: BigInt) = new Area {
        val mapping = SizeMapping(0x0, (1<<13)*4)
        val txt_buf_rd_addr = busCtrl.readAddress(mapping) >> 2
        val txt_buf_wr_addr = busCtrl.writeAddress(mapping) >> 2

        io.txt_buf_wr           := False
        io.txt_buf_rd           := False
        io.txt_buf_addr         := txt_buf_wr_addr

        busCtrl.onWritePrimitive(mapping, true, null){
            io.txt_buf_wr   := True
            io.txt_buf_addr := txt_buf_wr_addr
        }
        busCtrl.nonStopWrite(io.txt_buf_wr_data, 0)

        busCtrl.multiCycleRead(mapping, 2)
        busCtrl.onReadPrimitive(mapping, false, null){
            io.txt_buf_rd   := True
            io.txt_buf_addr := txt_buf_rd_addr
        }
        busCtrl.readPrimitive(io.txt_buf_rd_data, mapping, 0, null)
    }
}

