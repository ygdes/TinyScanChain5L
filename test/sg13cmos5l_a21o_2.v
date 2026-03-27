`timescale 1ns/10ps
`celldefine
module sg13cmos5l_a21o_2 (X, A1, A2, B1);
	output X;
	input A1, A2, B1;
	wire int_fwire_0;
	and (int_fwire_0, A1, A2);
	or (X, int_fwire_0, B1);
endmodule
`endcelldefine
