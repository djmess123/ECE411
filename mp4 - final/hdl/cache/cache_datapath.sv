/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */

module cache_datapath #(
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
    input logic [31:0] adr,
    input logic [31:0] mem_byte_enable256,

    input logic [255:0] pmem_rdata,
    input logic [255:0] mem_wdata256,

    input logic v0_ld, v1_ld, v2_ld, v3_ld, 
    input logic d0_ld, d1_ld, d2_ld, d3_ld,
    input logic tag0_ld, tag1_ld, tag2_ld, tag3_ld,
    input logic lru_ld, lru4_ld,
    input logic v0_in, v1_in, v2_in, v3_in, 
    input logic d0_in, d1_in, d2_in, d3_in, 
    input logic lru_in,
    input logic [2:0] lru4_in,
    input logic write_0, write_1, write_2, write_3,

    input logic mem_sel, data_out_sel, pmem_adr_sel,
    input logic [1:0] data_out_sel4,
    input logic en_sel0, en_sel1, en_sel2, en_sel3,

    output logic [255:0] data_out,
    output logic v0_out, v1_out, v2_out, v3_out, 
    output logic d0_out, d1_out, d2_out, d3_out,
    output logic lru_out,
    output logic [2:0] lru4_out,
    output logic [s_tag:0] tag0_out, tag1_out, tag2_out, tag3_out, tag_out,
    output logic [31:0] pmem_adr
);

logic [255:0] way0_in, way1_in, way2_in, way3_in, way0_out, way1_out, way2_out, way3_out;
logic [31:0] write_en0, write_en1, write_en2, write_en3;

assign tag_out = adr[31:32-s_tag];

data_array way0(
    .clk(clk),
    .write_en(write_en0),    
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(way0_in),
    .dataout(way0_out)
);

array Valid0(
    .clk(clk),
    .rst(rst),
    .load(v0_ld),    
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(v0_in), 
    .dataout(v0_out)
);

array Dirty0(
    .clk(clk),
    .rst(rst),
    .load(d0_ld),    
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(d0_in),      
    .dataout(d0_out)
);

// array #(.s_index(3), .width(24)) Tag0(
array #(.s_index(5), .width(s_tag)) Tag0(
    .clk(clk),
    .rst(rst),
    .load(tag0_ld),   
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    // .datain(adr[31:8]),
    .datain(adr[31:32-s_tag]),
    .dataout(tag0_out)  
);

data_array way1(
    .clk(clk),
    .write_en(write_en1),  
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(way1_in),  
    .dataout(way1_out)
);

array Valid1(
    .clk(clk),
    .rst(rst),
    .load(v1_ld),    
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(v1_in),  
    .dataout(v1_out)
);

array Dirty1(
    .clk(clk),
    .rst(rst),
    .load(d1_ld),      
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(d1_in),  
    .dataout(d1_out)
);

// array #(.s_index(3), .width(24)) Tag1(
array #(.s_index(5), .width(s_tag)) Tag1(
    .clk(clk),
    .rst(rst),
    .load(tag1_ld),     
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    // .datain(adr[31:8]),
    .datain(adr[31:32-s_tag]),
    .dataout(tag1_out)  
);



// WAY 2

data_array way2(
    .clk(clk),
    //.read(1'b1),
    .write_en(write_en2),  
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(way2_in),  
    .dataout(way2_out)
);

array Valid2(
    .clk(clk),
    .rst(rst),
    //.read(1'b1),
    .load(v2_ld),    
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(v2_in),  
    .dataout(v2_out)
);

array Dirty2(
    .clk(clk),
    .rst(rst),
    //.read(1'b1),
    .load(d2_ld),      
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(d2_in),  
    .dataout(d2_out)
);

array #(.s_index(5), .width(s_tag)) Tag2(
    .clk(clk),
    .rst(rst),
    //.read(1'b1),
    .load(tag2_ld),     
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(adr[31:32-s_tag]),
    .dataout(tag2_out)  
);



// WAY 3

data_array way3(
    .clk(clk),
    //.read(1'b1),
    .write_en(write_en3),  
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(way3_in),  
    .dataout(way3_out)
);

array Valid3(
    .clk(clk),
    .rst(rst),
    //.read(1'b1),
    .load(v3_ld),    
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(v3_in),  
    .dataout(v3_out)
);

array Dirty3(
    .clk(clk),
    .rst(rst),
    //.read(1'b1),
    .load(d3_ld),     
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(d3_in),  
    .dataout(d3_out)
);

array #(.s_index(5), .width(s_tag)) Tag3(
    .clk(clk),
    .rst(rst),
    //.read(1'b1),
    .load(tag3_ld),     
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(adr[31:32-s_tag]),
    .dataout(tag3_out)  
);


// LRU 2WAY

// array LRU(
//     .clk(clk),
//     .rst(rst),
//     .read(1'b1),
//     .load(lru_ld),       
//     // .rindex(adr[7:5]),
//     // .windex(adr[7:5]),
//     .rindex(adr[5+s_index-1:5]),
//     .windex(adr[5+s_index-1:5]),
//     .datain(lru_in),    
//     .dataout(lru_out)
// );


