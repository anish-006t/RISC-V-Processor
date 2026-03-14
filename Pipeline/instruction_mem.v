`define IMEM_SIZE 4096

module instruction_mem (
    input  wire [63:0] addr,
    output wire [31:0] instr
);

    wire [11:0] relevant_addr = addr[11:0];
    reg  [7:0] memory [0:`IMEM_SIZE-1];
    integer i;  

    initial begin
        // Initialize memory to 0
        for (i = 0; i < `IMEM_SIZE; i = i + 1)
            memory[i] = 8'd0;

        // Load instructions from instructions.txt

        $readmemh("instructions.txt", memory);
    end

    assign instr = {
        memory[relevant_addr],
        memory[relevant_addr + 1],
        memory[relevant_addr + 2],
        memory[relevant_addr + 3]
    };

endmodule
