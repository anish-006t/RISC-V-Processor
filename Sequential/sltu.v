module sltu64(
  input wire [63:0] a,
  input wire [63:0] b,
  input wire sub_cout,
  output wire [63:0] res
);

  assign res = {63'b0, ~sub_cout};
endmodule
