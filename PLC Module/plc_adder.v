
//execution block diagram page 34
module plc_adder(
    input   wire                        clk,
    input   wire                        rst,
    input   wire                        indicator,
    input   wire                        write_en,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    input   wire    [WAY_WIDTH-1:0]     way,

    output  reg     [2*ADDR_WIDTH-1:0]  add_addr_tuple,
    output  reg     [2*WAY_WIDTH-1:0]   add_way_tuple,
    output  reg                         add_flag
);

    parameter ADDR_WIDTH = 8;                   // exu_lsu_early_va_e[10:3]? // pcx_packet 40 bits are for address
    parameter WAY_WIDTH = 4;                    //

    reg [1:0] state;

    parameter IDLE  = 2'b00;
    parameter WXO   = 2'b01;    // Wait for X
    parameter WXE   = 2'b10;    // Wait for X'

    always @(posedge  clk) begin
        if (rst) begin
            state <= IDLE;
            add_addr_tuple <= 0;
            add_way_tuple <= 0;
            add_flag <= 1'b0;
        end else if (state == IDLE) begin
            state <= indicator? WXO : state;
            add_addr_tuple <= add_addr_tuple;
            add_way_tuple <= add_way_tuple;
            add_flag <= 1'b0;
        end else if (write_en)begin
				if (state == WXO) begin
					state <= WXE;
					add_addr_tuple	<= {addr, add_addr_tuple[ADDR_WIDTH-1:0]};
					add_way_tuple	<= {way, add_way_tuple [WAY_WIDTH-1:0]};
					add_flag <= 1'b0;
				end else if (state == WXE) begin
					state <= IDLE;
					add_addr_tuple	<= {add_addr_tuple[2*ADDR_WIDTH-1:ADDR_WIDTH], addr};
					add_way_tuple	<= {add_way_tuple[2*WAY_WIDTH-1:WAY_WIDTH], way};
					add_flag <= 1'b1;
				end
		end else begin
				state <= state;
				add_addr_tuple	<= add_addr_tuple;
				add_way_tuple	<= add_way_tuple;
				add_flag <= add_flag;
		end
    end

endmodule
