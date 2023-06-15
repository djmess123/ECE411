module ght
import rv32i_types::*;
import mp4_types::*;
#(
parameter correlation = 1
)
(
    input   logic       clk,
    input   logic       rst,            //resets everything to strong not taken

    //port to IF that requests a prediction
    output  logic [correlation-1:0]  r_index,   // index to read from the table, from the btb

    //port from EX that updates prediction after branch is computed
    input   logic       w_taken,            // set for taken, 0 for not taken
    input   logic       w_load             
    
);

logic [correlation-1:0] shiftreg;

always_comb
begin
    r_index = shiftreg;     // most significant bit is prediction of T/NT
end

always_ff @(posedge clk)
begin
    if (rst) 
        shiftreg <= '0;
    else 
    begin
        if(w_load == 1'b1)        // write the result of the branch
            shiftreg <= {shiftreg[correlation-2:0],w_taken};
    end
end


endmodule


//Branch Target Address Cache (BTAC) or Branch Target Buffer (BTB)

