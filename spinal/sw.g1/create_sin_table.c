
#include <stdint.h>
#include <math.h>
#include <stdio.h>

typedef uint32_t fpxx_t;

fpxx_t float_to_fpxx(float f)
{
    union {
        float       f;
        uint32_t    i;
    } fi;

    fi.f = f;


    uint32_t sign = fi.i>>31;
    int32_t exp  = (fi.i>>23) & 0xff;
    uint32_t mant = fi.i & ((1<<23)-1);

    float pow_exp = pow(2, (exp-127));
    exp  = (exp == 0) ? 0 : exp-127+((1<<(6-1))-1);
    mant = mant >> (23-13);

    uint32_t result = (sign<<(6+13)) | (exp<<13) | mant;

    return result;
}

int main()
{
    printf("\n\nconst uint32_t fpxx_sin_table[256] = {\n");

    for(int i=0;i<256;++i){
        float f = sin(i/1024.0*2*M_PI);
        fpxx_t result = float_to_fpxx(f);
        printf("    0x%08x", result);
        if (i!=255) printf(",");
        printf("\n");
    }
    printf("};\n");

    return 0;
}
