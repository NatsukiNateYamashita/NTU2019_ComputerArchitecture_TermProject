`define Opcode_ADDI     7'b0010011
`define Opcode_LW       7'b0000011
`define Opcode_SW       7'b0100011
`define Opcode_BEQ      7'b1100011

module Imm_Gen(
    instruction,
    data_o
);

input   [31:0] instruction;
output  [31:0] data_o;

reg [31:0] data_r;

assign data_o = data_r;

always @( instruction ) begin
    case( instruction[6:0] )
        `Opcode_ADDI: begin
             data_r = { { 20{instruction[31]} }, instruction[31:20]};
        end

        `Opcode_LW  : begin
            data_r = { { 20{instruction[31]} }, instruction[31:20]};
        end

        `Opcode_SW  : begin
            data_r = { { 20{instruction[31]} }, instruction[31:25], instruction[11:7]};
        end

        `Opcode_BEQ : begin
            data_r = { { 20{instruction[31]} }, instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
        end

        default     : begin
            data_r = { { 20{instruction[31]} }, 12'b0};
        end
    endcase
end

endmodule
