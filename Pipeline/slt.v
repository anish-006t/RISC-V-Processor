module slt64(
  input wire [63:0] a,
  input wire [63:0] b,
  input wire [63:0] sub_out,
  input wire sub_overflow,
  output wire [63:0] res
);

  assign res = {63'b0, (sub_out[63]^sub_overflow)};
endmodule