// +FHDR-----------------------------------------------------------------------
// Copyright.
 // ----------------------------------------------------------------------------
// FILE NAME      : router_normal.v
 // DEPARTMENT     : 
 // AUTHOR         : Yuxin Chen
 // AUTHOR’S EMAIL : cyx1324841682@sjtu.edu.cn
 // ----------------------------------------------------------------------------
// RELEASE HISTORY
 // VERSION DATE        AUTHOR  DESCRIPTION
 // 1.0  2024/03/13    Yuxin Chen 	    
// ----------------------------------------------------------------------------
// KEYWORDS    : ROUTER
 // ----------------------------------------------------------------------------
// PURPOSE     : 4 PORT ROUTER(X1,X2,Y,LOCAL), for 2x4mesh normol ROUTER.
 // ----------------------------------------------------------------------------
// PARAMETERS
 //     PARAM NAME      RANGE    : DESCRIPTION         : DEFAULT : UNITS
 //		ROUTER_ADDRESS  [1,2,5,6]: LOCAL Router ADDRESS: 3'b1    :
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
module router_normal#(
	parameter ROUTER_ADDRESS = 3'b1
)(
	input				clk		,
	input 				rst_n	,
	
	input [`DATA_WIDTH-1:0]		LOCAL_DATA_IN		,
	input						LOCAL_DATA_VALID_IN	,
	
	output	reg [`DATA_WIDTH-1:0]	LOCAL_DATA_OUT		,
	output	reg 					LOCAL_DATA_VALID_OUT,
	output						LOCAL_FULL_OUT		,
	
	input [`DATA_WIDTH-1:0]		X1_DATA_IN		,
	input						X1_DATA_VALID_IN	,
	input						X1_FULL_IN		,
	
	output	reg [`DATA_WIDTH-1:0]	X1_DATA_OUT		,
	output	reg 					X1_DATA_VALID_OUT,
	output						X1_FULL_OUT		,

	input [`DATA_WIDTH-1:0]		X2_DATA_IN		,
	input						X2_DATA_VALID_IN	,
	input						X2_FULL_IN		,
	
	output	reg [`DATA_WIDTH-1:0]	X2_DATA_OUT		,
	output	reg 					X2_DATA_VALID_OUT,
	output						X2_FULL_OUT		,


	input [`DATA_WIDTH-1:0]		Y_DATA_IN		,
	input						Y_DATA_VALID_IN	,
	input						Y_FULL_IN		,
	
	output	reg [`DATA_WIDTH-1:0]	Y_DATA_OUT		,
	output	reg 					Y_DATA_VALID_OUT,
	output						Y_FULL_OUT		

);

// wire and reg definition
wire [2:0] router_add;


reg buffer_x1_vaild	[0:2];
reg buffer_x2_vaild	[0:2];
reg buffer_y_vaild	[0:2];
reg buffer_local_vaild	[0:2];
reg [31:0] buffer_x1 [0:2];
reg [31:0] buffer_x2 [0:2];
reg [31:0] buffer_y [0:2];
reg [31:0] buffer_local [0:2];

wire en_x1;
reg en_buffer_x1;
reg [32:0] fifo_data_buffer_x1;
reg fifo_data_valid_x1;
wire [`DATA_WIDTH-1:0] fifo_rd_data_x1;
wire fifo_rd_en_x1;
wire fifo_almost_full_x1;
wire fifo_full_x1;
wire fifo_almost_empty_x1;
wire fifo_empty_x1;
wire [2:0] x1_dst;
wire [2:0] port_x1_dst;


wire en_x2;
reg en_buffer_x2;
reg [32:0] fifo_data_buffer_x2;
reg fifo_data_valid_x2;
wire [`DATA_WIDTH-1:0] fifo_rd_data_x2;
wire fifo_rd_en_x2;
wire fifo_almost_full_x2;
wire fifo_full_x2;
wire fifo_almost_empty_x2;
wire fifo_empty_x2;
wire [2:0] x2_dst;
wire [2:0] port_x2_dst;

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

wire x1_SA_vaild;
wire x2_SA_vaild;
wire y_SA_vaild;
wire local_SA_vaild;

wire [2:0] port_sw_x1;
wire [2:0] port_sw_x2;
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


sync_fifo_8x32 unit_fifo_x1(
	.clk(clk),
	.rst_n(rst_n),
	.wr_en(X1_DATA_VALID_IN),
	.wr_data(X1_DATA_IN),
	.almost_full(fifo_almost_full_x1),
	.full(X1_FULL_OUT),
	
	.rd_en(fifo_rd_en_x1),
	.rd_data(fifo_rd_data_x1),
	.almost_empty(fifo_almost_empty_x1),
	.empty(fifo_empty_x1)
);

sync_fifo_8x32 unit_fifo_x2(
	.clk(clk),
	.rst_n(rst_n),
	.wr_en(X2_DATA_VALID_IN),
	.wr_data(X2_DATA_IN),
	.almost_full(fifo_almost_full_x2),
	.full(X2_FULL_OUT),
	
	.rd_en(fifo_rd_en_x2),
	.rd_data(fifo_rd_data_x2),
	.almost_empty(fifo_almost_empty_x2),
	.empty(fifo_empty_x2)
);


