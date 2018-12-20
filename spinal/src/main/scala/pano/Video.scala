
package pano

import spinal.core._

case class VideoTimings() extends Bundle {
    val h_active            = UInt(12 bits)
    val h_fp                = UInt(9 bits)
    val h_sync              = UInt(9 bits)
    val h_bp                = UInt(9 bits)
    val h_sync_positive     = Bool

    val h_total_m1          = UInt(12 bits)

    val v_active            = UInt(11 bits)
    val v_fp                = UInt(9 bits)
    val v_sync              = UInt(9 bits)
    val v_bp                = UInt(9 bits)
    val v_sync_positive     = Bool

    val v_total_m1          = UInt(12 bits)
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
    val vsync   = Bool
    val req     = Bool
    val eol     = Bool
    val eof     = Bool
    val pixel   = Pixel()
}

