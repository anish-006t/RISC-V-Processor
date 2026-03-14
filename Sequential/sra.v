module sra(
input wire [63:0] a,
input wire [5:0] shamt,
output wire [63:0] y
);

wire [63:0] s1,s2,s3,s4,s5;
wire sign = a[63];
genvar i;

//Stage 1
generate
for(i=0;i<64;i=i+1) begin:STAGE1
wire t1;
wire ge1 = (i+1 < 64);
mux2 mz1(.a(sign),.b(a[i+1]),.sel(ge1),.y(t1));
mux2 m1(.a(a[i]),.b(t1),.sel(shamt[0]),.y(s1[i]));
end
endgenerate

//Stage 2
generate
for(i=0;i<64;i=i+1) begin:STAGE2
wire t2;
wire ge2 = (i+2 < 64);
mux2 mz2(.a(sign),.b(s1[i+2]),.sel(ge2),.y(t2));
mux2 m2(.a(s1[i]),.b(t2),.sel(shamt[1]),.y(s2[i]));
end
endgenerate
// Stage 3
generate
for(i=0;i<64;i=i+1) begin:STAGE3
wire t3;
wire ge4 = (i+4 < 64);
mux2 mz3(.a(sign),.b(s2[i+4]),.sel(ge4),.y(t3));
mux2 m3(.a(s2[i]),.b(t3),.sel(shamt[2]),.y(s3[i]));
end
endgenerate

// Stage 4
generate
for(i=0;i<64;i=i+1) begin:STAGE4
wire t4;
wire ge8 = (i+8 < 64);
mux2 mz4(.a(sign),.b(s3[i+8]),.sel(ge8),.y(t4));
mux2 m4(.a(s3[i]),.b(t4),.sel(shamt[3]),.y(s4[i]));
end
endgenerate

// Stage 5
generate
for(i=0;i<64;i=i+1) begin:STAGE5
wire t5;
wire ge16 = (i+16 < 64);
mux2 mz5(.a(sign),.b(s4[i+16]),.sel(ge16),.y(t5));
mux2 m5(.a(s4[i]),.b(t5),.sel(shamt[4]),.y(s5[i]));
end
endgenerate

// Stage 6
generate
for(i=0;i<64;i=i+1) begin:STAGE6
wire t6;
wire ge32 = (i+32 < 64);
mux2 mz6(.a(sign),.b(s5[i+32]),.sel(ge32),.y(t6));
mux2 m6(.a(s5[i]),.b(t6),.sel(shamt[5]),.y(y[i]));
end
endgenerate

endmodule
