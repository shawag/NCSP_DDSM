`include "Timescale.v"
module OUTPUT_GEN (
    input           i_clk,
    input           i_rst_n,

    input [7:0]     i_int,
    input [3:0]     i_frac,

    output [7:0]    o_mash_out  
);

reg [7:0] r_int_1d;
reg [7:0] r_mash_out;

wire [7:0] w_sum;

assign o_mash_out = r_mash_out;

always @ (posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        r_int_1d <= {8{1'b0}};
    else
        r_int_1d <= i_int;
end

always @ (posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        r_mash_out <= {8{1'b0}};
    else
        r_mash_out <= w_sum;
end


ADDER_BASIC #(
	.P_DATA_WIDTH 	( 8  ))
u0_ADDER_BASIC(
	.i_a    	( r_int_1d   ),
	.i_b    	( {{5{i_frac[3]}},i_frac[2:0]}),
	.i_cin  	( 1'b0   ),
	.o_sum  	( w_sum   ),
	.o_cout 	(         )
);
    
endmodule //OUTPUT_GEN
