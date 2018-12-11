
package pano

import spinal.core._

case class VideoTimings() extends Bundle {
    val h_active            = UInt(12 bits)
    val h_fp                = UInt(8 bits)
    val h_sync              = UInt(8 bits)
    val h_bp                = UInt(8 bits)
    val h_sync_positive     = Bool

    val h_total_m1          = UInt(12 bits)

    val v_active            = UInt(11 bits)
    val v_fp                = UInt(6 bits)
    val v_sync              = UInt(6 bits)
    val v_bp                = UInt(6 bits)
    val v_sync_positive     = Bool

    val v_total_m1          = UInt(12 bits)
}

class VideoOut extends Component {
    val io = new Bundle {
        val timings         = in(VideoTimings())
        val pixel_in        = in(PixelStream())
        val vga_out         = out(Reg(VgaData()) init)
    }

    val h_cntr  = Reg(UInt(12 bits)) init(0)
    val v_cntr  = Reg(UInt(11 bits)) init(0)

    when(io.pixel_in.req && io.pixel_in.eof){
        h_cntr  := 0
        v_cntr  := 0
    }
    .elsewhen(h_cntr === io.timings.h_total_m1){
        h_cntr  := 0
        v_cntr  := v_cntr + 1
    }
    .otherwise{
        h_cntr  := h_cntr + 1
    }

    val h_blank = io.timings.h_fp + io.timings.h_sync + io.timings.h_bp
    val v_blank = io.timings.v_fp + io.timings.v_sync + io.timings.v_bp

    val blank = (v_cntr < v_blank) || (h_cntr < h_blank)

    io.vga_out.blank_   := !blank;
    io.vga_out.de       := !blank;
    io.vga_out.hsync    := (h_cntr >= io.timings.h_fp) && (h_cntr < (io.timings.h_fp + io.timings.h_sync)) ^ !(io.timings.h_sync_positive);
    io.vga_out.vsync    := (v_cntr >= io.timings.v_fp) && (v_cntr < (io.timings.v_fp + io.timings.v_sync)) ^ !(io.timings.v_sync_positive);

    io.vga_out.r        := blank ? U"8'd0" | io.pixel_in.pixel.r;
    io.vga_out.g        := blank ? U"8'd0" | io.pixel_in.pixel.g;
    io.vga_out.b        := blank ? U"8'd0" | io.pixel_in.pixel.b;

}


