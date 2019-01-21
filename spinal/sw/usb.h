#ifndef USB_H
#define USB_H

void ulpi_wait_reg_done();
int ulpi_reg_rd(int addr);
void ulpi_reg_wr(int addr, int wr_data);
void ulpi_get_rx_cmd(int *rx_cmd, int *rx_cmd_changed);
void ulpi_get_vendor_id_product_id(int *vendor_id, int *product_id);
void ulpi_print_id();
void ulpi_monitor_rx_cmd();
void ulpi_reset_bus();

#endif
