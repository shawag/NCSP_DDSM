/*
 * @Author: shawag 
 * @Date: 2025-01-03 10:22:17 
 * @Last Modified by: shawag
 * @Last Modified time: 2025-01-03 11:25:56
 */
 `include "../src/timescale.v"
 `define CLK_PERIOD 10
 //`define RES_CAL
 //`define SYS_TEST 
 `define FUN_TEST
// `define MODE_TEST
module TB_DSM_COMP();

//dut signals
//input signal for both
reg [7:0]    N;
reg [23:0]   Kin;
reg [11:0]   phaseAdd;

reg [3:0]    mash_bit;
reg [11:0]  seed;
reg MASH_EN, MASH_POL, RESET, clk, mashResetEn, phaseAdjustEn, sel_frac,ff_rst;
//input signal for test module
reg [1:0]    sel_order;
//input signal for ref_module
reg         sel_2nd_order;
reg         sel_3rd_order;
//output signal for test module
wire [7:0]  mash_out;
wire [3:0]  sd_int;
//output signal for ref_module
wire [7:0]  mash_out_ref;
wire [3:0]  sd_int_ref;

//input signal for ref_module
reg [7:0]   sel_sum;
reg [8:0]   sel_carry;
//output file for test module
integer file_out_t;
//output file for ref module
integer file_out_r;
reg [4:0]   mashbitplus16;
real 		frac_res_out;
integer		t_start;
integer		t_end;


//delay signal for test module
reg [7:0]  sum_1_l_t_4d = 0;
reg [7:0]  sum_1_i_t_2d = 0;
reg [23:0]  sum_1_r_6d = 0;

reg [7:0]  sum_2_l_t_4d = 0;
reg [7:0]  sum_2_i_t_2d = 0;
reg [23:0]  sum_2_r_8d = 0;

reg [7:0]  sum_3_l_t_4d = 0;
reg [7:0]  sum_3_i_t_2d = 0;
reg [23:0]  sum_3_r_10d = 0;

reg         nc_net_in_1_r_5p5d = 0;
reg         nc_net_in_2_r_7p5d = 0;
reg         nc_net_in_3_r_9p5d = 0;
//inner signal
//sum stage 1 for test
wire [7:0] sum_1_m_t = u_test.u_NCSP_MASH.u0_EFM_CHAIN.u0_EFM_SEL.o_efm_data;
wire [7:0] sum_1_i_t = u_test.u_NCSP_MASH.u1_EFM_CHAIN.u0_EFM.o_efm_data;
wire [7:0] sum_1_l_t = u_test.u_NCSP_MASH.u2_EFM_CHAIN.u0_EFM.o_efm_data;
wire [23:0] sum_1_t = {sum_1_m_t,sum_1_i_t_2d,sum_1_l_t_4d};

wire [7:0] sum_2_m_t = u_test.u_NCSP_MASH.u0_EFM_CHAIN.u1_EFM_SEL.o_efm_data;
wire [7:0] sum_2_i_t = u_test.u_NCSP_MASH.u1_EFM_CHAIN.u1_EFM.o_efm_data;
wire [7:0] sum_2_l_t = u_test.u_NCSP_MASH.u2_EFM_CHAIN.u1_EFM.o_efm_data;
wire [23:0] sum_2_t = {sum_2_m_t,sum_2_i_t_2d,sum_2_l_t_4d};

wire [7:0] sum_3_m_t = u_test.u_NCSP_MASH.u0_EFM_CHAIN.u2_EFM_SEL.o_efm_data;
wire [7:0] sum_3_i_t = u_test.u_NCSP_MASH.u1_EFM_CHAIN.u2_EFM.o_efm_data;
wire [7:0] sum_3_l_t = u_test.u_NCSP_MASH.u2_EFM_CHAIN.u2_EFM.o_efm_data;
wire [23:0] sum_3_t = {sum_3_m_t,sum_3_i_t_2d,sum_3_l_t_4d};

wire nc_net_in_1_t = u_test.u_NC_NETWORK.i_quantize1;
wire nc_net_in_2_t = u_test.u_NC_NETWORK.i_quantize2;
wire nc_net_in_3_t = u_test.u_NC_NETWORK.i_quantize3;

