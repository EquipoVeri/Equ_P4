module Retard_Generate
#(
	parameter WORD_LENGTH = 16,
	parameter FILTER_ORDER = 32
)
(
	input clk,
	input reset,
	input enable,
	input [WORD_LENGTH-1:0] DataInput,
	input [(FILTER_ORDER*WORD_LENGTH)-1:0] Coefficient,
	output [WORD_LENGTH-1:0] DataOutput
	
);

logic [(FILTER_ORDER + 1)*(WORD_LENGTH) - 1:0] DataAcumulator;
logic [(FILTER_ORDER + 1)*(WORD_LENGTH) - 1:0] DataRegister;


assign DataRegister[WORD_LENGTH - 1:0] = DataInput;
assign DataOutput = DataAcumulator[(FILTER_ORDER+1)*(WORD_LENGTH)-1:FILTER_ORDER*(WORD_LENGTH)];

localparam numofMult = FILTER_ORDER;
genvar i;

generate
	for(i=0 ; i <= numofMult-1; i=i+1) begin:retards
		Retard_Unit
		#(
			.WORD_LENGTH(WORD_LENGTH)
		)
		retard_u
		(
			.clk(clk),
			.reset(reset),
			.enable(enable),
			.DataInput(DataRegister[WORD_LENGTH*(i+1) - 1:WORD_LENGTH*i]),
			.DataAdd(DataAcumulator[WORD_LENGTH*(i+1) - 1:WORD_LENGTH*i]),
			.DataMult(Coefficient[WORD_LENGTH*(i+1) - 1:WORD_LENGTH*i]),
			.DataResult(DataAcumulator[WORD_LENGTH*(i+2) - 1:WORD_LENGTH*(i+1)]),
			.DataReg(DataRegister[WORD_LENGTH*(i+2) - 1:WORD_LENGTH*(i+1)])
		);
	end:retards
endgenerate

endmodule
