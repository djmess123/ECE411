


module mp4_tb;

`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// Dump signals
initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, mp4_tb, "+all");
end
/****************************** End do not touch *****************************/

/********************** Signals for performance counters *********************/

int cycles_processed;
int instructions_processed; assign instructions_processed = rvfi.order;
int branches_seen;
int branch_predictions_missed;
int Num_stalls;

int instr_cache_hits;
int instr_cache_calls;

int data_cache_hits;
int data_cache_calls;



always_ff @(posedge dut.clk)
begin
    if (rvfi.commit && 
        
        (dut.DP.WB.ctrl.opcode == op_br || dut.DP.WB.ctrl.opcode == op_jal || dut.DP.WB.ctrl.opcode == op_jalr ) )
        branches_seen <= branches_seen + 1;

    if (dut.DP.flush == 1'b1)
        branch_predictions_missed <= branch_predictions_missed + 1;

    cycles_processed = cycles_processed + 1;
    if(dut.DP.stall==1'b1)
        Num_stalls+=1;

    if (dut.choI)
        instr_cache_hits <= instr_cache_hits + 1;
    if (dut.choD)
        data_cache_hits <= data_cache_hits + 1;
    if (dut.ccoI)
        instr_cache_calls <= instr_cache_calls + 1;
    if (dut.ccoD)
        data_cache_calls <= data_cache_calls + 1;
end


always_comb
begin
 if (rvfi.halt)
    begin
        $display("//------------------PERFORMANCE----------------------//");
        $display(" ");
        $display("Cycles taken:             %d", cycles_processed);
        $display(" ");
        $display("Instructions processed:   %d", instructions_processed);
        $display("Branches processed:       %d", branches_seen);
        $display("Branches missed:          %d", branch_predictions_missed);
        $display(" ");
        $display("CPI:                      %d", cycles_processed/instructions_processed);
        $display("Stalls:                   %d", Num_stalls);
        $display(" ");
        $display("Inst Cache Calls:         %d", instr_cache_calls);
        $display("Inst Cache Hits:          %d", instr_cache_hits);
        $display("Data Cache Calls:         %d", data_cache_calls);
        $display("Data Cache Hits:          %d", data_cache_hits);
        $display(" ");

        $display("//---------------------------------------------------//");
    end

end



/*****************************************************************************/


/************************ Signals necessary for monitor **********************/
// This section not required until CP2


// Set high when a valid instruction is modifying regfile or PC
assign rvfi.commit = dut.DP.WB.rvfi.commit; 
// Set high when target PC == Current PC for a branch
assign rvfi.halt = dut.DP.WB.rvfi.halt; 

initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO

always_comb begin : rvfi_passthrough
//Instruction and trap:
    rvfi.inst = dut.DP.WB.rvfi.inst;
    rvfi.trap = dut.DP.WB.rvfi.trap;

//Regfile:
    rvfi.rs1_addr = dut.DP.WB.rvfi.rs1_addr;
    rvfi.rs2_addr = dut.DP.WB.rvfi.rs2_addr;

    rvfi.rs1_rdata = dut.DP.ID.regfile.data[dut.DP.WB.rvfi.rs1_addr];
    rvfi.rs2_rdata = dut.DP.ID.regfile.data[dut.DP.WB.rvfi.rs2_addr];

    rvfi.load_regfile = dut.DP.WB.rvfi.load_regfile;
    
    rvfi.rd_addr = dut.DP.WB.rvfi.rd_addr;

    rvfi.rd_wdata = dut.DP.regfilemux_out_MEMWB;

//PC:
    rvfi.pc_rdata = dut.DP.WB.rvfi.pc_rdata;
    rvfi.pc_wdata = dut.DP.WB.rvfi.pc_wdata;

//Memory:
    rvfi.mem_addr = dut.DP.WB.rvfi.mem_addr;
    rvfi.mem_rmask = dut.DP.WB.rvfi.mem_rmask;
    rvfi.mem_wmask = dut.DP.WB.rvfi.mem_wmask;
    rvfi.mem_rdata = dut.DP.WB.rvfi.mem_rdata;
    rvfi.mem_wdata = dut.DP.WB.rvfi.mem_wdata;
end

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/
/*
//icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

//dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata
*/





/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = '{default: '0};

/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level for CP2:
Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

mp4 dut(
    .clk(itf.clk),
    .rst(itf.rst),
    
     // Remove after CP1
     /*
    .instr_mem_resp(itf.inst_resp),
    .instr_mem_rdata(itf.inst_rdata),
	.data_mem_resp(itf.data_resp),
    .data_mem_rdata(itf.data_rdata),
    .instr_read(itf.inst_read),
	.instr_mem_address(itf.inst_addr),
    .data_read(itf.data_read),
    .data_write(itf.data_write),
    .data_mbe(itf.data_mbe),
    .data_mem_address(itf.data_addr),
    .data_mem_wdata(itf.data_wdata)
    */
    // Use for CP2 onwards
    .pmem_read(itf.mem_read),
    .pmem_write(itf.mem_write),
    .pmem_wdata(itf.mem_wdata),
    .pmem_rdata(itf.mem_rdata),
    .pmem_address(itf.mem_addr),
    .pmem_resp(itf.mem_resp)
    
);
/***************************** End Instantiation *****************************/

endmodule
