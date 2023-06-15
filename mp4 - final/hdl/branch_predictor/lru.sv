module lru
import rv32i_types::*;
import mp4_types::*;
#(
parameter s_index = 4,
parameter width = 2
)
(
    input   logic       clk,
    input   logic       rst,                // resets lru array to all 0
    input   logic       w_load,               // set at posedge to update LRU to w_index              (clocked)
    input   logic       w_new,

    input   logic   [s_index-1:0]   w_index, // input for what to update (also add)

    output  logic   [s_index-1:0]   lru_index // outputs current lru index value                      (comb)
);

localparam num_sets = 2**s_index;

// LRU:   ... 0000 0000 | 0000 | 00 | 0  <-- lsb is top of tree
logic [num_sets-1:0] lru;

always_comb begin : READ_INDEX
    lru_calculate(0,0);
end




always_ff @(posedge clk) begin : LRU_UPDATE_ADD
    if (rst)
        lru <= '0;
    if (w_load)
    begin
        if (w_new)
            lru_update(lru_index,0,0);  //add entry to the least recently used
        else
            lru_update(w_index, 0, 0);    //trace thru tree and update lru based on hit w_index
    end
end



// walks thru to find LRU, updates bits on the way, and returns address of new location
function automatic void lru_add (input integer depth, p);
    
    //check for end
    if (depth == s_index)
        return;
    
    //recurse
    else
    begin
        if (lru[p])
        begin
            lru[p] <= 1'b0;  //set opposite
            lru_add(depth+1, (2*p)+2);  //right (1)
            return;
        end
        else
        begin
            lru[p] <= 1'b1;  //set opposite
            lru_add(depth+1, (2*p)+1);  //left (0)
            return;
        end
    end

endfunction 



// walsk thru and updates LRU bit
function automatic void lru_update (input [s_index-1:0] index_target, input integer depth, p);
    
    //check for end
    if (depth == s_index)
        return;
    
    //recurse
    else
    begin
        if (index_target[depth])
        begin
            lru[p] <= 1'b0;  //set opposite
            lru_update(index_target, depth+1, (2*p)+2);  //right (1)
            return;
        end
        else
        begin
            lru[p] <= 1'b1;  //set opposite
            lru_update(index_target, depth+1, (2*p)+1);  //left (0)
            return;
        end
    end

endfunction 




// generates index combinationally
function automatic void lru_calculate (input integer depth, p);
    
    //check for end
    if (depth == s_index)
        return;
    
    //recurse
    else
    begin
        if (lru[p])
        begin
            lru_index[depth] = lru[p];
            lru_calculate(depth+1, (2*p)+2);  //right (1)
            return;
        end
        else
        begin
            lru_index[depth] = lru[p];
            lru_calculate(depth+1, (2*p)+1);  //left (0)
            return;
        end
    end

endfunction 


endmodule


//Branch Target Address Cache (BTAC) or Branch Target Buffer (BTB)

