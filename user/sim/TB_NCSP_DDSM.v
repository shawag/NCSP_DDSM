/*
 * @Author: shawag 
 * @Date: 2024-11-25 09:33:05 
 * @Last Modified by: shawag
 * @Last Modified time: 2024-11-25 17:00:26
 */
 `include "../src/timescale.v"
 `define CLK_PERIOD 10
 `define RES_CAL
 //`define SYS_TEST 
 `define FUN_TEST
// `define MODE_TEST
module TB_NCSP_DDSM();

//dut signals
//input signal
reg [7:0]    N;
reg [23:0]   Kin;
reg [11:0]   phaseAdd;
reg [1:0]    sel_order;
reg [3:0]    mash_bit;
reg [11:0]  seed;
reg MASH_EN, MASH_POL, RESET, clk, mashResetEn, phaseAdjustEn, sel_frac,ff_rst;
//output signal
wire [7:0]  mash_out;
wire [3:0]  sd_int;

reg [4:0]   mashbitplus16;
real 		frac_res_out;
integer		t_start;
integer		t_end;
//instantiation the top module
NCSP_MASH_TOP u_NCSP_MASH_TOP(
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
    .o_frac             (        sd_int         )   
);


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
	ff_rst = 0;
    #100
    RESET = 1;
	ff_rst = 1;
    #100
    RESET = 0;
	ff_rst = 0; 
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
    mash_bit = mashbit;
	case(mashbit)
		4'd0: begin
			$display("%t,INFO: mashbit=16",$time);
		end
		4'd1: begin
			$display("%t,INFO: mashbit=17",$time);
		end
		4'd2: begin
			$display("%t,INFO: mashbit=18",$time);
		end
		4'd3: begin
			$display("%t,INFO: mashbit=19",$time);
			end
		4'd4: begin
			$display("%t,INFO: mashbit=20",$time);
		end
		4'd5: begin
			$display("%t,INFO: mashbit=21",$time);
		end
		4'd6: begin
			$display("%t,INFO: mashbit=22",$time);
		end
		4'd7: begin
			$display("%t,INFO: mashbit=23",$time);
		end
		4'd8: begin
			$display("%t,INFO: mashbit=24",$time);
		end
		default: begin
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
			$display("%t,INFO: mashorder=1",$time);
		end
		2'd2: begin
			sel_order = 2'b01;
			$display("%t,INFO: mashorder=2",$time);
		end
		2'd3: begin
			sel_order = 2'b11;
			$display("%t,INFO: mashorder=3",$time);
		end
	default: begin
		sel_order = 2'b00;
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
	#(20*`CLK_PERIOD)
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
	frac_1order_16bit(8'd10,24'h000001,12'd511);
	//#(50*`CLK_PERIOD)
	frac_1order_16bit(8'd10,24'h000001,12'd511);
	//#(50*`CLK_PERIOD)
	frac_1order_16bit(8'd10,24'h000001,12'd0);
	//#(50*`CLK_PERIOD)	
	frac_xorder_xbit_phase(4'd0,2'd1,8'd10,24'h000001,12'd0,12'd511);
	//#(50*`CLK_PERIOD)
	$stop;
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
