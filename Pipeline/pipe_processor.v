`include "pc.v"
`include "pc_plus_4.v"
`include "instruction_mem.v"
`include "if_id_reg.v"
`include "reg_file.v"
`include "control.v"
`include "imm_gen.v"
`include "branch_targ_adder.v"
`include "id_ex_reg.v"
`include "alu_control.v"
`include "alu.v"
`include "ex_mem_reg.v"
`include "data_mem.v"
`include "mem_wb_reg.v"
`include "mux.v"
`include "forwarding_unit.v"
`include "hazard_detection_unit.v"

module pipe_processor(
    input clk,
    input reset
);

//////////////////////////////////////////////////
// IF STAGE
//////////////////////////////////////////////////

wire [63:0] pc_current;
wire [63:0] pc_next;
wire [63:0] pc_plus4_if;
wire [31:0] instruction;
wire pc_stall;
wire ifid_stall;
wire ifid_flush;
wire idex_flush;
wire idex_bubble;
wire load_use_hazard;
wire branch_taken_ex;

pc PC(
    .clk(clk),
    .reset(reset),
    //.stall(1'b0), // old
    .stall(pc_stall),
    .pc_in(pc_next),
    .pc_out(pc_current)
);

pc_plus_4 PC4(
    .pc_in(pc_current),
    .pc_out(pc_plus4_if)
);

instruction_mem IMEM(
    .addr(pc_current),
    .instr(instruction)
);

//////////////////////////////////////////////////
// IF/ID PIPELINE REGISTER
//////////////////////////////////////////////////

wire [31:0] ifid_instr;
wire [63:0] ifid_pc;
wire [63:0] ifid_pc4;

if_id_reg IF_ID(
    .clk(clk),
    .reset(reset),
    //.stall(1'b0), // old
    .stall(ifid_stall),
    //.flush(1'b0), // old
    .flush(ifid_flush),

    .instr_in(instruction),
    .pc_in(pc_current),
    .pc4_in(pc_plus4_if),

    .instr_out(ifid_instr),
    .pc_out(ifid_pc),
    .pc4_out(ifid_pc4)
);

//////////////////////////////////////////////////
// ID STAGE
//////////////////////////////////////////////////

wire [4:0] rs1 = ifid_instr[19:15];
wire [4:0] rs2 = ifid_instr[24:20];
wire [4:0] rd  = ifid_instr[11:7];
wire [6:0] ifid_opcode = ifid_instr[6:0];

wire [2:0] funct3 = ifid_instr[14:12];
wire instr30 = ifid_instr[30];

wire [63:0] rs1_data;
wire [63:0] rs2_data;

wire RegWrite;
wire MemRead;
wire MemWrite;
wire MemtoReg;
wire Branch;
wire ALUSrc;
wire [1:0] ALUOp;

wire [63:0] writeback_data;

control CTRL(
    .opcode(ifid_instr[6:0]),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
);

reg_file RF(
    .clk(clk),
    .reset(reset),

    .read_reg1(rs1),
    .read_reg2(rs2),

    .write_reg(memwb_rd),
    .write_data(writeback_data),
    .reg_write_en(memwb_RegWrite),

    .read_data1(rs1_data),
    .read_data2(rs2_data),

    .dump_regs(1'b0)
);

wire [63:0] imm;

imm_gen IMM(
    .instr(ifid_instr),
    .imm_out(imm)
);

wire [63:0] branch_target;

branch_targ_adder BTA(
    .pc(ifid_pc),
    .imm(imm),
    .branch_target(branch_target)
);

//////////////////////////////////////////////////
// ID/EX PIPELINE REGISTER
//////////////////////////////////////////////////

wire [63:0] idex_rs1_data;
wire [63:0] idex_rs2_data;
wire [63:0] idex_imm;
wire [63:0] idex_branch_target;

wire [4:0] idex_rs1;
wire [4:0] idex_rs2;
wire [4:0] idex_rd;

wire [2:0] idex_funct3;
wire idex_instr30;

wire idex_RegWrite;
wire idex_MemRead;
wire idex_MemWrite;
wire idex_MemtoReg;
wire idex_Branch;
wire idex_ALUSrc;
wire [1:0] idex_ALUOp;

id_ex_reg ID_EX(
    .clk(clk),
    .reset(reset),
    //.flush(1'b0), // old
    .flush(idex_flush),
    //.bubble(1'b0), // old
    .bubble(idex_bubble),

    .pc4_in(ifid_pc4),
    .rs1_data_in(rs1_data),
    .rs2_data_in(rs2_data),
    .imm_in(imm),
    .branch_target_in(branch_target),

    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),

    .funct3_in(funct3),
    .instr30_in(instr30),

    .RegWrite_in(RegWrite),
    .MemRead_in(MemRead),
    .MemWrite_in(MemWrite),
    .MemtoReg_in(MemtoReg),
    .Branch_in(Branch),
    .ALUSrc_in(ALUSrc),
    .ALUOp_in(ALUOp),

    .rs1_data_out(idex_rs1_data),
    .rs2_data_out(idex_rs2_data),
    .imm_out(idex_imm),
    .branch_target_out(idex_branch_target),

    .rs1_out(idex_rs1),
    .rs2_out(idex_rs2),
    .rd_out(idex_rd),
    .funct3_out(idex_funct3),
    .instr30_out(idex_instr30),

    .RegWrite_out(idex_RegWrite),
    .MemRead_out(idex_MemRead),
    .MemWrite_out(idex_MemWrite),
    .MemtoReg_out(idex_MemtoReg),
    .Branch_out(idex_Branch),
    .ALUSrc_out(idex_ALUSrc),
    .ALUOp_out(idex_ALUOp)
);

//////////////////////////////////////////////////
// EX STAGE
//////////////////////////////////////////////////

wire [3:0] alu_control_signal;

alu_control ALUCTRL(
    .ALUOp(idex_ALUOp),
    .instr30(idex_instr30),
    .funct3(idex_funct3),
    .ALUControl(alu_control_signal)
);

wire [63:0] alu_b;
wire [1:0] forward_a_sel;
wire [1:0] forward_b_sel;
wire [63:0] ex_alu_src_a;
wire [63:0] ex_rs2_data_forwarded;

mux_2to1_64 alu_src_mux(
    //.in0(idex_rs2_data), // old
    .in0(ex_rs2_data_forwarded),
    .in1(idex_imm),
    .sel(idex_ALUSrc),
    .out(alu_b)
);

wire [63:0] alu_result;
wire zero_flag;

alu_64_bit ALU(
    //.a(idex_rs1_data), // old
    .a(ex_alu_src_a),
    .b(alu_b),
    .opcode(alu_control_signal),
    .result(alu_result),
    .cout(),
    .carry_flag(),
    .overflow_flag(),
    .zero_flag(zero_flag)
);

assign branch_taken_ex = idex_Branch && zero_flag;

//////////////////////////////////////////////////
// EX/MEM PIPELINE REGISTER
//////////////////////////////////////////////////

wire [63:0] exmem_alu_result;
wire [63:0] exmem_rs2_data;
wire [63:0] exmem_branch_target_unused;
wire [4:0] exmem_rd;

wire exmem_zero_unused;
wire exmem_Branch_unused;
wire exmem_RegWrite;
wire exmem_MemRead;
wire exmem_MemWrite;
wire exmem_MemtoReg;

ex_mem_reg EX_MEM(
    .clk(clk),
    .reset(reset),

    .alu_result_in(alu_result),
    .rs2_data_in(ex_rs2_data_forwarded),
    .branch_target_in(idex_branch_target),
    .rd_in(idex_rd),
    .zero_in(zero_flag),

    .RegWrite_in(idex_RegWrite),
    .MemRead_in(idex_MemRead),
    .MemWrite_in(idex_MemWrite),
    .MemtoReg_in(idex_MemtoReg),
    .Branch_in(idex_Branch),

    .alu_result_out(exmem_alu_result),
    .rs2_data_out(exmem_rs2_data),
    .branch_target_out(exmem_branch_target_unused),
    .rd_out(exmem_rd),
    .zero_out(exmem_zero_unused),

    .RegWrite_out(exmem_RegWrite),
    .MemRead_out(exmem_MemRead),
    .MemWrite_out(exmem_MemWrite),
    .MemtoReg_out(exmem_MemtoReg),
    .Branch_out(exmem_Branch_unused)
);

//////////////////////////////////////////////////
// MEM STAGE
//////////////////////////////////////////////////

wire [63:0] mem_read_data;

data_mem DMEM(
    .clk(clk),
    .reset(reset),
    .address(exmem_alu_result),
    .write_data(exmem_rs2_data),
    .MemRead(exmem_MemRead),
    .MemWrite(exmem_MemWrite),
    .read_data(mem_read_data)
);

//////////////////////////////////////////////////
// MEM/WB PIPELINE REGISTER
//////////////////////////////////////////////////

wire [63:0] memwb_mem_data;
wire [63:0] memwb_alu_result;

wire [4:0] memwb_rd;
wire memwb_RegWrite;
wire memwb_MemtoReg;

mem_wb_reg MEM_WB(
    .clk(clk),
    .reset(reset),

    .mem_data_in(mem_read_data),
    .alu_result_in(exmem_alu_result),
    .rd_in(exmem_rd),

    .RegWrite_in(exmem_RegWrite),
    .MemtoReg_in(exmem_MemtoReg),

    .mem_data_out(memwb_mem_data),
    .alu_result_out(memwb_alu_result),
    .rd_out(memwb_rd),

    .RegWrite_out(memwb_RegWrite),
    .MemtoReg_out(memwb_MemtoReg)
);

forwarding_unit FORWARD_UNIT(
    .exmem_RegWrite(exmem_RegWrite),
    .exmem_rd(exmem_rd),
    .memwb_RegWrite(memwb_RegWrite),
    .memwb_rd(memwb_rd),
    .idex_rs1(idex_rs1),
    .idex_rs2(idex_rs2),
    .forward_a(forward_a_sel),
    .forward_b(forward_b_sel)
);

assign ex_alu_src_a =
    (forward_a_sel == 2'b10) ? exmem_alu_result :
    (forward_a_sel == 2'b01) ? writeback_data :
    idex_rs1_data;

assign ex_rs2_data_forwarded =
    (forward_b_sel == 2'b10) ? exmem_alu_result :
    (forward_b_sel == 2'b01) ? writeback_data :
    idex_rs2_data;

//////////////////////////////////////////////////
// WRITEBACK
//////////////////////////////////////////////////

mux_2to1_64 WB_MUX(
    .in0(memwb_alu_result),
    .in1(memwb_mem_data),
    .sel(memwb_MemtoReg),
    .out(writeback_data)
);

//////////////////////////////////////////////////
// PC UPDATE
//////////////////////////////////////////////////

hazard_detection_unit HAZARD_DETECT(
    .idex_MemRead(idex_MemRead),
    .idex_rd(idex_rd),
    .ifid_rs1(rs1),
    .ifid_rs2(rs2),
    .ifid_opcode(ifid_opcode),
    .load_use_hazard(load_use_hazard)
);

assign pc_stall = load_use_hazard && !branch_taken_ex;
assign ifid_stall = load_use_hazard && !branch_taken_ex;
assign ifid_flush = branch_taken_ex;
assign idex_flush = branch_taken_ex;
assign idex_bubble = load_use_hazard && !branch_taken_ex;

//assign pc_next = pc_plus4_if; // old
assign pc_next = branch_taken_ex ? idex_branch_target : pc_plus4_if;

//always @(posedge clk) // old
//    $display("PC=%h IF=%h ID=%h EX=%h MEM=%h WB=%h", // old
//        pc_current, // old
//        instruction, // old
//        ifid_instr, // old
//        idex_rd, // old
//        exmem_rd, // old
//        memwb_rd); // old

endmodule
