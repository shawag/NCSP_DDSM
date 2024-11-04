`include "Timescale.v"
module ADDER_BASIC #(
    parameter P_DATA_WIDTH = 3
)(
    input [P_DATA_WIDTH-1:0] i_a ,
    input [P_DATA_WIDTH-1:0] i_b ,
    input                    i_cin ,  

    output [P_DATA_WIDTH-1:0]  o_sum ,
    output [P_DATA_WIDTH-1:0]  o_cout
);

wire [P_DATA_WIDTH:0] g;
wire [P_DATA_WIDTH:0] p;
wire [P_DATA_WIDTH:0] c;

assign c[0] = i_cin;
assign p = i_a | i_b;
assign g = i_a & i_b;

assign  c[1] = g[0] | (p[0]&c[0]);
assign  c[2] = g[1] | (p[1]&(g[0] | (p[0]&c[0])));
assign  c[3] = g[2] | (p[2]&(g[1]|(p[1]&(g[0]|(p[0]&c[0])))));

assign o_sum = p ^ c[2:0];

assign o_cout = c[3:1];


endmodule