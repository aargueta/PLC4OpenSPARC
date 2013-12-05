`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:38:12 12/04/2013 
// Design Name: 
// Module Name:    send_cpx_pkt 
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
module send_cpx_pkt(
	clk,
	rst,
	send,
	cpx_pkt,
	read,
	cpx_chunk,
	cpx_empty,
	sent
);	
	
	input clk;
	input rst;
	input send;
	input read;
	input [32*5-1:0] cpx_pkt;
	output reg [63:0] cpx_chunk;
	output cpx_empty;
	output reg sent;

	reg [2:0] send_state;
	always@(posedge clk)begin
		if(rst | sent)begin
			sent <= 0;
			send_state <= 0;
		end else if(send & read)
			{sent, send_state} <= send_state + 1'b1;
		else begin
			send_state <= send_state;
			sent <= sent;
		end
	end

	always @(*)begin
		case(send_state)
			0: cpx_chunk <= { 32'h00000018, cpx_pkt[159:128]};
			1: cpx_chunk <= { 32'h00000010, cpx_pkt[127:96]};
			2: cpx_chunk <= { 32'h00000010, cpx_pkt[95:64]};
			3: cpx_chunk <= { 32'h00000010, cpx_pkt[63:32]};
			4: cpx_chunk <= { 32'h00000010, cpx_pkt[31:0]};
			5: cpx_chunk <= { 32'h00000000, 32'h0BAD0BAD};
			6: cpx_chunk <= { 32'h00000000, 32'h0BAD0BAD};
			7: cpx_chunk <= { 32'h00000000, 32'h0BAD0BAD};
		endcase
	end

	assign cpx_empty = ~send;
endmodule
