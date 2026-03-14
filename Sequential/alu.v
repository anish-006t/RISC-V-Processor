`timescale 1ns/1ps

`include "mux2.v"

`include "sll.v"
`include "srl.v"
`include "sra.v"
`include "and.v"
`include "or.v"
`include "xor.v"
`include "slt.v"
`include "sltu.v"


module fa(
    input  a1,
    input  b1,
    input  cin,
    output sum,
    output cout
);

    
    assign sum = a1 ^ b1 ^ cin;
    assign cout = (a1 & b1)| (a1&cin)|(b1&cin);
endmodule

module alu_64_bit(
    input [63:0] a, 
    input [63:0] b,
    input [3:0] opcode,
    output reg [63:0] result,
    output wire cout,
    output wire carry_flag,
    output wire overflow_flag,
    output wire zero_flag

);


    wire[63:0] add_out, sub_out;

    wire add_cout, sub_cout;
    wire add_overflow, sub_overflow;

    // Addition

    wire [64:0] carry_add;
    assign carry_add[0] = 1'b0;

    genvar i;
    generate
        for (i=0;i<64;i=i+1) begin: ADDER
            fa fa_add(
            
                .a1(a[i]),
                .b1(b[i]),
                .cin(carry_add[i]),
                .sum(add_out[i]),
                .cout(carry_add[i+1])
            );
        end
    endgenerate

    assign add_cout = carry_add[64];
    assign add_overflow = carry_add[64]^carry_add[63];

    // Subtraction

    wire [64:0] carry_sub;
    assign carry_sub[0] = 1'b1; 

    generate
        for (i=0;i<64;i=i+1) begin: SUBTRACTOR
            fa fa_sub(
                .a1(a[i]),
                .b1(~b[i]),
                .cin(carry_sub[i]),
                .sum(sub_out[i]),
                .cout(carry_sub[i+1])
            );
        end

    endgenerate

    wire[63:0] and_out, or_out, xor_out;
    wire[63:0] sll_out, srl_out, sra_out;
    wire[63:0] slt_out, sltu_out;

    assign sub_cout = carry_sub[64];

    assign sub_overflow = carry_sub[64]^carry_sub[63];

    and64 u_and (.a(a),.b(b),.res(and_out));
    or64 u_or (.a(a),.b(b),.res(or_out));
    xor64 u_xor (.a(a),.b(b),.res(xor_out));


    sll u_sll(.a(a),.shamt(b[5:0]),.y(sll_out));
    srl u_srl(.a(a),.shamt(b[5:0]),.y(srl_out));
    sra u_sra(.a(a),.shamt(b[5:0]),.y(sra_out));


    slt64 u_slt(.a(a), .b(b), .sub_out(sub_out), .sub_overflow(sub_overflow), .res(slt_out));
    sltu64 u_sltu (.a(a), .b(b), .sub_cout(sub_cout), .res(sltu_out));


    always @(*) begin
        case (opcode)
            4'b0000: begin
                result = add_out;
            end
            4'b0001: begin
                result = sll_out;
            end
            4'b0010: begin
                result = slt_out;
            end
            4'b0011: begin
                result = sltu_out;
            end
            4'b0100: begin
                result = xor_out;
            end
            4'b0101: begin
                result = srl_out;
            end
            4'b0110: begin
                result = or_out;
            end
            4'b0111: begin
                result = and_out;
            end
            4'b1000: begin
                result = sub_out;
            end
            4'b1101: begin
                result = sra_out;
            end
            default: begin
                result = 64'b0;
            end
        endcase
    end

    assign carry_flag =(opcode==4'b0000)?add_cout :
                       (opcode==4'b1000)?~sub_cout:
                       1'b0;

    assign overflow_flag = (opcode == 4'b0000) ? add_overflow :
                           (opcode == 4'b1000) ? sub_overflow : 1'b0;

    assign zero_flag = (result == 64'b0) ? 1'b1 : 1'b0;

    assign cout = carry_flag;
endmodule

