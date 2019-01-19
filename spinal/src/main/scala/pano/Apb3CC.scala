
package pano

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._

object Apb3CC {
}

class Apb3CC(apb3Config: Apb3Config, srcDomain: ClockDomain, destDomain: ClockDomain) extends Component {

    val io = new Bundle {
        val src         = slave(Apb3(apb3Config))
        val dest        = master(Apb3(apb3Config))
    }

    val PRDATA_dest = Bits(apb3Config.dataWidth bits)

    val xfer_done_src = Bool
    val xfer_done_dest = Bool

    val u_sync_pulse_xfer_done = new PulseCCByToggle(destDomain, srcDomain)
    u_sync_pulse_xfer_done.io.pulseIn      <> xfer_done_dest
    u_sync_pulse_xfer_done.io.pulseOut     <> xfer_done_src


    val src = new ClockingArea(srcDomain) {

        val xfer_start  = Reg(Bool) init(False)
        val PADDR       = Reg(UInt(apb3Config.addressWidth bits)) init(0)
        val PSEL        = Reg(Bits(apb3Config.selWidth bits)) init(0)
        val PWRITE      = RegInit(False)
        val PWDATA      = Reg(Bits(apb3Config.dataWidth bits)) init(0)
        val PRDATA      = Reg(Bits(apb3Config.dataWidth bits)) init(0)
        val PREADY      = RegInit(False)
        val PSLVERROR   = if (apb3Config.useSlaveError) Reg(Bool) else null

        xfer_start  := False
        when((io.src.PENABLE && io.src.PSEL.orR).rise){
            xfer_start      := True
            PADDR           := io.src.PADDR
            PSEL            := io.src.PSEL
            PWRITE          := io.src.PWRITE
            PWDATA          := io.src.PWDATA
        }

        PREADY          := False
        when(xfer_done_src){
            PREADY          := True
            when (!io.src.PWRITE){
                PRDATA      := PRDATA_dest.addTag(crossClockDomain)
            }
        }

        io.src.PRDATA   := PRDATA
        io.src.PREADY   := PREADY
    }

    val xfer_start_dest = Bool
    val u_sync_pulse_xfer_start = new PulseCCByToggle(srcDomain, destDomain)
    u_sync_pulse_xfer_start.io.pulseIn      <> src.xfer_start
    u_sync_pulse_xfer_start.io.pulseOut     <> xfer_start_dest

    val dest = new ClockingArea(destDomain) {
        val xfer_start_dest_d1 = RegNext(xfer_start_dest) init(False)

        val PADDR       = Reg(UInt(apb3Config.addressWidth bits)) init(0)
        val PSEL        = Reg(Bits(apb3Config.selWidth bits)) init(0)
        val PWRITE      = RegInit(False)
        val PWDATA      = Reg(Bits(apb3Config.dataWidth bits)) init(0)
        val PRDATA      = Reg(Bits(apb3Config.dataWidth bits)) init(0)
        val PSLVERROR   = if (apb3Config.useSlaveError) Reg(Bool) else null

        when(xfer_start_dest){
            PADDR       := src.PADDR.addTag(crossClockDomain)
            PSEL        := src.PSEL.addTag(crossClockDomain)
            PWRITE      := src.PWRITE.addTag(crossClockDomain)
            PWDATA      := src.PWDATA.addTag(crossClockDomain)
        }

        val PENABLE     = RegInit(False) setWhen(xfer_start_dest_d1) clearWhen(io.dest.PREADY)
        val xfer_done   = RegInit(False)

        xfer_done := False
        when(PENABLE && io.dest.PREADY){
            PSEL        := 0
            when(!io.dest.PWRITE){
                PRDATA      := io.dest.PRDATA
            }
            xfer_done := True
        }


        io.dest.PENABLE := PENABLE
        io.dest.PADDR   := PADDR
        io.dest.PSEL    := PSEL
        io.dest.PWRITE  := PWRITE
        io.dest.PWDATA  := PWDATA

        PRDATA_dest     := PRDATA
        xfer_done_dest  := xfer_done
    }
}


case class Apb3CCFormalTb() extends Component
{
    val io = new Bundle() {
        val clk             = in(Bool)
        val reset_          = in(Bool)
    }


    val domain = new ClockingArea(ClockDomain(io.clk, io.reset_, 
                                                config = ClockDomainConfig(resetKind = SYNC, resetActiveLevel = LOW)))
    {
       val apb3Config = Apb3Config(addressWidth = 6, dataWidth = 32)
   
       val src     = Apb3(apb3Config)
       val dest    = Apb3(apb3Config)
   
       val u_apb3cc = new Apb3CC(apb3Config, ClockDomain.current, ClockDomain.current)
       u_apb3cc.io.src         <> src
       u_apb3cc.io.dest        <> dest
   
       val src_xfer_cntr = Reg(UInt(8 bits)) init(0)
       val dest_xfer_cntr = Reg(UInt(8 bits)) init(0)
   
       when(src.PENABLE && src.PREADY){
           src_xfer_cntr := src_xfer_cntr + 1
       }
   
       when(dest.PENABLE && dest.PREADY){
           dest_xfer_cntr := dest_xfer_cntr + 1
       }
   
   
       import spinal.core.GenerationFlags._
       import spinal.core.Formal._
   
       GenerationFlags.formal{
            import pano.lib._

            assume(io.reset_ === !initstate())

            assume(rose(src.PENABLE)    |-> stable(src.PSEL))
            assume(rose(src.PENABLE)    |-> stable(src.PADDR))
            assume(rose(src.PENABLE)    |-> stable(src.PWRITE))
            assume(rose(src.PENABLE)    |-> stable(src.PWDATA))

            assume(src.PREADY           |-> stable(src.PENABLE))
            assume(src.PREADY           |-> stable(src.PSEL))
            assume(src.PREADY           |-> stable(src.PADDR))
            assume(src.PREADY           |-> stable(src.PWRITE))
            assume(src.PREADY           |-> stable(src.PWDATA))

            assume(fell(src.PENABLE)    |-> src.PREADY)
            assume(fell(src.PSEL.orR)   |-> src.PREADY)

            assume(!stable(src.PSEL)    |=> (fell(src.PENABLE) || !src.PENABLE))
            assume(!stable(src.PADDR)   |=> (fell(src.PENABLE) || !src.PENABLE))
            assume(!stable(src.PWRITE)  |=> (fell(src.PENABLE) || !src.PENABLE))
            assume(!stable(src.PWDATA)  |=> (fell(src.PENABLE) || !src.PENABLE))

            assume(rose(dest.PREADY)   |-> dest.PENABLE)
            assume(rose(dest.PREADY)   |=> fell(dest.PREADY))
   
            when(!initstate()){
                assert(src_xfer_cntr === dest_xfer_cntr || src_xfer_cntr+1 === dest_xfer_cntr)
            }
       }
    }.setName("")
}

object Apb3CCVerilog{
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)
        config.includeFormal.generateSystemVerilog({
            val toplevel = new Apb3CCFormalTb()
            toplevel
        })
        println("DONE")
    }
}

