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

	max_cpx_stall, 
	max_cpx_ctl_stall, 

	max_pcx_empty,
	max_pcx_almost_empty,
	max_pcx_data,

	// Inputs
	gclk,
	reset,

	spc_pcx_data_pa,
	spc_pcx_atom_pq,
	spc_pcx_req_pq,

	max_cpx_valid,
	max_cpx_data,

	max_cpx_ctl_valid,
	max_cpx_ctl_data,

	max_pcx_read


);
   
    //=============================================
    // Outputs

    // SPARC/PCX interface
    output [4:0] pcx_spc_grant_px;

    // SPARC/CPX interface
    output                  cpx_spc_data_rdy_cx2;
    output [`CPX_WIDTH-1:0] cpx_spc_data_cx2;

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

    // SPARC/PCX interface
    input [`PCX_WIDTH-1:0] spc_pcx_data_pa;
    input                  spc_pcx_atom_pq;
    input [4:0]            spc_pcx_req_pq;

    // Maxeler Interface
	input max_cpx_valid;
	input [`MAX_D_WIDTH-1:0] max_cpx_data;
	input max_cpx_ctl_valid;
	input [`MAX_D_WIDTH-1:0] max_cpx_ctl_data;

	input max_pcx_read;

    //=============================================

    // FSL/Max wires

    // CCX/FSL wires
	wire pcx_fsl_m_control;
	wire [`MAX_D_WIDTH-1:0] pcx_fsl_m_data;
	wire pcx_fsl_m_write;
	wire fsl_pcx_m_full;

	wire cpx_fsl_s_read;
	wire fsl_cpx_s_exists;
	wire [3:0] fsl_cpx_s_control;
	wire [`MAX_D_WIDTH-1:0] fsl_cpx_s_data;
	
	wire [`MAX_D_WIDTH-1:0] pcx_max_s_data;

	wire [3:0] dummy_ctl_out;
	(* box_type = "user_black_box" *)
	fsl_fifo ccx2max_to_max(
	    .clk(gclk),
	    .rst(reset),

	    .din({pcx_fsl_m_control, 3'b000, pcx_fsl_m_data}),
	    .wr_en(pcx_fsl_m_write),
	    .full(fsl_pcx_m_full),

	    .dout({dummy_ctl_out, pcx_max_s_data}),
	    .rd_en(max_pcx_read),
	    .empty(max_pcx_empty),
	    .almost_empty(max_pcx_almost_empty),
	    .valid()
  	);

	/*fsl_v20 #(.C_ASYNC_CLKS(0)) ccx2max_to_max (
	    // Clock and reset signals
	    .FSL_Clk(gclk),
	    .SYS_Rst(reset),
	    .FSL_Rst(),

	    // FSL master signals
	    .FSL_M_Clk(),
	    .FSL_M_Data(pcx_fsl_m_data),
	    .FSL_M_Control(pcx_fsl_m_control),
	    .FSL_M_Write(pcx_fsl_m_write),
	    .FSL_M_Full(fsl_pcx_m_full),

	    // FSL slave signals
	    .FSL_S_Clk(gclk),
	    .FSL_S_Data(pcx_max_s_data),
	    .FSL_S_Control(pcx_max_s_control),
	    .FSL_S_Read(max_pcx_read),
	    .FSL_S_Exists(pcx_max_s_exists),

	    // FIFO status signals
	    .FSL_Full(),
	    .FSL_Has_Data(),
	    .FSL_Control_IRQ()
	);*/

	(* box_type = "user_black_box" *)
	fsl_fifo max_to_ccx2max(
	    .clk(gclk),
	    .rst(reset),

	    .din({max_cpx_ctl_data[3:0], max_cpx_data}),
	    .wr_en(max_cpx_valid),
	    .full(max_cpx_stall),

	    .dout({fsl_cpx_s_control, fsl_cpx_s_data}),
	    .rd_en(cpx_fsl_s_read),
	    .empty(fsl_cpx_s_empty),
	    .almost_empty(),
	    .valid()
  	);
	assign fsl_cpx_s_exists = ~fsl_cpx_s_empty;
	assign max_cpx_ctl_stall = max_cpx_stall;

	/*fsl_v20 #(.C_ASYNC_CLKS(0)) max_to_ccx2max (
	    // Clock and reset signals
	    .FSL_Clk(gclk),
	    .SYS_Rst(reset),
	    .FSL_Rst(),

	    // FSL master signals
	    .FSL_M_Clk(),
	    .FSL_M_Data(max_cpx_data),
	    .FSL_M_Control(),
	    .FSL_M_Write(max_cpx_valid),
	    .FSL_M_Full(max_cpx_stall),

	    // FSL slave signals
	    .FSL_S_Clk(),
	    .FSL_S_Data(fsl_cpx_s_data),
	    .FSL_S_Control(fsl_cpx_s_control),
	    .FSL_S_Read(cpx_fsl_s_read),
	    .FSL_S_Exists(fsl_cpx_s_exists),

	    // FIFO status signals
	    .FSL_Full(),
	    .FSL_Has_Data(),
	    .FSL_Control_IRQ()
	);*/
	
	/*reg [2:0] cpx_count;
	always @(posedge gclk)begin
		if(reset)begin
			cpx_count <= 0;
			fsl_cpx_s_control <= 0;
		end else begin
			if(max_cpx_valid)begin
				if(cpx_count == 0 || cpx_count >= 5)begin
					cpx_count <= 3'd1;
					fsl_cpx_s_control <= 1;
				end else begin
					cpx_count <= cpx_count + 1;
					fsl_cpx_s_control <= 0;
				end
			end else begin
				fsl_cpx_s_control <= 0;
				if(cpx_count >= 5)begin
					cpx_count <= 0;
				end else begin
					cpx_count <= cpx_count;
				end
			end
		end
	end*/

	ccx2mb ccx2mb (
		// Outputs
		.pcx_spc_grant_px(pcx_spc_grant_px),
		.pcx_fsl_m_control(pcx_fsl_m_control),
		.pcx_fsl_m_data(pcx_fsl_m_data),
		.pcx_fsl_m_write(pcx_fsl_m_write),

		.cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2),
		.cpx_spc_data_cx2(cpx_spc_data_cx2),

		.cpx_fsl_s_read(cpx_fsl_s_read),

		// Inputs
		.gclk(gclk),
		.reset_l(~reset),

		.spc_pcx_data_pa(spc_pcx_data_pa),
		.spc_pcx_atom_pq(spc_pcx_atom_pq),
		.spc_pcx_req_pq(spc_pcx_req_pq),

		.fsl_pcx_m_full(fsl_pcx_m_full),

		.fsl_cpx_s_exists(fsl_cpx_s_exists),
		.fsl_cpx_s_control(fsl_cpx_s_control[3]),
		.fsl_cpx_s_data(fsl_cpx_s_data)
	);

	assign max_pcx_data = pcx_max_s_data;

endmodule
