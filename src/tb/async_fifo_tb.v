`include "global.v"
module async_fifo_tb();

reg 							wr_clk		;
reg								wr_rst		;
reg 							wr_en		;
reg		[`DATA_WIDTH-1:0]		wr_data		;
wire							almost_full	;
wire							full		;

reg								rd_clk		;
reg								rd_rst		;
reg								rd_en		;
wire	[`DATA_WIDTH-1:0]		rd_data		;
wire							almost_empty;
wire							empty		;


reg init_done, wr_flag;

initial begin
	// initial
	init_done = 0;
	wr_flag = 1;
	
	wr_clk = 0;
	wr_rst = 0;
	wr_en = 0;
	wr_data = 0;
	rd_clk = 0;
	rd_rst = 0;
	rd_en = 0;
	
	#30 wr_rst = 1;
	rd_rst = 1;
	
	#30 init_done = 1;
		
	
	#800 wr_flag = 0;
	#200 $finish;
end

always@(*) begin
	if(init_done & wr_flag)
		if(full) 	wr_en = 0;
		else		wr_en = 1;
	else
		wr_en = 0;
end

always@(*) begin
	if(init_done)
		if(empty)	rd_en = 0;
		else		rd_en = 1;
	else
		rd_en = 0;
end

always@(posedge wr_clk) begin
	if(init_done & wr_flag)
		if(wr_en) wr_data = wr_data + 1;
end

always #5 		wr_clk = !wr_clk;
always #10 		rd_clk = !rd_clk;







async_fifo_8x32 fifo_unit
(
	.wr_clk(wr_clk),
	.wr_rst(wr_rst),
	.wr_en(wr_en),
	.wr_data(wr_data),
	.almost_full(almost_full),
	.full(full),
	.rd_clk(rd_clk),
	.rd_rst(rd_rst),
	.rd_en(rd_en),
	.rd_data(rd_data),
	.almost_empty(almost_empty),
	.empty(empty)
);



endmodule
