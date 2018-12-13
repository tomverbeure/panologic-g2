
#include <stdint.h>

#include "reg.h"
#include "top_defines.h"

int cur_x = 0;
int cur_y = 0;

#define TXT_BUF ((volatile uint32_t *)(0x00080000 | TXT_BUF_ADDR))
int txt_buf_width         = 80;
int txt_buf_height        = 25;

int txt_buf_active_width  = 50;
int txt_buf_active_height = 10;

void clear()
{
    for(int l=0;l<txt_buf_active_height;++l){
        for(int c=0;c<txt_buf_active_width;++c){
            TXT_BUF[l * txt_buf_width + c] = 32;
        }
    }
}

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

void print(char *str)
{
    while(*str != '\0'){
        if (*str == '\n'){
            next_line();

            ++str;
            continue;
        }
        TXT_BUF[cur_y * txt_buf_width + cur_x] = *str;
        ++str;

        ++cur_x;
        if (cur_x >= txt_buf_active_width){
            next_line();
        }
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

void print_int(int value, int hex)
{
    char buf[16] = "\0";
    if (hex) {
        for(int i=7;i>=0;--i){
            buf[7-i] = hex_digits[((value >> (i*4))&0xf)];
        }
        buf[8] = '\0';
    }

    print(buf);
}


