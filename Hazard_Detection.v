module Hazard_Detection
(
    rs1_i,
    rs2_i,
    rd_i,
    ctrlMemRead_i,
    ctrlPcWrite_o,
    stall_o,
    noop_o,
);

// ports
input   [4:0]   rs1_i;
input   [4:0]   rs2_i;
input   [4:0]   rd_i;
input           ctrlMemRead_i;
output          ctrlPcWrite_o;
output          stall_o;
output          noop_o;

// registers
reg ctrlPcWrite;
reg noop;
reg stall;

assign  ctrlPcWrite_o = ctrlPcWrite;
assign  noop_o = noop;
assign  stall_o = stall;

always @(ctrlMemRead_i or rs1_i or rs2_i or rd_i) begin
    if (ctrlMemRead_i == 1 && (rd_i == rs1_i || rd_i == rs2_i)) begin
        ctrlPcWrite = 0;
        noop = 1;
        stall = 1;
    end else begin
        ctrlPcWrite = 1;
        noop = 0;
        stall = 0;
    end
end
    
endmodule