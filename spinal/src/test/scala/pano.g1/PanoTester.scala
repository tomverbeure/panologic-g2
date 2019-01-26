
package pano

import org.scalatest.FunSuite

import spinal.sim._
import spinal.core._
import spinal.core.sim._

object PanoTesterG1 {

    class PanoCoreDut extends Component {
        val io = new Bundle {
            val osc_clk             = in(Bool)
        }
    //============================================================
    // Create osc_clk clock domain
    //============================================================
    val oscClkDomain = ClockDomain(
        clock = io.osc_clk,
        frequency = FixedFrequency(100 MHz),
        config = ClockDomainConfig(
                    resetKind = BOOT
        )
    )
        val u_pano_core = new PanoCoreG1(oscClkDomain)
    }
}

class PanoTesterG1 extends FunSuite {

    test("PanoG1") {

        var compiled = SimConfig
            .withWave
//            .allOptimisation
            .compile(new PanoTesterG1.PanoCoreDut())

        compiled.doSim { dut =>

            dut.clockDomain.forkStimulus(period = 10)
            dut.clockDomain.forkSimSpeedPrinter(0.2)

            var i = 0;
            while(i<500){
                dut.clockDomain.waitSampling(1000)
                printf("*")
                if (i%10==9){
                    printf("%d\n", i)
                }
                i = i +1
            }
        }
    }

}
