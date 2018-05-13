 module Register
#(
	parameter Word_Length = 8
)

(
	// Input Ports
	input clk,
	input reset,
	input enable,
	input [Word_Length-1:0] Data_Input,

	// Output Ports
	output [Word_Length-1:0] Data_Output
);

logic  [Word_Length-1:0] Data_logic;

always_ff@(posedge clk or negedge reset) begin: ThisIsARegister
	if(reset == 1'b0) 
		Data_logic <= 0;
	else 
		if(enable == 1'b1)
			Data_logic <= Data_Input;
end: ThisIsARegister

assign Data_Output = Data_logic;

endmodule