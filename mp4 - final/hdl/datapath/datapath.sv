

module datapath
import rv32i_types::*;
import mp4_types::*;
(
    input                       clk,
    input                       rst,
  
    // port to i-cache
    input 					    instr_mem_resp,
    input rv32i_word 	        instr_mem_rdata,
    output logic 			    instr_read,
    output logic [31:0]         instr_mem_address,

    // port to d-cache  
    input 					    data_mem_resp,
    input rv32i_word 	        data_mem_rdata, 
    output logic [3:0] 	        data_mbe,
    output logic                data_read,
    output logic                data_write,
    output logic [31:0]         data_mem_address,
    output logic [31:0]         data_mem_wdata,

    // port to control
    output  rv32i_opcode        opcode,
    output  logic [2:0]         funct3,
    output  logic [6:0]         funct7,
    input   rv32i_control_word  ctrl
);

// IFID
rv32i_word          instr_IFID;
rv32i_word          pc_addr_IFID;

// IDEX
rv32i_word          rs1_data_IDEX;
rv32i_word          rs2_data_IDEX;
rv32i_word          i_imm_IDEX;
rv32i_word          s_imm_IDEX;
rv32i_word          b_imm_IDEX;
rv32i_word          u_imm_IDEX;
rv32i_word          j_imm_IDEX;
logic [4:0]         rd_IDEX;
rv32i_word          pc_addr_IDEX;
rv32i_control_word  ctrl_IDEX;
logic [2:0]         funct3_IDEX;
logic                 Mul_stall;
//EXMEM
rv32i_word              alu_out_EXMEM;
logic                   br_en_EXMEM;
logic                   jmp_en_EXMEM;
logic [4:0]             rd_EXMEM;
rv32i_word              rs2_data_EXMEM;
rv32i_control_word      ctrl_EXMEM;

rv32i_word              u_imm_EXMEM;
rv32i_word              pc_addr_EXMEM;
logic [2:0]             funct3_EXMEM;

//MEMWB
rv32i_word              alu_out_MEMWB;
rv32i_word              mem_out_MEMWB;
logic [4:0]             rd_MEMWB;
rv32i_control_word      ctrl_MEMWB;

logic                   br_en_MEMWB;
rv32i_word              u_imm_MEMWB;
rv32i_word              pc_addr_MEMWB;

// RVFI
rvfi_monitor_passthrough rvfi_IDEX;
rvfi_monitor_passthrough rvfi_EXMEM;
rvfi_monitor_passthrough rvfi_MEMWB;


// Branch MEM --> IF
//pcmux::pcmux_sel_t  pcmux_sel_branch;
//rv32i_word          alu_out_branch;
logic               br_en;
logic               jmp_en;



//Branch Predictor
rv32i_word  addr_pred;
logic       taken_pred;
logic       w_br_op;        assign w_br_op = (ctrl_IDEX.opcode == op_br ) || (ctrl_IDEX.opcode == op_jal ); //NOT JALR!!!
logic       taken_IFID;
logic       taken_IDEX;
logic       successful_pred;
rv32i_word  branch_addr_EX;
logic       taken_corrected;

always_comb begin : BR_PRED

//check that branch was correct
if (ctrl_IDEX.opcode == op_jalr)        //jalr is always incorrect (nt) because i dont have time to add checks to address
    begin
    successful_pred = 1'b0;             //always flush on jalr cause you always take it
    taken_corrected = 1'b1;             //always take branch address
    end
else
    begin
    successful_pred = ( taken_IDEX == ((br_en || jmp_en) && 
                                       (    (ctrl_IDEX.opcode == op_br )   || 
                                            (ctrl_IDEX.opcode == op_jal )     )   ));
    taken_corrected = taken_IDEX ^ ~successful_pred; //mispredict, need to take branch
    end

end




// Register Write WB --> ID
logic                   regfile_MEMWB;
logic                   regfile_WB;
logic [4:0]             rd_WB;
rv32i_word              data_WB;

// Stalling logic
logic               stall;
assign stall =      ((data_read || data_write) && (~data_mem_resp)) || ((instr_read) && (~instr_mem_resp)||(Mul_stall));         //DJM instr stalls shouldnt stall everything, just stall IF

// Flushing logic
logic               flush;
logic               flush_req;
assign flush_req =  ~successful_pred;                                          //DJM might need extra protection from accidental flushing

assign flush = flush_req && ~stall;




// Forwarding + Hazards
rv32i_word          regfilemux_out;                                                                                 //DJM forwarding looks sparse, may need more
rv32i_word          regfilemux_out_MEMWB;
logic               load_regfile_MEMWB;
logic a, b;

// Modules ----------------------------------------------------------------
ID ID (.*);
IF IF (.*);
EX EX (.*);
MEM MEM (.*);
WB WB (.*);

bp #(.s_index(5), .width(3)) BP
(
    .clk            (clk),
    .rst            (rst),

    .r_pc           (instr_mem_address),             //from IF directly
    .r_addr_pred    (addr_pred),             // to IF to pcmux directly
    .r_taken_pred   (taken_pred),             // to IF to pcmux directly

    .w_br_op        (w_br_op),      // from EX, tells if it actually is a branch op
    .w_pc           (pc_addr_IDEX),             // from EX / s
    .w_dest         (branch_addr_EX),             // from EX / alu
    .w_taken        (taken_corrected)              // from EX / br_en


);


endmodule : datapath

