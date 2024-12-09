`include "Timescale.v"
module EFM #(
    parameter P_DATA_WIDTH = 8
)
(
    input                       i_clk       ,
    input                       i_rst_n     ,
    input [7:0]                 i_efm_data       ,
    input [7:0]                 i_seed          ,
    input                       i_quantize     ,
    output [7:0]                o_efm_data      ,
    output                      o_quantize    
);
reg ro_quantize;
wire w_quantize;
wire [7:0] w_cout_bit;
assign o_quantize = ro_quantize;
assign w_quantize = w_cout_bit[7];

reg [7:0] r_efm_data;
wire [7:0] w_sum;
assign o_efm_data = r_efm_data;
always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        r_efm_data  <= i_seed;
    else
        r_efm_data  <= w_sum; 
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        ro_quantize <= 1'b0;
    else
        ro_quantize <= w_quantize;
end

PIPELINE_ADDER 
u_PIPELINE_ADDER(
	.i_clk       	( i_clk           ),
	.i_rst_n    	( i_rst_n         ),
	.i_a        	( i_efm_data      ),
	.i_b        	( w_sum      ),
	.i_cin      	( i_quantize      ),
	.o_sum       	( w_sum      ),
	.o_cout_bit  	( w_cout_bit      )
);


endmodule //EFM
