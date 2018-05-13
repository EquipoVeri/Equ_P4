module MAC_Accumulator #(
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

wire [NBITS_FOR_COUNTER-1:0] counter_ROM_wire;
wire [NBITS_FOR_COUNTER-1:0] counter_RAM_wire;
wire [NBITS_FOR_COUNTER-1:0] counter_acc_wire;
wire [WORD_LENGTH-1:0] mux_wire;
wire [WORD_LENGTH-1:0] filter_Result_wire;
wire [WORD_LENGTH-1:0] coeficient_wire;
wire [WORD_LENGTH-1:0] result_wire;
wire [WORD_LENGTH-1:0] accumulator_wire;
wire flag_ROM_counter;


CounterWithFunction
#(
	.MAXIMUM_VALUE(WORD_LENGTH*2)
)
Counter_ROM
(
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.sync_reset(sync_reset),
	.count(counter_ROM_wire),
	.flag(flag_ROM_counter)
);

single_port_rom
#(
	.DATA_WIDTH(WORD_LENGTH), 
	.ADDR_WIDTH(NBITS_FOR_COUNTER),
	.ROM_FILE(ROM_FILE)
)
ROM
(
	.addr(counter_ROM_wire),
	.clk(clk), 
	.q(coeficient_wire)
);

CounterWithFunction
#(
	.MAXIMUM_VALUE(WORD_LENGTH*2)
)
Counter_RAM
(
	.clk(clk),
	.reset(reset),
	.enable(enable & flag_ROM_counter),
	.sync_reset(sync_reset),
	.count(counter_RAM_wire),
	.flag()
);

single_port_ram 
#(
	.DATA_WIDTH(WORD_LENGTH), 
	.ADDR_WIDTH(5)
)
RAM
(
	.data(result_wire),
	.addr(counter_acc_wire),
	.we(enable), 
	.clk(clk),
	.q(accumulator_wire)
);

Fixed_Point_MAC
#(
	.Word_Length(WORD_LENGTH),
	.Integer_Part(2)
)
MAC
(
	.A(coeficient_wire),
	.B(DataInput),
	.C(mux_wire),
	.D(result_wire)
);

Multiplexer2to1 
#(
	.NBits(WORD_LENGTH)
)
Mux_Zero 
(
	.Selector(flag_ROM_counter),
	.MUX_Data0(accumulator_wire),
	.MUX_Data1({WORD_LENGTH{1'b0}}),
	.MUX_Output(mux_wire)
);

Register 
#(
	.Word_Length(WORD_LENGTH)
)
Register_Bypass_R 
(
	.clk(clk),
	.reset(reset),
	.enable(sync_reset),
	.Data_Input(result_wire),
	.Data_Output(filter_Result_wire)
);

assign counter_acc_wire = counter_ROM_wire + counter_RAM_wire;
assign DataOutput = filter_Result_wire;

 /*--------------------------------------------------------------------*/
 /*Log Function*/
function integer CeilLog2;
	input integer data;
   integer i,result;
   begin
		for(i=0; 2**i < data; i=i+1)
			result = i + 1;
      CeilLog2 = result;
   end
endfunction
/*--------------------------------------------------------------------*/

endmodule 