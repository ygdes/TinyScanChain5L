/* ScanChain.v
 created mer. 18 mars 2026 18:47:27 CET by whygee@f-cpu.org

A polyphase shift register for scan-chaining in iHP SG13G2 5LM technology.

It's small but slow : it takes 8 clock cycles to shift one bit.
But it's still fast enough for most debug chores.
*/

/*
  8-step sequencer using an inverted ring counter,
  aka Johnson counter. 4 DFF, 4 AND,
  using raw cells from iHP CMOS PDK

  In this version, reset forces all outputs to 1 instead of 0
  to flush the shift register very fast.

  area : 10.8864 + 4×54.432 + 4×14.5152 = 286.68
*/
module Johnson8(
    input  wire CLK,
    input  wire RESET,
    output wire [3:0] Latch
);
  // invert & Boost Reset
  wire rstN;
  (* keep *) sg13g2_inv_4 boost0(.Y(rstN),  .A(RESET));

  // The ring counter
  wire [3:0] J4P, J4N;
  (* keep *) sg13g2_dfrbp_2  DFF_J1(.Q(J4P[0]), .Q_N(J4N[0]), .D(J4N[3]), .RESET_B(RESET), .CLK(CLK));
  (* keep *) sg13g2_dfrbp_2  DFF_J2(.Q(J4P[1]), .Q_N(J4N[1]), .D(J4P[0]), .RESET_B(RESET), .CLK(CLK));
  (* keep *) sg13g2_dfrbp_2  DFF_J3(.Q(J4P[2]), .Q_N(J4N[2]), .D(J4P[1]), .RESET_B(RESET), .CLK(CLK));
  (* keep *) sg13g2_dfrbp_2  DFF_J4(.Q(J4P[3]), .Q_N(J4N[3]), .D(J4P[2]), .RESET_B(RESET), .CLK(CLK));

  // The decoder
  (* keep *) sg13g2_a21o_2 dec0(.X(Latch[0]), .A1(J4N[3]), .A2(J4N[0]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec2(.X(Latch[1]), .A1(J4P[1]), .A2(J4N[2]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec4(.X(Latch[2]), .A1(J4P[3]), .A2(J4P[0]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec6(.X(Latch[3]), .A1(J4N[1]), .A2(J4P[2]), .B1(rstN));
endmodule


/*
 Just a 4-bit interter-buffer
 area : 4 × 10.8864 = 43.5456
*/
module Inverters_x4 (
    input  wire [3:0] A,
    output wire [3:0] Y);
  (* keep *) sg13g2_inv_4  Amp0(.Y(Y[0]), .A(A[0]));
  (* keep *) sg13g2_inv_4  Amp1(.Y(Y[1]), .A(A[1]));
  (* keep *) sg13g2_inv_4  Amp2(.Y(Y[2]), .A(A[2]));
  (* keep *) sg13g2_inv_4  Amp3(.Y(Y[3]), .A(A[3]));
endmodule

/*
 Just a 4-bit non-interter-buffer
 area : 4 × 14.51520 = 58.0608
*/
module Buffers_x4 (
    input  wire [3:0] A,
    output wire [3:0] X);
  (* keep *) sg13g2_buf_4  Amp0(.X(X[0]), .A(A[0]));
  (* keep *) sg13g2_buf_4  Amp1(.X(X[1]), .A(A[1]));
  (* keep *) sg13g2_buf_4  Amp2(.X(X[2]), .A(A[2]));
  (* keep *) sg13g2_buf_4  Amp3(.X(X[3]), .A(A[3]));
endmodule


/* This is just a "delay/temporary" cell, inserted every 4 data cells, so one per quad.
   area : 2 × 9.072 = 18.144
*/
module SC_RSFF(
    input  wire D,
    input  wire D_N,
    input  wire EN,
    output wire Q,
    output wire Q_N);
  (* keep *) sg13g2_a21oi_1 rs_neg(.Y(Q_N), .A1(EN), .A2(D  ), .B1(Q  ));
  (* keep *) sg13g2_a21oi_1 rs_pos(.Y(Q  ), .A1(EN), .A2(D_N), .B1(Q_N));
endmodule

/* This is an "input" cell, used by the 3 other slots of a quad.
   area : 9.072 + 14.5152 = 23.5872
*/
module SC_RSFF_in(
    input  wire D,
    input  wire D_N,
    input  wire Din,
    input  wire GET,
    input  wire EN,
    output wire Q,
    output wire Q_N);
  (* keep *) sg13g2_a221oi_1 rs_neg(.Y(Q_N), .A1(EN), .A2(D  ), .B1(Din), .B2(GET), .C1(Q));
  (* keep *) sg13g2_a21oi_1  rs_pos(.Y(Q  ), .A1(EN), .A2(D_N),                     .B1(Q_N));
endmodule

/* This is an "output" cell, that stores a bit from the scan chain for external use.
   area : 4 × 9.072 = 36.288
*/
module SC_RSFF_out(
    input  wire D,
    input  wire D_N,
    input  wire EN,
    input  wire SET,
    output wire Dout,
    output wire Q,
    output wire Q_N);
  // The scan chain:
  (* keep *) sg13g2_a21oi_1 rssc_neg(.Y(Q_N), .A1(EN), .A2(D  ), .B1(Q  ));
  (* keep *) sg13g2_a21oi_1 rssc_pos(.Y(Q  ), .A1(EN), .A2(D_N), .B1(Q_N));
  // The data latch:
  wire DoutN;
  (* keep *) sg13g2_a21oi_1 rsdo_neg(.Y(DoutN), .A1(SET), .A2(Q  ), .B1(Dout ));
  (* keep *) sg13g2_a21oi_1 rsdo_pos(.Y(Dout ), .A1(SET), .A2(Q_N), .B1(DoutN));
endmodule

// Note : SC_RFF_inout is possible. But not required here yet so I skip.

module SC_Quad_In(
    input  wire GET,
    input  wire [2:0] Din,

    input  wire [3:0] Latch,
    input  wire [1:0] SCin,
    output wire [1:0] SCout
);
  wire tp1, tp2, tp3, tn1, tn2, tn3;
  SC_RSFF     tmp(.D(SCin[0]), .D_N(SCin[1]), .EN(Latch[3]), .Q(tp1),      .Q_N(tn1));
  SC_RSFF_in  in2(.D(tp1),     .D_N(tn1),     .EN(Latch[2]), .Q(tp2),      .Q_N(tn2),      .Din(Din[2]), .GET(GET));
  SC_RSFF_in  in1(.D(tp2),     .D_N(tn2),     .EN(Latch[1]), .Q(tp3),      .Q_N(tn3),      .Din(Din[1]), .GET(GET));
  SC_RSFF_in  in0(.D(tp3),     .D_N(tn3),     .EN(Latch[0]), .Q(SCout[0]), .Q_N(SCout[1]), .Din(Din[0]), .GET(GET));
endmodule

module SC_Quad_Out(
    input  wire SET,
    output wire [2:0] Dout,

    input  wire [3:0] Latch,
    input  wire [1:0] SCin,
    output wire [1:0] SCout
);
  wire tp1, tp2, tp3, tn1, tn2, tn3;
  SC_RSFF     tmp (.D(SCin[0]), .D_N(SCin[1]), .EN(Latch[3]), .Q(tp1),      .Q_N(tn1));
  SC_RSFF_out out2(.D(tp1),     .D_N(tn1),     .EN(Latch[2]), .Q(tp2),      .Q_N(tn2),      .Dout(Dout[2]), .SET(SET));
  SC_RSFF_out out1(.D(tp2),     .D_N(tn2),     .EN(Latch[1]), .Q(tp3),      .Q_N(tn3),      .Dout(Dout[1]), .SET(SET));
  SC_RSFF_out out0(.D(tp3),     .D_N(tn3),     .EN(Latch[0]), .Q(SCout[0]), .Q_N(SCout[1]), .Dout(Dout[0]), .SET(SET));
endmodule
