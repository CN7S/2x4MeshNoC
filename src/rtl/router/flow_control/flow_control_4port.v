// +FHDR-----------------------------------------------------------------------
// Copyright.
 // ----------------------------------------------------------------------------
// FILE NAME       : flow_control_4port.v
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
// PURPOSE     : Control the pipeline of a 4-port router.
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

module flow_control_4port(

input 	[2:0]	out_x1_sw	,
input 	[2:0]	out_x2_sw	,
input 	[2:0]	out_y_sw	,
input 	[2:0]	out_local_sw	,

input 		full_x1		,
input 		full_x2		,
input 		full_y		,
input 		full_local	,

input 		valid_x1	,
input 		valid_x2	,
input 		valid_y		,
input		valid_local	,

input 		empty_x1	,
output 		en_fifo_x1	,
output 	reg	en_x1		,

input 		empty_x2	,
output 		en_fifo_x2	,
output 	reg	en_x2	 	,

input 		empty_y		,
output 		en_fifo_y	,
output 	reg 	en_y		,

input 		empty_local	,
output 		en_fifo_local	,
output 	reg 	en_local

);

// x1_flow
always@(*)
begin
	if (valid_x1)
	begin
		if       (out_x1_sw == `SW_X1 && !full_x1)        en_x1 = 1;
		else if  (out_x2_sw == `SW_X1 && !full_x2)        en_x1 = 1;
		else if  (out_y_sw == `SW_X1 && !full_y)          en_x1 = 1;
		else if  (out_local_sw == `SW_X1 && !full_local)  en_x1 = 1;
		else	en_x1 = 0;
	end
	else 	en_x1 = 1;
end

assign en_fifo_x1 = (en_x1 && !empty_x1);

// x2_flow
always@(*)
begin
	if (valid_x2)
	begin
		if      (out_x1_sw == `SW_X2 && !full_x1)       en_x2 = 1;
		else if (out_x2_sw == `SW_X2 && !full_x2)       en_x2 = 1;
		else if (out_y_sw == `SW_X2 && !full_y)         en_x2 = 1;
		else if (out_local_sw == `SW_X2 && !full_local) en_x2 = 1;
		else	en_x2 = 0;
	end
	else 	en_x2 = 1;
end

assign en_fifo_x2 = (en_x2 && !empty_x2);

// y_flow
always@(*)
begin
	if (valid_y)
	begin
		if      (out_x1_sw == `SW_Y1 && !full_x1)       en_y = 1;
		else if (out_x2_sw == `SW_Y1 && !full_x2)       en_y = 1;
		else if (out_y_sw == `SW_Y1 && !full_y)         en_y = 1;
		else if (out_local_sw == `SW_Y1 && !full_local) en_y = 1;
		else	en_y = 0;
	end
	else 	en_y = 1;
end

assign en_fifo_y = (en_y && !empty_y);

// local_flow
always@(*)
begin
	if (valid_local)
	begin
		if      (out_x1_sw == `SW_LOCAL && !full_x1)        en_local = 1;
		else if (out_x2_sw == `SW_LOCAL && !full_x2)        en_local = 1;
		else if (out_y_sw == `SW_LOCAL && !full_y)          en_local = 1;
		else if (out_local_sw == `SW_LOCAL && !full_local)  en_local = 1;
		else	en_local = 0;
	end
	else 	en_local = 1;
end

assign en_fifo_local = (en_local && !empty_local);

endmodule
