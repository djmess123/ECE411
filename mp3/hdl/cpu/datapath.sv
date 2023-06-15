`define BAD_MUX_SEL $display("Illegal mux select")


module datapath
import rv32i_types::*;
(
    input                   clk,
    input                   rst,
    
    //memory
    //input                   mem_resp,
    input rv32i_word        mem_rdata,
    //output logic            mem_read,
    //output logic            mem_write,
    //output logic [3:0]      mem_byte_enable,
    output rv32i_word       mem_address,    // 4 byte aligned
    output rv32i_word       mem_wdata,      // signal used by RVFI Monitor
    output logic [1:0]      mar_byte_request, // 1 byte aligned

    //muxes signals
    input pcmux::pcmux_sel_t            pcmux_sel,
    input alumux::alumux1_sel_t         alumux1_sel,
    input alumux::alumux2_sel_t         alumux2_sel,
    input regfilemux::regfilemux_sel_t  regfilemux_sel,
    input marmux::marmux_sel_t          marmux_sel,
    input cmpmux::cmpmux_sel_t          cmpmux_sel,

    //loads signals
    input logic	load_pc,
    input logic	load_ir,
    input logic	load_regfile,
    input logic	load_mar,
    input logic load_mdr,
    input logic	load_data_out,

    input alu_ops aluop,
    input branch_funct3_t	cmpop,

    //state parameters for controller
    output rv32i_opcode opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic       br_en,
    output logic [4:0] rs1,
    output logic [4:0] rs2
    
    

);

/******************* Signals Needed for RVFI Monitor *************************/
rv32i_word pcmux_out;
rv32i_word mdrreg_out;

/*************************** Interconnections ********************************/

//mux outputs
rv32i_word	alumux1_out;
rv32i_word	alumux2_out;
rv32i_word	regfilemux_out;
rv32i_word	marmux_out;
rv32i_word	cmp_mux_out;



//component outputs
rv32i_word	alu_out;

rv32i_word	pc_out;
rv32i_word	pc_plus4_out;


rv32i_reg	rd;

rv32i_word	rs1_out;
rv32i_word	rs2_out;

rv32i_word	i_imm;
rv32i_word	u_imm;
rv32i_word	b_imm;
rv32i_word	s_imm;
rv32i_word  j_imm;


/***************************** Registers *************************************/
// Keep Instruction register named `IR` for RVFI Monitor
ir IR
(
    .load   (load_ir),
    .in     (mdrreg_out),
    .*                      
);

register MDR
(
    .load   (load_mdr),
    .in     (mem_rdata),
    .out    (mdrreg_out),
    .*
);

regfile regfile 
(
    .load   (load_regfile),
    .in     (regfilemux_out),
    .src_a  (rs1), 
    .src_b  (rs2), 
    .dest   (rd),
    .reg_a  (rs1_out), 
    .reg_b  (rs2_out),
    .*
);

pc_register PC
(
    .load   (load_pc),
    .in     (pcmux_out),
    .out    (pc_out),
    .*
);

register DATAOUT
(
    .load   (load_data_out),
    .in     (rs2_out),
    .out    (mem_wdata),
    .*
);

register MAR
(
    .load   (load_mar),
    .in     (marmux_out),
    .out    ({mem_address[31:2], mar_byte_request}),
    .*
);
assign mem_address[1:0] = 2'b00; //force 4 byte aligned memory access

/******************************* ALU and CMP *********************************/
alu ALU
(
    .aluop  (aluop),
    .a      (alumux1_out), 
    .b      (alumux2_out),
    .f      (alu_out)
);

cmp CMP
(
   .a       (rs1_out), 
   .b       (cmp_mux_out),
   .f       (br_en),
   .*
);


/******************************** Muxes **************************************/
assign pc_plus4_out = pc_out + 4;

always_comb begin : MUXES
    // We provide one (incomplete) example of a mux instantiated using
    // a case statement.  Using enumerated types rather than bit vectors
    // provides compile time type safety.  Defensive programming is extremely
    // useful in SystemVerilog. 
    unique case (pcmux_sel)
        pcmux::pc_plus4:        pcmux_out = pc_plus4_out; //pc_out + 4;
        pcmux::alu_out:         pcmux_out = alu_out;
        pcmux::alu_mod2:        pcmux_out = {alu_out[31:1], 1'b0};
        default: `BAD_MUX_SEL;
    endcase

    unique case (alumux1_sel)
        alumux::rs1_out:        alumux1_out = rs1_out;
        alumux::pc_out:         alumux1_out = pc_out;
        default: `BAD_MUX_SEL;
    endcase

    unique case (alumux2_sel)
        alumux::i_imm:          alumux2_out = i_imm;
        alumux::u_imm:          alumux2_out = u_imm;
        alumux::b_imm:          alumux2_out = b_imm;
        alumux::s_imm:          alumux2_out = s_imm;
        alumux::j_imm:          alumux2_out = j_imm;
        alumux::rs2_out:        alumux2_out = rs2_out;
        default: `BAD_MUX_SEL;
    endcase

    unique case (regfilemux_sel)
        regfilemux::alu_out:    regfilemux_out = alu_out; 
        regfilemux::br_en:      regfilemux_out = {31'h0, br_en};    //zext
        regfilemux::u_imm:      regfilemux_out = u_imm;   
        regfilemux::pc_plus4:   regfilemux_out = pc_plus4_out;

        regfilemux::lw:         regfilemux_out = mdrreg_out;        //full 32 bits

        regfilemux::lh: begin
            unique case (mar_byte_request[1])
                1'd0: regfilemux_out = mdrreg_out[15] ? {16'hFFFF, mdrreg_out[15:0]} :    {16'h0, mdrreg_out[15:0]};    //half sext
                1'd1: regfilemux_out = mdrreg_out[31] ? {16'hFFFF, mdrreg_out[31:16]} :    {16'h0, mdrreg_out[31:16]};    //half sext
            endcase
        end
        regfilemux::lhu: begin
            unique case (mar_byte_request[1])
                1'd0: regfilemux_out = {16'h0, mdrreg_out[15:0]};    //half zext
                1'd1: regfilemux_out = {16'h0, mdrreg_out[31:16]};    //half zext
            endcase
        end     

        regfilemux::lb: begin
            unique case (mar_byte_request)
                2'b00: regfilemux_out = mdrreg_out[7]   ? {24'hFFFFFF,  mdrreg_out[7:0]}   : {24'h0, mdrreg_out[7:0] };    //byte sext
                2'b01: regfilemux_out = mdrreg_out[15]  ? {24'hFFFFFF,  mdrreg_out[15:8]}  : {24'h0, mdrreg_out[15:8] };    //byte sext
                2'b10: regfilemux_out = mdrreg_out[23]  ? {24'hFFFFFF,  mdrreg_out[23:16]} : {24'h0, mdrreg_out[23:16] };    //byte sext
                2'b11: regfilemux_out = mdrreg_out[31]  ? {24'hFFFFFF,  mdrreg_out[31:24]} : {24'h0, mdrreg_out[31:24] };    //byte sext
            endcase
        end
        regfilemux::lbu:begin
            unique case (mar_byte_request)
                2'b00: regfilemux_out = {24'h0, mdrreg_out[7:0] };      //byte zext 
                2'b01: regfilemux_out = {24'h0, mdrreg_out[15:8] };     //byte zext 
                2'b10: regfilemux_out = {24'h0, mdrreg_out[23:16] };    //byte zext 
                2'b11: regfilemux_out = {24'h0, mdrreg_out[31:24] };    //byte zext 
            endcase
        end
           
        default: `BAD_MUX_SEL;
    endcase

    unique case (marmux_sel)
        marmux::pc_out:         marmux_out = pc_out;
        marmux::alu_out:        marmux_out = alu_out;
        default: `BAD_MUX_SEL;
    endcase

    unique case (cmpmux_sel)
        cmpmux::rs2_out:        cmp_mux_out = rs2_out;
        cmpmux::i_imm:          cmp_mux_out = i_imm;
        default: `BAD_MUX_SEL;
    endcase
end




endmodule : datapath
