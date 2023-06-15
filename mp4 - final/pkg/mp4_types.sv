


package mp4_types;
import rv32i_types::*;


typedef struct packed {
    logic        halt;          //
    logic        commit;        //
    //logic [63:0] order;       // handled in top.sv
    logic [31:0] inst;          // 
    logic        trap;          //  detech DEADBEEF opcode
    logic [4:0]  rs1_addr;      //
    logic [4:0]  rs2_addr;      //
    logic [31:0] rs1_rdata;     
    logic [31:0] rs2_rdata;       
    logic        load_regfile;  //
    logic [4:0]  rd_addr;       //
    logic [31:0] rd_wdata;      
    logic [31:0] pc_rdata;      //
    logic [31:0] pc_wdata;      // overwrite if branch
    logic [31:0] mem_addr;      
    logic [3:0]  mem_rmask;     
    logic [3:0]  mem_wmask;     //
    logic [31:0] mem_rdata;     
    logic [31:0] mem_wdata;     
    logic        load_pc;       // always 1?
    logic [1:0]  pcmux_sel_branch;  // overwrite if no branch
    //logic [15:0] errcode;

} rvfi_monitor_passthrough;


// IF YOU EDIT THIS STRUCT< YOU MUST CHANGE THE REGISTER BLOCK IN EX
// MEM_BYTE_ENABLE DIRECTLY REPLACES CERTAIN BITS SO IT MUST LINE UP
typedef struct packed {
    rv32i_opcode opcode;
    alu_ops aluop;
    pcmux::pcmux_sel_t pcmux_sel;
    alumux::alumux1_sel_t alumux1_sel;
    alumux::alumux2_sel_t alumux2_sel;
    regfilemux::regfilemux_sel_t regfilemux_sel;
    cmpmux::cmpmux_sel_t cmpmux_sel;
    logic load_pc;
    logic load_regfile;
    logic mem_read;
    logic mem_write;
    logic wbmux_sel;
    branch_funct3_t cmpop;
    logic [3:0] mem_byte_enable; 
    logic [1:0] rsmux1_sel;
    logic [1:0] rsmux2_sel;
    logic [2:0] funct3;
    logic [6:0] funct7;
} rv32i_control_word;
//
//



endpackage : mp4_types



/*
typedef struct packed {
    rv32i_opcode opcode;
    alu_ops aluop;
    pcmux::pcmux_sel_t pcmux_sel;
    alumux::alumux1_sel_t alumux1_sel;
    alumux::alumux2_sel_t alumux2_sel;
    regfilemux::regfilemux_sel_t regfilemux_sel;
    cmpmux::cmpmux_sel_t cmpmux_sel;
    logic load_pc;
    logic load_regfile;
    logic mem_read;
    logic mem_write;
    logic wbmux_sel;
    branch_funct3_t cmpop;
    logic [3:0] mem_byte_enable;    
} rv32i_control_word;

*/