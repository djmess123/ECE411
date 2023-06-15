`define SRC 0
`define RAND 1
`define TESTBENCH `SRC


module mp2_tb;

timeunit 1ns;
timeprecision 1ns;

/****************************** Generate Clock *******************************/
bit clk;
always #5 clk = clk === 1'b0;


/*********************** Variable/Interface Declarations *********************/
logic commit;
assign commit = dut.load_pc;
tb_itf itf(clk);
logic [63:0] order;
initial order = 0;
always @(posedge itf.clk iff commit) order <= order + 1;
int timeout = 100000000;   // Feel Free to adjust the timeout value
assign itf.registers = dut.datapath.regfile.data;
assign itf.halt = dut.load_pc & (dut.datapath.pc_out == dut.datapath.pcmux_out);
/*****************************************************************************/

/************************** Testbench Instantiation **************************/
// source_tb --- drives the dut by executing a RISC-V binary
// random_tb --- drives the dut by generating random input vectors
generate
if (`TESTBENCH == `SRC) begin : testbench
    source_tb tb(.mem_itf(itf));
end
else begin : testbench
    random_tb tb(.itf(itf), .mem_itf(itf));
end
endgenerate

// Initial Reset
initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, mp2_tb, "+all");
    itf.rst = 1'b1;
    repeat (5) @(posedge clk);
    itf.rst = 1'b0;
end
/*****************************************************************************/


/************************* Error Halting Conditions **************************/
// Stop simulation on error detection
always @(itf.errcode iff (itf.errcode != 0)) begin
    $system($sformatf("echo 'DASM(%8h)' | spike-dasm", dut.datapath.IR.data));
    repeat (30) @(posedge itf.clk);
    $display("TOP: Errcode: %0d", itf.errcode);
    $finish;
end

// Stop simulation on timeout (stall detection), halt
always @(posedge itf.clk) begin
    if (itf.halt)
        $finish;
    if (timeout == 0) begin
        $display("TOP: Timed out");
        $finish;
    end
    timeout <= timeout - 1;
end

// Simulataneous Memory Read and Write
always @(posedge itf.clk iff (itf.mem_read && itf.mem_write))
    $error("@%0t TOP: Simultaneous memory read and write detected", $time);

/*****************************************************************************/

mp2 dut(
    .clk             (itf.clk),
    .rst             (itf.rst),
    .mem_resp        (itf.mem_resp),
    .mem_rdata       (itf.mem_rdata),
    .mem_read        (itf.mem_read),
    .mem_write       (itf.mem_write),
    .mem_byte_enable (itf.mem_byte_enable),
    .mem_address     (itf.mem_address),
    .mem_wdata       (itf.mem_wdata)
);

riscv_formal_monitor_rv32i monitor(
    .clock (itf.clk),
    .reset (itf.rst),
    .rvfi_valid (commit),
    .rvfi_order (order),
    .rvfi_insn (dut.datapath.IR.data),
    .rvfi_trap(dut.control.trap),
    .rvfi_halt(itf.halt),
    .rvfi_intr(1'b0),
    .rvfi_mode(2'b00),
    .rvfi_rs1_addr(dut.control.rs1_addr),
    .rvfi_rs2_addr(dut.control.rs2_addr),
    .rvfi_rs1_rdata(monitor.rvfi_rs1_addr ? dut.datapath.rs1_out : 0),
    .rvfi_rs2_rdata(monitor.rvfi_rs2_addr ? dut.datapath.rs2_out : 0),
    .rvfi_rd_addr(dut.load_regfile ? dut.datapath.rd : 5'h0),
    .rvfi_rd_wdata(monitor.rvfi_rd_addr ? dut.datapath.regfilemux_out : 0),
    .rvfi_pc_rdata(dut.datapath.pc_out),
    .rvfi_pc_wdata(dut.datapath.pcmux_out),
    .rvfi_mem_addr(itf.mem_address),
    .rvfi_mem_rmask(dut.control.rmask),
    .rvfi_mem_wmask(dut.control.wmask),
    .rvfi_mem_rdata(dut.datapath.mdrreg_out),
    .rvfi_mem_wdata(dut.datapath.mem_wdata),
    .rvfi_mem_extamo(1'b0),
    .errcode(itf.errcode)
);

endmodule : mp2_tb
