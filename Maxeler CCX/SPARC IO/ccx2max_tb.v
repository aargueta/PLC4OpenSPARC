`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:04:37 11/11/2013
// Design Name:   ccx2max
// Module Name:   F:/GitHub Repos/PLC4OpenSPARC/Maxeler CCX/SPARC IO/ccx2max_tb.v
// Project Name:  max_ccx_hw
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ccx2max
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`ifndef FSL_D_WIDTH
`define FSL_D_WIDTH  32
`endif

`ifndef PCX_WIDTH
`define PCX_WIDTH   124
`endif

`ifndef CPX_WIDTH
`define CPX_WIDTH   145
`endif
`define MAX_D_WIDTH 32

`define FIRST_CHUNK 29'd1
`define FOLLOWING_CHUNK	29'd0

`define NOT_ATOMIC_MASK 32'hFFFDFFFF

module ccx2max_tb;
	
	reg [2:0] packet_num;

	// Inputs
	reg gclk;
	reg reset;
	reg [`PCX_WIDTH-1:0] spc_pcx_data_pa;
	reg spc_pcx_atom_pq;
	reg [4:0] spc_pcx_req_pq;
	reg max_cpx_valid;
	reg [31:0] max_cpx_data;
	reg max_pcx_read;
	reg max_cpx_ctl_valid;
	reg [31:0] max_cpx_ctl_data;

	// Outputs
	wire [4:0] pcx_spc_grant_px;
	wire cpx_spc_data_rdy_cx2;
	wire [`CPX_WIDTH-1:0] cpx_spc_data_cx2;
	wire max_cpx_stall;
	wire max_pcx_empty;
	wire max_pcx_almost_empty;
	wire [31:0] max_pcx_data;
	wire max_cpx_ctl_stall;

	// Instantiate the Unit Under Test (UUT)
	ccx2max uut (
		.pcx_spc_grant_px(pcx_spc_grant_px), 
		.cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2), 
		.cpx_spc_data_cx2(cpx_spc_data_cx2), 
		.max_cpx_stall(max_cpx_stall), 
		.max_cpx_ctl_stall(max_cpx_ctl_stall), 
		.max_pcx_empty(max_pcx_empty), 
		.max_pcx_almost_empty(max_pcx_almost_empty), 
		.max_pcx_data(max_pcx_data), 
		.gclk(gclk), 
		.reset(reset), 
		.spc_pcx_data_pa(spc_pcx_data_pa), 
		.spc_pcx_atom_pq(spc_pcx_atom_pq), 
		.spc_pcx_req_pq(spc_pcx_req_pq), 
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
		spc_pcx_data_pa = 0;
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		max_cpx_valid = 0;
		max_cpx_data = 0;
		max_pcx_read = 0;
		max_cpx_ctl_valid = 0;
		max_cpx_ctl_data = 0;
		packet_num = 0;

		// Wait 100 ns for global reset to finish
		#100;
		repeat(4)
			#10 gclk = ~gclk;
		reset = 0;
		forever
			#10 gclk = ~gclk;
	end
	
	initial begin
		#160;
		spc_pcx_data_pa =  {28'hDEAD111, 32'h1A1B1C1D, 32'h2A1B1C1D, 32'h3A1B1C1D};
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 1;
		#10
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		#160
		spc_pcx_data_pa =  {28'hDEAD222, 32'h1A2B2C2D, 32'h2A2B2C2D, 32'h3A2B2C2D};
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 1;
		#10
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		#160
		spc_pcx_data_pa =  {28'hDEAD333, {3{32'h3A3B3C3D}}};
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 1;
		#10
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		#160
		spc_pcx_data_pa =  {28'hDEAD4444, {3{32'h4A4B4C4D}}};
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 1;
		#10
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		max_pcx_read = 1;
	end
	
	initial begin
		#160;
		max_cpx_data = 32'h0;
		max_pcx_read = 0;
		repeat(3)begin
			max_cpx_valid = 1;
			max_cpx_ctl_valid = 1;
			max_cpx_data = {max_cpx_data[31:16] + 16'd1, 16'd0} & `NOT_ATOMIC_MASK;

			packet_num = 3'd0;
			max_cpx_ctl_data = {`FIRST_CHUNK, packet_num};
			repeat(4)begin
				#20 max_cpx_data = (max_cpx_data + 32'h1) & `NOT_ATOMIC_MASK;
				packet_num = packet_num + 3'd1;
				max_cpx_ctl_data = {`FOLLOWING_CHUNK, packet_num};
			end
			#20 max_cpx_valid = 0;
			#160;
		end
		max_pcx_read = 1;
	end
      
endmodule

