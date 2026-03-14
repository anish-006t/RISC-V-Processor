module pc (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [63:0] pc_in,
    output reg [63:0] pc_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 64'd0;
    end
    else if (!stall) begin
        pc_out <= pc_in;
    end
end

endmodule