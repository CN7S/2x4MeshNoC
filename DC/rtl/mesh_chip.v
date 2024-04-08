module mesh_chip(

	input 			clk,
	input 			rst_n,
	
	input  	[7:0] 	pe_enable,
	
	output 	[7:0] 	pe_task_receive_finish_flag,
	output 	[7:0] 	pe_task_send_finish_flag

);

wire 			net_clk;
wire 			net_rst_n;
wire  	[7:0] 	net_pe_enable;
wire 	[7:0] 	net_pe_task_receive_finish_flag;
wire 	[7:0] 	net_pe_task_send_finish_flag;

PIW
	PIW_clk(.PAD(clk),.C(net_clk)),
	PIW_rstn(.PAD(rst_n),.C(net_rst_n)),
	PIW_pe_enable0(.PAD(pe_enable[0]),.C(net_pe_enable[0])),
	PIW_pe_enable1(.PAD(pe_enable[1]),.C(net_pe_enable[1])),
	PIW_pe_enable2(.PAD(pe_enable[2]),.C(net_pe_enable[2])),
	PIW_pe_enable3(.PAD(pe_enable[3]),.C(net_pe_enable[3])),
	PIW_pe_enable4(.PAD(pe_enable[4]),.C(net_pe_enable[4])),
	PIW_pe_enable5(.PAD(pe_enable[5]),.C(net_pe_enable[5])),
	PIW_pe_enable6(.PAD(pe_enable[6]),.C(net_pe_enable[6])),
	PIW_pe_enable7(.PAD(pe_enable[7]),.C(net_pe_enable[7]));
	

PO8W
	PO8W_pe_task_receive_finish_flag0(.I(net_pe_task_receive_finish_flag[0]),.PAD(pe_task_receive_finish_flag[0])),
	PO8W_pe_task_receive_finish_flag1(.I(net_pe_task_receive_finish_flag[1]),.PAD(pe_task_receive_finish_flag[1])),
	PO8W_pe_task_receive_finish_flag2(.I(net_pe_task_receive_finish_flag[2]),.PAD(pe_task_receive_finish_flag[2])),
	PO8W_pe_task_receive_finish_flag3(.I(net_pe_task_receive_finish_flag[3]),.PAD(pe_task_receive_finish_flag[3])),
	PO8W_pe_task_receive_finish_flag4(.I(net_pe_task_receive_finish_flag[4]),.PAD(pe_task_receive_finish_flag[4])),
	PO8W_pe_task_receive_finish_flag5(.I(net_pe_task_receive_finish_flag[5]),.PAD(pe_task_receive_finish_flag[5])),
	PO8W_pe_task_receive_finish_flag6(.I(net_pe_task_receive_finish_flag[6]),.PAD(pe_task_receive_finish_flag[6])),
	PO8W_pe_task_receive_finish_flag7(.I(net_pe_task_receive_finish_flag[7]),.PAD(pe_task_receive_finish_flag[7])),
	PO8W_pe_task_send_finish_flag0(.I(net_pe_task_send_finish_flag[0]),.PAD(pe_task_send_finish_flag[0])),
	PO8W_pe_task_send_finish_flag1(.I(net_pe_task_send_finish_flag[1]),.PAD(pe_task_send_finish_flag[1])),
	PO8W_pe_task_send_finish_flag2(.I(net_pe_task_send_finish_flag[2]),.PAD(pe_task_send_finish_flag[2])),
	PO8W_pe_task_send_finish_flag3(.I(net_pe_task_send_finish_flag[3]),.PAD(pe_task_send_finish_flag[3])),
	PO8W_pe_task_send_finish_flag4(.I(net_pe_task_send_finish_flag[4]),.PAD(pe_task_send_finish_flag[4])),
	PO8W_pe_task_send_finish_flag5(.I(net_pe_task_send_finish_flag[5]),.PAD(pe_task_send_finish_flag[5])),
	PO8W_pe_task_send_finish_flag6(.I(net_pe_task_send_finish_flag[6]),.PAD(pe_task_send_finish_flag[6])),
	PO8W_pe_task_send_finish_flag7(.I(net_pe_task_send_finish_flag[7]),.PAD(pe_task_send_finish_flag[7]));

mesh insc_mesh(
 	.clk(net_clk),
 	.rst_n(net_rst_n),
  	.pe_enable(net_pe_enable),
 	.pe_task_receive_finish_flag(net_pe_task_receive_finish_flag),
 	.pe_task_send_finish_flag(net_pe_task_send_finish_flag)
);

endmodule
