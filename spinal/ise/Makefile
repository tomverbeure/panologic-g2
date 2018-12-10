
XILINX_DIR = /opt/Xilinx/14.7/ISE_DS/
XILINX_BIN = $(XILINX_DIR)/ISE/bin/lin64

BITSTREAM_NAME = Pano

#ise: progmem.hex c64_font.hex vga8x12_font.hex screen_buffer.hex
ise:
	$(XILINX_BIN)/ise

impact:
	sudo LD_PRELOAD=$(XILINX_DIR)/usb-driver/libusb-driver.so $(XILINX_BIN)/impact

update_ram: progmem.mem
	$(XILINX_BIN)/data2mem -bm progmem.bmm -bt $(BITSTREAM_NAME).bit -bd progmem.mem -o b $(BITSTREAM_NAME).new.bit
	$(XILINX_BIN)/data2mem -bm progmem.bmm -bt $(BITSTREAM_NAME).new.bit -d > $(BITSTREAM_NAME).new.bit.dump
	mv $(BITSTREAM_NAME).bit $(BITSTREAM_NAME).bit.orig
	mv $(BITSTREAM_NAME).new.bit $(BITSTREAM_NAME).bit

dump:
	$(XILINX_BIN)/data2mem -bm progmem.bmm -bt $(BITSTREAM_NAME).bit -d > $(BITSTREAM_NAME).bit.dump

.PHONY: progmem.mem
progmem.mem:
	cd ../sw/ && make
	cp ../sw/progmem.mem .

.PHONY: progmem.hex
progmem.hex:
	cd ../sw/ && make
	cp ../sw/progmem*.hex .

c64_font.hex:
	cd ../misc/ && make
	cp ../misc/$@ $@

vga8x12_font.hex:
	cd ../misc/ && make
	cp ../misc/$@ $@

screen_buffer.hex:
	cd ../misc/ && make
	cp ../misc/$@ $@
