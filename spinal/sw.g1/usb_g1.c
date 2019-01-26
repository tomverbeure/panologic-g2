#include <stdbool.h>
#include "usb_g1.h"
#include "global.h"
#include "reg.h"
#include "isp1760-regs.h"
#include "print.h"

#define RW_TEST_VALUE   0x5555aaaa

static u32 isp1760_read32(u32 reg);
static void isp1760_write32(u32 reg,u32 Value);

static u32 isp1760_read32(u32 reg)
{
   uint16_t Lsb;
   uint16_t Msb;

   Lsb = REG16_RD(USB_BASE_ADDR + (reg * 2));
   Msb = REG16_RD(USB_BASE_ADDR + (reg * 2) + 4);

   return Lsb + (Msb << 16);
}

static void isp1760_write32(u32 reg,u32 Value)
{
   REG16_WR(USB_BASE_ADDR + (reg * 2),(u16) (Value & 0xffff));
   REG16_WR(USB_BASE_ADDR + (reg  * 2) + 4,(u16) ((Value >> 16) & 0xffff));
}

void UsbInit()
{
// Select 16 bit mode
   isp1760_write32(HC_HW_MODE_CTRL,0);
// The first access may have set ALL_ATX_RESET because the top half of the
// 32 bit data bus i spulled up per the spec sheet.
   isp1760_write32(HC_HW_MODE_CTRL,0);
}

// Return 1 if USB controller is detected
bool UsbProbe(void)
{
   bool Ret = false;  // Assume the worse
   static int Toggle = 0;
   u32 Value;
   int i;

   do {
      isp1760_write32(HC_SCRATCH_REG,RW_TEST_VALUE);
      Value = isp1760_read32(HC_CHIP_ID_REG);
      print("HC_CHIP_ID_REG: ");
      print_int(Value,1);
      print("\n");

      for(i = 0; i < 10; i += 4) {
         Value = isp1760_read32(i);
         print_int(i,1);
         print(": ");
         print_int(Value,1);
         print("\n");
      }

      Value = isp1760_read32(HC_SCRATCH_REG);
      print("HC_SCRATCH_REG: ");
      print_int(Value,1);
      if(Value == RW_TEST_VALUE) {
         print(" (correct!) ");
      }
      print("\n");

      isp1760_write32(HC_SCRATCH_REG,~RW_TEST_VALUE);

      Value = isp1760_read32(HC_SCRATCH_REG);
      print("HC_SCRATCH_REG: ");
      print_int(Value,1);
      if(Value == ~RW_TEST_VALUE) {
         print(" (correct!) ");
      }
      print("\n");
#if 0
      if((isp1760_read32(HC_CHIP_ID_REG) & 0xffff) != 0x1761) {
         break;
      }
      if(isp1760_read32(HC_SCRATCH_REG) != RW_TEST_VALUE) {
         break;
      }

      isp1760_write32(HC_SCRATCH_REG,~RW_TEST_VALUE);

      if(isp1760_read32(HC_SCRATCH_REG) != ~RW_TEST_VALUE) {
         break;
      }
      Ret = true;

      Toggle = Toggle ? 0 : 1;
      REG_WR(LED_CONFIG_ADR,Toggle);
#endif

   } while(false);

   return Ret;
}


