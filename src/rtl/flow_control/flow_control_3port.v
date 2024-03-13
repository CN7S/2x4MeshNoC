// +FHDR-----------------------------------------------------------------------
// Copyright.
 // ----------------------------------------------------------------------------
// FILE NAME       : flow_control_3port.v
 // DEPARTMENT     : 
 // AUTHOR         : 
 // AUTHOR’S EMAIL : 
 // ----------------------------------------------------------------------------
// RELEASE HISTORY
 // VERSION DATE        AUTHOR  DESCRIPTION
 // 1.0  2024/03/13    
// ----------------------------------------------------------------------------
// KEYWORDS    : Flow control
 // ----------------------------------------------------------------------------
// PURPOSE     : Control the pipeline of a 3-port router.
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

`include"global.v"

module flow_control_3port(

input 	[2:0]	out_x_sw	,
input 	[2:0]	out_y_sw	,
input 	[2:0]	out_local_sw	,

input 		full_x		,
input 		full_y		,
input 		full_local	,

input 		valid_x		,
input 		valid_y		,
input		valid_local	,

input 		empty_x		,
output 		en_fifo_x	,
output 	reg	en_x		,

input 		empty_y		,
output 		en_fifo_y	,
output 	reg 	en_y		,

input 		empty_local	,
output 		en_fifo_local	,
output 	reg 	en_local

);

// x_flow
always@(*)
begin
	if (valid_x)
	begin
		if 	(out_x_sw == `SW_X1 && !full_x) 	en_x = 1;
		else if (out_y_sw == `SW_X1 && !full_y) 	en_x = 1;
		else if (out_local_sw == `SW_X1 && !full_local) en_x = 1;
		else  en_x = 0;
	end
	else 	en_x = 1;
end

assign en_fifo_x = (en_x && !empty_x);

// y_flow
always@(*)
begin
	if (valid_y)
	begin
		if      (out_x_sw == `SW_Y1 && !full_x) 	en_y = 1;
		else if (out_y_sw == `SW_Y1 && !full_y)		en_y = 1;
		else if (out_local_sw == `SW_Y1 && !full_local) en_y = 1;
		else  en_y = 0;
	end
	else 	en_y = 1;
end

assign en_fifo_y = (en_y && !empty_y);

// local_flow
always@(*)
begin
	if (valid_local)
	begin
		if 	(out_x_sw == `SW_LOCAL && !full_x) 	   en_local = 1;
		else if (out_y_sw == `SW_LOCAL && !full_y)	   en_local = 1;
		else if (out_local_sw == `SW_LOCAL && !full_local) en_local = 1;
		else  en_local = 0;
	end
	else 	en_local = 1;
end

assign en_fifo_local = (en_local && !empty_local);

endmodule
