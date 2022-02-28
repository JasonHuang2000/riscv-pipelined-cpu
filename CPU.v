module CPU (
    clk_i, 
    rst_i,
    start_i,
    mem_data_i, 
    mem_ack_i,     
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o
);

// Ports
input           clk_i;
input           rst_i;
input           start_i;

input   [255:0] mem_data_i;
input           mem_ack_i;
output  [255:0] mem_data_o;
output  [31:0]  mem_addr_o;
output          mem_enable_o;
output          mem_write_o;

// wires
wire    [31:0]  pc_IF;
wire    [31:0]  pc_ID;
wire    [31:0]  pc_new;
wire    [31:0]  pc_branch;
wire    [31:0]  pc_result;
wire    [31:0]  four;

wire    [31:0]  ins_IF;
wire    [31:0]  ins_ID;
wire    [31:0]  ins_EX;
wire    [31:0]  ins_MEM;
wire    [31:0]  ins_WB;

wire    [7:0]   ctrl_ID;
wire    [6:0]   ctrl_EX;
wire    [6:0]   ctrl_MEM;
wire    [6:0]   ctrl_WB;

wire    [31:0]  rs1Data_ID;
wire    [31:0]  rs2Data_ID;
wire    [31:0]  rs1Data_EX;
wire    [31:0]  rs2Data_EX;

wire    [31:0]  imm_ID;
wire    [31:0]  imm_EX;

wire    [2:0]   ALU_ctrl;
wire    [31:0]  MUX_in1;
wire    [31:0]  ALU_in1;
wire    [31:0]  ALU_in2;
wire    [31:0]  ALUResult_EX;
wire    [31:0]  ALUResult_MEM;
wire    [31:0]  ALUResult_WB;

wire    [31:0]  MEMWriteData;
wire    [31:0]  MEMReadData_MEM;
wire    [31:0]  MEMReadData_WB;

wire    [31:0]  WBData;

wire            rs1rs2Equal;

wire            noop;
wire            PCWrite;
wire            stall;
wire            stall_all;
wire            flush;

assign  four = 32'd4;
assign  pc_new = pc_IF + four;
assign  rs1rs2Equal = rs1Data_ID == rs2Data_ID ? 1 : 0;
assign  flush = ctrl_ID[0] & rs1rs2Equal;

Instruction_Memory Instruction_Memory (
    .addr_i         (pc_IF),
    .instr_o        (ins_IF)
);

MUX32 MUX_PC (
    .data1_i        (pc_new),
    .data2_i        (pc_branch),
    .select_i       (flush),
    .data_o         (pc_result)
);

PC PC (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .start_i        (start_i),
    .stall_i        (stall | stall_all),
    .PCWrite_i      (PCWrite),
    .pc_i           (pc_result),
    .pc_o           (pc_IF)
);

Control Control (
    .Op_i           (ins_ID[6:0]),
    .noop_i         (noop),
    .ctrl_o         (ctrl_ID)
);

Hazard_Detection Hazard_Detection (
    .rs1_i          (ins_ID[19:15]),
    .rs2_i          (ins_ID[24:20]),
    .rd_i           (ins_EX[11:7]),
    .ctrlMemRead_i  (ctrl_EX[4]),
    .ctrlPcWrite_o  (PCWrite),
    .stall_o        (stall),
    .noop_o         (noop)
);

Branch_PC Branch_PC (
    .offset_i       (imm_ID),
    .pcCur_i        (pc_ID),
    .pcBranch_o     (pc_branch)
);

Registers Registers (
    .clk_i          (clk_i),
    .RS1addr_i      (ins_ID[19:15]),
    .RS2addr_i      (ins_ID[24:20]),
    .RDaddr_i       (ins_WB[11:7]), 
    .RDdata_i       (WBData),
    .RegWrite_i     (ctrl_WB[6]), 
    .RS1data_o      (rs1Data_ID), 
    .RS2data_o      (rs2Data_ID) 
);

