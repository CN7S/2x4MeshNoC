`include "global.v"
module mesh_tb();


reg clk;
reg rst_n;


reg [7:0] pe_enable;
reg [7:0] pe_dbg_mode_wire;
reg [23:0] pe_send_num_wire;
reg [23:0] pe_receive_num_wire;
reg [31:0] pe_rate_wire;
reg [191:0] pe_dst_seq_wire;
reg [31:0] pe_mode_wire;
	
	
reg [7:0] pe_flush_wire;
	
wire [7:0] pe_task_receive_finish_flag;
wire [7:0] pe_task_send_finish_flag;


initial begin
	clk = 0;
	rst_n = 0;
	
	// configure
	
	// // bit complement
	// pe_enable = 0;
	// pe_dbg_mode_wire = {8{1'b1}};
	// pe_send_num_wire = {8{3'b001}};
	// pe_receive_num_wire = {8{3'b001}};
	// pe_rate_wire = 0;
	// pe_mode_wire = {8{4'b0001}};
	// pe_dst_seq_wire = {24'h0, 24'h1, 24'h2, 24'h3, 24'h4, 24'h5, 24'h6, 24'h7};
	// pe_flush_wire = {8{1'b1}};

	// // bit reverse
	// pe_enable = 0;
	// pe_dbg_mode_wire = {8{1'b1}};
	// pe_send_num_wire = {8{3'b001}};
	// pe_receive_num_wire = {8{3'b001}};
	// pe_rate_wire = 0;
	// pe_mode_wire = {8{4'b0001}};
	// pe_dst_seq_wire = {24'h7, 24'h3, 24'h5, 24'h1, 24'h6, 24'h2, 24'h4, 24'h0};
	// pe_flush_wire = {8{1'b1}};

	// //bit rotation
	// pe_enable = 0;
	// pe_dbg_mode_wire = {8{1'b1}};
	// pe_send_num_wire = {8{3'b001}};
	// pe_receive_num_wire = {8{3'b001}};
	// pe_rate_wire = 0;
	// pe_mode_wire = {8{4'b0001}};
	// pe_dst_seq_wire = {24'h7, 24'h3, 24'h6, 24'h2, 24'h5, 24'h1, 24'h4, 24'h0};
	// pe_flush_wire = {8{1'b1}};

	// //shuffle
	// pe_enable = 0;
	// pe_dbg_mode_wire = {8{1'b1}};
	// pe_send_num_wire = {8{3'b001}};
	// pe_receive_num_wire = {8{3'b001}};
	// pe_rate_wire = 0;
	// pe_mode_wire = {8{4'b0001}};
	// pe_dst_seq_wire = {24'h7, 24'h5, 24'h3, 24'h1, 24'h6, 24'h4, 24'h2, 24'h0};
	// pe_flush_wire = {8{1'b1}};

	// //tornado
	// pe_enable = 0;
	// pe_dbg_mode_wire = {8{1'b1}};
	// pe_send_num_wire = {8{3'b001}};
	// pe_receive_num_wire = {8{3'b001}};
	// pe_rate_wire = 0;
	// pe_mode_wire = {8{4'b0001}};
	// pe_dst_seq_wire = {24'h2, 24'h1, 24'h0, 24'h7, 24'h6, 24'h5, 24'h4, 24'h3};
	// pe_flush_wire = {8{1'b1}};

	// //neighbor
	// pe_enable = 0;
	// pe_dbg_mode_wire = {8{1'b1}};
	// pe_send_num_wire = {8{3'b001}};
	// pe_receive_num_wire = {8{3'b001}};
	// pe_rate_wire = 0;
	// pe_mode_wire = {8{4'b0001}};
	// pe_dst_seq_wire = {24'h0, 24'h7, 24'h6, 24'h5, 24'h4, 24'h3, 24'h2, 24'h1};
	// pe_flush_wire = {8{1'b1}};

	//hotspot
	pe_enable = 0;
	pe_dbg_mode_wire = {8{1'b1}};
	pe_send_num_wire = 	{{3'b001},{3'b001},{3'b001},{3'b001},{3'b001},{3'b001},{3'b001},{3'b000}};
	pe_receive_num_wire = 	{{3'b000},{3'b000},{3'b000},{3'b000},{3'b000},{3'b000},{3'b000},{3'b111}};
	pe_rate_wire = 0;
	pe_mode_wire = {8{4'b0001}};
	pe_dst_seq_wire = {8{24'h0}};
	pe_flush_wire = {8{1'b1}};

	// //turn
	// pe_enable = 0;
	// pe_dbg_mode_wire = {8{1'b1}};
	// pe_send_num_wire = {8{3'b111}};
	// pe_receive_num_wire = {8{3'b111}};
	// pe_rate_wire = 0;
	// pe_mode_wire = {8{4'b0000}};
	// pe_dst_seq_wire = {8{24'h0}};
	// pe_flush_wire = {8{1'b1}};
	
	// reset
	
	#20 rst_n = 1;

	// enable
	#40
	pe_flush_wire = {8{1'b0}};
	#1000
	
	pe_enable = {8{1'b1}};

end



always #5 clk = ~clk;














mesh mesh_unit(
	.clk(clk),
	.rst_n(rst_n),
	.pe_enable(pe_enable),
	.pe_dbg_mode_wire(pe_dbg_mode_wire),
	.pe_send_num_wire(pe_send_num_wire),
	.pe_receive_num_wire(pe_receive_num_wire),
	.pe_rate_wire(pe_rate_wire),
	.pe_dst_seq_wire(pe_dst_seq_wire),
	.pe_mode_wire(pe_mode_wire),
	.pe_flush_wire(pe_flush_wire),
	.pe_task_receive_finish_flag(pe_task_receive_finish_flag),
	.pe_task_send_finish_flag(pe_task_send_finish_flag)
);

endmodule
