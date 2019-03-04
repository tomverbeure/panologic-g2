/* 
 
Code in this file is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

Code in this file is derived and/or copied from many sources including:
 
GPL:
Copyright (C) 2011 Circuits At Home, LTD. All rights reserved.
http://www.circuitsathome.com 
 
Linux driver for the NXP ISP1760 chip
Copyright 2014 Laurent Pinchart
Copyright 2007 Sebastian Siewior 
 
This is a very minimal USB host driver with specific goals and limitations. 
 
Goals in priority order
1. Provide USB game controller support for vintage games. 
2. Provide mass storage support for loading programs and games.
3. Provide keyboard support for development and vintage computing. 
 
Limitations: 
1. Only support up to 3 USB perpherials connected DIRECTLY to one of 
the 3 USB ports on the Pano.  Code is much simplifed by limiting the number 
of devices as well as eliminating the need for general USB HUB support. 
 
2. Game controller support will be limited to a few specific devices, no 
attempt will be made to parse the HID decsciptors. 
 
3. Keyboard support will be limited to keyboards that support the opional boot 
mode. 
 
4. Hot pulling of USB devices is not supported to simplify the logic.
*/
 
#include <stdbool.h>
#include <string.h>
#include "usb_g1.h"
#include "global.h"
#include "reg.h"
#include "isp1760-regs.h"
#include "print.h"
#include "usb_ch9.h"
#include "gpio.h"
#include "usbhub.h"
#include "printf.h"

#define LOG(format, ...) printf("%s: " format,__FUNCTION__ ,## __VA_ARGS__)
#define LOG_RAW(format, ...) printf(format,## __VA_ARGS__)

#define WAIT_CYCLES_1MS    1184

#define RW_TEST_VALUE   0x5555aaaa
#define INT_REG_RESERVED_BITS 0xfffffc15

// Support a maximum of 5 devices (root hub, built in external hub, 3 external
// devices
#define MAX_USB_DEVICES    5

#define ROOT_HUB_ADR       1     // hub built into the isp1760
#define EXTERNAL_HUB_ADR   2     // Pano's built in hub

#ifdef __GNUC__
#define GCC_PACKED __attribute__ ((packed))
#else
#define GCC_PACKED
#endif

/* Common setup data constant combinations  */
#define bmREQ_GET_DESCR     USB_SETUP_DEVICE_TO_HOST | USB_SETUP_TYPE_STANDARD | USB_SETUP_RECIPIENT_DEVICE     //get descriptor request type
#define bmREQ_SET           USB_SETUP_HOST_TO_DEVICE | USB_SETUP_TYPE_STANDARD | USB_SETUP_RECIPIENT_DEVICE     //set request type for all but 'set feature' and 'set interface'
#define bmREQ_CL_GET_INTF   USB_SETUP_DEVICE_TO_HOST | USB_SETUP_TYPE_CLASS | USB_SETUP_RECIPIENT_INTERFACE     //get interface request type

/* USB Setup Packet Structure   */
typedef struct {
   union {
// byte 0: Bit-map of request type
      uint8_t bmRequestType;  
      struct {
         uint8_t recipient : 5;  // Recipient of the request
         uint8_t type : 2;       // Type of request
         uint8_t direction : 1;  // Direction of data X-fer
      } GCC_PACKED;
   } ReqType_u;

// byte 1: Request
   uint8_t bRequest;          

// bytes 2,3
   union {
      uint16_t wValue;        
      struct {
         uint8_t wValueLo;
         uint8_t wValueHi;
      } GCC_PACKED;
   } wVal_u;

// bytes 4,5
   uint16_t wIndex;           
// bytes 6,7
   uint16_t wLength;
} GCC_PACKED SetupPkt;


// 
#define USB_SPEED_LOW      0
#define USB_SPEED_USB11    1  // 12 Mb
#define USB_SPEED_HIGH     2  // 480 Mb

typedef struct {
   uint16_t CtrlOutBuf;
   uint16_t CtrlInBuf;
   uint8_t TTPort;
   uint8_t HubDevnum;
   uint8_t bDeviceClass;      // Class code (assigned by the USB-IF). 0xFF-Vendor specific.
   uint8_t bDeviceSubClass;   // Subclass code (assigned by the USB-IF).
   uint16_t bMaxPacketSize0;
   uint32_t UsbSpeed:2;
   uint32_t Toggle:1;
   uint32_t Ping:1;
   uint32_t Present:1;        // This device is present
} GCC_PACKED PanoUsbDevice;

// Indexed by USB address
PanoUsbDevice gUsbDevice[MAX_USB_DEVICES + 1];

/* Philips Proprietary Transfer Descriptor (PTD) */
struct ptd {
   u32 dw0;
   u32 dw1;
   u32 dw2;
   u32 dw3;
   u32 dw4;
   u32 dw5;
   u32 dw6;
   u32 dw7;
};

#define PTD_OFFSET         0x0400
#define ISO_PTD_OFFSET     0x0400
#define INT_PTD_OFFSET     0x0800
#define ATL_PTD_OFFSET     0x0c00
#define PAYLOAD_OFFSET     0x1000

#define USB_TOKEN_OUT      0
#define USB_TOKEN_IN       1
#define USB_TOKEN_SETUP    2
#define USB_TOKEN_PING     3
/* ATL */
/* DW0 */
#define DW0_VALID_BIT         1
#define FROM_DW0_VALID(x)     ((x) & 0x01)
#define TO_DW0_LENGTH(x)      (((u32) x) << 3)
#define TO_DW0_MAXPACKET(x)      (((u32) x) << 18)
#define TO_DW0_MULTI(x)       (((u32) x) << 29)
#define TO_DW0_ENDPOINT(x)    (((u32)  x) << 31)
/* DW1 */
#define TO_DW1_DEVICE_ADDR(x)    (((u32) x) << 3)
#define TO_DW1_PID_TOKEN(x)      (((u32) x) << 10)
#define DW1_TRANS_BULK        ((u32) 2 << 12)
#define DW1_TRANS_INT         ((u32) 3 << 12)
#define DW1_TRANS_SPLIT       ((u32) 1 << 14)
#define DW1_SE_USB_LOSPEED    ((u32) 2 << 16)
#define TO_DW1_PORT_NUM(x)    (((u32) x) << 18)
#define TO_DW1_HUB_NUM(x)     (((u32) x) << 25)
/* DW2 */
#define TO_DW2_DATA_START_ADDR(x)   (((u32) x) << 8)
#define TO_DW2_RL(x)       ((x) << 25)
#define FROM_DW2_RL(x)        (((x) >> 25) & 0xf)
/* DW3 */
#define FROM_DW3_NRBYTESTRANSFERRED(x)    ((x) & 0x7fff)
#define FROM_DW3_SCS_NRBYTESTRANSFERRED(x)   ((x) & 0x07ff)
#define TO_DW3_NAKCOUNT(x)    ((x) << 19)
#define FROM_DW3_NAKCOUNT(x)     (((x) >> 19) & 0xf)
#define TO_DW3_CERR(x)        ((x) << 23)
#define FROM_DW3_CERR(x)      (((x) >> 23) & 0x3)
#define TO_DW3_DATA_TOGGLE(x)    ((x) << 25)
#define FROM_DW3_DATA_TOGGLE(x)     (((x) >> 25) & 0x1)
#define TO_DW3_PING(x)        ((x) << 26)
#define FROM_DW3_PING(x)      (((x) >> 26) & 0x1)
#define DW3_ERROR_BIT         (1 << 28)
#define DW3_BABBLE_BIT        (1 << 29)
#define DW3_HALT_BIT       (1 << 30)
#define DW3_ACTIVE_BIT        (1 << 31)
#define FROM_DW3_ACTIVE(x)    (((x) >> 31) & 0x01)

