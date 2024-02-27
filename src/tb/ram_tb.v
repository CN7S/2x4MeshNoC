`include "global.v"


module ram_tb();
 
reg 						rst_n;
reg 						wr_clk;
reg 						wr_en;
reg 	[`ADDR_WIDTH-1:0]	wr_addr;
reg		[`DATA_WIDTH-1:0]	wr_data;
reg							rd_clk;
reg							rd_en;
reg		[`ADDR_WIDTH-1:0]	rd_addr;
wire	[`DATA_WIDTH-1:0]	rd_data;

integer i;

initial begin
	rst_n = 0;
	wr_addr = 0;
	wr_clk = 0;
	wr_data = 0;
	wr_en = 0;
	rd_addr = 0;
	rd_clk = 0;
	rd_en = 0;
	
	#20 rst_n = 1;

	// seperate write and read test
	for(i = 0; i < 8; i=i+1) begin
		@(posedge wr_clk);
		wr_addr = i;
		wr_data = i;
		wr_en = 1;
	end
	@(posedge wr_clk);
	wr_en = 0;
	wr_addr = 0;
	wr_data = 0;
	
	for(i = 0; i < 8; i=i+1) begin
		@(posedge rd_clk);
		rd_addr = i;
		rd_en = 1;
		@(negedge rd_clk);
		if(i)
			if(rd_data != i-1) begin 
				$display("At %t, read data error! The data is %d", $time, rd_data);
				$finish;
			end
	end
	@(posedge rd_clk);
	rd_en = 0;
	rd_addr = 0;
	@(negedge rd_clk);
	if(rd_data != 7) begin
		$display("At %t, read data error! The data is %d", $time, rd_data);
		$finish;
	end
	
	$display("Seperate Test Passing.");
	
	// Write and Read meanwhile test
	for(i = 0; i < 8; i = i+1) begin
		@(posedge wr_clk);
		wr_addr = i;
		wr_data = 20*i;
		wr_en = 1;
		rd_addr = 7-i;
		rd_en = 1;
	end	
	@(posedge wr_clk);
	wr_addr = 0;
	wr_data = 0;
	wr_en = 0;
	rd_en = 0;
	rd_addr = 0;
	
	#30;
	$stop;
	rst_n = 0;
	#30;
	$finish;
	
end

always #5 wr_clk = ~wr_clk;
always #5 rd_clk = ~rd_clk;

ram_8x32 ram_unit
(
	.rst_n(rst_n),
	
	.wr_clk(wr_clk),
	.wr_en(wr_en),
	.wr_addr(wr_addr),
	.wr_data(wr_data),
	
	.rd_clk(rd_clk),
	.rd_en(rd_en),
	.rd_addr(rd_addr),
	.rd_data(rd_data)
);

endmodule