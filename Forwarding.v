`include "header.v"

module Forwarding
(
    rs1_i,
    rs2_i,
    rdMEM_i,
    rdWB_i,
    RegWriteMEM_i,
    RegWriteWB_i,
    rs1Data_i,
    rs2Data_i,
    WriteData_i,
    ALUResultMEM_i,
    MUXOut1_o,
    MUXOut2_o,
);

// ports
input   [4:0]   rs1_i;
input   [4:0]   rs2_i;
input   [4:0]   rdMEM_i;
input   [4:0]   rdWB_i;
input           RegWriteMEM_i;
input           RegWriteWB_i;
input   [31:0]  rs1Data_i;
input   [31:0]  rs2Data_i;
input   [31:0]  WriteData_i;
input   [31:0]  ALUResultMEM_i;
output  [31:0]  MUXOut1_o;
output  [31:0]  MUXOut2_o;

// wires
wire    [1:0]   forwardA_o;
wire    [1:0]   forwardB_o;

// registers
reg     [1:0]   forwardA;
reg     [1:0]   forwardB;
reg     [31:0]  MUXOut1;
reg     [31:0]  MUXOut2;

// read from reg
assign  forwardA_o = forwardA;
assign  forwardB_o = forwardB;
assign  MUXOut1_o = MUXOut1;
assign  MUXOut2_o = MUXOut2;

// EX & MEM hazard
always @(rs1_i or rs2_i or rdMEM_i or rdWB_i or RegWriteMEM_i or RegWriteWB_i) begin
    forwardA <= `src_ID_EX;
    forwardB <= `src_ID_EX;
    if (RegWriteMEM_i == 1 && rdMEM_i != 0 && rdMEM_i == rs1_i) begin
        forwardA <= `src_EX_MEM;
    end
    if (RegWriteMEM_i == 1 && rdMEM_i != 0 && rdMEM_i == rs2_i) begin
        forwardB <= `src_EX_MEM;
    end
    if (RegWriteWB_i == 1 && rdWB_i != 0 && !(RegWriteMEM_i == 1 && rdMEM_i != 0 && rdMEM_i == rs1_i) && rdWB_i == rs1_i) begin
        forwardA <= `src_MEM_WB;
    end
    if (RegWriteWB_i == 1 && rdWB_i != 0 && !(RegWriteMEM_i == 1 && rdMEM_i != 0 && rdMEM_i == rs2_i) && rdWB_i == rs2_i) begin
        forwardB <= `src_MEM_WB;
    end
end

// MUXes
always @(forwardA_o or rs1Data_i or ALUResultMEM_i or WriteData_i) begin
    case (forwardA_o)
        `src_ID_EX:  MUXOut1 <= rs1Data_i;
        `src_EX_MEM: MUXOut1 <= ALUResultMEM_i;
        `src_MEM_WB: MUXOut1 <= WriteData_i;
        default:     MUXOut1 <= 32'b0;
    endcase 
end
always @(forwardB_o or rs2Data_i or ALUResultMEM_i or WriteData_i) begin
    case (forwardB_o)
        `src_ID_EX:  MUXOut2 <= rs2Data_i;
        `src_EX_MEM: MUXOut2 <= ALUResultMEM_i;
        `src_MEM_WB: MUXOut2 <= WriteData_i;
        default:     MUXOut2 <= 32'b0;
    endcase 
end

endmodule