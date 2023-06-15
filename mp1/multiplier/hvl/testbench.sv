
`ifndef testbench
`define testbench
module testbench(multiplier_itf.testbench itf);
import mult_types::*;

add_shift_multiplier dut (
    .clk_i          ( itf.clk          ),
    .reset_n_i      ( itf.reset_n      ),
    .multiplicand_i ( itf.multiplicand ),
    .multiplier_i   ( itf.multiplier   ),
    .start_i        ( itf.start        ),
    .ready_o        ( itf.rdy          ),
    .product_o      ( itf.product      ),
    .done_o         ( itf.done         )
);

assign itf.mult_op = dut.ms.op;
default clocking tb_clk @(negedge itf.clk); endclocking

initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars();
end

// DO NOT MODIFY CODE ABOVE THIS LINE

/* Uncomment to "monitor" changes to adder operational state over time */
//initial $monitor("dut-op: time: %0t op: %s", $time, dut.ms.op.name);


// Resets the multiplier
task reset();
    itf.reset_n <= 1'b0;
    ##5;
    itf.reset_n <= 1'b1;
    ##1;
endtask : reset

// error_e defined in package mult_types in file ../include/types.sv
// Asynchronously reports error in DUT to grading harness
function void report_error(error_e error);
    itf.tb_report_dut_error(error);
endfunction : report_error

logic [15:0] correct_result = 16'h0000;

initial itf.reset_n = 1'b0;
initial begin
    reset();
    /********************** Your Code Here *****************************/
    assert (itf.rdy)
    else begin
        $error("Error: Not Ready");
        report_error (NOT_READY);
    end

	//run through all possible multiplications
	for (int i = 0; i <= 255; ++i) 
	begin
		itf.multiplicand <= i[7:0];
		correct_result <= 16'h0000;
		for (int j = 0; j <= 255; ++j) 
		begin
			itf.multiplier <= j[7:0];
			//begin
			itf.start <= 1'b1;
			##1;
			itf.start <= 1'b0;
			//wait for finish
			@(tb_clk iff (itf.done || itf.rdy));

			//check result
			assert (itf.product == correct_result)
            else begin
                $error("With %d x %d, dut outputs: %d while spec outputs: %d\n",
                        itf.multiplicand, itf.multiplier, itf.product, correct_result);
                report_error (BAD_PRODUCT);
            end
            assert (itf.rdy)
            else begin
                $error("Error: Not Ready");
                report_error (NOT_READY);
            end
			//update what the next test result will be
			##1;
			correct_result <= correct_result + itf.multiplicand;
			##1;
		end
	end
	
    //cover reset in ADD ============================
    itf.multiplicand <= 8'h17;
    itf.multiplier <= 8'hA1;
    correct_result <= 16'hE77;
    //begin
    itf.start <= 1'b1;
    ##1;
    itf.start <= 1'b0;

    itf.reset_n <= 1'b0;
    ##5;
    itf.reset_n <= 1'b1;
    ##5
    
    assert (itf.rdy)
    else begin
        $error("Error: Not Ready");
        report_error (NOT_READY);
    end
    //cover reset in SHIFT ============================
    //begin

    itf.start <= 1'b1;
    ##1;
    itf.start <= 1'b0;

    ##1
    itf.reset_n <= 1'b0;
    ##5;
    itf.reset_n <= 1'b1;
    ##5
    
    assert (itf.rdy)
    else begin
        $error("Error: Not Ready");
        report_error (NOT_READY);
    end

    //cover start in ADD ============================
    //begin
    itf.start <= 1'b1;
    ##1;
    itf.start <= 1'b0;

    itf.start <= 1'b0;
    ##5;
    itf.start <= 1'b1;

    @(tb_clk iff (itf.done));
    assert (itf.rdy)
    else begin
        $error("Error: Not Ready");
        report_error (NOT_READY);
    end


    //cover start in SHIFT ============================
    //begin
    ##5
    itf.start <= 1'b1;
    ##1;
    itf.start <= 1'b0;

    ##1
    itf.start <= 1'b0;
    ##5;
    itf.start <= 1'b1;

    @(tb_clk iff (itf.done));
    assert (itf.rdy)
    else begin
        $error("Error: Not Ready");
        report_error (NOT_READY);
    end

    /*******************************************************************/
    itf.finish(); // Use this finish task in order to let grading harness
                  // complete in process and/or scheduled operations
    $error("Improper Simulation Exit");
end


endmodule : testbench
`endif
