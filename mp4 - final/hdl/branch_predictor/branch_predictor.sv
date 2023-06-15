module bp
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
    output  rv32i_word  r_addr_pred,             
    output  logic       r_taken_pred,   

    //port from EX that updates prediction after branch is computed
    input   logic       w_br_op,
    input   rv32i_word  w_pc,       // pc of the branch instruction (ctrl.pc_addr or sumthin)
    input   rv32i_word  w_dest,     // address calculated of where the branch goes (alu_out)
    input   logic       w_taken      // whether or not the branch was taken (br_en)

);


//local signals
logic load;
logic r_hit;
logic w_hit;

logic [s_index-1:0] r_index;
logic [s_index-1:0] w_index;
logic [s_index-1:0] w_pc_index;
logic [s_index-1:0] lru_index;

logic r_taken;

logic load_bht;
logic load_btb;
logic load_lru;


always_comb begin : MUXES
    
    //final taken/not taken mux
    if (r_taken && r_hit)
        r_taken_pred = 1'b1;
    else
        r_taken_pred = 1'b0;

    //w_index mux
    if (w_hit)
        w_index = w_pc_index;      //hit? lets grab where to write to from the pc table
    else
        w_index = lru_index;    //no hit? lets find the next best spot with lru

    //load new values if the write input is either a BR or a JAL    (not JALR or any other isntruction)
    load = w_br_op;
end

// contains pc values in a lookup table
pct   #(.s_index(s_index), .width(width))   pct(
    .clk        (clk),
    .rst        (rst),
    .r_pc       (r_pc),
    .w_pc       (w_pc),
    .load       (load),
    .r_index    (r_index),
    .r_hit      (r_hit),
    .w_index    (w_index),
    .w_hit      (w_hit),
    .w_pc_index (w_pc_index)
);

// stores the state machine for T/NT
bht   #(.s_index(s_index), .width(width))  bht(        
    .clk               (clk),
    .rst               (rst),             //resets everything to strong not taken
    .r_index           (r_index),             // index to read from the table, from the btb
    .r_taken           (r_taken),             // output from msb of the r_index data, 1 for take, 0 for not-taken
    .w_index           (w_index),             // index to write into the table                                       hit ? btb : lru
    .w_taken           (w_taken),             // set for taken, 0 for not taken
    .w_new             (~w_hit),             // set for new entry, defaults state to weak version of w_taken
    .w_load            (load)              // set for updating bht, will update state machine on next clk
);

//stores the address the branch will likely take
btb   #(.s_index(s_index), .width(width))  btb(
    .clk                (clk),             
    .rst                (rst),                  //resets everything to addresses of 0
    .r_index            (r_index),              // index to read from the table, from the btb
    .r_addr_pred        (r_addr_pred),                     // output addr from index, else 0
    .w_index            (w_index),              // index to write into the table
    .w_addr_pred        (w_dest),               // prediction to write into an entry                                from MEM
    .w_load             (load)              // set for updating bht, will update state machine on next clk      if op == op_br
);

//stores the use history of all entries to efficiently swap out for new entries
lru  #(.s_index(s_index), .width(width))   lru(
    .clk                (clk),             
    .rst                (rst),             // resets lru array to all 0
    .lru_index          (lru_index),             // outputs current lru index value                      (comb)
    .w_load             (load),             // set at posedge to update LRU to w_index              (clocked)
    .w_new              (~w_hit),
    .w_index            (w_index)              // input for what to update (also add)
);


endmodule
