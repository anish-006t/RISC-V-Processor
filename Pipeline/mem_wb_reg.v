module mem_wb_reg(
    input wire clk,
    input wire reset,

    input wire [63:0] mem_data_in,
    input wire [63:0] alu_result_in,
    input wire [4:0] rd_in,

    input wire RegWrite_in,
    input wire MemtoReg_in,

    output reg [63:0] mem_data_out,
    output reg [63:0] alu_result_out,
    output reg [4:0] rd_out,

    output reg RegWrite_out,
    output reg MemtoReg_out
);

always @(posedge clk) begin
    if (reset) begin
        mem_data_out <= 0;
        alu_result_out <= 0;
        rd_out <= 0;
        RegWrite_out <= 0;
        MemtoReg_out <= 0;
    end
    else begin
        mem_data_out <= mem_data_in;
        alu_result_out <= alu_result_in;
        rd_out <= rd_in;
        RegWrite_out <= RegWrite_in;
        MemtoReg_out <= MemtoReg_in;
    end
end

endmodule