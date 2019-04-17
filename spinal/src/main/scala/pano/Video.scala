
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

    def timing_640x480_60 : Unit = {
        // Clock: 25MHz
        h_active        := 640
        h_fp            := 16
        h_sync          := 96
        h_bp            := 48
        h_sync_positive := False

        v_active        := 480
        v_fp            := 11
        v_sync          := 2
        v_bp            := 31
        v_sync_positive := False
    }

    def timing_1024x768_60 : Unit = {
        // Clock: 65MHz
        h_active        := 1024
        h_fp            := 24
        h_sync          := 136
        h_bp            := 160
        h_sync_positive := True

        v_active        := 768
        v_fp            := 3
        v_sync          := 6
        v_bp            := 29
        v_sync_positive := True
    }

    def timing_1152x864_60 : Unit = {
        // Clock: 81.62MHz
        h_active        := 1152
        h_fp            := 64
        h_sync          := 120
        h_bp            := 184
        h_sync_positive := True

        v_active        := 864
        v_fp            := 1
        v_sync          := 3
        v_bp            := 27
        v_sync_positive := True
    }

    def timing_1280x1024_60 : Unit = {
        // Clock: 108.0
        h_active        := 1280
        h_fp            := 48
        h_sync          := 112
        h_bp            := 248
        h_sync_positive := True

        v_active        := 1024
        v_fp            := 1
        v_sync          := 3
        v_bp            := 38
        v_sync_positive := True
    }


    def timing_1080p_60 = {
        // Clock: 147.5
        h_active        := 1920
        h_fp            := 88
        h_sync          := 44
        h_bp            := 148
        h_sync_positive := True

        v_active        := 1080
        v_fp            := 4
        v_sync          := 5
        v_bp            := 36
        v_sync_positive := True
    }

    def timing_1680x1050_60 : Unit = {
        // Clock: 147MHz
        h_active        := 1680
        h_fp            := 104
        h_sync          := 184
        h_bp            := 288
        h_sync_positive := True

        v_active        := 1050
        v_fp            := 1
        v_sync          := 3
        v_bp            := 33
        v_sync_positive := True
    }
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

