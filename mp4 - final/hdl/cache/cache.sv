/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

module cache #(
    parameter s_offset = 5,
    // parameter s_index  = 3,
    parameter s_index  = 5,
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
    input   logic           pmem_resp,

    output logic cache_hit_out, cache_call_out
);

logic v0_out, v1_out, v2_out, v3_out; 
logic d0_out, d1_out, d2_out, d3_out; 
logic lru_out;
logic [2:0] lru4_out;
// logic [23:0] tag0_out, tag1_out, tag_out;
logic [s_tag:0] tag0_out, tag1_out, tag2_out, tag3_out, tag_out;
logic v0_ld, v1_ld, v2_ld, v3_ld; 
logic d0_ld, d1_ld, d2_ld, d3_ld; 
logic tag0_ld, tag1_ld, tag2_ld, tag3_ld; 
logic lru_ld, lru4_ld;
logic v0_in, v1_in, v2_in, v3_in; 
logic d0_in, d1_in, d2_in, d3_in; 
logic lru_in;
logic [2:0] lru4_in;
logic[31:0] mem_byte_enable256;
logic mem_sel, data_out_sel, pmem_adr_sel;
logic [1:0] data_out_sel4;
logic en_sel0, en_sel1, en_sel2, en_sel3; 
logic write_0, write_1, write_2, write_3;
logic [255:0] mem_wdata256, data_out;

assign pmem_wdata = data_out;

cache_control control
(
    .clk(clk),
    .rst(rst),

    .mem_read(mem_read), .mem_write(mem_write), .pmem_resp(pmem_resp),
    .mem_address(mem_address),

    .v0_out(v0_out), .v1_out(v1_out), .v2_out(v2_out), .v3_out(v3_out),
    .d0_out(d0_out), .d1_out(d1_out), .d2_out(d2_out), .d3_out(d3_out),
    .lru_out(lru_out),
    .lru4_out(lru4_out),
    .tag0_out(tag0_out), .tag1_out(tag1_out), .tag2_out(tag2_out), .tag_out(tag_out),


    .v0_ld(v0_ld), .v1_ld(v1_ld), .v2_ld(v2_ld), .v3_ld(v3_ld),
    .d0_ld(d0_ld), .d1_ld(d1_ld), .d2_ld(d2_ld), .d3_ld(d3_ld),
    .tag0_ld(tag0_ld), .tag1_ld(tag1_ld), .tag2_ld(tag2_ld), .tag3_ld(tag3_ld),
    .lru_ld(lru_ld), .lru4_ld(lru4_ld),
    .v0_in(v0_in), .v1_in(v1_in), .v2_in(v2_in), .v3_in(v3_in),
    .d0_in(d0_in), .d1_in(d1_in), .d2_in(d2_in), .d3_in(d3_in),
    .lru_in(lru_in),
    .lru4_in(lru4_in),
    .write_0(write_0), .write_1(write_1), .write_2(write_2), .write_3(write_3),

    .mem_sel(mem_sel), .data_out_sel(data_out_sel), .pmem_adr_sel(pmem_adr_sel), 
    .data_out_sel4(data_out_sel4),
    .en_sel0(en_sel0), .en_sel1(en_sel1), .en_sel2(en_sel2), .en_sel3(en_sel3),
    .mem_resp(mem_resp), .pmem_read(pmem_read), .pmem_write(pmem_write),

    .cache_hit_out(cache_hit_out), .cache_call_out(cache_call_out)
);

cache_datapath datapath
(
    .clk(clk),
    .rst(rst),
    .adr(mem_address),
    .mem_byte_enable256(mem_byte_enable256),

    .pmem_rdata(pmem_rdata),
    .mem_wdata256(mem_wdata256),

    .v0_ld(v0_ld), .v1_ld(v1_ld), .v2_ld(v2_ld), .v3_ld(v3_ld),
    .d0_ld(d0_ld), .d1_ld(d1_ld), .d2_ld(d2_ld), .d3_ld(d3_ld),
    .tag0_ld(tag0_ld), .tag1_ld(tag1_ld), .tag2_ld(tag2_ld), .tag3_ld(tag3_ld),
    .lru_ld(lru_ld), .lru4_ld(lru4_ld),
    .v0_in(v0_in), .v1_in(v1_in), .v2_in(v2_in), .v3_in(v3_in),
    .d0_in(d0_in), .d1_in(d1_in), .d2_in(d2_in), .d3_in(d3_in),
    .lru_in(lru_in),
    .lru4_in(lru4_in),
    .write_0(write_0), .write_1(write_1), .write_2(write_2), .write_3(write_3),

    .mem_sel(mem_sel), .data_out_sel(data_out_sel), .pmem_adr_sel(pmem_adr_sel),
    .data_out_sel4(data_out_sel4),
    .en_sel0(en_sel0), .en_sel1(en_sel1), .en_sel2(en_sel2), .en_sel3(en_sel3),


    .data_out(data_out), 

    .v0_out(v0_out), .v1_out(v1_out), .v2_out(v2_out), .v3_out(v3_out),
    .d0_out(d0_out), .d1_out(d1_out), .d2_out(d2_out), .d3_out(d3_out),
    .lru_out(lru_out),
    .lru4_out(lru4_out),
    .tag0_out(tag0_out), .tag1_out(tag1_out), .tag2_out(tag2_out), .tag3_out(tag3_out), .tag_out(tag_out),
    .pmem_adr(pmem_address)
);

bus_adapter bus_adapter
(
    .mem_wdata256(mem_wdata256),
    .mem_rdata256(data_out),        
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_byte_enable(mem_byte_enable),
    .mem_byte_enable256(mem_byte_enable256),  
    .address(mem_address)
);

endmodule : cache
