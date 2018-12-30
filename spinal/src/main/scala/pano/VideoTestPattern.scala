
package pano

import spinal.core._
import spinal.lib.bus.misc.BusSlaveFactory
import spinal.lib.bus.amba3.apb._

object VideoTestPattern {
    def getApb3Config() = Apb3Config(addressWidth = 5,dataWidth = 32)
}

class VideoTestPattern extends Component {

    val io = new Bundle {
        val timings     = in(VideoTimings())

        val pixel_in    = in(PixelStream())
        val pixel_out   = out(Reg(PixelStream()))

        val pattern_nr  = in(UInt(4 bits))
        val const_color = in(Pixel())
    }


    val col_cntr    = Reg(UInt(12 bits)) init(0)
    val line_cntr   = Reg(UInt(11 bits)) init(0)

    when(io.pixel_in.vsync){
        line_cntr   := 0
        col_cntr    := 0
    }
    .elsewhen(io.pixel_in.req){
        when(io.pixel_in.eof){
            line_cntr   := 0
            col_cntr    := 0
        }
        .elsewhen(io.pixel_in.eol){
            line_cntr   := line_cntr + 1
            col_cntr    := 0
        }
        .otherwise{
            col_cntr    := col_cntr + 1
        }
    }

    io.pixel_out    := io.pixel_in

    val h_active_div4 = UInt(col_cntr.getWidth bits)
    val v_active_div4 = UInt(line_cntr.getWidth bits)

    h_active_div4 := io.timings.h_active|>>2
    v_active_div4 := io.timings.v_active|>>2

    val h1 = col_cntr < (h_active_div4  )
    val h2 = col_cntr < (h_active_div4*2)
    val h3 = col_cntr < (h_active_div4*3)
    val h4 = col_cntr < (h_active_div4*4)

    val v1 = line_cntr < (v_active_div4  )
    val v2 = line_cntr < (v_active_div4*2)
    val v3 = line_cntr < (v_active_div4*3)
    val v4 = line_cntr < (v_active_div4*4)

    switch(io.pattern_nr){
        is(0){
            // Const color
            io.pixel_out.pixel      := io.const_color
        }
        is(1){
            // Red gradient
            io.pixel_out.pixel.r    := (col_cntr(7 downto 0) + line_cntr(7 downto 0)).resize(8)
            io.pixel_out.pixel.g    := U(0, 8 bits)
            io.pixel_out.pixel.b    := U(0, 8 bits)
        }
        is(2){
            // Green gradient
            io.pixel_out.pixel.r    := U(0, 8 bits)
            io.pixel_out.pixel.g    := (col_cntr(7 downto 0) + line_cntr(7 downto 0)).resize(8)
            io.pixel_out.pixel.b    := U(0, 8 bits)
        }
        is(3){
            // Blue gradient
            io.pixel_out.pixel.r    := U(0, 8 bits)
            io.pixel_out.pixel.g    := U(0, 8 bits)
            io.pixel_out.pixel.b    := (col_cntr(7 downto 0) + line_cntr(7 downto 0)).resize(8)
        }
        is(4){
            // RGBW vertical bars
            when(h1){
                io.pixel_out.pixel.r    := U(255, 8 bits)
                io.pixel_out.pixel.g    := U(0,   8 bits)
                io.pixel_out.pixel.b    := U(0,   8 bits)
            }
            .elsewhen(h2){
                io.pixel_out.pixel.r    := U(0,   8 bits)
                io.pixel_out.pixel.g    := U(255, 8 bits)
                io.pixel_out.pixel.b    := U(0,   8 bits)
            }
            .elsewhen(h3){
                io.pixel_out.pixel.r    := U(0,   8 bits)
                io.pixel_out.pixel.g    := U(0,   8 bits)
                io.pixel_out.pixel.b    := U(255, 8 bits)
            }
            .otherwise{
                io.pixel_out.pixel.r    := U(255, 8 bits)
                io.pixel_out.pixel.g    := U(255, 8 bits)
                io.pixel_out.pixel.b    := U(255, 8 bits)
            }
        }
        is(5){
            // RGBW horizontal bars
            when(v1){
                io.pixel_out.pixel.r    := U(255, 8 bits)
                io.pixel_out.pixel.g    := U(0,   8 bits)
                io.pixel_out.pixel.b    := U(0,   8 bits)
            }
            .elsewhen(v2){
                io.pixel_out.pixel.r    := U(0,   8 bits)
                io.pixel_out.pixel.g    := U(255, 8 bits)
                io.pixel_out.pixel.b    := U(0,   8 bits)
            }
            .elsewhen(v3){
                io.pixel_out.pixel.r    := U(0,   8 bits)
                io.pixel_out.pixel.g    := U(0,   8 bits)
                io.pixel_out.pixel.b    := U(255, 8 bits)
            }
            .otherwise{
                io.pixel_out.pixel.r    := U(255, 8 bits)
                io.pixel_out.pixel.g    := U(255, 8 bits)
                io.pixel_out.pixel.b    := U(255, 8 bits)
            }
        }
        is(6){
            // Complex
            io.pixel_out.pixel.r        := (line_cntr(3 downto 0) @@ col_cntr(3 downto 0))
            io.pixel_out.pixel.g        := (line_cntr |<< 3)(7 downto 0)
            io.pixel_out.pixel.b        := (col_cntr |<<3)(7 downto 0)
        }
    }

    def driveFrom(busCtrl : BusSlaveFactory, baseAddress : BigInt) = new Area {
        val pattern_nr  = busCtrl.createReadAndWrite(io.pattern_nr, 0x0000) init(0)
        val const_color = busCtrl.createReadAndWrite(io.const_color, 0x0004)

        io.pattern_nr  := pattern_nr.addTag(crossClockDomain)
        io.const_color := const_color.addTag(crossClockDomain)
    }

}

