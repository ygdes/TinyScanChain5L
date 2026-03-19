# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


#  # Inputs
#  ui[0]: "DI0"
#  ui[1]: "DI1"
#  ui[2]: "DI2"
#  ui[3]: "DI3"
#  ui[4]: "DI4"
#  ui[5]: "DI5"
#  ui[6]: "DI6"
#  ui[7]: "DI7"
#
#  # Outputs
#  uo[0]: "DO0"
#  uo[1]: "DO1"
#  uo[2]: "DO2"
#  uo[3]: "DO3"
#  uo[4]: "DO4"
#  uo[5]: "DO5"
#  uo[6]: "DO6"
#  uo[7]: "DO7"
#
#  # Bidirectional pins
#  uio[0]: "SC_RESET"
#  uio[1]: "SC_CLK"
#  uio[2]: "SC_GET"
#  uio[3]: "SC_SET"
#  uio[4]: "SC_DIN"
#  uio[5]: "SC_DOUT"
#  uio[6]: "DO8"
#  uio[7]: "Count_Enable"

SC_RESET     =   1  # asserted by 0, like the general rst pin
SC_CLK       =   2  # counts on rising edge
SC_GET       =   4  # pulse high to latch in
SC_SET       =   8  # pulse high to latch out
SC_DIN       =  16  # must be ready before SC_CLK rising edge
SC_DOUT      =  32  
DO8          =  64
Count_Enable = 128

async def clear(dut, flags):
  dut.uio_in.value = flags
  await ClockCycles(dut.clk, 1)
  dut.uio_in.value = flags + SC_RESET
  await ClockCycles(dut.clk, 1)

async def pulse(dut, flags, pin):
  dut.uio_in.value = flags + pin 
  await ClockCycles(dut.clk, 1)
  dut.uio_in.value = flags
  await ClockCycles(dut.clk, 1)

async def pulse8x(dut, bytes, flags):
  j = 0
  while (j < bytes):
    j = j+1
    i = 0
    while (i < 8):   # a whole byte for SPI, just one bit for the shift register
      i = i+1
      await  pulse(dut, flags, SC_CLK)



@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")

  # Set the clock period to 10 us (100 KHz)
  clock = Clock(dut.clk, 10, unit="us")
  cocotb.start_soon(clock.start())

  # Reset

  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = SC_SET # clear the output latches too
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 2)

  # check LFSR
  
  dut.rst_n.value = 1
  dut.uio_in.value = Count_Enable + SC_SET
  dut._log.info("Let's see if the LFSR works.")
  await ClockCycles(dut.clk, 43)

  # check avalanche

  dut.uio_in.value = SC_SET + SC_DIN
  dut._log.info("LFSR stopped. Does the input value cascade to the output during RESET ?")
  await ClockCycles(dut.clk, 1)
  #print("dut.uio_out.value = " + str(dut.uio_out.value))
  assert dut.uio_out.value == SC_DOUT + DO8
  assert dut.uo_out.value == 255

  dut.uio_in.value = SC_SET  # restore the cleared value at the output port)
  await ClockCycles(dut.clk, 1)
  #print("dut.uio_out.value = " + str(dut.uio_out.value))
  assert dut.uio_out.value == 0
  assert dut.uo_out.value == 0

  # check capture

  dut._log.info("Does the scan chain capture the input data ?")
  dut.ui_in.value = 20 # 00010100
  await pulse(dut, SC_RESET, SC_GET)
  # sc_dout should be 0 here, right ?

  # Flush the chain and fill it with 1, should output 1s after 24*8 cycles

  dut._log.info("Dumping the scan chain")
  await pulse8x(dut, 3*8, SC_RESET + SC_DIN)

  dut._log.info("fill the output port with 1s")
  await pulse(dut, SC_RESET, SC_SET)
  assert dut.uo_out.value == 255

  # it's not possible to "get" when the chain is all-1s
  await pulse(dut, SC_RESET, SC_GET)

  # Flush the chain and fill it with 0, should output 0s after 24*8 cycles

  dut._log.info("flush the chain, fill with 0s")
  await pulse8x(dut, 4*8, SC_RESET)

  # fill the output port with 0s
  await pulse(dut, SC_RESET, SC_SET)
  assert dut.uo_out.value == 0

  # let the LFSR run again a bit
  dut.uio_in.value = Count_Enable + SC_RESET
  dut._log.info("Let's see if the LFSR works.")
  await ClockCycles(dut.clk, 12)

  dut._log.info("Sample more input data")
  dut.ui_in.value = 235 # ~00010100
  await pulse(dut, SC_RESET, SC_GET)
  dut._log.info("flush the chain again, fill with 0s")
  await pulse8x(dut, 4*8, SC_RESET)

  dut.ui_in.value = 0
  n = 1
  for i in range(0, 8):
    print (n)
    dut.ui_in.value = n
    await pulse(dut, SC_RESET, SC_GET)
    await ClockCycles(dut.clk, 3)
    await clear(dut, 0)
    n = n+n
