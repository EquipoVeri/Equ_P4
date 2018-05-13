module Serial_Send_Register#(
	// PARAMETERS
	parameter LENGTH = 8) (
	// INPUTS
	input clk,
	input reset,
	input [LENGTH - 1:0] DataParalel_in,
	input enable,
	// OUTPUTS
	output logic DataOutput,
	output logic Flag
);

// Internal register used to store the parallel data in.
logic [3:0] Counter;
bit MaxValue_Bit;
// ---------------------------------------------------------------------------------------

always_ff@(posedge clk or negedge reset) begin:Register_conditions
	// Check for reset.
	if(reset == 1'b0) 
		Counter <= {4{1'b1}};
	// Check if normal enable.
	else if(enable == 1'b1)begin
		if(Counter == 0)
			Counter <= LENGTH - 1'b1;
		else
			Counter <= Counter - 1'b1;		
	end
end:Register_conditions

// ---------------------------------------------------------------------------------------

// Calculate when to turn on flag.
always_comb begin
if(Counter == 0)
	MaxValue_Bit = 1'b1;
else
	MaxValue_Bit = 1'b0;
end

assign Flag = MaxValue_Bit;

// Assign LSB to simulate PISO register.
assign DataOutput = DataParalel_in[Counter];

endmodule
	