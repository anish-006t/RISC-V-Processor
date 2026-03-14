// tb_control.v  (FINAL FIXED VERSION)
// Testbench for control.v
// Verifies R-type, I-type, load, store, and branch control signals

`timescale 1ns/1ps

module control_tb;

    reg  [6:0] opcode;
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;

    integer test_pass = 0, test_fail = 0;

    initial begin
        $dumpfile("tb/control_tb.vcd");
        $dumpvars(0, control_tb);
    end

    // Instantiate DUT
    control uut (
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    // Define opcodes
    localparam OPC_RTYPE   = 7'b0110011;
    localparam OPC_I_ARITH = 7'b0010011;
    localparam OPC_LOAD    = 7'b0000011;
    localparam OPC_STORE   = 7'b0100011;
    localparam OPC_BRANCH  = 7'b1100011;
    localparam OPC_OTHER   = 7'b1111111; // invalid/default

    // Expected bundle order: {Branch, MemRead, MemtoReg, ALUOp[1:0], MemWrite, ALUSrc, RegWrite}
    task check;
        input [6:0] op;
        input [7:0] expected;
        reg [7:0] actual;
        begin
            opcode = op;
            #1; // small delay for propagation
            actual = {Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite};
            if (actual === expected) begin
                $display("Opcode=%b => Signals={Br=%b MRd=%b M2R=%b ALUOp=%b MWr=%b ASrc=%b RWr=%b} ✅ PASS",
                         opcode, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
                test_pass = test_pass + 1;
            end else begin
                $display("Opcode=%b => Signals={Br=%b MRd=%b M2R=%b ALUOp=%b MWr=%b ASrc=%b RWr=%b} ❌ FAIL",
                         opcode, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
                test_fail = test_fail + 1;
            end
        end
    endtask

    initial begin
        $display("\n==== Testing control.v ====\n");

        // R-type: ALUOp=10, RegWrite=1
        // {Branch, MemRead, MemtoReg, ALUOp[1:0], MemWrite, ALUSrc, RegWrite} = 0001001
        check(OPC_RTYPE, 8'b00010001);

        // I-type (addi): ALUOp=00, ALUSrc=1, RegWrite=1
        check(OPC_I_ARITH, 8'b00000011);

        // LOAD: MemRead=1, MemtoReg=1, ALUOp=00, ALUSrc=1, RegWrite=1
        check(OPC_LOAD, 8'b01100011);

        // STORE: MemWrite=1, ALUSrc=1, RegWrite=0  ✅ FIXED EXPECTED VALUE
        check(OPC_STORE, 8'b00000110);

        // BRANCH: Branch=1, ALUOp=01
        check(OPC_BRANCH, 8'b10001000);

        // DEFAULT / invalid opcode: expect all 0s
        check(OPC_OTHER, 8'b00000000);

        $display("\n==== Test Summary ====");
        $display("PASSED: %0d", test_pass);
        $display("FAILED: %0d", test_fail);
        $display("Total:  %0d", test_pass + test_fail);
        $display("==== Test completed ====\n");
        $finish;
    end

endmodule