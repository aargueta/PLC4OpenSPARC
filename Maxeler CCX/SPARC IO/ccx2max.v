`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:18:26 11/03/2013 
// Design Name: 
// Module Name:    ccx2max 
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

`include "ccx2mb.h"
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
module ccx2max(
	// Outputs
	pcx_spc_grant_px,

	cpx_spc_data_rdy_cx2,
	cpx_spc_data_cx2,

	max_cpx_read, 

	max_pcx_valid,
	max_pcx_data,

	// Inputs
	gclk,
	reset,
	core_reset_done,

	spc_pcx_data_pa,
	spc_pcx_atom_pq,
	spc_pcx_req_pq,

	max_cpx_valid,
	max_cpx_data,
	max_cpx_ctl_data,
	max_cpx_empty,
	max_cpx_almost_empty,

	max_pcx_stall
);
   
    //=============================================
    // Outputs

    // SPARC/PCX interface
    output [4:0] pcx_spc_grant_px;

    // SPARC/CPX interface
    output                  cpx_spc_data_rdy_cx2;
    output [`CPX_WIDTH-1:0] cpx_spc_data_cx2;

    // Maxeler Interface
    output max_cpx_read;

    output 					  max_pcx_valid;
    output [`MAX_D_WIDTH-1:0] max_pcx_data;

    //=============================================
    // Inputs
    input gclk;
    input reset;
	 input core_reset_done;

    // SPARC/PCX interface
    input [`PCX_WIDTH-1:0] spc_pcx_data_pa;
    input                  spc_pcx_atom_pq;
    input [4:0]            spc_pcx_req_pq;

    // Maxeler Interface
	input max_cpx_valid;
	input [`MAX_D_WIDTH-1:0] max_cpx_data;
	input [`MAX_D_WIDTH-1:0] max_cpx_ctl_data;
	input max_cpx_empty;
	input max_cpx_almost_empty;

	input max_pcx_stall;

    //=============================================
	ccx2mb ccx2mb (
		// Outputs
		.pcx_spc_grant_px(pcx_spc_grant_px),
		.pcx_fsl_m_control(),
		.pcx_fsl_m_data(max_pcx_data),
		.pcx_fsl_m_write(max_pcx_valid),

		.cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2),
		.cpx_spc_data_cx2(cpx_spc_data_cx2),

		.cpx_fsl_s_read(max_cpx_read),

		// Inputs
		.gclk(gclk),
		.reset_l(~reset),

		.spc_pcx_data_pa(spc_pcx_data_pa),
		.spc_pcx_atom_pq(spc_pcx_atom_pq),
		.spc_pcx_req_pq(spc_pcx_req_pq),

		.fsl_pcx_m_full(max_pcx_stall),

		.fsl_cpx_s_exists(core_reset_done & ~max_cpx_empty),
		.fsl_cpx_s_control(max_cpx_ctl_data[3]),
		.fsl_cpx_s_data({max_cpx_empty, max_cpx_almost_empty, max_cpx_data[29:0]}),
		.fsl_cpx_s_valid(max_cpx_ctl_data[4])
	);
endmodule
