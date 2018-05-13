module Register #(
	// PARAMETERS
	parameter WORD_LENGTH = 16
) 
(
	// INPUTS
	input clk,
	input reset,
	input enable,
	input [WORD_LENGTH-1:0] Data_Input,
	// OUTPUTS
	output logic [WORD_LENGTH-1:0] Data_Output
);

// ---------------------------------------------------------------------------------------

always_ff@(posedge clk or negedge reset) begin: ThisIsARegister
	// Checking reset.
	if(reset == 1'b0) 
		Data_Output <= {WORD_LENGTH{1'b0}};
	else 
	 if(enable == 1'b1)
	 	// Assign input as output.
		Data_Output <= Data_Input;
end: ThisIsARegister

endmodule 