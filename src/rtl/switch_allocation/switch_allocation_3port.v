// +FHDR-----------------------------------------------------------------------
// Copyright.
 // ----------------------------------------------------------------------------
// FILE NAME      : switch_allocation_3port.v
 // DEPARTMENT     : 
 // AUTHOR         : Yuxin Chen
 // AUTHOR’S EMAIL : cyx1324841682@sjtu.edu.cn
 // ----------------------------------------------------------------------------
// RELEASE HISTORY
 // VERSION DATE        AUTHOR  DESCRIPTION
 // 1.0  2024/03/13    Yuxin Chen 	    
// ----------------------------------------------------------------------------
// KEYWORDS    : Switch allocation
 // ----------------------------------------------------------------------------
// PURPOSE     : 3 PORT SA, allocate output crossbar.
 // ----------------------------------------------------------------------------
// PARAMETERS
 //     PARAM NAME      RANGE    : DESCRIPTION         : DEFAULT : UNITS
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
module switch_allocation_3port
(
	input				clk		,
	input				rst_n	,
	input				en		,
	
	// input_dst
	input	[2:0]		port_x_dst		,
	input	[2:0]		port_y_dst		,
	input	[2:0]		port_local_dst	,

	input 				port_x_en,
	input 				port_y_en,
	input 				port_local_en,
	
	input				out_x_busy,
	input				out_y_busy,
	input				out_local_busy,
	
	//input vaild
	output reg			port_x_valid,
	output reg			port_y_valid,
	output reg 			port_local_valid,

	// allocate outport switch
	output reg	[2:0]	out_x_sw		,
	output reg	[2:0]	out_y_sw		,
	output reg	[2:0]	out_local_sw	
);

reg out_x_priority_x;
reg out_x_priority_y;
reg out_x_priority_local;
reg out_y_priority_x;
reg out_y_priority_y;
reg out_y_priority_local;
reg out_local_priority_x;
reg out_local_priority_y;
reg out_local_priority_local;

reg [2:0] out_x_sw_temp;
reg [2:0] out_y_sw_temp;
reg [2:0] out_local_sw_temp;

reg [2:0] port_x_dst_buf;
reg [2:0] port_y_dst_buf;
reg [2:0] port_local_dst_buf;
wire [2:0] port_x_dst_tmp;
wire [2:0] port_y_dst_tmp;
wire [2:0] port_local_dst_tmp;


assign port_x_dst_tmp = port_x_en ? port_x_dst : port_x_dst_buf;
assign port_y_dst_tmp =  port_y_en ? port_y_dst : port_y_dst_buf;
assign port_local_dst_tmp =  port_local_en ? port_local_dst : port_local_dst_buf;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		port_x_dst_buf <= `EMPTY;
		port_y_dst_buf <= `EMPTY;
		port_local_dst_buf <= `EMPTY;
	end
	else begin
		if(port_x_en)		port_x_dst_buf <= port_x_dst;
		if(port_y_en)		port_y_dst_buf <= port_y_dst;
		if(port_local_en)	port_local_dst_buf <= port_local_dst;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_x_priority_x 			<= 1'b1;
		out_x_priority_local		<= 1'b0;
		out_x_priority_y 			<= 1'b0;
	end
	else if(en && !out_x_busy) begin
		out_x_priority_x 			<= out_x_priority_local;
		out_x_priority_y			<= out_x_priority_x;
		out_x_priority_local		<= out_x_priority_y;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_y_priority_x 			<= 1'b1;
		out_y_priority_local		<= 1'b0;
		out_y_priority_y 			<= 1'b0;
	end
	else if(en && !out_y_busy) begin
		out_y_priority_x 			<= out_y_priority_local;
		out_y_priority_y			<= out_y_priority_x;
		out_y_priority_local		<= out_y_priority_y;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_local_priority_x 			<= 1'b1;
		out_local_priority_local		<= 1'b0;
		out_local_priority_y 			<= 1'b0;
	end
	else if(en && !out_local_busy) begin
		out_local_priority_x 			<= out_local_priority_local;
		out_local_priority_y			<= out_local_priority_x;
		out_local_priority_local		<= out_local_priority_y;
	end
end


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_x_sw			<= `SW_STOP;
		out_y_sw			<= `SW_STOP;
		out_local_sw		<= `SW_STOP;
	end
	else if(en) begin
		out_x_sw			<= out_x_sw_temp;
		out_y_sw			<= out_y_sw_temp;
		out_local_sw		<= out_local_sw_temp;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		port_x_valid 		<= 0;
		port_y_valid 		<= 0;
		port_local_valid 	<= 0;
	end
	else begin
		if(port_x_dst_tmp != `EMPTY) port_x_valid <= 1;
		else					port_x_valid <= 0;
		if(port_y_dst_tmp != `EMPTY) port_y_valid <= 1;
		else					port_y_valid <= 0;
		if(port_local_dst_tmp != `EMPTY) port_local_valid <= 1;
		else					port_local_valid <= 0;
	end
end


// out_local_port
always@(*) begin
	if(out_local_priority_local) begin
		if(port_local_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else if(port_y_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else begin
			out_local_sw_temp = `SW_STOP;
		end
	end
	else if(out_local_priority_x) begin
		if(port_x_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else if(port_y_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else if(port_local_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_local_sw_temp = `SW_STOP;
		end
	end
	else if(out_local_priority_y) begin
		if(port_y_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else if(port_local_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst_tmp == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else  begin
			out_local_sw_temp = `SW_STOP;
		end
	end
end


// out_x_port
always@(*) begin
	if(out_x_priority_local) begin
		if(port_local_dst_tmp == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst_tmp == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_X1;
		end
		else if(port_y_dst_tmp == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_Y1;
		end
		else begin
			out_x_sw_temp = `SW_STOP;
		end
	end
	else if(out_x_priority_x) begin
		if(port_x_dst_tmp == `OUT_X1_PORT)  begin
			out_x_sw_temp = `SW_X1;
		end
		else if(port_y_dst_tmp == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_Y1;
		end
		else if(port_local_dst_tmp == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_x_sw_temp = `SW_STOP;
		end
	end
	else if(out_x_priority_y) begin
		if(port_y_dst_tmp == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_Y1;
		end
		else if(port_local_dst_tmp == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst_tmp == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_X1;
		end
		else  begin
			out_x_sw_temp = `SW_STOP;
		end
	end
end


// out_y_port
always@(*) begin
	if(out_y_priority_local) begin
		if(port_local_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else if(port_y_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else begin
			out_y_sw_temp = `SW_STOP;
		end
	end
	else if(out_y_priority_x) begin
		if(port_x_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else if(port_y_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else if(port_local_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_y_sw_temp = `SW_STOP;
		end
	end
	else if(out_y_priority_y) begin
		if(port_y_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else if(port_local_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst_tmp == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else  begin
			out_y_sw_temp = `SW_STOP;
		end
	end
end

endmodule

