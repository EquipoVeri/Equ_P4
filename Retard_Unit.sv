module Retard_Unit
#(
	parameter WORD_LENGTH = 16
)
(
	input clk,
	input reset,
	input enable,
	input [WORD_LENGTH-1:0] DataInput,
	input [WORD_LENGTH-1:0] DataAdd,
	input [WORD_LENGTH-1:0] DataMult,
	output [WORD_LENGTH-1:0] DataResult,
	output [WORD_LENGTH-1:0] DataReg
);

Fixed_Point_MAC
#(
	.Word_Length(WORD_LENGTH),
	.Integer_Part(2)
)
fixed_point
(
	.A(DataInput),
	.B(DataMult),
	.C(DataAdd),
	.D(DataResult)
);

Register
#(
	.Word_Length(WORD_LENGTH)
)
reg_retard
(
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.Data_Input(DataInput),
	.Data_Output(DataReg)
);


endmodule
