// +FHDR-----------------------------------------------------------------------
// Copyright.
// ----------------------------------------------------------------------------
 // FILE NAME      : router_sta_sport.v
 // DEPARTMENT     :
 // AUTHOR         : Yi Wan
 // AUTHOR’S EMAIL : wanyi2003@sjtu.edu.cn
// ----------------------------------------------------------------------------
// RELEASE HISTORY
 // VERSION DATE        AUTHOR  DESCRIPTION
 // 1.1  2024-03-21  Yi Wan     
// ----------------------------------------------------------------------------
// KEYWORDS    : 4-port static routing
 // ----------------------------------------------------------------------------
// PURPOSE     : Determine output port for a 4-port router.
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

`include"global.v"

module router_compute_4port
(
	input 					clk,
	input 					rst_n,
	input 					en,
	input					valid,
	
	input			[31:0]	data,
	input			[2:0]	router_add,	//address of router
	
	input 			[2:0] 	stress_x1,	//stress of x1_port
	input 			[2:0] 	stress_x2,	//stress of x2_port
	input 			[2:0] 	stress_y,	//stress of y_port

  	output	reg 	[2:0]	port
);

//port
always@(posedge clk or negedge rst_n) 
begin
	if (!rst_n) 
		port <= `EMPTY; 
	else if (en)
	begin
		if(!valid)
			port <= `EMPTY; 
		else 
			if (router_add[2:0] == data[2:0])
				port <= `OUT_LOCAL_PORT;
			else 
				if (router_add[1:0] == data[1:0])
					port <= `OUT_Y1_PORT;
				else
					if (router_add[2] == data[2])
						if (router_add[1:0] < data[1:0])
							port <= `OUT_X2_PORT;
						else 
							port <= `OUT_X1_PORT;
					else 
						if (router_add[1:0] < data[1:0])
							if (stress_x2 < stress_y)
								port <= `OUT_X2_PORT;
							else port <= `OUT_Y1_PORT;
						else 
							if ( stress_x1 < stress_y )
								port <= `OUT_X1_PORT;
							else 
								port <= `OUT_Y1_PORT;
	end
end//port

endmodule
