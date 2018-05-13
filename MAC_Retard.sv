module MAC_Retard
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


wire [527:0] BandPassFilter = {
16'hffed,
16'hffd1,
16'hff9e,
16'hff4a,
16'hfed4,
16'hfe4c,
16'hfdd5,
16'hfd9f,
16'hfdd7,
16'hfea2,
16'h0005,
16'h01e5,
16'h0406,
16'h0612,
16'h07b0,
16'h0895,
16'h0895,
16'h07b0,
16'h0612,
16'h0406,
16'h01e5,
16'h0005,
16'hfea2,
16'hfdd7,
16'hfd9f,
16'hfdd5,
16'hfe4c,
16'hfed4,
16'hff4a,
16'hff9e,
16'hffd1,
16'hffed,
16'h0000
};

wire  [527:0] LowPassFilter = {
16'h002f,
16'h0039,
16'h0050,
16'h0077,
16'h00ae,
16'h00f4,
16'h0148,
16'h01a7,
16'h020e,
16'h0278,
16'h02e0,
16'h0340,
16'h0394,
16'h03d8,
16'h0407,
16'h0420,
16'h0420,
16'h0407,
16'h03d8,
16'h0394,
16'h0340,
16'h02e0,
16'h0278,
16'h020e,
16'h01a7,
16'h0148,
16'h00f4,
16'h00ae,
16'h0077,
16'h0050,
16'h0039,
16'h002f,
16'h0000
};

wire [527:0] HighPassFilter = {
16'hffe6,
16'hffea,
16'hfff6,
16'h0015,
16'h004e,
16'h009b,
16'h00e0,
16'h00f0,
16'h0095,
16'hffa7,
16'hfe1b,
16'hfc12,
16'hf9d5,
16'hf7cc,
16'hf65f,
16'h35c0,
16'hf65f,
16'hf7cc,
16'hf9d5,
16'hfc12,
16'hfe1b,
16'hffa7,
16'h0095,
16'h00f0,
16'h00e0,
16'h009b,
16'h004e,
16'h0015,
16'hfff6,
16'hffea,
16'hffe6,
16'h0000,
16'h0000
};


wire [WORD_LENGTH-1:0] LPF_L_wire;
wire [WORD_LENGTH-1:0] LPF_R_wire;

wire [WORD_LENGTH-1:0] BPF_L_wire;
wire [WORD_LENGTH-1:0] BPF_R_wire;

wire [WORD_LENGTH-1:0] HPF_L_wire;
wire [WORD_LENGTH-1:0] HPF_R_wire;

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