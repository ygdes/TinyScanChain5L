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

  dut.rst_n.value = 1
  dut.uio_in.value = Count_Enable + SC_SET
  dut._log.info("Let's see if the LFSR works.")
  await ClockCycles(dut.clk, 48)


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


  dut._log.info("Does the scan chain capture the input data ?")
  dut.ui_in.value = 109 # 01101101
  await pulse(dut, SC_RESET, SC_GET)
  # sc_dout should be 1 right ?

  dut._log.info("Dumping the scan chain")
  # Flush the chain. Fed with 1, should output 1s after 24*8 cycles
  await pulse8x(dut, 4*8, SC_RESET + SC_DIN)


  # fill the output port with 1s
  await pulse(dut, SC_RESET, SC_SET)

  # see if it works better now ?
  await pulse(dut, SC_RESET, SC_GET)


  await pulse8x(dut, 4*8, SC_RESET)


  # fill the output port with 0s
  await pulse(dut, SC_RESET, SC_SET)

  #dut.uio_in.value = SC_RESET + SC_SET 
  #await ClockCycles(dut.clk, 1)
  #dut.uio_in.value = Count_Enable + SC_GET
  #await ClockCycles(dut.clk, 1)
  # Set the input values you want to test
  #dut.ui_in.value = 20
  #dut.uio_in.value = 30
  # assert dut.uo_out.value == 50
