module shift_register_er
#(
	parameter WORD_LENGTH = 11
)
(
    input clk,
    input reset,
    input enable,
    input d,
    output logic [WORD_LENGTH-1:0] q
);

//wire [WORD_LENGTH-1:0] q_w;

always_ff @(negedge reset or posedge clk)
	begin
		if (reset == 1'b0)
			q <= {WORD_LENGTH{1'b0}};
		else
			if (enable)
				q <= {q[WORD_LENGTH-2:0],d};
	end

//assign q = q_w;

endmodule
