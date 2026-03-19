// lfsr8.v
// © 2026 Yann Guidon / whygee@f-cpu.org

// Just a 8-bit LFSR for Tiny Tapeout targetting the iHP CMOS PDK
// LFSR shifts "right" (down to LSB) with poly 0x95
// Check the "map" image in /doc

module LFSR8E(
  input wire CLK,
  input wire RESET,
  input wire LFSR_EN,
  output [7:0] LFSR_STATE
);
  // The poly XORs
  wire x1, x2, x3; 
  (* keep *) sg13g2_xor2_1 x_a(.X(x1), .A(LFSR_STATE[0]), .B(LFSR_STATE[5]));
  (* keep *) sg13g2_xor2_1 x_b(.X(x2), .A(LFSR_STATE[0]), .B(LFSR_STATE[3]));
  (* keep *) sg13g2_xor2_1 x_c(.X(x3), .A(LFSR_STATE[0]), .B(LFSR_STATE[1]));

  wire dum1, dum2;
  // The actual shit register, that supports "reset to 00000110"
  (* keep *) sg13g2_sdfrbpq_1 lfsr7(            .Q(LFSR_STATE[7]), .SCD(LFSR_STATE[0]), .RESET_B(RESET), .CLK(CLK), .SCE(LFSR_EN), .D(LFSR_STATE[7]));
  (* keep *) sg13g2_sdfrbpq_1 lfsr6(            .Q(LFSR_STATE[6]), .SCD(LFSR_STATE[7]), .RESET_B(RESET), .CLK(CLK), .SCE(LFSR_EN), .D(LFSR_STATE[6]));
  (* keep *) sg13g2_sdfrbpq_1 lfsr5(            .Q(LFSR_STATE[5]), .SCD(LFSR_STATE[6]), .RESET_B(RESET), .CLK(CLK), .SCE(LFSR_EN), .D(LFSR_STATE[5]));
  (* keep *) sg13g2_sdfrbpq_1 lfsr4(            .Q(LFSR_STATE[4]), .SCD(x1),            .RESET_B(RESET), .CLK(CLK), .SCE(LFSR_EN), .D(LFSR_STATE[4]));
  (* keep *) sg13g2_sdfrbpq_1 lfsr3(            .Q(LFSR_STATE[3]), .SCD(LFSR_STATE[4]), .RESET_B(RESET), .CLK(CLK), .SCE(LFSR_EN), .D(LFSR_STATE[3]));
  (* keep *) sg13g2_sdfrbp_1  lfsr2(.Q(dum2), .Q_N(LFSR_STATE[2]), .SCD(x2),            .RESET_B(RESET), .CLK(CLK), .SCE(LFSR_EN), .D(dum2));
  (* keep *) sg13g2_sdfrbp_1  lfsr1(.Q(dum1), .Q_N(LFSR_STATE[1]), .SCD(LFSR_STATE[2]), .RESET_B(RESET), .CLK(CLK), .SCE(LFSR_EN), .D(dum1));
  (* keep *) sg13g2_sdfrbpq_1 lfsr0(            .Q(LFSR_STATE[0]), .SCD(x3),            .RESET_B(RESET), .CLK(CLK), .SCE(LFSR_EN), .D(LFSR_STATE[0]));
endmodule
