
# USB

## Overview

The Pano Logic G1 device has a USB host chip that deals with host USB duties as well as low level PHY functionality.

The Pano Logic G2, on the other hand, only has a low level PHY. The PHY deals with all the analog functionality, but
it has no knowledge about USB packet framing, inter-packet timings, or anything related to higher level USB.

It is thus up to the FPGA to implement a USB host to take care of all that.

The USB PHY chip is an [SMSC 3300-EKZ](https://www.microchip.com/wwwproducts/en/USB3300). It has an industry standard
ULPI interface to connect to the FPGA. The data sheet itself is [here](http://ww1.microchip.com/downloads/en/DeviceDoc/00001783C.pdf).

## ULPI

ULPI is an interface standard to transfer USB information over an 8-bit data bus and a few additional control signals.

A copy of the specification can be found [here](https://www.sparkfun.com/datasheets/Components/SMD/ULPI_v1_1.pdf).
And the SMSC ULPI Design Guide is [here](http://ww1.microchip.com/downloads/en/AppNotes/en562704.pdf)

