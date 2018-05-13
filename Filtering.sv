module Filtering
#(	
	parameter WORD_LENGTH =16
)
(
	////////////////////	Clock Input	 	////////////////////	 
	input CLOCK_50,						//	50 MHz
	////////////////////	Push Button		////////////////////
	input reset,
	input [1:0] selector,
	////////////////////	I2C		////////////////////////////
	inout I2C_SDAT,						//	I2C Data
	output I2C_SCLK,						//	I2C Clock
	////////////////	Audio CODEC		////////////////////////
	output AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
	input AUD_ADCDAT,						//	Audio CODEC ADC Data
	inout AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
	output AUD_DACDAT,					//	Audio CODEC DAC Data
	inout AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
	output AUD_XCK							//	Audio CODEC Chip Clock
);

wire		AUD_CTRL_CLK;
wire		DLY_RST;
logic AUD_DACDAT_log;



Reset_Delay			
ResetModule	
(	.iCLK(CLOCK_50),
	.oRESET(DLY_RST)
);

Audio_PLL 		
PLL	
(	
	.areset(~DLY_RST),
	.inclk0(CLOCK_50),
	.c0(AUD_CTRL_CLK)
);


I2C_Module 		
I2C	(	//	Host Side
		.iCLK(CLOCK_50),
		.iRST_N(reset),
		//	I2C Side
		.I2C_SCLK(I2C_SCLK),
		.I2C_SDAT(I2C_SDAT)	);

AUDIO_DAC 			
u4	(	//	Audio Side
	.oAUD_BCK(AUD_BCLK),
	.oAUD_LRCK(AUD_DACLRCK),
	//	Control Signals
	 .iCLK_18_4(AUD_CTRL_CLK),
	.iRST_N(DLY_RST)	);

							
assign	AUD_ADCLRCK	=	AUD_DACLRCK;
assign	AUD_XCK		=	AUD_CTRL_CLK;


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////// USER ZONE ///////////////////////////////////////////////

/*
always_comb begin
	if(Selector)
		AUD_DACDAT_log = AUD_ADCDAT;
	else
		AUD_DACDAT_log = 0;
end
*/

assign AUD_DACDAT = AUD_DACDAT_log;


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

wire [WORD_LENGTH-1:0] data_chL_w;
wire [WORD_LENGTH-1:0] data_chR_w;

wire [WORD_LENGTH-1:0] LPF_L;
wire [WORD_LENGTH-1:0] LPF_R;

wire [WORD_LENGTH-1:0] BPF_L;
wire [WORD_LENGTH-1:0] BPF_R;

wire [WORD_LENGTH-1:0] HPF_L;
wire [WORD_LENGTH-1:0] HPF_R;

wire [WORD_LENGTH-1:0] Reg_Bypass_L;
wire [WORD_LENGTH-1:0] Reg_Bypass_R;

wire [WORD_LENGTH-1:0] Mux_L;
wire [WORD_LENGTH-1:0] Mux_R;

wire Serial_L;
wire Serial_R;

bit enable_shotR_b;
bit enable_shotL_b;
bit shot_R_b;
bit shot_L_b;

shift_register_er
#(
	.WORD_LENGTH(WORD_LENGTH)
)
register_input_chL
(
    .clk(AUD_BCLK),
    .reset(reset),
    .enable(~AUD_DACLRCK),
    .d(AUD_ADCDAT),
    .q(data_chL_w)
);

shift_register_er
#(
	.WORD_LENGTH(WORD_LENGTH)
)
register_input_chR
(
    .clk(AUD_BCLK),
    .reset(reset),
    .enable(AUD_DACLRCK),
    .d(AUD_ADCDAT),
    .q(data_chR_w)
);

One_Shot shot_L
(
	.clk(AUD_BCLK),
	.reset(reset),
	.Start(enable_shotL_b),
	.Shot(shot_L_b)
);

One_Shot shot_R
(
	.clk(AUD_BCLK),
	.reset(reset),
	.Start(enable_shotR_b),
	.Shot(shot_R_b)
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
	.enable(shot_L_b),
	.DataInput(data_chL_w),
	.Coefficient(LowPassFilter),
	.DataOutput(LPF_L)
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
	.enable(shot_R_b),
	.DataInput(data_chR_w),
	.Coefficient(LowPassFilter),
	.DataOutput(LPF_R)
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
	.enable(shot_L_b),
	.DataInput(data_chL_w),
	.Coefficient(BandPassFilter),
	.DataOutput(BPF_L)
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
	.enable(shot_R_b),
	.DataInput(data_chR_w),
	.Coefficient(BandPassFilter),
	.DataOutput(BPF_R)
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
	.enable(shot_L_b),
	.DataInput(data_chL_w),
	.Coefficient(HighPassFilter),
	.DataOutput(HPF_L)
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
	.enable(shot_R_b),
	.DataInput(data_chR_w),
	.Coefficient(HighPassFilter),
	.DataOutput(HPF_R)
);
 	
////////////// BYPASS REGISTERS ////////////

Register
#(
	.Word_Length(WORD_LENGTH)
)
bypass_L
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_L_b),
	.Data_Input(data_chL_w),
	.Data_Output(Reg_Bypass_L)
);

Register
#(
	.Word_Length(WORD_LENGTH)
)
bypass_R
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_R_b),
	.Data_Input(data_chR_w),
	.Data_Output(Reg_Bypass_R)
);

//////////MULTIPLEXERS///////////////////////////
Multiplexer4to1
#(
	.NBits(WORD_LENGTH)
)
mux_filters_L
(
	.Selector(selector),
	.MUX_Data0(Reg_Bypass_L),
	.MUX_Data1(LPF_L),
	.MUX_Data2(BPF_L),
	.MUX_Data3(HPF_L),
	.MUX_Output(Mux_L)
);

Multiplexer4to1
#(
	.NBits(WORD_LENGTH)
)
mux_filters_R
(
	.Selector(selector),
	.MUX_Data0(Reg_Bypass_R),
	.MUX_Data1(LPF_R),
	.MUX_Data2(BPF_R),
	.MUX_Data3(HPF_R),
	.MUX_Output(Mux_R)
);



/////////// TRANSMIT DATA TO DAC /////////////////////////

Serial_Send_Register
#(
	.LENGTH(WORD_LENGTH)
)
serial_reg_L
(
	.clk(AUD_BCLK),
	.reset(reset),
	.DataParalel_in(Mux_L),
	.enable(~AUD_DACLRCK),
	.DataOutput(Serial_L),
	.Flag(enable_shotL_b)
);

Serial_Send_Register
#(
	.LENGTH(WORD_LENGTH)
)
serial_reg_R
(
	.clk(AUD_BCLK),
	.reset(reset),
	.DataParalel_in(Mux_R),
	.enable(AUD_DACLRCK),
	.DataOutput(Serial_R),
	.Flag(enable_shotR_b)
);

Multiplexer2to1
#(
	.NBits(1)
)
mux_dac
(
	.Selector(AUD_DACLRCK),
	.MUX_Data0(Serial_L),
	.MUX_Data1(Serial_R),
	.MUX_Output(AUD_DACDAT_log)

);
 	
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

endmodule
