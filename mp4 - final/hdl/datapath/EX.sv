`define BAD_MUX_SEL1 $display("Illegal mux select EX")




module EX 
import rv32i_types::*;
import mp4_types::*;
(

    input clk,
    input rst,

    // forwarding port
    input   logic                   stall,
    input   logic                   flush,                  // DJM make this an output?

    // registered inputs from ID
    input   rv32i_word              rs1_data_IDEX,
    input   rv32i_word              rs2_data_IDEX,
    input   rv32i_word              i_imm_IDEX,
    input   rv32i_word              s_imm_IDEX,
    input   rv32i_word              b_imm_IDEX,
    input   rv32i_word              u_imm_IDEX,
    input   rv32i_word              j_imm_IDEX,
    input   logic [4:0]             rd_IDEX,
    input   rv32i_word              pc_addr_IDEX,
    input   logic [2:0]             funct3_IDEX,

    // control word
    input   rv32i_control_word      ctrl_IDEX,

    // port to IF for branches
    //output  pcmux::pcmux_sel_t      pcmux_sel_branch,
    output  rv32i_word              branch_addr_EX,
    output  logic                   br_en,
    output  logic                   jmp_en,

    // registered outputs to MEM
    output  rv32i_word              alu_out_EXMEM,
    output  logic                   br_en_EXMEM,
    output  logic                   jmp_en_EXMEM,
    output  logic [4:0]             rd_EXMEM,
    output  rv32i_word              rs2_data_EXMEM,
    output  rv32i_control_word      ctrl_EXMEM,
    output  rv32i_word              u_imm_EXMEM,
    output  rv32i_word              pc_addr_EXMEM,
    output  logic [2:0]             funct3_EXMEM,
    output  logic                   Mul_stall,
    //RVFI
    input   rvfi_monitor_passthrough    rvfi_IDEX,
    output  rvfi_monitor_passthrough    rvfi_EXMEM,

	// Forwarding
	input	rv32i_word			regfilemux_out,             // DJM  mem?
	input	rv32i_word			regfilemux_out_MEMWB,       //      wb?

    output logic a                                          // WHY "a" ????????
);

// local signals
rv32i_word  rs1_data;       assign rs1_data = rs1_data_IDEX;
rv32i_word  rs2_data;       assign rs2_data = rs2_data_IDEX;
rv32i_word  i_imm;          assign i_imm    = i_imm_IDEX;
rv32i_word  s_imm;          assign s_imm    = s_imm_IDEX;
rv32i_word  b_imm;          assign b_imm    = b_imm_IDEX;
rv32i_word  u_imm;          assign u_imm    = u_imm_IDEX;
rv32i_word  j_imm;          assign j_imm    = j_imm_IDEX;
logic [4:0] rd;             assign rd       = rd_IDEX;
rv32i_word  pc_addr;        assign pc_addr  = pc_addr_IDEX;
rv32i_word  rs1_forward;
rv32i_word  rs2_forward;
logic muldiv_done_o_prev;    
logic mul_stall_prev;    


rv32i_word	cmp_mux_out;
rv32i_word	alumux1_out;
rv32i_word	alumux2_out;
logic       br_en;
logic       jmp_en;
logic mult_ready_o;
logic muldiv_done_o;
logic[63:0] muldiv_result;

rv32i_word alu_out;
//logic [3:0] mem_byte_enable;
logic start_i;
rv32i_control_word ctrl;    assign ctrl     = ctrl_IDEX;
rvfi_monitor_passthrough rvfi;  assign rvfi = rvfi_IDEX;

//rv32i_word alu_out_raw;
// alu
alu ALU
(
    .aluop  (ctrl.aluop),
    .a      (alumux1_out), 
    .b      (alumux2_out),
    .f      (alu_out)
);

mulDiv mulDiv
(
    .clk_i(clk),
    .reset_n_i(~rst),
    .multiplicand_i(alumux1_out),
    .multiplier_i(alumux2_out),
    .funct(ctrl.funct3),
    .start_i(start_i),
    .ready_o(mult_ready_o),
    .done_o(muldiv_done_o),
    .result_o(muldiv_result)
);

/*
always_comb begin : SLTIU
    alu_out = alu_out_raw;
    if (ctrl.opcode == op_imm)
    begin
        if((ctrl.funct3 == 2) || (ctrl.funct3 == 3))
            alu_out = br_en;
    end
end
*/

// cmp
cmp CMP
(
    .cmpop  (ctrl.cmpop),
    .a      (rs1_forward), 
    .b      (cmp_mux_out),
    .f      (br_en)
);



always_comb begin : JMP
    jmp_en = 1'b0;
    if ((ctrl.opcode == op_jal) || (ctrl.opcode == op_jalr))
    begin
        jmp_en = 1'b1;
    end
end

always_ff @(posedge clk) begin 
    muldiv_done_o_prev<=muldiv_done_o;
    if ((ctrl_IDEX.opcode==op_reg&&ctrl_IDEX.funct7==1) && ~mul_stall_prev)
    begin
        start_i <= 1;
    end
    else
        start_i <= 0;
end

assign Mul_stall = (ctrl_IDEX.opcode==op_reg&&ctrl_IDEX.funct7==1) && ~ (~muldiv_done_o_prev&&muldiv_done_o);

always_ff @(posedge clk ) begin
    mul_stall_prev <= Mul_stall;
    // if(rst)
    //     Mul_stall<=1'b0;
    // if ((ctrl_IDEX.opcode==op_reg&&ctrl_IDEX.funct7==1))
    //     Mul_stall<=1'b1;
    // else if(~muldiv_done_o_prev&&muldiv_done_o)
    //     Mul_stall<=0;
end

always_comb begin : MUXES

    //-----------------------------------------
    if (ctrl.rsmux1_sel == 2'b00)
        rs1_forward = rs1_data;
    else if (ctrl.rsmux1_sel == 2'b01)
        rs1_forward = regfilemux_out;
    else // if (ctrl.rsmux1_sel == 2'b10)
        rs1_forward = regfilemux_out_MEMWB;


    // -----------------------------------------------
    if (ctrl.rsmux2_sel == 2'b00)
        rs2_forward = rs2_data;
    else if (ctrl.rsmux2_sel == 2'b01)
        rs2_forward = regfilemux_out;
    else // if (ctrl.rsmux2_sel == 2'b10)
        rs2_forward = regfilemux_out_MEMWB;

    unique case (ctrl.alumux1_sel)
        alumux::rs1_out:        alumux1_out = rs1_forward;
        alumux::pc_out:         alumux1_out = pc_addr;
        default: `BAD_MUX_SEL1;
    endcase

    unique case (ctrl.alumux2_sel)
        alumux::i_imm:          alumux2_out = i_imm;
        alumux::u_imm:          alumux2_out = u_imm;
        alumux::b_imm:          alumux2_out = b_imm;
        alumux::s_imm:          alumux2_out = s_imm;
        alumux::j_imm:          alumux2_out = j_imm;
        alumux::rs2_out:        alumux2_out = rs2_forward;
        default: `BAD_MUX_SEL1;
    endcase

    unique case (ctrl.cmpmux_sel)
        cmpmux::rs2_out:        cmp_mux_out = rs2_forward;
        cmpmux::i_imm:          cmp_mux_out = i_imm;
        default: `BAD_MUX_SEL1;
    endcase

    unique case (ctrl.pcmux_sel)                                      //DJM This was flush?? what??
        //pcmux::pc_plus4:        pcmux_out = pc_out + 4;
        pcmux::alu_out:         branch_addr_EX = alu_out;
        pcmux::alu_mod2:        branch_addr_EX = {alu_out[31:1], 1'b0};

        default:                branch_addr_EX = alu_out;
    endcase
end

always_ff @(posedge clk) begin : REGISTERS
    if (rst)
    begin
        alu_out_EXMEM   <= 32'h00000000;
        br_en_EXMEM     <= 1'b0;
        jmp_en_EXMEM    <= 1'b0;
        rd_EXMEM        <= 5'h0;
        rs2_data_EXMEM  <= 32'h00000000;
        ctrl_EXMEM      <= '0;
        u_imm_EXMEM     <= 32'h00000000;
        pc_addr_EXMEM   <= 32'h00000000;
        rvfi_EXMEM      <= '0;

    end
    else
    begin
        if (~stall||flush)
        begin
            if(ctrl_IDEX.opcode==op_reg&&ctrl_IDEX.funct7==1)
                case(ctrl.funct3)
                    0: alu_out_EXMEM <=rv32i_word'(muldiv_result[31:0]);
                    1: alu_out_EXMEM <=rv32i_word'(muldiv_result[63:32]);
                    2: alu_out_EXMEM <=rv32i_word'(muldiv_result[63:32]);
                    3: alu_out_EXMEM <=rv32i_word'(muldiv_result[63:32]);
                    4: alu_out_EXMEM <=rv32i_word'(muldiv_result[31:0]);
                    5: alu_out_EXMEM <=rv32i_word'(muldiv_result[31:0]);
                    6: alu_out_EXMEM <=rv32i_word'(muldiv_result[31:0]);
                    7: alu_out_EXMEM <=rv32i_word'(muldiv_result[31:0]);
                endcase
            else
                alu_out_EXMEM   <= alu_out;
            br_en_EXMEM     <= br_en;                           //DJM  we know if we should branch already, why are we passing onto another stage, we can flush right now!
            jmp_en_EXMEM    <= jmp_en;
            rd_EXMEM        <= rd_IDEX;
            // rs2_data_EXMEM  <= rs2_data_IDEX;
            rs2_data_EXMEM  <= rs2_forward;
            funct3_EXMEM    <= funct3_IDEX;

            if (ctrl.opcode == op_store)
            begin
                ctrl_EXMEM.opcode           <=   ctrl.opcode;
                ctrl_EXMEM.aluop            <=   ctrl.aluop;
                ctrl_EXMEM.pcmux_sel        <=   ctrl.pcmux_sel;
                ctrl_EXMEM.alumux1_sel      <=   ctrl.alumux1_sel;
                ctrl_EXMEM.alumux2_sel      <=   ctrl.alumux2_sel;
                ctrl_EXMEM.regfilemux_sel   <=   ctrl.regfilemux_sel;
                ctrl_EXMEM.cmpmux_sel       <=   ctrl.cmpmux_sel;
                ctrl_EXMEM.load_pc          <=   ctrl.load_pc;
                ctrl_EXMEM.load_regfile     <=   ctrl.load_regfile;
                ctrl_EXMEM.mem_read         <=   ctrl.mem_read;
                ctrl_EXMEM.mem_write        <=   ctrl.mem_write;
                ctrl_EXMEM.wbmux_sel        <=   ctrl.wbmux_sel;
                ctrl_EXMEM.cmpop            <=   ctrl.cmpop; 
                ctrl_EXMEM.mem_byte_enable  <=   ctrl.mem_byte_enable;                //unused in irene's implementation

                ctrl_EXMEM.funct3 <= ctrl.funct3;
                ctrl_EXMEM.funct7 <= ctrl.funct7;
            end
            else
                ctrl_EXMEM      <= ctrl;
            

            a <= ctrl.load_regfile;                                 // DJM why "a" again! just call it what it is
            u_imm_EXMEM     <= u_imm_IDEX;
            pc_addr_EXMEM   <= pc_addr_IDEX;



            // this is written like this so we can insert new values into halt, pc_wdata, and mem_wmask while passing everything else along nicely

            rvfi_EXMEM.halt                 <= (((ctrl.opcode == op_br)|| (ctrl.opcode == op_jal) ) && (alu_out == pc_addr_IDEX) && (br_en || jmp_en));
            rvfi_EXMEM.commit               <= rvfi.commit           ;
            //rvfi_EXMEM.order              <  = rvfi.order            ;
            rvfi_EXMEM.inst                 <= rvfi.inst             ;
            rvfi_EXMEM.trap                 <= rvfi.trap             ;
            rvfi_EXMEM.rs1_addr             <= rvfi.rs1_addr         ;
            rvfi_EXMEM.rs2_addr             <= rvfi.rs2_addr         ;
            rvfi_EXMEM.rs1_rdata            <= rvfi.rs1_rdata        ;
            rvfi_EXMEM.rs2_rdata            <= rvfi.rs2_rdata        ;
            rvfi_EXMEM.load_regfile         <= rvfi.load_regfile     ;
            rvfi_EXMEM.rd_addr              <= rvfi.rd_addr          ;
            rvfi_EXMEM.rd_wdata             <= rvfi.rd_wdata         ;
            rvfi_EXMEM.pc_rdata             <= rvfi.pc_rdata         ;
            rvfi_EXMEM.pc_wdata             <= ( jmp_en || (br_en && (ctrl.opcode == op_br)))? alu_out  : rvfi.pc_wdata   ;       // DJM changed to match irene
            rvfi_EXMEM.mem_addr             <= rvfi.mem_addr         ;
            rvfi_EXMEM.mem_rmask            <= rvfi.mem_rmask        ;
            rvfi_EXMEM.mem_wmask            <= rvfi.mem_rmask        ;               //DJM    matching irene diff
            rvfi_EXMEM.mem_rdata            <= rvfi.mem_rdata        ;
            rvfi_EXMEM.mem_wdata            <= rvfi.mem_wdata        ;
            rvfi_EXMEM.load_pc              <= rvfi.load_pc          ;
            rvfi_EXMEM.pcmux_sel_branch     <= rvfi.pcmux_sel_branch ;
        end
    end
end


endmodule
