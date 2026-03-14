// alu_control.v

module alu_control (
    input  wire [1:0] ALUOp,
    input  wire       instr30,
    input  wire [2:0] funct3,
    output reg  [3:0] ALUControl
);

    localparam ADD_Oper = 4'b0000;
    localparam SLL_Oper = 4'b0001;
    localparam SLT_Oper = 4'b0010;
    localparam SLTU_Oper = 4'b0011;
    localparam XOR_Oper = 4'b0100;
    localparam SRL_Oper = 4'b0101;
    localparam OR_Oper = 4'b0110;
    localparam AND_Oper = 4'b0111;
    localparam SUB_Oper = 4'b1000;
    localparam SRA_Oper = 4'b1101;

    always @(*) begin
        case (ALUOp)

            2'b00: begin
                // Load/Store
                ALUControl = ADD_Oper;
            end

            2'b01: begin
                // Branch 
                ALUControl = SUB_Oper;
            end

            2'b10: begin
                case (funct3)

                    3'b000: begin
                        // add/sub
                        if (instr30 == 1'b1)
                            ALUControl = SUB_Oper;
                        else
                            ALUControl = ADD_Oper;
                    end

                    3'b001: ALUControl = SLL_Oper;
                    3'b010: ALUControl = SLT_Oper;
                    3'b011: ALUControl = SLTU_Oper;
                    3'b100: ALUControl = XOR_Oper;

                    3'b101: begin
                        if (instr30)
                            ALUControl = SRA_Oper;
                        else
                            ALUControl = SRL_Oper;
                    end

                    3'b110: ALUControl = OR_Oper;
                    3'b111: ALUControl = AND_Oper;

                    default: ALUControl = ADD_Oper;
                endcase
            end

            default: ALUControl = ADD_Oper;
        endcase
    end

endmodule