sync_fifo_8x32 unit_fifo_y(
	.clk(clk),
	.rst_n(rst_n),
	.wr_en(Y_DATA_VALID_IN),
	.wr_data(Y_DATA_IN),
	.almost_full(fifo_almost_full_y),
	.full(Y_FULL_OUT),
	
	.rd_en(fifo_rd_en_y),
	.rd_data(fifo_rd_data_y),
	.almost_empty(fifo_almost_empty_y),
	.empty(fifo_empty_y)
);
	// x1_fifo_buffer
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_valid_x1 <= 0;
	end
	else begin
		fifo_data_valid_x1 <= fifo_rd_en_x1;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		en_buffer_x1 <= 1;
	end
	else begin
		en_buffer_x1 <= en_x1;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_buffer_x1 <= 0;
	end
	else if(en_buffer_x1) begin
		fifo_data_buffer_x1 <= {fifo_data_valid_x1, fifo_rd_data_x1};
	end
end

	// x2_fifo_buffer
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_valid_x2 <= 0;
	end
	else begin
		fifo_data_valid_x2 <= fifo_rd_en_x2;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		en_buffer_x2 <= 1;
	end
	else begin
		en_buffer_x2 <= en_x2;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_data_buffer_x2 <= 0;
	end
	else if(en_buffer_x2) begin
		fifo_data_buffer_x2 <= {fifo_data_valid_x2, fifo_rd_data_x2};
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

	// x1 pipeline
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x1_vaild[0],buffer_x1[0]} <= 0;
	end
	else if(en_x1) begin
		if(!en_buffer_x1) begin
			{buffer_x1_vaild[0],buffer_x1[0]} <= fifo_data_buffer_x1;
		end
		else begin
			{buffer_x1_vaild[0],buffer_x1[0]} <= {fifo_data_valid_x1, fifo_rd_data_x1};
		end
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x1_vaild[1],buffer_x1[1]} <= 0;
	end
	else if(en_x1) begin
		{buffer_x1_vaild[1],buffer_x1[1]} <= {buffer_x1_vaild[0],buffer_x1[0]};
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x1_vaild[2],buffer_x1[2]} <= 0;
	end
	else if(en_x1) begin
		{buffer_x1_vaild[2],buffer_x1[2]} <= {buffer_x1_vaild[1],buffer_x1[1]};
	end
end


	// x2 pipeline
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x2_vaild[0],buffer_x2[0]} <= 0;
	end
	else if(en_x2) begin
		if(!en_buffer_x2) begin
			{buffer_x2_vaild[0],buffer_x2[0]} <= fifo_data_buffer_x2;
		end
		else begin
			{buffer_x2_vaild[0],buffer_x2[0]} <= {fifo_data_valid_x2, fifo_rd_data_x2};
		end
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x2_vaild[1],buffer_x2[1]} <= 0;
	end
	else if(en_x2) begin
		{buffer_x2_vaild[1],buffer_x2[1]} <= {buffer_x2_vaild[0],buffer_x2[0]};
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{buffer_x2_vaild[2],buffer_x2[2]} <= 0;
	end
	else if(en_x2) begin
		{buffer_x2_vaild[2],buffer_x2[2]} <= {buffer_x2_vaild[1],buffer_x2[1]};
	end
end


	// y pipeline
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
	// local pipeline
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

wire [`DATA_WIDTH-1:0] x1_data_tmp;
assign x1_data_tmp = buffer_x1[0];
assign x1_dst = x1_data_tmp[2:0];

wire [`DATA_WIDTH-1:0] x2_data_tmp;
assign x2_data_tmp = buffer_x2[0];
assign x2_dst = x2_data_tmp[2:0];

wire [`DATA_WIDTH-1:0] y_data_tmp;
assign y_data_tmp = buffer_y[0];
assign y_dst = y_data_tmp[2:0];

wire [`DATA_WIDTH-1:0] local_data_tmp;
assign local_data_tmp = buffer_local[0];
assign local_dst = local_data_tmp[2:0];

router_sta_4port router_sta_x1(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_x1),
	.valid(buffer_x1_vaild[0]),
	.router_add(router_add),
	.dst(x1_dst),
	.port(port_x1_dst)
);

router_sta_4port router_sta_x2(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_x2),
	.valid(buffer_x2_vaild[0]),
	.router_add(router_add),
	.dst(x2_dst),
	.port(port_x2_dst)
);



router_sta_4port router_sta_y(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_y),
	.valid(buffer_y_vaild[0]),
	.router_add(router_add),
	.dst(y_dst),
	.port(port_y_dst)
);


router_sta_4port router_sta_local(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_local),
	.valid(buffer_local_vaild[0]),
	.router_add(router_add),
	.dst(local_dst),
	.port(port_local_dst)
);

// SA


