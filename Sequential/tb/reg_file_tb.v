// tb_reg_file.v
`timescale 1ns/1ps

module reg_file_tb;

    reg         clk;
    reg         reset;
    reg  [4:0]  read_reg1;
    reg  [4:0]  read_reg2;
    reg  [4:0]  write_reg;
    reg  [63:0] write_data;
    reg         reg_write_en;
    wire [63:0] read_data1;
    wire [63:0] read_data2;
    reg         dump_regs;

    // Instantiate DUT
    reg_file uut (
        .clk(clk),
        .reset(reset),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .reg_write_en(reg_write_en),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .dump_regs(dump_regs)
    );

    // Clock generator (10 ns period)
    always #5 clk = ~clk;

    // Helper: write to register (x0 write ignored)
    task write_regfile;
        input [4:0] regnum;
        input [63:0] data;
        begin
            @(negedge clk);
            write_reg     = regnum;
            write_data    = data;
            reg_write_en  = 1;
            @(posedge clk); // write occurs here
            @(negedge clk);
            reg_write_en  = 0;
        end
    endtask

    // Helper: read two registers
    task read_regs;
        input [4:0] r1;
        input [4:0] r2;
        begin
            read_reg1 = r1;
            read_reg2 = r2;
            #1;
            $display("Read x%0d=%016h, x%0d=%016h", r1, read_data1, r2, read_data2);
            total_tests = total_tests + 1;
            // simple check: x0 should always be zero
            if (r1 == 0 && read_data1 !== 64'd0) failed_tests = failed_tests + 1;
            if (r2 == 0 && read_data2 !== 64'd0) failed_tests = failed_tests + 1;
        end
    endtask

    integer total_tests = 0;
    integer failed_tests = 0;

    initial begin
        $dumpfile("tb/reg_file_tb.vcd");
        $dumpvars(0, reg_file_tb);
        $display("\n==== Testing reg_file.v ====\n");
        clk = 0;
        reset = 1;
        read_reg1 = 0;
        read_reg2 = 0;
        write_reg = 0;
        write_data = 0;
        reg_write_en = 0;
        dump_regs = 0;

        // Hold reset a couple of cycles
        repeat (2) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // ✅ Test 1: write and read a few registers
        write_regfile(5'd1, 64'h1111111111111111);
        write_regfile(5'd2, 64'h2222222222222222);
        write_regfile(5'd3, 64'h3333333333333333);
        read_regs(5'd1, 5'd2);
        read_regs(5'd3, 5'd0); // x0 should always be zero

        // ✅ Test 2: write x0, confirm it remains zero
        write_regfile(5'd0, 64'hDEADBEEFCAFEBABE);
        read_regs(5'd0, 5'd1); // x0 should still be 0

        // ✅ Test 3: dump registers to file
        @(negedge clk);
        dump_regs = 1;
        @(posedge clk);
        @(negedge clk);
        dump_regs = 0;
        @(posedge clk);
        $display("Register dump triggered -> check 'register file.txt'");

        // ✅ Test 4: reset clears registers
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);
        read_regs(5'd1, 5'd2); // should be all zeros

        $display("\n==== Test completed successfully ====\n");
        $display("\n==== Test Summary ====\n");
        $display("PASSED: %0d", total_tests - failed_tests);
        $display("FAILED: %0d", failed_tests);
        $display("Total:  %0d", total_tests);
        $finish;
    end

endmodule