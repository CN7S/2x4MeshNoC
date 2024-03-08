`include "global.v"

module router_sta_3port
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

//////////
module router_sta_4port
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
		begin
			if (router_add[1:0] < dst[1:0])
				port <= `OUT_X2_PORT;
			else 
				port <= `OUT_X1_PORT;
		end
		else 
		begin
			if (router_add[2] != dst[2])
				port <= `OUT_Y1_PORT;
			else 
				port <= `OUT_LOCAL_PORT;
  		end
	end
end

endmodule
