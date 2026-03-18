# Welcome to the TinyScanChain

It's "just a quick, last-day FOMO" project where I try some new ideas in real silicon, so I can restart the project "DTAP - Debug and Test Access Port"(see https://hackaday.io/project/193122-dtap-debug-and-test-access-port)

## What is this Tiny Tapeout tile ?

Tiny Tapeout (https://tinytapeout.com) provides 200µm × 150µm of estate on the iHP 5LM SG13G2 technology. That's about 2K gates at best but you'll still want to spy on them : observability and control are necessary so you need a TAP (Test Access Port) !

But TinyTapout does not provide a JTAG-like interface, you're on your own. So let's make one. Unfortunately the typical BILBO gates are bulky and require large fanout, and interfere with the routing of the other gates.

The iHP SG13G2 PDK provides A221OI and A21OI gates which solve this problem. It's not JTAG-compatible but it's simple, functional and should not interfere with the main design (if the synthesiser cooperates)

.

.

## Resources

- [https://github.com/ygdes/ttihp-HDSISO8](https://github.com/ygdes/ttihp-HDSISO8) implements a high density shift register / delay line with DLHQ gates (standard latches) and 4-phase non-overlapping clocks.
- [https://github.com/ygdes/ttihp-HDSISO8RS](https://github.com/ygdes/ttihp-HDSISO8RS) enhances the density by 36% with a pair of A21OI gates instead of one DLHQ gate.

These projects have shown that an iHP tile could be filled with more than 1K Reset-Set latches, though the synthesiser and the place&route tools do not cooperate, reducing the rated speed to about 20MHz, whatever this means, since the clock is virtually sped down by 8. Still, 1M bits per second is enough for a comfy debug session. However this should not affect the DUT's performance and it's now a matter of coercing the tools to de-prioritise the scan chain, and learn other tricks.

## How it works

First look at the projects above.

![](ShiftRegister_latches.png)

In this TAP system we don't need the sophisticated demux-mux machinery that splits and merges the full-speed bitstream. Let's keep a rate of one bit per byte (think: SPI!) and a single chain (so far), let's KISS because size matters.

Then take one RSFF made from a couple of sg13g2_a21o_1 (area: 2×12.7) and add some features such as a second FF or another data input.

![](ScanChainCells.png)

Note: The scan chain has a granularity of 4 steps but only 3 actual data bits. Clock pulses should always be in bursts of 8, each burst provides one bit, so the bits are grouped by 3. So each transaction will consist of sequences of 3 bytes over SPI.

## How to test

The pins are :

* SC_RESET clears the counter's state and the contents of the scan chain.

* SC_CLK advances the pulse counter/generator. 8 pulses advance the data by 1 bit.

* SC_DIN is the serial data input, must be set before clocking 8 pulses.

* SC_DOUT is the serial data output

* SC_GET is a control signal that transfers external data, in parallel, into the scan chain (if the cell allows it)

* SC_SET is a control signal that transfers the scan chain's value into the auxiliary latch for longer-term storage.


The other pins are extra inputs and outputs that can be probed or externally controlled.

Structure of the scan chain :

(to be documented)


## External hardware

Hook it up to a microcontroller or CPU. Software will be written, let's tape it out first.

## What next?

This is only a first, quick try. The original DTAP project is half-duplex and defines only 3 or 4 pins : CLK, R/W, with a split or shared serial in and out pin. The SC_GET and SC_SET signals should be controlled internally by a Finite State Machine to reduce the number of pins.

Stay tuned.
