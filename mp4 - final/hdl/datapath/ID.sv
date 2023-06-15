
module ID 
import rv32i_types::*;
import mp4_types::*;
(

    input clk,
    input rst,

    // forwarding port
    input   logic               stall,
    input   logic               flush,

    // registered inputs from IF
    input  rv32i_word           instr_IFID,
    input  rv32i_word           pc_addr_IFID,
    input  logic                taken_IFID,


    // output to control 
    output  rv32i_opcode        opcode,
    output  logic [2:0]         funct3,
    output  logic [6:0]         funct7,
    input   rv32i_control_word  ctrl,


    // port to WB
    input   rv32i_word          data_WB,

    // registered outputs to EX
    output  rv32i_word          rs1_data_IDEX,
    output  rv32i_word          rs2_data_IDEX,
    output  rv32i_word          i_imm_IDEX,
    output  rv32i_word          s_imm_IDEX,
    output  rv32i_word          b_imm_IDEX,
    output  rv32i_word          u_imm_IDEX,
    output  rv32i_word          j_imm_IDEX,
    output  logic [4:0]         rd_IDEX,
    output  rv32i_word          pc_addr_IDEX,
    output  rv32i_control_word  ctrl_IDEX,
    output  logic [2:0]         funct3_IDEX,
    output  logic               taken_IDEX,

	// Forwarding
	input	logic               load_regfile_MEMWB, 
    input   logic               b,                          // DJM why is this just called "b"?
	input	logic [4:0]			rd_EXMEM,
	input	rv32i_word			regfilemux_out_MEMWB,
    input	logic [4:0]			rd_MEMWB,
    input rv32i_control_word    ctrl_EXMEM,

    //RVFI
    output  rvfi_monitor_passthrough    rvfi_IDEX
);

// local signals
logic [4:0] rs1_idx;
logic [4:0] rs2_idx;
rv32i_word rs1_out;
rv32i_word rs2_out;
rv32i_word  instr;      assign instr = instr_IFID;
rv32i_word  pc_addr;    assign pc_addr = pc_addr_IFID;
logic [1:0] rsmux1_sel;
logic [1:0] rsmux2_sel;

rvfi_monitor_passthrough rvfi; 

// regfile
regfile regfile 
(
    .load   (~stall && b), // load_regfile_MEMWB),                      //ASDNJDTGAGBAERTAERYTBEATEARCESRG
    .in     (regfilemux_out_MEMWB),
    .src_a  (rs1_idx), 
    .src_b  (rs2_idx), 
    .dest   (rd_MEMWB),
    .reg_a  (rs1_out), 
    .reg_b  (rs2_out),
    .*
);

// instruction decode for control word fetch
always_comb begin : DECODE
    funct3  = instr[14:12];
    funct7  = instr[31:25];
    opcode  = rv32i_opcode'(instr[6:0]);
    rs1_idx = instr[19:15];                  // register file index 1
    rs2_idx = instr[24:20];                  // register file index 2
end

always_comb begin : HAZARD                                                  // looks the same as what luca and david have, but referenced to previous frames
	// RS1 
    if (rs1_idx != 0) 
    begin                                                                   // DJM this may need a conditional based on if this opcode uses the ALU or CMP
        if (ctrl_IDEX.load_regfile && (rs1_idx == rd_IDEX))                 // This also may need guarding for the STORE opcode since it does not use a destination register, but might have a value for rd!
            rsmux1_sel = 2'b01;
        else if (ctrl_EXMEM.load_regfile && (rs1_idx == rd_EXMEM))
            rsmux1_sel = 2'b10;
        else
            rsmux1_sel = 2'b00;
    end
    else 
        rsmux1_sel = 2'b00;

	// RS2
    if (rs2_idx != 0) 
    begin
        if (ctrl_IDEX.load_regfile && (rs2_idx == rd_IDEX))
            rsmux2_sel = 2'b01;
        else if (ctrl_EXMEM.load_regfile && (rs2_idx == rd_EXMEM))
            rsmux2_sel = 2'b10;
        else
            rsmux2_sel = 2'b00;
    end
    else 
        rsmux2_sel = 2'b00;
end


