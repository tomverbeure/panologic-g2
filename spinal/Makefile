
#sim:
#	sbt "test-only rt.PanoTester"

.PHONY: submodule prog_g1 prog_g2_rev_b prog_g2_rev_c
submodule:
	cd ../ && git submodule update --init

syn: submodule
	sbt "runMain pano.PanoVerilog"

syn_ulpi:
	sbt "runMain pano.UlpiCtrlVerilog"

syn_apb3cc:
	sbt "runMain pano.Apb3CCVerilog"

syn_usbh:
	sbt "runMain pano.UsbHostVerilog"

syn-g1: submodule
	sbt "runMain pano.PanoG1Verilog"

waves:
	gtkwave -o simWorkspace/PanoCoreDut/test.vcd &

ifeq ($(TOPDIR),)
TOPDIR := .
endif

-include xc3sprog/Makefile


