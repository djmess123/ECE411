
module cmp
import rv32i_types::*;
(
    input branch_funct3_t cmpop,
    input [31:0] a, b,
    output logic f
);

always_comb
begin
    unique case (cmpop)
    beq  :  f = (a == b) ? 1'b1 : 1'b0;
    bne  :  f = (a != b) ? 1'b1 : 1'b0;
    blt  :  f = ($signed(a) < $signed(b))  ? 1'b1 : 1'b0;
    bge  :  f = ($signed(a) >= $signed(b)) ? 1'b1 : 1'b0;
    bltu :  f = (a < b)  ? 1'b1 : 1'b0;
    bgeu :  f = (a >= b) ? 1'b1 : 1'b0;
    default : f = 1'bX;
    endcase
end

endmodule : cmp
