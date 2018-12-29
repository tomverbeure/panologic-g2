#ifndef GMII_H
#define GMII_H

void gmii_mdio_init();
void gmii_mdc_toggle();
int gmii_mdio_rd(int phy_addr, int reg_addr);
void gmii_phy_identifier(int phy_addr, uint32_t *oui, uint32_t *model_nr, uint32_t *rev_nr);
void gmii_reg_dump(int phy_addr);
void gmii_wait_auto_neg_complete(int phy_addr);
void gmii_print_phy_id(int phy_addr);
void gmii_monitor_regs(int phy_addr);
void gmii_dump_packets();

#endif
