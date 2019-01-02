
#include "global.h"
#include "top_defines.h"
#include "reg.h"

void ulpi_wait_reg_done()
{
    int rd_data;

    do{
        rd_data = REG_RD(ULPI_REG_STATUS);
    }
    while(rd_data & (1<<ULPI_REG_STATUS_PENDING_BIT));
}

int ulpi_reg_rd(int addr)
{
    ulpi_wait_reg_done();
    REG_WR(ULPI_REG_ACTION,   (0 << ULPI_REG_ACTION_WR_BIT)
                            | (addr << ULPI_REG_ACTION_ADDR_BIT));

    ulpi_wait_reg_done();
    int rd_data = REG_RD(ULPI_REG_STATUS) & 0xff;

    return rd_data;
}

void ulpi_reg_wr(int addr, int wr_data)
{
    ulpi_wait_reg_done();
    REG_WR(ULPI_REG_ACTION,   (1<<ULPI_REG_ACTION_WR_BIT)
                            | (wr_data << ULPI_REG_ACTION_WR_DATA_BIT)
                            | (addr << ULPI_REG_ACTION_ADDR_BIT));

}

void ulpi_get_vendor_id_product_id(int *vendor_id, int *product_id)
{
    *vendor_id  = ulpi_reg_rd(0) | (ulpi_reg_rd(1) << 8);
    *product_id = ulpi_reg_rd(2) | (ulpi_reg_rd(3) << 8);
}

