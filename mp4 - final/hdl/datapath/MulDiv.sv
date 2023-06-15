
module mulDiv
import mult_types::*;
(
    input logic clk_i,
    input logic reset_n_i,
    input operand_t multiplicand_i,
    input operand_t multiplier_i,
    input logic start_i,
    input logic [2:0] funct,
    output logic ready_o,
    output logic[63:0] result_o,
    output logic done_o
);

/******************************** Declarations *******************************/
mstate_s ms;
mstate_s ms_reset;
mstate_s ms_init;
mstate_s ms_add;
mstate_s ms_shiftl;

dstate_s ds;
dstate_s ds_reset;
dstate_s ds_init;
logic update_state;

logic [width_p-1:0] divisor_copy;
logic [width_p-1:0] qicur, qinext;
logic [width_p:0]  ac, ac_next;
logic [2*width_p-1:0] quotient,remainder; 

/*****************************************************************************/

/******************************** Assignments ********************************/
assign ready_o = ms.ready;
/*****************************************************************************/

/******************************** Monitors ***********************************/
//initial $monitor($time, " DUT: ready_o: %1b", ready_o);
//initial $monitor($time, " DUT: reset_n_i: %1b", reset_n_i);
//initial $monitor($time, " DUT: state: %s", ms.op.name);
//initial $monitor($time, " DUT: clk: %1b, reset_n_i %1b, state: %s, rdy: %1b",
            //clk_i, reset_n_i, ms.op.name, ready_o);
/*****************************************************************************/

/************************** Behavioral Descriptions **************************/

// Describes reset state
function void m_reset(output mstate_s ms_next);
    ms_next = '0;
    ms_next.ready = 1'b1;
endfunction

function void d_reset(output dstate_s ds_next);
    ds_next = '0;
    ds_next.ready = 1'b1;
endfunction

// Describes multiplication initialization state
function void init_mult(input logic[width_p-1:0] multiplicand,
                   input logic[width_p-1:0] multiplier,
                   output mstate_s ms_next);
    ms_next.ready = 1'b0;
    ms_next.done = 1'b0;
    ms_next.iteration = 0;
    ms_next.op = ADD;

    ms_next.M = multiplicand;
    ms_next.C = 1'b0;
    ms_next.A = 0;
    ms_next.Q = multiplier;
endfunction

function void init_div(input logic[width_p-1:0] dividend,
                        input logic [width_p-1:0] divisor,
                        output dstate_s ds_next);
    ds_next.ready = 1'b0;
    ds_next.done = 1'b0;
    ds_next.iteration = 0;
    ds_next.op = DIV;

endfunction

// Describes state after add occurs
function void add(input mstate_s cur, output mstate_s next);
    next = cur;
    next.op = SHIFTL;
    if (cur.Q[0])
        {next.C, next.A} = 32'(cur.A + cur.M);
    else
        next.C = 1'b0;
endfunction

// Describes state after shift occurs
function void shiftl(input mstate_s cur, output mstate_s next);
      next = cur;
      {next.A, next.Q} = {cur.C, cur.A, cur.Q[width_p-1:1]};
      next.op = ADD;
      next.iteration += 1;
      if (next.iteration == width_p) begin
            next.op = DONE;
            next.done = 1'b1;
            next.ready = 1'b1;
      end
endfunction

// function void shiftr(input dstate_s cur, output dstate_s next);
//     next = cur;
//     if(cur.A>=cur.Q) begin
//         next.A=cur.A-cur.Q;
//         {next.A,next.C} = {next.A[width_p-1:0],cur.C,1'b1};
//     end else begin
//         {next.A,next.C} = {cur.A,cur.C}<<1;
//     end
//     next.iteration += 1;  
//     next.op=SUB;
//     if(next.iteration == width_p) begin
//             next.op = DONE;
//             next.done = 1'b1;
//             next.ready = 1'b1;
//     end
// endfunction

// function void sub(input dstate_s cur, output dstate_s next);
//     next=cur;
//     next.op=SHIFTR;
// endfunction
/*****************************************************************************/

