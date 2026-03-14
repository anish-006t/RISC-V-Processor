

module control (
    input  wire [6:0] opcode,
    output reg       Branch,
    output reg       MemRead,
    output reg       MemtoReg,
    output reg [1:0] ALUOp,
    output reg       MemWrite,
    output reg       ALUSrc,
    output reg       RegWrite
);

    // opcode constants (RISC-V)
    localparam OPC_RTYPE  = 7'b0110011; // R-type 
    localparam OPC_I_ARITH= 7'b0010011; // addi 
    localparam OPC_LOAD   = 7'b0000011; // ld
    localparam OPC_STORE  = 7'b0100011; // sd
    localparam OPC_BRANCH = 7'b1100011; // beq

    always @(*) begin

        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        ALUOp    = 2'b00;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;

        case (opcode)
            OPC_RTYPE: begin
               
                Branch   = 1'b0;
                MemRead  = 1'b0;
                MemtoReg = 1'b0;
                ALUOp    = 2'b10; 
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;
                RegWrite = 1'b1;
            end

            OPC_I_ARITH: begin
               
                Branch   = 1'b0;
                MemRead  = 1'b0;
                MemtoReg = 1'b0;
                ALUOp    = 2'b00; 
                MemWrite = 1'b0;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
            end

            OPC_LOAD: begin
               
                Branch   = 1'b0;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUOp    = 2'b00; //used for address calculation
                MemWrite = 1'b0;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
            end

            OPC_STORE: begin
              
                Branch   = 1'b0;
                MemRead  = 1'b0;
                MemtoReg = 1'b0;
                ALUOp    = 2'b00; // address
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                RegWrite = 1'b0;
            end

            OPC_BRANCH: begin
               
                Branch   = 1'b1;
                MemRead  = 1'b0;
                MemtoReg = 1'b0;
                ALUOp    = 2'b01;// for beq function, subtraction used
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;
                RegWrite = 1'b0;
            end

            default: begin
                
            end
        endcase
    end

endmodule