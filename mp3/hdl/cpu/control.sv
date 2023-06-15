
module control
import rv32i_types::*; /* Import types defined in rv32i_types.sv */
(
    input clk,
    input rst,








    
    
    //mux signals
    output pcmux::pcmux_sel_t           pcmux_sel,
    output alumux::alumux1_sel_t        alumux1_sel,
    output alumux::alumux2_sel_t        alumux2_sel,
    output regfilemux::regfilemux_sel_t regfilemux_sel,
    output marmux::marmux_sel_t         marmux_sel,
    output cmpmux::cmpmux_sel_t         cmpmux_sel,

    //load signals
    output logic load_pc,
    output logic load_ir,
    output logic load_regfile,
    output logic load_mar,
    output logic load_mdr,
    output logic load_data_out,

    output alu_ops aluop,
    output branch_funct3_t	cmpop,

    //state parameters
    input logic mem_resp,
    input logic [1:0] mar_byte_request,
    output logic mem_read,
    output logic mem_write,
    output logic [3:0]      mem_byte_enable,

    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic       br_en,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);

/***************** USED BY RVFIMON --- ONLY MODIFY WHEN TOLD *****************/
logic trap;
logic [4:0] rs1_addr, rs2_addr;
logic [3:0] rmask, wmask;

branch_funct3_t branch_funct3;
store_funct3_t store_funct3;
load_funct3_t load_funct3;
arith_funct3_t arith_funct3;

assign arith_funct3 = arith_funct3_t'(funct3);
assign branch_funct3 = branch_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);
assign rs1_addr = rs1;
assign rs2_addr = rs2;

always_comb
begin : trap_check
    trap = '0;
    rmask = '0;
    wmask = '0;

    case (opcode)
        op_lui, op_auipc, op_imm, op_reg, op_jal, op_jalr:;

        op_br: begin
            case (branch_funct3)
                beq, bne, blt, bge, bltu, bgeu:;
                default: trap = '1;
            endcase
        end

        op_load: begin
            case (load_funct3)
                lw: rmask = 4'b1111;
                lh, lhu:
                begin
                    unique case (mar_byte_request[1])
                        1'd0: rmask = 4'b0011;
                        1'd1: rmask = 4'b1100;
                    endcase
                end
                lb, lbu:
                begin
                    unique case (mar_byte_request[1:0])
                        2'd0: rmask = 4'b0001;
                        2'd1: rmask = 4'b0010;
                        2'd2: rmask = 4'b0100;
                        2'd3: rmask = 4'b1000;
                    endcase
                end
                default: trap = '1;
            endcase


            
        end

        op_store: begin
            case (store_funct3)
                sw: wmask = 4'b1111;
                sh: 
                begin
                    unique case (mar_byte_request[1])
                        1'd0: wmask = 4'b0011;
                        1'd1: wmask = 4'b1100;
                    endcase
                end
                sb: 
                begin
                    unique case (mar_byte_request[1:0])
                        2'd0: wmask = 4'b0001;
                        2'd1: wmask = 4'b0010;
                        2'd2: wmask = 4'b0100;
                        2'd3: wmask = 4'b1000;
                    endcase
                end
                default: trap = '1;
            endcase
        end

        default: trap = '1;
    endcase
end
/*****************************************************************************/

enum int unsigned {
    /* List of states */
    FETCH1,
    FETCH2,
    FETCH3,
    DECODE,
    BR,
    AUIPC,
    CALC_ADDR,
    ST1,
    ST2,
    LD1,
    LD2,
    LUI,
    REG,
    IMM
} state, next_states;

/************************* Function Definitions *******************************/
/**
 *  You do not need to use these functions, but it can be nice to encapsulate
 *  behavior in such a way.  For example, if you use the `loadRegfile`
 *  function, then you only need to ensure that you set the load_regfile bit
 *  to 1'b1 in one place, rather than in many.
 *
 *  SystemVerilog functions must take zero "simulation time" (as opposed to 
 *  tasks).  Thus, they are generally synthesizable, and appropraite
 *  for design code.  Arguments to functions are, by default, input.  But
 *  may be passed as outputs, inouts, or by reference using the `ref` keyword.
**/

/**
 *  Rather than filling up an always_block with a whole bunch of default values,
 *  set the default values for controller output signals in this function,
 *   and then call it at the beginning of your always_comb block.
**/
function void set_defaults();
    
    load_pc	        = 	1'b0;
    load_ir	        = 	1'b0;
    load_regfile	= 	1'b0;
    load_mar	    = 	1'b0;
    load_mdr	    = 	1'b0;
    load_data_out	= 	1'b0;
    pcmux_sel	    = 	pcmux::pc_plus4;
    cmpop	        = 	branch_funct3_t'(funct3);
    alumux1_sel	    = 	alumux::rs1_out;
    alumux2_sel	    = 	alumux::i_imm;
    regfilemux_sel	= 	regfilemux::alu_out;
    marmux_sel	    = 	marmux::pc_out;
    cmpmux_sel	    = 	cmpmux::rs2_out;
    aluop	        = 	alu_ops'(funct3);
    mem_read	    = 	1'b0;
    mem_write	    = 	1'b0;
    mem_byte_enable	= 	4'b1111;
    //rs1	            = 	5'b0;
    //rs2	            = 	5'b0;

