`timescale 1ns/1ps

`include "pc.v"
`include "pc_plus_4.v"
`include "branch_targ_adder.v"
`include "instruction_mem.v"
`include "reg_file.v"
`include "control.v"
`include "alu_control.v"
`include "alu.v"
`include "imm_gen.v"
`include "data_mem.v"
`include "mux.v"
`include "processor.v"

module seq_tb;

    reg clk;
    reg reset;
    reg dump_regs;

    integer cycle_count;
    integer fd;

    processor uut (
        .clk(clk),
        .reset(reset),
        .dump_regs(dump_regs)
    );

 
    // Clock (10 ns period)
    always #5 clk = ~clk;

    initial begin
      
        clk = 0;
        reset = 1;
        dump_regs = 0;
        cycle_count = 0;

        // Hold reset for 20 ns
        #20;
        reset = 0;

        // Run until processor halts (instruction == 0)
        cycle_count = 0;

        while (uut.instruction != 32'b0) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end
        // Final register dump
        dump_regs = 1;
        @(posedge clk);  // allow time for dump to occur
        @(posedge clk);  // ensure dump completes before finishing
        dump_regs = 0;

        // Append cycle count to file
        fd = $fopen("register_file.txt", "a");

        if (fd) begin
            $fdisplay(fd, "%0d", cycle_count);
            $fclose(fd);
        end

        $finish;
    end

endmodule