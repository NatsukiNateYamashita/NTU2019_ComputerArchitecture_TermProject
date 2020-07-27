`define ALUOp_R_type 2'b10
`define ALUOp_I_type 2'b11
`define ALUOp_LDSD   2'b00
`define ALUOp_BEQ    2'b01
`define Funct_OR  10'b0000000110
`define Funct_AND 10'b0000000111
`define Funct_ADD 10'b0000000000
`define Funct_SUB 10'b0100000000
`define Funct_MUL 10'b0000001000
`define ALU_Ctrl_OR  4'b0001
`define ALU_Ctrl_AND 4'b0000
`define ALU_Ctrl_ADD 4'b0010
`define ALU_Ctrl_SUB 4'b0110
`define ALU_Ctrl_MUL 4'b1000

module ALU_Control(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

input       [9:0] funct_i;
input       [1:0] ALUOp_i;
output  [3:0] ALUCtrl_o;
reg  [3:0] ALUCtrl_r;

assign ALUCtrl_o = ALUCtrl_r;

always @(funct_i or ALUOp_i) begin
  	if (ALUOp_i == `ALUOp_I_type) begin
  		  ALUCtrl_r = `ALU_Ctrl_ADD;
  	end
  	else if (ALUOp_i == `ALUOp_BEQ) begin
  		  ALUCtrl_r = `ALU_Ctrl_SUB;
  	end
  	else if (ALUOp_i == `ALUOp_LDSD) begin
  		  ALUCtrl_r = `ALU_Ctrl_ADD;
  	end
  	else begin
    		case (funct_i)
          	`Funct_OR : ALUCtrl_r <= `ALU_Ctrl_OR;
      			`Funct_AND: ALUCtrl_r <= `ALU_Ctrl_AND;
      			`Funct_ADD: ALUCtrl_r <= `ALU_Ctrl_ADD;
      			`Funct_SUB: ALUCtrl_r <= `ALU_Ctrl_SUB;
      			`Funct_MUL: ALUCtrl_r <= `ALU_Ctrl_MUL;
      			default:ALUCtrl_r <= 4'b0000;
    		endcase
  	end
end
endmodule
