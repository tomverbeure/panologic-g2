#include <stdint.h>
#include <math.h>

#include "reg.h"
#include "top_defines.h"
#include "print.h"
#include "i2c.h"
#include "gmii.h"
#include "dvi.h"

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

int main() {

    REG_WR(LED_DIR, 0xff);

    dvi_ctrl_init();

#if 0
    while(1){
        REG_WR(LED_WRITE, 0x01);
        wait(WAIT_CYCLES);
        REG_WR(LED_WRITE, 0x02);
        wait(WAIT_CYCLES);
    }
#endif

#if 1
    clear();
while(1){
    print("Pano Logic G2 Reverse Engineering\n");
    print("---------------------------------\n");
    print("\n");
    print("Spartan-6 LX150 FPGA\n");
    print("DVI & HDMI working @ 1080p\n");
    print("\n");
    print("Code at github.com/tomverbeure/panologic-g2\n");

    wait(1000000);
}
#endif

#if 0
    gmii_mdio_init();
    gmii_wait_auto_neg_complete(0);
    gmii_reg_dump(0);
#endif
#if 0
    gmii_print_phy_id(0);
#endif
#if 0
    gmii_monitor_regs(0);
#endif
#if 0
    gmii_dump_packets(0);
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