//sum stage 1 for ref
wire [23:0] sum_1_r = u_ref.K106.sum;
wire [23:0] sum_2_r = u_ref.K86.sum;
wire [23:0] sum_3_r = u_ref.K87.sum;

wire nc_net_in_1_r = u_ref.K106.Cout;
wire nc_net_in_2_r = u_ref.K86.Cout;
wire nc_net_in_3_r = u_ref.K87.Cout;
//test signal delay for data compare
always @(*) begin
	 sum_1_l_t_4d <=  #(4*`CLK_PERIOD) sum_1_l_t;
	 sum_1_i_t_2d <=  #(2*`CLK_PERIOD) sum_1_i_t;
	 sum_1_r_6d <=  #(6*`CLK_PERIOD) sum_1_r;

	 sum_2_l_t_4d <=  #(4*`CLK_PERIOD) sum_2_l_t;
	 sum_2_i_t_2d <=  #(2*`CLK_PERIOD) sum_2_i_t;
	 sum_2_r_8d <=  #(8*`CLK_PERIOD) sum_2_r;

	 sum_3_l_t_4d <=  #(4*`CLK_PERIOD) sum_3_l_t;
	 sum_3_i_t_2d <=  #(2*`CLK_PERIOD) sum_3_i_t;
	 sum_3_r_10d <=  #(10*`CLK_PERIOD) sum_3_r;

	 nc_net_in_1_r_5p5d <=  #(5.5*`CLK_PERIOD) nc_net_in_1_r;
	 nc_net_in_2_r_7p5d <=  #(7.5*`CLK_PERIOD) nc_net_in_2_r;
	 nc_net_in_3_r_9p5d <=  #(9.5*`CLK_PERIOD) nc_net_in_3_r;
end
//instantiation the test module
NCSP_MASH_TOP u_test(
	.i_clk           	( clk            ),
	.i_rst           	( RESET          ),
	.i_ff_rst			( ff_rst         ),
	.i_seed          	( seed           ),
	.i_phaseadd      	( phaseAdd       ),
	.i_sel_order     	( sel_order      ),
	.i_mash_bit      	( mash_bit       ),
	.i_mashreseten   	( mashResetEn    ),
	.i_phaseadjusten 	( phaseAdjustEn  ),
	.i_sel_frac      	( sel_frac       ),
	.i_int           	( N              ),
	.i_msb           	( Kin[23:16]     ),
	.i_isb           	( Kin[15:8]      ),
	.i_lsb           	( Kin[7:0]       ),
	.o_mash_out      	( mash_out       ),
    .o_frac             ( sd_int         )   
);

//instantiation the ref module
wea_pll_mashFast_topSeed24_fxV1 u_ref(
	.MASH_EN       	( MASH_EN        ),
	.MASH_POL      	( MASH_POL       ),
	.RESET         	( RESET          ),
	.clk           	( clk            ),
	.mashResetEn   	( mashResetEn    ),
	.phaseAdjustEn 	( phaseAdjustEn  ),
	.sel_2nd_order 	( sel_2nd_order  ),
	.sel_3rd_order 	( sel_3rd_order  ),
	.sel_frac      	( sel_frac       ),
	.N             	( N              ),
	.mash_out      	( mash_out_ref       ),
	.Kin           	( Kin            ),
	.sd_int        	( sd_int_ref         ),
	.phaseAdd      	( phaseAdd       ),
	.sel_sum       	( sel_sum        ),
	.sel_carry     	( sel_carry      ),
	.seed          	( seed           )
);


initial begin
$dumpfile("test.vcd");
$dumpvars(0);



end


//**************************************************
// clock generator
//**************************************************
initial begin:clk_gen
	$display("%t,INFO: clock period is %0dns",$time,`CLK_PERIOD);
    clk = 0;
    forever #((`CLK_PERIOD/2)) clk = ~clk;
end


//**************************************************
// reset generator
//**************************************************
task reset_gen;
begin
    #100 
    RESET = 0;
    #100
    RESET = 1;
    #100
    RESET = 0;
end
endtask

task sync_gen;
begin
	//SYNC signal is a pulse valid at least 2 clock cycle
    #(`CLK_PERIOD)
    RESET = 1;
    #(2*`CLK_PERIOD)
    RESET = 0; 
