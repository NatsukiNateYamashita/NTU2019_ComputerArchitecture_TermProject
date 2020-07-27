module CPU
(
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

//input
input clk_i;
input rst_i;
input start_i;

//
// to Data Memory interface
//
input	[256-1:0]	mem_data_i;
input				mem_ack_i;
output	[256-1:0]	mem_data_o;
output	[32-1:0]	mem_addr_o;
output				mem_enable_o;
output				mem_write_o;

//
// add your project1 here!

// P1 start	*************************************************************

// Wires
wire [1:0]    Control_ALUOp_o;
wire          Control_ALU_Src_o;
wire          Control_RegWrite_o;
wire          Control_MemWrite_o;
wire          Control_MemRead_o;
wire          Control_MemtoReg_o;
wire          Control_Branch_o;

wire [31:0]   IF_ID_pc_o;
wire [31:0]   IF_ID_instruction;

wire [1:0]    ID_EX_ALUOp_o;
wire          ID_EX_ALUSrc_o;
wire          ID_EX_RegWrite_o;
wire          ID_EX_MemWrite_o;
wire          ID_EX_MemRead_o;
wire          ID_EX_MemtoReg_o;
wire          ID_EX_Branch_o;

wire [31:0]   ID_EX_RS1data_o;
wire [31:0]   ID_EX_RS2data_o;
wire [31:0]   ID_EX_imm_o;
wire [9:0]    ID_EX_funct_o;
wire [4:0]    ID_EX_RDaddr_o;

wire [4:0]    ID_EX_RS1addr_o;
wire [4:0]    ID_EX_RS2addr_o;

wire          EX_MEM_RegWrite_o;
wire          EX_MEM_MemWrite_o;
wire          EX_MEM_MemRead_o;
wire          EX_MEM_MemtoReg_o;

wire          EX_MEM_Zero_o;
wire [31:0]   EX_MEM_ALU_data_o;
wire [31:0]   EX_MEM_writeData_o;
wire [4:0]    EX_MEM_RDaddr_o;

wire          MEM_WB_RegWrite_o;
wire          MEM_WB_MemtoReg_o;
wire [31:0]   MEM_WB_ReadData_o;
wire [31:0]   MEM_WB_ALU_data_o;
wire [4:0]    MEM_WB_RDaddr_o;

wire [31:0]   Add_PC_data_o;

wire [31:0]   Add_imm_data_o;

wire [31:0]   PC_instruction_addr;

wire [31:0]   instruction;

wire [31:0]   Registers_RS1data_o;
wire [31:0]   Registers_RS2data_o;

wire [31:0]   MUX_RegDst_data_o;
wire [31:0]   MUX_PCSrc_data_o;
wire [31:0]   MUX_ALUSrc_data_o;
wire [31:0]   MUX_ALUSrcA_data_o;
wire [31:0]   MUX_ALUSrcB_data_o;

wire [31:0]   Imm_Gen_data_o;

wire [31:0]   ALU_data_o;
wire          ALU_zero_o;

wire [3:0]    ALU_Control_ALUCtrl_o;

wire [31:0]   Data_Memory_data_o;

wire [1:0] Forwording_Unit_ForwardA_o;
wire [1:0] Forwording_Unit_ForwardB_o;

wire Hazzard_Detection_mux8_o;
wire Hazzard_Detection_flush_o;
wire Hazzard_Detection_PCWrite_o;

wire [7:0]  MUX8_data_o;

wire dcache_stall;


Control Control(
    .Op_i       (IF_ID_instruction[6:0]),
    .ALUOp_o    (Control_ALUOp_o),
    .ALUSrc_o   (Control_ALU_Src_o),
    .RegWrite_o (Control_RegWrite_o),
    .MemWrite_o (Control_MemWrite_o),
    .MemRead_o  (Control_MemRead_o),
    .MemtoReg_o (Control_MemtoReg_o),
    .Branch_o   (Control_Branch_o)
);



IF_ID IF_ID(
    .clk_i      (clk_i),
    .pc_i       (PC_instruction_addr),
    .instr_i    (instruction),
    //.stall_i    (Hazzard_Detection_mux8_o),
	.stall_i	(dcache_stall),
    .flush_i    (Hazzard_Detection_flush_o),
    .pc_o       (IF_ID_pc_o),
    .instr_o    (IF_ID_instruction)
);


ID_EX ID_EX(
    .clk_i      (clk_i),
    .start_i    (start_i),
    .ALUOp_i    (MUX8_data_o[7:6]),
    .ALUSrc_i   (MUX8_data_o[5]),
    .RegWrite_i (MUX8_data_o[4]),
    .MemWrite_i (MUX8_data_o[3]),
    .MemRead_i  (MUX8_data_o[2]),
    .MemtoReg_i	(MUX8_data_o[1]),
	.Branch_i   (MUX8_data_o[0]),
    .ALUOp_o    (ID_EX_ALUOp_o),
    .ALUSrc_o   (ID_EX_ALUSrc_o),
    .RegWrite_o (ID_EX_RegWrite_o),
    .MemWrite_o (ID_EX_MemWrite_o),
    .MemRead_o  (ID_EX_MemRead_o),
    .MemtoReg_o	(ID_EX_MemtoReg_o),
	.Branch_o   (ID_EX_Branch_o),

    .RS1data_i  (Registers_RS1data_o),
    .RS2data_i  (Registers_RS2data_o),
	.imm_i	  	(Imm_Gen_data_o),
    .funct_i    ({IF_ID_instruction[31:25], IF_ID_instruction[14:12]}),
    .RDaddr_i   (IF_ID_instruction[11:7]),
    .RS1data_o  (ID_EX_RS1data_o),
    .RS2data_o  (ID_EX_RS2data_o),
    .imm_o      (ID_EX_imm_o),
    .funct_o    (ID_EX_funct_o),
    .RDaddr_o   (ID_EX_RDaddr_o),

    .RSaddr_i   (IF_ID_instruction[19:15]),
    .RS2addr_i  (IF_ID_instruction[24:20]),
    .RS1addr_o  (ID_EX_RS1addr_o),
    .RS2addr_o  (ID_EX_RS2addr_o),

	.stall_i	(dcache_stall)
);


EX_MEM EX_MEM(
    .clk_i      (clk_i),
    .RegWrite_i (ID_EX_RegWrite_o),
    .MemWrite_i (ID_EX_MemWrite_o),
    .MemRead_i  (ID_EX_MemRead_o),
    .MemtoReg_i (ID_EX_MemtoReg_o),

    .RegWrite_o (EX_MEM_RegWrite_o),
    .MemWrite_o (EX_MEM_MemWrite_o),
    .MemRead_o  (EX_MEM_MemRead_o),
    .MemtoReg_o (EX_MEM_MemtoReg_o),


    .Zero_i     (ALU_zero_o),
    .ALU_data_i (ALU_data_o),
    .writeData_i(MUX_ALUSrcB_data_o),
    .RDaddr_i   (ID_EX_RDaddr_o),
    
	.Zero_o     (EX_MEM_Zero_o),
    .ALU_data_o (EX_MEM_ALU_data_o),
    .writeData_o(EX_MEM_writeData_o),
    .RDaddr_o   (EX_MEM_RDaddr_o),

	.stall_i	(dcache_stall)
);


MEM_WB MEM_WB(
    .clk_i      (clk_i),
    .RegWrite_i (EX_MEM_RegWrite_o),
    .MemtoReg_i (EX_MEM_MemtoReg_o),
    .RegWrite_o (MEM_WB_RegWrite_o),
    .MemtoReg_o (MEM_WB_MemtoReg_o),

	.ReadData_i (Data_Memory_data_o),
    .ALU_data_i (EX_MEM_ALU_data_o),
    .RDaddr_i   (EX_MEM_RDaddr_o),
    .ReadData_o (MEM_WB_ReadData_o),
    .ALU_data_o (MEM_WB_ALU_data_o),
    .RDaddr_o   (MEM_WB_RDaddr_o),

	.stall_i	(dcache_stall)
);


Adder Add_PC(
    .data1_in   (PC_instruction_addr),
    .data2_in   (32'd4),
    .data_o     (Add_PC_data_o)
);


Adder Add_imm(
   .data1_in  	(Imm_Gen_data_o << 1),
   .data2_in	(IF_ID_pc_o),
   .data_o	    (Add_imm_data_o)
);



PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
	.stall_i	(dcache_stall),
    .PCWrite_i  (Hazzard_Detection_PCWrite_o),
    .pc_i       (MUX_PCSrc_data_o),
    .pc_o       (PC_instruction_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (PC_instruction_addr),
    .instr_o    (instruction)
);


Registers Registers(
	.clk_i		(clk_i),
    .RS1addr_i  (IF_ID_instruction[19:15]),
    .RS2addr_i  (IF_ID_instruction[24:20]),
    .RDaddr_i   (MEM_WB_RDaddr_o),
    .RDdata_i   (MUX_RegDst_data_o),
    .RegWrite_i (MEM_WB_RegWrite_o),
	.RS1data_o  (Registers_RS1data_o),
    .RS2data_o  (Registers_RS2data_o)
);

MUX5 MUX_RegDst(
    .data1_i    (MEM_WB_ALU_data_o),
    .data2_i    (MEM_WB_ReadData_o),
	.select_i   (MEM_WB_MemtoReg_o),
    .data_o     (MUX_RegDst_data_o)
);

MUX5 MUX_PCSrc(
    .data1_i    (Add_PC_data_o),
    .data2_i    (Add_imm_data_o),
    .select_i   (Hazzard_Detection_flush_o),
    .data_o     (MUX_PCSrc_data_o)
);

MUX5 MUX_ALUSrc(
    .data1_i    (MUX_ALUSrcB_data_o),
    .data2_i    (ID_EX_imm_o),
    .select_i   (ID_EX_ALUSrc_o),
    .data_o     (MUX_ALUSrc_data_o)
);

MUX32 MUX_ALUSrcA(
    .data1_i    (ID_EX_RS1data_o),
    .data2_i    (MUX_RegDst_data_o),
    .data3_i    (EX_MEM_ALU_data_o),
    .select_i   (Forwording_Unit_ForwardA_o),
    .data_o     (MUX_ALUSrcA_data_o)
);

MUX32 MUX_ALUSrcB(
    .data1_i    (ID_EX_RS2data_o),
    .data2_i    (MUX_RegDst_data_o),
    .data3_i    (EX_MEM_ALU_data_o),
    .select_i   (Forwording_Unit_ForwardB_o),
    .data_o     (MUX_ALUSrcB_data_o)
);

Imm_Gen Imm_Gen(
    .instruction(IF_ID_instruction),
    .data_o     (Imm_Gen_data_o)
);


ALU ALU(
    .data1_i    (MUX_ALUSrcA_data_o),
    .data2_i    (MUX_ALUSrc_data_o),
    .ALUCtrl_i  (ALU_Control_ALUCtrl_o),
    .data_o     (ALU_data_o),
    .Zero_o     (ALU_zero_o)
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX_funct_o),
    .ALUOp_i    (ID_EX_ALUOp_o),
    .ALUCtrl_o  (ALU_Control_ALUCtrl_o)
);

//Data_Memory Data_Memory(
//	  .clk_i	  	(clk_i),
//	  .data_i     (EX_MEM_writeData_o),
//    .MemWrite_i (EX_MEM_MemWrite_o),
//    .addr_i     (EX_MEM_ALU_data_o),
//    .data_o     (Data_Memory_data_o)
//);

Forwarding_Unit Forwarding_Unit(
    .EX_MEM_RegisterRd_i (EX_MEM_RDaddr_o),
    .EX_MEM_RegWrite_i   (EX_MEM_RegWrite_o),
    .MEM_WB_RegisterRd_i (MEM_WB_RDaddr_o),
    .MEM_WB_RegWrite_i   (MEM_WB_RegWrite_o),
    .ID_EX_RS1_i         (ID_EX_RS1addr_o),
    .ID_EX_RS2_i         (ID_EX_RS2addr_o),
    .ForwardA_o          (Forwording_Unit_ForwardA_o),
    .ForwardB_o          (Forwording_Unit_ForwardB_o)
);


Hazzard_Detection Hazzard_Detection(
    .ID_EX_MemWrite_i	 	(ID_EX_MemWrite_o),
    .ID_EX_MemRead_i	 	(ID_EX_MemRead_o),
    .ID_EX_RegisterRd_i		(ID_EX_RDaddr_o),
    .IF_ID_RS1_i	        (IF_ID_instruction[19:15]),
    .IF_ID_RS2_i	        (IF_ID_instruction[24:20]),
    .Registers_RS1data_i 	(Registers_RS1data_o),
    .Registers_RS2data_i 	(Registers_RS2data_o),
    .branch_i           	(Control_Branch_o),
    .stall_o            	(Hazzard_Detection_mux8_o),
    .flush_o            	(Hazzard_Detection_flush_o),
    .PCWrite_o          	(Hazzard_Detection_PCWrite_o)
);

MUX8 MUX8(
    .data_i	    ({Control_ALUOp_o, Control_ALU_Src_o, Control_RegWrite_o, Control_MemWrite_o, Control_MemRead_o, Control_MemtoReg_o, Control_Branch_o}),
    .select_i	  (Hazzard_Detection_mux8_o),
    .data_o	    (MUX8_data_o)
);

// P1 end	***********************************************************

//PC PC
//(
//	.clk_i(clk_i),
//	.rst_i(rst_i),
//	.start_i(start_i),
//	.stall_i(),
//	.PCWrite_i(),
//	.pc_i(),
//	.pc_o()
//);

//Instruction_Memory Instruction_Memory(
//	.addr_i(),
//	.instr_o()
//);

//Registers Registers(
//	.clk_i(clk_i),
//	.RS1addr_i(),
//	.RS2addr_i(),
//	.RDaddr_i(),
//	.RDdata_i(),
//	.RegWrite_i(),
//	.RS1data_o(),
//	.RS2data_o()
//);

//data cache
dcache_top dcache
(
    // System clock, reset and stall
	.clk_i(clk_i),
	.rst_i(rst_i),

	// from Data Memory interface
	.mem_data_i		(mem_data_i),
	.mem_ack_i		(mem_ack_i),
	// to Data Memory interface
	.mem_data_o		(mem_data_o),
	.mem_addr_o		(mem_addr_o),
	.mem_enable_o	(mem_enable_o),
	.mem_write_o	(mem_write_o),

	// from CPU interface	
	.p1_data_i		(EX_MEM_writeData_o),
	.p1_addr_i		(EX_MEM_ALU_data_o),
	.p1_MemRead_i	(EX_MEM_MemRead_o),
	.p1_MemWrite_i	(EX_MEM_MemWrite_o),
	// to CPU interface
	.p1_data_o		(Data_Memory_data_o),
	.p1_stall_o		(dcache_stall)
);

endmodule
