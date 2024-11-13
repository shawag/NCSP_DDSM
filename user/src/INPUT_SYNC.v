`include "Timescale.v"
module INPUT_SYNC
(
    input      		i_clk,
    input     		i_rst,

    input [11:0] 	i_seed,
	input [1:0]		i_sel_order,
	input [3:0]		i_mash_bit,
	input			i_mashreseten,
	input			i_phaseadjusten,
	input			i_sel_frac,

    output [11:0] 	o_seed,
	output [1:0]	o_sel_order,
	output [3:0]	o_mash_bit,
	output			o_mashreseten,
	output			o_phaseadjusten,

	output			o_sel_frac
);
reg [11:0] 	r_seed;
reg [1:0]	r_sel_order;
reg [3:0]	r_mash_bit;
reg 		r_mashreseten;
reg 		r_phaseadjusten;
reg 		r_sel_frac;

assign o_seed = r_seed;
assign o_sel_order = r_sel_order;
assign o_mash_bit = r_mash_bit;
assign o_mashreseten = r_mashreseten;
assign o_phaseadjusten = r_phaseadjusten;
assign o_sel_frac = r_sel_frac;

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_seed <= {12{1'b0}};
		r_sel_order <= {2{1'b0}};
		r_mash_bit <= {4{1'b0}};
		r_mashreseten <= 1'b0;
		r_phaseadjusten <= 1'b0;
		r_sel_frac <= 1'b0;
    end
    else begin
        r_seed <= i_seed;
        r_sel_order <= i_sel_order;
        r_mash_bit <= i_mash_bit;
        r_mashreseten <= i_mashreseten;
        r_phaseadjusten <= i_phaseadjusten;
        r_sel_frac <= i_sel_frac;
    end
end
endmodule