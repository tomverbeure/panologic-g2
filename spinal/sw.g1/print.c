
#include <stdint.h>

#include "reg.h"
#include "top_defines.h"
void _putchar(char character);


#ifdef PRINT_UART
#include "uart.h"
#else
int cur_x = 0;
int cur_y = 0;

#define TXT_BUF ((volatile uint32_t *)(0x80000000 | TXT_BUF_ADDR))
int txt_buf_width         = 130;
int txt_buf_height        = 60;

int txt_buf_active_width  = 130;
int txt_buf_active_height = 60;
#endif

void clear()
{
#ifndef PRINT_UART
    for(int l=0;l<txt_buf_active_height;++l){
        for(int c=0;c<txt_buf_active_width;++c){
            TXT_BUF[l * txt_buf_width + c] = 32;
        }
    }
#endif
}

#ifndef PRINT_UART
void scroll()
{
    for(int l=0;l<txt_buf_active_height;++l){
        for(int c=0;c<txt_buf_active_width;++c){
            TXT_BUF[l * txt_buf_width + c] = (l==txt_buf_active_height-1) ? ' ' : TXT_BUF[(l+1)*txt_buf_width + c];
        }
    }
}

void next_line()
{
    cur_x = 0;
    ++cur_y;
    if (cur_y >= txt_buf_active_height){
        scroll();
        cur_y = txt_buf_active_height-1;
    }
}

void _putchar(char c)
{
   if (c == '\n'){
       next_line();
   }
   else {
      TXT_BUF[cur_y * txt_buf_width + cur_x] = c;

      ++cur_x;
      if (cur_x >= txt_buf_active_width){
          next_line();
      }
   }
}
#endif

void print(const char *str)
{
    while(*str != '\0'){
       _putchar(*str++);
    }
}

char hex_digits[] = "0123456789abcdef";

void print_byte(unsigned char value, int hex)
{
    char buf[16] = "\0";
    if (hex) {
        for(int i=1;i>=0;--i){
            buf[1-i] = hex_digits[((value >> (i*4))&0xf)];
        }
        buf[8] = '\0';
    }

    print(buf);
}

void print_int(int value, int Flags)
{
    char buf[16] = "\0";
    char *cp = buf;

    if (Flags & 1) {
        for(int i=7;i>=0;--i){
            buf[7-i] = hex_digits[((value >> (i*4))&0xf)];
        }
        buf[8] = '\0';
    }

    if(Flags & 2) {
    // Supress leading zeros
       while(*cp == '0') {
          cp++;
       }
       if(*cp == 0) {
       // All zeros, display one
          cp--;
       }
    }

    print(cp);
}


