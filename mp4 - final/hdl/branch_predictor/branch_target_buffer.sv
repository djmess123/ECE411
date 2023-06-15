module btb
import rv32i_types::*;
import mp4_types::*;
#(
parameter s_index = 4,
parameter width = 2
)
(
    input   logic                   clk,             
    input   logic                   rst,                  //resets everything to addresses of 0
    input   logic   [s_index-1:0]   r_index,              // index to read from the table, from the btb
    output  rv32i_word              r_addr_pred,          // output addr from index, else 0
    input   logic   [s_index-1:0]   w_index,              // index to write into the table
    input   rv32i_word              w_addr_pred,          // prediction to write into an entry                                from MEM
    input   logic                   w_load                // set for updating bht, will update state machine on next clk      if op == op_br
);

localparam num_sets = 2**s_index;

rv32i_word pc_predict    [num_sets-1:0] /* synthesis ramstyle = "logic" */;

always_comb
begin
    r_addr_pred = pc_predict[r_index];
end

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            pc_predict[i] <= '0;
    end
    else begin
        if(w_load)        // write the result of the branch
        begin
            pc_predict[w_index] <= w_addr_pred;
        end
    end
end


endmodule


//Branch Target Address Cache (BTAC) or Branch Target Buffer (BTB)

