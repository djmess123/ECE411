module bht
import rv32i_types::*;
import mp4_types::*;
#(
parameter s_index = 4,
parameter width = 2
)
(
    input   logic       clk,
    input   logic       rst,            //resets everything to strong not taken

    //port to IF that requests a prediction
    input   logic [s_index-1:0]  r_index,   // index to read from the table, from the btb
    output  logic                r_taken,   // output from msb of the r_index data, 1 for take, 0 for not-taken

    //port from EX that updates prediction after branch is computed
    input   logic [s_index-1:0]   w_index,  // index to write into the table
    input   logic       w_taken,            // set for taken, 0 for not taken
    input   logic       w_load,             
    input   logic       w_new               // set for updating bht, will update state machine on next clk
    
);

localparam num_sets = 2**s_index;

logic [width-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;

always_comb
begin
    r_taken = data[r_index][width-1];     // most significant bit is prediction of T/NT
end

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            data[i] <= '0;
    end
    else 
    begin
        if(w_load == 1'b1)        // write the result of the branch
        begin
            if (w_new == 1'b1)
                data[w_index] <= {width{w_taken}};    //start fully saturated at initial taken value
            else
            begin
                if (w_taken == 1'b1) // taken
                begin
                    if (data[w_index] != {width{1'b1}})                    // make saturate at taken
                        data[w_index] <= data[w_index] + {{width{1'b0}},{(width-1){1'b1}}};
                end
                else        // not taken
                begin
                    if (data[w_index] != {width{1'b0}})                     // make saturate at not taken
                        data[w_index] <= data[w_index] - {{width{1'b0}},{(width-1){1'b1}}};
                end
            end
        end
    end
end







endmodule


//Branch Target Address Cache (BTAC) or Branch Target Buffer (BTB)

