/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input rst,

    /* CPU memory signals */
    input   logic [31:0]    mem_address,
    output  logic [31:0]    mem_rdata,
    input   logic [31:0]    mem_wdata,
    input   logic           mem_read,
    input   logic           mem_write,
    input   logic [3:0]     mem_byte_enable,
    output  logic           mem_resp,

    /* Physical memory signals */
    output  logic [31:0]    pmem_address,
    input   logic [255:0]   pmem_rdata,
    output  logic [255:0]   pmem_wdata,
    output  logic           pmem_read,
    output  logic           pmem_write,
    input   logic           pmem_resp
);

/* Signals*/
logic   [31:0]  mem_byte_enable256;
logic   [255:0] mem_wdata256;
logic   [255:0] mem_rdata256;   


logic cache_dirty ;
logic cache_hit   ;
logic cache_read  ;
logic cache_write ;
logic cache_load  ;
logic cache_lru   ;
logic hit_way0    ;

logic load_way_sel;
logic load_valid;
logic valid_in;

logic load_dirty;
logic dirty_in;

logic load_lru;
logic lru_in;

logic  [31:0] load_data;
logic load_tag;

waymux::waymux_sel_t   waymux_sel;
cacheinmux::cacheinmux_sel_t cacheinmux_sel;

/* Assignments */
assign pmem_address = mem_address;

cache_control control
(
    //bus adaptor
    .*
    /*
    //datapath
    .cache_dirty            (),
    .cache_hit              (),
    .cache_read             (),
    .cache_write            (),
    .cache_load             (),

    

    //cpu
    .mem_resp               ()
    */
);

cache_datapath datapath 
(
    //cacheline
    .*
    /*
    //controller
    .cache_read             (),
    .cache_write            (),
    .cache_load             (),
    .cache_dirty            (),
    .cache_hit              (),

    //bus adaptor
    .mem_wdata256           (),
    .mem_byte_enable256     (),
    .mem_address            (),
    .mem_rdata256           (),
    */
);

bus_adapter bus_adapter
(
    
    .address            (mem_address),        //32
    .*
    /*
    .mem_wdata256       (),       //256
    .mem_rdata256       (),       //256
    .mem_wdata          (),       //32
    .mem_rdata          (),       //32
    .mem_byte_enable    (),       //4
    .mem_byte_enable256 (),       //32
    */
);

endmodule : cache
