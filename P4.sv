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
wire [WORD_LENGTH-1:0] Mux_L;
wire [WORD_LENGTH-1:0] Mux_R;
wire [WORD_LENGTH-1:0] data_chL_w;
wire [WORD_LENGTH-1:0] data_chR_w;
wire [WORD_LENGTH-1:0] LPF_L_wire;
wire [WORD_LENGTH-1:0] LPF_R_wire;

wire [WORD_LENGTH-1:0] BPF_L_wire;
wire [WORD_LENGTH-1:0] BPF_R_wire;

wire [WORD_LENGTH-1:0] HPF_L_wire;
wire [WORD_LENGTH-1:0] HPF_R_wire;
wire I2C_SCLK_wire;
wire AUD_XCK_wire;
wire AUD_DACDAT_wire;
wire AUD_ADCLRCK_wire;
wire Serial_L;
wire Serial_R;
bit enable_shotR_b;
bit enable_shotL_b;
logic AUD_DACDAT_log;

Filtering Filtering(
	.CLOCK_50,
	.reset,
	.Selector,
	.I2C_SDAT,
	.I2C_SCLK,
	.AUD_ADCLRCK,
	.AUD_ADCDAT,
	.AUD_DACLRCK,
	//.AUD_DACDAT,
	.AUD_BCLK,
	.AUD_XCK
);

MAC_Retard
#(	
	.WORD_LENGTH(WORD_LENGTH)
)
MAC_Retard_Generate
(
	.CLOCK_50,
	.reset,
	.AUD_BCLK,
	.shot_R(shot_R_b),
	.shot_L(shot_L_b),
	.Channel_R(DataChannel_R),
	.Channel_L(DataChannel_L),
	.LPF_L(LPF_L_wire),
	.LPF_R(LPF_R_wire),
	.BPF_L(BPF_L_wire),
	.BPF_R(BPF_R_wire),
	.HPF_L(HPF_L_wire),
	.HPF_R(HPF_R_wire)
);

// ---------------------------------------------------------------------------------------
// Converting the serial data from the CODEC into parallel data.

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
    .q(DataChannel_L)
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
    .q(DataChannel_R)
);

// ---------------------------------------------------------------------------------------
// One shots enable the filters at the appropriate AUD_DACLRCK edges.

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

// ---------------------------------------------------------------------------------------
// Bypass registers of parallel data in to syncronize filters and AUD_DACLRCK edges.

////////////// BYPASS REGISTERS ////////////

Register 
#(
	.Word_Length(WORD_LENGTH)
)
Register_Bypass_R 
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_R_b),
	.Data_Input(DataChannel_R),
	.Data_Output(Reg_Bypass_R)
);

Register 
#(
	.Word_Length(WORD_LENGTH)
)
Register_Bypass_L 
(
	.clk(AUD_BCLK),
	.reset(reset),
	.enable(shot_L_b),
	.Data_Input(DataChannel_L),
	.Data_Output(Reg_Bypass_L)
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

//////////MULTIPLEXERS///////////////////////////
Multiplexer4to1
#(
	.NBits(WORD_LENGTH)
)
mux_filters_L
(
	.Selector(Selector),
	.MUX_Data0(Reg_Bypass_L),
	.MUX_Data1(LPF_L_wire),
	.MUX_Data2(BPF_L_wire),
	.MUX_Data3(HPF_L_wire),
	.MUX_Output(Mux_L)
);

Multiplexer4to1
#(
	.NBits(WORD_LENGTH)
)
mux_filters_R
(
	.Selector(Selector),
	.MUX_Data0(Reg_Bypass_R),
	.MUX_Data1(LPF_R_wire),
	.MUX_Data2(BPF_R_wire),
	.MUX_Data3(HPF_R_wire),
	.MUX_Output(Mux_R)
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

assign AUD_DACDAT = AUD_DACDAT_log;

endmodule 