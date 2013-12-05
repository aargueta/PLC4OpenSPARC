/* More about the bw_r_dcd cache side
 * Info found on page 41 of pdf OpenSPARCT1_MegaCell.pdf
 *
 *  9-KByte 4-way set associate data cache
 *      Each way contains 128 entries of 144 bits (16 bytes, where a byte is eight data bits and one parity bit).
 *      There are eight copies of the data cache, one in each instance of the OpenSPARC T1 cluster.
 *      DCD is a single-ported static random access memory (SRAM) configured as two banks of 128 entries x 288 bits.
 *      Each cache line consists of four words. Each word consists of four 9-bit bytes
 *      Each cache line is contained in one bank and each bank stores two doublewords and four
 *           parity bits per word for each of two ways, which gives a total of 288 bits per bank.
 *
 *
 *  Focus on Read Operation:
 *      Single cycle lateny and single cycle throughput
 *      Upper 7 bit of 8-bit input addres are deoced to select
 *      one of 128 entries..
 *       LSB used for upper or lower double world to read out
 *
 *
 * There is an alternate bus for address input that is 2:1 muxed
 *
 *
 *  Signals of interest for when reading
 *       _______________
 *      |               |
 *      |       L$      |
 *      |               |
 *      |_______________|
 * Inputs
 *  dcache_rvld_e           - Cache read enable
 *  dcache_rd_addr_e[10:3]  - address input
 *  dcache_rsel_way_wb[3:0] - Way select for read data
 *
 *
 *
 * Outputs:
 *  dcache_rdata_wb[63:0] - double word output
 *  dcache_rparity_err_wb - PArity check result
 *
 *  BIST = Built-in self test
 *
 *  Once address is sent there is a one cycle delay to get data
 *
 *
 */

 /* Alejandro's idea was to implement a stall for us instead of them.
  *
  *
  *
  */

