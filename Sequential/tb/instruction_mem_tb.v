`timescale 1ns/1ps

module instruction_mem_tb;

    reg  [63:0] addr;
    wire [31:0] instr;

    integer errors = 0;

    instruction_mem uut (
        .addr(addr),
        .instr(instr)
    );

    task check;
        input [31:0] expected;
        input [255:0] testname;
        begin
            #1;
            if (instr === expected) begin
                $display("PASS: %s | instr = 0x%h", testname, instr);
            end
            else begin
                $display("FAIL: %s | Expected = 0x%h, Got = 0x%h",
                         testname, expected, instr);
                errors = errors + 1;
            end
        end
    endtask


    initial begin

        $display("========== IMEM TEST START ==========");

        addr = 0;   check(32'h00500113, "Instr @ 0");
        addr = 4;   check(32'h00A00193, "Instr @ 4");
        addr = 8;   check(32'h003100B3, "Instr @ 8");
        addr = 12;  check(32'h40310133, "Instr @ 12");
        addr = 16;  check(32'h0031F233, "Instr @ 16");
        addr = 20;  check(32'h0041F2B3, "Instr @ 20");
        addr = 24;  check(32'h00416333, "Instr @ 24");
        addr = 12;  check(32'h40310133, "Instr @ 12");
        addr = 32;  check(32'h0012B023, "Instr @ 32");
        addr = 36;  check(32'h0002B503, "Instr @ 36");
        addr = 40;  check(32'h0062BC23, "Instr @ 40");
        addr = 44;  check(32'h0182B583, "Instr @ 44");
        addr = 48;  check(32'h00520463, "Instr @ 48");
        addr = 52;  check(32'h00000063, "Instr @ 52");
        addr = 56;  check(32'h00A086B3, "Instr @ 56");

        $display("======================================");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED, Errors = %0d", errors);

        $finish;
    end

endmodule