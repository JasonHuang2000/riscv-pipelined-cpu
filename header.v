// opcode
`define opcode_r 7'b0110011
`define opcode_imm 7'b0010011
`define opcode_lw 7'b0000011
`define opcode_sw 7'b0100011
`define opcode_beq 7'b1100011

// control code 
// RegWrite - Mem2Reg - MemRead - MemWrite - ALUOp - ALUSrc - Branch
`define ctrl_r 8'b10001000
`define ctrl_imm 8'b10001110
`define ctrl_lw 8'b11100010
`define ctrl_sw 8'b00010010
`define ctrl_beq 8'b00000101
`define ctrl_noop 8'b00000000

// ALU opcode
`define ALU_opcode_r 2'b10
`define ALU_opcode_imm 2'b11
`define ALU_opcode_lw_sw 2'b00
`define ALU_opcode_beq 2'b01

// R-type function codes
`define funct_AND 10'b0000000111
`define funct_XOR 10'b0000000100
`define funct_SLL 10'b0000000001
`define funct_ADD 10'b0000000000
`define funct_SUB 10'b0100000000
`define funct_MUL 10'b0000001000

// I-type function codes
`define funct3_ADDI 3'b000
`define funct3_SRAI 3'b101

// ALU control codes
`define ALU_AND 3'b000
`define ALU_XOR 3'b001
`define ALU_SLL 3'b010
`define ALU_ADD 3'b011
`define ALU_SUB 3'b100
`define ALU_MUL 3'b101
`define ALU_SRA 3'b110

// Pipeline registers
`define IF_ID 0
`define ID_EX 1
`define EX_MEM 2
`define MEM_WB 3

// ALU source
`define src_ID_EX 2'b00
`define src_EX_MEM 2'b10
`define src_MEM_WB 2'b01