always_comb begin
    update_state = 1'b0;
    if ((~reset_n_i) | (start_i) | (ms.op == ADD) || (ms.op == SHIFTL) || (ds.op == DIV))
        update_state = 1'b1;
    if (funct[2]==1'b0)begin
        m_reset(ms_reset);
        case(funct[1:0])
            0: init_mult($signed(multiplicand_i), $signed(multiplier_i), ms_init);
            1: init_mult($signed(multiplicand_i), $signed(multiplier_i), ms_init);
            2: init_mult($signed(multiplicand_i), $unsigned(multiplier_i), ms_init);
            3: init_mult($unsigned(multiplicand_i), $unsigned(multiplier_i), ms_init);
        endcase
        add(ms, ms_add);
        shiftl(ms, ms_shiftl);
    end else begin
        d_reset(ds_reset);
        case(funct[0])
            0: init_div($signed(multiplicand_i), $signed(multiplier_i), ds_init);
            1: init_div($unsigned(multiplicand_i), $unsigned(multiplier_i), ds_init);
        endcase
        init_div(multiplicand_i, multiplier_i, ds_init);
        if(ac >= {1'b0,divisor_copy})begin
            ac_next = ac-divisor_copy;
            {ac_next, qinext} = {ac_next[width_p-1:0],qicur,1'b1};
        end else begin
            {ac_next, qinext} = {ac,qicur}<<1;
        end
    end
end

/*************************** Non-Blocking Assignments ************************/
always_ff @(posedge clk_i) begin
    if (~reset_n_i)begin
            ms <= ms_reset;
            ds <= ds_reset;
    end
    else if (update_state||ds.op==DONE||ds.op==NONE) begin
        if (start_i & ready_o) begin
            if (funct[2]==1'b0)
            begin
                ms <= ms_init;
                ds<=ds_reset;
            end
            else
            begin
                ds<=ds_init;
                ms<=ms_reset;
                divisor_copy<=multiplier_i;
                {ac,qicur} <={{width_p{1'b0}},multiplicand_i,1'b0};
            end
        end
        else begin
            if (funct[2]==1'b0)begin
                case (ms.op)
                    ADD: ms <= ms_add;
                    SHIFTL: ms <= ms_shiftl;
                    default: ms <= ms_reset;
                endcase
            end
            else 
                case(ds.op)
                    DIV:
                    begin
                        ac<=ac_next;
                        qicur<=qinext;
                        ds.iteration<=ds.iteration+1;
                        if(ds.iteration==width_p-1)
                            ds.op<=DONE;
                    end
                    DONE:
                    begin
                        ds.done<=1'b1;
                        quotient<=qicur;
                        remainder<=ac[width_p:1];
                        ds.op<=NONE;
                    end
                    default:
                    begin
                        ds<=ds_reset;
                        ds.done<=1'b0;
                    end
                endcase
        end
    end
end

always_ff @(posedge clk_i)begin
    if (funct[2]==1'b0) begin
        done_o <= ms.done;
        result_o <= ({ms.A, ms.Q});
    end else begin
        done_o <= ds.done;
        if(funct[1]==1'b0)
        begin
            if(multiplier_i=='hffffffff && multiplicand_i=='h80000000)
            begin
                if(funct==4)
                    result_o<=32'h80000000;
                else
                    result_o<=operand_t'(quotient);
            end
            else
                result_o<=operand_t'(quotient);
        end
        else
        begin
            if(multiplier_i==32'hffffffff && multiplicand_i==32'h80000000)
            begin
                if(funct==6)
                    result_o<=0;
                else
                    result_o<=operand_t'(remainder);
            end
            else
                result_o<=operand_t'(remainder);
        end
    end
end
/*****************************************************************************/

// synthesis translate_off
//default clocking @(posedge clk_i); endclocking
//default disable iff (~reset_n_i)
//
//genvar i;
//genvar j;
//generate
//    for (i = 0; i < (1 << width_p); ++i) begin : outer_cover_loop
//        for (j = 0; j < (1 << width_p); ++j) begin : inner_cover_loop
//            mult_cover: cover property (
//                start_i and (multiplicand_i == i) and (multiplier_i == j)
//            );
//        end
//    end
//endgenerate
// synthesis translate_on

endmodule : mulDiv

