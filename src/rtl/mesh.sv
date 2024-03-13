// +FHDR-----------------------------------------------------------------------
// Copyright (c) 2004 Freescale Semiconductor, Inc. All rights reserved
 // Freescale Confidential Proprietary
 // ----------------------------------------------------------------------------
// FILE NAME      :
 // DEPARTMENT     :
 // AUTHOR         :
 // AUTHOR’S EMAIL :
 // ----------------------------------------------------------------------------
// RELEASE HISTORY
 // VERSION DATE        AUTHOR  DESCRIPTION
 // 1.0  YYYY-MM-DD  name       
// ----------------------------------------------------------------------------
// KEYWORDS    : General file searching keywords, leave blank if none.
 // ----------------------------------------------------------------------------
// PURPOSE     : Short description of functionality
 // ----------------------------------------------------------------------------
// PARAMETERS
 //     PARAM NAME      RANGE    : DESCRIPTION       : DEFAULT : UNITS
 // e.g.DATA_WIDTH     [32,16]   : width of the data : 32  :
 // ----------------------------------------------------------------------------
// REUSE ISSUES
 //   Reset Strategy      :
//   Clock Domains        :
//   Critical Timing      :
//   Test Features        :
//   Asynchronous I/F     :
//   Scan Methodology     :
//   Instantiations       :
//   Synthesizable (y/n)  :
//   Other      		  :
 // -FHDR-----------------------------------------------------------------------


