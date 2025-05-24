module Carry_Generation_Circuit (
	input wire [7:0] X,
	input wire [7:0] Y,
	input wire Carry_in,
	output wire Carry_out
);
    wire [7:0] internal_borrow_chain;
Borrow_Logic_Cell d1_inst (
	.Bin(Carry_in),
	.Y(Y[0]),
	.X(X[0]),
	.Bout(internal_borrow_chain[0])
);
genvar i;
generate
	for (i = 1; i < 8; i = i + 1) begin : bit_cells
    	Borrow_Logic_Cell d_inst (
            .Bin(internal_borrow_chain[i-1]),
        	.Y(Y[i]),
        	.X(X[i]),
            .Bout(internal_borrow_chain[i])  
    	);
	end
endgenerate
assign Carry_out = internal_borrow_chain[7];
Borrow_Logic_Cell d8_inst (
	.Bin(internal_borrow_chain[6]),
	.Y(Y[7]),
	.X(X[7]),
	.Bout(Carry_out)
);
endmodule
