`include "Timescale.v"
module EFM_SEL #(
    parameter P_DATA_WIDTH = 8
)
(
    input                       i_clk       ,
    input                       i_rst_n     ,
    input [7:0]                 i_sum_sel    ,
    input [8:0]                 i_cout_sel,
    input [7:0]                 i_efm_data       ,
    input [7:0]                 i_seed          ,
    input                       i_quantize     ,
    output [7:0]                o_efm_data      ,
    output                      o_quantize    
);

reg ro_quantize;
reg r_quantize;
wire [7:0] w_sum; 
wire [7:0] w_cout_bit;
reg [7:0] r_sum;
assign o_quantize = ro_quantize;
assign o_efm_data = r_sum & i_sum_sel;


always @(*) begin
    case(1'b1)
        i_cout_sel[0]:begin
            r_quantize = i_quantize;
        end
        i_cout_sel[1]:begin
            r_quantize = w_cout_bit[0];
        end
        i_cout_sel[2]:begin
            r_quantize = w_cout_bit[1];
        end
        i_cout_sel[3]:begin
            r_quantize = w_cout_bit[2];
        end
        i_cout_sel[4]:begin
            r_quantize = w_cout_bit[3];
        end
        i_cout_sel[5]:begin
            r_quantize = w_cout_bit[4];
        end
        i_cout_sel[6]:begin
            r_quantize = w_cout_bit[5];
        end
        i_cout_sel[7]:begin
            r_quantize = w_cout_bit[6];
        end
        i_cout_sel[8]:begin
            r_quantize = w_cout_bit[7];
        end
        default:begin
            r_quantize = w_cout_bit[7];
        end
    endcase
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        r_sum  <= i_seed;
    else
        r_sum  <= w_sum; 
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        ro_quantize <= 1'b0;
    else
        ro_quantize <= r_quantize;
end

PIPELINE_ADDER 
u_PIPELINE_ADDER(
	.i_clk       	( i_clk           ),
	.i_rst_n    	( i_rst_n         ),
	.i_a        	( i_efm_data      ),
	.i_b        	( r_sum      ),
	.i_cin      	( i_quantize      ),
	.o_sum       	( w_sum      ),
	.o_cout_bit  	( w_cout_bit      )
);


endmodule //EFM
