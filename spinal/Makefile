
#sim:
#	sbt "test-only rt.PanoTester"

syn:
	sbt "run-main pano.PanoVerilog"

syn_ulpi:
	sbt "run-main pano.UlpiCtrlVerilog"

syn_apb3cc:
	sbt "run-main pano.Apb3CCVerilog"

waves:
	gtkwave -o simWorkspace/PanoCoreDut/test.vcd &
    
