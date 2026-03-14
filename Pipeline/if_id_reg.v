module if_id_reg(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,

    input wire [31:0] instr_in,
    input wire [63:0] pc_in,
    input wire [63:0] pc4_in,

    output reg [31:0] instr_out,
    output reg [63:0] pc_out,
    output reg [63:0] pc4_out
);

always @(posedge clk) begin
    if (reset || flush) begin
        instr_out <= 32'd0;
        pc_out <= 64'd0; 
        pc4_out <= 64'd0;
    end
    else if (!stall) begin
        instr_out <= instr_in;
        pc_out <= pc_in;
        pc4_out <= pc4_in;
    end
end

endmodule