module plc_checker (
    input   wire                    clk,
    input   wire                    rst,        // basically reset
    input   wire                    start,      // start loading
    input   wire                    last,       // last_tuple
    input   wire [2*ADDR_WIDTH-1:0] addr_tuple, // addr to access
    input   wire [2*WAY_WIDTH-1:0]  way_tuple,  // way to fetch, part of addr

    output  reg                     next,       // fetch new tuple
    output  reg                     plc_error,  // report they dont match

    // bw_r_dcd interface
    input   wire [DATA_SIZE-1:0]    ddata,      // data from cache

    output  reg                     read_en,    // read enable
    output  reg [ADDR_WIDTH-1:0]    addr_out,   // addr to access
    output  reg [WAY_WIDTH-1:0]     way_out    // way to fetch
);

    parameter ADDR_WIDTH = 8;                   // exu_lsu_early_va_e[10:3]? // pcx_packet 40 bits are for address
    parameter WAY_WIDTH = 4;                    //
    parameter DATA_SIZE = 64;                   // Going with the bigger of cpx(128) and pcx (64)

    parameter FA = 4'd0;
    parameter SA = 4'd1;
    parameter DO = 4'd2;
    parameter DE = 4'd3;
    parameter LO = 4'd4;
    parameter LE = 4'd5;

    reg [DATA_SIZE-1:0] data_o;                 // register to save orig data
    reg [3:0] state;

    integer k;

    /*  FSM
     *
     *  First Address:
     *       Send Address
     *       read en
     *  Second Address:
     *      Send Address
     *      read en
     *      if last tuple go to Last Read O
     *  Data Read O
     *      save data from Address i - 2;
     *      read_en cause doing more
     *      Send Address
     *
     *  Data Read E
     *      compare data to data i -1;
     *      read_en cause doing more
     *      Send Address
     *      if last tuple go to Last Read O
     *
     *  Last Read O
     *      save data from Address i-2;
     *      read_en off
     *
     *  Last Read E
     *      compare data to data i -1;
     *      read_en off
     *
     */

    always @(posedge clk, posedge rst) begin

        //Defaults, works with vhdl, should with verilog?
        // because all these que overwritten appropriately fro next cycle
        if (rst) begin
            plc_error <= 1'b0;     //unless we encounter one
            read_en   <= 1'b0;
            state     <= 0;
            next      <= 1'b0;
        end else begin
        // Note that data in ddata is (latched not flopped)
        // may allows us to do this pipelining.

        // First Address
        if(start & state == FA) begin
            addr_out <= addr_tuple[2*ADDR_WIDTH-1:ADDR_WIDTH];  //every cycle we will have new address
            way_out <= way_tuple[2*WAY_WIDTH-1:WAY_WIDTH];      //every cycle we will have new address
            state   <= SA;
            read_en <= 1'b1;
            next    <= 1'b0;
        end

        //Second Address
        if (state == SA) begin
            addr_out <= addr_tuple[ADDR_WIDTH-1:0]; //every cycle we will have new address
            way_out  <= way_tuple[WAY_WIDTH-1:0];   //every cycle we will have new address
            read_en  <= 1'b1;
            state <= DO;
            next  <= 1'b1;              // get new tuple if there is one
            if(last == 1'b1) begin      // not that last would have been loaded on previous fetch
                state <= LO;
            end
        end


        // Data Read O
        if (state == DO) begin
            addr_out <= addr_tuple[2*ADDR_WIDTH-1:ADDR_WIDTH];
            way_out  <= way_tuple[2*WAY_WIDTH-1:WAY_WIDTH];
            read_en  <= 1'b1;
            state <= DE;
            next  <= 1'b0;
        end

        // Data Read E
        if (state == DE) begin
            if (data_o != ddata) begin
                plc_error <= 1'b1;
            end
            addr_out <= addr_tuple[ADDR_WIDTH-1:0];
            way_out  <= way_tuple[WAY_WIDTH-1:0];
            read_en  <= 1'b1;
            state <= DO;
            next  <= 1'b1;          // get new tuple if there is one
            if (last == 1'b1) begin
                state <= LO;
            end
        end

        // Last Read O
        if(state == LO) begin
            data_o  <= ddata;       // save the data of original
            state   <= LE;
            read_en <= 1'b0;
        end

        // Last Read E
        if (state == LE) begin
            if (data_o != ddata) begin
                plc_error <= 1'b1;
            end else begin
                plc_error <= 1'b1;
            end
            read_en <= 1'b0;
            state <= FA;
        end //! Why is this like this?
        end // else
    end

endmodule

// add_flag, store_flag and fetch_flags must be mutually exclusive
module plc_list (
    input  wire                     clk,
    input  wire                     rst,
    input  wire [2*ADDR_WIDTH-1:0]  add_addr_tuple,     // address tuple to store in the list
    input  wire [2*WAY_WIDTH-1:0]   add_way_tuple,       // address tuple to store in the list
    input  wire                     add_flag,           // signal plc_list to store add_addr_tuple
    input  wire [ADDR_WIDTH-1:0]    store_addr,         // destination of a store
    input  wire [WAY_WIDTH-1:0]     store_addr_w,       // destination of a store
    input  wire                     store_flag,         // store indicator
    input  wire                     fetch_flag,         // signal to output a new address from the plc_list

    output reg                      add_done,           // Done adding to list
    output reg                      store_done,         // store of variable
    output reg                      fetch_done,         // fetching new tuple done
    output reg  [2*ADDR_WIDTH-1:0]  fetch_addr_tuple,   // address tuple output upon a request (fetch_flag)
    output reg  [2*WAY_WIDTH-1:0]   fetch_way_tuple,    // address tuple output upon a request (fetch_flag)
    output reg                      fetch_none,         // nothing to fetch
    output wire                     req_error,
    output reg                      plc_check_flag,     // signal to continue asking for addresses
    output reg                      last_flag           // signal of last element in list
`ifdef  DEBUG
    ,
    output wire [2:0]               d_error
`endif
);

// Parameters
    parameter LIST_CAP = 32;                    // Adjust to test
    parameter LIST_CAP_BITS = 5;                // Bits required to encode address into PLC_List
    parameter ADDR_WIDTH = 8;                   // exu_lsu_early_va_e[10:3]? // pcx_packet 40 bits are for address
    parameter WAY_WIDTH = 4;                    //
    parameter DATA_SIZE = 64;                   // Going with the bigger of cpx(128) and pcx (64)

// PLC list memory elements
    reg [2*ADDR_WIDTH-1:0]  list [LIST_CAP-1:0];    // list of tuples <A,A'>
    reg [2*WAY_WIDTH-1:0]   ways [LIST_CAP-1:0];    // list of tuples need ways as well
    //! I think here we might only need one store counter since EDDI does a write right after
    reg [LIST_CAP-1:0]      store_counter;          // up-down counters, [valid:cnt]
    reg [LIST_CAP_BITS-1:0] size;                   // number of tuples in the list
    reg [LIST_CAP_BITS-1:0] fetch_ptr;              // current pointer used to output addr tuples
    reg                     list_full;

    reg                     add_error, store_error;

    integer i;

// List memory & Add
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            for (i = 0; i < LIST_CAP; i = i+1) begin
                list[i] <= 'd0;
                ways[i] <= 'd0;
            end
            size <= 'd0;
            list_full <= 1'b0;
            add_done  <= 1'b0;
            add_error <= 1'b0;
        end else if (add_flag) begin    // assumes no duplicates
            if (~list_full) begin
                list[size] <= add_addr_tuple;
                ways[size] <= add_way_tuple;
                list_full  <= (size == 'hffff_ffff_ffff_ffff) ? 1'b1 : 1'b0;
                size <= size + 1;
                add_done  <= 1'b1;
                add_error <= 1'b0;
            end else begin
                add_done <= 1'b1;
                add_error <= 1'b1;
            end
        end else begin
            add_done <= 1'b0;
        end
    end


    //! Need to implement pause so that it can send the same index again

    always @(*) begin
        last_flag = (fetch_ptr == size);
    end
// Fetch
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            fetch_addr_tuple <= 0;
				fetch_way_tuple <= 0;
            fetch_ptr  <= 'd0;
            fetch_done <= 1'b0;
            fetch_none <= 1'b0;
        end else if (plc_check_flag) begin
            fetch_addr_tuple <= list[0];
            fetch_way_tuple <= ways[0];
            fetch_ptr <= 'd1;
            fetch_done <= 1'b1;
            fetch_none <= 1'b0;
        end else if (fetch_flag) begin
            if (fetch_ptr != size) begin    // if valid
                fetch_addr_tuple <= list[fetch_ptr];
                fetch_way_tuple  <= ways[fetch_ptr];
                fetch_ptr  <= fetch_ptr + 'd1;
                fetch_done <= 1'b1;
                fetch_none <= 1'b0;
                //! might need a cycle delay
            end else begin                  // if not valid
					fetch_addr_tuple <= fetch_addr_tuple;
					fetch_way_tuple <= fetch_way_tuple ;
                fetch_ptr  <= 'd0;
                fetch_done <= 1'b1;
                fetch_none <= 1'b1;
            end
        end else begin
            fetch_done <= 1'b0;
        end
    end

// Search & Store & plc_check_flag

    wire [ADDR_WIDTH-1:0]    search_addr = store_addr;       // address to look for
    wire [WAY_WIDTH-1:0]     search_way  = store_addr_w;      // address to look for
    wire                     search_hit = |search_result;    // the address was found, used to ctrl the up-down counters

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            store_counter <= 'd0;
            plc_check_flag <= 1'b0;
            store_done <= 1'b0;
            store_error <= 1'b0;
        end else if (store_flag) begin
            store_done <= 1'b1;
            if (search_hit) begin
                store_counter <= store_counter ^ search_result;
                plc_check_flag <= !(|(store_counter ^ search_result));
            end else begin
                plc_check_flag <= 1'b0;
            end
        end else begin
            plc_check_flag <= 1'b0;
            store_done <= 1'b0;
        end
    end

// Naive List Search
    // Parallel search: Faster but larger than a binary search
    genvar g;
    wire [LIST_CAP-1:0] search_result;
    generate
        for (g = 0; g < LIST_CAP; g = g+1) begin: SEARCH
            assign search_result[g] = store_flag & (((list[g][2*ADDR_WIDTH-1:ADDR_WIDTH] == search_addr) &&
                                    (ways[g][2*WAY_WIDTH-1:WAY_WIDTH] == search_way)) ||
                                ((list[g][ADDR_WIDTH-1:0] == search_addr) &&
                                    (ways[g][2*WAY_WIDTH-1:0] == search_way)));
        end
    endgenerate

// Error
    assign req_error = | {
        add_error,
        store_error,
        ~((add_flag ^ fetch_flag) ^ (add_flag ^ store_flag) ^ (fetch_flag ^ store_flag))
    };

`ifdef DEBUG
// Debug
    assign d_error = {
        add_error,
        store_error,
        ~((add_flag ^ fetch_flag) ^ (add_flag ^ store_flag) ^ (fetch_flag ^ store_flag))
    };
`endif

endmodule