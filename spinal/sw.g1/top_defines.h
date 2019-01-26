#ifndef _TOP_DEFINES_H_
#define _TOP_DEFINES_H_

#define IO_BASE_ADDR                0x80000000
#define GPIO_BASE_ADDR              (IO_BASE_ADDR + 0x000000)
#define UART_BASE_ADDR              (IO_BASE_ADDR + 0x000100)
#define TIMER_BASE_ADDR             (IO_BASE_ADDR + 0x000200)
#define USB_BASE_ADDR               (IO_BASE_ADDR + 0x080000)
//#define TXT_BUF_ADDR                (IO_BASE_ADDR + 0x02000200)

#define TEST_PATTERN_NR_ADDR                    0x00000200
#define TEST_PATTERN_CONST_COLOR_ADDR           0x00000204

typedef unsigned char byte;
typedef unsigned short u16;
typedef unsigned int u32;

#endif   // _TOP_DEFINES_H_

