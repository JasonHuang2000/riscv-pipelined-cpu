`include "header.v"

module ALU (
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o,
);

// Ports
input  signed [31:0]  data1_i;
input  signed [31:0]  data2_i;
input   [2:0]   ALUCtrl_i;
output signed [31:0]  data_o;

reg signed [31:0]  reg_o;

// Output result
always @(data1_i or data2_i or ALUCtrl_i) begin
    case (ALUCtrl_i)
        `ALU_AND: reg_o = data1_i & data2_i;
        `ALU_XOR: reg_o = data1_i ^ data2_i;
        `ALU_SLL: reg_o = data1_i << data2_i;
        `ALU_ADD: reg_o = data1_i + data2_i;
        `ALU_SUB: reg_o = data1_i - data2_i;
        `ALU_MUL: reg_o = data1_i * data2_i;
        `ALU_SRA: reg_o = data1_i >>> data2_i[4:0];
    endcase
end

assign data_o = reg_o;

endmodule