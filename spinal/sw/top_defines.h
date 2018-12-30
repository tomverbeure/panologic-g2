
#define LED_READ_ADDR               0x00000000
#define LED_WRITE_ADDR              0x00000004
#define	LED_DIR_ADDR                0x00000008

#define BUTTON_ADDR                 0x00000010

#define DVI_CTRL_DIR_ADDR           0x00000100
#define DVI_CTRL_WR_ADDR            0x00000104
#define DVI_CTRL_SET_ADDR           0x00000108
#define DVI_CTRL_CLR_ADDR           0x0000010c
#define DVI_CTRL_RD_ADDR            0x00000110

#define GMII_MDIO_ADDR              0x00010000

#define GMII_MDC_VAL_BIT         0
#define GMII_MDIO_WR_BIT         1
#define GMII_MDIO_ENA_BIT        2
#define GMII_MDIO_RD_BIT         3

#define GMII_RX_FIFO_RD_ADDR        0x00010004
#define GMII_RX_FIFO_RD_COUNT_ADDR  0x00010008

#define TEST_PATTERN_NR_ADDR                    0x00000200
#define TEST_PATTERN_CONST_COLOR_ADDR           0x00000204

#define TXT_BUF_ADDR                0x00020000

#define ULPI_REG_ACTION_ADDR        0x00000300
#define ULPI_REG_STATUS_ADDR        0x00000304
