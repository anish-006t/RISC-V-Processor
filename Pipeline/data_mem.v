`define DMEM_SIZE 1024

module data_mem (
    input wire clk,
    input wire reset,
    input wire [63:0] address,
    input wire [63:0] write_data,
    input wire MemRead,
    input wire MemWrite,
    output wire [63:0] read_data
);

    reg [7:0] memory [0:`DMEM_SIZE-1];
    wire [9:0] addr = address[9:0];
    integer i;

   
    always @(posedge clk) begin
        if (reset) begin
            for (i=0;i< `DMEM_SIZE; i=i+1)
                memory[i] <= 8'd0;
        end
        else if (MemWrite) begin
            // Big-endian write
            memory[addr] <= write_data[63:56];
            memory[addr+1] <= write_data[55:48];
            memory[addr+2] <= write_data[47:40];
            memory[addr+3] <= write_data[39:32];
            memory[addr+4] <= write_data[31:24];
            memory[addr+5] <= write_data[23:16];
            memory[addr+6] <= write_data[15:8];
            memory[addr+7] <= write_data[7:0];
        end
    end
// Big-endian read
    assign read_data = (MemRead) ? {
        memory[addr],
        memory[addr+1],
        memory[addr+2],
        memory[addr+3],
        memory[addr+4],
        memory[addr+5],
        memory[addr+6],
        memory[addr+7]
    } : 64'd0;

endmodule