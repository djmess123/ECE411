module mp3
import rv32i_types::*;
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

/* CPU to cache signals */
logic [255:0]   line_i;
logic [255:0]   line_o;
logic [31:0]    address_i;
logic           read_i;
logic           write_i;
logic           resp_o;

/* Cache to P-memory signals */
logic [31:0]    mem_address;
logic [31:0]    mem_rdata;
logic [31:0]    mem_wdata;
logic           mem_read;
logic           mem_write;
logic [3:0]     mem_byte_enable;
logic           mem_resp;


// Keep cpu named `cpu` for RVFI Monitor
// Note: you have to rename your mp2 module to `cpu`
cpu cpu(.*);

// Keep cache named `cache` for RVFI Monitor
cache cache(
    /* Physical memory signals */
    .pmem_address   (address_i),   //32
    .pmem_rdata     (line_o),     //256
    .pmem_wdata     (line_i),     //256
    .pmem_read      (read_i),
    .pmem_write     (write_i),
    .pmem_resp      (resp_o),
    .*                          );

// Hint: What do you need to interface between cache and main memory?
cacheline_adaptor ca
(
    // Port to memory
    .burst_i    (pmem_rdata),     //64
    .burst_o    (pmem_wdata),     //64
    .address_o  (pmem_address),   //32
    .read_o     (pmem_read),
    .write_o    (pmem_write),
    .resp_i     (pmem_resp),
    .reset_n    (~rst),
    .*                          );


endmodule : mp3