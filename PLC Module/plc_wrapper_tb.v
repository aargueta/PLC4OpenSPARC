`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:00:32 12/04/2013
// Design Name:   plc_wrapper
// Module Name:   F:/GitHub Repos/PLC4OpenSPARC/Maxeler CCX/SPARC IO/plc_wrapper_tb.v
// Project Name:  max_ccx_hw
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: plc_wrapper
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module plc_wrapper_tb;

	// Inputs
	reg clk;
	reg rst;
	reg add_to_list;
	reg [7:0] addr_in;
	reg [3:0] way_in;
	reg read_enable_in;
	reg alt_mx_sel_in;
	reg write_enable;
	reg [63:0] data;

	// Outputs
	wire [7:0] addr_out;
	wire [3:0] way_out;
	wire read_enable_out;
	wire alt_mx_sel_out;
	wire plc_error_found;

	// Instantiate the Unit Under Test (UUT)
	plc_wrapper uut (
		.clk(clk), 
		.rst(rst), 
		.add_to_list(add_to_list), 
		.addr_in(addr_in), 
		.way_in(way_in), 
		.read_enable_in(read_enable_in), 
		.alt_mx_sel_in(alt_mx_sel_in), 
		.addr_out(addr_out), 
		.way_out(way_out), 
		.read_enable_out(read_enable_out), 
		.alt_mx_sel_out(alt_mx_sel_out), 
		.write_enable(write_enable), 
		.data(data), 
		.plc_error_found(plc_error_found)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		add_to_list = 0;
		addr_in = 0;
		way_in = 0;
		read_enable_in = 0;
		alt_mx_sel_in = 0;
		write_enable = 0;
		data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		repeat(4)
			#5 clk = ~clk;
		rst = 0;
		forever
			#5 clk = ~clk;

	end
	
	initial begin
		#200;
		add_to_list = 1;
		#10;
		add_to_list = 0;
		addr_in = 8'hAB;
		way_in = 4'hC;
		write_enable = 1;
		#10;
		write_enable = 0;
		#10;
		add_to_list = 1;
		#10;
		add_to_list = 0;
		addr_in = 8'hDE;
		way_in = 4'hF;
		write_enable = 1;
		#10;
		write_enable = 0;
	end
      
endmodule

