
# Files to update when changing memory size:
# - ./spinal/sw/Makefile (MEM_WORDS)
# - ./spinal/sw/start.S (stack pointer)
# - ./spinal/ise/progmem.bmm (it's complicated...)
# - ./spinal/src/main/scala/cc/CpuComplex.scala (onChipRamSize)

MEM_WORDS       = 32768

OBJ_FILES       = start.o progmem.o print.o i2c.o gmii.o dvi.o usb.o

TOOLS_PREFIX    = /opt/riscv32i/bin
TARGET          = $(TOOLS_PREFIX)/riscv32-unknown-elf
AS              = $(TARGET)-as
ASFLAGS         = -march=rv32i -mabi=ilp32
LD              = $(TARGET)-gcc
LDFLAGS         = -march=rv32i -mabi=ilp32 -Wl,-Tsections.lds,-Map,progmem.map -ffreestanding -nostartfiles
CC              = $(TARGET)-gcc
CFLAGS          = -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=$(FREQ_PLL)000000 -O2
#CFLAGS          = -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=$(FREQ_PLL)000000 -Os -lto -msave-restore
OBJCOPY         = $(TARGET)-objcopy
OBJDUMP         = $(TARGET)-objdump

#include boards/$(BOARD).mk

.PHONY: all clean syntax time stat flash

#all: progmem.dis progmem.bin progmem0.coe progmem0.mif progmem0.hex progmem.mem
all: progmem.dis progmem.bin progmem_pad.bin progmem.mem progmem.hex

progmem.dis: progmem_dis.elf
	$(OBJDUMP) -s -D $< > $@

progmem.hex: progmem_pad.bin
	$(OBJCOPY) -O ihex -I binary $< $@

progmem0.hex: progmem.bin
	../misc/create_mif.rb -f hex -d $(MEM_WORDS) -w 8 -o 0 -i 4 $< > progmem0.hex
	../misc/create_mif.rb -f hex -d $(MEM_WORDS) -w 8 -o 1 -i 4 $< > progmem1.hex
	../misc/create_mif.rb -f hex -d $(MEM_WORDS) -w 8 -o 2 -i 4 $< > progmem2.hex
	../misc/create_mif.rb -f hex -d $(MEM_WORDS) -w 8 -o 3 -i 4 $< > progmem3.hex

progmem0.coe: progmem.bin
	../misc/create_mif.rb -f coe -d $(MEM_WORDS) -w 8 -o 0 -i 4 $< > progmem0.coe
	../misc/create_mif.rb -f coe -d $(MEM_WORDS) -w 8 -o 1 -i 4 $< > progmem1.coe
	../misc/create_mif.rb -f coe -d $(MEM_WORDS) -w 8 -o 2 -i 4 $< > progmem2.coe
	../misc/create_mif.rb -f coe -d $(MEM_WORDS) -w 8 -o 3 -i 4 $< > progmem3.coe

progmem0.mif: progmem.bin
	../misc/create_mif.rb -f mif -d $(MEM_WORDS) -w 8 -o 0 -i 4 $< > progmem0.mif
	../misc/create_mif.rb -f mif -d $(MEM_WORDS) -w 8 -o 1 -i 4 $< > progmem1.mif
	../misc/create_mif.rb -f mif -d $(MEM_WORDS) -w 8 -o 2 -i 4 $< > progmem2.mif
	../misc/create_mif.rb -f mif -d $(MEM_WORDS) -w 8 -o 3 -i 4 $< > progmem3.mif

progmem.mif: progmem.bin
	../misc/create_mif.rb -f mif -d $(MEM_WORDS) -w 32 $< > progmem.mif

progmem.mem: progmem.bin
	../misc/create_mif.rb -f mem -d $(MEM_WORDS) -w 32 $< > progmem.mem

progmem.bin: progmem.elf
	$(OBJCOPY) -O binary $< $@

progmem_pad.bin: progmem.elf
	$(OBJCOPY) --pad-to=$(MEM_WORDS) -O binary $< $@

progmem.elf: fpxx_sin_table.h $(OBJ_FILES) top_defines.h sections.lds Makefile
	$(LD) $(LDFLAGS) -s -o $@ $(OBJ_FILES) > progmem.map

progmem_dis.elf: fpxx_sin_table.h $(OBJ_FILES) top_defines.h sections.lds Makefile
	$(LD) $(LDFLAGS) -o $@ $(OBJ_FILES) > progmem.map

fpxx_sin_table.h: create_sin_table Makefile
	./create_sin_table > $@

create_sin_table: create_sin_table.c
	gcc -o $@ $< -lm

clean:
	\rm -fr *.o *.hex *.elf *.dis *.bin *.coe *.map *.mif *.mem create_sin_table fpxx_sin_table.h
