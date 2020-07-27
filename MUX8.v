module MUX8(
    data_i,
    select_i,
    data_o
);


input	[7:0]	data_i;
input	select_i;
output	[7:0]	data_o;

assign data_o = (select_i == 1'b1)? 8'b0 : data_i;

endmodule
