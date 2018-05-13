MAC_Filter
#(	
	parameter WORD_LENGTH =16
)
(
	////////////////////	Clock Input	 	////////////////////	 
	input CLOCK_50,						//	50 MHz
	////////////////////	Push Button		////////////////////
	input reset,
	////////////////	Audio CODEC		////////////////////////
	inout AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
	input shot_R,
	input shot_L,
	input [WORD_LENGTH-1:0] Channel_R,
	input [WORD_LENGTH-1:0] Channel_L,
	output [WORD_LENGTH-1:0] LPF_L,
	output [WORD_LENGTH-1:0] LPF_R,
	output [WORD_LENGTH-1:0] BPF_L,
	output [WORD_LENGTH-1:0] BPF_R,
	output [WORD_LENGTH-1:0] HPF_L,
	output [WORD_LENGTH-1:0] HPF_R
);

wire [WORD_LENGTH-1:0] LPF_L_wire;
wire [WORD_LENGTH-1:0] LPF_R_wire;

wire [WORD_LENGTH-1:0] BPF_L_wire;
wire [WORD_LENGTH-1:0] BPF_R_wire;

wire [WORD_LENGTH-1:0] HPF_L_wire;
wire [WORD_LENGTH-1:0] HPF_R_wire;

MAC_Accumulator #(
	// PARAMETERS
	parameter WORD_LENGTH = 16,
	parameter NBITS_FOR_COUNTER = CeilLog2(WORD_LENGTH*2),
	parameter ROM_FILE = "LPF.txt"
)	
(
	//INPUTS
	input clk,
	input reset,
	input [WORD_LENGTH-1:0] DataInput,
	input enable,
	input sync_reset,
	//OUTPUTS
	output [WORD_LENGTH-1:0] DataOutput
);

/////////////////////////////////FILTER IMPLEMENTATION////////////////////////////////

Retard_Generate
#(
	.WORD_LENGTH(WORD_LENGTH),
	.FILTER_ORDER(32)
)
retard_LPF_L
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_L),
	.DataInput(Channel_L),
	.Coefficient(LowPassFilter),
	.DataOutput(LPF_L_wire)
);

Retard_Generate
#(
	.WORD_LENGTH(WORD_LENGTH),
	.FILTER_ORDER(32)
)
retard_LPF_R
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_R),
	.DataInput(Channel_R),
	.Coefficient(LowPassFilter),
	.DataOutput(LPF_R_wire)
);

Retard_Generate
#(
	.WORD_LENGTH(WORD_LENGTH),
	.FILTER_ORDER(32)
)
retard_BPF_L
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_L),
	.DataInput(Channel_L),
	.Coefficient(BandPassFilter),
	.DataOutput(BPF_L_wire)
);

Retard_Generate
#(
	.WORD_LENGTH(WORD_LENGTH),
	.FILTER_ORDER(32)
)
retard_BPF_R
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_R),
	.DataInput(Channel_R),
	.Coefficient(BandPassFilter),
	.DataOutput(BPF_R_wire)
);

Retard_Generate
#(
	.WORD_LENGTH(WORD_LENGTH),
	.FILTER_ORDER(32)
)
retard_HPF_L
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_L),
	.DataInput(Channel_L),
	.Coefficient(HighPassFilter),
	.DataOutput(HPF_L_wire)
);

Retard_Generate
#(
	.WORD_LENGTH(WORD_LENGTH),
	.FILTER_ORDER(32)
)
retard_HPF_R
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_R),
	.DataInput(Channel_R),
	.Coefficient(HighPassFilter),
	.DataOutput(HPF_R_wire)
);

assign LPF_L = LPF_L_wire;
assign LPF_R = LPF_R_wire;
assign BPF_L = BPF_L_wire;
assign BPF_R = BPF_R_wire;
assign HPF_L = HPF_L_wire;
assign HPF_R = HPF_R_wire;
 	
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

endmodule 