module id_ex_reg(
    input wire clk,
    input wire reset,
    input wire flush,
    input wire bubble,

    input wire [63:0] pc4_in,
    input wire [63:0] rs1_data_in,
    input wire [63:0] rs2_data_in,
    input wire [63:0] imm_in,
    input wire [63:0] branch_target_in,

    input wire [4:0] rs1_in,
    input wire [4:0] rs2_in,
    input wire [4:0] rd_in,

    input wire [2:0] funct3_in,
    input wire instr30_in,

    input wire RegWrite_in,
    input wire MemRead_in,
    input wire MemWrite_in,
    input wire MemtoReg_in,
    input wire Branch_in,
    input wire ALUSrc_in,
    input wire [1:0] ALUOp_in,

    output reg [63:0] pc4_out,
    output reg [63:0] rs1_data_out,
    output reg [63:0] rs2_data_out,
    output reg [63:0] imm_out,
    output reg [63:0] branch_target_out,

    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,

    output reg [2:0] funct3_out,
    output reg instr30_out,

    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemtoReg_out,
    output reg Branch_out,
    output reg ALUSrc_out,
    output reg [1:0] ALUOp_out
);

always @(posedge clk) begin
    if (reset || flush) begin
        pc4_out <= 0;
        rs1_data_out <= 0;
        rs2_data_out <= 0;
        imm_out <= 0;
        branch_target_out <= 0;
        rs1_out <= 0;
        rs2_out <= 0;
        rd_out <= 0;
        funct3_out <= 0;
        instr30_out <= 0;
        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemtoReg_out <= 0;
        Branch_out <= 0;
        ALUSrc_out <= 0;
        ALUOp_out <= 0;
    end
    else begin
        pc4_out <= pc4_in;
        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        imm_out <= imm_in;
        branch_target_out <= branch_target_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        funct3_out <= funct3_in;
        instr30_out <= instr30_in;

        if (bubble) begin
            RegWrite_out <= 0;
            MemRead_out  <= 0;
            MemWrite_out <= 0;
            MemtoReg_out <= 0;
            Branch_out <= 0;
            ALUSrc_out <= 0;
            ALUOp_out <= 0;
        end
        else begin
            RegWrite_out <= RegWrite_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemtoReg_out <= MemtoReg_in;
            Branch_out <= Branch_in;
            ALUSrc_out <= ALUSrc_in;
            ALUOp_out <= ALUOp_in;
        end
    end
end

endmodule