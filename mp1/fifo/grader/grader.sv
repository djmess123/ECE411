`ifndef grader
`define grader


module grader(fifo_itf itf);
import fifo_types::*;
import grader_types::*;

grader_itf gitf(itf.clk);

transaction_monitor mon (.*);
transaction_scoreboard scb (.*);

int log_fd, stu_fd;
string err;

initial begin
    log_fd = $fopen("./log.txt", "w");
    stu_fd = $fopen("./student_log.txt", "w");
    if ((log_fd == 0) || (stu_fd == 0)) begin
        $error("%s %0d: Unable to open log file(s)",
                `__FILE__, `__LINE__);
        $exit;
    end
    $display("GDR: Grader Running");
    repeat (cap_p * 1000) @(posedge itf.clk);
    $display("GDR: Timing Out");
    $finish;
end

function automatic int findErrors(const ref logic src [time],
                                  const ref logic dst [time]);
    parameter int search_radius = 1;
    int rv = 0;
    foreach(src[t]) begin
        $display("src[%0t]", t);
        rv += 1;
        for (int i = int'(t-search_radius); i <= int'(t+search_radius); ++i) begin
            if (dst.exists(i)) begin
                rv -= 1;
                break;
            end
        end
    end
    return rv;
endfunction : findErrors

int res_false_pos, res_false_neg, data_false_pos, data_false_neg;
function void setErrors;
    res_false_pos = findErrors(itf.stu_errors.res, gitf.grd_errors.res);
    res_false_neg = findErrors(gitf.grd_errors.res, itf.stu_errors.res);
    data_false_pos = findErrors(itf.stu_errors.data, gitf.grd_errors.data);
    data_false_neg = findErrors(gitf.grd_errors.data, itf.stu_errors.data);
endfunction


task logErrors(int fd);
    $fdisplay(fd, "%0d False Positive Reset Errors", res_false_pos);
    $fdisplay(fd, "%0d False Negative Reset Errors", res_false_neg);
    $fdisplay(fd, "%0d False Positive Data Errors", data_false_pos);
    $fdisplay(fd, "%0d False Negative Data Errors", data_false_neg);
endtask

task logCoverage(int fd, logic full);
    $fdisplay(fd, "Passed %0d of %0d enqueue covers", 
        $countones(gitf.covers.enqs), cap_p);
    $fdisplay(fd, "Passed %0d of %0d dequeue covers", 
        $countones(gitf.covers.deqs), cap_p);
    $fdisplay(fd, "Passed %0d of %0d both covers", 
        $countones(gitf.covers.boths), cap_p-1);
    if (full) begin
        for (int i = 0; i < $size(gitf.covers.enqs)-1; ++i)
            if (!gitf.covers.enqs[i])
                $fdisplay(fd, "Failed Enqueue[%0d]", i);
            for (int i = 1; i < $size(gitf.covers.deqs); ++i)
            if (!gitf.covers.deqs[i])
                $fdisplay(fd, "Failed Dequeue[%0d]", i);
            for (int i = 1; i < $size(gitf.covers.boths)-1; ++i)
            if (!gitf.covers.boths[i])
                $fdisplay(fd, "Failed Both[%0d]", i);
    end
endtask : logCoverage

final begin
    $display("GDR: Cleaning Up Grading Run...");
    logCoverage(log_fd, 1'b1);
    logCoverage(stu_fd, 1'b0);
    setErrors();
    logErrors(log_fd);
    logErrors(stu_fd);
    $fclose(log_fd);
    $fclose(stu_fd);
end

endmodule : grader
`endif

