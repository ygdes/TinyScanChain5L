/* ScanChain.v
 created mer. 18 mars 2026 18:47:27 CET by whygee@f-cpu.org

A polyphase shift register for scan-chaining in iHP SG13G2 5LM technology.

It's small but slow : it takes 8 clock cycles to shift one bit.
But it's still fast enough for most debug chores.
*/

/*
  8-step sequencer using an inverted ring counter,
  aka Johnson counter. 4 DFF, 8 AND,
  using raw cells from iHP CMOS PDK

  In this version, reset forces all outputs to 1 instead of 0
  to flush the shift register very fast.

  area : 10.8864 + 4×54.432 + 8×14.5152 = 344.736
*/

module Johnson8(
  input  wire CLK,
  input  wire RESET,
  output wire [3:0] DFF4,
  output wire [7:0] Decoded8);

  // invert & Boost Reset
  wire rstN;
  (* keep *) sg13g2_inv_4 boost0(.Y(rstN),  .A(RESET));

  // The ring counter
  wire [3:0] J4P, J4N;
  (* keep *) sg13g2_dfrbp_2  DFF_J1(.Q(J4P[0]), .Q_N(J4N[0]), .D(J4N[3]), .RESET_B(RESET), .CLK(CLK));
  (* keep *) sg13g2_dfrbp_2  DFF_J2(.Q(J4P[1]), .Q_N(J4N[1]), .D(J4P[0]), .RESET_B(RESET), .CLK(CLK));
  (* keep *) sg13g2_dfrbp_2  DFF_J3(.Q(J4P[2]), .Q_N(J4N[2]), .D(J4P[1]), .RESET_B(RESET), .CLK(CLK));
  (* keep *) sg13g2_dfrbp_2  DFF_J4(.Q(J4P[3]), .Q_N(J4N[3]), .D(J4P[2]), .RESET_B(RESET), .CLK(CLK));
  assign DFF4 = J4P;

  // The decoder
  (* keep *) sg13g2_a21o_2 dec0(.X(Decoded8[0]), .A1(J4N[3]), .A2(J4N[0]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec1(.X(Decoded8[1]), .A1(J4P[0]), .A2(J4N[1]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec2(.X(Decoded8[2]), .A1(J4P[1]), .A2(J4N[2]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec3(.X(Decoded8[3]), .A1(J4P[2]), .A2(J4N[3]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec4(.X(Decoded8[4]), .A1(J4P[3]), .A2(J4P[0]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec5(.X(Decoded8[5]), .A1(J4N[0]), .A2(J4P[1]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec6(.X(Decoded8[6]), .A1(J4N[1]), .A2(J4P[2]), .B1(rstN));
  (* keep *) sg13g2_a21o_2 dec7(.X(Decoded8[7]), .A1(J4N[2]), .A2(J4P[3]), .B1(rstN));
endmodule



/*
 Just a 4-bit interter-buffer to keep the code size down.
 area : 4 × 5.4432 = 21.778
*/
module Inverters_x4 (
    input  wire [3:0] A,
    output wire [3:0] Y);
  (* keep *) sg13g2_inv_4  Amp0(.Y(Y[0]), .A(A[0]));
  (* keep *) sg13g2_inv_4  Amp1(.Y(Y[1]), .A(A[1]));
  (* keep *) sg13g2_inv_4  Amp2(.Y(Y[2]), .A(A[2]));
  (* keep *) sg13g2_inv_4  Amp3(.Y(Y[3]), .A(A[3]));
endmodule

/* This is just a "delay/temporary" cell,
   inserted every 4 data cells.
   area : 2 × 9.072 = 18.144
*/
module SC_RSFF_pos(
    input  wire D,
    input  wire D_N,
    input  wire EN,
    output wire Q,
    output wire Q_N);
  (* keep *) sg13g2_a21oi_1 rs_neg(.Y(Q_N), .A1(EN), .A2(D  ), .B1(Q  ));
  (* keep *) sg13g2_a21oi_1 rs_pos(.Y(Q  ), .A1(EN), .A2(D_N), .B1(Q_N));
endmodule




