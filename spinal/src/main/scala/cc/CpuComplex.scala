
package cc

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.bus.simple._

import scala.collection.mutable.ArrayBuffer
import vexriscv.plugin.{NONE, _}
import vexriscv.{VexRiscv, VexRiscvConfig, plugin}
import vexriscv.demo._

case class CpuComplexConfig(
                       onChipRamSize      : BigInt,
                       onChipRamHexFile   : String,
                       pipelineDBus       : Boolean,
                       pipelineMainBus    : Boolean,
                       pipelineApbBridge  : Boolean,
                       apb3Config         : Apb3Config,
                       cpuPlugins         : ArrayBuffer[Plugin[VexRiscv]]){

  require(pipelineApbBridge || pipelineMainBus, "At least pipelineMainBus or pipelineApbBridge should be enable to avoid wipe transactions")
}

object CpuComplexConfig{

    def default =  CpuComplexConfig(
        onChipRamSize         = 8 kB,
        onChipRamHexFile      = null,
        pipelineDBus          = true,
        pipelineMainBus       = true,
        pipelineApbBridge     = true,
        cpuPlugins = ArrayBuffer(
            new IBusSimplePlugin(
                resetVector = 0x00000000l,
                cmdForkOnSecondStage = true,
                cmdForkPersistence = false,
                prediction = NONE,
                catchAccessFault = false,
                compressedGen = false
            ),
            new DBusSimplePlugin(
                catchAddressMisaligned = false,
                catchAccessFault = false,
                earlyInjection = false
            ),
            new CsrPlugin(CsrPluginConfig.smallest(mtvecInit = 0x00000020l)),
            new DecoderSimplePlugin(
                catchIllegalInstruction = false
            ),
            new RegFilePlugin(
                regFileReadyKind = plugin.SYNC,
                zeroBoot = false
            ),
            new IntAluPlugin,
            new SrcPlugin(
                separatedAddSub = false,
                executeInsertion = false
            ),
            new LightShifterPlugin,
            new HazardSimplePlugin(
                bypassExecute = false,
                bypassMemory = false,
                bypassWriteBack = false,
                bypassWriteBackBuffer = false,
                pessimisticUseSrc = false,
                pessimisticWriteRegFile = false,
                pessimisticAddressMatch = false
            ),
            new BranchPlugin(
                earlyBranch = false,
                catchAddressMisaligned = false
            ),
            new YamlPlugin("cpu0.yaml")
        ),
        apb3Config = Apb3Config(
            addressWidth = 20,
            dataWidth = 32
        )
  )

  def fast = {
    val config = default

    // Replace HazardSimplePlugin to get datapath bypass
    config.cpuPlugins(config.cpuPlugins.indexWhere(_.isInstanceOf[HazardSimplePlugin])) = new HazardSimplePlugin(
      bypassExecute = true,
      bypassMemory = true,
      bypassWriteBack = true,
      bypassWriteBackBuffer = true
    )
//    config.cpuPlugins(config.cpuPlugins.indexWhere(_.isInstanceOf[LightShifterPlugin])) = new FullBarrelShifterPlugin()

    config
  }
}


case class CpuComplex(config : CpuComplexConfig) extends Component
{
    import config._

    val io = new Bundle {
        val apb                     = master(Apb3(config.apb3Config))
        val externalInterrupt       = in(Bool)
        val timerInterrupt          = in(Bool)
    }

    val pipelinedMemoryBusConfig = PipelinedMemoryBusConfig(
        addressWidth = 32,
        dataWidth = 32
    )

    // Arbiter of the cpu dBus/iBus to drive the mainBus
    // Priority to dBus, !! cmd transactions can change on the fly !!
    val mainBusArbiter = new MuraxMasterArbiter(pipelinedMemoryBusConfig)

    //Instanciate the CPU
    val cpu = new VexRiscv(
        config = VexRiscvConfig(
            plugins = cpuPlugins
        )
    )

    // Checkout plugins used to instanciate the CPU to connect them to the SoC
    for(plugin <- cpu.plugins) plugin match{
        case plugin : IBusSimplePlugin => mainBusArbiter.io.iBus <> plugin.iBus
        case plugin : DBusSimplePlugin => {
            if(!pipelineDBus)
                mainBusArbiter.io.dBus <> plugin.dBus
            else {
                mainBusArbiter.io.dBus.cmd << plugin.dBus.cmd.halfPipe()
                mainBusArbiter.io.dBus.rsp <> plugin.dBus.rsp
            }
        }
        case plugin : CsrPlugin        => {
            plugin.externalInterrupt    := io.externalInterrupt
            plugin.timerInterrupt       := io.timerInterrupt
        }
        case _ =>
    }

    //****** MainBus slaves ********
    val mainBusMapping = ArrayBuffer[(PipelinedMemoryBus,SizeMapping)]()
    val ram = new MuraxPipelinedMemoryBusRam(
        onChipRamSize = onChipRamSize,
        onChipRamHexFile = onChipRamHexFile,
        pipelinedMemoryBusConfig = pipelinedMemoryBusConfig
    )

    mainBusMapping += ram.io.bus -> (0x00000000l, onChipRamSize)

    val apbBridge = new PipelinedMemoryBusToApbBridge(
        apb3Config = Apb3Config(
            addressWidth = 20,
            dataWidth = 32
        ),
        pipelineBridge = pipelineApbBridge,
        pipelinedMemoryBusConfig = pipelinedMemoryBusConfig
    )
    mainBusMapping += apbBridge.io.pipelinedMemoryBus -> (0x80000000l, 1 MB)

    io.apb <> apbBridge.io.apb

    val mainBusDecoder = new Area {
        val logic = new MuraxPipelinedMemoryBusDecoder(
            master = mainBusArbiter.io.masterBus,
            specification = mainBusMapping,
            pipelineMaster = pipelineMainBus
        )
    }
    
}

