// Design by: Le Vu Trung Duong
// Date: 2025-03-16
// Description: This is the AXI4 Lite interface for the MY_IP IP core
`timescale 1 ns / 1 ps

`define DATA_WIDTH              32
`define OP_WIDTH                3
`define ADDR_WIDTH              10
`define MASK_ADDR_WIDTH         2
`define MEM_OP_WIDTH            16

`define SEL_A                   2'b00
`define SEL_B                   2'b01
`define SEL_OUT                 2'b10

`define OP_ADD                  3'b000
`define OP_SUB                  3'b001
`define OP_AND                  3'b010
`define OP_OR                   3'b011
`define OP_SLL                  3'b100
`define OP_SRL                  3'b101
`define OP_SLT                  3'b110
`define OP_XOR                  3'b111

`define COUNTER_WIDTH           10

// For AXI4
`define ZCU102
`ifdef ZCU102
    `define AXI_DONE_ADDR           40'h04_0004_0000
    `define AXI_START_ADDR          40'h04_0008_0000
    `define AXI_TRANSFER_MASK       16'h04_81
    `define AXI_PIO_MASK            16'h04_00
`endif
`ifdef KV260
    `define AXI_DONE_ADDR           40'h00_A004_0000
    `define AXI_START_ADDR          40'h00_A008_0000
    `define AXI_TRANSFER_MASK       16'h00_A
`endif

`define AXI_DATA_WIDTH              32
`define AXI_TRANSFER_MODE_WIDTH     2

