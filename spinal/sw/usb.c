
#include "global.h"
#include "top_defines.h"
#include "reg.h"
#include "print.h"

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

void ulpi_get_rx_cmd(int *rx_cmd, int *rx_cmd_changed)
{
    int rx_cmd_raw = REG_RD(ULPI_RX_CMD);

    *rx_cmd         = rx_cmd_raw & 0xff;
    *rx_cmd_changed = (rx_cmd_raw >> ULPI_RX_CMD_CHANGED_BIT) & 1;
}

void ulpi_print_id()
{
    int vendor_id, product_id;
    ulpi_get_vendor_id_product_id(&vendor_id, &product_id);
    print("vendor_id:");
    print_int(vendor_id, 1);
    print("   product_id:");
    print_int(product_id, 1);
    print("\n");
}

void ulpi_monitor_rx_cmd()
{
    int first = 1;

    while(1){
        int rx_cmd, rx_cmd_changed;

        ulpi_get_rx_cmd(&rx_cmd, &rx_cmd_changed);

        if (rx_cmd_changed || first){
            print("rx_cmd: ");
            print_int(rx_cmd, 1);
            print("\n");

            first = 0;
        }
    }
}