`include "global.v"
module mesh(
	input clk,
	input rst_n,
	
	// pe config
	input [7:0] pe_enable,
	input [7:0] pe_dbg_mode_wire,
	input [23:0] pe_send_num_wire,
	input [23:0] pe_receive_num_wire,
	input [31:0] pe_rate_wire,
	input [191:0] pe_dst_seq_wire,
	input [31:0] pe_mode_wire,
	
	
	input [7:0] pe_flush_wire,
	
	output [7:0] pe_task_receive_finish_flag,
	output [7:0] pe_task_send_finish_flag
	
);

// parameter
parameter [23:0] ROUTER_ADDRESS_PAR  = {3'd6,3'd5,3'd2,3'd1,3'd7,3'd4,3'd3,3'd0};
parameter [23:0] MY_ID_PAR  = {3'd7,3'd6,3'd5,3'd4,3'd3,3'd2,3'd1,3'd0};
parameter [23:0] ONE_ID_PAR  = {3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1};
parameter [23:0] TWO_ID_PAR  = {3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd2,3'd2};
parameter [23:0] THR_ID_PAR  = {3'd2,3'd2,3'd2,3'd2,3'd2,3'd3,3'd3,3'd3};
parameter [23:0] FOU_ID_PAR  = {3'd3,3'd3,3'd3,3'd3,3'd4,3'd4,3'd4,3'd4};
parameter [23:0] FIV_ID_PAR  = {3'd4,3'd4,3'd4,3'd5,3'd5,3'd5,3'd5,3'd5};
parameter [23:0] SIX_ID_PAR  = {3'd5,3'd5,3'd6,3'd6,3'd6,3'd6,3'd6,3'd6};
parameter [23:0] SEV_ID_PAR  = {3'd6,3'd7,3'd7,3'd7,3'd7,3'd7,3'd7,3'd7};

// border
wire [3:0][`DATA_WIDTH-1:0] LOCAL_DATA_IN_border;
wire   [3:0] LOCAL_DATA_VALID_IN_border;
wire [3:0][`DATA_WIDTH-1:0] LOCAL_DATA_OUT_border;
wire   [3:0] LOCAL_DATA_VALID_OUT_border;
wire   [3:0] LOCAL_FULL_OUT_border;

wire [3:0][`DATA_WIDTH-1:0] X_DATA_IN_border;
wire   [3:0] X_DATA_VALID_IN_border;
wire   [3:0] X_FULL_IN_border;
wire [3:0][`DATA_WIDTH-1:0] X_DATA_OUT_border;
wire   [3:0] X_DATA_VALID_OUT_border;
wire   [3:0] X_FULL_OUT_border;

wire [3:0][`DATA_WIDTH-1:0] Y_DATA_IN_border;
wire   [3:0] Y_DATA_VALID_IN_border;
wire   [3:0] Y_FULL_IN_border;
wire [3:0][`DATA_WIDTH-1:0] Y_DATA_OUT_border;
wire   [3:0] Y_DATA_VALID_OUT_border;
wire   [3:0] Y_FULL_OUT_border;

// normal
wire [3:0][`DATA_WIDTH-1:0] LOCAL_DATA_IN_normal;
wire   [3:0] LOCAL_DATA_VALID_IN_normal;
wire [3:0][`DATA_WIDTH-1:0] LOCAL_DATA_OUT_normal;
wire   [3:0] LOCAL_DATA_VALID_OUT_normal;
wire   [3:0] LOCAL_FULL_OUT_normal;

wire [3:0][`DATA_WIDTH-1:0] X1_DATA_IN_normal;
wire   [3:0] X1_DATA_VALID_IN_normal;
wire   [3:0] X1_FULL_IN_normal;
wire [3:0][`DATA_WIDTH-1:0] X1_DATA_OUT_normal;
wire   [3:0] X1_DATA_VALID_OUT_normal;
wire   [3:0] X1_FULL_OUT_normal;

wire [3:0][`DATA_WIDTH-1:0] X2_DATA_IN_normal;
wire   [3:0] X2_DATA_VALID_IN_normal;
wire   [3:0] X2_FULL_IN_normal;
wire [3:0][`DATA_WIDTH-1:0] X2_DATA_OUT_normal;
wire   [3:0] X2_DATA_VALID_OUT_normal;
wire   [3:0] X2_FULL_OUT_normal;

wire [3:0][`DATA_WIDTH-1:0] Y_DATA_IN_normal;
wire   [3:0] Y_DATA_VALID_IN_normal;
wire   [3:0] Y_FULL_IN_normal;
wire [3:0][`DATA_WIDTH-1:0] Y_DATA_OUT_normal;
wire   [3:0] Y_DATA_VALID_OUT_normal;
wire   [3:0] Y_FULL_OUT_normal;

// PE

wire [7:0] enable_wire;
wire [7:0] dbg_mode_wire;
wire [7:0][2:0] send_num_wire;
wire [7:0][2:0] receive_num_wire;
wire [7:0][3:0] rate_wire;
wire [7:0][23:0] dst_seq_wire;
wire [7:0][3:0] mode_wire;
wire [7:0] flush_wire;

wire [7:0] task_send_finish_flag;
wire [7:0] task_receive_finish_flag;

wire [7:0][6:0] so_retrsreq_receive_flag;
wire [7:0][7:0] so_retrsreq_receive_num;
wire [7:0][6:0] so_retrsreq_send_flag;
wire [7:0][7:0] so_retrsreq_send_num;
wire [7:0][7:0] latency_max;
wire [7:0][7:0] latency_min;
wire [7:0][26:0] latency_sum;

wire [7:0][31:0] data_p2r;
wire [7:0][31:0] data_r2p;
wire [7:0] valid_p2r;
wire [7:0] valid_r2p;
wire [7:0] full;

// interconnect wire

	// router interconnect
assign LOCAL_DATA_IN_border = {data_p2r[7], data_p2r[4], data_p2r[3], data_p2r[0]};
assign LOCAL_DATA_VALID_IN_border = {valid_p2r[7], valid_p2r[4], valid_p2r[3], valid_p2r[0]};

/*
assign LOCAL_DATA_OUT_border = {data_r2p[7], data_r2p[4], data_r2p[3], data_r2p[0]};
assign LOCAL_DATA_VALID_OUT_border = {valid_r2p[7], valid_r2p[4], valid_r2p[3], valid_r2p[0]};
assign LOCAL_FULL_OUT_border = {full[7], full[4], full[3], full[0]};
*/



assign LOCAL_DATA_IN_normal = {data_p2r[6], data_p2r[5], data_p2r[2], data_p2r[1]};
assign LOCAL_DATA_VALID_IN_normal = {valid_p2r[6], valid_p2r[5], valid_p2r[2], valid_p2r[1]};

/*
assign LOCAL_DATA_OUT_normal = {data_r2p[6], data_r2p[5], data_r2p[2], data_r2p[1]};
assign LOCAL_DATA_VALID_OUT_normal = {valid_r2p[6], valid_r2p[5], valid_r2p[2], valid_r2p[1]};
assign LOCAL_FULL_OUT_normal = {full[6], full[5], full[2], full[1]};
*/

assign X_DATA_IN_border = {X2_DATA_OUT_normal[3], X1_DATA_OUT_normal[2], X2_DATA_OUT_normal[1], X1_DATA_OUT_normal[0]};
assign X_DATA_VALID_IN_border = {X2_DATA_VALID_OUT_normal[3], X1_DATA_VALID_OUT_normal[2], X2_DATA_VALID_OUT_normal[1], X1_DATA_VALID_OUT_normal[0]};
assign X_FULL_IN_border = {X2_FULL_OUT_normal[3], X1_FULL_OUT_normal[2], X2_FULL_OUT_normal[1], X1_FULL_OUT_normal[0]};

assign Y_DATA_IN_border = {Y_DATA_OUT_border[1], Y_DATA_OUT_border[0], Y_DATA_OUT_border[3], Y_DATA_OUT_border[2]};
assign Y_DATA_VALID_IN_border = {Y_DATA_VALID_OUT_border[1], Y_DATA_VALID_OUT_border[0], Y_DATA_VALID_OUT_border[3], Y_DATA_VALID_OUT_border[2]};
assign Y_FULL_IN_border = {Y_FULL_OUT_border[1], Y_FULL_OUT_border[0], Y_FULL_OUT_border[3], Y_FULL_OUT_border[2]};

assign X1_DATA_IN_normal = {X2_DATA_OUT_normal[2], X_DATA_OUT_border[2], X2_DATA_OUT_normal[0], X_DATA_OUT_border[0]};
assign X1_DATA_VALID_IN_normal = {X2_DATA_VALID_OUT_normal[2], X_DATA_VALID_OUT_border[2], X2_DATA_VALID_OUT_normal[0], X_DATA_VALID_OUT_border[0]};
assign X1_FULL_IN_normal = {X2_FULL_OUT_normal[2], X_FULL_OUT_border[2], X2_FULL_OUT_normal[0], X_FULL_OUT_border[0]};

assign X2_DATA_IN_normal = {X_DATA_OUT_border[3], X1_DATA_OUT_normal[3], X_DATA_OUT_border[1], X1_DATA_OUT_normal[1]};
assign X2_DATA_VALID_IN_normal = {X_DATA_VALID_OUT_border[3], X1_DATA_VALID_OUT_normal[3], X_DATA_VALID_OUT_border[1], X1_DATA_VALID_OUT_normal[1]};
assign X2_FULL_IN_normal = {X_FULL_OUT_border[3], X1_FULL_OUT_normal[3], X_FULL_OUT_border[1], X1_FULL_OUT_normal[1]};

assign Y_DATA_IN_normal = {Y_DATA_OUT_normal[1], Y_DATA_OUT_normal[0], Y_DATA_OUT_normal[3], Y_DATA_OUT_normal[2]};
assign Y_DATA_VALID_IN_normal = {Y_DATA_VALID_OUT_normal[1], Y_DATA_VALID_OUT_normal[0], Y_DATA_VALID_OUT_normal[3], Y_DATA_VALID_OUT_normal[2]};
assign Y_FULL_IN_normal = {Y_FULL_OUT_normal[1], Y_FULL_OUT_normal[0], Y_FULL_OUT_normal[3], Y_FULL_OUT_normal[2]};

	//pe interconnect


assign data_r2p = {LOCAL_DATA_OUT_border[3], LOCAL_DATA_OUT_normal[3], 
					LOCAL_DATA_OUT_normal[2], LOCAL_DATA_OUT_border[2], 
					LOCAL_DATA_OUT_border[1], LOCAL_DATA_OUT_normal[1], 
					LOCAL_DATA_OUT_normal[0], LOCAL_DATA_OUT_border[0]};
assign valid_r2p = {LOCAL_DATA_VALID_OUT_border[3], LOCAL_DATA_VALID_OUT_normal[3],
					LOCAL_DATA_VALID_OUT_normal[2], LOCAL_DATA_VALID_OUT_border[2],
					LOCAL_DATA_VALID_OUT_border[1], LOCAL_DATA_VALID_OUT_normal[1],
					LOCAL_DATA_VALID_OUT_normal[0], LOCAL_DATA_VALID_OUT_border[0]};
assign full = {LOCAL_FULL_OUT_border[3], LOCAL_FULL_OUT_normal[3],
				LOCAL_FULL_OUT_normal[2], LOCAL_FULL_OUT_border[2],
				LOCAL_FULL_OUT_border[1], LOCAL_FULL_OUT_normal[1],
				LOCAL_FULL_OUT_normal[0], LOCAL_FULL_OUT_border[0]};

assign enable_wire = pe_enable;
assign dbg_mode_wire = pe_dbg_mode_wire;
assign send_num_wire = pe_send_num_wire;
assign receive_num_wire = pe_receive_num_wire;
assign rate_wire = pe_rate_wire;
assign dst_seq_wire = pe_dst_seq_wire;
assign mode_wire = pe_mode_wire;
assign flush_wire = pe_flush_wire;

assign pe_task_receive_finish_flag = task_receive_finish_flag;
assign pe_task_send_finish_flag = task_send_finish_flag;


genvar gen;
generate
	for(gen = 0; gen < 8; gen=gen+1)
	begin: router
		if(gen < 4)
			router_border #(
			.ROUTER_ADDRESS(ROUTER_ADDRESS_PAR[3*gen+2:3*gen])
			)router_unit
			(
				.clk(clk),
				.rst_n(rst_n),
				
				.LOCAL_DATA_IN(LOCAL_DATA_IN_border[gen]),
				.LOCAL_DATA_VALID_IN(LOCAL_DATA_VALID_IN_border[gen]),
				
				.LOCAL_DATA_OUT(LOCAL_DATA_OUT_border[gen]),
				.LOCAL_DATA_VALID_OUT(LOCAL_DATA_VALID_OUT_border[gen]),
				.LOCAL_FULL_OUT(LOCAL_FULL_OUT_border[gen]),
				
				.X_DATA_IN(X_DATA_IN_border[gen]),
				.X_DATA_VALID_IN(X_DATA_VALID_IN_border[gen]),
				.X_FULL_IN(X_FULL_IN_border[gen]),
				
				.X_DATA_OUT(X_DATA_OUT_border[gen]),
				.X_DATA_VALID_OUT(X_DATA_VALID_OUT_border[gen]),
				.X_FULL_OUT(X_FULL_OUT_border[gen]),
				
				
				.Y_DATA_IN(Y_DATA_IN_border[gen]),
				.Y_DATA_VALID_IN(Y_DATA_VALID_IN_border[gen]),
				.Y_FULL_IN(Y_FULL_IN_border[gen]),
				
				.Y_DATA_OUT(Y_DATA_OUT_border[gen]),
				.Y_DATA_VALID_OUT(Y_DATA_VALID_OUT_border[gen]),
				.Y_FULL_OUT(Y_FULL_OUT_border[gen])
			);
		else
			router_normal #(
			.ROUTER_ADDRESS(ROUTER_ADDRESS_PAR[3*gen+2:3*gen])
			)router_unit
			(
				.clk(clk),
				.rst_n(rst_n),
				
				.LOCAL_DATA_IN(LOCAL_DATA_IN_normal[gen-4]),
				.LOCAL_DATA_VALID_IN(LOCAL_DATA_VALID_IN_normal[gen-4]),
				
				.LOCAL_DATA_OUT(LOCAL_DATA_OUT_normal[gen-4]),
				.LOCAL_DATA_VALID_OUT(LOCAL_DATA_VALID_OUT_normal[gen-4]),
				.LOCAL_FULL_OUT(LOCAL_FULL_OUT_normal[gen-4]),
				
				.X1_DATA_IN(X1_DATA_IN_normal[gen-4]),
				.X1_DATA_VALID_IN(X1_DATA_VALID_IN_normal[gen-4]),
				.X1_FULL_IN(X1_FULL_IN_normal[gen-4]),
				
				.X1_DATA_OUT(X1_DATA_OUT_normal[gen-4]),
				.X1_DATA_VALID_OUT(X1_DATA_VALID_OUT_normal[gen-4]),
				.X1_FULL_OUT(X1_FULL_OUT_normal[gen-4]),
				
				.X2_DATA_IN(X2_DATA_IN_normal[gen-4]),
				.X2_DATA_VALID_IN(X2_DATA_VALID_IN_normal[gen-4]),
				.X2_FULL_IN(X2_FULL_IN_normal[gen-4]),
				
				.X2_DATA_OUT(X2_DATA_OUT_normal[gen-4]),
				.X2_DATA_VALID_OUT(X2_DATA_VALID_OUT_normal[gen-4]),
				.X2_FULL_OUT(X2_FULL_OUT_normal[gen-4]),
				
				.Y_DATA_IN(Y_DATA_IN_normal[gen-4]),
				.Y_DATA_VALID_IN(Y_DATA_VALID_IN_normal[gen-4]),
				.Y_FULL_IN(Y_FULL_IN_normal[gen-4]),
				
				.Y_DATA_OUT(Y_DATA_OUT_normal[gen-4]),
				.Y_DATA_VALID_OUT(Y_DATA_VALID_OUT_normal[gen-4]),
				.Y_FULL_OUT(Y_FULL_OUT_normal[gen-4])
			);
	end
endgenerate


generate
	for(gen = 0; gen < 8; gen = gen + 1)
	begin: pecore
		PE #(
		.MY_ID(MY_ID_PAR[3*gen+2:3*gen]),
		.ONE_ID(ONE_ID_PAR[3*gen+2:3*gen]),
		.TWO_ID(TWO_ID_PAR[3*gen+2:3*gen]),
		.THR_ID(THR_ID_PAR[3*gen+2:3*gen]),
		.FOU_ID(FOU_ID_PAR[3*gen+2:3*gen]),
		.FIV_ID(FIV_ID_PAR[3*gen+2:3*gen]),
		.SIX_ID(SIX_ID_PAR[3*gen+2:3*gen]),
		.SEV_ID(SEV_ID_PAR[3*gen+2:3*gen])
		)PE_unit
		(
			.enable_wire(enable_wire[gen]),
			.dbg_mode_wire(dbg_mode_wire[gen]),
			.send_num_wire(send_num_wire[gen]),
			.receive_num_wire(receive_num_wire[gen]),
			.rate_wire(rate_wire[gen]),
			.dst_seq_wire(dst_seq_wire[gen]),
			.mode_wire(mode_wire[gen]),
			.flush_wire(flush_wire[gen]),
			.task_send_finish_flag(task_send_finish_flag[gen]),
			.task_receive_finish_flag(task_receive_finish_flag[gen]),
			.so_retrsreq_receive_flag(so_retrsreq_receive_flag[gen]),
			.so_retrsreq_send_flag(so_retrsreq_send_flag[gen]),
			.so_retrsreq_receive_num(so_retrsreq_receive_num[gen]),
			.so_retrsreq_send_num(so_retrsreq_send_num[gen]),
			.latency_min(latency_min[gen]),
			.latency_max(latency_max[gen]),
			.latency_sum(latency_sum[gen]),
			.data_p2r(data_p2r[gen]),
			.valid_p2r(valid_p2r[gen]),
			.data_r2p(data_r2p[gen]),
			.valid_r2p(valid_r2p[gen]),
			.full(full[gen]),
			.rst_n(rst_n),
			.clk(clk)
		);
	end // pecore
endgenerate



endmodule