
#sim:
#	sbt "test-only rt.PanoTester"

syn:
	sbt "run-main pano.PanoVerilog"

syn_ulpi:
	sbt "run-main pano.UlpiCtrlVerilog"

waves:
	gtkwave -o simWorkspace/PanoCoreDut/test.vcd &
    
