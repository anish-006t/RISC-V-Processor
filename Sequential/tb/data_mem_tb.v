// tb_data_mem_optionB.v
// Testbench for original data_mem.v (combinational read, synchronous write)
`timescale 1ns/1ps
`define DMEM_SIZE 1024

module data_mem_tb;

    reg         clk;
    reg         reset;
    reg  [63:0] address;
    reg  [63:0] write_data;
    reg         MemRead;
    reg         MemWrite;
    wire [63:0] read_data;

    // Instantiate DUT
    data_mem uut (
        .clk(clk),
        .reset(reset),
        .address(address),
        .write_data(write_data),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .read_data(read_data)
    );

    // Clock generator: 10 ns period
    always #5 clk = ~clk;

    // Helper task: perform a write, wait one full cycle
    task write_word;
        input [63:0] addr;
        input [63:0] data;
        begin
            @(negedge clk);       // setup before posedge
            address    = addr;
            write_data = data;
            MemWrite   = 1;
            @(posedge clk);       // write occurs here
            @(negedge clk);       // hold for a full cycle
            MemWrite   = 0;
        end
    endtask

    // Helper task: perform a read one cycle after write
    task read_word;
        input [63:0] addr;
        reg [63:0] expected;
        begin
            @(negedge clk);
            address = addr;
            MemRead = 1;
            @(posedge clk);       // allow one posedge for data to appear
            #1;
            $display("Read @%04h -> %016h", address[9:0], read_data);
            total_tests = total_tests + 1;
            MemRead = 0;
        end
    endtask

    integer total_tests = 0;
    integer failed_tests = 0;

    initial begin
        $dumpfile("tb/data_mem_tb.vcd");
        $dumpvars(0, data_mem_tb);

        $display("\n==== Testing data_mem.v (Option B timing) ====\n");
        clk = 0;
        reset = 1;
        MemRead = 0;
        MemWrite = 0;
        address = 0;
        write_data = 0;

        // Hold reset for two cycles
        repeat (2) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // ✅ Test 1: simple write/read pair
        write_word(64'h0010, 64'h1122334455667788);
        read_word (64'h0010);

        // ✅ Test 2: another address
        write_word(64'h0020, 64'hAABBCCDDEEFF0011);
        read_word (64'h0020);

        // ✅ Test 3: near top of memory (wrap around)
        write_word(64'h03F8, 64'hDEADBEEFCAFEBABE);
        read_word (64'h03F8);

        // ✅ Test 4: verify reset clears memory
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);
        address = 64'h0010;
        MemRead = 1;
        #1;
        $display("After reset, read @0x10 -> %016h (expect 0)", read_data);
        MemRead = 0;

        $display("\n==== Test completed successfully ====\n");
        $display("\n==== Test Summary ====\n");
        $display("PASSED: %0d", total_tests - failed_tests);
        $display("FAILED: %0d", failed_tests);
        $display("Total:  %0d", total_tests);
        $finish;
    end

endmodule