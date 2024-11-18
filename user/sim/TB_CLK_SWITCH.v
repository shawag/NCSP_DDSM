`timescale 1ns/1ps

module TB_CLK_SWITCH;
//------------------------------------
reg             clk_a   ;
reg             clk_b   ;
reg             rst_a  ;
reg             rst_b  ;
reg             clk_sel     ;

wire            clk_out;


initial
begin
    clk_a = 1'b0;
    
    #10;
    forever
    begin
        #5 clk_a = ~clk_a;
    end
end


initial
begin
    clk_b = 1'b1;
    
    #11;
    forever
    begin
        #5 clk_b = ~clk_b;
    end
end


initial
begin
    rst_a = 1'b1;
    #1e3;
    @(posedge clk_a) rst_a = 1'b0;
end


initial
begin
    rst_b = 1'b1;
    #1e3;
    @(negedge clk_b) rst_b = 1'b0;
end


initial
begin
    clk_sel = 1'b0;

    #5e3   
    clk_sel = 1'b1;
    #5e3   
    clk_sel = 1'b0;
    #5e3   
    $finish;
end



CLK_SWITCH u_CLK_SWITCH(
	.clk_a   	( clk_a    ),
	.clk_b   	( clk_b    ),
	.rst_a   	( rst_a    ),
	.rst_b   	( rst_b    ),
	.clk_sel 	( clk_sel  ),
	.clk_out 	( clk_out  )
);



endmodule


