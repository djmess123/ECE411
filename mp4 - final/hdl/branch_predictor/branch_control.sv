module bc
import rv32i_types::*;
import mp4_types::*;
#(
parameter s_index = 4,
parameter width = 2
)
(
    input   logic       clk,
    input   logic       rst,

    //port to IF that requests a prediction
    input   rv32i_word  r_pc,

    //port from EX that updates prediction after branch is computed
    input   rv32i_word  w_pc,
    input   rv32i_word  w_dest,
    input   logic       load,

    output  rv32i_word  prediction
);





















endmodule
