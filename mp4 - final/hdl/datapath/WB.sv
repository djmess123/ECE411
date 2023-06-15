`define BAD_MUX_SEL $display("Illegal mux select WB")




module WB
import rv32i_types::*;
import mp4_types::*;
(
    // unused
    //input clk,
    //input rst,

    // registered inputs from MEM
    input   logic                   stall,
    input   rv32i_word              alu_out_MEMWB,
    input   logic [4:0]             rd_MEMWB,
    input   rv32i_word              mem_out_MEMWB,
    input   rv32i_word              u_imm_MEMWB,
    input   rv32i_word              pc_addr_MEMWB,

    // control word
    input   rv32i_control_word      ctrl_MEMWB,

    // port to ID
    output  logic                   regfile_WB,
    output  logic [4:0]             rd_WB,
    output  rv32i_word              data_WB,

    //RVFI
    input   rvfi_monitor_passthrough    rvfi_MEMWB

);

rv32i_control_word ctrl;    assign ctrl     = ctrl_MEMWB;
rvfi_monitor_passthrough rvfi;


always_comb begin : RVFI
    if (stall)
        rvfi = '0;
    else
        rvfi = rvfi_MEMWB;



    
end



always_comb begin : REGFILE 
    regfile_WB = ctrl.load_regfile;
    rd_WB = rd_MEMWB;
end


/*

End of pipeline...

always_ff @ posedge clk
begin




end
*/

endmodule
