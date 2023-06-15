module pct
import rv32i_types::*;
import mp4_types::*;
#(
parameter s_index = 4,
parameter width = 2
)
(
    input   logic       clk,
    input   logic       rst,

    input   rv32i_word              r_pc,
    output  logic   [s_index-1:0]   r_index,
    output  logic                   r_hit,

    input   rv32i_word              w_pc,
    input   logic                   load,
    output  logic   [s_index-1:0]   w_pc_index,     // valid if hit
    input   logic   [s_index-1:0]   w_index,        // hit ? w_pc_index : lru_index
    output  logic                   w_hit

);
localparam num_sets = 2**s_index;

/* synthesis ramstyle = "logic" */
rv32i_word pc_lookup     [num_sets-1:0];

always_comb
begin
    r_hit = 1'b0;
    w_hit = 1'b0;
    r_index = '0;
    w_pc_index = '0;
    for (int i = 0; i < num_sets; i++)
    begin       
        if (pc_lookup[i] == r_pc)                       //detect hit read
        begin
            r_hit = 1'b1; 
            r_index = i[s_index-1:0];
        end
        if (pc_lookup[i] == w_pc)                       //detect hit on write
        begin
            w_hit = 1'b1; 
            w_pc_index = i[s_index-1:0];
        end
    end
end


always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            pc_lookup[i] <= '0;
    end
    else begin
        if(load)        // write the result of the branch
            pc_lookup[w_index] <= w_pc;
    end
end

endmodule

