#include <stdint.h>
#include <math.h>
#include <stdbool.h>

#include "reg.h"
#include "top_defines.h"
#include "gpio.h"
#include "print.h"
#ifdef PRINT_UART
#include "uart.h"
#endif
#include "usb_g1.h"

static inline uint32_t rdcycle(void) {
    uint32_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

static inline int nop(void) {
    asm volatile ("addi x0, x0, 0");
    return 0;
}

void wait(int cycles)
{
#if 1
    volatile int cnt = 0;

    for(int i=0;i<cycles;++i){
        ++cnt;
    }
#else
    int start;

    start = rdcycle();
    while ((rdcycle() - start) <= cycles);
#endif
}

// 422 millisecond delay
#define WAIT_CYCLES 500000

int button_pressed()
{
    return (REG_RD(GPIO_READ_ADDR) & GPIO_BIT_SWITCH) == GPIO_BIT_SWITCH;
}

int main() 
{
   REG_WR(GPIO_DIR_ADDR, 0xff);
   UartInit();
    clear();
    print("Pano Logic G1 Reverse Engineering\n");
    print("---------------------------------\n");
    print("\n");
    print("\n");
    print("Code at github.com/tomverbeure/panologic-g2\n");

    UsbInit();

 // Turn off all LEDS
    REG_WR(GPIO_WRITE_ADDR, GPIO_BIT_LED_GREEN | GPIO_BIT_LED_BLUE | GPIO_BIT_LED_RED);

//    UsbProbe();
    UsbTest();

    while(1){
       uint32_t Leds;
        if(button_pressed()){
        // Flash Green LED when button is pressed
            Leds = REG_RD(GPIO_READ_ADDR);
            Leds &= ~GPIO_BIT_LED_GREEN;
            REG_WR(GPIO_WRITE_ADDR,Leds);
            wait(WAIT_CYCLES);
            Leds |= GPIO_BIT_LED_GREEN;
            REG_WR(GPIO_WRITE_ADDR,Leds);
            wait(WAIT_CYCLES);
        // and send a character to the uart
            print("This is yea another test\n");
//            REG_WR(UART_TX_DATA,'a');

        }
    }
}
