`ifndef testbench
`define testbench


module testbench(fifo_itf itf);
import fifo_types::*;

fifo_synch_1r1w dut (
    .clk_i     ( itf.clk     ),
    .reset_n_i ( itf.reset_n ),

    // valid-ready enqueue protocol
    .data_i    ( itf.data_i  ),
    .valid_i   ( itf.valid_i ),
    .ready_o   ( itf.rdy     ),

    // valid-yumi deqeueue protocol
    .valid_o   ( itf.valid_o ),
    .data_o    ( itf.data_o  ),
    .yumi_i    ( itf.yumi    )
);

initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars();
end

// Clock Synchronizer for Student Use
default clocking tb_clk @(negedge itf.clk); endclocking

task reset();
    itf.reset_n <= 1'b0;
    ##(10);
    itf.reset_n <= 1'b1;
    ##(1);
endtask : reset

function automatic void report_error(error_e err); 
    itf.tb_report_dut_error(err);
endfunction : report_error

// DO NOT MODIFY CODE ABOVE THIS LINE

initial begin
    reset();
    /************************ Your Code Here ***********************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.

    //enqueue 
    itf.valid_i <= 1'b1;
    for (int j = 0; j <= 255; j++) 
    begin
        assert (itf.rdy)
        else begin
            $error("Queue not ready: %d", j);
            break;
        end
        itf.data_i <= j[7:0];
        ##1;
    end
    itf.valid_i <= 1'b0;

    //dequeue 
    for (int j = 0; j <= 255; j++) 
    begin
        assert (itf.valid_o)
        else begin
            $error("Queue not valid (its definitely empty): %d", j);
            break;
        end
        itf.yumi <= 1'b1;
        assert(itf.data_o == j)
        else begin
            $error("Incorrect dequeue: Data_o = %d, Expected = %d", itf.data_o, j);
            report_error (INCORRECT_DATA_O_ON_YUMI_I);
        end
        ##1;
    end
    itf.yumi <= 1'b0;

    
    //enqueue and dequeue

    itf.valid_i <= 1'b1;
    itf.data_i <= 8'h00;   
    ##1;

    for (int j = 1; j <= 255; j++) 
    begin
        assert (itf.rdy)        //check full
        else begin
            $error("Queue not ready: %d", j);
            break;
        end
        itf.data_i <= j[7:0];   //enqueue

        assert (itf.valid_o)    //check empty
        else begin
            $error("Queue not valid (its definitely empty): %d", j);
            break;
        end
        itf.yumi <= 1'b1;           

        assert(itf.data_o == j/2)   //dequeue and check value
        else begin
            $error("Incorrect dequeue: Data_o = %d, Expected = %d", itf.data_o, j/2);
            report_error (INCORRECT_DATA_O_ON_YUMI_I);
        end

        ##1;
        itf.yumi <= 1'b0;  
        itf.data_i <= j;   //enqueue
        ##1;
    end
    itf.valid_i <= 1'b0;
    itf.yumi <= 1'b0;
    




    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    itf.finish();
    $error("TB: Illegal Exit ocurred");
end

always_ff @(posedge itf.clk)
begin
    if (~itf.reset_n)
    begin
        assert(itf.rdy)
        else begin
            $error("reset did not trigger ready");
            report_error (RESET_DOES_NOT_CAUSE_READY_O);
        end
    end
end

endmodule : testbench
`endif

