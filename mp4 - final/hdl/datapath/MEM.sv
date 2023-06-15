`define BAD_MUX_SEL2 $display("Illegal mux select MEM")




module MEM 
import rv32i_types::*;
import mp4_types::*;
(

    input clk,
    input rst,

    // forwarding port
    input   logic                   stall,
    input   logic                   flush,

    // registered inputs to from EX
    input  rv32i_word               alu_out_EXMEM,
    input  logic                    br_en_EXMEM,
    input  logic [4:0]              rd_EXMEM,
    input  rv32i_word               rs2_data_EXMEM,

    input  rv32i_word               u_imm_EXMEM,
    input  rv32i_word               pc_addr_EXMEM,
    input  logic [2:0]              funct3_EXMEM,

    // control word
    input   rv32i_control_word      ctrl_EXMEM,

    //RVFI
    input   rvfi_monitor_passthrough    rvfi_EXMEM,
    output  rvfi_monitor_passthrough    rvfi_MEMWB,

    // port to data cache / magic memory
    input rv32i_word 	            data_mem_rdata, 
    output logic 			        data_read,
    output logic 			        data_write,
    output logic [3:0] 	            data_mbe,
    output rv32i_word 	            data_mem_address,
    output rv32i_word 	            data_mem_wdata,



    // registered outputs to WB
    output  rv32i_word              alu_out_MEMWB,
    output  rv32i_word              mem_out_MEMWB,
    output  logic [4:0]             rd_MEMWB,
    output  rv32i_control_word      ctrl_MEMWB,
    output  logic                   br_en_MEMWB,
    output  rv32i_word              u_imm_MEMWB,
    output  rv32i_word              pc_addr_MEMWB,

    output  rv32i_word              regfilemux_out,
    output  rv32i_word              regfilemux_out_MEMWB,
    output  logic                   load_regfile_MEMWB,

    input logic a,
    output logic b
);

rv32i_control_word ctrl;    assign ctrl = ctrl_EXMEM;
rvfi_monitor_passthrough rvfi;  assign rvfi = rvfi_EXMEM;



always_comb begin : STORES
    data_read = ctrl.mem_read;
    data_write = ctrl.mem_write;
    data_mem_address = {alu_out_EXMEM[31:2], 2'b00};             //DJM  changed from irene

    data_mbe = 4'b0000;
    data_mem_wdata = 32'd0;
    if(ctrl.mem_write) 
    // if (ctrl.opcode == op_store)                                                    // DJM      NEEDS FORWARDING FROM WB->MEM      <<<    data_mem_wdata      = fwd_wdata_sel ? fwd_WB_to_MEM : rs2_data_EXMEM;   >>>
    begin
        unique case(store_funct3_t'(funct3_EXMEM))
            sw: begin
                data_mbe = 4'b1111;
                data_mem_wdata = rs2_data_EXMEM;
            end
            sh: begin
                data_mbe = 4'b0011 << (alu_out_EXMEM[1] << 1);
                unique case(alu_out_EXMEM[1])
                    1'b1: data_mem_wdata = rs2_data_EXMEM << 16;                    //DJM why is this being shifted??   sh and sb just take whatever is the lowest bits of the register and store that...
                    1'b0: data_mem_wdata = rs2_data_EXMEM;
                endcase
            end
            sb: begin
                data_mbe = 4'b0001 << alu_out_EXMEM[1:0];
                unique case(alu_out_EXMEM[1:0])
                    2'b11: data_mem_wdata = rs2_data_EXMEM << 24;
                    2'b10: data_mem_wdata = rs2_data_EXMEM << 16;
                    2'b01: data_mem_wdata = rs2_data_EXMEM << 8;
                    2'b00: data_mem_wdata = rs2_data_EXMEM;
                endcase
            end
            default:;
        endcase
    end
end

logic [3:0] rmask;

always_comb begin : loads
    rmask = 4'b0000;
    if (ctrl.opcode == op_load)
    begin
        case (load_funct3_t'(ctrl.funct3))
            lw: rmask = 4'b1111;
            lh, lhu:
            begin
                unique case (alu_out_EXMEM[1])
                    1'd0: rmask = 4'b0011;
                    1'd1: rmask = 4'b1100;
                endcase
            end
            lb, lbu:
            begin
                unique case (alu_out_EXMEM[1:0])
                    2'd0: rmask = 4'b0001;
                    2'd1: rmask = 4'b0010;
                    2'd2: rmask = 4'b0100;
                    2'd3: rmask = 4'b1000;
                endcase
            end
        endcase
    end

end



always_comb begin : MUXES
    regfilemux_out = '0; 
    if (rd_EXMEM != 0) begin
        unique case (ctrl.regfilemux_sel)
            regfilemux::alu_out:    regfilemux_out = alu_out_EXMEM;     
            regfilemux::br_en:      regfilemux_out = {31'h0, br_en_EXMEM};  
            regfilemux::u_imm:      regfilemux_out = u_imm_EXMEM;   
            regfilemux::pc_plus4:   regfilemux_out = pc_addr_EXMEM + 4;

            regfilemux::lw:         regfilemux_out = data_mem_rdata;        //full 32 bits
            regfilemux::lh: begin
                unique case (alu_out_EXMEM[1])
                    1'd0: regfilemux_out = data_mem_rdata[15] ? {16'hFFFF, data_mem_rdata[15:0]} :    {16'h0, data_mem_rdata[15:0]};    //half sext
                    1'd1: regfilemux_out = data_mem_rdata[31] ? {16'hFFFF, data_mem_rdata[31:16]} :    {16'h0, data_mem_rdata[31:16]};    //half sext
                endcase
            end
            regfilemux::lhu: begin
                unique case (alu_out_EXMEM[1])
                    1'd0: regfilemux_out = {16'h0, data_mem_rdata[15:0]};    //half zext
                    1'd1: regfilemux_out = {16'h0, data_mem_rdata[31:16]};    //half zext
                endcase
            end     
            regfilemux::lb: begin
                unique case (alu_out_EXMEM[1:0])
                    2'b00: regfilemux_out = data_mem_rdata[7]   ? {24'hFFFFFF,  data_mem_rdata[7:0]}   : {24'h0, data_mem_rdata[7:0] };    //byte sext
                    2'b01: regfilemux_out = data_mem_rdata[15]  ? {24'hFFFFFF,  data_mem_rdata[15:8]}  : {24'h0, data_mem_rdata[15:8] };    //byte sext
                    2'b10: regfilemux_out = data_mem_rdata[23]  ? {24'hFFFFFF,  data_mem_rdata[23:16]} : {24'h0, data_mem_rdata[23:16] };    //byte sext
                    2'b11: regfilemux_out = data_mem_rdata[31]  ? {24'hFFFFFF,  data_mem_rdata[31:24]} : {24'h0, data_mem_rdata[31:24] };    //byte sext
                endcase
            end
            regfilemux::lbu:begin
                unique case (alu_out_EXMEM[1:0])
                    2'b00: regfilemux_out = {24'h0, data_mem_rdata[7:0] };      //byte zext 
                    2'b01: regfilemux_out = {24'h0, data_mem_rdata[15:8] };     //byte zext 
                    2'b10: regfilemux_out = {24'h0, data_mem_rdata[23:16] };    //byte zext 
                    2'b11: regfilemux_out = {24'h0, data_mem_rdata[31:24] };    //byte zext 
                endcase
            end
            default: `BAD_MUX_SEL2;
        endcase
    end
