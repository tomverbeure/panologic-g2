
package pano

import spinal.core._

class VideoTimingGen extends Component {

    val io = new Bundle {
        val timings     = in(VideoTimings())
        val pixel_out   = out(Reg(PixelStream()))
    }

    val col_cntr    = Reg(UInt(12 bits)) init(0)
    val line_cntr   = Reg(UInt(11 bits)) init(0)

    val last_col  = col_cntr  === io.timings.h_total_m1
    val last_line = line_cntr === io.timings.v_total_m1

    when(!last_col){
        col_cntr    := col_cntr + 1
    }
    .otherwise{
        col_cntr    := 0
        when(!last_line){
            line_cntr   := line_cntr + 1
        }
        .otherwise{
            line_cntr   := 0
        }
    }

    val h_blank = io.timings.h_fp + io.timings.h_sync + io.timings.h_bp
    val v_blank = io.timings.v_fp + io.timings.v_sync + io.timings.v_bp

    val pixel_active = (col_cntr >= h_blank) && (line_cntr >= v_blank)

    io.pixel_out.vsync  := (col_cntr === 0) && (line_cntr === 0)
    io.pixel_out.req    := pixel_active

    io.pixel_out.last_col   := pixel_active ? last_col    | False
    io.pixel_out.last_line  := pixel_active ? last_line   | False

    io.pixel_out.pixel.r    := U(128, 8 bits)
    io.pixel_out.pixel.g    := U(128, 8 bits)
    io.pixel_out.pixel.b    := U(128, 8 bits)

}

