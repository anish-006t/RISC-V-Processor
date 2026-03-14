// tb_branch_targ_adder.v
`timescale 1ns/1ps

module branch_target_adder_tb;

    reg  [63:0] pc;
    reg  [63:0] imm;
    wire [63:0] branch_target;

    // Instantiate DUT
    branch_targ_adder uut (
        .pc(pc),
        .imm(imm),
        .branch_target(branch_target)
    );

    // Helper task to display test case
    task test_case;
        input [63:0] pc_in;
        input [63:0] imm_in;
        reg   [63:0] expected;
        begin
            pc  = pc_in;
            imm = imm_in;
            #1; // allow time for combinational logic
            expected = pc_in + imm_in;
            if (branch_target === expected) begin
                $display("PC=%016h, IMM=%016h => TARGET=%016h (Expected=%016h) PASS",
                    pc, imm, branch_target, expected);
                total_tests = total_tests + 1;
            end else begin
                $display("PC=%016h, IMM=%016h => TARGET=%016h (Expected=%016h) FAIL",
                    pc, imm, branch_target, expected);
                total_tests = total_tests + 1;
                failed_tests = failed_tests + 1;
            end
        end
    endtask

    integer total_tests = 0;
    integer failed_tests = 0;

    initial begin
        $dumpfile("tb/branch_target_adder_tb.vcd");
        $dumpvars(0, branch_target_adder_tb);

        $display("\n==== Testing branch_targ_adder.v ====\n");

        // Simple positive offset
        test_case(64'h0000_0000_0000_1000, 64'h0000_0000_0000_0004);
        test_case(64'h0000_0000_0000_0040, 64'h0000_0000_0000_0008);

        // Larger positive offset
        test_case(64'h0000_0000_1000_0000, 64'h0000_0000_0000_0100);

        // Negative immediate (two's complement)
        test_case(64'h0000_0000_0000_1000, 64'hFFFF_FFFF_FFFF_FFFC); // -4

        // Zero offset
        test_case(64'h0000_0000_0000_1000, 64'h0);

        // Overflow scenario (wrap-around)
        test_case(64'hFFFF_FFFF_FFFF_FFFF, 64'h1);

        $display("\n==== Test Summary ====\n");
        $display("PASSED: %0d", total_tests - failed_tests);
        $display("FAILED: %0d", failed_tests);
        $display("Total:  %0d", total_tests);
        $display("==== Test completed ====");
        $finish;
    end

endmodule