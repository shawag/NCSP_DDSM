`include "Timescale.v"
module PHASE_ADDER (
    input      i_clk,
    input      i_rst,
    input      i_rst_n,
    input      i_phaseadjusten,

    input [11:0] i_phaseadd,
    input [7:0]  i_msb,
    input [7:0]  i_isb,
    input [7:0]  i_lsb,

    output [7:0] o_msb,
    output [7:0] o_isb,
    output [7:0] o_lsb    
);

reg [11:0] r_phaseadd;
reg [7:0]  r_msb;
reg [7:0]  r_isb;
reg [7:0]  r_lsb;

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
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
    
endmodule //PHASE_ADDER
