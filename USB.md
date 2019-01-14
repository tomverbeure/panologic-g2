
# USB

## Overview

The Pano Logic G1 device has a USB host chip that deals with host USB duties as well as low level PHY functionality.

The Pano Logic G2, on the other hand, only has a low level PHY. The PHY deals with all the analog functionality, but
it has no knowledge about USB packet framing, inter-packet timings, or anything related to higher level USB.

It is thus up to the FPGA to implement a USB host to take care of all that.

The USB PHY chip is an [SMSC 3300-EKZ](https://www.microchip.com/wwwproducts/en/USB3300). It has an industry standard
ULPI interface to connect to the FPGA. The data sheet itself is [here](http://ww1.microchip.com/downloads/en/DeviceDoc/00001783C.pdf).

[USB in a Nutshell](https://www.beyondlogic.org/usbnutshell/usb1.shtml) is a very good tutorial about USB in general.

The [EHCI Specification](https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/ehci-specification-for-usb.pdf)
is a good starting point when learning about what a general USB host should support.

Here's a [bit-banged USB host](https://github.com/scanlime/propeller-usb-host) written in Propeller.

## ULPI

ULPI is an interface standard to transfer USB information over an 8-bit data bus and a few additional control signals.

A copy of the specification can be found [here](https://www.sparkfun.com/datasheets/Components/SMD/ULPI_v1_1.pdf).
And the SMSC ULPI Design Guide is [here](http://ww1.microchip.com/downloads/en/AppNotes/en562704.pdf)

## Various USB Requirements

### ULPI Specification 3.8.2.6.1: USB Inter-packet Delay and acket timeout

* Very tight requirements in terms of maximum delay times between transmit and receiving packets
* For now, only use FS, not HS, since that's not mandatory.
* Only looking at host requirements for now, not peripheral.
* transmit to transmit time: max 6.5 bit times (or ~30 60MHz cycles)
    * This means we need to be able to queue multiple transmit packets in row, and to space them apart.
    * Should be easy to do because CPU can just prepare them up front.
* receive to transmit: also 6.5 bit times. 
    * If the host needs to reply based on the result of what the peripheral sent, then we probably 
      need HW for this?
    * Or can we queue up 2 possible replies in the transmit queue and kick off only one and discard
      the rest?
* transmit to receive:
    * Max 18 bit times for timeout (== 90 clocks) Probably not very critical in practice?


### ULPI Specification 3.8.2.6.3: Link Decision Time

These are a stricter version of the ones of 3.8.2.6.1. Probably due to the delays that are
inserted by the PHY.

### FS/LS detection

This is derived from 3.8.5.1 with HS specific stuff stripped.

* Use linestate to detect FS or LS.  
    * This should always be FS since we have a hub connected?
* Host drives FS peripheral.
    * Set XcvrSelect to 00. Set TermSelect to 0. Set OpMode to 10.
    * This drives SE0.
    * Peripheral will reply with chirp K.
    * Host should not react with chirp K because we don't care about HS right now.


### Preventing Suspend Mode

* A host of hub needs to send a keep-alive packet to prevent a device from going to suspend mode.
* For FS, it needs to be sent every 1ms.

### Transmitting a packet

* Probably not a bad idea to have the HW insert the CRC.
* CRC5 for token packets, CRC16 for data packets.
* Start of Frame packets (one every 1ms for FS) include a frame number.
  Should probably be generated automatically as well.

### Control Stage

Setup Stage:
* Host: SETUP Token
* Host: DATA0 Setup Packet
* Function: replies with ACK or doesn't reply at all

Data Stage:

Receive:
* Host: IN Token
* Function: DATA/STALL/NACK or ignore
* Host: ACK reply in case of a DATA reply

Transmit:
* Host: OUT Token
* Host: DATA
* Device: Function replies ACK/NAK/STALL

Status Stage:
* Host: IN Token
* Function: DATA0/STALL/NAK
* Host: Host ACK in case of DATA0

# USB Minimum Viable HW

* Higher level transactions:
    * Control Transfers
        * Setup stage
            * H: SETUP
            * H: DATA0
            * F: ACK
        * Data stage: 
            * IN:
                * H: IN
                * F: DATAx/STALL/NAK
                * H: ACK
            * OUT:
                * H: IN
                * H: DATAx
                * F: ACK/NAK/STALL
        * Status stage: 
            * IN:
                * H: OUT
                * H: DATA0 (zero length)
                * F: ACK/STALL/NAK
            * OUT: 
                * H: IN
                * F: DATA0 (zero length)/STALL/NAK
                * H: ACK
            
    * Interrupt Transfers
        * IN:
            * H: IN
            * F: DATAx/STALL/NAK
            * H: ACK
        * OUT:
            * H: OUT
            * H: DATAx
            * F: ACK/NAK/STALL
        
    * ISO Transfers
        * IN:
            * H: IN
            * F: DATAx
        * OUT:
            * H: OUT
            * F: DATAx

    * Bulk Transfers
        * IN:
            * H: IN
            * F: DATAx/STALL/NAK
            * H: ACK
        * OUT: 
            * H: OUT
            * H: DATAx
            * F: ACK/NAK/STALL

    * SOF Transfers
        H: SOF

*  Basic primitives:
    * Automatically send out SOF every x ms
    * IN:
        * H: IN/SETUP
        * F: DATAx/STALL/NAK/TIMEOUT
            * STALL or NAK not support for SETUP. But that's ok: we assume that the function
              will just not do that 
        * H: ACK (in case of DATAx)
    * OUT:
        * H: OUT
        * H: DATAx
        * F: ACK/NAK/STALL

    What about issuing PRE (for downstream LS devices) ?

* Register API: 
    * Specify ISO or NISO
        * Determines whether or not fire-and-forget
        * Is this necessary? We could also simply make timeout, which SW should expect or could ignore.
    * Specify IN/OUT/SETUP by writing PID (4 bits. HW creates inverted copy)
        * HW automatically selects the right transfers
    * Specify ADDR/ENDP
    * Specify maximum payload size per packet (Max 8 for LS, 64 for FS, 1024 for HS)
    * For TX:
        * write all bytes for transaction to RAM. This means we can't support longer multi-packet
          transactions that size of RAM
        * Kick off transaction
        * FSM kicks off different transactions.
        * For each packet, all supports stuff is inserted: CRC, etc.k:w
        * FSM automatically inserts necessary inter-packet delays and checked for timeouts
        * In case of NAK, retry.
        * Toggle between DATA0 and DATA1 when multiple packets for a transaction
    * For RX:
        * FSM kicks of different transactions
        * Check CRCs of received data

* ACK
    * No errors (CRC or bitstuff)
    * Issue when sequence bits match and more data can be received OR when sequences bits mismatch and sender
      and receiver must resynchronize
* NAK
    * function unable to accept data (OUT) or function has no data to transmit (IN)
    * Use for flow control purposes
* STALL
    * Unable to transmit or receive data
    * control pipe request not supported



