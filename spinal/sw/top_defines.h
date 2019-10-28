
#define LED_READ_ADDR               0x00000000
#define LED_WRITE_ADDR              0x00000004
#define  LED_DIR_ADDR                0x00000008

#define BUTTON_ADDR                 0x00000010

// object CCGpio
// 0x0000 : Direction. 0 -> input, 1 -> output
// 0x0004 : Write
// 0x0008 : Set
// 0x000c : Clear
// 0x0010 : Read
#define CCGPIO_DIR_OFFSET           0
#define CCGPIO_WR_OFFSET            4
#define CCGPIO_SET_OFFSET           8
#define CCGPIO_CLR_OFFSET           0xc
#define CCGPIO_RD_OFFSET            0x10

// val u_dvi_ctrl = CCGpio(2)
#define DVI_CTRL_BASE_ADDR          0x00000100
#define DVI_CTRL_DIR_ADDR           (DVI_CTRL_BASE_ADDR + CCGPIO_DIR_OFFSET)
#define DVI_CTRL_WR_ADDR            (DVI_CTRL_BASE_ADDR + CCGPIO_WR_OFFSET)
#define DVI_CTRL_SET_ADDR           (DVI_CTRL_BASE_ADDR + CCGPIO_SET_OFFSET)
#define DVI_CTRL_CLR_ADDR           (DVI_CTRL_BASE_ADDR + CCGPIO_CLR_OFFSET)
#define DVI_CTRL_RD_ADDR            (DVI_CTRL_BASE_ADDR + CCGPIO_RD_OFFSET)

#define GMII_MDIO_ADDR              0x00010000
#define GMII_MDC_VAL_BIT                0
#define GMII_MDIO_WR_BIT                1
#define GMII_MDIO_ENA_BIT               2
#define GMII_MDIO_RD_BIT                3

#define GMII_RX_FIFO_RD_ADDR        0x00010004
#define GMII_RX_FIFO_RD_PAYLOAD_BIT     0
#define GMII_RX_FIFO_RD_VALID_BIT       16

#define GMII_RX_FIFO_RD_COUNT_ADDR  0x00010008

#define TEST_PATTERN_NR_ADDR                    0x00000200
#define TEST_PATTERN_CONST_COLOR_ADDR           0x00000204

#define TXT_BUF_ADDR                0x00020000

#define ULPI_REG_ACTION_ADDR        0x00000300
#define ULPI_REG_ACTION_ADDR_BIT        0
#define ULPI_REG_ACTION_WR_DATA_BIT     8
#define ULPI_REG_ACTION_WR_BIT          31

#define ULPI_REG_STATUS_ADDR        0x00000304
#define ULPI_REG_STATUS_RD_DATA_BIT     0
#define ULPI_REG_STATUS_PENDING_BIT     8

#define ULPI_RX_CMD_ADDR            0x00000308
#define ULPI_RX_CMD_VALUE_BIT           0
#define ULPI_RX_CMD_CHANGED_BIT         8