end
endtask


//**************************************************
// mashbit decoder task
//**************************************************
task mashbit_decoder;
input [3:0] mashbit;
//output [4:0] mashbit_res;
begin
	mashbitplus16 = mashbit + 16;
	//assign mashbit_res = mashbit + 5'd16;
	case(mashbit)
		4'd0: begin
			sel_sum = 8'b00000000;
			sel_carry = 9'b000000001;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=16",$time);
		end
		4'd1: begin
			sel_sum = 8'b00000001;
			sel_carry = 9'b000000010;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=17",$time);
		end
		4'd2: begin
			sel_sum = 8'b00000011;
			sel_carry = 9'b000000100;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=18",$time);
		end
		4'd3: begin
			sel_sum = 8'b00000111;
			sel_carry = 9'b000001000;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=19",$time);
			end
		4'd4: begin
			sel_sum = 8'b00001111;
			sel_carry = 9'b000010000;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=20",$time);
		end
		4'd5: begin
			sel_sum = 8'b00011111;
			sel_carry = 9'b000100000;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=21",$time);
		end
		4'd6: begin
			sel_sum = 8'b00111111;
			sel_carry = 9'b001000000;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=22",$time);
		end
		4'd7: begin
			sel_sum = 8'b01111111;
			sel_carry = 9'b010000000;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=23",$time);
		end
		4'd8: begin
			sel_sum = 8'b11111111;
			sel_carry = 9'b100000000;
			mash_bit = mashbit;
			$display("%t,INFO: mashbit=24",$time);
		end
		default: begin
			sel_sum = 8'b00000000;
			sel_carry = 9'b000000001;
			mash_bit = mashbit;
			$display("%t,ERROR: mashbit is invalid! mashbit set to 16",$time);
		end
	endcase
end
endtask
//**************************************************
// mashorder decoder task
//**************************************************
task mashorder_decoder;
input [1:0] mashorder;
begin
	case(mashorder)
		2'd1: begin
			sel_order = 2'b00;
            sel_2nd_order = 0;
			sel_3rd_order = 0;
			$display("%t,INFO: mashorder=1",$time);
		end
		2'd2: begin
			sel_order = 2'b01;
            sel_2nd_order = 1;
			sel_3rd_order = 0;
			$display("%t,INFO: mashorder=2",$time);
		end
		2'd3: begin
			sel_order = 2'b11;
            sel_2nd_order = 1;
			sel_3rd_order = 1;
			$display("%t,INFO: mashorder=3",$time);
		end
	default: begin
		sel_order = 2'b00;
        sel_2nd_order = 0;
		sel_3rd_order = 0;
		$display("%t,ERROR: mashorder is invalid! mashorder set to 1",$time);
	end
	endcase
end
endtask
//**************************************************
// phaseadjust_sync task
//**************************************************
task phaseadjust_sync;
input [11:0] phaseAdd_val;
begin
	$display("%t,INFO: phaseadjust_sync start, phaseadd value is %0d",$time,phaseAdd_val);
	mashResetEn = 0;
	phaseAdjustEn = 1;
	phaseAdd = phaseAdd_val;
	sync_gen;
	$display("%t,INFO: phaseadjust_sync end ",$time);
end
endtask
//**************************************************
// initseed_sync task
//**************************************************
task initseed_sync;
input [11:0] seed_val;
begin
	$display("%t,INFO: initseed_sync start, seed value is %0d",$time,seed_val);
	mashResetEn = 1;
	phaseAdjustEn = 0;
	seed = seed_val;
	reset_gen();
	$display("%t,INFO: initseed_sync end ",$time);
