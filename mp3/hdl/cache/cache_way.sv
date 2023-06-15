module cache_way #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input                        clk,
    input                        rst,

    input   logic [s_index-1:0]  addr_index,
    input   logic [s_tag-1:0]    addr_tag,
    input   logic [s_line-1:0]   data_in,  

    input   logic                read,
    input                        load_dirty,
    input                        load_tag,
    input                        load_valid,
    input  [s_mask-1:0]          load_data,
    input                        dirty_in,
    input                        valid_in,
    
    output  logic                hit,
    output  logic                dirty,
    output  logic [s_line-1:0]   data_out
);

logic               valid;
logic   [s_tag-1:0] tag;

array                   dirty_arr
(
    .read(read),
    .load(load_dirty),
    .rindex(addr_index),
    .windex(addr_index),
    .datain(dirty_in),
    .dataout(dirty),
    .*
);
array                   valid_arr
(   
    .read(read),
    .load(load_valid),
    .rindex(addr_index),
    .windex(addr_index),
    .datain(valid_in),
    .dataout(valid),
    .*
);
array #(.width(s_tag))     tag_arr
(   
    .read(read),
    .load(load_tag),
    .rindex(addr_index),
    .windex(addr_index),
    .datain(addr_tag),
    .dataout(tag),
    .*
);

data_array              data_arr
(   
    .read(read),
    .write_en(load_data),
    .rindex(addr_index),
    .windex(addr_index),
    .datain(data_in),
    .dataout(data_out),
    .*
);

//comparator
always_comb
begin
    if (valid && (addr_tag == tag))
        hit = 1'b1;
    else
        hit = 1'b0;
end


endmodule;
