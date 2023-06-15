
module mp4
import rv32i_types::*;
import mp4_types::*;
(
    input clk,
    input rst,
	
    input pmem_resp,
    input [63:0] pmem_rdata,

    output logic pmem_read,
    output logic pmem_write,
    output rv32i_word pmem_address,
    output [63:0] pmem_wdata
);

rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
rv32i_control_word ctrl;

/* D-Cache */
logic d_resp;
logic d_read;
logic d_write;
logic [3:0] d_mbe;
logic [31:0] d_addr;
logic [31:0] d_wdata;
logic [31:0] d_rdata;

/* L2 D-Cache */
logic d_L2_read;
logic d_L2_write;
logic d_L2_resp;
logic [255:0] d_L2_wdata;
logic [255:0] d_L2_rdata;
rv32i_word d_L2_address;

/* Arbiter - D-Cache */
logic d_pmem_read;
logic d_pmem_write;
logic d_pmem_resp;
logic [255:0] d_pmem_wdata;
logic [255:0] d_pmem_rdata;
rv32i_word d_pmem_address;

/* I-Cache */
logic i_read;
logic i_resp;
logic [31:0] i_addr;
logic [31:0] i_rdata;

/* L2 I-Cache */
logic i_L2_read;
logic i_L2_resp;
logic [255:0] i_L2_rdata;
rv32i_word i_L2_address;

/* Arbiter - I-Cache */
logic i_pmem_read;
logic i_pmem_resp;
logic [255:0] i_pmem_rdata;
rv32i_word i_pmem_address;

/* Arbiter - Cacheline Adapter Signals */
logic [255:0] line_i;
logic [255:0] line_o;
logic [31:0] address_i;
logic read_i;
logic write_i;
logic resp_o;

logic choI, choD, ccoI, ccoD;
int hitI; 
int hitD;
int callI;
int callD;

always_ff @(posedge clk) begin
    if (choI) hitI <= hitI + 1;
    if (choD) hitD <= hitD + 1;
    if (ccoI) callI <= callI + 1;
    if (ccoD) callD <= callD + 1;
end

datapath DP
(
    .clk(clk),
    .rst(rst),
  
    // i-cache
    .instr_mem_resp(i_resp),
    .instr_mem_rdata(i_rdata),
    .instr_read(i_read),
    .instr_mem_address(i_addr),

    // d-cache  
    .data_mem_resp(d_resp),
    .data_mem_rdata(d_rdata), 
    .data_read(d_read),
    .data_mbe(d_mbe),
    .data_write(d_write),
    .data_mem_address(d_addr),
    .data_mem_wdata(d_wdata),

    // control
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .ctrl(ctrl)
);

control_rom control_rom
(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .ctrl(ctrl)
);


cacheline_adaptor GCA
(
    .clk(clk),
    .reset_n(~rst),
    .line_i(line_i),
    .line_o(line_o),
    .address_i(address_i),
    .read_i(read_i),
    .write_i(write_i),
    .resp_o(resp_o),
    .burst_i(pmem_rdata),
    .burst_o(pmem_wdata),
    .address_o(pmem_address),
    .read_o(pmem_read),
    .write_o(pmem_write),
    .resp_i(pmem_resp)
);






// GOLDEN CACHE

// gcache gcacheI (
// 	.clk(clk), 
// 	.mem_address(i_addr),
// 	.mem_rdata_cpu(i_rdata),
// 	.mem_wdata_cpu(32'd0),
// 	.mem_read(i_read),
// 	.mem_write(1'b0),
// 	.mem_byte_enable_cpu(4'b0000),
// 	.mem_resp(i_resp),

// 	.pmem_address(i_pmem_address),
// 	.pmem_rdata(i_pmem_rdata),
// 	.pmem_wdata(),
// 	.pmem_read(i_pmem_read),
// 	.pmem_write(),
// 	.pmem_resp(i_pmem_resp)
// );

// gcache gcacheD (
//     .clk(clk),

//     .mem_address(d_addr),
//     .mem_rdata_cpu(d_rdata),
//     .mem_wdata_cpu(d_wdata),
//     .mem_read(d_read),
//     .mem_write(d_write),
//     .mem_byte_enable_cpu(d_mbe),
//     .mem_resp(d_resp),

//     .pmem_address(d_pmem_address),
//     .pmem_rdata(d_pmem_rdata),
//     .pmem_wdata(d_pmem_wdata),
//     .pmem_read(d_pmem_read),
//     .pmem_write(d_pmem_write),
//     .pmem_resp(d_pmem_resp)
// );






// CP2 CACHE

