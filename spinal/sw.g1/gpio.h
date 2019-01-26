#ifndef _GPIO_H_
#define _GPIO_H_
#include "top_defines.h"

#define GPIO_READ_ADDR              (GPIO_BASE_ADDR)
#define GPIO_WRITE_ADDR             (GPIO_BASE_ADDR + 4)
#define GPIO_DIR_ADDR               (GPIO_BASE_ADDR + 8)

#define GPIO_BIT_LED_GREEN          0x00000001
#define GPIO_BIT_LED_BLUE           0x00000002
#define GPIO_BIT_LED_RED            0x00000004
#define GPIO_BIT_SWITCH             0x00000008

#endif   // _GPIO_H_

