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
`undef DEFINE_0IN
module opensparc_t1(
	clk,
	rst,
	
	cpx_empty,
	cpx_almost_empty,
	cpx_read,
	cpx_data,

	pcx_valid,
	pcx_stall,
	pcx_data
);
	parameter CPU_ID = 4'b0000;
	input clk;
	input rst;
	
	input cpx_empty;
	input cpx_almost_empty;
	output cpx_read;
	input [63:0] cpx_data;

	output pcx_valid;
	input pcx_stall;
	output [31:0] pcx_data;

	wire [`PCX_WIDTH-1:0] spc_pcx_data_pa;
   wire                  spc_pcx_atom_pq;
   wire [4:0]            spc_pcx_req_pq;
	
    // SPARC/PCX interface
    wire [4:0] pcx_spc_grant_px;

    // SPARC/CPX interface
    wire                  cpx_spc_data_rdy_cx2;
    wire [`CPX_WIDTH-1:0] cpx_spc_data_cx2;
	 
	// Reset counter
	wire reset_done;
	
	wire cpx_read;
	ccx2max ccx(
		//Outputs
		.pcx_spc_grant_px(pcx_spc_grant_px), 

		.cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2), 
		.cpx_spc_data_cx2(cpx_spc_data_cx2), 

		.max_cpx_read(cpx_read),

		.max_pcx_valid(pcx_valid), 
		.max_pcx_data(pcx_data), 

		//Inputs
		.gclk(clk), 
		.reset(rst), 
		.core_reset_done(reset_done),

		.spc_pcx_data_pa(spc_pcx_data_pa), 
		.spc_pcx_atom_pq(spc_pcx_atom_pq), 
		.spc_pcx_req_pq(spc_pcx_req_pq), 

		.max_cpx_valid(max_valid), 
		.max_cpx_data(cpx_data[31:0]), 
		.max_cpx_ctl_data(cpx_data[63:32]), 
		.max_cpx_empty(cpx_empty),
		.max_cpx_almost_empty(cpx_almost_empty),

		.max_pcx_stall(pcx_stall)
	);

	/*
	// Dummy reply logic
	assign spc_pcx_atom_pq = 0;
	assign spc_pcx_req_pq = {cpx_spc_data_rdy_cx2, 4'b0000};
	always @(posedge clk)begin
		spc_pcx_data_pa = {5'h17, cpx_spc_data_cx2[118:0]};
	end	*/

	iop_fpga sparc(
		.reset_l(~rst), 
		.gclk(clk),
		.cpu_id(CPU_ID),
		.spc_pcx_req_pq(spc_pcx_req_pq),
		.spc_pcx_atom_pq(spc_pcx_atom_pq),
		.spc_pcx_data_pa(spc_pcx_data_pa),
		.pcx_spc_grant_px(pcx_spc_grant_px),
		.cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2),
		.cpx_spc_data_cx2(cpx_spc_data_cx2),
		.reset_done(reset_done)
	);

endmodule
