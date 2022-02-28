`include "header.v"

module ALU_Control (
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

// Ports
input   [9:0]   funct_i;
input   [1:0]   ALUOp_i;
output  [2:0]   ALUCtrl_o;

// registers
reg     [2:0]   ALUCtrl;

assign  ALUCtrl_o = ALUCtrl;

// Output signal
always @(funct_i or ALUOp_i) begin
    case (ALUOp_i)
        `ALU_opcode_r: 
            case (funct_i)
                `funct_AND: ALUCtrl = `ALU_AND;
                `funct_XOR: ALUCtrl = `ALU_XOR;
                `funct_SLL: ALUCtrl = `ALU_SLL;
                `funct_ADD: ALUCtrl = `ALU_ADD;
                `funct_SUB: ALUCtrl = `ALU_SUB;
                `funct_MUL: ALUCtrl = `ALU_MUL;
            endcase
        `ALU_opcode_imm: 
            case (funct_i[2:0])
                `funct3_ADDI: ALUCtrl = `ALU_ADD;
                `funct3_SRAI: ALUCtrl = `ALU_SRA;
            endcase
        `ALU_opcode_lw_sw: 
            ALUCtrl = `ALU_ADD;
        `ALU_opcode_beq: 
            ALUCtrl = `ALU_SUB;
    endcase
end

endmodule