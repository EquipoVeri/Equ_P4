// Quartus II Verilog Template
// Single Port ROM

module single_port_rom #(
	// PARAMETERS
	parameter DATA_WIDTH=8, 
	parameter ADDR_WIDTH=8, 
	parameter ROM_FILE = "rom_values_init.txt") (
	// INPUTS
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	// OUTPUTS
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the ROM variable
	logic [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.
	initial
	begin
		$readmemh(ROM_FILE, rom);
	end

	always_ff @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule
