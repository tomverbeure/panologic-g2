
#sim:
#	sbt "test-only rt.PanoTester"

syn:
	sbt "runMain pano.PanoVerilog"

syn_ulpi:
	sbt "runMain pano.UlpiCtrlVerilog"

syn_apb3cc:
	sbt "runMain pano.Apb3CCVerilog"

waves:
	gtkwave -o simWorkspace/PanoCoreDut/test.vcd &
    