end
endtask
//**************************************************
// mash_set task
//**************************************************
task mash_set;
input mashen;
input mashpol;
input fracen;
begin
	MASH_EN = mashen;
	MASH_POL = mashpol;
	set_frac(fracen);
	if(mashen==1'b0)
		$display("%t,INFO: mash has not been activiated!",$time);
	else if(mashen==1'b1) begin
		$display("%t,INFO: mash has been activiacted!",$time);
		if(mashpol==1'b0)
			$display("%t,INFO: active clock edge is negedge",$time);	
		else
			$display("%t,INFO: active clock edge is posedge",$time);
	end
	else
		$display("%t,ERROR: system is error!",$time);
end

endtask 
//**************************************************
// set_frac task
//**************************************************
task set_frac;
input frac_en;
begin
	sel_frac = frac_en;
	if(frac_en==1'b0)
		$display("%t,INFO: interger mode",$time);
	else
		$display("%t,INFO: frac mode",$time);
end
endtask
//**************************************************
// number_set task
//**************************************************
task number_set;
input [7:0] n_val;
input [23:0] kin_val;
begin
   	
	frac_cal(kin_val);	
	N = n_val;
	Kin = kin_val;
	$display("%t,INFO: N=%0d, Kin=%0d",$time,n_val,kin_val);
end
endtask
//**************************************************
// frac_cal task
//**************************************************
task frac_cal;
input [23:0] kin_val;
begin:frac_cal
	real frac_res;
	frac_res = ($itor(kin_val))/($itor(((2**mashbitplus16)-1)));
	frac_res_out = frac_res;
	//frac_res = kin_val/((2**mashbitplus16)-1);
	$display("%t,INFO: frac_res=%.24f",$time,frac_res);
end
endtask
task res_cal;
begin:res_cal
	real res;
	integer cntn3;
	integer cntn2;
	integer cntn1;
	integer cnt0;
	integer cnt1;
	integer cnt2;
	integer cnt3;
	reg signed [127:0] input_accum;
	integer cnt;
	res = 0;
	input_accum = 0;
	cnt = 0;
	cntn3 = 0;	
	cntn2 = 0;
	cntn1 = 0;
	cnt0 = 0;
	cnt1 = 0;
	cnt2 = 0;
	cnt3=0;
	t_start = $time;
	while (((res-frac_res_out)/frac_res_out)>=0.001 || (res-frac_res_out)/frac_res_out<=-0.001)
	begin
		@(posedge clk)
		case($signed(sd_int))
		-3:
			cntn3 = cntn3+1;
		-2:
			cntn2 = cntn2+1;
		-1:
			cntn1 = cntn1+1;
		0:
			cnt0 = cnt0+1;
		1:
			cnt1 = cnt1+1;
		2:
			cnt2 = cnt2+1;
		3:
			cnt3 = cnt3+1;	
		endcase
		input_accum = input_accum + $signed(sd_int);
		cnt = cnt+1'b1;
		//res = $itor(input_accum)/$itor(cnt);
		res = $itor(input_accum)/($itor(cnt));
		//res = $itor(input_accum);
	end
	t_end = $time;
	$display("%t,INFO: res = %.24f", $time,res);
	$display("%t,INFO: error = %f", $time,(res-frac_res_out)/frac_res_out);
	$display("%t,INFO: time consume is %0d0ns, t_start = %0d0ns, t_end = %0d0ns,",$time,(t_end-t_start),t_start,t_end);
	$display("%t,INFO: cntn3=%0d, cntn2=%0d, cntn1=%0d, cnt0=%0d, cnt1=%0d, cnt2=%0d, cnt3=%0d",$time,
					cntn3,cntn2,cntn1,cnt0,cnt1,cnt2,cnt3);
	$display("%t,INFO: cntn3=%0f%%, cntn2=%0f%%, cntn1=%0f%%, cnt0=%0f%%, cnt1=%0f%%, cnt2=%0f%%, cnt3=%0f%%",$time,
					cntn3/($itor(cnt)),cntn2/($itor(cnt)),cntn1/($itor(cnt)),
					cnt0/($itor(cnt)),cnt1/($itor(cnt)),cnt2/($itor(cnt)),cnt3/($itor(cnt)));
	$display("%t,INFO: current res_cal end",$time);
end
endtask
//**************************************************
// output write to file task
//**************************************************
/*
task file_write;
//input file;
input fp;
input [3:0] data_in;
begin:file_write

    fp = $fopen("frac_out_t.txt","w");
    
    repeat(200) begin
        @(posedge clk);
        #1;
        $fdisplay(fp,"%d",$signed(data_in)); 
    end
	$fclose(fp);
end
endtask
*/

//**************************************************
//task group for 3 order frac mode, seed_init
//**************************************************
task frac_3order_16bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_16bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd0);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_3order_17bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_17bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd1);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_3order_18bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_18bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd2);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_3order_19bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_19bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd3);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask
task frac_3order_20bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_20bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd4);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_3order_21bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_21bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd5);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask
task frac_3order_22bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_22bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd6);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_3order_23bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_23bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd7);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_3order_24bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_3order_24bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd8);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

