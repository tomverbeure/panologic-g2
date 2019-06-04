
# Pano Logic G2

Most of the bringup of the Pano Logic G2 happens here.

Instead of pure Verilog, I'm using SpinalHDL (which converts to Verilog) because
I can write code much quicker, with less errors.

To build this code:

```
cd ~/projects/panologic-g2/spinal/fonts
make
cd ~/projects/panologic-g2/spinal/sw
make
cd ~/projects/panologic-g2/spinal
make syn
```

After this, you should have a `Pano.v` file that is ready to be processed by Xilinx ISE.

A working `Pano.v` is already included in case you want to build all the Verilog.

Right now, the firmware is not loaded as part of the initial synthesis, but it needs to be
patched into the bitstream afterwards.

To do this:

```
cd ./ise
make update_ram
```

This will replace the `Pano.bit` with an updated version.

In the main() function of ./sw/progmem.c, you can currently select what interface to test by playing with
`#if 0` statements.

I've included a working `Pano.bit` bitstream file in the `./ise` directory that can be loaded
straight onto the Pano box, if you really don't want to build anything.

I sometimes also add a `Pano.lx100.bit` file in the `./ise` directory because rev C
versions of the Pano G2 use that instead of the lx150. These are completely untested though.
