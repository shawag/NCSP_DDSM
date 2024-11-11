`include "Timescale.v"
module NCSP_MASH_TOP 
(
    input      		i_clk,
    input     		i_rst,

	input [11:0] 	i_seed,
	input [11:0]	i_phaseadd,
	input [1:0]		i_sel_order,
	input [3:0]		i_mash_bit,
	input			i_mashreseten,
	input			i_phaseadjusten,

	input			i_sel_frac,
	input [7:0] 	i_int,

    input [7:0] 	i_msb,
    input [7:0] 	i_isb,
    input [7:0] 	i_lsb,

    output [7:0] 	o_mash_out
    
);
wire				w_rst_n;
wire [7:0] 			msb;
wire [7:0] 			isb;
wire [7:0] 			lsb;
wire [7:0] 			w_msb;
wire [7:0] 			w_isb;
wire [7:0] 			w_lsb;
wire [3:0]			w_frac;

wire                w_quantize1;
wire                w_quantize2;
wire                w_quantize3;
wire				w_sel_2order;
wire				w_sel_3_order;

wire [3:0]          w_network;
wire [3:0]			w_frac_sel;

assign w_sel_2order = (i_sel_order[0])? w_quantize2:1'b0;
assign w_sel_3order = (i_sel_order[1])? w_quantize3:1'b0;
assign w_frac_sel = (i_sel_frac)? w_frac:4'b0;
assign w_rst_n = ~(i_mashreseten & i_rst);


PHASE_ADDER u_PHASE_ADDER(
	.i_clk           	( i_clk            ),
	.i_rst           	( i_rst            ),
	.i_rst_n         	( i_rst_n          ),
	.i_phaseadjusten 	( i_phaseadjusten  ),
	.i_phaseadd      	( i_phaseadd       ),
	.i_msb           	( i_msb            ),
	.i_isb           	( i_isb            ),
	.i_lsb           	( i_lsb            ),
	.o_msb           	( msb            ),
	.o_isb           	( isb            ),
	.o_lsb           	( lsb            )
);


INPUT_STAGE 
u_INPUT_STAGE_frac(
	.i_clk   	( i_clk    ),
	.i_rst_n 	( w_rst_n  ),
	.i_msb   	( msb    ),
	.i_isb  	( isb    ),
	.i_lsb   	( lsb    ),
	.o_msb   	( w_msb    ),
	.o_isb  	( w_isb    ),
	.o_lsb   	( w_lsb    )
);


NCSP_MASH 
u_NCSP_MASH(
	.i_clk         	( i_clk          ),
	.i_rst_n       	( w_rst_n        ),
	.i_mash_bit		( i_mash_bit     ),
	.i_seed		    ( i_seed       ),
	.i_level1_data 	( w_msb          ),
	.i_level2_data 	( w_isb         ),
	.i_level3_data 	( w_lsb         ),
	.o_quantize1   	( w_quantize1    ),
	.o_quantize2   	( w_quantize2    ),
	.o_quantize3   	( w_quantize3    )
);



NC_NETWORK u_NC_NETWORK(
	.i_clk       	( i_clk        ),
	.i_rst_n     	( w_rst_n      ),
	.i_quantize1 	( w_quantize1  ),
	.i_quantize2 	( w_sel_2order ),
	.i_quantize3 	( w_sel_3order ),
	.o_network   	( w_network    )
);



OUTPUT_STAGE u_OUTPUT_STAGE_frac(
	.i_clk     	( i_clk      ),
	.i_rst_n   	( w_rst_n    ),
	.i_network 	( w_network  ),
	.o_frac    	( w_frac     )
);


OUTPUT_GEN u_OUTPUT_GEN(
	.i_clk      	( i_clk       ),
	.i_rst_n    	( w_rst_n     ),
	.i_int      	( i_int       ),
	.i_frac     	( w_frac_sel  ),
	.o_mash_out 	( o_mash_out  )
);


   
endmodule //NC_MASH_TOP
