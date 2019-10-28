
#include "global.h"
#include "top_defines.h"
#include "i2c.h"
#include "reg.h"

#define I2C_SET_BITS(addr, bits)     (REG_OFF_WR(addr, CCGPIO_SET, bits))
#define I2C_CLR_BITS(addr, bits)     (REG_OFF_WR(addr, CCGPIO_CLR, bits))
#define I2C_RD_BITS(addr)            (REG_OFF_RD(addr, CCGPIO_RD))

void i2c_set_scl(i2c_ctx_t *ctx, int bit)
{
    if (bit)
        I2C_SET_BITS(ctx->base_addr, 1 << ctx->scl_pin_nr);
    else
        I2C_CLR_BITS(ctx->base_addr, 1 << ctx->scl_pin_nr);
}

void i2c_set_sda(i2c_ctx_t *ctx, int bit)
{
    if (bit)
        I2C_SET_BITS(ctx->base_addr, 1 << ctx->sda_pin_nr);
    else
        I2C_CLR_BITS(ctx->base_addr, 1 << ctx->sda_pin_nr);
}


static int i2c_get_scl(i2c_ctx_t *ctx)
{
    return (I2C_RD_BITS(ctx->base_addr) >> ctx->scl_pin_nr) & 1;
}

static int i2c_get_sda(i2c_ctx_t *ctx)
{
    return (I2C_RD_BITS(ctx->base_addr) >> ctx->sda_pin_nr) & 1;
}

void i2c_init(i2c_ctx_t *ctx)
{
    i2c_set_sda(ctx, 1);
    i2c_set_scl(ctx, 1);
}


void i2c_dly()
{
    int i;
    for(i=0;i<15;++i){
        // Any random register without side effects...
        // This needs to be replaced with a global timer wait or something.
        I2C_RD_BITS(DVI_CTRL_BASE_ADDR);
    }
}

void i2c_start(i2c_ctx_t *ctx)
{
    i2c_set_sda(ctx, 1);             // i2c start bit sequence
    i2c_dly();
    i2c_set_scl(ctx, 1);
    i2c_dly();
    i2c_set_sda(ctx, 0);
    i2c_dly();
    i2c_set_scl(ctx, 0);
    i2c_dly();
    i2c_dly();
}

void i2c_stop(i2c_ctx_t *ctx)
{
    i2c_dly();
    i2c_set_sda(ctx, 0);             // i2c stop bit sequence
    i2c_dly();
    i2c_set_scl(ctx, 1);
    i2c_dly();
    i2c_set_sda(ctx, 1);
    i2c_dly();
}

unsigned char i2c_rx(i2c_ctx_t *ctx, char ack)
{
    char x, d=0;
    i2c_set_sda(ctx, 1);

    for(x=0; x<8; x++) {
        d <<= 1;

        i2c_set_scl(ctx, 1);
        i2c_dly();
        // wait for any i2c_set_scl clock stretching
        while(i2c_get_scl(ctx)==0);

        d |= i2c_get_sda(ctx);
        i2c_set_scl(ctx, 0);
        i2c_dly();
    }
    i2c_dly();

    if(ack)
        i2c_set_sda(ctx, 0);
    else
        i2c_set_sda(ctx, 1);

    i2c_set_scl(ctx, 1);
    i2c_dly();             // send (N)ACK bit

    i2c_set_scl(ctx, 0);
    i2c_dly();             // send (N)ACK bit

    i2c_set_sda(ctx, 1);
    return d;
}

// return 1: ACK, 0: NACK
int i2c_tx(i2c_ctx_t *ctx, unsigned char d)
{
    char x;
    for(x=8; x; x--) {
        i2c_set_sda(ctx, (d & 0x80)>>7);
        d <<= 1;
        i2c_dly();
        i2c_set_scl(ctx, 1);
        i2c_dly();
        i2c_set_scl(ctx, 0);
    }
    i2c_dly();
    i2c_dly();
    i2c_set_sda(ctx, 1);
    i2c_dly();
    i2c_set_scl(ctx, 1);
    i2c_dly();

    int bit = i2c_get_sda(ctx);         // possible ACK bit
#if 0
    if (bit){
        GPIO_DOUT_SET = 1;
    }
    else {
        GPIO_DOUT_CLR = 1;
    }
#endif

    i2c_set_scl(ctx, 0);
    i2c_dly();

    return !bit;
}

int i2c_write_buf(i2c_ctx_t *ctx, byte addr, byte* data, int len)
{
    int ack;

    i2c_start(ctx);
    ack = i2c_tx(ctx, addr);
    if (!ack){
        i2c_stop(ctx);
        return 0;
    }


    int i;
    for(i=0;i<len;++i){
        ack = i2c_tx(ctx, data[i]);
        if (!ack){
            i2c_stop(ctx);
            return 0;
        }
    }

    i2c_stop(ctx);

    return 1;
}

int i2c_read_buf(i2c_ctx_t *ctx, byte addr, byte *data, int len)
{
    int ack;

    i2c_start(ctx);

    ack = i2c_tx(ctx, addr | 1);
    if (!ack){
        i2c_stop(ctx);
        return 0;
    }

    int i;
    for(i=0;i<len;++i){
        data[i] = i2c_rx(ctx, i!=len-1);
    }
    i2c_stop(ctx);

    return 1;
}

int i2c_write_reg_nr(i2c_ctx_t *ctx, byte addr, byte reg_nr)
{
    return i2c_write_buf(ctx, addr, &reg_nr, 1);
}

int i2c_write_reg(i2c_ctx_t *ctx, byte addr, byte reg_nr, byte value)
{
    byte data[2] = { reg_nr, value };

    return i2c_write_buf(ctx, addr, data, 2);
}

int i2c_write_regs(i2c_ctx_t *ctx, byte addr, byte reg_nr, byte *values, int len)
{
    int ack;

    i2c_start(ctx);

    ack = i2c_tx(ctx, addr);
    if (!ack){
        i2c_stop(ctx);
        return 0;
    }

    ack = i2c_tx(ctx, reg_nr);
    if (!ack){
        i2c_stop(ctx);
        return 0;
    }

    int i;
    for(i=0;i<len;++i){
        ack = i2c_tx(ctx, values[i]);
        if (!ack){
            i2c_stop(ctx);
            return 0;
        }
    }

    i2c_stop(ctx);

    return 1;
}


int i2c_read_reg(i2c_ctx_t *ctx, byte addr, byte reg_nr, byte *value)
{
    int result;

    // Set address to read
    result = i2c_write_buf(ctx, addr, &reg_nr, 1);
    if (!result)
        return 0;

    result = i2c_read_buf(ctx, addr, value, 1);
    if (!result)
        return 0;

    return 1;
}

int i2c_read_regs(i2c_ctx_t *ctx, byte addr, byte reg_nr, byte *values, int len)
{
    int result;

    // Set address to read
    result = i2c_write_buf(ctx, addr, &reg_nr, 1);
    if (!result)
        return 0;

    result = i2c_read_buf(ctx, addr, values, len);
    if (!result)
        return 0;

    return 1;
}

