
 module Fixed_Point_MAC
#(
	parameter Word_Length = 6,
	parameter Integer_Part = 3,
	parameter Fractional_Part = Word_Length - Integer_Part
)
(
	// Input Ports
	input signed [Word_Length-1:0] A,B,C,

	// Output Ports
	output signed[Word_Length-1:0] D
);

logic signed  [2*Word_Length-1:0] X_wire;
logic signed [Word_Length-1:0] X_Trunc_wire, D_wire;


always_comb
begin
	X_wire = A * B;
	X_Trunc_wire = X_wire[2*Word_Length-1-Integer_Part:Fractional_Part];
	D_wire = X_Trunc_wire + C;
end

assign D = D_wire;

endmodule
