
package cc

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._
import spinal.lib.io.{TriStateArray, TriState}

object CCGpio {
    def getApb3Config() = Apb3Config(addressWidth = 5,dataWidth = 32)
}

// 0x0000 : Direction. 0 -> input, 1 -> output
// 0x0004 : Write
// 0x0008 : Set
// 0x000c : Clear
// 0x0010 : Read

case class CCGpio(gpioWidth: Int) extends Component {

    val io = new Bundle {
        val apb  = slave(Apb3(CCGpio.getApb3Config()))
        val gpio = master(TriStateArray(gpioWidth bits))
    }

    val value = Reg(Bits(gpioWidth bits)) init(0)
    val ctrl = Apb3SlaveFactory(io.apb)

    // Direction
    io.gpio.writeEnable := ctrl.createReadAndWrite(Bits(gpioWidth bits), 0) init(0)

    // Straight read and write
    ctrl.readAndWrite(value, 4)

    // Set bit when corresponding value is set
    val wrBits = ctrl.nonStopWrite(Bits(gpioWidth bits), 0)
    ctrl.onWrite(8){
        for(i <- 0 until gpioWidth){
            when(wrBits(i)){
                value(i) := True
            }
        }
    }

    // Clear bit when corresponding value is set
    ctrl.onWrite(12){
        for(i <- 0 until gpioWidth){
            when(wrBits(i)){
                value(i) := False
            }
        }
    }

    ctrl.read(io.gpio.read, 0x0010)

    io.gpio.write := value
}