//**************************************************
//task group for 2 order frac mode, seed_init
//**************************************************
task frac_2order_16bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_16bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd0);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_2order_17bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_17bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd1);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_2order_18bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_18bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd2);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_2order_19bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_19bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd3);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask
task frac_2order_20bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_20bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd4);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_2order_21bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_21bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd5);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask
task frac_2order_22bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_22bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd6);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_2order_23bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_23bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd7);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_2order_24bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_2order_24bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd2);
	mashbit_decoder(4'd8);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

//**************************************************
//task group for 1 order frac mode, seed_init
//**************************************************
task frac_1order_16bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_16bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd0);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_1order_17bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_17bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd1);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_1order_18bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_18bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd2);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_1order_19bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_19bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd3);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask
task frac_1order_20bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_20bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd4);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_1order_21bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_21bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd5);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask
task frac_1order_22bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_22bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd6);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_1order_23bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_23bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd7);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask

task frac_1order_24bit;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
begin:frac_1order_24bit
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd8);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask
//**************************************************

task frac_xorder_xbit_phase;
input [3:0] bit_val;
input [1:0]	order_val;
input [7:0]	N_val;
input [23:0] Kin_val;
input [11:0] seed_val;
input [11:0] phase_val;
begin:frac_xorder_xbit_phase
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(order_val);
	mashbit_decoder(bit_val);
	number_set(N_val,Kin_val);
	initseed_sync(seed_val);
	//#(1*`CLK_PERIOD)
	phaseadjust_sync(phase_val);
	`ifdef RES_CAL
	res_cal();
	`endif
