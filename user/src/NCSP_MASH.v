`include "Timescale.v"
//this define is used to turn off sp-mash with the purpose of sim with the reference design
`define TEST_WITH_REF 
module NCSP_MASH #(
    parameter P_DATA_WIDTH = 8
)
(
    input                    i_clk,
    input                    i_rst_n,
	input					i_ff_rst,
//	input					i_rst_n_1d,
	input [7:0]              i_sum_sel,
	input [8:0]              i_cout_sel,
	input [11:0] 			 i_seed,
    input [7:0] 			 i_level1_data,
    input [7:0] 			 i_level2_data,
    input [7:0] 			 i_level3_data,
   
    output                   o_quantize1,
    output                   o_quantize2,
    output                   o_quantize3
);

reg [7:0] rst_delay_tree;

wire w_quantize21;
wire w_quantize22;
wire w_quantize23;

wire w_quantize31;
wire w_quantize32;
wire w_quantize33;

always @(posedge i_clk or posedge i_ff_rst) begin
	if(i_ff_rst) begin
		rst_delay_tree <= 8'hff;
	end
	else begin
		rst_delay_tree <= {rst_delay_tree[6:0],i_rst_n};
	end
	
end


EFM_CHAIN_SEL
u0_EFM_CHAIN(
	.i_clk        	( i_clk         ),
	.i_rst_n      	( rst_delay_tree[3]    ),
 	.i_rst_n_2d		( rst_delay_tree[5]    ),
	.i_rst_n_4d		( rst_delay_tree[7]    ),
	.i_sum_sel		( i_sum_sel    ),
	.i_cout_sel 	( i_cout_sel   ),
	.i_level_data 	( i_level1_data  ),
	.i_seed			( i_seed[11:4]   ),
	.i_quantize1  	( w_quantize21   ),
	.i_quantize2  	( w_quantize22   ),
	.i_quantize3  	( w_quantize23   ),
	.o_quantize1  	( o_quantize1   ),
	.o_quantize2  	( o_quantize2   ),
	.o_quantize3  	( o_quantize3   )
);

EFM_CHAIN 
u1_EFM_CHAIN(
	.i_clk        	( i_clk         ),
	.i_rst_n      	( rst_delay_tree[1]    ),
	.i_rst_n_2d		( rst_delay_tree[3]    ),
	.i_rst_n_4d		( rst_delay_tree[5]    ),
	.i_level_data 	( i_level2_data  ),
	.i_seed       	({i_seed[3:0],{4{1'b0}}}),
	.i_quantize1  	( w_quantize31   ),
	.i_quantize2  	( w_quantize32   ),
	.i_quantize3  	( w_quantize33   ),
	.o_quantize1  	( w_quantize21   ),
	.o_quantize2  	( w_quantize22   ),
	.o_quantize3  	( w_quantize23   )
);

EFM_CHAIN 
u2_EFM_CHAIN(
	.i_clk        	( i_clk         ),
	.i_rst_n      	( i_rst_n       ),
	.i_rst_n_2d		( rst_delay_tree[1]    ),
	.i_rst_n_4d		( rst_delay_tree[3]    ),
	.i_level_data 	( i_level3_data  ),
	.i_seed			({8{1'b0}}       )	,
	.i_quantize1  	( 1'b0   ),
	//in fun compare  mode, turn off the sp-mash 
	`ifdef TEST_WITH_REF
	.i_quantize2  	( 1'b0 ),
	.i_quantize3  	( 1'b0   ),	
	`else
	.i_quantize2  	( o_quantize1 ),
	.i_quantize3  	( o_quantize2   ),	
	`endif
	
	.o_quantize1  	( w_quantize31   ),
	.o_quantize2  	( w_quantize32   ),
	.o_quantize3  	( w_quantize33   )
);

endmodule