#define INT_UNDERRUN       (1 << 2)
#define INT_BABBLE         (1 << 1)
#define INT_EXACT       (1 << 0)

#define SETUP_PID (2)
#define IN_PID    (1)
#define OUT_PID      (0)

/* Errata 1 */
#define RL_COUNTER   (0)
#define NAK_COUNTER  (0)
#define ERR_COUNTER  (2)

#if 0
struct isp1760_qtd {
   u8 packet_type;
   void *data_buffer;
   u32 payload_addr;

   /* the rest is HCD-private */
   struct list_head qtd_list;
   struct urb *urb;
   size_t length;
   size_t actual_length;

   /* QTD_ENQUEUED:  waiting for transfer (inactive) */
   /* QTD_PAYLOAD_ALLOC:   chip mem has been allocated for payload */
   /* QTD_XFER_STARTED: valid ptd has been written to isp176x - only
            interrupt handler may touch this qtd! */
   /* QTD_XFER_COMPLETE:   payload has been transferred successfully */
   /* QTD_RETIRE:    transfer error/abort qtd */
#define QTD_ENQUEUED    0
#define QTD_PAYLOAD_ALLOC  1
#define QTD_XFER_STARTED   2
#define QTD_XFER_COMPLETE  3
#define QTD_RETIRE      4
   u32 status;
};

/* Queue head, one for each active endpoint */
struct isp1760_qh {
   struct list_head qh_list;
   struct list_head qtd_list;
   u32 toggle;
   u32 ping;
   int slot;
   int tt_buffer_dirty; /* See USB2.0 spec section 11.17.5 */
};

/* magic numbers that can affect system performance */
#define  EHCI_TUNE_CERR    3  /* 0-3 qtd retries; 0 == don't stop */
#define  EHCI_TUNE_RL_HS      4  /* nak throttle; see 4.9 */
#define  EHCI_TUNE_RL_TT      0
#define  EHCI_TUNE_MULT_HS 1  /* 1-3 transactions/uframe; 4.10.3 */
#define  EHCI_TUNE_MULT_TT 1
#define  EHCI_TUNE_FLS     2  /* (small) 256 frame schedule */

#endif
static u32 isp1760_read32(u32 reg);
static void isp1760_write32(u32 reg,u32 Value);
static void isp1760_bits(u32 reg,u32 Sets,u32 Resets);

void UsbTest(void);
void print_1cr(const char *label,int value);
void DumpPtd(const char *msg,u32 *p);
void Dump1760Mem(void);
void InitTest(void);
int _DoTransfer(u32 *ptd,const char *Func,int Line);
#define DoTransfer(x)  _DoTransfer(x,__FUNCTION__,__LINE__)

int SetConfiguration(uint8_t Adr,uint8_t Configuration);
int SetHubFeature(uint16_t Adr,uint8_t bmRequestType,uint8_t bRequest,uint16_t wIndex);
int ClearHubFeature(uint8_t Adr,uint8_t bmRequestType,uint8_t bRequest,uint16_t wIndex);
int DumpPortStatus(uint16_t Port,uint32_t Status);
int GetPortStatus(uint8_t Adr,uint16_t Port,uint32_t *pStatus);
int GetHubDesc(uint16_t Adr);
void InitPtd(u32 *Ptd,uint8_t Adr,uint8_t Token,u16 PayLoadAdr,int Len);
int SetupTransaction(uint8_t Adr,SetupPkt *p,int8_t *pResponse,int ResponseLen);
int GetDevDesc(uint8_t Adr);
int SetUsbAddress(uint8_t Adr);
u32 base_to_chip(u32 base);

void msleep(int ms)
{
    volatile int cnt = 0;
    int i;
    int cycles = ms * WAIT_CYCLES_1MS;

    for(i = 0; i < cycles; ++i) {
        ++cnt;
    }
}

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

/*
 * Access functions for isp176x memory
 */
static void mem_reads8(u32 src, u32 *dst, u32 bytes)
{
   u32 val;
   if(src >= PTD_OFFSET) {
      isp1760_write32(HC_MEMORY_REG,src);
   }
   while(bytes >= 4) {
      *dst++ = isp1760_read32(src);
      bytes -= 4;
      src += 4;
   }

   if(bytes > 0) {
   // Handle remaining bytes
      unsigned char *src_byteptr = (unsigned char *) &val;
      unsigned char *dst_byteptr = (unsigned char *) dst;
      val = isp1760_read32(src);
      while(bytes-- > 0) {
         *dst_byteptr++ = *src_byteptr++;
      }
   }
}

static void mem_writes8(u32 dst,u32 *src, u32 bytes)
{
   while (bytes >= 4) {
      isp1760_write32(dst,*src++);
      bytes -= 4;
      dst += 4;
   }

   if(bytes > 0) {
   // Handle remaining bytes
      u32 val = 0;
      unsigned char *src_byteptr = (unsigned char *) src;
      unsigned char *dst_byteptr = (unsigned char *) &val;
      while(bytes-- > 0) {
         *dst_byteptr++ = *src_byteptr++;
      }
      isp1760_write32(dst,val);
   }
}

/*
 * Read and write ptds. 'ptd_offset' should be one of ISO_PTD_OFFSET,
 * INT_PTD_OFFSET, and ATL_PTD_OFFSET. 'slot' should be less than 32.
 */
static void ptd_read(u32 ptd_offset, u32 slot,struct ptd *ptd)
{
   mem_reads8(ptd_offset + slot*sizeof(*ptd),(u32 *) ptd, sizeof(*ptd));
}

static void ptd_write(u32 ptd_offset, u32 slot,struct ptd *ptd)
{
   mem_writes8(ptd_offset + slot*sizeof(*ptd) + sizeof(ptd->dw0),
                  &ptd->dw1, 7*sizeof(ptd->dw1));
   /* Make sure dw0 gets written last (after other dw's and after payload)
      since it contains the enable bit */
   mem_writes8(ptd_offset + slot*sizeof(*ptd), &ptd->dw0,sizeof(ptd->dw0));
}

static void isp1760_bits(u32 reg,u32 Sets,u32 Resets)
{
   u32 Value = isp1760_read32(reg);
   Value |= Sets;
   Value &= ~Resets;
   isp1760_write32(reg,Value);
}


void UsbInit()
{
   int i;
   InitTest();
// clear the memory 
   for(i = 0; i < 16128; i++) {
      isp1760_write32(0x400 + (i * 4),0);
   }
   return;

// Select 16 bit mode
   isp1760_write32(HC_HW_MODE_CTRL,ALL_ATX_RESET);
   msleep(15);
   isp1760_write32(HC_HW_MODE_CTRL,0);
   isp1760_write32(HC_HW_MODE_CTRL,0);
}

#if 0
// Return 1 if USB controller is detected
bool UsbProbe(void)
{
   bool Ret = false;  // Assume the worse
   u32 Value;
   const char *Err = NULL;
   u32 i;

   do {
      isp1760_write32(HC_SCRATCH_REG,RW_TEST_VALUE);
      Value = isp1760_read32(HC_CHIP_ID_REG);
      if(Value != 0x11761) {
         Err = "HC_CHIP_ID_REG";
         break;
      }
      Value = isp1760_read32(HC_SCRATCH_REG);
      if(Value != RW_TEST_VALUE) {
         Err = "HC_SCRATCH_REG";
         break;
      }
      isp1760_write32(HC_SCRATCH_REG,~RW_TEST_VALUE);
      Value = isp1760_read32(HC_SCRATCH_REG);
      if(Value != (u32) ~RW_TEST_VALUE) {
         Err = "HC_SCRATCH_REG #2";
         break;
      }
      print("Memory test\n");
      for(i = 0; i < 16128; i++) {
         isp1760_write32(0x400 + (i * 4),i);
      }

      isp1760_write32(HC_MEMORY_REG,0x400);
      for(i = 0; i < 16128; i++) {
         Value = isp1760_read32(0x400);
         if(Value != i) {
            print_int(i,1);

            Err = "\nMemory test";
            break;
         }
      }

      if(i == 16128) {
         print("\npassed\n");
      }
      for(i = 0; i < 16128; i++) {
         isp1760_write32(0x400 + (i * 4),0);
      }

      Ret = true;
      UsbRegDump();
   } while(false);

   if(Err != NULL) {
      print(Err);
      print(" failed, read ");
      print_int(Value,1);
      print("\n");
   }

   return Ret;
}
#endif

