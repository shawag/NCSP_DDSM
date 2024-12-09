`include "Timescale.v"
module PIPELINE_ADDER #(
    parameter P_DATA_WIDTH = 8
)
(  
    input               i_clk   ,
    input               i_rst_n ,
    input [7:0] i_a     ,
    input [7:0] i_b     ,
    input       i_cin   ,
    output [7:0] o_sum  ,
    output [7:0] o_cout_bit   
);


wire  [3:0] cout_low_bit;
wire  [3:0] cout_high_bit; 
wire  [3:0] sum_high;
wire  [3:0] sum_low;

reg [3:0]   r_cout_bit_low;
reg [3:0]   r_sum_low;
reg [3:0]   r_a_high;
reg [3:0]   r_b_high;

always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_cout_bit_low <= {4{1'b0}};
        r_sum_low <=  {4{1'b0}};
        r_a_high   <= {4{1'b0}};
        r_b_high   <= {4{1'b0}};
    end
    else begin
        r_cout_bit_low <= cout_low_bit;
        r_sum_low <= sum_low;
        r_a_high   <= i_a[7:4];
        r_b_high   <= i_b[7:4];
    end
end

assign o_sum = {sum_high, r_sum_low};
assign o_cout_bit = {cout_high_bit, r_cout_bit_low};

ADDER_LCA_4BIT 
u0_ADDER_LCA_4BIT(
	.i_a    	( i_a[3:0]),
	.i_b    	( i_b[3:0]),
	.i_cin  	( i_cin   ),
	.o_sum  	( sum_low),
	.o_cout_bit ( cout_low_bit  )
);

ADDER_LCA_4BIT 
u1_ADDER_LCA_4BIT(
	.i_a    	( r_a_high),
	.i_b    	( r_b_high),
	.i_cin  	( r_cout_bit_low[3]),
	.o_sum  	( sum_high),
    .o_cout_bit ( cout_high_bit  )
);


endmodule