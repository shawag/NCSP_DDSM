`include "Timescale.v"
module PHASE_ADDER (
    input      i_clk,
    input      i_rst,
    input      i_phaseadjusten,

    input [11:0] i_phaseadd,
    input [7:0]  i_msb,
    input [7:0]  i_isb,
    input [7:0]  i_lsb,

    output [7:0] o_msb,
    output [7:0] o_isb,
    output [7:0] o_lsb    
);
wire        seq_in;
wire        seq_valid;
wire [11:0] phaseadd_sel;
reg [11:0]  r_phaseadd;
reg [7:0]   r_msb;
reg [7:0]   r_isb;
reg [7:0]   r_lsb;
reg [1:0]   r_seq;

assign seq_in = i_phaseadjusten & i_rst;
assign seq_valid = seq_in & r_seq[0] & (~r_seq[1]);
assign phaseadd_sel = seq_valid ? r_phaseadd : {12{1'b0}};
assign o_isb[3:0] = r_isb[3:0];
assign o_lsb = r_lsb;

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_phaseadd <= {12{1'b0}};
        r_msb <= {8{1'b0}};
        r_isb <= {8{1'b0}};
        r_lsb <= {8{1'b0}};
    end
    else begin
        r_phaseadd <= i_phaseadd;
        r_msb <= i_msb;
        r_isb <= i_isb;
        r_lsb <= i_lsb;
    end
end

always @(posedge i_clk or negedge i_phaseadjusten) begin
    if(~i_phaseadjusten)
        r_seq <= 2'b00;
    else
        r_seq <= {r_seq[0], seq_in};
end

ADDER_BASIC #(
	.P_DATA_WIDTH 	( 12  ))
u1_ADDER_BASIC(
	.i_a    	( {r_msb,r_isb[7:4]}),
	.i_b    	( phaseadd_sel   ),
	.i_cin  	( 1'b0   ),
	.o_sum  	( {o_msb,o_isb[7:4]}   ),
	.o_cout 	(         )
);

    
endmodule //PHASE_ADDER
