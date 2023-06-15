import rv32i_types::*;
import mp4_types::*;

module control_rom
(
    //input clk,
    //input rst,
    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output rv32i_control_word ctrl
);




function void set_defaults();
    ctrl.opcode             =     opcode;
    ctrl.load_regfile       =     1'b0;
    ctrl.pcmux_sel    	    =     pcmux::pc_plus4;
    ctrl.cmpop        	    =     branch_funct3_t'(funct3);;
    ctrl.alumux1_sel    	=     alumux::rs1_out;
    ctrl.alumux2_sel    	=     alumux::i_imm;
    ctrl.cmpmux_sel    	    =     cmpmux::rs2_out;
    ctrl.aluop        	    =     alu_ops'(funct3);
    ctrl.mem_read    	    =     0;
    ctrl.mem_write      	=     0;
    ctrl.mem_byte_enable    =     4'h0;
    ctrl.regfilemux_sel     =     regfilemux::alu_out;

    ctrl.funct3 = funct3;
    ctrl.funct7 = funct7;

endfunction

always_comb
begin
    set_defaults();
    case(opcode)
        op_load : begin
            unique case (load_funct3_t'(funct3))
                lb: ctrl.regfilemux_sel = regfilemux::lb;
                lh: ctrl.regfilemux_sel = regfilemux::lh;
                lw: ctrl.regfilemux_sel = regfilemux::lw;
                lbu: ctrl.regfilemux_sel = regfilemux::lbu;
                lhu: ctrl.regfilemux_sel = regfilemux::lhu;
            endcase
            ctrl.aluop = alu_add;
            ctrl.mem_read = 1'b1;
            ctrl.mem_write = 1'b0;
            ctrl.load_regfile = 1'b1;
        end
        op_store : begin
            ctrl.aluop = alu_add;
            ctrl.alumux2_sel = alumux::s_imm;
            ctrl.mem_read = 1'b0;
            ctrl.mem_write = 1'b1;
        end
        op_auipc:
        begin
            ctrl.aluop=alu_add;
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = alumux::u_imm;
            ctrl.load_regfile = 1'b1;
        end
        op_jal:
        begin
            ctrl.aluop=alu_add;
            ctrl.regfilemux_sel=regfilemux::pc_plus4;
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = alumux::j_imm;
            ctrl.pcmux_sel=pcmux::alu_out;
            ctrl.load_regfile = 1'b1;
        end
        op_lui:
        begin
            ctrl.regfilemux_sel=regfilemux::u_imm;
            ctrl.mem_read=1'b1;
            ctrl.mem_write=1'b0;
            ctrl.load_regfile=1'b1;
        end
        op_jalr:
        begin
            ctrl.aluop=alu_add;
            ctrl.regfilemux_sel=regfilemux::pc_plus4;
            ctrl.alumux1_sel = alumux::rs1_out;
            ctrl.alumux2_sel = alumux::i_imm;
            ctrl.pcmux_sel=pcmux::alu_mod2;
            ctrl.load_regfile=1'b1;
        end
        op_br:
        begin
            ctrl.aluop=alu_add;
            ctrl.regfilemux_sel=regfilemux::alu_out;
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = alumux::b_imm;
            ctrl.pcmux_sel=pcmux::alu_out;
            ctrl.load_regfile=1'b0;
        end
        op_imm:
        begin
            ctrl.load_regfile=1'b1;
            unique case (funct3)
                    2:  //SLTI
                    begin
                        ctrl.cmpop=blt;
                        ctrl.regfilemux_sel=regfilemux::br_en;
                        ctrl.cmpmux_sel=cmpmux::i_imm;
                    end
                    3 : //SLTIU
                    begin
                        ctrl.cmpop=bltu;
                        ctrl.regfilemux_sel=regfilemux::br_en;
                        ctrl.cmpmux_sel=cmpmux::i_imm;
                    end
                    5: //SRAI / SRLI
                    begin
                        ctrl.load_regfile=1'b1;
                        if (funct7 == 7'b0100000)
                            ctrl.aluop=alu_sra;
                        else
                            ctrl.aluop=alu_srl;
                    end
                    default:
                    begin
                        ctrl.aluop = alu_ops'(funct3);
                    end
            endcase
        end
        op_reg: begin
            unique case (arith_funct3_t'(funct3))
                    add: //ADD
                    begin
                        if(funct7[5])
                            ctrl.aluop=alu_sub;
                        else
                            ctrl.aluop=alu_add;
                        ctrl.cmpop=beq;
                        ctrl.load_regfile=1'b1;
                        ctrl.alumux1_sel=alumux::rs1_out;
                        ctrl.alumux2_sel=alumux::rs2_out;
                        ctrl.cmpmux_sel=cmpmux::rs2_out;
                        ctrl.regfilemux_sel=regfilemux::alu_out;
                    end
                    slt:  //SLT
                    begin
                        ctrl.load_regfile=1'b1;
                        if(funct7!=1) begin
                            ctrl.regfilemux_sel=regfilemux::br_en;
                            ctrl.cmpop=blt;
                        end else begin
                            ctrl.regfilemux_sel=regfilemux::alu_out;
                            ctrl.cmpop=beq;
                        end
                        ctrl.aluop=alu_add;
                        ctrl.cmpmux_sel=cmpmux::rs2_out;
                        ctrl.alumux1_sel=alumux::rs1_out;
                        ctrl.alumux2_sel=alumux::rs2_out;
                    end
                    sltu: //SLTU
                    begin
                        ctrl.load_regfile=1'b1;
                        if(funct7!=1)
                        begin
                            ctrl.regfilemux_sel=regfilemux::br_en;
                            ctrl.cmpop=bltu;
                        end else begin
                            ctrl.regfilemux_sel=regfilemux::alu_out;
                            ctrl.cmpop=beq;
                        end
                        ctrl.aluop=alu_add;
                        ctrl.cmpmux_sel=cmpmux::rs2_out;
                        ctrl.alumux1_sel=alumux::rs1_out;
                        ctrl.alumux2_sel=alumux::rs2_out;
                    end
                    sr:
                    begin
                        ctrl.load_regfile=1'b1;
                        if(funct7[5])
                            ctrl.aluop=alu_sra;
                        else
                            ctrl.aluop=alu_srl;
                        ctrl.cmpop=beq;
                        ctrl.cmpmux_sel=cmpmux::rs2_out;
                        ctrl.regfilemux_sel=regfilemux::alu_out;
                        ctrl.alumux1_sel=alumux::rs1_out;
                        ctrl.alumux2_sel=alumux::rs2_out;
                    end
                    default:    //sll, axor, aor, aand
                    begin
                        ctrl.load_regfile=1'b1;
                        ctrl.aluop= alu_ops'(funct3);
                        ctrl.alumux1_sel=alumux::rs1_out;
                        ctrl.alumux2_sel=alumux::rs2_out;
                        ctrl.cmpmux_sel=cmpmux::rs2_out;
                        ctrl.regfilemux_sel=regfilemux::alu_out;
                    end
                endcase
        end
    default:
    begin
        ctrl = 47'h1DEADBEEF;
    end
    endcase
    
end

endmodule : control_rom
