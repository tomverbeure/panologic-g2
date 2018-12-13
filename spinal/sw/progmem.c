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


#define WAIT_CYCLES 1000000

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
        {   0x33,       0x08},              // charge pump settings. See table 10
        {   0x34,       0x16},              // charge pump settings. See table 10
        {   0x36,       0x60},              // charge pump settings. See table 10
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

//        i2c_write_regs(&dvi_ctrl_i2c_ctx, 0x75<<1, reg_nr, &reg_val, 1);
        i2c_write_regs(&dvi_ctrl_i2c_ctx, 0x76<<1, reg_nr, &reg_val, 1);

        ++i;
    }
}


int main() {

    REG_WR(LED_CONFIG, 0x00);

    dvi_ctrl_init();

#if 0
    int addr = 0x75;
    while(1){
        {
            bool ack = i2c_write_reg_nr(&dvi_ctrl_i2c_ctx, (addr & 0x7f)<<1, 0x5a);
            if (ack){
                REG_WR(LED_CONFIG, 0xff);
                wait(10000);
            }
            else{
                REG_WR(LED_CONFIG, 0x00);
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
    print("Spartan-6 LX150 FPGA + DVI working\n");
    print("\n");
    print("Code at github.com/tomverbeure/panologic-g2\n");
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
            REG_WR(LED_CONFIG, 0xff);
            wait(WAIT_CYCLES);
            REG_WR(LED_CONFIG, 0x0);
            wait(WAIT_CYCLES);
        }
        else{
            REG_WR(LED_CONFIG, 0x00);
        }
    }
}
