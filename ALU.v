`define ALU_Ctrl_ADD 4'b0010
`define ALU_Ctrl_SUB 4'b0110
`define ALU_Ctrl_AND 4'b0000
`define ALU_Ctrl_OR  4'b0001
`define ALU_Ctrl_MUL 4'b1000

module ALU(
    data1_i    ,
    data2_i    ,
    ALUCtrl_i  ,
    data_o     ,
    Zero_o
);

input       [31:0]  data1_i;
input       [31:0]  data2_i;
input       [3:0]   ALUCtrl_i;
output reg  [31:0]  data_o;
output reg          Zero_o;

always @(*) begin
   if(data1_i && data2_i) begin
    	 case (ALUCtrl_i)
    		  `ALU_Ctrl_ADD: data_o <= data1_i + data2_i;
    		  `ALU_Ctrl_MUL: data_o <= data1_i * data2_i;
      		`ALU_Ctrl_SUB: data_o <= data1_i - data2_i;
      		`ALU_Ctrl_AND: data_o <= data1_i & data2_i;
      		`ALU_Ctrl_OR:  data_o <= data1_i | data2_i;
      		default: data_o <= data1_i & data2_i;
    	endcase
  end
  else if(data1_i)begin
      case (ALUCtrl_i)
         `ALU_Ctrl_ADD: data_o <= data1_i;
         `ALU_Ctrl_MUL: data_o <= data1_i;
         `ALU_Ctrl_SUB: data_o <= data1_i;
         `ALU_Ctrl_AND: data_o <= data1_i;
         `ALU_Ctrl_OR:  data_o <= data1_i;
         default: data_o <= data1_i;
     endcase
  end
  else begin
      case (ALUCtrl_i)
         `ALU_Ctrl_ADD: data_o <= data2_i;
         `ALU_Ctrl_MUL: data_o <= data2_i;
         `ALU_Ctrl_SUB: data_o <= data2_i;
         `ALU_Ctrl_AND: data_o <= data2_i;
         `ALU_Ctrl_OR:  data_o <= data2_i;
         default: data_o <= data2_i;
      endcase
  end
	Zero_o = 1'b0;
end
endmodule
