#ifndef I2C_H
#define I2C_H

#include "global.h"
#include "top_defines.h"

typedef struct {
    int             base_addr;
    unsigned char   scl_pin_nr;
    unsigned char   sda_pin_nr;
} i2c_ctx_t;

void i2c_init(i2c_ctx_t *ctx);
void i2c_dly();
void i2c_start(i2c_ctx_t *ctx);
void i2c_stop(i2c_ctx_t *ctx);
unsigned char i2c_rx(i2c_ctx_t *ctx, char ack);
int i2c_tx(i2c_ctx_t *ctx, unsigned char d);
int i2c_write_buf(i2c_ctx_t *ctx, byte addr, byte* data, int len);
int i2c_read_buf(i2c_ctx_t *ctx, byte addr, byte *data, int len);
int i2c_write_reg_nr(i2c_ctx_t *ctx, byte addr, byte reg_nr);
int i2c_write_reg(i2c_ctx_t *ctx, byte addr, byte reg_nr, byte value);
int i2c_write_regs(i2c_ctx_t *ctx, byte addr, byte reg_nr, byte *values, int len);
int i2c_read_reg(i2c_ctx_t *ctx, byte addr, byte reg_nr, byte *value);
int i2c_read_regs(i2c_ctx_t *ctx, byte addr, byte reg_nr, byte *values, int len);

void i2c_set_scl(i2c_ctx_t *ctx, int bit);
void i2c_set_sda(i2c_ctx_t *ctx, int bit);

#endif
