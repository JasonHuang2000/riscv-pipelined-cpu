`include "header.v"

module Pipeline_Registers
(
    clk_i,
    pc_i,
    stall_i,
    stall_all_i,
    flush_i,
    ins_i,
    ctrl_i,
    rs1Data_i,
    rs2Data_i,
    imm_i,
    ALUResult_i,
    MEMWriteData_i,
    MEMReadData_i,
    pc_o,
    ctrlEX_o,
    ctrlMEM_o,
    ctrlWB_o,
    insID_o,
    insEX_o,
    insMEM_o,
    insWB_o,
    rs1Data_o,
    rs2Data_o,
    imm_o,
    ALUResultMEM_o,
    ALUResultWB_o,
    MEMWriteData_o,
    MEMReadData_o,
);

// ports
input           clk_i;
input   [31:0]  pc_i;
input           stall_i;
input           stall_all_i;
input           flush_i;
input   [31:0]  ins_i;
input   [6:0]   ctrl_i;
input   [31:0]  rs1Data_i;
input   [31:0]  rs2Data_i;
input   [31:0]  imm_i;
input   [31:0]  ALUResult_i;
input   [31:0]  MEMWriteData_i;
input   [31:0]  MEMReadData_i;

output  [31:0]  pc_o;
output  [6:0]   ctrlEX_o;
output  [6:0]   ctrlMEM_o;
output  [6:0]   ctrlWB_o;
output  [31:0]  insID_o;
output  [31:0]  insEX_o;
output  [31:0]  insMEM_o;
output  [31:0]  insWB_o;
output  [31:0]  rs1Data_o;
output  [31:0]  rs2Data_o;
output  [31:0]  imm_o;
output  [31:0]  ALUResultMEM_o;
output  [31:0]  ALUResultWB_o;
output  [31:0]  MEMWriteData_o;
output  [31:0]  MEMReadData_o;

// register
reg     [31:0]  pc;
reg     [6:0]   ctrl        [3:0];
reg     [31:0]  ins         [3:0];
reg     [31:0]  rs1Data;
reg     [31:0]  rs2Data;
reg     [31:0]  imm;
reg     [31:0]  ALUResult   [3:0];
reg     [31:0]  MEMWriteData;
reg     [31:0]  MEMReadData;

// read data
assign  pc_o = pc;
assign  ctrlEX_o = ctrl[`ID_EX];
assign  ctrlMEM_o = ctrl[`EX_MEM];
assign  ctrlWB_o = ctrl[`MEM_WB];
assign  insID_o = ins[`IF_ID];
assign  insEX_o = ins[`ID_EX];
assign  insMEM_o = ins[`EX_MEM];
assign  insWB_o = ins[`MEM_WB];
assign  rs1Data_o = rs1Data;
assign  rs2Data_o = rs2Data;
assign  imm_o = imm;
assign  ALUResultMEM_o = ALUResult[`EX_MEM];
assign  ALUResultWB_o = ALUResult[`MEM_WB];
assign  MEMWriteData_o = MEMWriteData;
assign  MEMReadData_o = MEMReadData;

// write data
always @(posedge clk_i) begin

    if (!stall_all_i) begin
        pc <= stall_i == 1 ? pc : pc_i;

        // control signals
        ctrl[`ID_EX] <= ctrl_i;
        ctrl[`EX_MEM] <= ctrl[`ID_EX];
        ctrl[`MEM_WB] <= ctrl[`EX_MEM];

        // instructions
        ins[`IF_ID] <= stall_i == 1 ? ins[`IF_ID] : (flush_i == 1 ? 32'b0 : ins_i);
        ins[`ID_EX] <= ins[`IF_ID];
        ins[`EX_MEM] <= ins[`ID_EX];
        ins[`MEM_WB] <= ins[`EX_MEM];

        // register data
        rs1Data <= rs1Data_i;
        rs2Data <= rs2Data_i;

        // imm (after sign extension)
        imm <= imm_i;

        // ALU result
        ALUResult[`EX_MEM] <= ALUResult_i;
        ALUResult[`MEM_WB] <= ALUResult[`EX_MEM];

        // DM write/read data
        MEMWriteData <= MEMWriteData_i;
        MEMReadData <= MEMReadData_i;
    end
end
    
endmodule