Sign_Extend Sign_Extend (
    .ins_i          (ins_ID),
    .imm_o          (imm_ID)
);

ALU_Control ALU_Control (
    .funct_i        ({ins_EX[31:25], ins_EX[14:12]}),
    .ALUOp_i        (ctrl_EX[2:1]),
    .ALUCtrl_o      (ALU_ctrl)
);

MUX32 ALU_MUX (
    .data1_i        (MUX_in1),
    .data2_i        (imm_EX),
    .select_i       (ctrl_EX[0]),
    .data_o         (ALU_in2)
);

ALU ALU (
    .data1_i        (ALU_in1),
    .data2_i        (ALU_in2),
    .ALUCtrl_i      (ALU_ctrl),
    .data_o         (ALUResult_EX)
);

Forwarding Forwarding (
    .rs1_i          (ins_EX[19:15]),
    .rs2_i          (ins_EX[24:20]),
    .rdMEM_i        (ins_MEM[11:7]),
    .rdWB_i         (ins_WB[11:7]),
    .RegWriteMEM_i  (ctrl_MEM[6]),
    .RegWriteWB_i   (ctrl_WB[6]),
    .rs1Data_i      (rs1Data_EX),
    .rs2Data_i      (rs2Data_EX),
    .WriteData_i    (WBData),
    .ALUResultMEM_i (ALUResult_MEM),
    .MUXOut1_o      (ALU_in1),
    .MUXOut2_o      (MUX_in1)
);

dcache_controller dcache (
    .clk_i          (clk_i), 
    .rst_i          (rst_i),
    
    .mem_data_i     (mem_data_i), 
    .mem_ack_i      (mem_ack_i),
    .mem_data_o     (mem_data_o),
    .mem_addr_o     (mem_addr_o),
    .mem_enable_o   (mem_enable_o),  
    .mem_write_o    (mem_write_o), 
    
    .cpu_data_i     (MEMWriteData), 
    .cpu_addr_i     (ALUResult_MEM),
    .cpu_MemRead_i  (ctrl_MEM[4]), 
    .cpu_MemWrite_i (ctrl_MEM[3]), 
    .cpu_data_o     (MEMReadData_MEM),
    .cpu_stall_o    (stall_all)
);

MUX32 MUX_WB (
    .data1_i        (ALUResult_WB),
    .data2_i        (MEMReadData_WB),
    .select_i       (ctrl_WB[5]),
    .data_o         (WBData)
);

Pipeline_Registers Pipeline_Registers (
    .clk_i          (clk_i),
    .pc_i           (pc_IF),
    .stall_i        (stall),
    .stall_all_i    (stall_all),
    .flush_i        (flush),
    .ins_i          (ins_IF),
    .ctrl_i         (ctrl_ID[7:1]),
    .rs1Data_i      (rs1Data_ID),
    .rs2Data_i      (rs2Data_ID),
    .imm_i          (imm_ID),
    .ALUResult_i    (ALUResult_EX),
    .MEMWriteData_i (MUX_in1),
    .MEMReadData_i  (MEMReadData_MEM),
    .pc_o           (pc_ID),
    .ctrlEX_o       (ctrl_EX),
    .ctrlMEM_o      (ctrl_MEM),
    .ctrlWB_o       (ctrl_WB),
    .insID_o        (ins_ID),
    .insEX_o        (ins_EX),
    .insMEM_o       (ins_MEM),
    .insWB_o        (ins_WB),
    .rs1Data_o      (rs1Data_EX),
    .rs2Data_o      (rs2Data_EX),
    .imm_o          (imm_EX),
    .ALUResultMEM_o (ALUResult_MEM),
    .ALUResultWB_o  (ALUResult_WB),
    .MEMWriteData_o (MEMWriteData),
    .MEMReadData_o  (MEMReadData_WB)
);

endmodule

