package pano

import spinal.core._

class Audio_test() extends BlackBox {
val io = new Bundle {
    var clk12 = in Bool
    var reset12_ = in Bool

    var codec_mclk = out Bool
    var codec_bclk = out Bool
    var codec_dacdat = out Bool
    var codec_daclrc = out Bool
    var codec_adcdat = in Bool
    var codec_adclrc = out Bool
  }

  // Remove io_ prefix 
  noIoPrefix() 

  addRTLPath("../../verilog/audio_test.v")
}


