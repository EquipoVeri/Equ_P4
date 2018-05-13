module Multiplexer4to1
#(
	parameter NBits=16
)
(
	input [1:0] Selector,
	input [NBits-1:0] MUX_Data0,
	input [NBits-1:0] MUX_Data1,
	input [NBits-1:0] MUX_Data2,
	input [NBits-1:0] MUX_Data3,

	output reg [NBits-1:0] MUX_Output
);

	always@(*) begin
		case(Selector)
			2'b00: MUX_Output = MUX_Data0;
			2'b01: MUX_Output = MUX_Data1;
			2'b10: MUX_Output = MUX_Data2;
			2'b11: MUX_Output = MUX_Data3;

		endcase
		
	/*always@(Selector,MUX_Data3,MUX_Data2,MUX_Data1,MUX_Data0) begin
		if(Selector)
			MUX_Output = MUX_Data0;
		else
			MUX_Output = MUX_Data1;
	end	*/
		
	end

endmodule