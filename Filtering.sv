module Filtering (
	////////////////////	Clock Input	////////////////////	 
	input CLOCK_50,						//	50 MHz
	////////////////////	Push Button	////////////////////
	input reset,
	input [2:0] Selector,
	//////////////////// 	I2C		////////////////////
	inout I2C_SDAT,						//	I2C Data
	output I2C_SCLK,						//	I2C Clock
	/////////////////// Audio CODEC	////////////////////
	output AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
	input AUD_ADCDAT,						//	Audio CODEC ADC Data
	inout AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
	output AUD_DACDAT,					//	Audio CODEC DAC Data
	inout AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
	output AUD_XCK							//	Audio CODEC Chip Clock
);


wire AUD_CTRL_CLK;
wire DLY_RST;
logic AUD_DACDAT_log;

// ---------------------------------------------------------------------------------------
// CODEC modules.

Reset_Delay	ResetModule	(	
	.iCLK(CLOCK_50),
	.oRESET(DLY_RST)
);

Audio_PLL PLL (	
	.areset(~DLY_RST),
	.inclk0(CLOCK_50),
	.c0(AUD_CTRL_CLK)
);


I2C_Module I2C	(
	//	Host Side
	.iCLK(CLOCK_50),
	.iRST_N(reset),
	//	I2C Side
	.I2C_SCLK(I2C_SCLK),
	.I2C_SDAT(I2C_SDAT)
);

AUDIO_DAC u4 (
	//	Audio Side
	.oAUD_BCK(AUD_BCLK),
	.oAUD_LRCK(AUD_DACLRCK),
	//	Control Signals
	.iCLK_18_4(AUD_CTRL_CLK),
	.iRST_N(DLY_RST)
);

// ---------------------------------------------------------------------------------------
// Assign CODEC signals.
	
assign AUD_ADCLRCK	=	AUD_DACLRCK;
assign AUD_XCK			=	AUD_CTRL_CLK;
assign AUD_DACDAT 	= AUD_DACDAT_log; 	


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////// USER ZONE ///////////////////////////////////////////////

always_comb begin
	if(Selector)
		AUD_DACDAT_log = AUD_ADCDAT;
	else
		AUD_DACDAT_log = 0;
end

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

endmodule