`define OPcode_NOP    7'b0000000
`define Opcode_R_type 7'b0110011
`define Opcode_I_type 7'b0010011
`define OPcode_SW     7'b0100011
`define OPcode_LW     7'b0000011
`define OPcode_BEQ    7'b1100011

module Control(
    Op_i,
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemWrite_o,
    MemRead_o,
    MemtoReg_o,
    Branch_o,
);

input       [6:0]   Op_i;
output reg          ALUSrc_o;
output reg          RegWrite_o;
output reg          MemWrite_o;
output reg          MemRead_o;
output reg          MemtoReg_o;
output reg          Branch_o;
output reg [1:0] ALUOp_o;

always @(Op_i) begin
	 if (Op_i == `Opcode_I_type) begin
  		ALUOp_o     <= 2'b11;
  		ALUSrc_o    <= 1'b1;
  		RegWrite_o  <= 1'b1;
  		MemWrite_o  <= 1'b0;
  		MemRead_o   <= 1'b0;
  		MemtoReg_o  <= 1'b0;
  		Branch_o    <= 1'b0;
	end
	else if (Op_i == `OPcode_BEQ ) begin
  		ALUOp_o     <= 2'b01;
  		ALUSrc_o    <= 1'b0;
  		RegWrite_o  <= 1'b0;
  		MemWrite_o  <= 1'b0;
  		MemRead_o   <= 1'b0;
  		MemtoReg_o  <= 1'b0;
  		Branch_o    <= 1'b1;
	end
	else if (Op_i == `Opcode_R_type) begin //R
  		ALUOp_o     <= 2'b10;
  		ALUSrc_o    <= 1'b0;
  		RegWrite_o  <= 1'b1;
  		MemWrite_o  <= 1'b0;
  		MemRead_o   <= 1'b0;
  		MemtoReg_o  <= 1'b0;
  		Branch_o    <= 1'b0;
	end
	else if (Op_i == `OPcode_NOP) begin //no instruction
  		ALUOp_o     <= 2'b00;
  		ALUSrc_o    <= 1'b1;
  		RegWrite_o  <= 1'b0;
  		MemWrite_o  <= 1'b0;
  		MemRead_o   <= 1'b0;
  		MemtoReg_o  <= 1'b0;
  		Branch_o    <= 1'b0;
	end
	else 	if (Op_i == `OPcode_SW) begin
  		ALUOp_o     <= 2'b00;
  		ALUSrc_o    <= 1'b1;
  		Branch_o    <= 1'b0;
  		RegWrite_o  <= 1'b0;
  		MemWrite_o  <= 1'b1;
  		MemRead_o   <= 1'b0;
  		MemtoReg_o  <= 1'b0;
		end
	 else if (Op_i == `OPcode_LW) begin
       ALUOp_o    <= 2'b00;
       ALUSrc_o   <= 1'b1;
       Branch_o   <= 1'b0;
  		 RegWrite_o <= 1'b1;
       MemWrite_o <= 1'b0;
       MemRead_o  <= 1'b1;
       MemtoReg_o <= 1'b1;
		end

end
endmodule
