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
	reg [31:0] rst_en;
	reg cpx_almost_empty;
	reg [31:0] cpx_ctl;
	reg [31:0] cpx_data;
	reg pcx_stall;

	reg send;
	reg [159:0] cpx_pkt;

	// Outputs
	wire cpx_read;
	wire pcx_valid;
	wire [31:0] pcx_data;

	wire cpx_empty;
	wire [63:0] cpx_chunk;
	wire sent;

	// Instantiate the Unit Under Test (UUT)
	opensparc_t1 uut (
		.clk(clk),
		.rst(rst),
		.rst_en(rst_en),
		
		.cpx_empty(cpx_empty),
		.cpx_almost_empty(cpx_almost_empty),
		.cpx_read(cpx_read),
		.cpx_data(cpx_chunk),//{cpx_ctl, cpx_data}),

		.pcx_valid(pcx_valid),
		.pcx_stall(pcx_stall),
		.pcx_data(pcx_data)
	);

	send_cpx_pkt sender(
		.clk(clk),
		.rst(rst),
		.send(send),
		.cpx_pkt(cpx_pkt),
		.read(cpx_read),
		.cpx_chunk(cpx_chunk),
		.cpx_empty(cpx_empty),
		.sent(sent)
	);	

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		rst_en = 32'd1;
		//cpx_empty = 0;
		cpx_almost_empty = 0;
		cpx_ctl = 0;
		cpx_data = 0;
		pcx_stall = 0;
		send = 0;
		cpx_pkt = 0;

		// Wait 100 ns for global rst to finish
		#100;
      
		repeat(4)
			#5 clk = ~clk;
		rst = 0;
		rst_en = 32'd0;
		forever
			#5 clk = ~clk;

	end
	
	initial begin
		#200;
		#10 send = 1'b1;
		cpx_pkt = {32'h00017000, 32'h00000000, 32'h00010001, 32'h00000000, 32'h00010001};
		while(~sent)
			#10;
		send = 0;
		while(~pcx_valid)
			#10;
		
		send = 1'b1;
		cpx_pkt = {32'h00011904, 32'h38008030, 32'h00000000, 32'h00000000, 32'h00000000};
		while(~sent)
			#10;
		send = 0;
		while(~pcx_valid)
			#10;
		
		send = 1'b1;
		cpx_pkt = {32'h00011904, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000};
		while(~sent)
			#10;
		send = 0;
		while(~pcx_valid)
			#10;
		
		send = 1'b1;
		cpx_pkt = {32'h00011904, 32'h02201082, 32'ha5008030, 32'h00000000, 32'h00000000};
		while(~sent)
			#10;
		send = 0;
		while(~pcx_valid)
			#10;
		
		send = 1'b1;
		cpx_pkt = {32'h00011904, 32'hc0286001, 32'hc0286002, 32'h86102006, 32'hc6286002};
		while(~sent)
			#10;
		send = 0;
		while(~pcx_valid)
			#10;
		
		/*#10 rst = 1'b0;
		cpx_empty = 0;
		cpx_ctl = 32'h00000018;
		cpx_data = 32'h00017000; 
		#10 cpx_data = 32'h00000000;
			 cpx_ctl = 32'h00000010;
		
		#10 cpx_data = 32'h00010001;
		#10 cpx_data = 32'h00000000;
		#10 cpx_data = 32'h00010001;
		#10 cpx_data = 32'h0BAD0BAD;
			cpx_ctl = 32'h0;
		#10 cpx_data = 32'h0BAD0BAD;
		#10 cpx_data = 32'h0BAD0BAD;
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
		#10 cpx_empty = 1;*/
		
	end
      
endmodule

