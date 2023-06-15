module arbiter(
    input clk,
    input rst,

    input logic read_i,
    input logic [31:0] address_i,

    input logic read_d,
    input logic write_d,
    input logic [255:0] wdata_d,
    input logic [31:0] address_d,

    input logic resp,
    input logic [255:0] rdata,

    output logic [255:0] rdata_i,
    output logic resp_i,

    output logic [255:0] rdata_d,
    output logic resp_d,

    output logic read,
    output logic write,
    output logic [255:0] wdata,
    output logic [31:0] address
);

enum int unsigned {
    waiting,
    icache,
    dcache
} state, next_state;

function void set_defaults();
    rdata_i = 256'b0;
    resp_i = 1'b0;
    rdata_d = 256'b0;
    resp_d = 1'b0;
    read = 1'b0;
    write = 1'b0;
    wdata = 256'b0;
    address = 32'b0;
endfunction

always_comb
begin : state_actions

    set_defaults(); 

    case(state)

    waiting:;

    icache:
    begin
        if (read_i == 1'b1) 
        begin
            read = 1'b1;
        end
        address = address_i;
        rdata_i = rdata;
        resp_i = resp;
    end
    
    dcache:
    begin
        address = address_d;
        resp_d = resp;
        if (read_d == 1'b1)
        begin
            read = 1'b1;
            rdata_d = rdata;
        end
        else if (write_d == 1'b1)
        begin
            write = 1'b1;
            wdata = wdata_d;
        end
    end

    endcase
end

always_comb
begin : next_state_logic

    case(state)

    waiting:
    begin
        if (read_i == 1'b1)
            next_state = icache;
        else if ((read_d == 1'b1) || (write_d == 1'b1))
            next_state = dcache;
        else
            next_state = waiting;
    end
    
    icache:
    begin
        if (resp == 1'b1)
            next_state = waiting;
        else 
            next_state = icache;
    end
    
    dcache:
    begin
        if (resp == 1'b1)
            next_state = waiting;
        else 
            next_state = dcache;
    end

    endcase

    if (rst)
        next_state = waiting;
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

endmodule : arbiter
