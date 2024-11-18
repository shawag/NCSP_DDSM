`include "Timescale.v"
module NCSP_MASH #(
    parameter P_DATA_WIDTH = 8
)
(
    input                    i_clk,
    input                    i_rst_n,
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
wire w_quantize21;
wire w_quantize22;
wire w_quantize23;

wire w_quantize31;
wire w_quantize32;
wire w_quantize33;


EFM_CHAIN_SEL
u0_EFM_CHAIN(
	.i_clk        	( i_clk         ),
	.i_rst_n      	( i_rst_n       ),
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
	.i_rst_n      	( i_rst_n       ),
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
	.i_level_data 	( i_level3_data  ),
	.i_seed			({8{1'b0}}       )	,
	.i_quantize1  	( 1'b0   ),
	.i_quantize2  	( o_quantize1   ),
	.i_quantize3  	( o_quantize2   ),
	.o_quantize1  	( w_quantize31   ),
	.o_quantize2  	( w_quantize32   ),
	.o_quantize3  	( w_quantize33   )
);

endmodule