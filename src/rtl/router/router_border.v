`include "global.v"
module router_border#(
	parameter ROUTER_ADDRESS = 3'b0
)
(
	input				clk		,
	input 				rst_n	,
	
	input [`DATA_WIDTH-1:0]		LOCAL_DATA_IN		,
	input						LOCAL_DATA_VALID_IN	,
	
	output	reg [`DATA_WIDTH-1:0]	LOCAL_DATA_OUT		,
	output	reg					LOCAL_DATA_VALID_OUT,
	output						LOCAL_FULL_OUT		,
	
	input [`DATA_WIDTH-1:0]		X_DATA_IN		,
	input						X_DATA_VALID_IN	,
	input						X_FULL_IN		,
	
	output	reg [`DATA_WIDTH-1:0]	X_DATA_OUT		,
	output	reg					X_DATA_VALID_OUT,
	output						X_FULL_OUT		,

	input [`DATA_WIDTH-1:0]		Y_DATA_IN		,
	input						Y_DATA_VALID_IN	,
	input						Y_FULL_IN		,
	
	output	reg [`DATA_WIDTH-1:0]	Y_DATA_OUT		,
	output	reg					Y_DATA_VALID_OUT,
	output			          	Y_FULL_OUT		
);

// wire and reg definition
wire [2:0] router_add;


reg buffer_x_vaild	[0:2];
reg buffer_y_vaild	[0:2];
reg buffer_local_vaild	[0:2];
reg [31:0] buffer_x [0:2];
reg [31:0] buffer_y [0:2];
reg [31:0] buffer_local [0:2];

wire en_x;
reg en_buffer_x;
reg [32:0] fifo_data_buffer_x;
reg fifo_data_valid_x;
wire [`DATA_WIDTH-1:0] fifo_rd_data_x;
wire fifo_rd_en_x;
wire fifo_almost_full_x;
wire fifo_full_x;
wire fifo_almost_empty_x;
wire fifo_empty_x;
wire [2:0] x_dst;
wire [2:0] port_x_dst;

wire en_y;
reg en_buffer_y;
reg [32:0] fifo_data_buffer_y;
reg fifo_data_valid_y;
wire [`DATA_WIDTH-1:0]fifo_rd_data_y;
wire fifo_rd_en_y;
wire fifo_almost_full_y;
wire fifo_full_y;
wire fifo_almost_empty_y;
wire fifo_empty_y;
wire [2:0] y_dst;
wire [2:0] port_y_dst;

wire en_local;
reg en_buffer_local;
reg [32:0] fifo_data_buffer_local;
reg fifo_data_valid_local;
wire [`DATA_WIDTH-1:0]fifo_rd_data_local;
wire fifo_rd_en_local;
wire fifo_almost_full_local;
wire fifo_full_local;
wire fifo_almost_empty_local;
wire fifo_empty_local;
wire [2:0] local_dst;
wire [2:0] port_local_dst;

wire x_SA_vaild;
wire y_SA_vaild;
wire local_SA_vaild;

wire [2:0] port_sw_x;
wire [2:0] port_sw_y;
wire [2:0] port_sw_local;


// ROUTER ADDRESS
assign router_add = ROUTER_ADDRESS;

// FIFO_IN
sync_fifo_8x32 unit_fifo_local(
	.clk(clk),
	.rst_n(rst_n),
	.wr_en(LOCAL_DATA_VALID_IN),
	.wr_data(LOCAL_DATA_IN),
	.almost_full(fifo_almost_full_local),
	.full(LOCAL_FULL_OUT),
	
	.rd_en(fifo_rd_en_local),
	.rd_data(fifo_rd_data_local),
	.almost_empty(fifo_almost_empty_local),
	.empty(fifo_empty_local)
);


sync_fifo_8x32 unit_fifo_x(
	.clk(clk),
	.rst_n(rst_n),
	.wr_en(X_DATA_VALID_IN),
	.wr_data(X_DATA_IN),
	.almost_full(X_FULL_OUT),
	.full(fifo_full_x),
	
	.rd_en(fifo_rd_en_x),
	.rd_data(fifo_rd_data_x),
	.almost_empty(fifo_almost_empty_x),
	.empty(fifo_empty_x)
);


