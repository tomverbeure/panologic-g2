
package mr1

import spinal.core._


class cpu_ram extends BlackBox {

    val io = new Bundle {
    	val clock           = in(Bool)
    	val address_a       = in(UInt(10 bits))
    	val wren_a          = in(Bool)
    	val data_a          = in(Bits(32 bits))
    	val q_a             = out(Bits(32 bits))
    
    	val address_b       = in(UInt(10 bits))
    	val wren_b          = in(Bool)
    	val byteena_b       = in(Bits(4 bits))
    	val data_b          = in(Bits(32 bits))
    	val q_b             = out(Bits(32 bits))
    }

    mapCurrentClockDomain(io.clock)
    noIoPrefix()

    // addRTLPath("./quartus/altera_models/cpu_ram/cpu_ram_bb.v")
}

