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
    parameter IDLE = 4'd6;

    reg [DATA_SIZE-1:0] data_o;                 // register to save orig data
    reg [3:0] state;

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

    always @(posedge clk) begin

        //Defaults, works with vhdl, should with verilog?
        // because all these que overwritten appropriately fro next cycle
        if (rst) begin
            plc_error <= 1'b0;     //unless we encounter one
            state     <= IDLE;
            data_o    <= ddata;
        end else begin
            // Note that data in ddata is (latched not flopped)
            // may allows us to do this pipelining.
            case (state)

            // First Address
            IDLE: begin
                if (start) begin
                    plc_error   <= 1'b0;
                    state       <= FA;
                    data_o      <= data_o;
                end
            end

            FA: begin
                    plc_error   <= 1'b0;
                    state       <= SA;
                    data_o      <= data_o;
            end

            //Second Address
            SA: begin
                plc_error   <= 1'b0;
                state       <= last? LO : DO;     // not that last would have been loaded on previous fetch
                data_o      <= data_o;              // get new tuple if there is one
            end

            // Data Read O
            DO: begin
                plc_error   <= 1'b0;
                state       <= DE;
                data_o      <= ddata;
            end

            // Data Read E
            DE: begin
                plc_error   <= (data_o != ddata);
                state       <= last? LO : DO;
                data_o      <= data_o;
            end

            // Last Read O
            LO: begin
                plc_error   <= 1'b0;
                state       <= LE;
                data_o      <= ddata;       // save the data of original
            end

            // Last Read E
            LE: begin
                plc_error   <= (data_o != ddata);
                state       <= IDLE;
                data_o      <= data_o;
            end //! Why is this like this?

            default: begin
                plc_error   <= 1'b0;
                state       <= IDLE;
                data_o      <= data_o;
            end
			endcase
        end // else
    end

    always @(*) begin
        addr_out = 'd0;
        way_out  = 'd0;
        read_en = 1'b0;
        next = 1'b0;

        case(state)
            // First Address
            FA:begin
                addr_out = addr_tuple[2*ADDR_WIDTH-1:ADDR_WIDTH];  //every cycle we will have new address
                way_out  = way_tuple [2*WAY_WIDTH-1:WAY_WIDTH];      //every cycle we will have new address
                read_en = 1'b1;
                next = 1'b0;
            end

            //Second Address
            SA:begin
                addr_out = addr_tuple[ADDR_WIDTH-1:0]; //every cycle we will have new address
                way_out  = way_tuple [WAY_WIDTH-1:0];   //every cycle we will have new address
                read_en = 1'b1;
                next = 1'b1;
            end

            // Data Read O
            DO:begin
                addr_out = addr_tuple[2*ADDR_WIDTH-1:ADDR_WIDTH];
                way_out  = way_tuple [2*WAY_WIDTH-1:WAY_WIDTH];
                read_en = 1'b1;
                next = 1'b0;
            end

            // Data Read E
            DE:begin
                addr_out = addr_tuple[ADDR_WIDTH-1:0];
                way_out  = way_tuple [WAY_WIDTH-1:0];
                read_en = 1'b1;
                next = 1'b1;
            end
        endcase
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
    wire                    list_full = &size;

// List memory & Add
	integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < LIST_CAP; i = i+1) begin
                  list[i] <= 'd0;
                  ways[i] <= 'd0;
            end
            size <= 'd0;
            add_done  <= 1'b0;
        end else if (add_flag) begin    // assumes no duplicates
            if (~list_full) begin
                list[size] <= add_addr_tuple;
                ways[size] <= add_way_tuple;
                size <= size + 'd1;
                add_done  <= 1'b1;
            end else begin
                size <= size;
                add_done <= 1'b1;
            end
        end else begin
            add_done <= 1'b0;
        end
    end

// Fetch
    always @(*) begin
        last_flag = (fetch_ptr == size);
    end
    always @(posedge clk) begin
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
            fetch_addr_tuple <= fetch_addr_tuple;
            fetch_way_tuple <= fetch_way_tuple;
            fetch_ptr <= fetch_ptr;
            fetch_done <= 1'b0;
            fetch_none <= fetch_none;
        end
    end

// Search & Store & plc_check_flag

    wire [ADDR_WIDTH-1:0]   search_addr = store_addr;       // address to look for
    wire [WAY_WIDTH-1:0]    search_way  = store_addr_w;     // address to look for
    wire [LIST_CAP-1:0]     search_result;
    wire                    search_hit = |search_result;    // the address was found, used to ctrl the up-down counters

    always @(posedge clk) begin
        if (rst) begin
            store_counter <= 'd0;
            store_done <= 1'b0;
        end else if (store_flag) begin
            store_done <= 1'b1;
            if (search_hit) begin
                store_counter <= store_counter ^ search_result;
            end else begin
                store_counter <= store_counter;
            end
        end else begin
            store_done <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            plc_check_flag <= 1'b0;
        end else if (search_hit & store_done) begin
            plc_check_flag <= !(|(store_counter ^ search_result));
        end else begin
            plc_check_flag <= 1'b0;
        end
    end

// Naive List Search
    // Parallel search: Faster but larger than a binary search
    genvar g;
    generate
        for (g = 0; g < LIST_CAP; g = g+1) begin: SEARCH
            assign search_result[g] = (((list[g][2*ADDR_WIDTH-1:ADDR_WIDTH] == search_addr) &&
                                    (ways[g][2*WAY_WIDTH-1:WAY_WIDTH] == search_way)) ||
                                ((list[g][ADDR_WIDTH-1:0] == search_addr) &&
                                    (ways[g][2*WAY_WIDTH-1:0] == search_way)));
        end
    endgenerate

// Error
    assign req_error = | {
        ~((add_flag ^ fetch_flag) ^ (add_flag ^ store_flag) ^ (fetch_flag ^ store_flag))
    };

`ifdef DEBUG
// Debug
    assign d_error = {
        ~((add_flag ^ fetch_flag) ^ (add_flag ^ store_flag) ^ (fetch_flag ^ store_flag))
    };
`endif

endmodule