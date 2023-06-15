/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

module cache_control 
import waymux::*;
(
    input clk,
    input rst,

    //datapath
    output logic cache_read,
    output logic cache_write,

    //output  load_way_sel,

    output  logic load_valid,
    output  logic valid_in,

    output  logic load_dirty,
    output  logic dirty_in,

    output  logic load_lru,
    output  logic lru_in,

    output  logic [31:0] load_data,
    output  logic load_tag,



    output  waymux::waymux_sel_t   waymux_sel,
    output  cacheinmux::cacheinmux_sel_t cacheinmux_sel,

    input   logic cache_dirty,
    input   logic cache_hit,
    input   logic cache_lru,
    input   logic hit_way0,

    //cacheline
    input   logic pmem_resp,
    output  logic pmem_write,
    output  logic pmem_read,

    //cpu
    output  logic mem_resp,
    input   logic mem_read,
    input   logic mem_write,
    input   logic [31:0]  mem_byte_enable256
);


enum int unsigned {
    /* List of states */
    IDLE,
    W,
    R,
    LD,
    WB
} state, next_state;

function void set_defaults();
    cache_read   = 1'b0;
    cache_write   = 1'b0;


    load_valid   = 1'b0;
    valid_in   = 1'b0;

    load_dirty   = 1'b0;
    dirty_in   = 1'b0;

    load_lru   = 1'b0;
    lru_in = 1'b0;

    load_data = 32'h0;
    load_tag = 1'b0;

    pmem_write = 1'b0;
    pmem_read = 1'b0;

    waymux_sel = waymux::use_hit;
    cacheinmux_sel = cacheinmux::use_mem;

    mem_resp = 1'b0;
    
endfunction


always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    
    unique case (state)
        IDLE:
        begin
            if (mem_read || mem_write)
            begin
                cache_read = 1'b1; //update cache index
            end
        end

        R:
        begin
            mem_resp    = cache_hit;
            pmem_read   = ~cache_hit;
            if (cache_hit)
            begin
                load_lru = 1'b1;
                lru_in = hit_way0;
            end

            if (pmem_resp)
            begin
                cache_read = 1'b1;
                load_data = 32'hFFFFFFFF;
                waymux_sel  = use_LRU;
            end
        end
        LD:
        begin
            if (mem_read)
                mem_resp = 1'b1;
            cache_read = 1'b1; //forawrds what is being loading into the cache directly to the CPU  
            
            waymux_sel  = use_LRU;
            load_data = 32'hFFFFFFFF;
            load_tag = 1'b1;

            load_dirty = 1'b1;
            dirty_in = 1'b0;

            load_valid = 1'b1;
            valid_in = 1'b1;

            load_lru = 1'b1;
            lru_in = ~cache_lru;

        end
        W:
        begin
            mem_resp = cache_hit;
            cacheinmux_sel = cacheinmux::use_cpu;
            if (cache_hit)
            begin
                waymux_sel = use_hit;
                load_data = mem_byte_enable256;

                load_dirty = 1'b1;
                dirty_in = 1'b1;

                load_lru = 1'b1;
                lru_in = hit_way0;
            end
        end
        WB:
        begin
            pmem_write = 1'b1;
            waymux_sel = use_LRU;
            if (pmem_resp)
            begin
                load_dirty = 1'b1;
                dirty_in = 1'b0;
                cache_read = 1'b1;
            end
        end
    endcase
end


always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
    
    unique case (state)
        IDLE:
        begin
            if (mem_read)
                next_state = R;
            else if(mem_write)
                next_state = W;
        end
        W:
        begin
            if (cache_hit)
                next_state = IDLE;
            else 
            begin
                if (cache_dirty)
                    next_state = WB;
                else
                    next_state = R;
            end
        end
        R:
        begin
            if (cache_hit)
                next_state = IDLE;  //end 2 cycle hit
            else 
            begin
                if (cache_dirty)
                    next_state = WB;
                else
                begin
                    if (pmem_resp) 
                        next_state = LD; //got repsonse
                    else
                        next_state = R; //loop
                end
            end
        end
        LD:
        begin
            if (mem_read)
                next_state = IDLE;
            else
                next_state = W;
        end
        WB:
        begin
            if (pmem_resp)
                next_state = R;
            else
                next_state = WB;
        end
    endcase
end


/* Assignment of next state on clock edge */
always_ff @(posedge clk)
begin: next_state_assignment
    if (rst)
        state <= IDLE; // double check this
    else
        state <= next_state;
end


endmodule : cache_control
