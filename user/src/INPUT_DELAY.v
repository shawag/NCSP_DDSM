`include "Timescale.v"
module INPUT_DELAY
(
    input                    i_clk,
    input                    i_rst_n,

    input [7:0] i_msb,
    input [7:0] i_isb,
    input [7:0] i_lsb,

    output [7:0] o_msb,
    output [7:0] o_isb,
    output [7:0] o_lsb    
    
);

assign o_lsb = i_lsb;

genvar i;
generate
    for(i=0; i<8; i=i+1) begin:msb_delay
        DELAY_UNIT #(
        	.P_DELAY_CYCLE 	( 2  ))
        u0_DELAY_UNIT_msb(
        	.i_clk   	( i_clk    ),
        	.i_rst_n 	( i_rst_n  ),
        	.i_in    	( i_msb[i]     ),
        	.o_delay 	( o_msb[i]  )
        );
    end
endgenerate


generate
    for(i=0; i<8; i=i+1) begin:isb_delay
        DELAY_UNIT #(
        	.P_DELAY_CYCLE 	( 1  ))
        u2_DELAY_UNIT_isb2(
        	.i_clk   	( i_clk    ),
        	.i_rst_n 	( i_rst_n  ),
        	.i_in    	( i_isb[i]     ),
        	.o_delay 	( o_isb[i]  )
        );
    end
endgenerate



endmodule