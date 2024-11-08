`include "Timescale.v"
module EFM_SEL #(
    parameter P_DATA_WIDTH = 8
)
(
    input                       i_clk       ,
    input                       i_rst_n     ,
    input [3:0]                 i_mash_bit    ,
    input [7:0]                 i_efm_data       ,
    input [7:0]                 i_seed          ,
    input                       i_quantize     ,
    output [7:0]                o_efm_data      ,
    output                      o_quantize    
);
reg [7:0] r_efm_data;
reg ro_quantize;
reg r_quantize;
wire [7:0] w_sum; 
wire [7:0] w_cout_bit;
assign o_quantize = ro_quantize;
assign o_efm_data = r_efm_data;
reg [7:0] r_sum;

always @(*) begin
    case(i_mash_bit)
        4'h0:begin
            r_efm_data = {8{1'b0}};
            r_quantize = i_quantize;
        end
        4'h1:begin
            r_efm_data = {{7{1'b0}},r_sum[0]};
            r_quantize = w_cout_bit[0];
        end
        4'h2:begin
            r_efm_data = {{6{1'b0}},r_sum[1:0]};
            r_quantize = w_cout_bit[1];
        end
        4'h3:begin
            r_efm_data = {{5{1'b0}},r_sum[2:0]};
            r_quantize = w_cout_bit[2];
        end
        4'h4:begin
            r_efm_data = {{4{1'b0}},r_sum[3:0]};
            r_quantize = w_cout_bit[3];
        end
        4'h5:begin
            r_efm_data = {{3{1'b0}},r_sum[4:0]};
            r_quantize = w_cout_bit[4];
        end
        4'h6:begin
            r_efm_data = {{2{1'b0}},r_sum[5:0]};
            r_quantize = w_cout_bit[5];
        end
        4'h7:begin
            r_efm_data = {{1{1'b0}},r_sum[6:0]};
            r_quantize = w_cout_bit[6];
        end
        4'h8:begin
            r_efm_data = r_sum[7:0];
            r_quantize = w_cout_bit[7];
        end
        default:begin
            r_efm_data = r_sum[7:0];
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
