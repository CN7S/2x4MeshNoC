// +FHDR-----------------------------------------------------------------------
// Copyright.
 // ----------------------------------------------------------------------------
// FILE NAME      : router_border.v
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
// PURPOSE     : 3 PORT ROUTER(X,Y,LOCAL), for 2x4mesh border ROUTER.
 // ----------------------------------------------------------------------------
// PARAMETERS
 //     PARAM NAME      RANGE    : DESCRIPTION         : DEFAULT : UNITS
 //		ROUTER_ADDRESS  [0,3,4,7]: LOCAL Router ADDRESS: 3'b0    :
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
module router_border#(
	parameter ROUTER_ADDRESS = 3'b0
)
(
	input				clk		,
	input 				rst_n	,
	
	input [`DATA_WIDTH-1:0]		LOCAL_DATA_IN		,
	input						LOCAL_DATA_VALID_IN	,
	
	output	 [`DATA_WIDTH-1:0]	LOCAL_DATA_OUT		,
	output						LOCAL_DATA_VALID_OUT,
	output						LOCAL_FULL_OUT		,
	
	input [`DATA_WIDTH-1:0]		X_DATA_IN		,
	input						X_DATA_VALID_IN	,
	input						X_FULL_IN		,
	
	output	 [`DATA_WIDTH-1:0]	X_DATA_OUT		,
	output						X_DATA_VALID_OUT,
	output						X_FULL_OUT		,

	input [`DATA_WIDTH-1:0]		Y_DATA_IN		,
	input						Y_DATA_VALID_IN	,
	input						Y_FULL_IN		,
	
	output	 [`DATA_WIDTH-1:0]	Y_DATA_OUT		,
	output						Y_DATA_VALID_OUT,
	output			          	Y_FULL_OUT		
);

// wire and reg definition
wire [2:0] router_add;

wire [`DATA_WIDTH-1:0] IN_data_local;
wire [`DATA_WIDTH-1:0] IN_data_x;
wire [`DATA_WIDTH-1:0] IN_data_y;
wire IN_data_valid_local;
wire IN_data_valid_x;
wire IN_data_valid_y;

wire [`DATA_WIDTH-1:0] OUT_data_in_x;
wire [`DATA_WIDTH-1:0] OUT_data_in_y;
wire [`DATA_WIDTH-1:0] OUT_data_in_local;



wire en_x;
wire fifo_almost_full_x;
wire fifo_full_x;
wire fifo_almost_empty_x;
wire fifo_empty_x;
wire [2:0] RC_x_dst;
wire [2:0] port_x_dst;

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

wire x_SA_vaild;
wire y_SA_vaild;
wire local_SA_vaild;

wire [2:0] port_sw_x;
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

input_unit input_unit_x
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_x),
	.data_valid_in(X_DATA_VALID_IN),
	.data_in(X_DATA_IN),
	
	.almost_full(fifo_almost_full_x),
	.full(X_FULL_OUT),
	.almost_empty(fifo_almost_empty_x),
	.empty(fifo_empty_x),
	
	.data_out(IN_data_x),
	.data_valid(IN_data_valid_x)
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

data_transfer transfer_unit_x
(
	.clk(clk),
	.rst_n(rst_n),
	.enable(en_x),
	.data_in(IN_data_x),
	.data_out(OUT_data_in_x)
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

// ROUTER_COMPUTER

wire [`DATA_WIDTH-1:0] RC_x_data_temp;
assign RC_x_data_temp = IN_data_x;
assign RC_x_dst = RC_x_data_temp[2:0];

wire [`DATA_WIDTH-1:0] RC_y_data_temp;
assign RC_y_data_temp = IN_data_y;
assign RC_y_dst = RC_y_data_temp[2:0];

wire [`DATA_WIDTH-1:0] RC_local_data_temp;
assign RC_local_data_temp = IN_data_local;
assign RC_local_dst = RC_local_data_temp[2:0];

router_compute_3port router_compute_x(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_x),
	.valid(IN_data_valid_x),
	.router_add(router_add),
	.dst(RC_x_dst),
	.port(port_x_dst)
);


router_compute_3port router_compute_y(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_y),
	.valid(IN_data_valid_y),
	.router_add(router_add),
	.dst(RC_y_dst),
	.port(port_y_dst)
);


router_compute_3port router_compute_local(
	.clk(clk),
	.rst_n(rst_n),
	.en(en_local),
	.valid(IN_data_valid_local),
	.router_add(router_add),
	.dst(RC_local_dst),
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
	.out_x_busy(X_FULL_IN),
	.out_y_busy(Y_FULL_IN),
	.out_local_busy(1'b0),
	.port_x_valid(x_SA_vaild),
	.port_y_valid(y_SA_vaild),
	.port_local_valid(local_SA_vaild),
	.out_x_sw(port_sw_x),
	.out_y_sw(port_sw_y),
	.out_local_sw(port_sw_local)
);


// OUT Unit


// X PORT
out_unit_3port out_unit_x(
	.clk(clk),
	.rst_n(rst_n),
	.full(X_FULL_IN),
	.port_sw_id(port_sw_x),
	.data_in_x(OUT_data_in_x),
	.data_in_y(OUT_data_in_y),
	.data_in_local(OUT_data_in_local),
	
	.data_out(X_DATA_OUT),
	.data_valid(X_DATA_VALID_OUT)
); // X PORT


// Y PORT
out_unit_3port out_unit_y(
	.clk(clk),
	.rst_n(rst_n),
	.full(Y_FULL_IN),
	.port_sw_id(port_sw_y),
	.data_in_x(OUT_data_in_x),
	.data_in_y(OUT_data_in_y),
	.data_in_local(OUT_data_in_local),
	
	.data_out(Y_DATA_OUT),
	.data_valid(Y_DATA_VALID_OUT)
); // Y PORT


// LOCAL PORT
out_unit_3port out_unit_local(
	.clk(clk),
	.rst_n(rst_n),
	.full(1'b0), // LOCAL_FULL_IN IS ALWAYS LOW
	.port_sw_id(port_sw_local),
	.data_in_x(OUT_data_in_x),
	.data_in_y(OUT_data_in_y),
	.data_in_local(OUT_data_in_local),
	
	.data_out(LOCAL_DATA_OUT),
	.data_valid(LOCAL_DATA_VALID_OUT)
); // LOCAL PORT

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
	.en_x(en_x),
	
	.empty_y(fifo_empty_y),
	.en_y(en_y),
	
	.empty_local(fifo_empty_local),
	.en_local(en_local)
);



endmodule

