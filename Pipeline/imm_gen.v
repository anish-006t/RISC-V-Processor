module imm_gen (
    input wire [31:0] instr,
    output reg signed [63:0] imm_out
);
    wire [6:0] opcode = instr[6:0];
    
    always @(*) begin
        case (opcode)
            7'b0010011,
            7'b0000011: begin
                // I-type logic 

                imm_out = {{52{instr[31]}}, instr[31:20]};
            end

            7'b0100011: begin
                // S-type logic
                imm_out = {{52{instr[31]}}, instr[31:25], instr[11:7]};
            end

            7'b1100011: begin
                // B-type logic
                imm_out = {{51{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            default: begin
                imm_out = 64'b0;
            end
        endcase
    end
endmodule
