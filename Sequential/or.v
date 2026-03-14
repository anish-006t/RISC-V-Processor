module or64(

    input wire [63:0] a,
    input wire [63:0] b,
    output wire [63:0] res
);
    genvar i;
    generate
        for (i=0;i<64;i=i+1)begin
            assign res[i] = a[i] | b[i];
        end
    endgenerate
endmodule