sync_fifo_8x32 unit_fifo_y(
	.clk(clk),
	.rst_n(rst_n),
	.wr_en(Y_DATA_VALID_IN),
	.wr_data(Y_DATA_IN),
	.almost_full(Y_FULL_OUT),
	.full(fifo_full_y),
	
	.rd_en(fifo_rd_en_y),
	.rd_data(fifo_rd_data_y),
	.almost_empty(fifo_almost_empty_y),
	.empty(fifo_empty_y)
);
	// x_fifo_buffer
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_valid_x <= 0;
	end
	else begin
		fifo_data_valid_x <= fifo_rd_en_x;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		en_buffer_x <= 1;
	end
	else begin
		en_buffer_x <= en_x;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_buffer_x <= 0;
	end
	else if(en_buffer_x) begin
		fifo_data_buffer_x <= {fifo_data_valid_x, fifo_rd_data_x};
	end
end

	// y_fifo_buffer
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_valid_y <= 0;
	end
	else begin
		fifo_data_valid_y <= fifo_rd_en_y;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		en_buffer_y <= 1;
	end
	else begin
		en_buffer_y <= en_y;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_buffer_y <= 0;
	end
	else if(en_buffer_y) begin
		fifo_data_buffer_y <= {fifo_data_valid_y, fifo_rd_data_y};
	end
end
	// local_fifo_buffer
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_valid_local <= 0;
	end
	else begin
		fifo_data_valid_local <= fifo_rd_en_local;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		en_buffer_local <= 1;
	end
	else begin
		en_buffer_local <= en_local;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_buffer_local <= 0;
	end
	else if(en_buffer_local) begin
		fifo_data_buffer_local <= {fifo_data_valid_local, fifo_rd_data_local};
	end
end
// BR

	// x pipeline buffer
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x_vaild[0],buffer_x[0]} <= 0;
	end
	else if(en_x) begin
		if(!en_buffer_x) begin
			{buffer_x_vaild[0],buffer_x[0]} <= fifo_data_buffer_x;
		end
		else begin
			{buffer_x_vaild[0],buffer_x[0]} <= {fifo_data_valid_x, fifo_rd_data_x};
		end
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x_vaild[1],buffer_x[1]} <= 0;
	end
	else if(en_x) begin
		{buffer_x_vaild[1],buffer_x[1]} <= {buffer_x_vaild[0],buffer_x[0]};
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x_vaild[2],buffer_x[2]} <= 0;
	end
	else if(en_x) begin
		{buffer_x_vaild[2],buffer_x[2]} <= {buffer_x_vaild[1],buffer_x[1]};
	end
end
	// y pipeline buffer
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_y_vaild[0],buffer_y[0]} <= 0;
	end
	else if(en_y) begin
		if(!en_buffer_y) begin
			{buffer_y_vaild[0],buffer_y[0]} <= fifo_data_buffer_y;
		end
		else begin
			{buffer_y_vaild[0],buffer_y[0]} <= {fifo_data_valid_y, fifo_rd_data_y};
		end
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_y_vaild[1],buffer_y[1]} <= 0;
	end
	else if(en_y) begin
		{buffer_y_vaild[1],buffer_y[1]} <= {buffer_y_vaild[0],buffer_y[0]};
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_y_vaild[2],buffer_y[2]} <= 0;
	end
	else if(en_y) begin
		{buffer_y_vaild[2],buffer_y[2]} <= {buffer_y_vaild[1],buffer_y[1]};
	end
end
	// local pipeline buffer
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_local_vaild[0],buffer_local[0]} <= 0;
	end
	else if(en_local) begin
		if(!en_buffer_local) begin
			{buffer_local_vaild[0],buffer_local[0]} <= fifo_data_buffer_local;
		end
		else begin
			{buffer_local_vaild[0],buffer_local[0]} <= {fifo_data_valid_local, fifo_rd_data_local};
		end
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_local_vaild[1],buffer_local[1]} <= 0;
	end
	else if(en_local) begin
		{buffer_local_vaild[1],buffer_local[1]} <= {buffer_local_vaild[0],buffer_local[0]};
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_local_vaild[2],buffer_local[2]} <= 0;
	end
	else if(en_local) begin
		{buffer_local_vaild[2],buffer_local[2]} <= {buffer_local_vaild[1],buffer_local[1]};
	end
end
// ROUTER_STATION

wire [`DATA_WIDTH-1:0] x_data_tmp;
assign x_data_tmp = buffer_x[0];
assign x_dst = x_data_tmp[2:0];

wire [`DATA_WIDTH-1:0] y_data_tmp;
assign y_data_tmp = buffer_y[0];
assign y_dst = y_data_tmp[2:0];

