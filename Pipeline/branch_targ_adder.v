module branch_targ_adder (
    input  wire [63:0] pc,
    input  wire [63:0] imm,
    output wire [63:0] branch_target
);
    assign branch_target = pc + imm; 
endmodule