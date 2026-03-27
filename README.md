![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

This is a port from iHP's SG13G2 to the feature-reduced SG13CMOS5L PDK.

# Welcome to the TinyScanChain

Let's try some new ideas in real silicon, so I can restart the project [DTAP - Debug and Test Access Port](https://hackaday.io/project/193122-dtap-debug-and-test-access-port)

[Read the documentation for this project](docs/info.md)

[You can play with this project on the iHP26a tapeout at address 625](https://app.tinytapeout.com/projects/4049)

## What is this Tiny Tapeout tile ?

Tiny Tapeout (https://tinytapeout.com) provides 200µm × 150µm of estate on the iHP 5LM SG13G2 technology. That's about 2K gates at best but you'll still want to spy on them : observability and control are necessary so you need a TAP (Test Access Port) !

But TinyTapout does not provide a JTAG-like interface, you're on your own. So let's make one. Unfortunately the typical BILBO gates are bulky and require large fanout, and interfere with the routing of the other gates.

The iHP SG13G2 PDK provides A221OI and A21OI gates which solve this problem. It's not JTAG-compatible but it's simple, functional and should not interfere with the main design (if the synthesiser cooperates)

The circuit has a short chain (24 bits of capacity) which can be synthesised up to 80MHz: this amounts to 10M bits per second (due to the internal 8x divider/polyphase asynch clock). To cut on the buffer fat, this version is rated at (only) 50MHz, or 6Mbps, which is still good enough for intense debugging sessions.

## Resources

- https://github.com/ygdes/ttihp-HDSISO8 implements a high density shift register / delay line with DLHQ gates (standard latches) and 4-phase non-overlapping clocks.
- https://github.com/ygdes/ttihp-HDSISO8RS enhances the density by 36% with a pair of A21OI gates instead of one DLHQ gate.

## What next?

Let's hope it makes it in time to tapeout ! I'll create a suitable FSM later. And then I could make a tool to generate custom scan chains or something. There's a lot to improve but the fundamentals are great.
