`timescale 1ns/1ps

module srl(
input wire [63:0] a,
input wire [5:0] shamt,
output wire [63:0] y
);

wire [63:0] s1,s2,s3,s4,s5;
genvar i;

// Stage 1
generate
for(i=0;i<64;i=i+1) begin:STAGE1
wire shifted;
assign shifted = (i==63) ? 1'b0 : a[i+1];
mux2 m1(.a(a[i]), .b(shifted), .sel(shamt[0]), .y(s1[i]));
end
endgenerate

//Stage 2
generate
for(i=0;i<64;i=i+1) begin:STAGE2
wire shifted;
assign shifted = (i>61) ? 1'b0 : s1[i+2];
mux2 m2(.a(s1[i]), .b(shifted), .sel(shamt[1]), .y(s2[i]));
end
endgenerate

// Stage 3
generate
for(i=0;i<64;i=i+1) begin:STAGE3
wire shifted;
assign shifted = (i>59) ? 1'b0 : s2[i+4];
mux2 m3(.a(s2[i]), .b(shifted), .sel(shamt[2]), .y(s3[i]));
end
endgenerate

// Stage 4
generate
for(i=0;i<64;i=i+1) begin:STAGE4
wire shifted;
assign shifted = (i>55) ? 1'b0 : s3[i+8];
mux2 m4(.a(s3[i]), .b(shifted), .sel(shamt[3]), .y(s4[i]));
end
endgenerate

// Stage 5
generate
for(i=0;i<64;i=i+1) begin:STAGE5
wire shifted;
assign shifted = (i>47) ? 1'b0 : s4[i+16];
mux2 m5(.a(s4[i]), .b(shifted), .sel(shamt[4]), .y(s5[i]));
end
endgenerate

// Stage 6
generate
for(i=0;i<64;i=i+1) begin:STAGE6
wire shifted;
assign shifted = (i>31) ? 1'b0 : s5[i+32];
mux2 m6(.a(s5[i]), .b(shifted), .sel(shamt[5]), .y(y[i]));
end
endgenerate

endmodule
