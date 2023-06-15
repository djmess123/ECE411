/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */

module cache_datapath 
import waymux::*;
import cacheinmux::*;
#(
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

    //controller
    input   logic cache_read,
    //input   logic cache_write,

    //input   load_way_sel,

    input   logic load_valid,
    input   logic valid_in,

    input   logic load_dirty,
    input   logic dirty_in,

    input   logic load_lru,
    input   logic lru_in,

    input   logic [s_mask-1:0] load_data,
    input   logic load_tag,

    input   logic mem_write,

    input   waymux::waymux_sel_t   waymux_sel,
    input   cacheinmux::cacheinmux_sel_t cacheinmux_sel,
    
    output  logic cache_dirty,
    output  logic cache_hit,
    output  logic cache_lru,
    output  logic hit_way0,



    
    //bus adaptor
    input   logic   [255:0] mem_wdata256,
    //input   logic   [31:0]  mem_byte_enable256,
    input   logic   [31:0]  mem_address,
    output  logic   [255:0] mem_rdata256,

    //cachline
    input   logic   [255:0] pmem_rdata,
    output  logic   [255:0] pmem_wdata

);

logic   [255:0] cache_data_in;


logic   load_dirty_way0;
logic   load_tag_way0;
logic   load_valid_way0;
logic   [s_mask-1:0]    load_data_way0;
logic   cache_dirty_way0;

logic   hit_way1;
logic   load_dirty_way1;
logic   load_tag_way1;
logic   load_valid_way1;
logic   [s_mask-1:0]    load_data_way1;
logic   cache_dirty_way1;

logic load_way_sel;


logic [s_line-1:0] data_out_way0;
logic [s_line-1:0] data_out_way1;

logic [s_index-1:0] addr_index;
logic [s_tag-1:0]   addr_tag;

assign addr_index = mem_address[7:5];
assign addr_tag = mem_address[31:8];


assign pmem_wdata = mem_rdata256;

//metadata array
array   LRU
(   
    .read(cache_read),
    .load(load_lru),
    .rindex(addr_index),
    .windex(addr_index),
    .datain(lru_in),
    .dataout(cache_lru),
    .*
);


cache_way way0
(
    .addr_index (addr_index),
    .addr_tag   (addr_tag),
    .read       (cache_read),

    .load_tag   (load_tag_way0),
    .load_data  (load_data_way0),
    .load_dirty (load_dirty_way0),
    .load_valid (load_valid_way0),

    .data_in    (cache_data_in),
    .dirty_in   (dirty_in),
    .valid_in   (valid_in),

    .hit        (hit_way0),
    .dirty      (cache_dirty_way0),
    .data_out   (data_out_way0),
    .*
);


cache_way way1
(
    .addr_index (addr_index),
    .addr_tag   (addr_tag),
    .read       (cache_read),

    .load_tag   (load_tag_way1),
    .load_data  (load_data_way1),
    .load_dirty (load_dirty_way1),
    .load_valid (load_valid_way1),

    .data_in    (cache_data_in),
    .dirty_in   (dirty_in),
    .valid_in   (valid_in),

    
    .hit        (hit_way1),
    .dirty      (cache_dirty_way1),
    .data_out   (data_out_way1),
    .*
);

//muxes
always_comb begin : CACHEMUXES

    unique case (waymux_sel)
        use_hit: load_way_sel = hit_way1; //was cache_hit
        use_LRU: load_way_sel = cache_lru;
    endcase

    unique case (cacheinmux_sel)
        use_mem: cache_data_in = pmem_rdata;
        use_cpu: cache_data_in = mem_wdata256;
    endcase


end


//logic

always_comb
begin
    cache_hit = hit_way0 || hit_way1;

    if (cache_hit)
    begin
        if (hit_way0)       //on a hit choose the hit data
            mem_rdata256 = data_out_way0;
        else
            mem_rdata256 = data_out_way1;
    end
    else
    begin
        if (cache_lru)      //output most recent (after change)
            mem_rdata256 = data_out_way1;
        else
            mem_rdata256 = data_out_way0;
    end


    //splitting loads
    load_data_way0 = ~load_way_sel ? load_data : 32'd0;
    load_data_way1 = load_way_sel ? load_data : 32'd0;

    load_dirty_way0 = load_dirty && ~load_way_sel;
    load_dirty_way1 = load_dirty &&  load_way_sel;

    load_valid_way0 = load_valid && ~load_way_sel;
    load_valid_way1 = load_valid &&  load_way_sel;

    load_tag_way0 = load_tag && ~load_way_sel;
    load_tag_way1 = load_tag &&  load_way_sel;


    cache_dirty = cache_lru ? cache_dirty_way1 : cache_dirty_way0;

end


endmodule : cache_datapath
