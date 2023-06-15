/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

module cacheL2 #(
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
    input   logic [31:0]    mem_address,    //keep 32
    output  logic [255:0]   mem_rdata,
    input   logic [255:0]   mem_wdata, 
    input   logic           mem_read,
    input   logic           mem_write,
    input   logic [31:0]    mem_byte_enable,
    output  logic           mem_resp,          

    /* Physical memory signals */
    output  logic [31:0]    pmem_address,      
    input   logic [255:0]   pmem_rdata,
    output  logic [255:0]   pmem_wdata,       
    output  logic           pmem_read,     
    output  logic           pmem_write,        
    input   logic           pmem_resp
);

logic v0_out, v1_out, d0_out, d1_out, lru_out;
logic [23:0] tag0_out, tag1_out;
logic v0_ld, v1_ld, d0_ld, d1_ld, tag0_ld, tag1_ld, lru_ld;
logic v0_in, v1_in, d0_in, d1_in, lru_in;

logic mem_sel, data_out_sel, pmem_adr_sel;
logic en_sel0, en_sel1, write_0, write_1;
logic [255:0] mem_wdata256, data_out;

assign pmem_wdata = data_out;

cache_control control
(
    .clk(clk),
    .rst(rst),

    .mem_read(mem_read), .mem_write(mem_write), .pmem_resp(pmem_resp),
    .mem_address(mem_address),

    .v0_out(v0_out), .v1_out(v1_out), .d0_out(d0_out), .d1_out(d1_out), .lru_out(lru_out),
    .tag0_out(tag0_out), .tag1_out(tag1_out),


    .v0_ld(v0_ld), .v1_ld(v1_ld), .d0_ld(d0_ld), .d1_ld(d1_ld), .tag0_ld(tag0_ld), .tag1_ld(tag1_ld), .lru_ld(lru_ld),
    .v0_in(v0_in), .v1_in(v1_in), .d0_in(d0_in), .d1_in(d1_in), .lru_in(lru_in),
    .write_0(write_0), .write_1(write_1),

    .mem_sel(mem_sel), .data_out_sel(data_out_sel), .pmem_adr_sel(pmem_adr_sel), 
    .en_sel0(en_sel0), .en_sel1(en_sel1),
    .mem_resp(mem_resp), .pmem_read(pmem_read), .pmem_write(pmem_write)
);

cache_datapath datapath
(
    .clk(clk),
    .rst(rst),
    .adr(mem_address),
    .mem_byte_enable256(mem_byte_enable256),

    .pmem_rdata(pmem_rdata),
    .mem_wdata256(mem_wdata),

    .v0_ld(v0_ld), .v1_ld(v1_ld), .d0_ld(d0_ld), .d1_ld(d1_ld), .tag0_ld(tag0_ld), .tag1_ld(tag1_ld), .lru_ld(lru_ld),
    .v0_in(v0_in), .v1_in(v1_in), .d0_in(d0_in), .d1_in(d1_in), .lru_in(lru_in),
    .write_0(write_0), .write_1(write_1),

    .mem_sel(mem_sel), .data_out_sel(data_out_sel), .pmem_adr_sel(pmem_adr_sel),
    .en_sel0(en_sel0), .en_sel1(en_sel1),


    .data_out(mem_rdata), 

    .v0_out(v0_out), .v1_out(v1_out), .d0_out(d0_out), .d1_out(d1_out), .lru_out(lru_out),
    .tag0_out(tag0_out), .tag1_out(tag1_out),
    .pmem_adr(pmem_address)
);
/*
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
*/
endmodule : cacheL2
