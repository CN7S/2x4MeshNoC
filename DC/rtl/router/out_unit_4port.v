// +FHDR-----------------------------------------------------------------------
// Copyright.
 // ----------------------------------------------------------------------------
// FILE NAME      : out_unit_4port.v
 // DEPARTMENT     : 
 // AUTHOR         : Yuxin Chen
 // AUTHOR’S EMAIL : cyx1324841682@sjtu.edu.cn
 // ----------------------------------------------------------------------------
// RELEASE HISTORY
 // VERSION DATE        AUTHOR  DESCRIPTION
 // 1.0  2024/03/13    Yuxin Chen 	    
// ----------------------------------------------------------------------------
// KEYWORDS    : OUT
 // ----------------------------------------------------------------------------
// PURPOSE     : OUT PORT UNIT
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

module out_unit_4port
(
	input clk,
	input rst_n,
	input full,
	input [2:0] port_sw_id,
	input [`DATA_WIDTH-1:0] data_in_x1,
	input [`DATA_WIDTH-1:0] data_in_x2,
	input [`DATA_WIDTH-1:0] data_in_y,
	input [`DATA_WIDTH-1:0] data_in_local,
	
	output reg [`DATA_WIDTH-1:0] data_out,
	output reg data_valid
);

reg [`DATA_WIDTH-1:0] crossbar_out; // the result of crossbar

// 4 port crossbar
always@(*) begin
	if(port_sw_id == `SW_STOP) 			crossbar_out = 0;
	else if(port_sw_id == `SW_X1) 		crossbar_out = data_in_x1;
	else if(port_sw_id == `SW_X2) 		crossbar_out = data_in_x2;
	else if(port_sw_id == `SW_Y1) 		crossbar_out = data_in_y;
	else if(port_sw_id == `SW_LOCAL) 	crossbar_out = data_in_local;
	else 								crossbar_out = 0;
end // crossbar


// data_out 
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 0;
	end
	else begin
		if(full) data_out <= data_out;
		else data_out <= crossbar_out;
	end
end // data_out


// data_valid
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_valid <= 1'b0;
	end
	else begin
		if(full) 						data_valid <= data_valid;
		else if(port_sw_id != `SW_STOP) data_valid <= 1'b1;
		else 							data_valid <= 1'b0;
	end
end // data_valid

endmodule