module P4 
#(
	//Parameters
	parameter WORD_LENGTH = 16
)
(
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

wire [WORD_LENGTH-1:0] DataChannel_L;
wire [WORD_LENGTH-1:0] DataChannel_R;
wire [WORD_LENGTH-1:0] Reg_Bypass_L;
wire [WORD_LENGTH-1:0] Reg_Bypass_R;

Filtering Filtering(
	.CLOCK_50,
	.reset,
	.Selector,
	.I2C_SDAT,
	.I2C_SCLK,
	.AUD_ADCLRCK,
	.AUD_ADCDAT,
	.AUD_DACLRCK,
	.AUD_DACDAT,
	.AUD_BCLK,
	.AUD_XCK,
);

// ---------------------------------------------------------------------------------------
// Converting the serial data from the CODEC into parallel data.

Register_MAC 
#(
	.WORD_LENGTH(WORD_LENGTH)
)	
Serial_Register_L 
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(~AUD_DACLRCK),
	.Data_Input(AUD_ADCDAT),
	.Data_Output(DataChannel_L)
);

Register_MAC 
#(
	.WORD_LENGTH(WORD_LENGTH)
)
Serial_Register_R 
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(AUD_DACLRCK),
	.Data_Input(AUD_ADCDAT),
	.Data_Output(DataChannel_R)
);

// ---------------------------------------------------------------------------------------
// Bypass registers of parallel data in to syncronize filters and AUD_DACLRCK edges.

Register 
#(
	.WORD_LENGTH(WORD_LENGTH)
)
Register_Bypass_R 
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(),
	.Data_Input(DataChannel_R),
	.Data_Output(Reg_Bypass_R)
);

Register 
#(
	.WORD_LENGTH(WORD_LENGTH)
)
Register_Bypass_L 
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(),
	.Data_Input(DataChannel_L),
	.Data_Output(Reg_Bypass_L)
);

// ---------------------------------------------------------------------------------------
//Filters with single MAC accumulator.

MAC_Accumulator 
#(
	.WORD_LENGTH(WORD_LENGTH),
	.ROM_FILE("LPF.txt")
)	
Low_Pass_MAC_filter_L
(
	.clk(AUD_BCLK),
	.reset(reset),
	.DataInput(Reg_Bypass_L),
	.enable(1'b1),
	.sync_reset(),
	.DataOutput()
);

endmodule 