endfunction

/**
 *  Use the next several functions to set the signals needed to
 *  load various registers
**/
function void loadPC(pcmux::pcmux_sel_t sel);
    load_pc = 1'b1;
    pcmux_sel = sel;
endfunction

function void loadRegfile(regfilemux::regfilemux_sel_t sel);
endfunction

function void loadMAR(marmux::marmux_sel_t sel);
endfunction

function void loadMDR();
endfunction

function void setALU(alumux::alumux1_sel_t sel1, alumux::alumux2_sel_t sel2, logic setop, alu_ops op);
    /* Student code here */


    if (setop)
        aluop = op; // else default value
endfunction

function automatic void setCMP(cmpmux::cmpmux_sel_t sel, branch_funct3_t op);
endfunction

/*****************************************************************************/

    /* Remember to deal with rst signal */

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    
    unique case (state)
        
        FETCH1:
        begin
            load_mar = 1'b1;
        end
        FETCH2:
        begin
            load_mdr = 1'd1;
            mem_read = 1'd1;
        end

        FETCH3:
        begin
            load_ir = 1'd1;
        end

        DECODE:
        begin
            //none
        end

        BR:         //double check
        begin
            unique case (opcode)
                op_jal   :
                begin
                    load_regfile = 1'b1;
                    regfilemux_sel = regfilemux::pc_plus4;  // save pc into rd, then
                    alumux2_sel = alumux::j_imm;            // add j-immediate
                    alumux1_sel = alumux::pc_out;           // to pc
                    pcmux_sel = pcmux::alu_out;             // and put back into pc
                end
                op_jalr  :
                begin
                    load_regfile = 1'b1;
                    regfilemux_sel = regfilemux::pc_plus4;  // save pc into rd, then
                    alumux2_sel = alumux::i_imm;            // add i-immediate
                    alumux1_sel = alumux::rs1_out;          // to rs1
                    pcmux_sel = pcmux::alu_mod2;             // and put in pc, mod2
                end
                op_br    :
                begin
                    load_regfile = 1'b0;                  
                    regfilemux_sel = regfilemux::alu_out;   // dont save pc
                    alumux2_sel = alumux::b_imm;            // add b-immediate
                    alumux1_sel = alumux::pc_out;           // to pc
                    pcmux_sel = pcmux::pcmux_sel_t'({1'b0, br_en}); // if cmpop is true, then put in pc
                end
			endcase

            load_pc = 1'd1;     // always modifying pc regardless
            aluop = alu_add;    // always adding
        end

        AUIPC:
        begin
            alumux1_sel = alumux::pc_out;   //1'd1;
            alumux2_sel = alumux::u_imm;    //3'd1;
            load_regfile = 1'd1;
            load_pc = 1'd1;
            aluop = alu_add; 

        end

        CALC_ADDR:
        begin
            aluop = alu_add;
            load_mar = 1'd1;
            marmux_sel = marmux::alu_out;   //1'd1;
            if (opcode == op_store)
            begin
                load_data_out = 1'd1;
                alumux2_sel = alumux::s_imm;    //3'd3;
            end

            //, wmask;

        end

        ST1:
        begin
            mem_write = 1'd1;
            unique case (store_funct3_t'(funct3))
                sw: mem_byte_enable = 4'b1111;
                sh:
                begin
                    unique case (mar_byte_request[1])
                        1'd0: mem_byte_enable = 4'b0011;
                        1'd1: mem_byte_enable = 4'b1100;
                    endcase
                end
                sb:
                begin
                    unique case (mar_byte_request[1:0])
                        2'd0: mem_byte_enable = 4'b0001;
                        2'd1: mem_byte_enable = 4'b0010;
                        2'd2: mem_byte_enable = 4'b0100;
                        2'd3: mem_byte_enable = 4'b1000;
                    endcase
                end
            endcase
        end

        ST2:
        begin
            load_pc =1'd1;
        end

        LD1:
        begin
            load_mdr = 1'd1;
            mem_read = 1'd1;
        end
        LD2:
        begin
            unique case (load_funct3_t'(funct3))
                lb: regfilemux_sel = regfilemux::lb;
                lh: regfilemux_sel = regfilemux::lh;
                lw: regfilemux_sel = regfilemux::lw;
                lbu: regfilemux_sel = regfilemux::lbu;
                lhu: regfilemux_sel = regfilemux::lhu;
            endcase
            load_regfile = 1'd1;
            load_pc = 1'd1; //
            
        end
        LUI:
        begin
            load_regfile = 1'd1;
            load_pc = 1'd1;
            regfilemux_sel = regfilemux::u_imm;  //3'd2;

        end

        IMM:
        begin
            load_regfile = 1'd1;
            load_pc = 1'd1;

            unique case (funct3)
                3'b010:                         //SLTI
                begin
                    regfilemux_sel = regfilemux::br_en; //4'd1;
                    cmpmux_sel = cmpmux::i_imm;         //1'd1;
                    cmpop = blt;
                end
                3'b011:                         //SLTIU
                begin
                    regfilemux_sel = regfilemux::br_en; //4'd1;
                    cmpmux_sel = cmpmux::i_imm;         //1'd1;
                    cmpop = bltu;
                end
                3'b101: 
                begin
                    if (funct7 == 7'b0100000)   //SRAI
                    begin
                        aluop = alu_sra;
                    end
                end
                default:
                begin
                    aluop = alu_ops'(funct3);
                end
            endcase
        end

        REG:
        begin
            load_regfile = 1'd1;
            load_pc = 1'd1;
            alumux1_sel = alumux::rs1_out;
            alumux2_sel = alumux::rs2_out;

            unique case (arith_funct3_t'(funct3))
                add:    // add
                begin
                    aluop = alu_add;
                    cmpop = beq;
                    cmpmux_sel = cmpmux::rs2_out;
                    regfilemux_sel = regfilemux::alu_out;
                end
                sll:    // shift logical left
                begin
                    aluop = alu_sll;
                    cmpop = beq;
                    cmpmux_sel = cmpmux::rs2_out;
                    regfilemux_sel = regfilemux::alu_out;
                end
                slt:    // set less than (rd = rs1 < rs2)
                begin
                    aluop = alu_add;
                    cmpop = blt;
                    cmpmux_sel = cmpmux::rs2_out;
                    regfilemux_sel =  regfilemux::br_en;
                end
                sltu:   // set less than unsigned
                begin
                    aluop = alu_add;
                    cmpop = bltu;
                    cmpmux_sel = cmpmux::rs2_out;
                    regfilemux_sel =  regfilemux::br_en;
                end
                axor:   // arthimetic xor
                begin
                    aluop = alu_xor;
                    cmpop = beq;
                    cmpmux_sel = cmpmux::rs2_out;
                    regfilemux_sel = regfilemux::alu_out;
                end
                sr:     // shift right (check bit 30 for logical vs arithmetic)
                begin
                    if (funct7[5])
                        aluop = alu_sra;
                    else
                        aluop = alu_srl;
                    cmpop = beq;
                    cmpmux_sel = cmpmux::rs2_out;
                    regfilemux_sel = regfilemux::alu_out;
                end
                aor:    // or
                begin
                    aluop = alu_or;
                    cmpop = beq;
                    cmpmux_sel = cmpmux::rs2_out;
                    regfilemux_sel = regfilemux::alu_out;
                end
                aand:   // and
                begin
                    aluop = alu_and;
                    cmpop = beq;
                    cmpmux_sel = cmpmux::rs2_out;
                    regfilemux_sel = regfilemux::alu_out;
                end
            endcase
        end

    endcase
end

//you think

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
    
    unique case (state)
        FETCH1:
            next_states = FETCH2;
        FETCH2:
            if (mem_resp)
                next_states = FETCH3;
            else
                next_states = FETCH2;
        FETCH3:
            next_states = DECODE;
        DECODE:
            case (opcode)
					op_lui   :
                        next_states =  LUI;
                    op_auipc :
                        next_states =  AUIPC;
                    op_jal   :
                        next_states =  BR;
                    op_jalr  :
                        next_states =  BR;
                    op_br    :
                        next_states =  BR;
                    op_load  :
                        next_states =  CALC_ADDR;
                    op_store :
                        next_states =  CALC_ADDR;
                    op_imm   :
                        next_states =  IMM;
                    op_reg   :
                        next_states =  REG;  
					default : 
						next_states = FETCH1;    //???
				endcase

        BR:
            next_states = FETCH1;
        AUIPC:
            next_states = FETCH1;
        CALC_ADDR:
            if (opcode == op_load)
                next_states = LD1;
            else if (opcode == op_store)
                next_states = ST1;
        ST1:
            if (mem_resp)
                next_states = ST2;
            else
                next_states = ST1;
        ST2:
            next_states = FETCH1;
        LD1:
            if (mem_resp)
                next_states = LD2;
            else
                next_states = LD1;
        LD2:
            next_states = FETCH1;
        LUI:
            next_states = FETCH1;
        IMM:
            next_states = FETCH1;
        REG:
            next_states = FETCH1;
    endcase
end





/* Assignment of next state on clock edge */
always_ff @(posedge clk)
begin: next_state_assignment
    if (rst)
        state <= FETCH1; // double check this
    else
        state <= next_states;
end

endmodule : control
