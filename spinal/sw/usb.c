
#include "global.h"
#include "top_defines.h"
#include "reg.h"
#include "print.h"

// J:   DM = 0, DP = 1
// K:   DM = 1, DP = 0
// Idle J: FS
// Idle K: LS

#define ULPI_LINESTATE(byte)            ((byte) & 0x03)
#define ULPI_LINESTATE_IS_SE0(byte)     ((ULPI_LINESTATE(byte) == 0x00)
#define ULPI_LINESTATE_IS_J(byte)       ((ULPI_LINESTATE(byte) == 0x01)
#define ULPI_LINESTATE_IS_K(byte)       ((ULPI_LINESTATE(byte) == 0x02)
#define ULPI_LINESTATE_IS_SE1(byte)     ((ULPI_LINESTATE(byte) == 0x03)

#define ULPI_FUNC_CTRL_ADDR             (0x04)
#define ULPI_FUNC_CTRL_SET_ADDR         (0x05)
#define ULPI_FUNC_CTRL_CLR_ADDR         (0x06)

#define ULPI_OTG_CTRL_ADDR              (0x0a)
#define ULPI_OTG_CTRL_SET_ADDR          (0x0b)
#define ULPI_OTG_CTRL_CLR_ADDR          (0x0c)

#define ULPI_SCRATCH_ADDR               (0x16)
#define ULPI_SCRATCH_SET_ADDR           (0x17)
#define ULPI_SCRATCH_CLR_ADDR           (0x18)

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

void ulpi_print_reg(int addr)
{
    int value = ulpi_reg_rd(addr);

    print("Register ");
    print_int(addr, 1);
    print(": ");
    print_int(value, 1);
    print("\n");
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

void ulpi_print_linestate(int byte)
{
    print("Linestate: ");
    switch(ULPI_LINESTATE(byte)){
        case 0: print("SE0\n"); break;
        case 1: print("J\n"); break;
        case 2: print("K\n"); break;
        case 3: print("SE1\n"); break;
    }
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

void ulpi_reset_bus()
{
    int rx_cmd, rx_cmd_changed;
    ulpi_get_rx_cmd(&rx_cmd, &rx_cmd_changed);

    ulpi_print_linestate(rx_cmd);

    ulpi_print_reg(ULPI_FUNC_CTRL_ADDR);
    ulpi_print_reg(ULPI_OTG_CTRL_ADDR);
    ulpi_print_reg(ULPI_SCRATCH_ADDR);

    unsigned int scratch = 0x5A;
    ulpi_reg_wr(ULPI_SCRATCH_ADDR, scratch);
    ulpi_print_reg(ULPI_SCRATCH_ADDR);
    
    unsigned int func_ctrl = ulpi_reg_rd(ULPI_FUNC_CTRL_ADDR);
    func_ctrl   = (func_ctrl & ~0x3);               // Set XcvrSel to 00: HS
    func_ctrl   = (func_ctrl & ~0x4);               // Set TermSel to 0:  HS
    func_ctrl   = (func_ctrl & ~0x18) | 0x10;       // Set OpMode to 10: disable bit-stuff and NRZI encoding
    ulpi_reg_wr(ULPI_FUNC_CTRL_ADDR, func_ctrl);

    ulpi_print_linestate(rx_cmd);
    ulpi_print_reg(ULPI_FUNC_CTRL_ADDR);
}
