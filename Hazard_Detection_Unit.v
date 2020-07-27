module Hazzard_Detection(
	ID_EX_MemWrite_i,
	ID_EX_MemRead_i,
	ID_EX_RegisterRd_i,
	IF_ID_RS1_i,
	IF_ID_RS2_i,
	Registers_RS1data_i ,
  Registers_RS2data_i ,
  branch_i,
	stall_o,
	flush_o,
	PCWrite_o
);

input	ID_EX_MemWrite_i, ID_EX_MemRead_i;
input	[4:0]	ID_EX_RegisterRd_i;
input	[4:0]	IF_ID_RS1_i;
input	[4:0]	IF_ID_RS2_i;
input	[31:0]	Registers_RS1data_i, Registers_RS2data_i;
input	branch_i;

output reg 	stall_o;
output reg 	flush_o;
output reg  PCWrite_o;

always @( * ) begin
	//lw stall
	if (ID_EX_MemRead_i && ((ID_EX_RegisterRd_i == IF_ID_RS1_i) || (ID_EX_RegisterRd_i == IF_ID_RS2_i))) begin
		//stall the pipeline, mux choose 0 rather than control
		stall_o <= 1'b1;
		PCWrite_o <= 1'b0;
	end
	else begin
		stall_o <= 1'b0;
		PCWrite_o <= 1'b1;
	end

	//flush
	if (branch_i && Registers_RS1data_i == Registers_RS2data_i) begin
		flush_o <= 1'b1;
	end
	else begin
		flush_o <= 1'b0;
	end
end

endmodule