void UsbRegDump()
{
   const uint16_t Regs[] = {
      0x0,0x8,
      0x20,0x2c,
      0x60,0x64,
      0x130,0x138,
      0x140,0x148,
      0x150,0x158,
      0x300,0x32c,
      0x334,0x344,
      0x354,0x354,
      0x374,0x374,
      1        // end of table
   };
   int i;
   int j;
   u32 Value;

   LOG("isp1760 regs:\n");
   for(i = 0; Regs[i] != 1; i += 2) {
      for(j = Regs[i]; j <= Regs[i+1]; j += 4) {
         Value = isp1760_read32(j);
         LOG("%x: 0x%x\n",j,Value);
      }
   }
}


void UsbTest()
{
   int i;
   uint32_t PortStatus;
#if 0
   u32 Value;
// Reset
   print("Reseting isp1760...");
//   isp1760_write32(HC_RESET_REG,SW_RESET_RESET_HC | SW_RESET_RESET_ALL);
//   isp1760_write32(HC_RESET_REG,SW_RESET_RESET_HC);
// Wait for reset to complete
   msleep(50);
   for( ; ; ) {
      Value = isp1760_read32(HC_RESET_REG);
      if((Value & SW_RESET_RESET_HC) == 0) {
         break;
      }
   }

   // isp1760_write32(HC_HW_MODE_CTRL,0);
   UsbInit();  // Back to 16 bit bus mode & ATX reset

// Enable port 1
   isp1760_bits(HC_PORT1_CTRL,PORT1_POWER | PORT1_INIT2 | PORT1_INIT1 ,0);
//    isp1760_write32(HC_PORT1_CTRL,0x80018);  // note 1 following table 54

// Reset host controller
   isp1760_write32(HC_USBCMD,CMD_RESET);

#if 0
   print("\nSet FLAG_CF\n");
   isp1760_write32(HC_CONFIGFLAG,FLAG_CF);   // Set configure flag
#endif

// clear the PTD memory region
   for(i = PTD_OFFSET; i < PAYLOAD_OFFSET; i += 4) {
      isp1760_write32(i,0);
   }

   print("Reset root hub...");
   isp1760_write32(HC_PORTSC1,PORT_POWER);
   isp1760_write32(HC_PORTSC1,PORT_RESET | PORT_POWER);
   msleep(50);
   isp1760_write32(HC_PORTSC1,PORT_POWER);

// Wait for controller to clear PORT_RESET
   for( ; ; ) {
      Value = isp1760_read32(HC_PORTSC1);
      if((Value & PORT_RESET) == 0) {
         break;
      }
   }
   print_1cr("\nHC_PORTSC1 after reset",Value);

// ARG !  AN10037 uses an example of 0x0001 0021 which changes some "reserved"
// bits that the spec sheet sheet says should never be changed, but the
// EHCI spec documents these "reserved" bits.  The comment in AN10037
// is "Result: R/S = 1; ITC[7:0] = 01h." where ITC is apparently the
// Interrupt Threshold Control field.  The EHCI spec documents bit 5 as the 
// Asynchronouse Schedule Enable bit.

// isp1760_write32(HC_USBCMD,0x10021);

   isp1760_bits(HC_USBCMD,CMD_RUN,0);
#if 0
// Set ATL Skip Map register
   isp1760_write32(HC_ATL_PTD_SKIPMAP_REG,0xffffffe);
#endif

   print("\nSet FLAG_CF\n");
   isp1760_write32(HC_CONFIGFLAG,FLAG_CF);   // Set configure flag

// Set ATL last PTD register
   isp1760_write32(HC_ATL_PTD_LASTPTD_REG,0x2);

// Wait 2ms for reset recovery
   msleep(2);
#endif

   isp1760_write32(HC_ATL_IRQ_MASK_OR_REG,1);
   isp1760_write32(HC_INTERRUPT_ENABLE,HC_ATL_INT | HC_SOT_INT);


// Get device descriptor from the root hub
   LOG("Get root hub device desc\n");
   gUsbDevice[0].bMaxPacketSize0 = 64;
   gUsbDevice[0].UsbSpeed = USB_SPEED_HIGH;
   GetDevDesc(0);
   LOG("Set root hub address\n");
   SetUsbAddress(ROOT_HUB_ADR);
   LOG("Set root hub configuration\n");
   SetConfiguration(ROOT_HUB_ADR,1);
   LOG("Get root hub desc\n");
   GetHubDesc(ROOT_HUB_ADR);

   LOG("Enable power on port 3\n");
// Only Port 3 is connected
   SetHubFeature(ROOT_HUB_ADR,bmREQ_SET_PORT_FEATURE,HUB_FEATURE_PORT_POWER,3);

   msleep(1000);
   LOG("After powering up port 3\n");
   ClearHubFeature(ROOT_HUB_ADR,bmREQ_CLEAR_PORT_FEATURE,HUB_FEATURE_C_PORT_CONNECTION,3);
   SetHubFeature(ROOT_HUB_ADR,bmREQ_SET_PORT_FEATURE,HUB_FEATURE_PORT_RESET,3);
   GetPortStatus(ROOT_HUB_ADR,3,&PortStatus);
   DumpPortStatus(3,PortStatus);

   msleep(1000);
   GetPortStatus(ROOT_HUB_ADR,3,&PortStatus);
   DumpPortStatus(3,PortStatus);

// Get device descriptor from the root hub
   LOG("\nGet external hub device desc\n");
   GetDevDesc(0);
   LOG("Set adr to %d\n",EXTERNAL_HUB_ADR);
   SetUsbAddress(EXTERNAL_HUB_ADR);
   LOG("Set configuration to 1\n");
   SetConfiguration(EXTERNAL_HUB_ADR,1);
   LOG("Get external hub desc\n");
   GetHubDesc(EXTERNAL_HUB_ADR);
// Power up all three ports
   for(i = 0; i < 3; i++) {
      LOG("Power UP external hub port %d\n",i+1);
      SetHubFeature(EXTERNAL_HUB_ADR,
                    bmREQ_SET_PORT_FEATURE,HUB_FEATURE_PORT_POWER,i+1);
   }
   LOG("Port status after power up\n");
   for(i = 0; i < 3; i++) {
      GetPortStatus(EXTERNAL_HUB_ADR,i+1,&PortStatus);
      DumpPortStatus(i+1,PortStatus);
#if 0
      SetHubFeature(EXTERNAL_HUB_ADR,
                    bmREQ_SET_PORT_FEATURE,HUB_FEATURE_PORT_POWER,i);
      ClearHubFeature(EXTERNAL_HUB_ADR,
                      bmREQ_CLEAR_PORT_FEATURE,HUB_FEATURE_C_PORT_CONNECTION,i);
#endif
   }
   msleep(1000);
// Check status of ports
   for(i = 0; i < 3; i++) {
      GetPortStatus(EXTERNAL_HUB_ADR,i+1,&PortStatus);
      DumpPortStatus(i+1,PortStatus);
      if(PortStatus & bmHUB_PORT_STATUS_PORT_CONNECTION) {
         LOG("Device connected to port %d, reset port\n",i+1);
         SetHubFeature(EXTERNAL_HUB_ADR,bmREQ_SET_PORT_FEATURE,
                       HUB_FEATURE_PORT_RESET,i+1);
         msleep(1000);
         GetPortStatus(EXTERNAL_HUB_ADR,i+1,&PortStatus);
         DumpPortStatus(i+1,PortStatus);
         LOG("Get device desc\n");

         gUsbDevice[0].TTPort = (uint8_t) i+1;
         gUsbDevice[0].HubDevnum = EXTERNAL_HUB_ADR;

      // Maximum packet length of control transfers for low speed: 8 bytes,
      // high speed: 8, 16, 32 or 64 bytes,
      // full speed: 64 bytes.

      // Maximum data payload size low-speed: 8 bytes, full-speed: 64 bytes,
      // high-speed: 1024 bytes
         if(PortStatus & bmHUB_PORT_STATUS_PORT_LOW_SPEED) {
            gUsbDevice[0].bMaxPacketSize0 = 8;
            gUsbDevice[0].UsbSpeed = USB_SPEED_LOW;
         }
         else if(PortStatus & bmHUB_PORT_STATUS_PORT_HIGH_SPEED) {
            gUsbDevice[0].bMaxPacketSize0 = 1024;
            gUsbDevice[0].UsbSpeed = USB_SPEED_HIGH;
         }
         else {
            gUsbDevice[0].bMaxPacketSize0 = 8;
            gUsbDevice[0].UsbSpeed = USB_SPEED_USB11;
         }
         GetDevDesc(0);
         LOG("Set adr to %d\n",EXTERNAL_HUB_ADR + i + 1);
         SetUsbAddress(EXTERNAL_HUB_ADR + i + 1);
      }
#if 0
      SetHubFeature(EXTERNAL_HUB_ADR,
                    bmREQ_SET_PORT_FEATURE,HUB_FEATURE_PORT_POWER,i);
      ClearHubFeature(EXTERNAL_HUB_ADR,
                      bmREQ_CLEAR_PORT_FEATURE,HUB_FEATURE_C_PORT_CONNECTION,i);
#endif
   }

   Dump1760Mem();
}

