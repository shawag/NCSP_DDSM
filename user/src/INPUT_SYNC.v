`include "Timescale.v"
module INPUT_SYNC
(
    input      		i_clk,
    input     		i_ff_rst,

    input [11:0] 	i_seed,
	input [1:0]		i_sel_order,
	input [3:0]		i_mash_bit,
	input			i_mashreseten,
	input			i_phaseadjusten,
	input			i_sel_frac,

    output [11:0] 	o_seed,
	output [1:0]	o_sel_order,
	output [7:0]	o_sum_sel,
    output [8:0]    o_cout_sel,
	output			o_mashreseten,
	output			o_phaseadjusten,

	output			o_sel_frac
);
reg [11:0] 	r_seed;
reg [1:0]	r_sel_order;
reg [3:0]   r_mash_bit;

reg [7:0]	 r_sum_sel;
reg [8:0]    r_cout_sel;
reg 		r_mashreseten;
reg 		r_phaseadjusten;
reg 		r_sel_frac;

assign o_seed = r_seed;
assign o_sel_order = r_sel_order;
assign o_mashreseten = r_mashreseten;
assign o_phaseadjusten = r_phaseadjusten;
assign o_sel_frac = r_sel_frac;
assign o_sum_sel = r_sum_sel;
assign o_cout_sel = r_cout_sel;

always @(posedge i_clk or posedge i_ff_rst) begin
    if(i_ff_rst) begin
        r_sum_sel <= {8{1'b0}};
		r_cout_sel <= {9{1'b0}};
    end
    else begin
        case(r_mash_bit)
            4'h0:begin
                r_sum_sel <= {8{1'b0}};
				r_cout_sel <= {{8{1'b0}},1'b1};
            end
            4'h1:begin
                r_sum_sel <= {{7{1'b0}},1'b1};
				r_cout_sel <= {{7{1'b0}},1'b1,1'b0};
            end
            4'h2:begin
                r_sum_sel <= {{6{1'b0}},{2{1'b1}}};
                r_cout_sel <= {{6{1'b0}},1'b1,{2{1'b0}}}; 
            end
            4'h3:begin
                r_sum_sel <= {{5{1'b0}},{3{1'b1}}};
                r_cout_sel <= {{5{1'b0}},1'b1,{3{1'b0}}};
            end
            4'h4:begin
                r_sum_sel <= {{4{1'b0}},{4{1'b1}}};
                r_cout_sel <= {{4{1'b0}},1'b1,{4{1'b0}}};
            end
            4'h5:begin
                r_sum_sel <= {{3{1'b0}},{5{1'b1}}};
                r_cout_sel <= {{3{1'b0}},1'b1,{5{1'b0}}};
            end
            4'h6:begin
                r_sum_sel <= {{2{1'b0}},{6{1'b1}}};
                r_cout_sel <= {{2{1'b0}},1'b1,{6{1'b0}}};
            end
            4'h7:begin
                r_sum_sel <= {1'b0,{7{1'b1}}};
                r_cout_sel <= {1'b0,1'b1,{7{1'b0}}};
            end
            4'h8:begin
                r_sum_sel <= {8{1'b1}};
                r_cout_sel <= {1'b1,{8{1'b0}}};
            end
            default:begin
                r_sum_sel <= {8{1'b1}};
                r_cout_sel <= {1'b1,{8{1'b0}}};
            end
        endcase
    end
end

always @(posedge i_clk or posedge i_ff_rst) begin
    if(i_ff_rst) begin
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