`include "Timescale.v"
module EFM_CHAIN #(
    parameter P_DATA_WIDTH = 8
)
( 
    input                    i_clk,
    input                    i_rst_n,
	input 					 i_rst_n_2d,
	input 					 i_rst_n_4d,

    input [7:0] 			 i_level_data,
	input [7:0] 			 i_seed,
    input                    i_quantize1,
    input                    i_quantize2,
    input                    i_quantize3,

    output                   o_quantize1,
    output                   o_quantize2,
    output                   o_quantize3
);

wire [7:0] 					 o_efm_data1;
wire [7:0] 					 o_efm_data2;

EFM 
u0_EFM(
	.i_clk      	( i_clk       ),
	.i_rst_n    	( i_rst_n     ),
	.i_efm_data 	( i_level_data),
	.i_seed     	( i_seed      ),
	.i_quantize 	( i_quantize1  ),
	.o_efm_data 	( o_efm_data1  ),
	.o_quantize 	( o_quantize1  )
);

EFM 
u1_EFM(
	.i_clk      	( i_clk       ),
	.i_rst_n    	( i_rst_n_2d     ),
	.i_efm_data 	( o_efm_data1),
	.i_seed     	( {8{1'b0}}      ),
	.i_quantize 	( i_quantize2  ),
	.o_efm_data 	( o_efm_data2  ),
	.o_quantize 	( o_quantize2  )
);

EFM
u2_EFM(
	.i_clk      	( i_clk       ),
	.i_rst_n    	( i_rst_n_4d     ),
	.i_efm_data 	( o_efm_data2),
	.i_seed     	( {8{1'b0}}      ),
	.i_quantize 	( i_quantize3  ),
	.o_efm_data 	(              ),
	.o_quantize 	( o_quantize3  )
);

endmodule //moduleName
