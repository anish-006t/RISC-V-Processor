
module ex_mem_reg(
    input wire clk,
    input wire reset,

    input wire [63:0] alu_result_in,
    input wire [63:0] rs2_data_in,

    input wire [63:0] branch_target_in, //bonus 

    input wire [4:0] rd_in,

    input wire zero_in,

    input wire RegWrite_in,
    input wire MemRead_in,
    input wire MemWrite_in,
    input wire MemtoReg_in,
    input wire Branch_in,

    output reg [63:0] alu_result_out,
    output reg [63:0] rs2_data_out,

    output reg [63:0] branch_target_out, //bonus

    output reg [4:0] rd_out,

    output reg zero_out,

    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemtoReg_out,
    output reg Branch_out
);

always @(posedge clk) begin
    if (reset) begin
        alu_result_out <= 0;
        rs2_data_out <= 0;
        branch_target_out <= 0;
        rd_out <= 0;
        zero_out <= 0;
        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemtoReg_out <= 0;
        Branch_out <= 0;
    end
    else begin
        alu_result_out <= alu_result_in;
        rs2_data_out <= rs2_data_in;
        branch_target_out <= branch_target_in;
        rd_out <= rd_in;
        zero_out <= zero_in;
        RegWrite_out <= RegWrite_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemtoReg_out <= MemtoReg_in;
        Branch_out <= Branch_in;
    end
end

endmodule