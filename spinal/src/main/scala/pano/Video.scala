
package pano

import spinal.core._

case class VideoTimings() extends Bundle {
    val h_active            = UInt(12 bits)
    val h_fp                = UInt(9 bits)
    val h_sync              = UInt(9 bits)
    val h_bp                = UInt(9 bits)
    val h_sync_positive     = Bool

    def h_total_m1          : UInt = h_active + h_fp + h_sync + h_bp - 1

    val v_active            = UInt(11 bits)
    val v_fp                = UInt(9 bits)
    val v_sync              = UInt(9 bits)
    val v_bp                = UInt(9 bits)
    val v_sync_positive     = Bool

    def v_total_m1          : UInt = v_active + v_fp + v_sync + v_bp - 1
}

case class VgaData() extends Bundle {
    val vsync    = Bool
    val hsync    = Bool
    val blank_   = Bool
    val de       = Bool
    val r        = UInt(8 bits)
    val g        = UInt(8 bits)
    val b        = UInt(8 bits)

    def init() : VgaData = {
        vsync   init(False)
        hsync   init(False)
        blank_  init(False)
        de      init(False)
        r       init(0)
        g       init(0)
        b       init(0)
        this
    }
}

case class Pixel() extends Bundle {
    val r       = UInt(8 bits)
    val g       = UInt(8 bits)
    val b       = UInt(8 bits)

    def setColor(r: Double, g: Double, b: Double) = {
        this.r := U( (r * ((1 <<this.r.getWidth)-1)).toInt, this.r.getWidth bits)
        this.g := U( (g * ((1 <<this.g.getWidth)-1)).toInt, this.g.getWidth bits)
        this.b := U( (b * ((1 <<this.b.getWidth)-1)).toInt, this.b.getWidth bits)
    }

}

case class PixelStream() extends Bundle {
    val vsync     = Bool
    val req       = Bool
    val last_col  = Bool
    val last_line = Bool
    val pixel     = Pixel()

    def eol = last_col 
    def eof = last_col && last_line
}

