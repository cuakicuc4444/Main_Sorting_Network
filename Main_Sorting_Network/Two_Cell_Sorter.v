module Two_Cell_Sorter (
	input wire [7:0] x,	
	input wire [7:0] y,	
	output wire [7:0] high,
	output wire [7:0] low 
);
 
wire carry_out_signal;
Carry_Generation_Circuit cgc_inst (
	.X(x),          	
	.Y(y),         
	.Carry_in(1'b0), 	
	.Carry_out(carry_out_signal)
);
assign high = (carry_out_signal == 1'b0) ? y : x;
assign low = (carry_out_signal == 1'b0) ? x : y;
endmodule