always_comb begin : RVFI
    rvfi.inst       = instr;
    rvfi.rs1_addr   = rs1_idx;
    rvfi.rs2_addr   = rs2_idx;
    rvfi.load_regfile   = ctrl.load_regfile;
    rvfi.rd_addr    =  ((opcode == op_br)||(opcode == op_store)) ? 5'b00000 : instr[11:7];      //RVFI requires rd_addr be zero when instruction does not use rd
    
    rvfi.pc_rdata = pc_addr_IFID;

    rvfi.pc_wdata = pc_addr_IFID + 4;                   //default, overwrite if branch
    rvfi.pcmux_sel_branch = ctrl.pcmux_sel;             //default, overwrite if no branch

    rvfi.load_pc = 1'b1;                                //always 1?
    rvfi.trap = (ctrl == 47'h1DEADBEEF ? 1'b1 : 1'b0);  // detect illegal opcode
    rvfi.commit = (pc_addr_IFID == 32'h00000000 ? 1'b0 : 1'b1 );    //detect stall / flush

end


// registered outputs for ID/EX
always_ff @(posedge clk) begin : REGISTERS

    if (rst || flush)
    begin
        rs1_data_IDEX    <= 32'h00000000;
        rs2_data_IDEX    <= 32'h00000000;
        i_imm_IDEX       <= 32'h00000000;
        s_imm_IDEX       <= 32'h00000000;
        b_imm_IDEX       <= 32'h00000000;
        u_imm_IDEX       <= 32'h00000000;
        j_imm_IDEX       <= 32'h00000000;
        rd_IDEX          <= 5'h0;
        pc_addr_IDEX     <= 32'h00000000;
        ctrl_IDEX        <= '0;
        funct3_IDEX      <= 3'h0;

        rvfi_IDEX        <= '0;
        taken_IDEX       <= 1'b0;
    end
    else
    begin
        if (~stall)
        begin
            rs1_data_IDEX    <= rs1_out;   
            rs2_data_IDEX    <= rs2_out;        

            i_imm_IDEX       <= {{21{instr[31]}}, instr[30:20]};
            s_imm_IDEX       <= {{21{instr[31]}}, instr[30:25], instr[11:7]};
            b_imm_IDEX       <= {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            u_imm_IDEX       <= {instr[31:12], 12'h000};
            j_imm_IDEX       <= {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            rd_IDEX          <= instr[11:7];
            pc_addr_IDEX     <= pc_addr;        //pass along
            funct3_IDEX      <= funct3;
            taken_IDEX       <= taken_IFID;

            rvfi_IDEX        <= rvfi;

            ctrl_IDEX.opcode           <=   ctrl.opcode;
            ctrl_IDEX.aluop            <=   ctrl.aluop;
            ctrl_IDEX.pcmux_sel        <=   ctrl.pcmux_sel;
            ctrl_IDEX.alumux1_sel      <=   ctrl.alumux1_sel;
            ctrl_IDEX.alumux2_sel      <=   ctrl.alumux2_sel;
            ctrl_IDEX.regfilemux_sel   <=   ctrl.regfilemux_sel;
            ctrl_IDEX.cmpmux_sel       <=   ctrl.cmpmux_sel;
            ctrl_IDEX.load_pc          <=   ctrl.load_pc;
            ctrl_IDEX.load_regfile     <=   (instr[11:7] == 0 ? 1'b0 : ctrl.load_regfile );   //rd == 0?
            ctrl_IDEX.mem_read         <=   ctrl.mem_read;
            ctrl_IDEX.mem_write        <=   ctrl.mem_write;
            ctrl_IDEX.wbmux_sel        <=   ctrl.wbmux_sel;
            ctrl_IDEX.cmpop            <=   ctrl.cmpop;
            ctrl_IDEX.mem_byte_enable  <=   ctrl.mem_byte_enable;  
            ctrl_IDEX.rsmux1_sel	   <=   rsmux1_sel;  
            ctrl_IDEX.rsmux2_sel	   <=   rsmux2_sel;  

            ctrl_IDEX.funct3 <= ctrl.funct3;
            ctrl_IDEX.funct7 <= ctrl.funct7;
        end
    end
end

endmodule
