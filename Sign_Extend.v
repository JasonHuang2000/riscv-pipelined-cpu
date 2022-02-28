`include "header.v"

module Sign_Extend
(
    ins_i,
    imm_o
);

// Ports
input   [31:0]  ins_i;
output  [31:0]  imm_o;

// registers
reg signed  [31:0]  imm;

assign imm_o = imm;

always @(ins_i) begin
    case (ins_i[6:0])
        `opcode_imm:    imm <= {{20{ins_i[31]}}, ins_i[31:20]};
        `opcode_lw:     imm <= {{20{ins_i[31]}}, ins_i[31:20]};
        `opcode_sw:     imm <= {{20{ins_i[31]}}, ins_i[31:25], ins_i[11:7]};
        `opcode_beq:    imm <= {{21{ins_i[31]}}, ins_i[7], ins_i[30:25], ins_i[11:8]};
        default:        imm <= 32'b0;
    endcase
end

endmodule