// mux for 64-bit inputs


module mux_2to1_64  #(parameter WIDTH = 64) (

    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire sel,
    output wire [WIDTH-1:0] out
);

    assign out = sel ? in1 : in0;

endmodule