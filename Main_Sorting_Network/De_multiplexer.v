module Borrow_Logic_Cell (
	input wire Bin,
	input wire Y,  
	input wire X,  
	output wire Bout
);
assign Bout = (~Bin & ~Y &  X) | (~Bin &  Y & ~X) | (~Bin &  Y &  X) | ( Bin &  Y &  X);
endmodule










