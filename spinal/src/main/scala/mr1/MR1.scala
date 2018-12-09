
package mr1

import spinal.core._

case class MR1Config(
                supportMul      : Boolean = false,
                supportDiv      : Boolean = false,
                supportCsr      : Boolean = false,
                supportFormal   : Boolean = false,
                supportFence    : Boolean = false,
                supportAsyncReg : Boolean = false,
                supportRegInit  : Boolean = false,
                pcSize          : Int     = 32,
                dataAddrSize    : Int     = 32,
                reflopDataRsp   : Boolean = true
                ) {

    def hasMul      = supportMul
    def hasDiv      = supportDiv
    def hasCsr      = supportCsr
    def hasFence    = supportFence

    def hasAsyncReg = supportAsyncReg
    def hasRegInit  = supportRegInit

    def hasFormal   = supportFormal
}

case class RegRdUpdate(config: MR1Config) extends Bundle {

    val rd_waddr_valid  = Bool
    val rd_waddr        = UInt(5 bits)
    val rd_wdata_valid  = Bool
    val rd_wdata        = Bits(32 bits)
}

case class RVFI(config: MR1Config) extends Bundle {

    val valid       = Bool
    val order       = UInt(64 bits)
    val insn        = Bits(32 bits)
    val trap        = Bool
    val halt        = Bool
    val intr        = Bool
    val rs1_addr    = UInt(5 bits)
    val rs2_addr    = UInt(5 bits)
    val rs1_rdata   = Bits(32 bits)
    val rs2_rdata   = Bits(32 bits)
    val rd_addr     = UInt(5 bits)
    val rd_wdata    = Bits(32 bits)
    val pc_rdata    = UInt(32 bits)
    val pc_wdata    = UInt(32 bits)
    val mem_addr    = UInt(32 bits)
    val mem_rmask   = Bits(4 bits)
    val mem_wmask   = Bits(4 bits)
    val mem_rdata   = Bits(32 bits)
    val mem_wdata   = Bits(32 bits)

    def init() : RVFI = {
        valid     init(False) addAttribute("keep")
        order     init(0) addAttribute("keep")
        insn      init(0) addAttribute("keep")
        trap      init(False) addAttribute("keep")
        halt      init(False) addAttribute("keep")
        intr      init(False) addAttribute("keep")
        rs1_addr  init(0) addAttribute("keep")
        rs2_addr  init(0) addAttribute("keep")
        rd_addr   init(0) addAttribute("keep")
        rs1_rdata init(0) addAttribute("keep")
        rs2_rdata init(0) addAttribute("keep")
        rd_wdata  init(0) addAttribute("keep")
        pc_rdata  init(0) addAttribute("keep")
        pc_wdata  init(0) addAttribute("keep")
        mem_addr  init(0) addAttribute("keep")
        mem_rmask init(0) addAttribute("keep")
        mem_rdata init(0) addAttribute("keep")
        mem_wmask init(0) addAttribute("keep")
        mem_wdata init(0) addAttribute("keep")

        this
    }
}

object InstrFormat extends SpinalEnum(binaryOneHot) {
    val R       = newElement()
    val I       = newElement()
    val S       = newElement()
    val B       = newElement()
    val U       = newElement()
    val J       = newElement()
    val Shamt   = newElement()
}

object InstrType extends SpinalEnum(binaryOneHot) {
    val Undef   = newElement()
    val JAL     = newElement()
    val JALR    = newElement()
    val B       = newElement()
    val L       = newElement()
    val S       = newElement()
    val ALU_ADD = newElement()
    val ALU     = newElement()
    val SHIFT   = newElement()
    val FENCE   = newElement()
    val E       = newElement()
    val CSR     = newElement()
    val MULDIV  = newElement()
}

case class InstrReqIntfc(config: MR1Config) extends Bundle() {

        val valid       = out(Bool)
        val ready       = in(Bool)
        val addr        = out(UInt(config.pcSize bits))
}

case class InstrRspIntfc(config: MR1Config) extends Bundle() {

        val valid       = in(Bool)
        val data        = in(Bits(32 bits))
}

case class DataReqIntfc(config: MR1Config) extends Bundle() {

        val valid       = out(Bool)
        val ready       = in(Bool)
        val addr        = out(UInt(config.dataAddrSize bits))
        val wr          = out(Bool)
        val size        = out(Bits(2 bits))
        val data        = out(Bits(32 bits))

}

case class DataRspIntfc(config: MR1Config) extends Bundle() {

        val valid       = in(Bool)
        val data        = in(Bits(32 bits))
}

class MR1(config: MR1Config) extends Component {
    val io = new Bundle {
        val instr_req = InstrReqIntfc(config).setName("instr_req")
        val instr_rsp = InstrRspIntfc(config).setName("instr_rsp")

        val data_req  = DataReqIntfc(config).setName("data_req")
        val data_rsp  = DataRspIntfc(config).setName("data_rsp")

        val rvfi        = if (config.supportFormal) out(RVFI(config).setName("rvfi")) else null
    }

    val fetch = new Fetch(config)
    fetch.io.instr_req <> io.instr_req
    fetch.io.instr_rsp <> io.instr_rsp

    val decode = new Decode(config)
    decode.io.f2d       <> fetch.io.f2d
    decode.io.d2f       <> fetch.io.d2f
    decode.io.rd_update <> fetch.io.d_rd_update

    val execute = new Execute(config)
    execute.io.d2e          <> decode.io.d2e
    execute.io.e2d          <> decode.io.e2d
    execute.io.rd_update    <> fetch.io.e_rd_update
    execute.io.data_req     <> io.data_req

    val reg_file = new RegFile(config)
    reg_file.io.rd2r <> fetch.io.rd2r
    reg_file.io.r2rd <> fetch.io.r2rd
    reg_file.io.r2rr <> decode.io.r2rr

    val wb = new Writeback(config)
    wb.io.e2w       <> execute.io.e2w
    wb.io.w2e       <> execute.io.w2e
    wb.io.rd_update <> fetch.io.w_rd_update
    wb.io.data_rsp  <> io.data_rsp
    wb.io.w2r       <> reg_file.io.w2r

    if (config.hasFormal){
        decode.io.d2e_rvfi  <> execute.io.d2e_rvfi
        execute.io.e2w_rvfi <> wb.io.e2w_rvfi
        wb.io.rvfi          <> io.rvfi
    }
}

object MR1Verilog {
    def main(args: Array[String]) {
        SpinalVerilog(new MR1(config = MR1Config(supportFormal = true,
                                                 supportMul = false,
                                                 supportDiv = false,
                                                 supportCsr = false)))
    }
}

