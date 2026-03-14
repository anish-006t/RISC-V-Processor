module hazard_detection_unit(
    input wire idex_MemRead,
    input wire [4:0] idex_rd,
    input wire [4:0] ifid_rs1,
    input wire [4:0] ifid_rs2,
    input wire [6:0] ifid_opcode,
    output wire load_use_hazard
);

localparam OPC_RTYPE   = 7'b0110011;
localparam OPC_I_ARITH = 7'b0010011;
localparam OPC_LOAD    = 7'b0000011;
localparam OPC_STORE   = 7'b0100011;
localparam OPC_BRANCH  = 7'b1100011;

wire rs1_used;
wire rs2_used;

assign rs1_used = (ifid_opcode == OPC_RTYPE)   ||
                  (ifid_opcode == OPC_I_ARITH) ||
                  (ifid_opcode == OPC_LOAD)    ||
                  (ifid_opcode == OPC_STORE)   ||
                  (ifid_opcode == OPC_BRANCH);

assign rs2_used = (ifid_opcode == OPC_RTYPE)  ||
                  (ifid_opcode == OPC_STORE)  ||
                  (ifid_opcode == OPC_BRANCH);

assign load_use_hazard = idex_MemRead &&
                         (idex_rd != 5'd0) &&
                         ((rs1_used && (idex_rd == ifid_rs1)) ||
                          (rs2_used && (idex_rd == ifid_rs2)));

endmodule
