/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_YannGuidon_TinyScanChain (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

// Plumbing time...

/*
 Bidirectional pins
 uio[0]: "SC_RESET"
 uio[1]: "SC_CLK"
 uio[2]: "SC_GET"
 uio[3]: "SC_SET"
 uio[4]: "SC_DIN"
 uio[5]: "SC_DOUT"
 uio[6]: "DO8"
 uio[7]: "Count_Enable"
*/
  wire SC_RESET, SC_CLK, SC_GET, SC_SET, SC_DIN, SC_DOUT, Count_Enable;

  assign SC_RESET     = uio_in[0];
  assign SC_CLK       = uio_in[1];
  assign SC_GET       = uio_in[2];
  assign SC_SET       = uio_in[3];
  assign SC_DIN       = uio_in[4];
//assign uio_out[5]   = SC_DOUT;
//assign uio_out[6]   = DO8;
  assign Count_Enable = uio_in[7];

  wire [8:0] DO;
  assign uo_out  = DO[7:0];
  assign uio_out = { 1'b0, DO[8], SC_DOUT, 5'b0 };
  assign uio_oe  = 8'b01100000;


  // The actual "meat" comes here.

  // The controller:
  wire [3:0] L4, Latch;
  Johnson8 J8( .CLK(SC_CLK), .RESET(SC_RESET), .Latch(L4) );
  Buffers_x4 b4(.A(L4), .X(Latch));
  // note: I boost the 4 latch signals, because they are important for timing (at high frequencies)
  // but let the toolset handle the less demanding SC_SET and SC_GET

  // Some circuit that has an internal state that can be observed:
  wire [7:0] SomeData;
  LFSR8E lfsr(.CLK(clk), .RESET(rst_n), .LFSR_EN(Count_Enable), .LFSR_STATE(SomeData));

  // The scan chain
  wire [1:0] t0, t1, t2, t3, t4, t5, t6, t7, t8;
  wire [23:0] S; // spy on this signal to "see" the whole scan chain

  assign t0={ ~SC_DIN, SC_DIN}; // yeah I got lazy here
  // output some data
  SC_Quad_Out QO0(.SET(SC_SET), .Dout(DO[2:0]), .Latch(Latch), .SCin(t0), .SCout(t1), .state_pos(S[2:0]));
  SC_Quad_Out QO1(.SET(SC_SET), .Dout(DO[5:3]), .Latch(Latch), .SCin(t1), .SCout(t2), .state_pos(S[5:3]));
  SC_Quad_Out QO2(.SET(SC_SET), .Dout(DO[8:6]), .Latch(Latch), .SCin(t2), .SCout(t3), .state_pos(S[8:6]));

  // read some internal data (and ignore the MSB of the LFSR, who cares)
  SC_Quad_In  QI0(.GET(SC_GET), .Din(SomeData[2:0]), .Latch(Latch), .SCin(t3), .SCout(t4), .state_pos(S[11:9]));
  SC_Quad_In  QI1(.GET(SC_GET), .Din(SomeData[5:3]), .Latch(Latch), .SCin(t4), .SCout(t5), .state_pos(S[14:12]));
  
  // input some external data
  wire [2:0] in3;
  assign in3 = { ui_in[1:0], SomeData[6] };
  SC_Quad_In  QI2(.GET(SC_GET), .Din(in3       ), .Latch(Latch), .SCin(t5), .SCout(t6), .state_pos(S[17:15]));
  SC_Quad_In  QI3(.GET(SC_GET), .Din(ui_in[4:2]), .Latch(Latch), .SCin(t6), .SCout(t7), .state_pos(S[20:18]));
  SC_Quad_In  QI4(.GET(SC_GET), .Din(ui_in[7:5]), .Latch(Latch), .SCin(t7), .SCout(t8), .state_pos(S[23:21]));

  assign SC_DOUT = t8[0]; // output only the positive value
  
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, SomeData[7], t8[1], uio_in[5], uio_in[6], S, 1'b0};

endmodule
