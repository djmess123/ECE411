/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

module cache_control #(
    parameter s_offset = 5,
    // parameter s_index  = 3,
    parameter s_index  = 5,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input rst,

    input logic mem_read, mem_write, pmem_resp,
    input logic [31:0] mem_address,

    input logic v0_out, v1_out, v2_out, v3_out, 
    input logic d0_out, d1_out, d2_out, d3_out, 
    input logic lru_out,
    input logic [2:0] lru4_out,
    input logic [s_tag:0] tag0_out, tag1_out, tag2_out, tag3_out, tag_out,

    output logic v0_ld, v1_ld, v2_ld, v3_ld, 
    output logic d0_ld, d1_ld, d2_ld, d3_ld, 
    output logic tag0_ld, tag1_ld, tag2_ld, tag3_ld, 
    output logic lru_ld, lru4_ld,
    output logic v0_in, v1_in, v2_in, v3_in, 
    output logic d0_in, d1_in, d2_in, d3_in, 
    output logic lru_in,
    output logic [2:0] lru4_in,
    output logic write_0, write_1, write_2, write_3,

    output logic mem_sel, data_out_sel, pmem_adr_sel, 
    output logic [1:0] data_out_sel4,
    output logic en_sel0, en_sel1, en_sel2, en_sel3,
    output logic mem_resp, pmem_read, pmem_write,

    output logic cache_hit_out, cache_call_out
);

enum int unsigned {
    /* List of states */
    waiting,
    read,
    write,
    write_back0,
    write_back1,
    write_back2,
    write_back3,
    allocate0,
    allocate1,
    allocate2,
    allocate3,
    allocate_dirty0,
    allocate_dirty1,
    allocate_dirty2,
    allocate_dirty3,
    write0,
    write1,
    write2,
    write3

} state, next_state;

function void set_defaults();
    lru_ld = 1'b0;
    lru4_ld = 1'b0;

    tag0_ld = 1'b0;
    d0_ld = 1'b0;
    v0_ld = 1'b0;

    tag1_ld = 1'b0;
    d1_ld = 1'b0;
    v1_ld = 1'b0;

    tag2_ld = 1'b0;
    d2_ld = 1'b0;
    v2_ld = 1'b0;

    tag3_ld = 1'b0;
    d3_ld = 1'b0;
    v3_ld = 1'b0;

    mem_sel = 1'b0;
    data_out_sel = 1'b0;
    data_out_sel4 = 2'b00;
    pmem_adr_sel = 1'b0;

    en_sel0 = 1'b0;
    en_sel1 = 1'b0;
    en_sel2 = 1'b0;
    en_sel3 = 1'b0;

    mem_resp = 1'b0;
    pmem_read = 1'b0;
    pmem_write = 1'b0;
    write_0 = 1'b0;
    write_1 = 1'b0;
    write_2 = 1'b0;
    write_3 = 1'b0;
endfunction

