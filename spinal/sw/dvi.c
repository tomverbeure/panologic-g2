#include <stdint.h>

#include "reg.h"
#include "top_defines.h"
#include "print.h"
#include "i2c.h"

#include "dvi.h"

i2c_ctx_t dvi_ctrl_i2c_ctx;

void dvi_ctrl_init()
{
    dvi_ctrl_i2c_ctx.base_addr = DVI_CTRL_BASE_ADDR;
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

