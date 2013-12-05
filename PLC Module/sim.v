`timescale 1ns/1ps

module sim();

    parameter ADDR_WIDTH = 8;
    parameter WAY_WIDTH = 4;
    parameter DATA_SIZE = 64;

    reg                     clk;
    reg                     rst;
    reg                     add_to_list;
    reg [ADDR_WIDTH-1:0]    addr_in;
    reg [WAY_WIDTH-1:0]     way_in;
    reg                     read_enable_in;
    reg                     alt_mx_sel_in;
    wire [ADDR_WIDTH-1:0]   addr_out;
    wire [WAY_WIDTH-1:0]    way_out;
    wire                    read_enable_out;
    wire                    alt_mx_sel_out;
    reg                     write_enable;
    reg [DATA_SIZE-1:0]     data;
    wire                    plc_error_found;


    plc_wrapper System (
        .clk                (clk),                  // input  wire                     clk
        .rst                (rst),                  // input  wire                     rst
        .add_to_list        (add_to_list),          // input  wire                     add_to_list
        .addr_in            (addr_in),              // input  wire [ADDR_WIDTH-1:0]    addr_in
        .way_in             (way_in),               // input  wire [WAY_WIDTH-1:0]     way_in
        .read_enable_in     (read_enable_in),       // input  wire                     read_enable_in
        .alt_mx_sel_in      (alt_mx_sel_in),        // input  wire                     alt_mx_sel_in
        .write_enable       (write_enable),         // input  wire                     write_enable
        .data               (data),                 // input  wire [DATA_SIZE-1:0]     data
        .plc_error_found    (plc_error_found),      // output reg                      plc_error_found
        .addr_out           (addr_out),             // output reg  [ADDR_WIDTH-1:0]    addr_out
        .way_out            (way_out),              // output reg  [WAY_WIDTH-1:0]     way_out
        .read_enable_out    (read_enable_out),      // output reg                      read_enable_out
        .alt_mx_sel_out     (alt_mx_sel_out)        // output reg                      alt_mx_sel_out
    );

    always begin
        #5 clk <= ~clk;
    end

    integer x;

    initial begin
        $display("Starting Simulation: sim");
            clk <= 1;
            rst <= 1;
            add_to_list <= 0;
            addr_in <= 0;
            way_in <= 0;
            read_enable_in <= 0;
            write_enable <= 0;
            alt_mx_sel_in <= 0;
            data <= 0;

        #19 rst <= 0;
        @(posedge clk);
            add_to_list = 1;
        @(posedge clk);
            add_to_list = 0;
            addr_in = 8'h12;
            way_in = 4'hC;
            write_enable = 1;
        @(posedge clk);
            write_enable = 0;
        @(posedge clk);
            add_to_list = 1;
        @(posedge clk);
            add_to_list = 0;
            addr_in = 8'h34;
            way_in = 4'hF;
            write_enable = 1;
        @(posedge clk);
            write_enable = 0;
        @(posedge clk);
            add_to_list = 1;
        @(posedge clk);
            add_to_list = 0;
            addr_in = 8'haa;
            way_in = 4'hF;
            write_enable = 1;
        @(posedge clk);
            write_enable = 0;
        @(posedge clk);
            add_to_list = 1;
        @(posedge clk);
            add_to_list = 0;
            addr_in = 8'h55;
            way_in = 4'hF;
            write_enable = 1;
        @(posedge clk);
            write_enable = 0;
        @(posedge clk);
            add_to_list = 1;
        @(posedge clk);
            add_to_list = 0;
            addr_in = 8'hee;
            way_in = 4'hF;
            write_enable = 1;
        @(posedge clk);
            write_enable = 0;
        @(posedge clk);
            add_to_list = 1;
        @(posedge clk);
            add_to_list = 0;
            addr_in = 8'hdd;
            way_in = 4'hF;
            write_enable = 1;
        @(posedge clk);
            write_enable = 0;



        #50;
        @(posedge clk);
            write_enable <= 1;
            addr_in <= 8'h55;
            way_in <= 4'hf;

        @(posedge clk);
            write_enable <= 1;
            addr_in <= 8'haa;
            way_in <= 4'hf;

        @(posedge clk);
            write_enable <= 0;

        // Should see plc_check_flag

        while (System.PLC_Check.addr_out != 8'h55) begin
            @(posedge clk);
        end

        @(posedge clk);
        data <= 2;

        #200 $display("Ending Simulation: sim");
        $finish();
    end

endmodule