`include "global.v"
module SA3port_tb();

reg clk;
reg rst_n;
reg en;

reg [2:0] port_x1_dst;
reg [2:0] port_x2_dst;
reg [2:0] port_y_dst;
reg [2:0] port_local_dst;


wire [2:0] out_x1_sw;
wire [2:0] out_x2_sw;
wire [2:0] out_y_sw;
wire [2:0] out_local_sw;



reg init_done;
reg check_flag;
reg [2:0] map [0:3];
reg [5:0] cnt_tmp;
reg [2:0] port_x1_dst_tmp;
reg [2:0] port_x2_dst_tmp;
reg [2:0] port_y_dst_tmp;
reg [2:0] port_local_dst_tmp; 

initial begin
	init_done = 0;
	clk = 0;
	rst_n = 0;
	en = 0;
	port_x1_dst = 0;
	port_x2_dst = 0;
	port_y_dst = 0;
	port_local_dst = 0;
	check_flag = 0;
	
	map[0] = `OUT_LOCAL_PORT;
	map[1] = `OUT_X1_PORT;
	map[2] = `OUT_Y1_PORT;
	map[3] = `OUT_LOCAL_PORT;
	cnt_tmp = 0;
	
#10	rst_n = 1;
	en = 1;
	init_done = 1;                                                                                                                                                                                                                                                                                                                                                                                                   
end


always #5 clk = !clk;

always@(posedge clk) begin
	if(init_done)
		cnt_tmp <= cnt_tmp+1;
end

always@(*) begin
	if(init_done) begin
		port_x1_dst = map[cnt_tmp[1:0]];
		port_y_dst = map[cnt_tmp[3:2]];
		port_local_dst = map[cnt_tmp[5:4]];
	end
end

always@(posedge clk) begin
	if(init_done) begin
		port_local_dst_tmp <= port_local_dst;
		port_x1_dst_tmp <= port_x1_dst;
		port_y_dst_tmp <= port_y_dst;
	end
end

always@(posedge clk) begin
	if(init_done) begin
		if(out_local_sw == `SW_LOCAL && port_local_dst_tmp != `OUT_LOCAL_PORT) check_flag = 1;
		else if(out_local_sw == `SW_X1 && port_x1_dst_tmp != `OUT_LOCAL_PORT) check_flag = 1;
		else if(out_local_sw == `SW_Y1 && port_y_dst_tmp != `OUT_LOCAL_PORT) check_flag = 1;
		else if(out_x1_sw == `SW_LOCAL && port_local_dst_tmp != `OUT_X1_PORT) check_flag = 1;
		else if(out_x1_sw == `SW_X1 && port_x1_dst_tmp != `OUT_X1_PORT) check_flag = 1;
		else if(out_x1_sw == `SW_Y1 && port_y_dst_tmp != `OUT_X1_PORT) check_flag = 1;
		else if(out_y_sw == `SW_LOCAL && port_local_dst_tmp != `OUT_Y1_PORT) check_flag = 1;
		else if(out_y_sw == `SW_X1 && port_x1_dst_tmp != `OUT_Y1_PORT) check_flag = 1;
		else if(out_y_sw == `SW_Y1 && port_y_dst_tmp != `OUT_Y1_PORT) check_flag = 1;
		else 	check_flag = 0;
	end
end


switch_allocation_3port sa3port_unit(
	.clk(clk),
	.rst_n(rst_n),
	.en(en),
	
	.port_x_dst(port_x1_dst),
	.port_y_dst(port_y_dst),
	.port_local_dst(port_local_dst),
	
	.out_x_sw(out_x1_sw),
	.out_y_sw(out_y_sw),
	.out_local_sw(out_local_sw)
);




endmodule

module SA4port_tb();

reg clk;
reg rst_n;
reg en;

reg [2:0] port_x1_dst;
reg [2:0] port_x2_dst;
reg [2:0] port_y_dst;
reg [2:0] port_local_dst;


wire [2:0] out_x1_sw;
wire [2:0] out_x2_sw;
wire [2:0] out_y_sw;
wire [2:0] out_local_sw;



reg init_done;
reg check_flag;
reg [2:0] map [0:3];
reg [7:0] cnt_tmp;
reg [2:0] port_x1_dst_tmp;
reg [2:0] port_x2_dst_tmp;
reg [2:0] port_y_dst_tmp;
reg [2:0] port_local_dst_tmp; 

initial begin
	init_done = 0;
	clk = 0;
	rst_n = 0;
	en = 0;
	port_x1_dst = 0;
	port_x2_dst = 0;
	port_y_dst = 0;
	port_local_dst = 0;
	check_flag = 0;
	
	map[0] = `OUT_LOCAL_PORT;
	map[1] = `OUT_X1_PORT;
	map[2] = `OUT_X2_PORT;
	map[3] = `OUT_Y1_PORT;
	cnt_tmp = 0;
	
#10	rst_n = 1;
	en = 1;
	init_done = 1;                                                                                                                                                                                                                                                                                                                                                                                                   
end


always #5 clk = !clk;

always@(posedge clk) begin
	if(init_done)
		cnt_tmp <= cnt_tmp + 1;
end

always@(*) begin
	if(init_done) begin
		port_x1_dst = map[cnt_tmp[1:0]];
		port_x2_dst = map[cnt_tmp[3:2]];
		port_y_dst = map[cnt_tmp[5:4]];
		port_local_dst = map[cnt_tmp[7:6]];
	end
end

always@(posedge clk) begin
	if(init_done) begin
		port_local_dst_tmp <= port_local_dst;
		port_x1_dst_tmp <= port_x1_dst;
		port_x2_dst_tmp <= port_x2_dst;
		port_y_dst_tmp <= port_y_dst;
	end
end

always@(posedge clk) begin
	if(init_done) begin
		if(out_local_sw == `SW_LOCAL && port_local_dst_tmp != `OUT_LOCAL_PORT) check_flag = 1;
		else if(out_local_sw == `SW_X1 && port_x1_dst_tmp != `OUT_LOCAL_PORT) check_flag = 1;
		else if(out_local_sw == `SW_X2 && port_x2_dst_tmp != `OUT_LOCAL_PORT) check_flag = 1;
		else if(out_local_sw == `SW_Y1 && port_y_dst_tmp != `OUT_LOCAL_PORT) check_flag = 1;
		else if(out_x1_sw == `SW_LOCAL && port_local_dst_tmp != `OUT_X1_PORT) check_flag = 1;
		else if(out_x1_sw == `SW_X1 && port_x1_dst_tmp != `OUT_X1_PORT) check_flag = 1;
		else if(out_x1_sw == `SW_X2 && port_x2_dst_tmp != `OUT_X1_PORT) check_flag = 1;
		else if(out_x1_sw == `SW_Y1 && port_y_dst_tmp != `OUT_X1_PORT) check_flag = 1;
		else if(out_x2_sw == `SW_LOCAL && port_local_dst_tmp != `OUT_X2_PORT) check_flag = 1;
		else if(out_x2_sw == `SW_X1 && port_x1_dst_tmp != `OUT_X2_PORT) check_flag = 1;
		else if(out_x2_sw == `SW_X2 && port_x2_dst_tmp != `OUT_X2_PORT) check_flag = 1;
		else if(out_x2_sw == `SW_Y1 && port_y_dst_tmp != `OUT_X2_PORT) check_flag = 1;
		else if(out_y_sw == `SW_LOCAL && port_local_dst_tmp != `OUT_Y1_PORT) check_flag = 1;
		else if(out_y_sw == `SW_X1 && port_x1_dst_tmp != `OUT_Y1_PORT) check_flag = 1;
		else if(out_y_sw == `SW_X2 && port_x2_dst_tmp != `OUT_Y1_PORT) check_flag = 1;
		else if(out_y_sw == `SW_Y1 && port_y_dst_tmp != `OUT_Y1_PORT) check_flag = 1;
		else 	check_flag = 0;
	end
end


switch_allocation_4port sa3port_unit(
	.clk(clk),
	.rst_n(rst_n),
	.en(en),
	
	.port_x1_dst(port_x1_dst),
	.port_x2_dst(port_x2_dst),
	.port_y_dst(port_y_dst),
	.port_local_dst(port_local_dst),
	
	.out_x1_sw(out_x1_sw),
	.out_x2_sw(out_x2_sw),
	.out_y_sw(out_y_sw),
	.out_local_sw(out_local_sw)
);




endmodule