int SetUsbAddress(uint8_t Adr)
{
   SetupPkt Pkt;

// copy data read from device descriptor while was address zero
   memcpy(&gUsbDevice[Adr],&gUsbDevice[0],sizeof(PanoUsbDevice));

   /* fill in setup packet */
   Pkt.ReqType_u.bmRequestType = bmREQ_SET;
   Pkt.bRequest = USB_REQUEST_SET_ADDRESS;
   Pkt.wVal_u.wValueLo = Adr;
   Pkt.wVal_u.wValueHi = 0;
   Pkt.wIndex = 0;
   Pkt.wLength = 0;
   return SetupTransaction(0,&Pkt,NULL,0);
}

int SetConfiguration(uint8_t Adr,uint8_t Configuration)
{
   SetupPkt Pkt;
   int8_t Dummy;

   /* fill in setup packet */
   Pkt.ReqType_u.bmRequestType = bmREQ_SET;
   Pkt.bRequest = USB_REQUEST_SET_CONFIGURATION;
   Pkt.wVal_u.wValueLo = Configuration;
   Pkt.wVal_u.wValueHi = 0;
   Pkt.wIndex = 0;
   Pkt.wLength = 0;

   return SetupTransaction(Adr,&Pkt,&Dummy,sizeof(Dummy));
}

int SetHubFeature(uint16_t Adr,uint8_t bmRequestType,uint8_t bRequest,uint16_t wIndex)
{
   SetupPkt Pkt;
   uint8_t Dummy;

   /* fill in setup packet */
   Pkt.ReqType_u.bmRequestType = bmRequestType;
   Pkt.bRequest = USB_REQUEST_SET_FEATURE;
   Pkt.wVal_u.wValueLo = bRequest;
   Pkt.wVal_u.wValueHi = 0;
   Pkt.wIndex = wIndex;
   Pkt.wLength = 0;

   return SetupTransaction(Adr,&Pkt,&Dummy,sizeof(Dummy));
}

int ClearHubFeature(uint8_t Adr,uint8_t bmRequestType,uint8_t bRequest,uint16_t wIndex)
{
   SetupPkt Pkt;
   uint8_t Dummy;

   /* fill in setup packet */
   Pkt.ReqType_u.bmRequestType = bmRequestType;
   Pkt.bRequest = USB_REQUEST_CLEAR_FEATURE;
   Pkt.wVal_u.wValueLo = bRequest;
   Pkt.wVal_u.wValueHi = 0;
   Pkt.wIndex = wIndex;
   Pkt.wLength = 0;

   return SetupTransaction(Adr,&Pkt,&Dummy,sizeof(Dummy));
}

int DumpPortStatus(uint16_t Port,uint32_t Status)
{
   const char *Sep = "";
   const struct {
      const char *Desc;
      uint8_t Bit;
   } GCC_PACKED Bits[] = {
      {"conn",0},
      {"enabled",1},
      {"suspend",2},
      {"oc",3},
      {"rst",4},
      {"pwr",8},
      {"lo_spd",9},
      {"hi_spd",10},
      {"tst",11},
      {"ind",12},
      {"conn_ch",16},
      {"en_ch",17},
      {"suspend_ch",18},
      {"oc_ch",19},
      {"rst_ch",20},
      {NULL}
   };
   int i;

   LOG_RAW("Port %d status 0x%x: ",Port,Status);
   if(Status != 0) {
      LOG_RAW(" (");
      for(i = 0; Bits[i].Desc != NULL; i++) {
         if(Status & (1 << Bits[i].Bit) ) {
            LOG_RAW("%s%s",Sep,Bits[i].Desc);
            Sep = ", ";
         }
      }
      LOG_RAW(")");
   }
   LOG_RAW("\n");
}

int GetPortStatus(uint8_t Adr,uint16_t Port,uint32_t *pStatus)
{
   SetupPkt Pkt;

   /* fill in setup packet */
   Pkt.ReqType_u.bmRequestType = bmREQ_GET_PORT_STATUS;
   Pkt.bRequest = USB_REQUEST_GET_STATUS;
   Pkt.wVal_u.wValueLo = 0;
   Pkt.wVal_u.wValueHi = 0;
   Pkt.wIndex = Port;
   Pkt.wLength = sizeof(*pStatus);

   return SetupTransaction(Adr,&Pkt,pStatus,sizeof(*pStatus));
}

int GetHubDesc(uint16_t Adr)
{
   SetupPkt Pkt;
   uint32_t Status;
   struct HubDescriptor Desc;
   int Err;

   /* fill in setup packet */
   Pkt.ReqType_u.bmRequestType = bmREQ_GET_HUB_DESCRIPTOR;
   Pkt.bRequest = USB_REQUEST_GET_DESCRIPTOR;
   Pkt.wVal_u.wValueLo = 0;
   Pkt.wVal_u.wValueHi = 0x29;
   Pkt.wIndex = 0;
   Pkt.wLength = sizeof(Desc);

   do {
      Err = SetupTransaction(Adr,&Pkt,(int8_t *)&Desc,sizeof(Desc));
      if(Err != 0) {
         break;
      }

      print_1cr("  bDescLength",Desc.bDescLength);
      print_1cr("  bDescriptorType",Desc.bDescriptorType);
      print_1cr("  bNbrPorts",Desc.bNbrPorts);
      print_1cr("  wHubCharacteristics",Desc.wHubCharacteristics);
      print_1cr("  bPwrOn2PwrGood",Desc.bPwrOn2PwrGood);
      print_1cr("  bHubContrCurrent",Desc.bHubContrCurrent);
   } while(false);

   return Err;
}

