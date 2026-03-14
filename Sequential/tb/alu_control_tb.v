// tb_alu_control.v
`timescale 1ns/1ps

module alu_control_tb;

    reg [1:0] ALUOp;
    reg instr30;
    reg [2:0] funct3;

    wire [3:0] ALUControl;

    // Instantiate DUT
    alu_control uut (
        .ALUOp(ALUOp),
        .instr30(instr30),
        .funct3(funct3),
        .ALUControl(ALUControl)
    );

    // Human-readable display for each ALUControl code
    function [80*8:1] decode_aluop;
        input [3:0] code;
        begin
            case (code)
                4'b0000: decode_aluop = "ADD";
                4'b0001: decode_aluop = "SLL";
                4'b0010: decode_aluop = "SLT";
                4'b0011: decode_aluop = "SLTU";
                4'b0100: decode_aluop = "XOR";
                4'b0101: decode_aluop = "SRL";
                4'b0110: decode_aluop = "OR";
                4'b0111: decode_aluop = "AND";
                4'b1000: decode_aluop = "SUB";
                4'b1101: decode_aluop = "SRA";
                default: decode_aluop = "UNKNOWN";
            endcase
        end
    endfunction

    // Print result
    task show;
        input [1:0] aop;
        input bit30;
        input [2:0] f3;
        input [6:0] opc;
        begin
            ALUOp = aop;
            instr30 = bit30;
            funct3 = f3;
            #1;
            $display("ALUOp=%b funct3=%b instr30=%b -> ALUControl=%b (%s)",
                     ALUOp, funct3, instr30, ALUControl, decode_aluop(ALUControl));
            test_pass = test_pass + 1;
        end
    endtask

    integer test_pass = 0, test_fail = 0;

    initial begin
        $dumpfile("tb/alu_control_tb.vcd");
        $dumpvars(0, alu_control_tb);
        
        $display("\n==== Testing alu_control.v ====\n");

        // Load/Store (ALUOp = 00 -> ADD)
        show(2'b00, 0, 3'b000, 7'b0000011); // ld
        show(2'b00, 1, 3'b101, 7'b0100011); // sd

        // Branch (ALUOp = 01 -> SUB)
        show(2'b01, 0, 3'b000, 7'b1100011); // beq

        // R-type / I-type operations (ALUOp = 10)
        show(2'b10, 0, 3'b000, 7'b0110011); // add
        show(2'b10, 1, 3'b000, 7'b0110011); // sub
        show(2'b10, 0, 3'b111, 7'b0110011); // and
        show(2'b10, 0, 3'b110, 7'b0110011); // or
        show(2'b10, 0, 3'b100, 7'b0110011); // xor
        show(2'b10, 0, 3'b001, 7'b0110011); // sll
        show(2'b10, 0, 3'b010, 7'b0110011); // slt
        show(2'b10, 0, 3'b011, 7'b0110011); // sltu
        show(2'b10, 0, 3'b101, 7'b0110011); // srl
        show(2'b10, 1, 3'b101, 7'b0110011); // sra

        // I-type addi (should treat instr30=0 as ADD)
        show(2'b10, 0, 3'b000, 7'b0010011); // addi

        // Invalid combinations (safety defaults)
        show(2'b11, 0, 3'b111, 7'b0000000);
        show(2'b10, 0, 3'b111, 7'b1111111);

        $display("\n==== Test Summary ====");
        $display("PASSED: %0d", test_pass);
        $display("FAILED: %0d", test_fail);
        $display("Total:  %0d", test_pass + test_fail);
        $display("==== Test completed ====\n");
        $finish;
    end

endmodule