module reg_file (
    input  wire clk,
    input  wire reset,
    input  wire [4:0] read_reg1,
    input  wire [4:0] read_reg2,
    input  wire [4:0] write_reg,
    input  wire [63:0] write_data,
    input  wire reg_write_en,
    output wire [63:0] read_data1,
    output wire [63:0] read_data2,
    input  wire dump_regs
);

    reg [63:0] regs [31:0];
    integer i;
    integer fd;
    reg dump_prev;

    // Async Reset and Write Logic
    //always @(posedge clk or posedge reset) begin // old
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 64'd0;
        end else begin
            if (reg_write_en && write_reg != 5'd0)
                regs[write_reg] <= write_data;
        end
    end

    // Read Logic (combinational)
    assign read_data1 = (read_reg1 == 5'd0) ? 64'd0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 5'd0) ? 64'd0 : regs[read_reg2];

    
    // Register Dump Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            dump_prev <= 1'b0;
        end else begin
            if (dump_regs && !dump_prev) begin
                fd = $fopen("register file.txt", "w");
                if (fd) begin
                    for (i = 0; i < 32; i = i + 1)
                        $fdisplay(fd, "%016h", regs[i]);
                    $fclose(fd);
                end
            end
            dump_prev <= dump_regs;
        end
    end

endmodule
