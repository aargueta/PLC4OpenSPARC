`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    06:19:02 11/11/2013 
// Design Name: 
// Module Name:    opensparc_t1 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
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
module opensparc_t1(
	// Outputs
	max_cpx_stall, 

	max_cpx_ctl_stall, 

	max_pcx_empty,
	max_pcx_almost_empty,
	max_pcx_data,

	// Inputs
	gclk,
	reset,

	max_cpx_valid,
	max_cpx_data,

	max_cpx_ctl_valid,
	max_cpx_ctl_data,

	max_pcx_read
 );
 
	//=============================================
	// Outputs

	// Maxeler Interface
	output max_cpx_stall;
    output max_cpx_ctl_stall;

	output max_pcx_empty;
	output max_pcx_almost_empty;
	output [`MAX_D_WIDTH-1:0] max_pcx_data;

	//=============================================
	// Inputs
	input gclk;
	input reset;

	// Maxeler Interface
	input max_cpx_valid;
	input [`MAX_D_WIDTH-1:0] max_cpx_data;
	input max_cpx_ctl_valid;
	input [`MAX_D_WIDTH-1:0] max_cpx_ctl_data;

	input max_pcx_read;
	
	
    // SPARC/PCX interface
    reg [15:0] packet_count;
    reg [1:0] idle_count;
    always @(posedge gclk)begin
    	if(reset)begin
    		packet_count <= 16'd0;
    		idle_count <= 16'd0;
		end else
			{packet_count, idle_count} <= {packet_count, idle_count} + 18'd1;
    end 

    wire [`PCX_WIDTH-1:0] spc_pcx_data_pa = {{3{16'hABCD, packet_count}}, 12'h123, packet_count};
    wire                  spc_pcx_atom_pq = 0;
    wire [4:0]            spc_pcx_req_pq = {4'b0000, &idle_count};
	
    // SPARC/PCX interface
    wire [4:0] pcx_spc_grant_px;

    // SPARC/CPX interface
    wire                  cpx_spc_data_rdy_cx2;
    wire [`CPX_WIDTH-1:0] cpx_spc_data_cx2;
	 
	ccx2max ccx(
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

endmodule