end


always_ff @(posedge clk) begin : REGISTERS
    if (rst)
    begin
        alu_out_MEMWB   <= 32'h00000000;
        rd_MEMWB        <= 5'h0;
        mem_out_MEMWB   <= 32'h00000000;
        ctrl_MEMWB      <= '0;
        u_imm_MEMWB     <= 32'h00000000;
        pc_addr_MEMWB   <= 32'h00000000;
        br_en_MEMWB     <= 1'b0;
        rvfi_MEMWB      <= '0;

    end
    else
    begin
        if (~stall||flush)
        begin
            alu_out_MEMWB       <= alu_out_EXMEM;
            rd_MEMWB            <= rd_EXMEM;
            mem_out_MEMWB       <= data_mem_rdata;
            ctrl_MEMWB          <= ctrl_EXMEM;
            u_imm_MEMWB         <= u_imm_EXMEM;
            pc_addr_MEMWB       <= pc_addr_EXMEM;
            br_en_MEMWB         <= br_en_EXMEM;
            load_regfile_MEMWB  <= ctrl.load_regfile;
            b <= a;                                                                     //DJM gotta get better names
            regfilemux_out_MEMWB <= regfilemux_out;


            //rvfi
            rvfi_MEMWB.halt                 <= rvfi.halt;
            rvfi_MEMWB.commit               <= rvfi.commit           ;  
            //rvfi_MEMWB.order              <  = rvfi.order            ;
            rvfi_MEMWB.inst                 <= rvfi.inst             ;
            rvfi_MEMWB.trap                 <= rvfi.trap             ;
            rvfi_MEMWB.rs1_addr             <= rvfi.rs1_addr         ;
            rvfi_MEMWB.rs2_addr             <= rvfi.rs2_addr         ;
            rvfi_MEMWB.rs1_rdata            <= rvfi.rs1_rdata        ;
            rvfi_MEMWB.rs2_rdata            <= rvfi.rs2_rdata        ;
            rvfi_MEMWB.load_regfile         <= rvfi.load_regfile     ;
            rvfi_MEMWB.rd_addr              <= rvfi.rd_addr          ;
            rvfi_MEMWB.rd_wdata             <= rvfi.rd_wdata         ;
            rvfi_MEMWB.pc_rdata             <= rvfi.pc_rdata         ;
            rvfi_MEMWB.pc_wdata             <= rvfi.pc_wdata         ;
            rvfi_MEMWB.mem_addr             <= data_mem_address      ;              //rvfi.mem_addr         ;
            rvfi_MEMWB.mem_rmask            <= rmask;                               //rvfi.mem_rmask        ;
            rvfi_MEMWB.mem_wmask            <= data_mbe              ;                                              // is this doing anything??
            rvfi_MEMWB.mem_rdata            <= data_mem_rdata        ;              //rvfi.mem_rdata        ;
            rvfi_MEMWB.mem_wdata            <= data_mem_wdata        ;              //rvfi.mem_wdata        ;
            rvfi_MEMWB.load_pc              <= rvfi.load_pc          ;
            rvfi_MEMWB.pcmux_sel_branch     <= rvfi.pcmux_sel_branch ;
        end
    end
end



endmodule
