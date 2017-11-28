module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire reg_dst, ALUSrc, reg_write;
wire [31:0] instruction;
wire [31:0] inst_addr, inst;
wire [31:0] extended;
wire [31:0] ALUinput2;
wire [31:0] Dread1;
wire [31:0] write_data;
wire [4:0] write_register;
wire [2:0] Alu_ctr;
wire [1:0] AluOp;

Control Control(
    .Op_i       (instruction[31:26]),
    .RegDst_o   (reg_dst),
    .ALUOp_o    (AluOp),
    .ALUSrc_o   (ALUSrc),
    .RegWrite_o (reg_write)
);

Adder Add_PC(
    .data1_in   (inst_addr),
    .data2_in   (32'd4),
    .data_o     (PC.pc_i)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (),
    .pc_o       (inst_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr), 
    .instr_o    (instruction)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (instruction[25:21]),
    .RTaddr_i   (instruction[20:16]),
    .RDaddr_i   (write_register), 
    .RDdata_i   (write_data),
    .RegWrite_i (reg_write), 
    .RSdata_o   (Dread1), 
    .RTdata_o   (MUX_ALUSrc.data1_i) 
);

MUX5 MUX_RegDst(
    .data1_i    (instruction[20:16]),
    .data2_i    (instruction[15:11]),
    .select_i   (reg_dst),
    .data_o     (write_register)
);

MUX32 MUX_ALUSrc(
    .data1_i    (),
    .data2_i    (extended),
    .select_i   (ALUSrc),
    .data_o     (ALUinput2)
);



Sign_Extend Sign_Extend(
    .data_i     (instruction[15:0]),
    .data_o     (extended)
);

ALU ALU(
    .data1_i    (Dread1),
    .data2_i    (ALUinput2),
    .ALUCtrl_i  (Alu_ctr),
    .data_o     (write_data),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (instruction[5:0]),
    .ALUOp_i    (AluOp),
    .ALUCtrl_o  (Alu_ctr)
);

endmodule