end
endtask
//**************************************************
// testbench
//**********
initial begin
	ff_rst = 0;
	N = 0;
	Kin = 0;
	phaseAdd = 0;
	sel_order = 0;
	mash_bit = 0;
	seed = 0;
	MASH_EN = 1; 
	MASH_POL = 0;
	RESET = 0;
	mashResetEn = 1;
	phaseAdjustEn = 0;
	sel_frac = 0;

    #10
	ff_rst = 1;
	
    #10
	ff_rst = 0;
	
	#50
	RESET = 1; 

	#50
	RESET = 0;
	//frac_3order_24bit(8'd255,24'h000001,12'd0);
	
	`ifdef MODE_TEST
	mash_set(1'b0,1'b1,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd1);
	number_set(8'd10,24'd1);
	initseed_sync(12'd0);
	#(50*`CLK_PERIOD)
	mash_set(1'b1,1'b0,1'b1);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd1);
	number_set(8'd10,24'd1);
	initseed_sync(12'd0);
	#(50*`CLK_PERIOD)
	mash_set(1'b1,1'b1,1'b0);
	mashorder_decoder(2'd1);
	mashbit_decoder(4'd1);
	number_set(8'd10,24'd1);
	initseed_sync(12'd0);
	#(50*`CLK_PERIOD)
	`endif
	`ifdef FUN_TEST
	frac_3order_24bit(8'd10,24'h111111,12'd0);
	file_out_t = $fopen("sum1_out_t.txt","w");
	file_out_r = $fopen("sum1_out_r.txt","w");
    repeat(2000) begin
        @(posedge clk);
        #1;
		if(sum_1_t != sum_1_r_6d)
			$display("%t,ERROR: sum_1_t=%0h, sum_1_r_6d=%0h",$time,sum_1_t,sum_1_r_6d);
		if(sum_2_t != sum_2_r_8d)
			$display("%t,ERROR: sum_2_t=%0h, sum_2_r_8d=%0h",$time,sum_2_t,sum_2_r_8d);
		if(sum_3_t != sum_3_r_10d)
			$display("%t,ERROR: sum_3_t=%0h, sum_3_r_10d=%0h",$time,sum_3_t,sum_3_r_10d);
		if(nc_net_in_1_t != nc_net_in_1_r_5p5d)
			$display("%t,ERROR: nc_net_in_1_t=%0d, nc_net_in_1_r_5p5d=%0d",$time,nc_net_in_1_t,nc_net_in_1_r_5p5d);
		if(nc_net_in_2_t != nc_net_in_2_r_7p5d)
			$display("%t,ERROR: nc_net_in_2_t=%0d, nc_net_in_2_r_7p5d=%0d",$time,nc_net_in_2_t,nc_net_in_2_r_7p5d);
		if(nc_net_in_3_t != nc_net_in_3_r_9p5d)
			$display("%t,ERROR: nc_net_in_3_t=%0d, nc_net_in_3_r_9p5d=%0d",$time,nc_net_in_3_t,nc_net_in_3_r_9p5d);
        $fdisplay(file_out_t,"%h",sum_1_t);
		$fdisplay(file_out_r,"%h",sum_1_r_6d); 
    end
	$fclose(file_out_t);
	$fclose(file_out_r);
	/*
    file_out_t = $fopen("frac_out_t.txt","w");
	file_out_r = $fopen("frac_out_r.txt","w");
    repeat(200) begin
        @(posedge clk);
        #1;
        $fdisplay(file_out_t,"%d",$signed(sd_int));
		$fdisplay(file_out_r,"%d",$signed(sd_int_ref)); 
    end
	$fclose(file_out_t);
	$fclose(file_out_r);
	*/
	#(200*`CLK_PERIOD);
	/*
	frac_3order_24bit(8'd10,24'h111000,12'h111);
	#(200*`CLK_PERIOD)
	frac_3order_24bit(8'd10,24'h111000,12'd0);
	#(200*`CLK_PERIOD)	
	frac_xorder_xbit_phase(4'd8,2'd3,8'd10,24'h111000,12'd0,12'h111);
	#(200*`CLK_PERIOD)
	$stop;
	*/
	$stop();
	`endif
	`ifdef SYS_TEST
	
	frac_1order_16bit(8'd10,24'h000001,12'd0);
	frac_1order_17bit(8'd10,24'h000001,12'd0);
	frac_1order_18bit(8'd10,24'h000001,12'd0);
	frac_1order_19bit(8'd10,24'h000001,12'd0);
	frac_1order_20bit(8'd10,24'h000001,12'd0);
	frac_1order_21bit(8'd10,24'h000001,12'd0);
	frac_1order_22bit(8'd10,24'h000001,12'd0);
	frac_1order_23bit(8'd10,24'h000001,12'd0);
	frac_1order_24bit(8'd10,24'h000001,12'd0);

	frac_2order_16bit(8'd10,24'h000001,12'd0);
	frac_2order_17bit(8'd10,24'h000001,12'd0);
	frac_2order_18bit(8'd10,24'h000001,12'd0);
	frac_2order_19bit(8'd10,24'h000001,12'd0);
	frac_2order_20bit(8'd10,24'h000001,12'd0);
	frac_2order_21bit(8'd10,24'h000001,12'd0);
	frac_2order_22bit(8'd10,24'h000001,12'd0);
	frac_2order_23bit(8'd10,24'h000001,12'd0);
	frac_2order_24bit(8'd10,24'h000001,12'd0);

	frac_3order_16bit(8'd10,24'h000001,12'd0);
	frac_3order_17bit(8'd10,24'h000001,12'd0);
	frac_3order_18bit(8'd10,24'h000001,12'd0);
	frac_3order_19bit(8'd10,24'h000001,12'd0);
	frac_3order_20bit(8'd10,24'h000001,12'd0);
	frac_3order_21bit(8'd10,24'h000001,12'd0);
	frac_3order_22bit(8'd10,24'h000001,12'd0);
	frac_3order_23bit(8'd10,24'h000001,12'd0);
	frac_3order_24bit(8'd10,24'h000001,12'd0);
	`endif
    /*
	frac_3order_16bit(8'd10,24'h000001,12'd4);
	$stop();
	/*
	/*
	mash_set(1'b1,1'b1,1'b1);
	mashorder_decoder(2'd3);
	mashbit_decoder(4'd8);
	number_set(8'd10,24'h000001);
	initseed_sync(12'd0);
	res_cal();
	*/
end
endmodule
