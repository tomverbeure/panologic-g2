#ifndef _UART_H_
#define _UART_H_
#include "top_defines.h"

#define UART_TX_DATA          (UART_BASE_ADDR + 0)
#define UART_RX_DATA          (UART_BASE_ADDR + 0)
#define UART_STATUS           (UART_BASE_ADDR + 4)
#define UART_CLK_DIV          (UART_BASE_ADDR + 8)
#define UART_FRAME            (UART_BASE_ADDR + 0xc)

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

void UartInit(void);
void UartPutch(char c);

#endif   // _UART_H_

