module pc_tb;
    reg clk;
    reg reset;
    reg [63:0] pc_in;
    wire [63:0] pc_out;
    integer total_tests = 0;
    integer failed_tests = 0;

    pc dut (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb/pc_tb.vcd");
        $dumpvars(0, pc_tb);

        clk = 0;
        reset = 1;
        pc_in = 64'd0;

        #10;
        reset = 0;

        pc_in = 64'd4;
        #10;
        total_tests = total_tests + 1;
        if (pc_out !== pc_in) failed_tests = failed_tests + 1;

        pc_in = 64'd8;
        #10;
        total_tests = total_tests + 1;
        if (pc_out !== pc_in) failed_tests = failed_tests + 1;

        pc_in = 64'd12;
        #10;
        total_tests = total_tests + 1;
        if (pc_out !== pc_in) failed_tests = failed_tests + 1;

        $display("\n==== Test Summary ====\n");
        $display("PASSED: %0d", total_tests - failed_tests);
        $display("FAILED: %0d", failed_tests);
        $display("Total:  %0d", total_tests);
        $finish;
    end

    initial begin
        $monitor("Time=%0t | reset=%b | pc_in=%d | pc_out=%d", $time, reset, pc_in, pc_out);
    end
endmodule