#include <stdint.h>

#include "reg.h"
#include "top_defines.h"
#include "uart.h"
#include "printf.h"

void UartInit()
{
   union {
      UartFraming Framing;
      uint32_t uint32;
   } u;

// baudrate = Fclk / (rxSamplePerBit*clockDividerWidth)

// Core clock = 25 Mhz, bits / baud = 8, baudrate = 115200
// div = 27.13
   REG_WR(UART_CLK_DIV,27);

// NB: apparently there's a bug in Spinal 1.2.2's Uart, we really get 7 data
// bits...
   u.Framing.DataLength = 6;  

   u.Framing.Parity = PARITY_NONE;
   u.Framing.Stop = 0;

   REG_WR(UART_FRAME,u.uint32);
}

void _putchar(char c)
{
   while ((REG_RD(UART_STATUS) & 0x00FF0000) == 0);
   REG_WR(UART_TX_DATA,c);
}

