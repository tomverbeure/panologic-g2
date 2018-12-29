#include <stdint.h>
#include <math.h>

#include "reg.h"
#include "top_defines.h"
#include "print.h"
#include "i2c.h"

static inline uint32_t rdcycle(void) {
    uint32_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

static inline int nop(void) {
    asm volatile ("addi x0, x0, 0");
    return 0;
}

void wait(int cycles)
{
#if 1
    volatile int cnt = 0;

    for(int i=0;i<cycles;++i){
        ++cnt;
    }
#else
    int start;

    start = rdcycle();
    while ((rdcycle() - start) <= cycles);
#endif
}


#define WAIT_CYCLES 500000

int button_pressed()
{
    return REG_RD(BUTTON) == 0x01;
}

i2c_ctx_t dvi_ctrl_i2c_ctx;

void dvi_ctrl_init()
{
    dvi_ctrl_i2c_ctx.base_addr = 0;
    dvi_ctrl_i2c_ctx.scl_pin_nr = 0;
    dvi_ctrl_i2c_ctx.sda_pin_nr = 1;

    i2c_init(&dvi_ctrl_i2c_ctx);

    byte chrontel_registers[][2] = {
        {   0x1c,       0x00},              // 1x DDR clocking
        {   0x1d,       0x40},              // internal clock delay
        {   0x1f,       0x80},              // input data format. Bit 4: vsp, bit 4: hsp

#if 0
        // clk <= 65Mhz
        {   0x33,       0x08},              // charge pump settings. See table 10
        {   0x34,       0x16},              // charge pump settings. See table 10
        {   0x36,       0x60},              // charge pump settings. See table 10
#else
        // clk > 65Mhz
        {   0x33,       0x06},              // charge pump settings. See table 10
        {   0x34,       0x26},              // charge pump settings. See table 10
        {   0x36,       0xa0},              // charge pump settings. See table 10
#endif

        {   0x48,       0x18},              // Test Image: none
//        {   0x48,       0x19},              // Test Image: color bars
//        {   0x48,       0x1e},              // Test Image: luminance ramp
        {   0x49,       0xc0},              // DVI on

        {   0xff,       0xff}               // The end
    };

    int i=0;
    while(chrontel_registers[i][0] != 0xff){
        byte reg_nr  = chrontel_registers[i][0];
        byte reg_val = chrontel_registers[i][1];

        i2c_write_regs(&dvi_ctrl_i2c_ctx, 0x75<<1, reg_nr, &reg_val, 1);
        i2c_write_regs(&dvi_ctrl_i2c_ctx, 0x76<<1, reg_nr, &reg_val, 1);

        ++i;
    }
}

void mii_mdio_init()
{
    // Set all IOs to output
    REG_WR(MII_SET, 1<<MII_MDC_ENA);
    REG_WR(MII_CLR, 1<<MII_MDIO_ENA);            // MDIO is tri-state while idle

    // Initial values
    REG_WR(MII_CLR, 1<<MII_MDC_VAL);
    REG_WR(MII_CLR, 1<<MII_MDIO_VAL);
}

#define MII_HALF_BIT_WAIT  1

void mii_mdc_toggle()
{
    wait(MII_HALF_BIT_WAIT);
    REG_WR(MII_SET, 1<<MII_MDC_VAL);
    wait(MII_HALF_BIT_WAIT);
    REG_WR(MII_CLR, 1<<MII_MDC_VAL);
}

int mii_mdio_rd(int phy_addr, int reg_addr)
{
    for(int i=0;i<32;++i){
        mii_mdc_toggle();
    }

    REG_WR(MII_SET, 1<<MII_MDIO_ENA);

    unsigned word =   (1 << 12)                     // Start bits
                    | (2 << 10)                     // Read
                    | ((phy_addr & 0x1f) << 5)
                    | ((reg_addr & 0x1f) << 0);

    for(int i=13; i >= 0; --i){
        int bit = (word >> i) & 1;

        if (bit) REG_WR(MII_SET, 1<<MII_MDIO_VAL);
        else     REG_WR(MII_CLR, 1<<MII_MDIO_VAL);

        mii_mdc_toggle();
    }

    int ta = 0;
    int rdata = 0;

    REG_WR(MII_CLR, 1<<MII_MDIO_ENA);
    mii_mdc_toggle();

    ta = (REG_RD(MII_RD) >> MII_MDIO_VAL) & 1;
    mii_mdc_toggle();
    ta = (ta<<1) | ((REG_RD(MII_RD) >> MII_MDIO_VAL) & 1);

    for(int i=15;i>=0;--i){
        rdata = (rdata<<1) | ((REG_RD(MII_RD) >> MII_MDIO_VAL) & 1);
        mii_mdc_toggle();
    }

    return rdata;
}


void mii_phy_identifier(int phy_addr, uint32_t *oui, uint32_t *model_nr, uint32_t *rev_nr)
{
    int rdata2 = mii_mdio_rd(phy_addr, 2);
    int rdata3 = mii_mdio_rd(phy_addr, 3);

    *oui      = (((rdata3 >> 10) & ((1<<6)-1))<< 0) | (rdata2 << 6);

    *model_nr = (rdata3 >> 4) & ((1<<6)-1);
    *rev_nr   = (rdata3 >> 0) & ((1<<4)-1);
}

void mii_reg_dump(int phy_addr)
{
    int rdata;

    rdata = mii_mdio_rd(phy_addr, 0);
    print("Reg  0: Control               : "); print_int(rdata, 1); print("\n");

    rdata = mii_mdio_rd(phy_addr, 1);
    print("Reg  1: Status                : "); print_int(rdata, 1); print("\n");

    rdata = mii_mdio_rd(phy_addr, 2);
    print("Reg  2: PHY ID                : "); print_int(rdata, 1); print("\n");

    rdata = mii_mdio_rd(phy_addr, 3);
    print("Reg  3: PHY ID                : "); print_int(rdata, 1); print("\n");

    rdata = mii_mdio_rd(phy_addr, 4);
    print("Reg  4: Auto-Neg Advertisement: "); print_int(rdata, 1); print("\n");

    rdata = mii_mdio_rd(phy_addr, 5);
    print("Reg  5: Link Partner Ability  : "); print_int(rdata, 1); print("\n");

    rdata = mii_mdio_rd(phy_addr, 6);
    print("Reg  6: Auto-Neg Expansion    : "); print_int(rdata, 1); print("\n");

    rdata = mii_mdio_rd(phy_addr, 16);
    print("Reg 16: PHY Specific Control  : "); print_int(rdata, 1); print("\n");

    rdata = mii_mdio_rd(phy_addr, 17);
    print("Reg 17: PHY Specific Status   : "); print_int(rdata, 1); print("\n");
}

void mii_wait_auto_neg_complete(int phy_addr)
{
    int rdata;

    do{
        rdata = mii_mdio_rd(phy_addr, 1);
    } while(!(rdata & (1<<5)));
}

int main() {

    REG_WR(LED_DIR, 0xff);

    while(1){
        REG_WR(LED_WRITE, 0x01);
        wait(WAIT_CYCLES);
        REG_WR(LED_WRITE, 0x02);
        wait(WAIT_CYCLES);
    }

    dvi_ctrl_init();

#if 0
    int addr = 0x75;
    while(1){
        {
            bool ack = i2c_write_reg_nr(&dvi_ctrl_i2c_ctx, (addr & 0x7f)<<1, 0x5a);
            if (ack){
                REG_WR(LED_WRITE, 0xff);
                wait(10000);
            }
            else{
                REG_WR(LED_WRITE, 0x00);
            }
            wait(250);
        }

        addr ^= 0x03;
    }
#endif

#if 1
    clear();
    print("Pano Logic G2 Reverse Engineering\n");
    print("---------------------------------\n");
    print("\n");
    print("Spartan-6 LX150 FPGA\n");
    print("DVI & HDMI working @ 1080p\n");
    print("\n");
    print("Code at github.com/tomverbeure/panologic-g2\n");
#endif

    mii_mdio_init();

    mii_wait_auto_neg_complete(0);

    mii_reg_dump(0);

    uint32_t oui, model_nr, rev_nr;

    mii_phy_identifier(0, &oui, &model_nr, &rev_nr);
    print("oui      :");
    print_int(oui, 1);
    print("\n");
    print("model_nr :");
    print_int(model_nr, 1);
    print("\n");
    print("rev_nr   :");
    print_int(rev_nr, 1);
    print("\n");

#if 0
    int prev_rdata = mii_mdio_rd(0, 17);
    while(1){
        int rdata = mii_mdio_rd(0, 17);

        if (rdata != prev_rdata){
            mii_reg_dump(0);
            prev_rdata = rdata;
        }
    }
#endif

#if 1
    int had_data = 0;

    while(1){
        unsigned int rx_data = REG_RD(MII_RX_FIFO);
        if ((rx_data>>9) == 0){
            if (had_data){
                print_int(had_data, 1);
                print("\n\n");
            }
            had_data = 0;
            continue;
        }

        if (!had_data){
            print(".");
        }

        had_data += 1;

//        print_byte(rx_data>>8, 1);
//        print(" ");
        print_byte(rx_data, 1);
        print(",");
    }

#endif

#if 0
    while(1){
    int mii_rdata = mii_mdio_rd(0, 2);
    print("PHY 2: ");
    print_int(mii_rdata, 1);
    print("\n");

    mii_rdata = mii_mdio_rd(0, 3);
    print("PHY 3: ");
    print_int(mii_rdata, 1);
    print("\n");

    wait(1000000);
    }
#endif

    int pattern_nr = 0;
    int const_color_nr = 0;

    while(1){
        wait(3000000);
        pattern_nr = (pattern_nr + 1) % 7;
        REG_WR(TEST_PATTERN_NR, pattern_nr);

        if (pattern_nr == 0){
            const_color_nr = (const_color_nr + 1)%5;

            switch(const_color_nr){
                case 0: REG_WR(TEST_PATTERN_CONST_COLOR, 0x000000); break;
                case 1: REG_WR(TEST_PATTERN_CONST_COLOR, 0xffffff); break;
                case 2: REG_WR(TEST_PATTERN_CONST_COLOR, 0x0000ff); break;
                case 3: REG_WR(TEST_PATTERN_CONST_COLOR, 0x00ff00); break;
                case 4: REG_WR(TEST_PATTERN_CONST_COLOR, 0xff0000); break;
            }
        }
    }

    while(1){
        if (!button_pressed()){
            REG_WR(LED_WRITE, 0xff);
            wait(WAIT_CYCLES);
            REG_WR(LED_WRITE, 0x0);
            wait(WAIT_CYCLES);
        }
        else{
            REG_WR(LED_WRITE, 0x00);
        }
    }
}
