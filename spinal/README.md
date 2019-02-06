
** IMPORTANT: I'm currently using SpinalHDL  1.3.2 which is the 'dev' branch instead of an officially released branch **

To use the `dev` branch: 

* git clone https://github.com/SpinalHDL/SpinalHDL.git 
* git checkout c3b555afb39144
* `sbt publishLocal`

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

I've also included a `Pano.bit` bitstream file in the `./ise` directory that can be loaded
straight onto the Pano box, if you really don't want to build anything.

It's possible to update the firmware that's baked in this bitstream by doing `make update_ram`
in the `./ise` directory. This will replace the `Pano.bit` with an updated version.

I sometimes also add a `Pano.lx100.bit` file in the `./ise` directory because rev C
versions of the Pano G2 use that instead of the lx150. These are completely untested though.
