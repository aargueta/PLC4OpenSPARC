`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:59:04 11/13/2013
// Design Name:   opensparc_t1
// Module Name:   F:/GitHub Repos/PLC4OpenSPARC/Maxeler CCX/SPARC IO/opensparc_t1_tb.v
// Project Name:  ccx_hw
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
	reg clk;
	reg rst;
	reg cpx_empty;
	reg cpx_almost_empty;
	reg [31:0] cpx_ctl;
	reg [31:0] cpx_data;
	reg pcx_stall;

	// Outputs
	wire cpx_read;
	wire pcx_valid;
	wire [31:0] pcx_data;

	// Instantiate the Unit Under Test (UUT)
	opensparc_t1 uut (
		.clk(clk),
		.rst(rst),
	
		.cpx_empty(cpx_empty),
		.cpx_almost_empty(cpx_almost_empty),
		.cpx_read(cpx_read),
		.cpx_data({cpx_ctl, cpx_data}),

		.pcx_valid(pcx_valid),
		.pcx_stall(pcx_stall),
		.pcx_data(pcx_data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		cpx_empty = 0;
		cpx_almost_empty = 0;
		cpx_ctl = 0;
		cpx_data = 0;
		pcx_stall = 0;

		// Wait 100 ns for global rst to finish
		#100;
      
		repeat(4)
			#5 clk = ~clk;
		rst = 0;
		forever
			#5 clk = ~clk;

	end
	
	initial begin
		#200;
		while(~cpx_read)
			#10;

		cpx_empty = 0;
		cpx_ctl = 32'h00000018;
		cpx_data = 32'h00017000; 
		#10 cpx_data = 32'h00000000;
			cpx_ctl = 32'h00000010;
		
		#10 cpx_data = 32'h00010001;
		#10 cpx_data = 32'h00000000;
		#10 cpx_data = 32'h00010001;
		#10 cpx_data = 32'h00000002;
			cpx_ctl = 32'h00000000;
		#10 cpx_data = 32'h00000000;
		#10 cpx_data = 32'h00000000;
		#10 cpx_empty = 1;
		
		while(~pcx_valid)
			#10;

		cpx_empty = 0;
		cpx_ctl = 32'h00000018;
		cpx_data = 32'h00011904; 
		#10 cpx_data = 32'h38008030;
			cpx_ctl = 32'h00000010;
		
		#10 cpx_data = 32'h00000000;
		#10 cpx_data = 32'h00000000;
		#10 cpx_data = 32'h00000000;
		#10 cpx_data = 32'h00000000;
			cpx_ctl = 32'h00000000;
		#10 cpx_data = 32'h00000000;
		#10 cpx_data = 32'h00000000;
		#10 cpx_empty = 1;
	end
      
endmodule

