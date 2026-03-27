`timescale 1ns/10ps
`celldefine
module sg13cmos5l_a221oi_1 (Y, A1, A2, B1, B2, C1);
	output Y;
	input A1, A2, B1, B2, C1;
	wire int_fwire_0, int_fwire_1, int_fwire_2;
	and (int_fwire_0, B1, B2);
	and (int_fwire_1, A1, A2);
	or (int_fwire_2, int_fwire_1, int_fwire_0, C1);
	not (Y, int_fwire_2);
endmodule
`endcelldefine
