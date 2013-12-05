
/*
 *  The use of this wrapper will get rid of the latching
 *  of the read data because when used it will change it
 */

module plc_wrapper (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     add_to_list,
    /* SIGNALS WE ARE MUXING */
    // inputs
    input  wire [ADDR_WIDTH-1:0]    addr_in,
    input  wire [WAY_WIDTH-1:0]     way_in,
    input  wire                     read_enable_in,
    input  wire                     alt_mx_sel_in,
    // outputs
    output reg  [ADDR_WIDTH-1:0]    addr_out,
    output reg  [WAY_WIDTH-1:0]     way_out,
    output reg                      read_enable_out,
    output reg                      alt_mx_sel_out,
    /* SIGNALS WE ARE OBSERVING */
    // inputs
    // signals indicating cache is in use
    input  wire                     write_enable,
                                    // read_enable above, also
    // outputs from dcache
    input  wire [DATA_SIZE-1:0]     data,
    // PLC errors
    output wire                     plc_error_found
);

    parameter ADDR_WIDTH = 8;
    parameter WAY_WIDTH  = 4;
    parameter DATA_SIZE = 64;

    reg  check_enable;
    reg  access_cache;
    reg  pause;

// Fetching
    wire                    last_flag;
    wire [2*ADDR_WIDTH-1:0] addr_tuple;
    wire [2*WAY_WIDTH-1:0]  way_tuple;
    wire                    fetch_flag;
    wire                    plc_check_flag;

// To Cache
    wire read_enable_chk;
    wire [ADDR_WIDTH-1:0] addr_out_chk;
    wire [WAY_WIDTH-1:0] way_out_chk;

// Adding
    wire [2*ADDR_WIDTH-1:0] add_addr_tuple;
    wire [2*WAY_WIDTH-1:0]  add_way_tuple;
    wire                    add_flag;


    always @(*) begin
        access_cache = read_enable_in | write_enable ;
    end

    always @(*) begin
        pause = check_enable & access_cache;
    end

    always @(*) begin
        read_enable_out =  check_enable && !access_cache ? read_enable_chk : read_enable_in;
        addr_out        =  check_enable && !access_cache ? addr_out_chk : addr_in;
        way_out         =  check_enable && !access_cache ? way_out_chk : way_in;
        alt_mx_sel_out  =  check_enable && !access_cache ? 1'b0 : alt_mx_sel_in;
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            check_enable <= 1'b0;
        end else if (plc_check_flag) begin
            check_enable <= 1'b1;
        end else if (last_flag & fetch_flag) begin
            check_enable <= 1'b0;
        end
    end

    plc_list #(
        .LIST_CAP           (32),               // parameter LIST_CAP = 32;
        .LIST_CAP_BITS      (5),                // parameter LIST_CAP_BITS = 5;
        .ADDR_WIDTH         (ADDR_WIDTH),       // parameter ADDR_WIDTH = 8;
        .WAY_WIDTH          (WAY_WIDTH),        // parameter WAY_WIDTH = 4;
        .DATA_SIZE          (DATA_SIZE)         // parameter DATA_SIZE = 64;
    ) PLC_List (
        .clk                (clk),              // input  wire                     clk
        .rst                (rst),              // input  wire                     rst
        .add_addr_tuple     (add_addr_tuple),   // input  wire [2*ADDR_WIDTH-1:0]  add_addr_tuple
        .add_way_tuple      (add_way_tuple),    // input  wire [2*WAY_WIDTH-1:0]   add_way_tuple
        .add_flag           (add_flag),         // input  wire                     add_flag
        .store_addr         (addr_in),          // input  wire [ADDR_WIDTH-1:0]    store_addr
        .store_addr_w       (way_in),           // input  wire [ADDR_WIDTH-1:0]    store_addr
        .store_flag         (write_enable),     // input  wire                     store_flag
        .fetch_flag         (fetch_flag),       // input  wire                     fetch_flag
        .add_done           (),                 // output reg                      add_done
        .store_done         (),                 // output reg                      store_done
        .fetch_done         (),                 // output reg                      fetch_done
        .fetch_addr_tuple   (addr_tuple),       // output reg  [2*ADDR_WIDTH-1:0]  fetch_addr_tuple
        .fetch_way_tuple    (way_tuple),        // output reg  [2*WAY_WIDTH-1:0]   fetch_way_tuple
        .fetch_none         (),                 // output reg                      fetch_none
        .req_error          (),                 // output wire                     req_error
        .plc_check_flag     (plc_check_flag),   // output reg                      plc_check_flag
        .last_flag          (last_flag)         // output reg                      last_flag
`ifdef  DEBUG
        ,.d_error           ()                  // output wire [2:0]               d_error
`endif
    );

    plc_checker  #(
        .ADDR_WIDTH         (ADDR_WIDTH),   // parameter ADDR_WIDTH = 8;
        .WAY_WIDTH          (WAY_WIDTH),    // parameter WAY_WIDTH = 4;
        .DATA_SIZE          (DATA_SIZE)     // parameter DATA_SIZE = 64;
    ) PLC_Check (
        .clk                (clk),
        .rst                (rst | pause),
        .start              (plc_check_flag),
        .last               (last_flag),
        .addr_tuple         (addr_tuple),
        .way_tuple          (way_tuple),
        .next               (fetch_flag),
        .plc_error          (plc_error_found),  //route this si the reason we zare doing this project
        .ddata              (data),
        .read_en            (read_enable_chk),
        .addr_out           (addr_out_chk),
        .way_out            (way_out_chk)
    );

    plc_adder #(
        .ADDR_WIDTH         (ADDR_WIDTH),       // parameter ADDR_WIDTH = 8;
        .WAY_WIDTH          (WAY_WIDTH)         // parameter WAY_WIDTH = 4;
    ) PLC_Adder (
        .clk                (clk),              // input   wire                        clk
        .rst                (rst),              // input   wire                        rst
        .indicator          (add_to_list),      // input   wire                        indicator
        .write_en           (write_enable),     // input   wire                        write_en
        .addr               (addr_in),          // input   wire    [ADDR_WIDTH-1:0]    addr
        .way                (way_in),           // input   wire    [WAY_WIDTH-1:0]     way
        .add_addr_tuple     (add_addr_tuple),   // output  reg     [2*ADDR_WIDTH-1:0]  add_addr_tuple
        .add_way_tuple      (add_way_tuple),    // output  reg     [2*WAY_WDITH-1:0]   add_way_tuple
        .add_flag           (add_flag)          // output  reg                         add_flag
    );


endmodule