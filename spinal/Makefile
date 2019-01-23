
sim:
	sbt "test-only rt.PanoTester"

syn:
	sbt "run-main pano.PanoVerilog"

syn-g1:
	sbt "run-main pano.PanoG1Verilog"

waves:
	gtkwave -o simWorkspace/PanoCoreDut/test.vcd &
    