// LRU 4WAY

array #(.s_index(5), .width(3)) LRU4(
    .clk(clk),
    .rst(rst),
    //.read(1'b1),
    .load(lru4_ld),       
    // .rindex(adr[7:5]),
    // .windex(adr[7:5]),
    .rindex(adr[5+s_index-1:5]),
    .windex(adr[5+s_index-1:5]),
    .datain(lru4_in),    
    .dataout(lru4_out)
);



// 2 WAY

// always_comb begin
//     // way0 - mem_wdata256 or pmem_rdata
//     if (mem_sel == 1'b1)     
//     begin
//         way0_in = pmem_rdata;
//         way1_in = pmem_rdata;
//     end
//     else
//     begin
//         way0_in = mem_wdata256;
//         way1_in = mem_wdata256;
//     end

//     if (data_out_sel == 0)
//         data_out = way0_out;
//     else
//         data_out = way1_out;

//     if (pmem_adr_sel == 1'b0)
//     // if (pmem_adr_sel == 1'b1)
//         pmem_adr = {adr[31:5], 5'b0};
//         // pmem_adr = adr;
//     else
//     begin
//         // if (data_out_sel == 0)
//         //     pmem_adr = {tag0_out, adr[7:5], 5'b00000}; // adr[7:0]};
//         // else
//         //     pmem_adr = {tag1_out, adr[7:5], 5'b00000}; // adr[7:0]};
//         if (data_out_sel == 0)
//             pmem_adr = {tag0_out, adr[5+s_index-1:5], 5'b00000}; // adr[7:0]};
//         else
//             pmem_adr = {tag1_out, adr[5+s_index-1:5], 5'b00000}; // adr[7:0]};
//     end

//     if (en_sel0 == 1'b1)
//         write_en0 = {32{1'b1}};
//     else if (write_0 == 1'b1)
//         write_en0 = mem_byte_enable256;
//     else
//         write_en0 = 32'b0;
    
//     if (en_sel1 == 1'b1)
//         write_en1 = {32{1'b1}};
//     else if (write_1 == 1'b1)
//         write_en1 = mem_byte_enable256;
//     else
//         write_en1 = 32'b0;
// end


// 4 WAY

always_comb begin
    // way0 - mem_wdata256 or pmem_rdata
    if (mem_sel == 1'b1)     
    begin
        way0_in = pmem_rdata;
        way1_in = pmem_rdata;
        way2_in = pmem_rdata;
        way3_in = pmem_rdata;
    end
    else
    begin
        way0_in = mem_wdata256;
        way1_in = mem_wdata256;
        way2_in = mem_wdata256;
        way3_in = mem_wdata256;
    end

    if (data_out_sel4 == 2'b00)
        data_out = way0_out;
    else if (data_out_sel4 == 2'b01)
        data_out = way1_out;
    else if (data_out_sel4 == 2'b10)
        data_out = way2_out;
    else
        data_out = way3_out;

    if (pmem_adr_sel == 1'b0)
    // if (pmem_adr_sel == 1'b1)
        pmem_adr = {adr[31:5], 5'b0};
        // pmem_adr = adr;
    else
    begin
        // if (data_out_sel == 0)
        //     pmem_adr = {tag0_out, adr[7:5], 5'b00000}; // adr[7:0]};
        // else
        //     pmem_adr = {tag1_out, adr[7:5], 5'b00000}; // adr[7:0]};
        if (data_out_sel4 == 2'b00)
            pmem_adr = {tag0_out, adr[5+s_index-1:5], 5'b00000}; // adr[7:0]};
        else if (data_out_sel4 == 2'b01)
            pmem_adr = {tag1_out, adr[5+s_index-1:5], 5'b00000}; // adr[7:0]};
        else if (data_out_sel4 == 2'b10)
            pmem_adr = {tag2_out, adr[5+s_index-1:5], 5'b00000}; 
        else
            pmem_adr = {tag3_out, adr[5+s_index-1:5], 5'b00000}; 
    end

    if (en_sel0 == 1'b1)
        write_en0 = {32{1'b1}};
    else if (write_0 == 1'b1)
        write_en0 = mem_byte_enable256;
    else
        write_en0 = 32'b0;
    
    if (en_sel1 == 1'b1)
        write_en1 = {32{1'b1}};
    else if (write_1 == 1'b1)
        write_en1 = mem_byte_enable256;
    else
        write_en1 = 32'b0;

    if (en_sel2 == 1'b1)
        write_en2 = {32{1'b1}};
    else if (write_2 == 1'b1)
        write_en2 = mem_byte_enable256;
    else
        write_en2 = 32'b0;
    
    if (en_sel3 == 1'b1)
        write_en3 = {32{1'b1}};
    else if (write_3 == 1'b1)
        write_en3 = mem_byte_enable256;
    else
        write_en3 = 32'b0;
end

endmodule : cache_datapath