int GetDevDesc(uint8_t Adr)
{
   USB_DEVICE_DESCRIPTOR DevDesc;
   SetupPkt Pkt;
   PanoUsbDevice *pDev = &gUsbDevice[Adr];
   int Err = 0;

   /* fill in setup packet */
   Pkt.ReqType_u.bmRequestType = bmREQ_GET_DESCR;
   Pkt.bRequest = USB_REQUEST_GET_DESCRIPTOR;
   Pkt.wVal_u.wValueLo = 0;
   Pkt.wVal_u.wValueHi = USB_DESCRIPTOR_DEVICE;
   Pkt.wIndex = 0;
   Pkt.wLength = sizeof(USB_DEVICE_DESCRIPTOR);

   do {
      Err = SetupTransaction(Adr,&Pkt,(int8_t *)&DevDesc,sizeof(DevDesc));
      if(Err != 0) {
         break;
      }

      pDev->bDeviceClass = DevDesc.bDeviceClass;
      pDev->bDeviceSubClass = DevDesc.bDeviceSubClass;
      pDev->bMaxPacketSize0 = DevDesc.bMaxPacketSize0;

      print_1cr("  bLength",DevDesc.bLength);
      print_1cr("  bDescriptorType",DevDesc.bDescriptorType);
      print_1cr("  bcdUSB",DevDesc.bcdUSB);
      print_1cr("  bDeviceClass",DevDesc.bDeviceClass);
      print_1cr("  bDeviceSubClass",DevDesc.bDeviceSubClass);
      print_1cr("  bDeviceProtocol",DevDesc.bDeviceProtocol);
      print_1cr("  bMaxPacketSize0",DevDesc.bMaxPacketSize0);
      print_1cr("  idVendor",DevDesc.idVendor);
      print_1cr("  idProduct",DevDesc.idProduct);
      print_1cr("  bcdDevice",DevDesc.bcdDevice);
      print_1cr("  iManufacturer",DevDesc.iManufacturer);
      print_1cr("  iProduct",DevDesc.iProduct);
      print_1cr("  iSerialNumber",DevDesc.iSerialNumber);
      print_1cr("  bNumConfigurations",DevDesc.bNumConfigurations);
   } while(false);

   return Err;
}


#if 0
static void create_ptd_atl(struct isp1760_qh *qh,
         struct isp1760_qtd *qtd, struct ptd *ptd)
{
   u32 maxpacket;
   u32 multi;
   u32 rl = RL_COUNTER;
   u32 nak = NAK_COUNTER;

   memset(ptd, 0, sizeof(*ptd));

   /* according to 3.6.2, max packet len can not be > 0x400 */
   maxpacket = usb_maxpacket(qtd->urb->dev, qtd->urb->pipe,
                  usb_pipeout(qtd->urb->pipe));
   multi =  1 + ((maxpacket >> 11) & 0x3);
   maxpacket &= 0x7ff;

   /* DW0 */
   ptd->dw0 = DW0_VALID_BIT;
   ptd->dw0 |= TO_DW0_LENGTH(qtd->length);
   ptd->dw0 |= TO_DW0_MAXPACKET(maxpacket);
   ptd->dw0 |= TO_DW0_ENDPOINT(usb_pipeendpoint(qtd->urb->pipe));

   /* DW1 */
   ptd->dw1 = usb_pipeendpoint(qtd>urb->pipe) >> 1;
   ptd->dw1 |= TO_DW1_DEVICE_ADDR(usb_pipedevice(qtd->urb->pipe));
   ptd->dw1 |= TO_DW1_PID_TOKEN(qtd->packet_type);

   if (usb_pipebulk(qtd->urb->pipe))
      ptd->dw1 |= DW1_TRANS_BULK;
   else if  (usb_pipeint(qtd->urb->pipe))
      ptd->dw1 |= DW1_TRANS_INT;

   if (qtd->urb->dev->speed != USB_SPEED_HIGH) {
      /* split transaction */

      ptd->dw1 |= DW1_TRANS_SPLIT;
      if (qtd->urb->dev->speed == USB_SPEED_LOW)
         ptd->dw1 |= DW1_SE_USB_LOSPEED;

      ptd->dw1 |= TO_DW1_PORT_NUM(qtd->urb->dev->ttport);
      ptd->dw1 |= TO_DW1_HUB_NUM(qtd->urb->dev->tt->hub->devnum);

      /* SE bit for Split INT transfers */
      if (usb_pipeint(qtd->urb->pipe) &&
            (qtd->urb->dev->speed == USB_SPEED_LOW))
         ptd->dw1 |= 2 << 16;

      rl = 0;
      nak = 0;
   } else {
      ptd->dw0 |= TO_DW0_MULTI(multi);
      if (usb_pipecontrol(qtd->urb->pipe) ||
                  usb_pipebulk(qtd->urb->pipe))
         ptd->dw3 |= TO_DW3_PING(qh->ping);
   }
   /* DW2 */
   ptd->dw2 = 0;
   ptd->dw2 |= TO_DW2_DATA_START_ADDR(base_to_chip(qtd->payload_addr));
   ptd->dw2 |= TO_DW2_RL(rl);

   /* DW3 */
   ptd->dw3 |= TO_DW3_NAKCOUNT(nak);
   ptd->dw3 |= TO_DW3_DATA_TOGGLE(qh->toggle);
   if (usb_pipecontrol(qtd->urb->pipe)) {
      if (qtd->data_buffer == qtd->urb->setup_packet)
         ptd->dw3 &= ~TO_DW3_DATA_TOGGLE(1);
      else if (last_qtd_of_urb(qtd, qh))
         ptd->dw3 |= TO_DW3_DATA_TOGGLE(1);
   }

   ptd->dw3 |= DW3_ACTIVE_BIT;
   /* Cerr */
   ptd->dw3 |= TO_DW3_CERR(ERR_COUNTER);
}
#endif

void print_1cr(const char *label,int value)
{
   LOG_RAW("%s: 0x%x\n",label,value);
}

void DumpPtd(const char *msg,u32 *p)
{
   const char *TokenTbl[] = {
      "OUT",
      "IN",
      "SETUP",
      "PING"
   };
   const char *EpTypeTbl[] = {
      "control",
      "???",
      "bulk",
      "???"
   };
   const char *SeTypeTbl[] = {
      "full-speed",
      "???",
      "low-speed",
      "???"
   };
   int EndPt;

   LOG_RAW("%s\n",msg);
   EndPt = ((p[0] >> 31) & 1) + ((p[1] & 07) << 1);

   print_1cr("V",p[0] & 1);
   if((p[3] >> 29) & 0x1) {
      print("Babble!\n");
   }
   if((p[3] >> 30) & 0x1) {
      print("Halt!\n");
   }

   if((p[3] >> 28) & 0x1) {
      print("Error!\n");
   }
   print_1cr("A",(p[3] >> 31) & 0x1);
   print_1cr("BytesTodo",(p[0] >> 3) & 0x7fff);
   print_1cr("BytesDone",p[3] & 0x7fff);

   print_1cr("NakCnt",(p[3] >> 19) & 0xf);
   print_1cr("RL",(p[2] >> 25) & 0xf);

   print_1cr("MaxPak",(p[0] >> 18) & 0x7ff);
   print_1cr("Multp",(p[0] >> 29) & 0x3);
   print_1cr("EndPt",EndPt);
   print_1cr("DevAdr",(p[1] >> 3) & 0x7f);

   LOG_RAW("Token: %s\n",TokenTbl[(p[1] >> 10) & 0x3]);
   LOG_RAW("EpType: %s\n",EpTypeTbl[(p[1] >> 12) & 0x3]);

   print_1cr("Split",(p[1] >> 14) & 0x1);
   if((p[1] >> 14) & 0x1) {
      LOG_RAW("  SE: %s\n",SeTypeTbl[(p[1] >> 16) & 0x3]);
      print_1cr("  Port",(p[1] >> 18) & 0x7f);
      print_1cr("  HubAdr",(p[1] >> 25) & 0x7f);

   }

   print_1cr("Start Adr",(((p[2] >> 8) & 0xffff) << 3) + 0x400);

   print_1cr("Cerr",(p[3] >> 23) & 0x3);
   print_1cr("DT",(p[3] >> 25) & 0x1);
   print_1cr("Ping",(p[3] >> 26) & 0x1);

   print_1cr("J",(p[4] >> 5) & 0x1);
   print_1cr("NextPTD",p[4] & 0x1f);
}


