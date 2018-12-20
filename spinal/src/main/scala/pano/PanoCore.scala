
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._

import mr1._

class PanoCore(voClkDomain: ClockDomain) extends Component {

    val io = new Bundle {
        val led_red             = out(Bool)
        val led_green           = out(Bool)
        val led_blue            = out(Bool)

        val switch_             = in(Bool)

        val dvi_ctrl_scl        = master(TriState(Bool))
        val dvi_ctrl_sda        = master(TriState(Bool))

        val vo                  = out(VgaData())
    }


    val leds = new Area {
        val led_cntr = Reg(UInt(24 bits)) init(0)

        when(led_cntr === U(led_cntr.range -> true)){
            led_cntr := 0
        }
        .otherwise {
            led_cntr := led_cntr +1
        }

        io.led_green    := led_cntr.msb
    }

    val test_pattern_nr = UInt(4 bits)
    val const_color     = Pixel()

    val mr1Config = MR1Config()
    val u_mr1_top = new MR1Top(mr1Config)
    u_mr1_top.io.led1       <> io.led_red
    u_mr1_top.io.led2       <> io.led_blue
    u_mr1_top.io.switch_    <> io.switch_
    u_mr1_top.io.dvi_ctrl_scl    <> io.dvi_ctrl_scl
    u_mr1_top.io.dvi_ctrl_sda    <> io.dvi_ctrl_sda
    u_mr1_top.io.test_pattern_nr            <> test_pattern_nr.addTag(crossClockDomain)
    u_mr1_top.io.test_pattern_const_color   <> const_color.addTag(crossClockDomain)

    val vo_area = new ClockingArea(voClkDomain) {

        val timings = VideoTimings()
        if (false){
            // 640x480@60
            timings.h_active        := 640
            timings.h_fp            := 16
            timings.h_sync          := 96
            timings.h_bp            := 48
            timings.h_sync_positive := False
            timings.h_total_m1      := (timings.h_active + timings.h_fp + timings.h_sync + timings.h_bp -1).resize(timings.h_total_m1.getWidth)

            timings.v_active        := 480
            timings.v_fp            := 11
            timings.v_sync          := 2
            timings.v_bp            := 31
            timings.v_sync_positive := False
            timings.v_total_m1      := (timings.v_active + timings.v_fp + timings.v_sync + timings.v_bp -1).resize(timings.v_total_m1.getWidth)
        }
        else if (false) {
            // 1280x1024@60
            // Clock: 108.0
            timings.h_active        := 1280
            timings.h_fp            := 48
            timings.h_sync          := 112
            timings.h_bp            := 248
            timings.h_sync_positive := True
            timings.h_total_m1      := (timings.h_active + timings.h_fp + timings.h_sync + timings.h_bp -1).resize(timings.h_total_m1.getWidth)

            timings.v_active        := 1024
            timings.v_fp            := 1
            timings.v_sync          := 3
            timings.v_bp            := 38
            timings.v_sync_positive := True
            timings.v_total_m1      := (timings.v_active + timings.v_fp + timings.v_sync + timings.v_bp -1).resize(timings.v_total_m1.getWidth)
        }
        else if (false) {
            // 1080p@60
            // Clock: 147.5
            timings.h_active        := 1920
            timings.h_fp            := 88
            timings.h_sync          := 44
            timings.h_bp            := 148
            timings.h_sync_positive := True
            timings.h_total_m1      := (timings.h_active + timings.h_fp + timings.h_sync + timings.h_bp -1).resize(timings.h_total_m1.getWidth)

            timings.v_active        := 1080
            timings.v_fp            := 4
            timings.v_sync          := 5
            timings.v_bp            := 36
            timings.v_sync_positive := True
            timings.v_total_m1      := (timings.v_active + timings.v_fp + timings.v_sync + timings.v_bp -1).resize(timings.v_total_m1.getWidth)
        }
        else  {
            // 1680x1050@60
            // Clock: 147MHz
            timings.h_active        := 1680
            timings.h_fp            := 104
            timings.h_sync          := 184
            timings.h_bp            := 288
            timings.h_sync_positive := True
            timings.h_total_m1      := (timings.h_active + timings.h_fp + timings.h_sync + timings.h_bp -1).resize(timings.h_total_m1.getWidth)

            timings.v_active        := 1050
            timings.v_fp            := 1
            timings.v_sync          := 3
            timings.v_bp            := 33
            timings.v_sync_positive := True
            timings.v_total_m1      := (timings.v_active + timings.v_fp + timings.v_sync + timings.v_bp -1).resize(timings.v_total_m1.getWidth)
        }

        val vi_gen_pixel_out = PixelStream()

        val u_vi_gen = new VideoTimingGen()
        u_vi_gen.io.timings         <> timings
        u_vi_gen.io.pixel_out       <> vi_gen_pixel_out

        val test_patt_pixel_out = PixelStream()

        val u_test_patt = new VideoTestPattern()
        u_test_patt.io.timings      <> timings
        u_test_patt.io.pixel_in     <> vi_gen_pixel_out
        u_test_patt.io.pixel_out    <> test_patt_pixel_out
        u_test_patt.io.pattern_nr   <> test_pattern_nr
        u_test_patt.io.const_color  <> const_color

        val txt_gen_pixel_out = PixelStream()

        val txt_buf_wr      = u_mr1_top.io.txt_buf_wr.addTag(crossClockDomain)
        val txt_buf_wr_addr = u_mr1_top.io.txt_buf_wr_addr.addTag(crossClockDomain)
        val txt_buf_wr_data = u_mr1_top.io.txt_buf_wr_data.addTag(crossClockDomain)

        val u_txt_gen = new VideoTxtGen()
        u_txt_gen.io.pixel_in       <> test_patt_pixel_out
        u_txt_gen.io.pixel_out      <> txt_gen_pixel_out
        u_txt_gen.io.txt_buf_wr      <> txt_buf_wr
        u_txt_gen.io.txt_buf_wr_addr <> txt_buf_wr_addr
        u_txt_gen.io.txt_buf_wr_data <> txt_buf_wr_data

        val u_vo = new VideoOut()
        u_vo.io.timings             <> timings
        u_vo.io.pixel_in            <> txt_gen_pixel_out
        u_vo.io.vga_out             <> io.vo
    }

}


