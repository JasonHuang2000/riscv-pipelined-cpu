`include "header.v"

module Control (
    Op_i,
    noop_i,
    ctrl_o
);

// ports
input   [6:0]   Op_i;
input           noop_i;
output  [7:0]   ctrl_o;

// registers
reg     [7:0]   ctrl;

// read data
assign  ctrl_o = ctrl;

// write data
always @(Op_i or noop_i) begin
    if (noop_i) begin
        ctrl <= `ctrl_noop;
    end else begin
        case (Op_i)
            `opcode_r:      ctrl <= `ctrl_r;
            `opcode_imm:    ctrl <= `ctrl_imm;
            `opcode_lw:     ctrl <= `ctrl_lw;
            `opcode_sw:     ctrl <= `ctrl_sw;
            `opcode_beq:    ctrl <= `ctrl_beq;
            default:        ctrl <= `ctrl_noop;
        endcase
    end
end

endmodule