#if 0
uint8_t ctrlReq(
   uint8_t addr, 
   uint8_t ep, 
   uint8_t bmReqType, 
   uint8_t bRequest, 
   uint8_t wValLo, 
   uint8_t wValHi,
   uint16_t wInd, 
   uint16_t total, 
   uint16_t nbytes, 
   uint8_t* dataptr, 
   USBReadParser *p) 
{
   bool direction = false; //request direction, IN or OUT
   uint8_t rcode;
   SETUP_PKT setup_pkt;

   EpInfo *pep = NULL;
   uint16_t nak_limit = 0;

   do {
      if((rcode = SetAddress(addr, ep, &pep, &nak_limit)) != 0) {
         break;
      }
      direction = ((bmReqType & 0x80) > 0);

      /* fill in setup packet */
      setup_pkt.ReqType_u.bmRequestType = bmReqType;
      setup_pkt.bRequest = bRequest;
      setup_pkt.wVal_u.wValueLo = wValLo;
      setup_pkt.wVal_u.wValueHi = wValHi;
      setup_pkt.wIndex = wInd;
      setup_pkt.wLength = total;

#if 0
      bytesWr(rSUDFIFO, 8, (uint8_t*) & setup_pkt); //transfer to setup packet FIFO
#endif

      //dispatch packet
      if((rcode = dispatchPkt(tokSETUP, ep, nak_limit) != 0) {
         break;
      }

      if(dataptr != NULL) { //data stage, if present
         if(direction) { //IN transfer
            uint16_t left = total;

            pep->bmRcvToggle = 1; //bmRCVTOG1;

            while(left) {
               // Bytes read into buffer
               uint16_t read = nbytes;
               //uint16_t read = (left<nbytes) ? left : nbytes;

               rcode = InTransfer(pep, nak_limit, &read, dataptr);
               if(rcode == hrTOGERR) {
                  // yes, we flip it wrong here so that next time it is actually correct!
                  pep->bmRcvToggle = (regRd(rHRSL) & bmSNDTOGRD) ? 0 : 1;
                  continue;
               }

               if(rcode) {
                  break;
               }

               // Invoke callback function if inTransfer completed successfully and callback function pointer is specified
               if(!rcode && p)
                  ((USBReadParser*)p)->Parse(read, dataptr, total - left);

               left -= read;

               if(read < nbytes)
                  break;
            }
         }
         else { //OUT transfer
            pep->bmSndToggle = 1; //bmSNDTOG1;
            rcode = OutTransfer(pep, nak_limit, nbytes, dataptr);
         }

         if(rcode != 0) {
            break;
         }
      }
      // Status stage
      rcode = dispatchPkt((direction) ? tokOUTHS : tokINHS, ep, nak_limit); //GET if direction
   } while(false);

   return rcode;
}
#endif


void Dump1760Mem()
{
   int i;
   u32 Value;

   LOG_RAW("1760 Memdump:\n");

   isp1760_write32(HC_MEMORY_REG,0x400);
   for(i = 0; i < 16128; i++) {
      Value = isp1760_read32(0x400);
      if(Value != 0) {
         LOG_RAW("0x%x => 0x%x\n",0x400 + (i * 4),Value);
      }
   }
}

/*
[ISP176x] – How does the ISP176x host controller Linux 2.6.9 HCD perform host
controller initialization? What is the register initialization sequence and register
content during the host controller initialization?
Resetting the ISP176x host controller:
1. Write 0h to the Buffer Status register (334h).
2. Write FFFF FFFFh to the ATL PTD Skip Map register (154h).
3. Write FFFF FFFFh to the INT PTD Skip Map register (144h).
4. Write FFFF FFFFh to the ISO PTD Skip Map register (134h).
5. Write 0h to the ATL PTD Done Map register (150h).
6. Write 0h to the INT PTD Done Map register (140h).
7. Write 0h to the ISO PTD Done Map register (130h).
8. Write 1h (RESET_ALL) to the SW Reset register (30Ch).
9. Write 2h (RESET_HC) to the SW Reset register (30Ch).
10. Write 2h (HCRESET) to the USBCMD register (20h).
11. Wait until 2h of the USBCMD register is cleared.
 
Register dump after step 11:
USBCMD[0x20]: 0x00080b00
USBSTS[0x24]: 0x00000000
USBINTR[0x28]: 0x00000000
CONFIGFLAG[0x60]: 0x00000000
PORTSC1[0x64]: 0x00002000
HW Mode Control[0x300]: 0x00000100
HC Chip ID[0x304]: 0x00011761
HcBufferStatus[0x334]: 0x00000000
HcInterrupt[0x310]: 0x00000050
HcInterruptEnable[0x314]: 0x00000000 
 
Enabling interrupts (SOF ITL interrupt enable):
12. Write 2h (SOFITLINT) to the HcInterrupt register (310h) to clear any pending
interrupts.
13. Write 2h (SOFITLINT_E) to the HcInterruptEnable register (314h).
If port 1 is used as a host port, perform the next three steps:
14. Perform an OR of the 8000 0000h (ALL_ATX_RESET) on the HW Mode Control
register (300h).
15. Sleep or delay for 10 ms to allow the ATX to reset.
16. CLEAR bit 31 (ALL_ATX_RESET) of the HW Mode Control register to get out of the
ATX reset state.
17. Write 0h to the ATL IRQ Mask AND register (32Ch).
18. Write 0h to the ATL IRQ Mask OR register (320h).
19. Write 0h to the INT IRQ Mask AND register (328h).
20. Write 0h to the INT IRQ Mask OR register (31Ch).
21. Write 0h to the ISO IRQ Mask AND register (324h).
22. Write FFFF FFFFh to the ISO IRQ Mask OR register (318h).
23. Perform an OR of the value 101h (GLOBAL_INTR_EN and DATA_BUS_WIDTH) on
the HW Mode Control register (300h).
Remark: For the 16-bit bus system, the DATA_BUS_WIDTH bit must not be set.
Register dump after step 23:
USBCMD[0x20]: 0x00080b00
USBSTS[0x24]: 0x00000000
USBINTR[0x28]: 0x00000000
CONFIGFLAG[0x60]: 0x00000000
PORTSC1[0x64]: 0x00002000
HW Mode Control[0x300]: 0x00000101
HC Chip ID[0x304]: 0x00011761
HcBufferStatus[0x334]: 0x00000000
HcInterrupt[0x310]: 0x00000050
HcInterruptEnable[0x314]: 0x00000002
Putting the host controller in operational mode:
24. Write 1h (RS) to the USBCMD register (20h).
25. Wait for the RS bit of the USBCMD register to be set by continuously reading the
register until the RS bit is set.
26. Write 1h (CF) to the CONFIGFLAG register (60h).
27. Wait for the CF bit of the CONFIGFLAG register to be set by continuously reading
the register until the CF bit is set.
Register dump after step 27:
USBCMD[0x20]: 0x00000001
USBSTS[0x24]: 0x00000000
USBINTR[0x28]: 0x00000000
CONFIGFLAG[0x60]: 0x00000001
PORTSC1[0x64]: 0x00000000
HW Mode Control[0x300]: 0x00000101
HC Chip ID[0x304]: 0x00011761
HcBufferStatus[0x334]: 0x00000000
HcInterrupt[0x310]: 0x00000050
HcInterruptEnable[0x314]: 0x00000002
PTD register initialization part 2:
28. Write 8000 0000h to the ATL PTD Last PTD register (158h).
29. Write 8000 0000h to the INT PTD Last PTD register (148h).
30. Write 1h to the ISO PTD Last PTD register (138h).
Register dump after step 30:
USBCMD[0x20]: 0x00000001
USBSTS[0x24]: 0x00000000
USBINTR[0x28]: 0x00000000
CONFIGFLAG[0x60]: 0x00000001
PORTSC1[0x64]: 0x00000000
HW Mode Control[0x300]: 0x00000101
HC Chip ID[0x304]: 0x00011761
HcBufferStatus[0x334]: 0x00000000
HcInterrupt[0x310]: 0x00000000
HcInterruptEnable[0x314]: 0x00000002
Remark: HcInterrupt status is now cleared by the interrupt handler, which has become
active.
Powering the root port:
31. Write 1000h (PP) to the PORTSC1 register (64h).
32. Read the PORTSC1 register (64h) and wait until the ECSC bit (2h) is set.
33. Perform an OR of 2h (ECSC) on the PORTSC1 register (64h).
34. Write 1901h to the PORTSC1 register (64h).
35. Wait for 50 ms before clearing the Port Reset (PR) bit.
36. Clear the PR bit (100h) of the PORTSC1 register (64h).
Remark: The hub driver can now enumerate the internal hub.
The HcInterrupt register value becomes zero after step 2 because the ISP176x host
controller driver is running in a Linux environment and there are two execution-contexts
of the code in this environment. The first is the normal context that runs the host
controller initialization while the second is the interrupt context that checks for the
interrupt status once it arrives.
The interrupt context is not shown in preceding steps. It only highlights what you must
get when you are initializing registers. In brief, when the system has an interrupt, the
interrupt context interprets it, clears the Interrupt Status register, and performs any action
that the interrupt has indicated. Therefore, you will see HcInterrupt zero at step 30.

*/

void InitTest()
{
   u32 Value;

   isp1760_write32(HC_HW_MODE_CTRL,0);
   isp1760_write32(HC_HW_MODE_CTRL,0);
#if 0
   LOG("power on register dump\n");
   UsbRegDump();
#endif

// 1. Write 0h to the Buffer Status register (334h).
   isp1760_write32(HC_BUFFER_STATUS_REG,0);

// 2. Write FFFF FFFFh to the ATL PTD Skip Map register (154h).
   isp1760_write32(0x154,0xffffffff);

// 3. Write FFFF FFFFh to the INT PTD Skip Map register (144h).
   isp1760_write32(0x144,0xffffffff);

// 4. Write FFFF FFFFh to the ISO PTD Skip Map register (134h).
   isp1760_write32(0x134,0xffffffff);

// 5. Write 0h to the ATL PTD Done Map register (150h).
   isp1760_write32(0x150,0);

// 6. Write 0h to the INT PTD Done Map register (140h).
   isp1760_write32(0x140,0);

// 7. Write 0h to the ISO PTD Done Map register (130h).
   isp1760_write32(0x130,0);

// 8. Write 1h (RESET_ALL) to the SW Reset register (30Ch).
   isp1760_write32(0x30c,1);

// 9. Write 2h (RESET_HC) to the SW Reset register (30Ch).
   isp1760_write32(0x30c,2);

// 10. Write 2h (HCRESET) to the USBCMD register (20h).
   Value = isp1760_read32(0x20);
   Value |= 2;
   print_1cr("USBCMD\n",Value);
   isp1760_write32(0x20,Value);

// 11. Wait until 2h of the USBCMD register is cleared.
#if 0
   print("Wait for bit 2 of USBCMD\n");

   while((isp1760_read32(0x20) & 2) != 0);
#else
   msleep(100);
#endif

   isp1760_write32(HC_HW_MODE_CTRL,0);
   isp1760_write32(HC_HW_MODE_CTRL,0);

//   print("Step 11 register dump\n");
//   UsbRegDump();
   Value &= ~2;
   isp1760_write32(0x20,Value);

//Enabling interrupts (SOF ITL interrupt enable):
//12. Write 2h (SOFITLINT) to the HcInterrupt register (310h) to clear any pending
// interrupts.

   isp1760_write32(0x310,2);

// 13. Write 2h (SOFITLINT_E) to the HcInterruptEnable register (314h).

   isp1760_write32(0x314,2);

// If port 1 is used as a host port, perform the next three steps:
// 14. Perform an OR of the 8000 0000h (ALL_ATX_RESET) on the HW Mode Control
// register (300h).

   Value = isp1760_read32(0x300);
   Value |= 0x80000000;
   isp1760_write32(0x300,Value);

// 15. Sleep or delay for 10 ms to allow the ATX to reset.
   msleep(50);

// 16. CLEAR bit 31 (ALL_ATX_RESET) of the HW Mode Control register to get out of the
// ATX reset state.
   Value &= ~0x80000000;
   isp1760_write32(0x300,Value);

// 17. Write 0h to the ATL IRQ Mask AND register (32Ch).
   isp1760_write32(0x32c,0);

// 18. Write 0h to the ATL IRQ Mask OR register (320h).
   isp1760_write32(0x320,0);

// 19. Write 0h to the INT IRQ Mask AND register (328h).
   isp1760_write32(0x328,0);

// 20. Write 0h to the INT IRQ Mask OR register (31Ch).
   isp1760_write32(0x31c,0);

// 21. Write 0h to the ISO IRQ Mask AND register (324h).
   isp1760_write32(0x324,0);

// 22. Write FFFF FFFFh to the ISO IRQ Mask OR register (318h).
   isp1760_write32(0x318,0xffffffff);

// 23. Perform an OR of the value 101h (GLOBAL_INTR_EN and DATA_BUS_WIDTH) on
// the HW Mode Control register (300h).

   Value = isp1760_read32(0x300);
   Value |= 1;
   isp1760_write32(0x300,Value);

//   print("Step 23 register dump\n");
//   UsbRegDump();

// Putting the host controller in operational mode:
// 24. Write 1h (RS) to the USBCMD register (20h).
   Value |= 1;
   isp1760_write32(0x20,Value);

// 25. Wait for the RS bit of the USBCMD register to be set by continuously reading the
// register until the RS bit is set.
   print("Waiting for run bit\n");
   while((isp1760_read32(0x20) & 1) == 0);

// 26. Write 1h (CF) to the CONFIGFLAG register (60h).

   isp1760_write32(0x60,1);

// 27. Wait for the CF bit of the CONFIGFLAG register to be set by continuously reading
// the register until the CF bit is set.
   print("Waiting for cf bit\n");
   while((isp1760_read32(0x60) & 1) == 0);

//   print("Register dump after step 27:\n");
//   UsbRegDump();

// PTD register initialization part 2:
// 28. Write 8000 0000h to the ATL PTD Last PTD register (158h).
   isp1760_write32(0x158,0x80000000);

// 29. Write 8000 0000h to the INT PTD Last PTD register (148h).
   isp1760_write32(0x148,0x80000000);

// 30. Write 1h to the ISO PTD Last PTD register (138h).
   isp1760_write32(0x138,0x80000000);
//   print("Register dump after step 30:\n");
//   UsbRegDump();

// Powering the root port:
// 31. Write 1000h (PP) to the PORTSC1 register (64h).
   isp1760_write32(0x64,0x1000);

// 32. Read the PORTSC1 register (64h) and wait until the ECSC bit (2h) is set.
   print("Waiting for ECSC bit\n");
   while((isp1760_read32(0x64) & 2) == 0);

// 33. Perform an OR of 2h (ECSC) on the PORTSC1 register (64h).
   Value = isp1760_read32(0x64);
   Value |= 2;
   isp1760_write32(0x64,Value);

// 34. Write 1901h to the PORTSC1 register (64h).
   isp1760_write32(0x64,0x1901);

// 35. Wait for 50 ms before clearing the Port Reset (PR) bit.
   msleep(100);

//36. Clear the PR bit (100h) of the PORTSC1 register (64h).
   isp1760_write32(0x64,0x1801);

//   print("Register dump after step 36:\n");
//   UsbRegDump();
}

// return 0 on success
int _DoTransfer(u32 *ptd,const char *Func,int Line)
{
   u32 Value;
   int Ret = 1;   // assume the worse
   u32 PtdBuf[8];

   mem_writes8(ATL_PTD_OFFSET+4,&ptd[1],28);
   mem_writes8(ATL_PTD_OFFSET,ptd,4);

// Set ATL Skip Map register
//   isp1760_write32(HC_ATL_PTD_SKIPMAP_REG,0xffffffe);
   isp1760_write32(HC_ATL_PTD_LASTPTD_REG,0x80000000);
   isp1760_write32(HC_ATL_PTD_SKIPMAP_REG,0);

   isp1760_write32(HC_ATL_IRQ_MASK_OR_REG,1);
   isp1760_write32(HC_INTERRUPT_ENABLE,HC_ATL_INT | HC_SOT_INT);

   isp1760_write32(HC_BUFFER_STATUS_REG,ATL_BUF_FILL);

// Poll interrupt register for up to 2 seconds...
   {
      int i = 0;
      int Toggle = 0;

      while(i < 2000) {
         Value = isp1760_read32(HC_INTERRUPT_REG) & ~INT_REG_RESERVED_BITS;
         if(Value != 0) {
            i++;
            if(Value == HC_SOT_INT) {
               i++;
#if 0
               uint32_t Leds = REG_RD(GPIO_READ_ADDR);
               if(Toggle) {
                  Toggle = 0;
                  Leds |= GPIO_BIT_LED_RED;
               }
               else {
                  Toggle = 1;
                  Leds &= ~GPIO_BIT_LED_RED;
               }
               REG_WR(GPIO_WRITE_ADDR,Leds);
#endif
            }
            else {
#if 1
               if(Value & (1 << 8)) {
                  i = 0x7fffffff;
                  Ret = 0;
               }
#else
               print("ints: ");
               print_int(Value,3);
               if(Value & HC_SOT_INT) {
                  i++;
                  print(" SOT");
               }
               if(Value & HC_EOT_INT) {
                  print(" EOT");
               }
               if(Value & (1 << 5)) {
                  print(" SUSP");
               }
               if(Value & (1 << 6)) {
                  print(" CLKREADY");
               }
               if(Value & (1 << 7)) {
                  print(" INT");
               }
               if(Value & (1 << 8)) {
                  print(" ATL");
                  i = 0x7fffffff;
                  Ret = 0;
               }
               if(Value & (1 << 9)) {
                  print(" ISO");
               }
               print("\n");
#endif
            }
         }
         isp1760_write32(HC_INTERRUPT_REG,Value);
      }
   }

   isp1760_write32(HC_ATL_PTD_SKIPMAP_REG,0xffffffff);
   isp1760_write32(HC_BUFFER_STATUS_REG,0);

   if(Ret == 0) {
   // Read the Done bit map to clear the bits
      isp1760_read32(HC_ATL_PTD_DONEMAP_REG);
   // Read back the Ptd to check status
      mem_reads8(ATL_PTD_OFFSET,PtdBuf,sizeof(PtdBuf));
      if(((PtdBuf[3] >> 28) & 0x1) || ((PtdBuf[3] >> 30) & 0x1)) {
         Ret = 1;
      }
   }

   if(Ret != 0) {
      LOG("%s#%d: ",Func,Line);
      DumpPtd("Transfer failed, ptd before:\n",ptd);
      DumpPtd("\nafter",PtdBuf);
      Dump1760Mem();
   }


   return Ret;
}

void InitPtd(u32 *Ptd,uint8_t Adr,uint8_t Token,u16 PayLoadAdr,int Len)
{
   PanoUsbDevice *pDev = &gUsbDevice[Adr];

   memset(Ptd,0,8 * sizeof(u32));
   Ptd[0] = DW0_VALID_BIT;
   Ptd[0] |= TO_DW0_LENGTH(Len);
   Ptd[0] |= TO_DW0_MAXPACKET(pDev->bMaxPacketSize0);
   // Ptd[0] |= TO_DW0_ENDPOINT(0);

   Ptd[1] = 0;
   Ptd[1] |= TO_DW1_DEVICE_ADDR(Adr);
   Ptd[1] |= TO_DW1_PID_TOKEN(Token);

   if(pDev->UsbSpeed != USB_SPEED_HIGH) {
      /* split transaction */
      Ptd[1] |= DW1_TRANS_SPLIT;
      if(pDev->UsbSpeed == USB_SPEED_LOW) {
         Ptd[1] |= DW1_SE_USB_LOSPEED;
      }

      Ptd[1] |= TO_DW1_PORT_NUM(pDev->TTPort);
      Ptd[1] |= TO_DW1_HUB_NUM(pDev->HubDevnum);
#if 0
      /* SE bit for Split INT transfers */
   if(usb_pipeint(qtd->urb->pipe) && (pDev->UsbSpeed == USB_SPEED_LOW))
         ptd->dw1 |= 2 << 16;
   }
   else {
      ptd->dw0 |= TO_DW0_MULTI(multi);
      if (usb_pipecontrol(qtd->urb->pipe) ||
                  usb_pipebulk(qtd->urb->pipe))
         ptd->dw3 |= TO_DW3_PING(qh->ping);

/////
      Ptd[3] |= TO_DW3_PING(pDev->Ping);

#endif
   }
   else {
      Ptd[0] |= TO_DW0_MULTI(1);
   }

   Ptd[2] |= TO_DW2_DATA_START_ADDR(base_to_chip(PayLoadAdr));
   Ptd[2] |= TO_DW2_RL(8);

   /* DW3 */
   Ptd[3] |= TO_DW3_NAKCOUNT(0);
   Ptd[3] |= TO_DW3_DATA_TOGGLE(pDev->Toggle);

#if 0
   if (usb_pipecontrol(qtd->urb->pipe)) {
      if (qtd->data_buffer == qtd->urb->setup_packet)
         Ptd[3] &= ~TO_DW3_DATA_TOGGLE(1);
      else if (last_qtd_of_urb(qtd, qh))
         Ptd[3] |= TO_DW3_DATA_TOGGLE(1);
   }
#endif

   Ptd[3] |= TO_DW3_DATA_TOGGLE(1); //??

   Ptd[3] |= DW3_ACTIVE_BIT;
   /* Cerr */
   Ptd[3] |= TO_DW3_CERR(ERR_COUNTER);
}

int SetupTransaction(uint8_t Adr,SetupPkt *p,int8_t *pResponse,int ResponseLen)
{
   u32 Ptd[8];
   u16 CmdPayloadAdr = 0x2000;
   u16 RespPayloadAdr = 0x2008;
   PanoUsbDevice *pDev = &gUsbDevice[Adr];
   int Ret = 0;   // assume the best

   do {
   // copy setup packet into payload memory
      mem_writes8(CmdPayloadAdr,p,sizeof(SetupPkt));
      InitPtd(&Ptd,Adr,USB_TOKEN_SETUP,CmdPayloadAdr,sizeof(SetupPkt));

      if((Ret = DoTransfer(Ptd)) != 0) {
         break;
      }
      InitPtd(&Ptd,Adr,USB_TOKEN_IN,RespPayloadAdr,ResponseLen);
      if((Ret = DoTransfer(Ptd)) != 0) {
         break;
      }
      mem_reads8(RespPayloadAdr,pResponse,ResponseLen);
   } while(false);

   return Ret;
}

u32 base_to_chip(u32 base)
{
   return ((base - 0x400) >> 3);
}

