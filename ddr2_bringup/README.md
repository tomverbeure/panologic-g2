

* Launch ISE Project Navigator
* Tools -> Core Generator
* Open -> ./ddr2_bringup/Pano.cgp
* IP Catalog: Memories & Storage Elements -> MIG Virtex-6 and Spartan-6 (3.92) : double-click
* Next -> Create Design
* Component Name: pano_g2_ddr2_c1 (c1 for MEMC1 controller)
* Next -> Select XC6SLX100 as pin compatible device
* Next -> Select DDR2 SDRAM for C1 controller
* Next -> Select 8000ps for 125MHz. 
  The DRAM supports 400MHz, the FPGA supports 312.50MHz, but we're choosing 125MHz right now
  just to get something up and running.
* Select MT47H32M16XX-25E-IT for Memory Part
* Next -> Use all default options for now
* Next -> Select 4 32-bit bidir ports
* Next -> Round Robin arbitration
* Next -> Drive strength etc. Use default settings for now.
* Next -> Just review...
* Next -> Accept
* Next -> Next -> Generate

pano_g2_ddr2_c1.xco is the main file?
