#include <stdint.h>
#include <math.h>

#include "reg.h"
#include "top_defines.h"
#include "print.h"

static inline uint32_t rdcycle(void) {
    uint32_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

static inline int nop(void) {
    asm volatile ("addi x0, x0, 0");
    return 0;
}

static void wait(int cycles)
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

void gmii_mdio_init()
{
    // Initial values
    REG_WR(GMII_MDIO,     (1<<GMII_MDC_VAL_BIT) 
                        | (0<<GMII_MDIO_ENA_BIT)            // MDIO starts out tri-state
                        | (1<<GMII_MDIO_WR_BIT) 
        );
}

#define MII_HALF_BIT_WAIT  1

#define GMII_MDC_SET()      (REG_WR(GMII_MDIO, REG_RD(GMII_MDIO) |  (1<<GMII_MDC_VAL_BIT)))
#define GMII_MDC_CLR()      (REG_WR(GMII_MDIO, REG_RD(GMII_MDIO) & ~(1<<GMII_MDC_VAL_BIT)))

#define GMII_MDIO_ENA()     (REG_WR(GMII_MDIO, REG_RD(GMII_MDIO) |  (1<<GMII_MDIO_ENA_BIT)))
#define GMII_MDIO_DIS()     (REG_WR(GMII_MDIO, REG_RD(GMII_MDIO) & ~(1<<GMII_MDIO_ENA_BIT)))

#define GMII_MDIO_SET()     (REG_WR(GMII_MDIO, REG_RD(GMII_MDIO) |  (1<<GMII_MDIO_WR_BIT)))
#define GMII_MDIO_CLR()     (REG_WR(GMII_MDIO, REG_RD(GMII_MDIO) & ~(1<<GMII_MDIO_WR_BIT)))

#define GMII_MDIO_RD()      ((REG_RD(GMII_MDIO) >> GMII_MDIO_RD_BIT) & 1)

void gmii_mdc_toggle()
{
    wait(MII_HALF_BIT_WAIT);
    GMII_MDC_SET();
    wait(MII_HALF_BIT_WAIT);
    GMII_MDC_CLR();
}

int gmii_mdio_rd(int phy_addr, int reg_addr)
{
    for(int i=0;i<32;++i){
        gmii_mdc_toggle();
    }

    GMII_MDIO_SET();

    unsigned word =   (1 << 12)                     // Start bits
                    | (2 << 10)                     // Read
                    | ((phy_addr & 0x1f) << 5)
                    | ((reg_addr & 0x1f) << 0);

    for(int i=13; i >= 0; --i){
        int bit = (word >> i) & 1;

        if (bit) GMII_MDIO_SET();
        else     GMII_MDIO_CLR();

        gmii_mdc_toggle();
    }

    int ta = 0;
    int rdata = 0;

    GMII_MDIO_DIS();
    gmii_mdc_toggle();

    ta = GMII_MDIO_RD();
    gmii_mdc_toggle();
    ta = (ta<<1) | GMII_MDIO_RD();

    for(int i=15;i>=0;--i){
        rdata = (rdata<<1) | GMII_MDIO_RD();
        gmii_mdc_toggle();
    }

    return rdata;
}


void gmii_phy_identifier(int phy_addr, uint32_t *oui, uint32_t *model_nr, uint32_t *rev_nr)
{
    int rdata2 = gmii_mdio_rd(phy_addr, 2);
    int rdata3 = gmii_mdio_rd(phy_addr, 3);

    *oui      = (((rdata3 >> 10) & ((1<<6)-1))<< 0) | (rdata2 << 6);

    *model_nr = (rdata3 >> 4) & ((1<<6)-1);
    *rev_nr   = (rdata3 >> 0) & ((1<<4)-1);
}

void gmii_reg_dump(int phy_addr)
{
    int rdata;

    rdata = gmii_mdio_rd(phy_addr, 0);
    print("Reg  0: Control               : "); print_int(rdata, 1); print("\n");

    rdata = gmii_mdio_rd(phy_addr, 1);
    print("Reg  1: Status                : "); print_int(rdata, 1); print("\n");

    rdata = gmii_mdio_rd(phy_addr, 2);
    print("Reg  2: PHY ID                : "); print_int(rdata, 1); print("\n");

    rdata = gmii_mdio_rd(phy_addr, 3);
    print("Reg  3: PHY ID                : "); print_int(rdata, 1); print("\n");

    rdata = gmii_mdio_rd(phy_addr, 4);
    print("Reg  4: Auto-Neg Advertisement: "); print_int(rdata, 1); print("\n");

    rdata = gmii_mdio_rd(phy_addr, 5);
    print("Reg  5: Link Partner Ability  : "); print_int(rdata, 1); print("\n");

    rdata = gmii_mdio_rd(phy_addr, 6);
    print("Reg  6: Auto-Neg Expansion    : "); print_int(rdata, 1); print("\n");

    rdata = gmii_mdio_rd(phy_addr, 16);
    print("Reg 16: PHY Specific Control  : "); print_int(rdata, 1); print("\n");

    rdata = gmii_mdio_rd(phy_addr, 17);
    print("Reg 17: PHY Specific Status   : "); print_int(rdata, 1); print("\n");
}

void gmii_wait_auto_neg_complete(int phy_addr)
{
    int rdata;

    do{
        rdata = gmii_mdio_rd(phy_addr, 1);
    } while(!(rdata & (1<<5)));
}

void gmii_print_phy_id(int phy_addr)
{
    uint32_t oui, model_nr, rev_nr;

    gmii_phy_identifier(phy_addr, &oui, &model_nr, &rev_nr);
    print("oui      :");
    print_int(oui, 1);
    print("\n");
    print("model_nr :");
    print_int(model_nr, 1);
    print("\n");
    print("rev_nr   :");
    print_int(rev_nr, 1);
    print("\n");
}

void gmii_monitor_regs(int phy_addr)
{
    int prev_rdata = gmii_mdio_rd(phy_addr, 17);
    while(1){
        int rdata = gmii_mdio_rd(phy_addr, 17);

        if (rdata != prev_rdata){
            gmii_reg_dump(phy_addr);
            prev_rdata = rdata;
        }
    }
}

void gmii_dump_packets()
{
    int had_data = 0;

    while(1){
        unsigned int rx_data = REG_RD(GMII_RX_FIFO_RD);
        if ((rx_data>>16) == 0){
            if (had_data){
                print_int(had_data, 1);
                print("\n\n");
            }
            had_data = 0;
            continue;
        }

        if (!had_data){
            print(".");
        }

        had_data += 1;

//        print_byte(rx_data>>8, 1);
//        print(" ");
        print_byte(rx_data, 1);
        print(",");
    }
}

