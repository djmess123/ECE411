module cacheline_adaptor
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);

/******************************** Declarations *******************************/
logic [255:0] buffer ;

//default clocking cc @(negedge clk); endclocking

/******************************** Assignments ********************************/
//assign ready_o = ms.ready;
assign address_o = address_i;      //pass on address to memory

/************************** Behavioral Descriptions **************************/
//function void reset(output mstate_s ms_next);
//    ms_next = '0;
//    ms_next.ready = 1'b1;
//endfunction

function void defaults();
   
    line_o <= 256'd0;
    resp_o <= 1'b0;
    burst_o <= 64'd0;
    //address_o <= 32'd0;
    read_o <= 1'b0;
    write_o <= 1'b0;


endfunction

/***************************** Blocking Assignments **************************/
//always_comb 
//begin
//end


/*************************** Non-Blocking Assignments ************************/
initial 
forever @(posedge clk) begin
    defaults();
    if(reset_n)
    begin
        if(read_i && ~write_i)      //read from memory to cache
        begin
            read_o <= 1'b1;             //signal we want to read from memory
            write_o <= 1'b0;
            
            for (int burst_count = 0; burst_count < 4; burst_count++)
            begin
                @(negedge clk iff(resp_i));
                unique case (burst_count)
                    2'b00: buffer[63:0] <= burst_i;
                    2'b01: buffer[127:64] <= burst_i;
                    2'b10: buffer[191:128] <= burst_i;
                    2'b11: buffer[255:192] <= burst_i;
                endcase
                
                //buffer[64*burst_count +: 64] <= burst_i;    //put bursts into correct slices of buffer
            end

            @(clk iff (resp_i == 1'b0));

            line_o <= buffer;
            resp_o <= 1'b1;             //tell cache we are done
            @(negedge clk);
            resp_o <= 1'b0;             //stop response after 1 clk cycle
            read_o <= 1'b0;  

        //else if (~read_i && write_i)    //write from cache to memory
        end
        else if (~read_i && write_i)
        begin
            write_o <= 1'b1;             //signal we want to write to memory
            
            
            for (int burst_count = 0; burst_count < 4; burst_count++)
            begin
                @(negedge clk iff(resp_i));
                unique case (burst_count)
                    2'b00: burst_o <= line_i[63:0];
                    2'b01: burst_o <= line_i[127:64];
                    2'b10: burst_o <= line_i[191:128];
                    2'b11: burst_o <= line_i[255:192];
                endcase
                
                //buffer[64*burst_count +: 64] <= burst_i;    //put bursts into correct slices of buffer
            end

            @(clk iff (resp_i == 1'b0));

            resp_o <= 1'b1;             //tell cache we are done
            @(negedge clk);
            resp_o <= 1'b0;             //stop response after 1 clk cycle
            write_o <= 1'b0;  

        end
    end
end


endmodule : cacheline_adaptor