switch_allocation_4port unit_sa(
	.clk(clk),
	.rst_n(rst_n),
	.en(1'b1),
	.port_x1_dst(port_x1_dst),
	.port_x2_dst(port_x2_dst),
	.port_y_dst(port_y_dst),
	.port_local_dst(port_local_dst),
	.port_x1_en(en_x1),
	.port_x2_en(en_x2),
	.port_y_en(en_y),
	.port_local_en(en_local),
	.port_x1_valid(x1_SA_vaild),
	.port_x2_valid(x2_SA_vaild),
	.port_y_valid(y_SA_vaild),
	.port_local_valid(local_SA_vaild),
	.out_x1_sw(port_sw_x1),
	.out_x2_sw(port_sw_x2),
	.out_y_sw(port_sw_y),
	.out_local_sw(port_sw_local)
);


// OUT

	// X1_DATA_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		X1_DATA_OUT <= 0;
	end
	else begin
		if(X1_FULL_IN) X1_DATA_OUT <= X1_DATA_OUT;
		else if(port_sw_x1 != `SW_STOP) begin
			if(port_sw_x1 == `SW_X1) X1_DATA_OUT <= buffer_x1[2];
			else if(port_sw_x1 == `SW_X2) X1_DATA_OUT <= buffer_x2[2];
			else if(port_sw_x1 == `SW_Y1) X1_DATA_OUT <= buffer_y[2];
			else if(port_sw_x1 == `SW_LOCAL) X1_DATA_OUT <= buffer_local[2];
		end
		else X1_DATA_OUT <= 0;
	end
end
	// X1_DATA_VALID_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		X1_DATA_VALID_OUT <= 0;
	end
	else begin
		if(X1_FULL_IN) X1_DATA_VALID_OUT <= X1_DATA_VALID_OUT;
		else if(!X1_FULL_IN && port_sw_x1 != `SW_STOP) begin
			X1_DATA_VALID_OUT <= 1;
		end
		else X1_DATA_VALID_OUT <= 0;
	end
end

	// X2_DATA_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		X2_DATA_OUT <= 0;
	end
	else begin
		if(X2_FULL_IN) X2_DATA_OUT <= X2_DATA_OUT;
		else if(port_sw_x2 != `SW_STOP) begin
			if(port_sw_x2 == `SW_X1) X2_DATA_OUT <= buffer_x1[2];
			else if(port_sw_x2 == `SW_X2) X2_DATA_OUT <= buffer_x2[2];
			else if(port_sw_x2 == `SW_Y1) X2_DATA_OUT <= buffer_y[2];
			else if(port_sw_x2 == `SW_LOCAL) X2_DATA_OUT <= buffer_local[2];
		end
		else X2_DATA_OUT <= 0;
	end
end
	// X2_DATA_VALID_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		X2_DATA_VALID_OUT <= 0;
	end
	else begin
		if(X2_FULL_IN) X2_DATA_VALID_OUT <= X2_DATA_VALID_OUT;
		else if(!X2_FULL_IN && port_sw_x2 != `SW_STOP) begin
			X2_DATA_VALID_OUT <= 1;
		end
		else X2_DATA_VALID_OUT <= 0;
	end
end

	// Y_DATA_OUT
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		Y_DATA_OUT <= 0;
	end
	else begin
		if(Y_FULL_IN) Y_DATA_OUT <= Y_DATA_OUT;
		else if(port_sw_y != `SW_STOP) begin
			if(port_sw_y == `SW_X1) Y_DATA_OUT <= buffer_x1[2];
			else if(port_sw_y == `SW_X2) Y_DATA_OUT <= buffer_x2[2];
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
		if(Y_FULL_IN) Y_DATA_VALID_OUT <= Y_DATA_VALID_OUT;
		else if(!Y_FULL_IN && port_sw_y != `SW_STOP) begin
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
			if(port_sw_local == `SW_X1) LOCAL_DATA_OUT <= buffer_x1[2];
			else if(port_sw_local == `SW_X2) LOCAL_DATA_OUT <= buffer_x2[2];
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

flow_control_4port unit_flow_control(
	.out_x1_sw(port_sw_x1),
	.out_x2_sw(port_sw_x2),
	.out_y_sw(port_sw_y),
	.out_local_sw(port_sw_local),
	
	.full_x1(X1_FULL_IN),
	.full_x2(X2_FULL_IN),
	.full_y(Y_FULL_IN),
	.full_local(1'b0),
	
	.valid_x1(x1_SA_vaild),
	.valid_x2(x2_SA_vaild),
	.valid_y(y_SA_vaild),
	.valid_local(local_SA_vaild),
	
	.empty_x1(fifo_empty_x1),
	.en_fifo_x1(fifo_rd_en_x1),
	.en_x1(en_x1),
	
	.empty_x2(fifo_empty_x2),
	.en_fifo_x2(fifo_rd_en_x2),
	.en_x2(en_x2),
	
	.empty_y(fifo_empty_y),
	.en_fifo_y(fifo_rd_en_y),
	.en_y(en_y),
	
	.empty_local(fifo_empty_local),
	.en_fifo_local(fifo_rd_en_local),
	.en_local(en_local)
);

endmodule