`define BAD_MUX_SEL4 $display("Illegal mux select IF4")
`define BAD_MUX_SEL5 $display("Illegal mux select IF5")
`define BAD_MUX_SEL6 $display("Illegal mux select IF6")

module IF 
import rv32i_types::*;
import mp4_types::*;
(

    input                       clk,
    input                       rst,

    // forwarding port
    input   logic               stall,
    input   logic               flush,

    // port to cache / magic memory
    input rv32i_word 	        instr_mem_rdata,
    output logic 			    instr_read,
	output rv32i_word 	        instr_mem_address,

    //branch predictor
    //input   pcmux::pcmux_sel_t  pcmux_sel_branch,
    input   rv32i_word          branch_addr_EX,
    rv32i_word                  pc_addr_IDEX,
    input   rv32i_word          addr_pred,
    input   logic               taken_pred,
    input   logic               taken_corrected,



    // register outputs to ID
    output  rv32i_word          instr_IFID,
    output  rv32i_word          pc_addr_IFID,

    output  logic               taken_IFID

);

logic load_pc;
rv32i_word branch_prediction;
rv32i_word branch_correction;
rv32i_word pc_in;
rv32i_word pc_out;

assign load_pc = ~stall || flush;   //DJM different, unchanged

// pc
pc_register PC
(
    .load   (load_pc),
    .in     (pc_in),
    .out    (pc_out),
    .*
);



always_comb begin : MEM_CONTROLLER
    instr_mem_address = pc_out;
    instr_read = 1'b1;                                                 //DJM different, unchanged
end




always_comb begin : MUXES

    // first predict
    unique case (taken_pred)
        1'b0:       branch_prediction = pc_out + 4;
        1'b1:       branch_prediction = addr_pred; 
        default:    `BAD_MUX_SEL4;
    endcase

    // correct miss predict
    unique case (taken_corrected)
        1'b0:       branch_correction = pc_addr_IDEX + 4;
        1'b1:       branch_correction = branch_addr_EX;
        default:    branch_correction = 'x;
    endcase

    // choose between first predict and correction
    unique case (flush) //mispredict
        1'b0:       pc_in = branch_prediction;    // predict like normal
        1'b1:       pc_in = branch_correction;    // flushing, need to correct old prediction
        default:    pc_in = 'x;
    endcase

end





// registered outputs for IF
always_ff @ (posedge clk) begin : REGISTERS
    if (rst || flush)                             //changed rst to stall
    begin
        instr_IFID <= 32'h00000013;
        pc_addr_IFID <= 32'h00000000;
        taken_IFID <= 1'b0;
    end
    else
    begin
        if (~stall)
        begin
            instr_IFID <= instr_mem_rdata;
            pc_addr_IFID <= pc_out;
            taken_IFID <= taken_pred;
        end
    end
end

endmodule
