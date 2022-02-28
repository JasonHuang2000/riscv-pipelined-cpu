module Branch_PC (
    offset_i,
    pcCur_i,
    pcBranch_o
);

// ports
input   [31:0]  offset_i;
input   [31:0]  pcCur_i;
output  [31:0]  pcBranch_o;

// reg
reg     [31:0]  pcBranch;

assign pcBranch_o = pcBranch;

always @(offset_i or pcCur_i) begin
    pcBranch = (offset_i << 1) + pcCur_i;
end

endmodule