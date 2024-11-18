`include "Timescale.v"
module CLK_SWITCH (
    input      clk_a,
    input      clk_b,
    input      rst_a,
    input      rst_b,
    input      clk_sel,

    output     clk_out
);

wire a1o;
reg  a1o_1d;
reg  a1o_2d;
reg  a1o_2d_sync;
wire a2o;

wire a3o;
reg  a3o_1d;
reg  a3o_2d;
reg  a3o_2d_sync;
wire a4o;

wire a1i;
wire a3i;

assign a1i = ~a3o_2d_sync;
assign a3i = ~a1o_2d_sync;

assign a1o = (~clk_sel) & a1i;

assign clk_out = a2o | a4o;

always @(posedge clk_a or posedge rst_a) begin
    if(rst_a) begin
        a1o_1d <= 1'b1;
        a1o_2d <= 1'b1;
        a1o_2d_sync <= 1'b1;
    end
    else begin
        a1o_1d <= a1o;
        a1o_2d <= a1o_1d;
        a1o_2d_sync <= a1o_2d;
    end  
end

CLKGT_9T1X ua_CLKGT_9T1X( 
    .CK  (clk_a), 
    .E   (a1o_2d),  
    .Z   (a2o)  
);

assign a3o = clk_sel & a3i;

always @(posedge clk_b or posedge rst_b) begin
    if(rst_b) begin
        a3o_1d <= 1'b0;
        a3o_2d <= 1'b0;
        a3o_2d_sync <= 1'b0;
    end
    else begin
        a3o_1d <= a3o;
        a3o_2d <= a3o_1d;
        a3o_2d_sync <= a3o_2d;
    end  
end

CLKGT_9T1X ub_CLKGT_9T1X( 
    .CK  (clk_b), 
    .E   (a3o_2d),  
    .Z   (a4o)  
);


endmodule //CLK_SWITCH
