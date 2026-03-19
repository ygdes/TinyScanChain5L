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
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 20
    dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    # assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
