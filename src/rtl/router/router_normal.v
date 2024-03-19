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
	
	output [`DATA_WIDTH-1:0]	LOCAL_DATA_OUT		,
	output 						LOCAL_DATA_VALID_OUT,
	output						LOCAL_FULL_OUT		,
	
	input [`DATA_WIDTH-1:0]		X1_DATA_IN		,
	input						X1_DATA_VALID_IN	,
	input						X1_FULL_IN		,
	
	output	[`DATA_WIDTH-1:0]	X1_DATA_OUT		,
	output						X1_DATA_VALID_OUT,
	output						X1_FULL_OUT		,

	input [`DATA_WIDTH-1:0]		X2_DATA_IN		,
	input						X2_DATA_VALID_IN	,
	input						X2_FULL_IN		,
	
	output	[`DATA_WIDTH-1:0]	X2_DATA_OUT		,
	output	 					X2_DATA_VALID_OUT,
	output						X2_FULL_OUT		,


	input [`DATA_WIDTH-1:0]		Y_DATA_IN		,
	input						Y_DATA_VALID_IN	,
	input						Y_FULL_IN		,
	
	output	[`DATA_WIDTH-1:0]	Y_DATA_OUT		,
	output						Y_DATA_VALID_OUT,
	output						Y_FULL_OUT		

);

// wire and reg definition
wire [2:0] router_add;

wire [`DATA_WIDTH-1:0] IN_data_local;
wire [`DATA_WIDTH-1:0] IN_data_x1;
wire [`DATA_WIDTH-1:0] IN_data_x2;
wire [`DATA_WIDTH-1:0] IN_data_y;
wire IN_data_valid_local;
wire IN_data_valid_x1;
wire IN_data_valid_x2;
wire IN_data_valid_y;

wire [`DATA_WIDTH-1:0] OUT_data_in_x1;
wire [`DATA_WIDTH-1:0] OUT_data_in_x2;
wire [`DATA_WIDTH-1:0] OUT_data_in_y;
wire [`DATA_WIDTH-1:0] OUT_data_in_local;


wire en_x1;
wire fifo_almost_full_x1;
wire fifo_full_x1;
wire fifo_almost_empty_x1;
wire fifo_empty_x1;
wire [2:0] RC_x1_dst;
wire [2:0] port_x1_dst;


wire en_x2;
wire fifo_almost_full_x2;
wire fifo_full_x2;
wire fifo_almost_empty_x2;
wire fifo_empty_x2;
wire [2:0] RC_x2_dst;
wire [2:0] port_x2_dst;

wire en_y;
wire fifo_almost_full_y;
wire fifo_full_y;
wire fifo_almost_empty_y;
wire fifo_empty_y;
wire [2:0] RC_y_dst;
wire [2:0] port_y_dst;

wire en_local;
wire fifo_almost_full_local;
wire fifo_full_local;
wire fifo_almost_empty_local;
wire fifo_empty_local;
wire [2:0] RC_local_dst;
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


// INPUT UNIT

input_unit input_unit_local
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_local),
	.data_valid_in(LOCAL_DATA_VALID_IN),
	.data_in(LOCAL_DATA_IN),
	
	.almost_full(fifo_almost_full_local),
	.full(LOCAL_FULL_OUT),
	.almost_empty(fifo_almost_empty_local),
	.empty(fifo_empty_local),
	
	.data_out(IN_data_local),
	.data_valid(IN_data_valid_local)
);

input_unit input_unit_x1
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_x1),
	.data_valid_in(X1_DATA_VALID_IN),
	.data_in(X1_DATA_IN),
	
	.almost_full(fifo_almost_full_x1),
	.full(X1_FULL_OUT),
	.almost_empty(fifo_almost_empty_x1),
	.empty(fifo_empty_x1),
	
	.data_out(IN_data_x1),
	.data_valid(IN_data_valid_x1)
);


input_unit input_unit_x2
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_x2),
	.data_valid_in(X2_DATA_VALID_IN),
	.data_in(X2_DATA_IN),
	
	.almost_full(fifo_almost_full_x2),
	.full(X2_FULL_OUT),
	.almost_empty(fifo_almost_empty_x2),
	.empty(fifo_empty_x2),
	
	.data_out(IN_data_x2),
	.data_valid(IN_data_valid_x2)
);


input_unit input_unit_y
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_y),
	.data_valid_in(Y_DATA_VALID_IN),
	.data_in(Y_DATA_IN),
	
	.almost_full(fifo_almost_full_y),
	.full(Y_FULL_OUT),
	.almost_empty(fifo_almost_empty_y),
	.empty(fifo_empty_y),
	
	.data_out(IN_data_y),
	.data_valid(IN_data_valid_y)
);

// DATA_TRANSFER_IN2OUT

data_transfer transfer_unit_x1
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_x1),
	.data_in(IN_data_x1),
	.data_out(OUT_data_in_x1)
);

data_transfer transfer_unit_x2
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_x2),
	.data_in(IN_data_x2),
	.data_out(OUT_data_in_x2)
);

data_transfer transfer_unit_y
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_y),
	.data_in(IN_data_y),
	.data_out(OUT_data_in_y)
);

data_transfer transfer_unit_local
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_local),
	.data_in(IN_data_local),
	.data_out(OUT_data_in_local)
);

// ROUTER_STATION

wire [`DATA_WIDTH-1:0] RC_x1_data_tmp;
assign RC_x1_data_tmp = IN_data_x1;
assign RC_x1_dst = RC_x1_data_tmp[2:0];

