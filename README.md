![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Welcome to the TinyScanChain

Let's try some new ideas in real silicon, so I can restart the project [DTAP - Debug and Test Access Port](https://hackaday.io/project/193122-dtap-debug-and-test-access-port)

[Read the documentation for this project](docs/info.md)

## What is this Tiny Tapeout tile ?

Tiny Tapeout (https://tinytapeout.com) provides 200µm × 150µm of estate on the iHP 5LM SG13G2 technology. That's about 2K gates at best but you'll still want to spy on them : observability and control are necessary so you need a TAP (Test Access Port) !

But TinyTapout does not provide a JTAG-like interface, you're on your own. So let's make one. Unfortunately the typical BILBO gates are bulky and require large fanout, and interfere with the routing of the other gates.

The iHP SG13G2 PDK provides A221OI and A21OI gates which solve this problem. It's not JTAG-compatible but it's simple, functional and should not interfere with the main design (if the synthesiser cooperates)

## Resources

- https://github.com/ygdes/ttihp-HDSISO8 implements a high density shift register / delay line with DLHQ gates (standard latches) and 4-phase non-overlapping clocks.
- https://github.com/ygdes/ttihp-HDSISO8RS enhances the density by 36% with a pair of A21OI gates instead of one DLHQ gate.

## What next?

Let's hope it makes it in time to tapeout ! I'll create a suitable FSM later.
