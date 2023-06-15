
module testbench(cam_itf itf);
import cam_types::*;

cam dut (
    .clk_i     ( itf.clk     ),
    .reset_n_i ( itf.reset_n ),
    .rw_n_i    ( itf.rw_n    ),
    .valid_i   ( itf.valid_i ),
    .key_i     ( itf.key     ),
    .val_i     ( itf.val_i   ),
    .val_o     ( itf.val_o   ),
    .valid_o   ( itf.valid_o )
);

default clocking tb_clk @(negedge itf.clk); endclocking

initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars();
end

task reset();
    itf.reset_n <= 1'b0;
    repeat (5) @(tb_clk);
    itf.reset_n <= 1'b1;
    repeat (5) @(tb_clk);
endtask

// DO NOT MODIFY CODE ABOVE THIS LINE

task write(input key_t key, input val_t val);
endtask

task read(input key_t key, output val_t val);
endtask

initial begin
    $display("Starting CAM Tests");

    reset();
    /************************** Your Code Here ****************************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.
    // Consider using the task skeletons above
    // To report errors, call itf.tb_report_dut_error in cam/include/cam_itf.sv


    for (int i = 0; i < 16; i++) 
    begin
        itf.rw_n <= 1'b0;       //write
        itf.valid_i <= 1'b1;    //good to go
        itf.key <= i;           //set key
        itf.val_i <= i+i;       //set value
        ##1;
    end

    for (int i = 8; i < 16; i++) 
    begin
        itf.rw_n <= 1'b1;       //read
        itf.valid_i <= 1'b1;    //good to go
        itf.key <= i;           //set key
        
        @(itf.clk);
        assert (itf.val_o == i+i)
        else begin
            $error("Incorrect read: Val_o = %d, Expected = %d", itf.val_o, i+i);
            itf.tb_report_dut_error(READ_ERROR);
        end
        ##1;
    end
    itf.valid_i <= 1'b0;    //end
    ##5

    itf.rw_n <= 1'b0;       //write
    itf.valid_i <= 1'b1;    //good to go
    itf.key <= 5;           //set key
    itf.val_i <= 7;         //set value
    ##1;
    itf.val_i <= 9;         //overwrite value
    ##1;
    itf.valid_i <= 1'b0;    //end
    ##5

    itf.rw_n <= 1'b0;       //write
    itf.valid_i <= 1'b1;    //good to go
    itf.key <= 5;           //set key
    itf.val_i <= 7;         //set value
    ##1;
    itf.rw_n <= 1'b1;       //read
    ##1;
    assert (itf.val_o == 7)
    else begin
        $error("Fail rear-write test");
        itf.tb_report_dut_error(READ_ERROR);
    end
    

    itf.valid_i <= 1'b0;    //end

    /**********************************************************************/

    itf.finish();
end

endmodule : testbench