wire [`DATA_WIDTH-1:0] RC_x2_data_tmp;
assign RC_x2_data_tmp = IN_data_x2;
assign RC_x2_dst = RC_x2_data_tmp[2:0];

wire [`DATA_WIDTH-1:0] RC_y_data_tmp;
assign RC_y_data_tmp = IN_data_y;
assign RC_y_dst = RC_y_data_tmp[2:0];

wire [`DATA_WIDTH-1:0] RC_local_data_tmp;
assign RC_local_data_tmp = IN_data_local;
assign RC_local_dst = RC_local_data_tmp[2:0];

router_compute_4port router_compute_x1(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_x1),
	.valid(IN_data_valid_x1),
	.router_add(router_add),
	.dst(RC_x1_dst),
	.port(port_x1_dst)
);

router_compute_4port router_compute_x2(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_x2),
	.valid(IN_data_valid_x2),
	.router_add(router_add),
	.dst(RC_x2_dst),
	.port(port_x2_dst)
);



router_compute_4port router_compute_y(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_y),
	.valid(IN_data_valid_y),
	.router_add(router_add),
	.dst(RC_y_dst),
	.port(port_y_dst)
);


router_compute_4port router_compute_local(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_local),
	.valid(IN_data_valid_local),
	.router_add(router_add),
	.dst(RC_local_dst),
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
	.out_x1_busy(X1_FULL_IN),
	.out_x2_busy(X2_FULL_IN),
	.out_y_busy(Y_FULL_IN),
	.out_local_busy(1'b0),
	.port_x1_valid(x1_SA_vaild),
	.port_x2_valid(x2_SA_vaild),
	.port_y_valid(y_SA_vaild),
	.port_local_valid(local_SA_vaild),
	.out_x1_sw(port_sw_x1),
	.out_x2_sw(port_sw_x2),
	.out_y_sw(port_sw_y),
	.out_local_sw(port_sw_local)
);


// OUT UNIT

// X1 PORT
out_unit_4port out_unit_x1(
	.clk(clk),
	.rst_n(rst_n),
	.full(X1_FULL_IN),
	.port_sw_id(port_sw_x1),
	.data_in_x1(OUT_data_in_x1),
	.data_in_x2(OUT_data_in_x2),
	.data_in_y(OUT_data_in_y),
	.data_in_local(OUT_data_in_local),
	
	.data_out(X1_DATA_OUT),
	.data_valid(X1_DATA_VALID_OUT)
); // X1 PORT

// X2 PORT
out_unit_4port out_unit_x2(
	.clk(clk),
	.rst_n(rst_n),
	.full(X2_FULL_IN),
	.port_sw_id(port_sw_x2),
	.data_in_x1(OUT_data_in_x1),
	.data_in_x2(OUT_data_in_x2),
	.data_in_y(OUT_data_in_y),
	.data_in_local(OUT_data_in_local),
	
	.data_out(X2_DATA_OUT),
	.data_valid(X2_DATA_VALID_OUT)
); // X2 PORT

// Y PORT
out_unit_4port out_unit_y(
	.clk(clk),
	.rst_n(rst_n),
	.full(Y_FULL_IN),
	.port_sw_id(port_sw_y),
	.data_in_x1(OUT_data_in_x1),
	.data_in_x2(OUT_data_in_x2),
	.data_in_y(OUT_data_in_y),
	.data_in_local(OUT_data_in_local),
	
	.data_out(Y_DATA_OUT),
	.data_valid(Y_DATA_VALID_OUT)
); // Y PORT

// LOCAL PORT
out_unit_4port out_unit_local(
	.clk(clk),
	.rst_n(rst_n),
	.full(1'b0),
	.port_sw_id(port_sw_local),
	.data_in_x1(OUT_data_in_x1),
	.data_in_x2(OUT_data_in_x2),
	.data_in_y(OUT_data_in_y),
	.data_in_local(OUT_data_in_local),
	
	.data_out(LOCAL_DATA_OUT),
	.data_valid(LOCAL_DATA_VALID_OUT)
); // LOCAL PORT

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