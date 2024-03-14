// +FHDR-----------------------------------------------------------------------
// Copyright.
// ----------------------------------------------------------------------------
 // FILE NAME      : router_sta_3port.v
 // DEPARTMENT     :
 // AUTHOR         : Yi Wan
 // AUTHOR’S EMAIL : wanyi2003@sjtu.edu.cn
// ----------------------------------------------------------------------------
// RELEASE HISTORY
 // VERSION DATE        AUTHOR  DESCRIPTION
 // 1.0  2024-03-13  Yi Wan     
// ----------------------------------------------------------------------------
// KEYWORDS    : 3-port static routing
 // ----------------------------------------------------------------------------
// PURPOSE     : Determine output port for a 3-port router.
 // ----------------------------------------------------------------------------
// PARAMETERS
 //     PARAM NAME      RANGE    : DESCRIPTION       : DEFAULT : UNITS
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

module router_compute_3port
(
	input 			clk,
	input 			rst_n,
	input 			en,

	input			valid,
	input		[2:0]	router_add,
	input		[2:0]	dst,

  	output	reg 	[2:0]	port
);

always@(posedge clk or negedge rst_n) 
begin
	if (!rst_n) 
		port <= `EMPTY;
	else if (en)
	begin
		if(!valid)
			port <= `EMPTY;
		else if (router_add[1:0] != dst[1:0])
			port <= `OUT_X1_PORT;
		else if (router_add[2] != dst[2])
			port <= `OUT_Y1_PORT;
		else 
			port <= `OUT_LOCAL_PORT;
	end
end

endmodule
