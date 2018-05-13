module Multiplexer2to1 #(
	// PARAMETERS
	parameter NBits=32) (
	// INPUTS
	input  Selector,
	input  [NBits-1:0] MUX_Data0,
	input  [NBits-1:0] MUX_Data1,
	// OUTPUTS
	output logic[NBits-1:0] MUX_Output
);

//---------------------------------------------------------------------------------------------

// This is a simple 2 to 1 mux. 
always_comb 
begin
	if(Selector)
		MUX_Output = MUX_Data1;
	else
		MUX_Output = MUX_Data0;
end

endmodule 