always_comb
begin : state_actions

    set_defaults(); 

    case(state)

    waiting:
    begin 

        if (mem_read)
        begin
            if ((tag0_out == mem_address[31:32-s_tag]) && (v0_out == 1'b1))
            begin
                lru4_ld = 1'b1;
                // CHANGE LRU IN!!!
                lru4_in = {2'b00, lru4_in[2]}; 
                data_out_sel4 = 2'b00;
                mem_resp = 1'b1;
            end
            else if ((tag1_out == mem_address[31:32-s_tag]) && (v1_out == 1'b1))
            begin
                lru4_ld = 1'b1;
                // CHANGE LRU IN!!!
                lru4_in = {2'b01, lru4_in[2]}; 
                data_out_sel4 = 2'b01;
                mem_resp = 1'b1;
            end
            else if ((tag2_out == mem_address[31:32-s_tag]) && (v2_out == 1'b1))
            begin
                lru4_ld = 1'b1;
                // CHANGE LRU IN!!!
                lru4_in = {1'b1, lru4_in[1], 1'b0}; 
                data_out_sel4 = 2'b10;
                mem_resp = 1'b1;
            end
            else if ((tag3_out == mem_address[31:32-s_tag]) && (v3_out == 1'b1))
            begin
                lru4_ld = 1'b1;
                // CHANGE LRU IN!!!
                lru4_in = {1'b1, lru4_in[1], 1'b1}; 
                data_out_sel4 = 2'b11;
                mem_resp = 1'b1;
            end
        end

        else if (mem_write)
        begin
            if ((tag0_out == mem_address[31:32-s_tag]) && (v0_out == 1'b1))
            begin
                lru4_ld = 1'b1;
                // CHANGE LRU IN!!!
                lru4_in = {2'b00, lru4_in[2]}; 
                data_out_sel4 = 2'b00;
                mem_resp = 1'b1;
                d0_ld = 1'b1;
                d0_in = 1'b1;
                write_0 = 1'b1;
            end
            else if ((tag1_out == mem_address[31:32-s_tag]) && (v1_out == 1'b1))
            begin
                lru4_ld = 1'b1;
                // CHANGE LRU IN!!!
                lru4_in = {2'b01, lru4_in[2]}; 
                data_out_sel4 = 2'b01;
                mem_resp = 1'b1;
                d1_ld = 1'b1;
                d1_in = 1'b1;
                write_1 = 1'b1;
            end
            else if ((tag2_out == mem_address[31:32-s_tag]) && (v2_out == 1'b1))
            begin
                lru4_ld = 1'b1;
                // CHANGE LRU IN!!!
                lru4_in = {1'b1, lru4_in[1], 1'b0}; 
                data_out_sel4 = 2'b10;
                mem_resp = 1'b1;
                d2_ld = 1'b1;
                d2_in = 1'b1;
                write_2 = 1'b1;
            end
            else if ((tag3_out == mem_address[31:32-s_tag]) && (v3_out == 1'b1))
            begin
                lru4_ld = 1'b1;
                // CHANGE LRU IN!!!
                lru4_in = {1'b1, lru4_in[1], 1'b1}; 
                data_out_sel4 = 2'b11;
                mem_resp = 1'b1;
                d3_ld = 1'b1;
                d3_in = 1'b1;
                write_3 = 1'b1;
            end
        end
    end

    write0:
    begin
        if ((tag0_out == mem_address[31:32-s_tag]) && (v0_out == 1'b1))
        begin
            lru4_ld = 1'b1;
            // CHANGE LRU IN!!!
            lru4_in = {2'b00, lru4_in[2]}; 
            data_out_sel4 = 2'b00;
            mem_resp = 1'b1;
            d0_ld = 1'b1;
            d0_in = 1'b1;
            write_0 = 1'b1;
        end
    end

    write1:
    begin
        if ((tag1_out == mem_address[31:32-s_tag]) && (v1_out == 1'b1))
        begin
            lru4_ld = 1'b1;
            // CHANGE LRU IN!!!
            lru4_in = {2'b01, lru4_in[2]}; 
            data_out_sel4 = 2'b01;
            mem_resp = 1'b1;
            d1_ld = 1'b1;
            d1_in = 1'b1;
            write_1 = 1'b1;
        end
    end

    write2:
    begin
        if ((tag2_out == mem_address[31:32-s_tag]) && (v2_out == 1'b1))
        begin
            lru4_ld = 1'b1;
            // CHANGE LRU IN!!!
            lru4_in = {1'b1, lru4_in[1], 1'b0}; 
            data_out_sel4 = 2'b10;
            mem_resp = 1'b1;
            d2_ld = 1'b1;
            d2_in = 1'b1;
            write_2 = 1'b1;
        end
    end

    write3:
    begin
        if ((tag3_out == mem_address[31:32-s_tag]) && (v3_out == 1'b1))
        begin
            lru4_ld = 1'b1;
            // CHANGE LRU IN!!!
            lru4_in = {1'b1, lru4_in[1], 1'b1}; 
            data_out_sel4 = 2'b11;
            mem_resp = 1'b1;
            d3_ld = 1'b1;
            d3_in = 1'b1;
            write_3 = 1'b1;
        end
    end

    write_back0:
    begin
        pmem_write = 1'b1;
        pmem_adr_sel = 1'b1;
        data_out_sel4 = 2'b00;
    end

    write_back1:
    begin
        pmem_write = 1'b1;
        pmem_adr_sel = 1'b1;
        data_out_sel4 = 2'b01;
    end

    write_back2:
    begin
        pmem_write = 1'b1;
        pmem_adr_sel = 1'b1;
        data_out_sel4 = 2'b10;
    end

    write_back3:
    begin
        pmem_write = 1'b1;
        pmem_adr_sel = 1'b1;
        data_out_sel4 = 2'b11;
    end

    allocate0:
    begin
        pmem_read = 1'b1;
        lru4_ld = 1'b1;
        // CHANGE LRU IN!!!
        lru4_in = {2'b00, lru4_in[2]}; 
        tag0_ld = 1'b1;
        d0_ld = 1'b1;
        d0_in = 1'b0;
        mem_sel = 1'b1;
        v0_ld = 1'b1;
        v0_in = 1'b1;
        data_out_sel4 = 2'b00;
        en_sel0 = 1'b1;
    end

    allocate1:
    begin
        pmem_read = 1'b1;
        lru4_ld = 1'b1;
        // CHANGE LRU IN!!!
        lru4_in = {2'b01, lru4_in[2]}; 
        tag1_ld = 1'b1;
        d1_ld = 1'b1;
        d1_in = 1'b0;
        mem_sel = 1'b1;
        v1_ld = 1'b1;
        v1_in = 1'b1;
        data_out_sel4 = 2'b01;
        en_sel1 = 1'b1;
    end

    allocate2:
    begin
        pmem_read = 1'b1;
        lru4_ld = 1'b1;
        // CHANGE LRU IN!!!
        lru4_in = {1'b1, lru4_in[1], 1'b0}; 
        tag2_ld = 1'b1;
        d2_ld = 1'b1;
        d2_in = 1'b0;
        mem_sel = 1'b1;
        v2_ld = 1'b1;
        v2_in = 1'b1;
        data_out_sel4 = 2'b10;
        en_sel2 = 1'b1;
    end

    allocate3:
    begin
        pmem_read = 1'b1;
        lru4_ld = 1'b1;
        // CHANGE LRU IN!!!
        lru4_in = {1'b1, lru4_in[1], 1'b1}; 
        tag3_ld = 1'b1;
        d3_ld = 1'b1;
        d3_in = 1'b0;
        mem_sel = 1'b1;
        v3_ld = 1'b1;
        v3_in = 1'b1;
        data_out_sel4 = 2'b11;
        en_sel3 = 1'b1;
    end

    allocate_dirty0:
    begin
        pmem_read = 1'b1;
        lru4_ld = 1'b1;
        // CHANGE LRU IN!!!
        lru4_in = {2'b00, lru4_in[2]}; 
        tag0_ld = 1'b1;
        d0_ld = 1'b1;
        d0_in = 1'b0;
        mem_sel = 1'b1;
        v0_ld = 1'b1;
        v0_in = 1'b1;
        data_out_sel = 2'b00;
        en_sel0 = 1'b1;
    end

    allocate_dirty1:
    begin
        pmem_read = 1'b1;
        lru4_ld = 1'b1;
        // CHANGE LRU IN!!!
        lru4_in = {2'b01, lru4_in[2]}; 
        tag1_ld = 1'b1;
        d1_ld = 1'b1;
        d1_in = 1'b0;
        mem_sel = 1'b1;
        v1_ld = 1'b1;
        v1_in = 1'b1;
        data_out_sel4 = 2'b01;
        en_sel1 = 1'b1;
    end

    allocate_dirty2:
    begin
        pmem_read = 1'b1;
        lru4_ld = 1'b1;
        // CHANGE LRU IN!!!
        lru4_in = {1'b1, lru4_in[1], 1'b0}; 
        tag2_ld = 1'b1;
        d2_ld = 1'b1;
        d2_in = 1'b0;
        mem_sel = 1'b1;
        v2_ld = 1'b1;
        v2_in = 1'b1;
        data_out_sel4 = 2'b10;
        en_sel2 = 1'b1;
    end

    allocate_dirty3:
    begin
        pmem_read = 1'b1;
        lru4_ld = 1'b1;
        // CHANGE LRU IN!!!
        lru4_in = {1'b1, lru4_in[1], 1'b1}; 
        tag3_ld = 1'b1;
        d3_ld = 1'b1;
        d3_in = 1'b0;
        mem_sel = 1'b1;
        v3_ld = 1'b1;
        v3_in = 1'b1;
        data_out_sel4 = 2'b11;
        en_sel3 = 1'b1;
    end

    endcase
end

logic cache_hit;
logic cache_call;

always_comb
begin : next_state_logic

    cache_hit = 1'b0;
    cache_call = 1'b0;

    case(state)

    waiting:
    begin

        if (mem_read)
        begin
            cache_call = 1'b1;
            if (((tag0_out == mem_address[31:32-s_tag]) && (v0_out == 1'b1)) 
             || ((tag1_out == mem_address[31:32-s_tag]) && (v1_out == 1'b1))
             || ((tag2_out == mem_address[31:32-s_tag]) && (v2_out == 1'b1))
             || ((tag3_out == mem_address[31:32-s_tag]) && (v3_out == 1'b1)))
                begin
                next_state = waiting;
                cache_hit = 1'b1;
                end
            
            else if ((v0_out == 1'b0))
                next_state = allocate0;
            else if ((v1_out == 1'b0))
                next_state = allocate1;
            else if ((v2_out == 1'b0))
                next_state = allocate2;
            else if ((v3_out == 1'b0))
                next_state = allocate3;

            // PSEUDO LRU
            else if (lru4_out[0] == 1'b0)      // [0,_,0]  0 1 2 3
            begin
                if (lru4_out[2] == 1'b0)       // go to way 3
                begin
                    if (d3_out == 1'b1)
                        next_state = write_back3;
                    else
                        next_state = allocate_dirty3;
                end
                else                           // go to way 2
                begin
                    if (d2_out == 1'b1)
                        next_state = write_back2;
                    else
                        next_state = allocate_dirty2;
                end
            end
            else 
            begin
                if (lru4_out[1] == 1'b0)       // go to way 1        [1, 0, _]
                begin
                    if (d1_out == 1'b1)
                        next_state = write_back1;
                    else
                        next_state = allocate_dirty1;
                end
                else                           // go to way 0
                begin
                    if (d0_out == 1'b1)
                        next_state = write_back0;
                    else
                        next_state = allocate_dirty0;
                end
            end
        end

        else if (mem_write)
        begin
            cache_call = 1'b1;
            if (((tag0_out == mem_address[31:32-s_tag]) && (v0_out == 1'b1)) 
             || ((tag1_out == mem_address[31:32-s_tag]) && (v1_out == 1'b1))
             || ((tag2_out == mem_address[31:32-s_tag]) && (v2_out == 1'b1))
             || ((tag3_out == mem_address[31:32-s_tag]) && (v3_out == 1'b1)))
                begin
                    cache_hit = 1'b1;
                    next_state = waiting;
                end

            else if ((v0_out == 1'b0))
                next_state = allocate0;
            else if ((v1_out == 1'b0))
                next_state = allocate1;
            else if ((v2_out == 1'b0))
                next_state = allocate2;
            else if ((v3_out == 1'b0))
                next_state = allocate3;

            // PSEUDO LRU
            else if (lru4_out[0] == 1'b0)      // [0,_,0]  0 1 2 3
            begin
                if (lru4_out[2] == 1'b0)       // go to way 3
                begin
                    if (d3_out == 1'b1)
                        next_state = write_back3;
                    else
                        next_state = allocate_dirty3;
                end
                else                           // go to way 2
                begin
                    if (d2_out == 1'b1)
                        next_state = write_back2;
                    else
                        next_state = allocate_dirty2;
                end
            end
            else 
            begin
                if (lru4_out[1] == 1'b0)       // go to way 1        [1, 0, _]
                begin
                    if (d1_out == 1'b1)
                        next_state = write_back1;
                    else
                        next_state = allocate_dirty1;
                end
                else                           // go to way 0
                begin
                    if (d0_out == 1'b1)
                        next_state = write_back0;
                    else
                        next_state = allocate_dirty0;
                end
            end
        end
        else
            next_state = waiting;
    end

    write0:
    begin
        next_state = waiting;
    end

    write1:
    begin
        next_state = waiting;
    end

    write2:
    begin
        next_state = waiting;
    end

    write3:
    begin
        next_state = waiting;
    end

    allocate0:
    begin
        if (pmem_resp)
        begin
            if (mem_read == 1'b1)
                next_state = waiting;
            else
                next_state = write0;
        end
        else
            next_state = allocate0;
    end

    allocate1:
    begin
        if (pmem_resp)
        begin
            if (mem_read == 1'b1)
                next_state = waiting;
            else
                next_state = write1;
        end
        else
            next_state = allocate1;
    end

    allocate2:
    begin
        if (pmem_resp)
        begin
            if (mem_read == 1'b1)
                next_state = waiting;
            else
                next_state = write2;
        end
        else
            next_state = allocate2;
    end

    allocate3:
    begin
        if (pmem_resp)
        begin
            if (mem_read == 1'b1)
                next_state = waiting;
            else
                next_state = write3;
        end
        else
            next_state = allocate3;
    end

    write_back0:
    begin
        if (pmem_resp)
            next_state = allocate_dirty0;
        else
            next_state = write_back0;
    end

    write_back1:
    begin
        if (pmem_resp)
            next_state = allocate_dirty1;
        else
            next_state = write_back1;
    end

    write_back2:
    begin
        if (pmem_resp)
            next_state = allocate_dirty2;
        else
            next_state = write_back2;
    end

    write_back3:
    begin
        if (pmem_resp)
            next_state = allocate_dirty3;
        else
            next_state = write_back3;
    end

    allocate_dirty0:
    begin
        if (pmem_resp)
        begin
            if (mem_read == 1'b1)
                next_state = waiting;
            else
                next_state = write0;
        end
        else
            next_state = allocate_dirty0;
    end

    allocate_dirty1:
    begin
        if (pmem_resp)
        begin
            if (mem_read == 1'b1)
                next_state = waiting;
            else
                next_state = write1;
        end
        else
            next_state = allocate_dirty1;
    end

    allocate_dirty2:
    begin
        if (pmem_resp)
        begin
            if (mem_read == 1'b1)
                next_state = waiting;
            else
                next_state = write2;
        end
        else
            next_state = allocate_dirty2;
    end

    allocate_dirty3:
    begin
        if (pmem_resp)
        begin
            if (mem_read == 1'b1)
                next_state = waiting;
            else
                next_state = write3;
        end
        else
            next_state = allocate_dirty3;
    end

    endcase

    if (rst)
        next_state = waiting;
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
    cache_hit_out <= cache_hit;
    cache_call_out <= cache_call;
end

endmodule : cache_control
