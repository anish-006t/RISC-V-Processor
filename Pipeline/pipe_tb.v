`timescale 1ns/1ps
`include "pipe_processor.v"
module pipe_tb;
    reg clk;
    reg reset;
    pipe_processor uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;
    integer i;
    integer cycle_count;
    integer outfile;
    integer pass_flag;
    integer instr_file;
    integer instr_bytes;
    integer read_status;
    reg [1023:0] line_buf;

    initial begin
        $dumpfile("pipe_tb.vcd");
        $dumpvars(0, pipe_tb);
    end

    initial begin
        clk = 0;
        reset = 1;
        cycle_count = 0;
        pass_flag = 1;
        instr_bytes = 0;

        // (EOF treated as HALT)
        instr_file = $fopen("instructions.txt", "r");
        if (instr_file != 0) begin
            while (!$feof(instr_file)) begin
                read_status = $fgets(line_buf, instr_file);
                if (read_status != 0) begin
                    instr_bytes = instr_bytes + 1;
                end
            end
            $fclose(instr_file);
        end

        #20 reset = 0;

        fork
            begin : RUN_LOOP
                while (1) begin
                    if (instr_bytes > 0 && uut.pc_current >= instr_bytes) begin
                        cycle_count = cycle_count + 1;
                        $display("EOF reached at cycle %0d", cycle_count);
                        disable RUN_LOOP;
                    end

                    #10;
                    cycle_count = cycle_count + 1;

                    // Timeout
                    if (cycle_count > 2000) begin
                        $display("TIMEOUT: No HALT instruction reached.");
                        disable RUN_LOOP;
                    end
                end
            end
        join

        outfile = $fopen("register_file.txt", "w");

        for (i = 0; i < 32; i = i + 1) begin
            $fdisplay(outfile, "%016h", uut.RF.regs[i]);
        end

        $fdisplay(outfile, "%0d", cycle_count);

        $fclose(outfile);

        $finish;
    end

endmodule