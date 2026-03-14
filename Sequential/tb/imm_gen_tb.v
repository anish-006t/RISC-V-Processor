`timescale 1ns/1ps

module imm_gen_tb;

    reg [31:0] instr;
    wire signed [63:0] imm_out;

    integer errors = 0;
    integer test_pass = 0, test_fail = 0;
    integer total_tests = 0;
    integer failed_tests = 0;

    initial begin
        $dumpfile("tb/imm_gen_tb.vcd");
        $dumpvars(0, imm_gen_tb);
    end

    // Instantiate DUT
    imm_gen uut (
        .instr(instr),
        .imm_out(imm_out)
    );

    task check;
        input signed [63:0] expected;
        input [255:0] testname;
        begin
            #1; // small delay to settle
            total_tests = total_tests + 1;
            if (imm_out === expected) begin
                $display("PASS: %s | imm_out = %0d (0x%h)", testname, imm_out, imm_out);
            end else begin
                $display("FAIL: %s | Expected = %0d (0x%h), Got = %0d (0x%h)",
                         testname, expected, expected, imm_out, imm_out);
                errors = errors + 1;
                failed_tests = failed_tests + 1;
            end
        end
    endtask


    initial begin

        $display("========== IMM GEN TEST START ==========");

        // ---------------- I-TYPE (+10) ----------------
        instr = 32'b000000001010_00010_000_00001_0010011;
        check(10, "I-type +10");

        // ---------------- I-TYPE (-4) ----------------
        instr = 32'b111111111100_00010_000_00001_0010011;
        check(-4, "I-type -4");

        // ---------------- S-TYPE (+8) ----------------
        instr = 32'b0000000_00011_00010_011_01000_0100011;
        check(8, "S-type +8");

        // ---------------- B-TYPE (+16) ----------------
        instr = 32'b0_000000_00010_00001_000_1000_0_1100011;
        check(16, "B-type +16");

        // ---------------- R-TYPE (should be 0) ----------------
        instr = 32'b0000000_00010_00001_000_00011_0110011;
        check(0, "R-type default");

        $display("========================================");
        $display("PASSED: %0d", total_tests - failed_tests);
        $display("FAILED: %0d", failed_tests);
        $display("Total:  %0d", total_tests);
        $finish;
    end

endmodule