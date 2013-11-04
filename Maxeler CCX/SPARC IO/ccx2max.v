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
`define MAX_D_WIDTH 32
module ccx2max(
	// Outputs
	pcx_spc_grant_px,

	cpx_max_stall, 

	cpx_spc_data_rdy_cx2,
	cpx_spc_data_cx2,

	// Inputs
	clk,
	reset,

	spc_pcx_data_pa,
	spc_pcx_atom_pq,
	spc_pcx_req_pq,

	max_cpx_valid,
	max_cpx_data

);
   
    //=============================================
    // Outputs

    // SPARC/PCX interface
    output [4:0] pcx_spc_grant_px;

    // PCX/Max interface
    output                    pcx_fsl_m_control;
    output [`MAX_D_WIDTH-1:0] pcx_fsl_m_data;
    output                    pcx_fsl_m_write;

    // SPARC/CPX interface
    output                  cpx_spc_data_rdy_cx2;
    output [`CPX_WIDTH-1:0] cpx_spc_data_cx2;

    // Maxeler Interface
    output cpx_max_stall;

    //=============================================
    // Inputs
    input gclk;
    input reset;

    // SPARC/PCX interface
    input [`PCX_WIDTH-1:0] spc_pcx_data_pa;
    input                  spc_pcx_atom_pq;
    input [4:0]            spc_pcx_req_pq;

    // PCX/Max interface
    input fsl_pcx_m_full;

    // Maxeler Interface
	input max_cpx_valid;
	input [`MAX_D_WIDTH-1:0] max_cpx_data;

    //=============================================

    wire reset_l =  ~reset;

    // FSL/Max wires

    // CCX/FSL wires
	wire pcx_fsl_m_control;
	wire [`MAX_D_WIDTH-1:0] pcx_fsl_m_data;
	wire pcx_fsl_m_write;
	wire fsl_pcx_m_full;

	wire cpx_fsl_s_read;
	wire fsl_cpx_s_exists;
	wire fsl_cpx_s_control;
	wire [`MAX_D_WIDTH-1:0] fsl_cpx_s_data;

	fsl_v20 #(.C_ASYNC_CLKS(0)) ccx2max_to_max (
	    // Clock and reset signals
	    .FSL_Clk(gclk),
	    .SYS_Rst(reset_l),
	    .FSL_Rst(),

	    // FSL master signals
	    .FSL_M_Clk(),
	    .FSL_M_Data(cpx_fsl_m_data),
	    .FSL_M_Control(cpx_fsl_m_control),
	    .FSL_M_Write(pcx_fsl_m_write),
	    .FSL_M_Full(fsl_pcx_m_full),

	    // FSL slave signals
	    .FSL_S_Clk(gclk),
	    .FSL_S_Data(),
	    .FSL_S_Control(),
	    .FSL_S_Read(),
	    .FSL_S_Exists(),

	    // FIFO status signals
	    .FSL_Full(),
	    .FSL_Has_Data(),
	    .FSL_Control_IRQ()
	);

	fsl_v20 #(.C_ASYNC_CLKS(0)) max_to_ccx2max (
	    // Clock and reset signals
	    .FSL_Clk(),
	    .SYS_Rst(),
	    .FSL_Rst(),

	    // FSL master signals
	    .FSL_M_Clk(),
	    .FSL_M_Data(),
	    .FSL_M_Control(),
	    .FSL_M_Write(),
	    .FSL_M_Full(),

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
	);


	ccx2mb ccx2mb (
		// Outputs
		.pcx_spc_grant_px(),
		.pcx_fsl_m_control(),
		.pcx_fsl_m_data(),
		.pcx_fsl_m_write(),

		.cpx_spc_data_rdy_cx2(),
		.cpx_spc_data_cx2(),

		.cpx_fsl_s_read(),

		// Inputs
		.gclk(),
		.reset_l(),

		.spc_pcx_data_pa(),
		.spc_pcx_atom_pq(),
		.spc_pcx_req_pq(),

		.fsl_pcx_m_full(),

		.fsl_cpx_s_exists(),
		.fsl_cpx_s_control(),
		.fsl_cpx_s_data()
	);




endmodule