wire [`DATA_WIDTH-1:0] local_data_tmp;
assign local_data_tmp = buffer_local[0];
assign local_dst = local_data_tmp[2:0];

router_sta_3port router_sta_x(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_x),
	.valid(buffer_x_vaild[0]),
	.router_add(router_add),
	.dst(x_dst),
	.port(port_x_dst)
);


router_sta_3port router_sta_y(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_y),
	.valid(buffer_y_vaild[0]),
	.router_add(router_add),
	.dst(y_dst),
	.port(port_y_dst)
);


router_sta_3port router_sta_local(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_local),
	.valid(buffer_local_vaild[0]),
	.router_add(router_add),
	.dst(local_dst),
	.port(port_local_dst)
);

// SA


switch_allocation_3port unit_sa(
	.clk(clk),
	.rst_n(rst_n),
	.en(1'b1),
	.port_x_dst(port_x_dst),
	.port_y_dst(port_y_dst),
	.port_local_dst(port_local_dst),
	.port_x_en(en_x),
	.port_y_en(en_y),
	.port_local_en(en_local),
	.port_x_valid(x_SA_vaild),
	.port_y_valid(y_SA_vaild),
	.port_local_valid(local_SA_vaild),
	.out_x_sw(port_sw_x),
	.out_y_sw(port_sw_y),
	.out_local_sw(port_sw_local)
);


// OUT

	// X_DATA_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		X_DATA_OUT <= 0;
	end
	else begin
		if(port_sw_x != `SW_STOP) begin
			if(port_sw_x == `SW_X1) X_DATA_OUT <= buffer_x[2];
			else if(port_sw_x == `SW_Y1) X_DATA_OUT <= buffer_y[2];
			else if(port_sw_x == `SW_LOCAL) X_DATA_OUT <= buffer_local[2];
		end
		else X_DATA_OUT <= 0;
	end
end
	// X_DATA_VALID_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		X_DATA_VALID_OUT <= 0;
	end
	else begin
		if(!X_FULL_IN && port_sw_x != `SW_STOP) begin
			X_DATA_VALID_OUT <= 1;
		end
		else X_DATA_VALID_OUT <= 0;
	end
end

	// Y_DATA_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		Y_DATA_OUT <= 0;
	end
	else begin
		if(port_sw_y != `SW_STOP) begin
			if(port_sw_y == `SW_X1) Y_DATA_OUT <= buffer_x[2];
			else if(port_sw_y == `SW_Y1) Y_DATA_OUT <= buffer_y[2];
			else if(port_sw_y == `SW_LOCAL) Y_DATA_OUT <= buffer_local[2];
		end
		else Y_DATA_OUT <= 0;
	end
end
	// Y_DATA_VALID_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		Y_DATA_VALID_OUT <= 0;
	end
	else begin
		if(!Y_FULL_IN && port_sw_y != `SW_STOP) begin
			Y_DATA_VALID_OUT <= 1;
		end
		else Y_DATA_VALID_OUT <= 0;
	end
end

	// LOCAL_DATA_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		LOCAL_DATA_OUT <= 0;
	end
	else begin
		if(port_sw_local != `SW_STOP) begin
			if(port_sw_local == `SW_X1) LOCAL_DATA_OUT <= buffer_x[2];
			else if(port_sw_local == `SW_Y1) LOCAL_DATA_OUT <= buffer_y[2];
			else if(port_sw_local == `SW_LOCAL) LOCAL_DATA_OUT <= buffer_local[2];
		end
		else LOCAL_DATA_OUT <= 0;
	end
end
	// LOCAL_DATA_VALID_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		LOCAL_DATA_VALID_OUT <= 0;
	end
	else begin
		if(port_sw_local != `SW_STOP) begin
			LOCAL_DATA_VALID_OUT <= 1;
		end
		else LOCAL_DATA_VALID_OUT <= 0;
	end
end

//Control

flow_control_3port unit_flow_control(
	.out_x_sw(port_sw_x),
	.out_y_sw(port_sw_y),
	.out_local_sw(port_sw_local),
	.full_x(X_FULL_IN),
	.full_y(Y_FULL_IN),
	.full_local(1'b0),
	.valid_x(x_SA_vaild),
	.valid_y(y_SA_vaild),
	.valid_local(local_SA_vaild),
	
	.empty_x(fifo_empty_x),
	.en_fifo_x(fifo_rd_en_x),
	.en_x(en_x),
	
	.empty_y(fifo_empty_y),
	.en_fifo_y(fifo_rd_en_y),
	.en_y(en_y),
	
	.empty_local(fifo_empty_local),
	.en_fifo_local(fifo_rd_en_local),
	.en_local(en_local)
);



endmodule

