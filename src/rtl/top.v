`include "global.v"
module mesh(
	input clk,
	input rst_n,
	input en,
	
	input pe_dbg_mode_wire,
	input [] pe_send_num_wire,
	input [] pe_receive_num_wire,
	input [] pe_rate_wire,
	input [] pe_dst_seq_wire,
	input [] pe_mode_wire,
	input pe_flush_wire
	
)

wire clk;
wire rst_n;

// border
wire [][] LOCAL_DATA_IN_border;
wire   [] LOCAL_DATA_VALID_IN_border;
wire [][] LOCAL_DATA_OUT_border;
wire   [] LOCAL_DATA_VALID_OUT_border;
wire   [] LOCAL_FULL_OUT_border;

wire [][] X_DATA_IN_border;
wire   [] X_DATA_VALID_IN_border;
wire   [] X_FULL_IN_border;
wire [][] X_DATA_OUT_border;
wire   [] X_DATA_VALID_OUT_border;
wire   [] X_FULL_OUT_border;

wire [][] Y_DATA_IN_border;
wire   [] Y_DATA_VALID_IN_border;
wire   [] Y_FULL_IN_border;
wire [][] Y_DATA_OUT_border;
wire   [] Y_DATA_VALID_OUT_border;
wire   [] Y_FULL_OUT_border;

// normal
wire [][] LOCAL_DATA_IN_normal;
wire   [] LOCAL_DATA_VALID_IN_normal;
wire [][] LOCAL_DATA_OUT_normal;
wire   [] LOCAL_DATA_VALID_OUT_normal;
wire   [] LOCAL_FULL_OUT_normal;

wire [][] X1_DATA_IN_normal;
wire   [] X1_DATA_VALID_IN_normal;
wire   [] X1_FULL_IN_normal;
wire [][] X1_DATA_OUT_normal;
wire   [] X1_DATA_VALID_OUT_normal;
wire   [] X1_FULL_OUT_normal;

wire [][] X2_DATA_IN_normal;
wire   [] X2_DATA_VALID_IN_normal;
wire   [] X2_FULL_IN_normal;
wire [][] X2_DATA_OUT_normal;
wire   [] X2_DATA_VALID_OUT_normal;
wire   [] X2_FULL_OUT_normal;

wire [][] Y_DATA_IN_normal;
wire   [] Y_DATA_VALID_IN_normal;
wire   [] Y_FULL_IN_normal;
wire [][] Y_DATA_OUT_normal;
wire   [] Y_DATA_VALID_OUT_normal;
wire   [] Y_FULL_OUT_normal;

// PE

wire [] enable_wire;
wire [] dbg_mode_wire;
wire [][] send_num_wire;
wire [][] receive_num_wire;
wire [][] rate_wire;
wire [][] dst_seq_wire;
wire [][] mode_wire;
wire [] flush_wire;

wire [] task_send_finish_flag;
wire [] task_receive_finish_flag;

wire [][] so_retrsreq_receive_flag;
wire [][] so_retrsreq_receive_num;
wire [][] so_retrsreq_send_flag;
wire [][] so_retrsreq_send_num;
wire [] latency_max;
wire [] latency_min;
wire [] latency_sum;

wire [][] data_p2r;
wire [][] data_r2p;
wire [] valid_p2r;
wire [] valid_r2p;
wire [] full;

// connect wire


genvar gen;
generate
	for(gen = 0; gen < 8; gen=gen+1)
	begin: router
		if(gen < 4)
			router_border router_unit(
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
				.X_FULL_OUT(X_FULL_IN_border[gen]),
				
				
				.Y_DATA_IN(Y_DATA_IN_border[gen]),
				.Y_DATA_VALID_IN(Y_DATA_VALID_IN_border[gen]),
				.Y_FULL_IN(Y_FULL_IN_border[gen]),
				
				.Y_DATA_OUT(Y_DATA_OUT_border[gen]),
				.Y_DATA_VALID_OUT(Y_DATA_VALID_IN_border[gen]),
				.Y_FULL_OUT(Y_FULL_OUT_border[gen]),
			);
		else
			router_normal router_unit(
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
				.Y_FULL_OUT(Y_FULL_OUT_normal[gen-4]),
			);
	end
endgenerate


generate
	for(gen = 0; gen < 8; gen = gen + 1)
	begin: pecore
		PE PE_unit(
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
	end
endgenerate



endmodule