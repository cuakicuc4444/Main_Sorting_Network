module Main_Sorting_Network ( 
    input wire [7:0] x1, 
    input wire [7:0] x2, 
    input wire [7:0] x3, 
    input wire [7:0] x4, 
    input wire [7:0] x5, 
    input wire [7:0] x6, 
    input wire [7:0] x7, 
    input wire [7:0] x8, 
    input wire [7:0] x9, 
    output wire [7:0] max, 
    output wire [7:0] med, 
    output wire [7:0] min  
);

wire [7:0] sorter1_y1, sorter1_y2, sorter1_y3; 
wire [7:0] sorter3_y1, sorter3_y2, sorter3_y3; 
wire [7:0] sorter5_y1, sorter5_y2, sorter5_y3; 

wire [7:0] sorter2_y1, sorter2_y2, sorter2_y3; 
wire [7:0] sorter4_y1, sorter4_y2, sorter4_y3; 
wire [7:0] sorter6_y1, sorter6_y2, sorter6_y3; 

wire [7:0] sorter7_y1, sorter7_y2, sorter7_y3; 


Three_Cell_Sorter sorter1_inst (
    .x1(x1), .x2(x2), .x3(x3),
    .y1(sorter1_y1), .y2(sorter1_y2), .y3(sorter1_y3)
);


Three_Cell_Sorter sorter3_inst (
    .x1(x4), .x2(x5), .x3(x6),
    .y1(sorter3_y1), .y2(sorter3_y2), .y3(sorter3_y3)
);

Three_Cell_Sorter sorter5_inst (
    .x1(x7), .x2(x8), .x3(x9),
    .y1(sorter5_y1), .y2(sorter5_y2), .y3(sorter5_y3)
);


Three_Cell_Sorter sorter2_inst (
    .x1(sorter1_y1), 
    .x2(sorter3_y1), 
    .x3(sorter5_y1), 
    .y1(sorter2_y1), .y2(sorter2_y2), .y3(sorter2_y3)
);

Three_Cell_Sorter sorter4_inst (
    .x1(sorter1_y2), 
    .x2(sorter3_y2), 
    .x3(sorter5_y2), 
    .y1(sorter4_y1), .y2(sorter4_y2), .y3(sorter4_y3)
);

Three_Cell_Sorter sorter6_inst (
    .x1(sorter1_y3), 
    .x2(sorter3_y3), 
    .x3(sorter5_y3), 
    .y1(sorter6_y1), .y2(sorter6_y2), .y3(sorter6_y3) 
);

Three_Cell_Sorter sorter7_inst ( 
    .x1(sorter2_y2), 
    .x2(sorter4_y2), 
    .x3(sorter6_y2), 
    .y1(sorter7_y1), 
    .y2(sorter7_y2), 
    .y3(sorter7_y3)  
);

assign max = sorter7_y1;       
assign med = sorter7_y2; 
assign min = sorter7_y3;      

endmodule