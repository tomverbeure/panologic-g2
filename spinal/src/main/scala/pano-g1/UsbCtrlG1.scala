
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc.SizeMapping

object Apb3UsbCtrlG1{
  def getApb3Config = Apb3Config(
    addressWidth = 19,
    dataWidth = 32,
    selWidth = 1,
    useSlaveError = false
  )
}

case class Apb3UsbCtrlG1() extends Component{
  val io = new Bundle{
    val usb_a   = out(UInt(17 bits))
    val usb_d   = master(TriStateArray(16 bits))
    val usb_cs_ = out(Bool)
    val usb_rd_ = out(Bool)
    val usb_wr_ = out(Bool)
    val apb =  slave(Apb3(Apb3UsbCtrlG1.getApb3Config))
    val interrupt = out Bool
  }

   val busCtrl = Apb3SlaveFactory(io.apb)

   val write_cycle = io.apb.PSEL(0) && io.apb.PWRITE
   val write_cycle1 = RegNext(write_cycle) init(False)

   io.usb_a := (io.apb.PADDR >> 2).resized
   io.usb_cs_ := !io.apb.PSEL(0)
   io.usb_rd_ := !(io.apb.PSEL(0) && !io.apb.PWRITE)
   io.usb_wr_ := !(write_cycle && io.apb.PENABLE)

   io.usb_d.writeEnable := B(0, 16 bits)
   io.usb_d.write := B(0, 16 bits)

   when(write_cycle || write_cycle1) {
       io.usb_d.writeEnable := B(U"16'hffff", 16 bits)
       io.usb_d.write := io.apb.PWDATA(15 downto 0)
   }
   .otherwise {
       io.apb.PRDATA := io.usb_d.read.resized
   }

//  io.interrupt := bridge.interruptCtrl.interrupt

}

