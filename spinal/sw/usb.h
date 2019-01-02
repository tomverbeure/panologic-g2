#ifndef USB_H
#define USB_H

void ulpi_wait_reg_done();
int ulpi_reg_rd(int addr);
void ulpi_reg_wr(int addr, int wr_data);
void ulpi_get_vendor_id_product_id(int *vendor_id, int *product_id);

#endif
