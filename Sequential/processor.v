module processor (
    input wire clk,
    input wire reset,
    input wire dump_regs   
);

    // PC
    wire [63:0] pc_current;
    wire [63:0] pc_next;

    pc pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc_current)
    );

    // Instruction Fetch
   
    wire [31:0] instruction;

    instruction_mem imem (
        .addr(pc_current),
        .instr(instruction)
    );


    // Control Unit

    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;

    control ctrl (
        .opcode(instruction[6:0]),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    // Registers 

    wire [63:0] read_data1, read_data2;
    wire [63:0] write_back_data;

    reg_file rf (
        .clk(clk),
        .reset(reset),
        .read_reg1(instruction[19:15]),
        .read_reg2(instruction[24:20]),
        .write_reg(instruction[11:7]),
        .write_data(write_back_data),
        .reg_write_en(RegWrite),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .dump_regs(dump_regs)
    );

  
    // Immediate generator
    wire signed [63:0] imm_out;

    imm_gen immgen (
        .instr(instruction),
        .imm_out(imm_out)
    );


    // ALU Control
    wire [3:0] ALUControl;

    alu_control alu_ctrl (
        .ALUOp(ALUOp),
        .instr30(instruction[30]),
        .funct3(instruction[14:12]),
        .ALUControl(ALUControl)
    );


    // ALU Mux (ALUSrc)
    wire [63:0] alu_input2;

    mux_2to1_64 alu_mux (
        .in0(read_data2),
        .in1(imm_out),
        .sel(ALUSrc),
        .out(alu_input2)
    );

    // ALU
    wire [63:0] alu_result;
    wire zero_flag;

    alu_64_bit alu (
        .a(read_data1),
        .b(alu_input2),
        .opcode(ALUControl),
        .result(alu_result),
        .cout(),
        .carry_flag(),
        .overflow_flag(),
        .zero_flag(zero_flag)
    );

    // Data Memory
    wire [63:0] mem_read_data;

    data_mem dmem (
        .clk(clk),
        .reset(reset),
        .address(alu_result),
        .write_data(read_data2),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .read_data(mem_read_data)
    );

// Write-back Mux (MemtoReg)
    mux_2to1_64 wb_mux (
        .in0(alu_result),
        .in1(mem_read_data),
        .sel(MemtoReg),
        .out(write_back_data)
    );

    // PC + 4
    wire [63:0] pc_plus4;

    pc_plus_4 pc_inc (
        .pc_in(pc_current),
        
        .pc_out(pc_plus4)
    );

    // Branch Target Adder
    wire [63:0] branch_target;

    branch_targ_adder bta (
        .pc(pc_current),
        .imm(imm_out),
        .branch_target(branch_target)
    );

    // PC Mux (Branch decision)
    wire pc_src;
    assign pc_src = Branch & zero_flag;

    mux_2to1_64 pc_mux (
        .in0(pc_plus4),
        .in1(branch_target),
        .sel(pc_src),
        .out(pc_next)
    );

endmodule