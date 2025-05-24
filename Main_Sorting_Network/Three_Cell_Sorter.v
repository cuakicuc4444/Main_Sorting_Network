module Three_Cell_Sorter (
	input wire [7:0] x1,
	input wire [7:0] x2,
	input wire [7:0] x3,
	output wire [7:0] y1,
	output wire [7:0] y2,
	output wire [7:0] y3 
);
wire [7:0] sorter1_high;
wire [7:0] sorter1_low;
wire [7:0] sorter3_high;
wire [7:0] sorter3_low;
Two_Cell_Sorter sorter1_inst (
	.x(x1),
	.y(x2),
	.high(sorter1_high),
	.low(sorter1_low) 
);
Two_Cell_Sorter sorter3_inst (
	.x(sorter1_low),
	.y(x3),
	.high(sorter3_high),
	.low(y3)       	
);
Two_Cell_Sorter sorter2_inst (
	.x(sorter1_high),
	.y(sorter3_high),
	.high(y1),    	
	.low(y2)     	
);
endmodule
