module MAC_Filter
#(	
	parameter WORD_LENGTH = 16
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

MAC_Accumulator 
#(
	.WORD_LENGTH(WORD_LENGTH),
	.ROM_FILE("LPF.txt")
)
MAC_LPF_L	
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(1'b1),
	.DataInput(Channel_L),
	.sync_reset(shot_L),
	.DataOutput(LPF_L_wire)
);

MAC_Accumulator 
#(
	.WORD_LENGTH(WORD_LENGTH),
	.ROM_FILE("LPF.txt")
)
MAC_LPF_R	
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(1'b1),
	.DataInput(Channel_R),
	.sync_reset(shot_R),
	.DataOutput(LPF_R_wire)
);



MAC_Accumulator #(
	.WORD_LENGTH(WORD_LENGTH),
	.ROM_FILE("BPF.txt")
)
MAC_BPF_L	
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(1'b1),
	.DataInput(Channel_L),
	.sync_reset(shot_L),
	.DataOutput(BPF_L_wire)
);

MAC_Accumulator 
#(
	.WORD_LENGTH(WORD_LENGTH),
	.ROM_FILE("BPF.txt")
)
MAC_BPF_R	
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(1'b1),
	.DataInput(Channel_R),
	.sync_reset(shot_R),
	.DataOutput(BPF_R_wire)
);



MAC_Accumulator 
#(
	.WORD_LENGTH(WORD_LENGTH),
	.ROM_FILE("HPF.txt")
)
MAC_HPF_L	
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(1'b1),
	.DataInput(Channel_L),
	.sync_reset(shot_L),
	.DataOutput(HPF_L_wire)
);

MAC_Accumulator 
#(
	.WORD_LENGTH(WORD_LENGTH),
	.ROM_FILE("HPF.txt")
)
MAC_HPF_R	
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(1'b1),
	.DataInput(Channel_R),
	.sync_reset(shot_R),
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