`define AXI_TRANSFER_A_MASK         2'd0
`define AXI_TRANSFER_B_MASK         2'd1
`define AXI_TRANSFER_O_MASK         2'd2
`define AXI_TRANSFER_OP_MASK        2'd3
	module myip_v1_0_S00_AXI #
	(
		parameter integer BRAM_DATA_WIDTH	= 32,
        parameter integer BRAM_ADDR_WIDTH	= 40,
        parameter integer BRAM_DEPTH        = 256,
        parameter integer BRAM_BASE_ADDR    = 32'H00001000,
        parameter integer BRAM_HIGH_ADDR    = 32'H000013FF,

		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 40
	)
	(
		input wire  S_AXI_ACLK,
		input wire  S_AXI_ARESETN,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		input wire [2 : 0] S_AXI_AWPROT,
		input wire  S_AXI_AWVALID,
		output wire  S_AXI_AWREADY,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input wire  S_AXI_WVALID,
		output wire  S_AXI_WREADY,
		output wire [1 : 0] S_AXI_BRESP,
		output wire  S_AXI_BVALID,
		input wire  S_AXI_BREADY,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		input wire [2 : 0] S_AXI_ARPROT,
		input wire  S_AXI_ARVALID,
		output wire  S_AXI_ARREADY,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		output wire [1 : 0] S_AXI_RRESP,
		output wire  S_AXI_RVALID,
		input wire  S_AXI_RREADY
	);

	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;

	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;

	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY		= axi_wready;
	assign S_AXI_BRESP		= axi_bresp;
	assign S_AXI_BVALID		= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RRESP		= axi_rresp;
	assign S_AXI_RVALID		= axi_rvalid;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end
	  else
	    begin
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else
	        begin
	          axi_awready <= 1'b0;
	        end
	    end
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end
	  else
	    begin
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end
	  else
	    begin
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
	    end
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          2'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          2'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          2'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          2'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                    end
	        endcase
	      end
	  end
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end
	  else
	    begin
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0;
	        end
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid)
	            begin
	              axi_bvalid <= 1'b0;
	            end
	        end
	    end
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end
	  else
	    begin
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          axi_arready <= 1'b1;
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end
	  else
	    begin
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0;
	        end
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end
	    end
	end

	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= slv_reg0;
	        2'h1   : reg_data_out <= slv_reg1;
	        2'h2   : reg_data_out <= slv_reg2;
	        2'h3   : reg_data_out <= slv_reg_output_results; // Đ?c k?t qu? t? thanh ghi output riêng
	        default : reg_data_out <= 0;
	      endcase
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end
	  else
	    begin
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;
	        end
	    end
	end

	reg [`ADDR_WIDTH-1:0]          						AXI_addra_r;
	reg [`AXI_DATA_WIDTH-1:0]       					AXI_dina_r;
	reg 					              				AXI_ena_r;
	reg 					              				AXI_wea_r;
	wire [`ADDR_WIDTH-1:0]          					AXI_addra_w;
	wire [`AXI_DATA_WIDTH-1:0]       					AXI_dina_w;
	wire 					              				AXI_ena_w;
	wire 					              				AXI_wea_w;

	wire [`AXI_DATA_WIDTH-1:0]							AXI_dout_w;
	assign AXI_addra_w 		= AXI_addra_r	;
	assign AXI_dina_w 		= AXI_dina_r	;
	assign AXI_ena_w 		= AXI_ena_r		;
	assign AXI_wea_w 		= AXI_wea_r		;

	always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )
	begin
		if (S_AXI_ARESETN == 1'b0) begin
			AXI_addra_r	 			<= 		`ADDR_WIDTH'h0;
			AXI_dina_r	 			<= 		`AXI_DATA_WIDTH'h0;
			AXI_ena_r	 			<= 		1'b0;
			AXI_wea_r	 			<= 		1'b0;
		end
		else begin
			if(slv_reg_wren) begin
				if (axi_awaddr[39:28] == 12'h00_A) begin
					AXI_addra_r	 		<= 		axi_awaddr[ADDR_LSB+`ADDR_WIDTH-1:ADDR_LSB];
					AXI_dina_r	 		<= 		S_AXI_WDATA;
					AXI_ena_r	 		<= 		slv_reg_wren;
					AXI_wea_r	 		<= 		slv_reg_wren;
				end
				else begin
					AXI_addra_r	 		<= 		`ADDR_WIDTH'h0;
					AXI_dina_r	 		<= 		`AXI_DATA_WIDTH'h0;
					AXI_ena_r	 		<= 1'b0;
					AXI_wea_r	 		<= 1'b0;
				end
			end
			else if (slv_reg_rden) begin
				if ( axi_araddr[39:28] == 12'h00_A) begin
					AXI_addra_r	 		<= 		axi_araddr[ADDR_LSB+`ADDR_WIDTH-1:ADDR_LSB];
					AXI_dina_r	 		<= 		`AXI_DATA_WIDTH'h0;
					AXI_ena_r	 		<= 		slv_reg_rden;
					AXI_wea_r	 		<= 		~slv_reg_rden;
				end
				else begin
					AXI_addra_r	 		<= 		`ADDR_WIDTH'h0;
					AXI_dina_r	 		<= 		`AXI_DATA_WIDTH'h0;
					AXI_ena_r	 		<= 1'b0;
					AXI_wea_r	 		<= 1'b0;
				end
			end
			else begin
				AXI_addra_r	 		<= 		`ADDR_WIDTH'h0;
				AXI_dina_r	 		<= 		`AXI_DATA_WIDTH'h0;
				AXI_ena_r	 		<= 1'b0;
				AXI_wea_r	 		<= 1'b0;
			end
		end
	end

	assign S_AXI_RDATA		= AXI_dout_w;

	// Define necessary wires for Main_Sorting_Network
	wire [7:0] main_sn_x1;
	wire [7:0] main_sn_x2;
	wire [7:0] main_sn_x3;
	wire [7:0] main_sn_x4;
	wire [7:0] main_sn_x5;
	wire [7:0] main_sn_x6;
	wire [7:0] main_sn_x7;
	wire [7:0] main_sn_x8;
	wire [7:0] main_sn_x9;

	wire [7:0] main_sn_max;
	wire [7:0] main_sn_med;
	wire [7:0] main_sn_min;

	// New register for storing sorting results (read-only from AXI perspective)
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_output_results;

	// Map AXI Slave Registers to Main_Sorting_Network Inputs
	assign main_sn_x1 = slv_reg0[23:16];
	assign main_sn_x2 = slv_reg0[15:8];
	assign main_sn_x3 = slv_reg0[7:0];

	assign main_sn_x4 = slv_reg1[23:16];
	assign main_sn_x5 = slv_reg1[15:8];
	assign main_sn_x6 = slv_reg1[7:0];

	assign main_sn_x7 = slv_reg2[23:16];
	assign main_sn_x8 = slv_reg2[15:8];
	assign main_sn_x9 = slv_reg2[7:0];

	// Update the output results register
    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg_output_results <= 0;
        end else begin
            slv_reg_output_results[7:0]   <= main_sn_min;
            slv_reg_output_results[15:8]  <= main_sn_med;
            slv_reg_output_results[23:16] <= main_sn_max;
            // Bits 31:24 can be used for status or remain 0
        end
    end

	Main_Sorting_Network sorting_inst (
		.x1(main_sn_x1),
		.x2(main_sn_x2),
		.x3(main_sn_x3),
		.x4(main_sn_x4),
		.x5(main_sn_x5),
		.x6(main_sn_x6),
		.x7(main_sn_x7),
		.x8(main_sn_x8),
		.x9(main_sn_x9),
		.max(main_sn_max),
		.med(main_sn_med),
		.min(main_sn_min)
	);

	endmodule
