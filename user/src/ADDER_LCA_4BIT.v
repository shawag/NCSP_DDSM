`include "Timescale.v"
module ADDER_LCA_4BIT (
    input [3:0] i_a ,
    input [3:0] i_b ,
    input       i_cin ,  

    output [3:0]  o_sum ,
    //cout for every bit
    output [3:0]  o_cout_bit 
);

wire [4:0] g;
wire [4:0] p;
wire [4:0] c;

assign c[0] = i_cin;
assign p = i_a | i_b;
assign g = i_a & i_b;

assign  c[1] = g[0] | (p[0]&c[0]);
assign  c[2] = g[1] | (p[1]&(g[0] | (p[0]&c[0])));
assign  c[3] = g[2] | (p[2]&(g[1]|(p[1]&(g[0]|(p[0]&c[0])))));
assign  c[4] = g[3] | (p[3]&(g[2]|(p[2]&(g[1]|(p[1]&(g[0]|(p[0]&c[0])))))));

assign o_sum = p ^ c[3:0];

assign o_cout_bit = c[4:1];


endmodule