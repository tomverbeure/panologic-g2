
#define GPIO_BASE_ADDR              0x0
#define GPIO_READ_ADDR              (GPIO_BASE_ADDR)
#define GPIO_WRITE_ADDR             (GPIO_BASE_ADDR + 4)
#define GPIO_DIR_ADDR               (GPIO_BASE_ADDR + 8)

#define GPIO_BIT_LED_GREEN          0x00000001
#define GPIO_BIT_LED_BLUE           0x00000002
#define GPIO_BIT_LED_RED            0x00000004
#define GPIO_BIT_SWITCH             0x00000008

//https://spinalhdl.github.io/SpinalDoc-RTD/SpinalHDL/Examples/Advanced%20ones/memory_mapped_uart.html?highlight=apb3uartctrl
#define UART_BASE_ADDR              0x100
#define UART_TX_DATA_ADDR           (UART_BASE_ADDR + 0)
#define UART_RX_DATA_ADDR           (UART_BASE_ADDR + 0)
#define UART_STATUS_ADDR            (UART_BASE_ADDR + 4)
#define UART_CLK_DIV_ADDR           (UART_BASE_ADDR + 8)
#define UART_FRAME_ADDR             (UART_BASE_ADDR + 12)

typedef struct {
   int DataLength:8;
   int Parity:2;
      #define PARITY_NONE     0
      #define PARITY_EVEN     1
      #define PARITY_ODD      2
   int Stop:1;
      #define STOP_BITS_1     0
      #define STOP_BITS_2     1
} UartFraming;

#define TEST_PATTERN_NR_ADDR                    0x00000200
#define TEST_PATTERN_CONST_COLOR_ADDR           0x00000204

#define TXT_BUF_ADDR                0x20000