cache cacheI (
    .clk(clk),
    .rst(rst),

    /* CPU memory signals */
    .mem_address(i_addr),
    .mem_rdata(i_rdata),         
    .mem_wdata(32'd0),
    .mem_read(i_read),
    .mem_write(1'b0),
    .mem_byte_enable(4'b0000),
    .mem_resp(i_resp),          

    /* Physical memory signals */
    .pmem_address(i_pmem_address),      
    .pmem_rdata(i_pmem_rdata),
    .pmem_wdata(),       
    .pmem_read(i_pmem_read),     
    .pmem_write(),        
    .pmem_resp(i_pmem_resp),

    .cache_hit_out(choI),
    .cache_call_out(ccoI)
);

cache cacheD (
    .clk(clk),
    .rst(rst),

    /* CPU memory signals */
    .mem_address(d_addr),
    .mem_rdata(d_rdata),         
    .mem_wdata(d_wdata),
    .mem_read(d_read),
    .mem_write(d_write),
    .mem_byte_enable(d_mbe),
    .mem_resp(d_resp),          

    /* Physical memory signals */
    .pmem_address(d_pmem_address),      
    .pmem_rdata(d_pmem_rdata),
    .pmem_wdata(d_pmem_wdata),       
    .pmem_read(d_pmem_read),     
    .pmem_write(d_pmem_write),        
    .pmem_resp(d_pmem_resp),

    .cache_hit_out(choD),
    .cache_call_out(ccoD)
);

arbiter AR(
    .clk(clk),
    .rst(rst),

	// Instruction Cache inputs
    .read_i(i_pmem_read),
    .address_i(i_pmem_address),

	// Data Cache inputs
    .read_d(d_pmem_read),
    .write_d(d_pmem_write),
    .wdata_d(d_pmem_wdata),
    .address_d(d_pmem_address),

	// Cacheline adapter inputs
    .resp(resp_o),
    .rdata(line_o),

	// Instruction Cache outputs 
    .rdata_i(i_pmem_rdata),
    .resp_i(i_pmem_resp),

	// Data Cache outputs 
    .rdata_d(d_pmem_rdata),
    .resp_d(d_pmem_resp),

	// Cacheline adapter outputs 
    .read(read_i),
    .write(write_i),
    .wdata(line_i),
    .address(address_i)
);






// L1 + L2

// cache cacheI (
//     .clk(clk),
//     .rst(rst),

//     /* CPU memory signals */
//     .mem_address(i_addr),
//     .mem_rdata(i_rdata),         
//     .mem_wdata(32'd0),
//     .mem_read(i_read),
//     .mem_write(1'b0),
//     .mem_byte_enable(4'b0000),
//     .mem_resp(i_resp),          

//     /* Physical memory signals */
//     .pmem_address(i_L2_address),      
//     .pmem_rdata(i_L2_rdata),
//     .pmem_wdata(),       
//     .pmem_read(i_L2_read),     
//     .pmem_write(),        
//     .pmem_resp(i_L2_resp)
// );

// cache cacheD (
//     .clk(clk),
//     .rst(rst),

//     /* CPU memory signals */
//     .mem_address(d_addr),
//     .mem_rdata(d_rdata),         
//     .mem_wdata(d_wdata),
//     .mem_read(d_read),
//     .mem_write(d_write),
//     .mem_byte_enable(d_mbe),
//     .mem_resp(d_resp),          

//     /* Physical memory signals */
//     .pmem_address(d_L2_address),      
//     .pmem_rdata(d_L2_rdata),
//     .pmem_wdata(d_L2_wdata),       
//     .pmem_read(d_L2_read),     
//     .pmem_write(d_L2_write),        
//     .pmem_resp(d_resp_L2)
// );

// cache L2cacheI (
//     .clk(clk),
//     .rst(rst),

//     /* CPU memory signals */
//     .mem_address(i_L2_address),
//     .mem_rdata(i_L2_rdata),         
//     .mem_wdata(32'd0),
//     .mem_read(i_L2_read),
//     .mem_write(1'b0),
//     .mem_byte_enable(4'b0000),
//     .mem_resp(i_L2_resp),          

//     /* Physical memory signals */
//     .pmem_address(i_pmem_address),      
//     .pmem_rdata(i_pmem_rdata),
//     .pmem_wdata(),       
//     .pmem_read(i_pmem_read),     
//     .pmem_write(),        
//     .pmem_resp(i_pmem_resp)
// );

// cache L2cacheD (
//     .clk(clk),
//     .rst(rst),

//     /* CPU memory signals */
//     .mem_address(d_L2_address),
//     .mem_rdata(d_L2_rdata),         
//     .mem_wdata(d_L2_wdata),
//     .mem_read(d_L2_read),
//     .mem_write(d_L2_write),
//     .mem_byte_enable(d_mbe),
//     .mem_resp(d_resp_L2),          

//     /* Physical memory signals */
//     .pmem_address(d_pmem_address),      
//     .pmem_rdata(d_pmem_rdata),
//     .pmem_wdata(d_pmem_wdata),       
//     .pmem_read(d_pmem_read),     
//     .pmem_write(d_pmem_write),        
//     .pmem_resp(d_pmem_resp)
// );

// arbiter AR(
//     .clk(clk),
//     .rst(rst),

// 	// Instruction Cache inputs
//     .read_i(i_pmem_read),
//     .address_i(i_pmem_address),

// 	// Data Cache inputs
//     .read_d(d_pmem_read),
//     .write_d(d_pmem_write),
//     .wdata_d(d_pmem_wdata),
//     .address_d(d_pmem_address),

// 	// Cacheline adapter inputs
//     .resp(resp_o),
//     .rdata(line_o),

// 	// Instruction Cache outputs 
//     .rdata_i(i_pmem_rdata),
//     .resp_i(i_pmem_resp),

// 	// Data Cache outputs 
//     .rdata_d(d_pmem_rdata),
//     .resp_d(d_pmem_resp),

// 	// Cacheline adapter outputs 
//     .read(read_i),
//     .write(write_i),
//     .wdata(line_i),
//     .address(address_i)
// );


endmodule : mp4
