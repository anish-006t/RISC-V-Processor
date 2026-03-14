module pc_plus_4 (
    input wire [63:0] pc_in,

    output wire [63:0] pc_out
);
    assign pc_out = pc_in + 64'd4;
endmodule
