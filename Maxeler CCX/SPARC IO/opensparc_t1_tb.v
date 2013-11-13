`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:59:04 11/13/2013
// Design Name:   opensparc_t1
// Module Name:   F:/GitHub Repos/PLC4OpenSPARC/Maxeler CCX/SPARC IO/opensparc_t1_tb.v
// Project Name:  max_ccx_hw
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: opensparc_t1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module opensparc_t1_tb;

	// Inputs
	reg gclk;
	reg reset;
	reg max_cpx_valid;
	reg [31:0] max_cpx_data;
	reg max_cpx_ctl_valid;
	reg [31:0] max_cpx_ctl_data;
	reg max_pcx_read;

	// Outputs
	wire max_cpx_stall;
	wire max_cpx_ctl_stall;
	wire max_pcx_empty;
	wire max_pcx_almost_empty;
	wire [31:0] max_pcx_data;

	// Instantiate the Unit Under Test (UUT)
	opensparc_t1 uut (
		.max_cpx_stall(max_cpx_stall), 
		.max_cpx_ctl_stall(max_cpx_ctl_stall), 
		.max_pcx_empty(max_pcx_empty), 
		.max_pcx_almost_empty(max_pcx_almost_empty), 
		.max_pcx_data(max_pcx_data), 
		.gclk(gclk), 
		.reset(reset), 
		.max_cpx_valid(max_cpx_valid), 
		.max_cpx_data(max_cpx_data), 
		.max_cpx_ctl_valid(max_cpx_ctl_valid), 
		.max_cpx_ctl_data(max_cpx_ctl_data), 
		.max_pcx_read(max_pcx_read)
	);

	initial begin
		// Initialize Inputs
		gclk = 0;
		reset = 1;
		max_cpx_valid = 0;
		max_cpx_data = 0;
		max_cpx_ctl_valid = 0;
		max_cpx_ctl_data = 0;
		max_pcx_read = 0;

		// Wait 100 ns for global reset to finish
		#100;
      
		repeat(4)
			#10 gclk = ~gclk;
		reset = 0;
		forever
			#10 gclk = ~gclk;

	end
	
	initial begin
		#200;
		max_pcx_read = 1;
		
	end
      
endmodule

