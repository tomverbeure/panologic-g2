# If your JTAG cable is not a Digilent JTAG-HS2 cable you will set the
# environment variable XC3SPROG_CABLE for your device.
# Refer to the supported hardware [web page](http://xc3sprog.sourceforge.net/hardware.php) 
# page or run  xc3sprog -c to find the correct cable option for your device.

XC3SPROG_CABLE ?= jtaghs2
XC3SPROG_OPTS ?= -c $(XC3SPROG_CABLE) -v
XC3SPROG ?= xc3sprog
THIS_DIR := $(TOPDIR)/xc3sprog

.PHONY: prog_g1 prog_g2_rev_b prog_g2_rev_c reset reload

prog_g1:
	$(XC3SPROG) $(XC3SPROG_OPTS) -I$(THIS_DIR)/pano_g1.bit $(TOPDIR)/ise.g1/PanoG1.bit
    
prog_g2_rev_b:
	$(XC3SPROG) $(XC3SPROG_OPTS) -I$(THIS_DIR)/pano_g2_lx150.bit $(TOPDIR)/ise/Pano.bit

prog_g2_rev_c:
	$(XC3SPROG) $(XC3SPROG_OPTS) -I$(THIS_DIR)/pano_g2_lx100.bit $(TOPDIR)/ise/Pano.lx100.bit

reset:
	$(XC3SPROG) $(XC3SPROG_OPTS) -R

