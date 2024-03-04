`include "global.v"

module router_sta
(
	input 			clk,
	input 			rst_n,
	input 			en,


	input		[2:0]	router_add,
	input		[2:0]	dst,

  	output	reg 	[2:0]	port
);

always@(posedge clk or negedge rst_n) 
begin
	if (!rst_n) 
	begin
		port <= 3'b000;
	end 

	else if (en)
	begin
		if (router_add[1:0] != dst[1:0])
		begin
			if (router_add[1:0] < dst[1:0])
			begin
				port <= `OUT_X2_PORT;
			end
			else 
			begin
				port <= `OUT_X1_PORT;
			end
		end

		else 
		begin
			if (router_add[2] == dst[2])
				port <= `OUT_LOCAL_PORT;
			else 
			begin
				if (router_add[2] < dst[2])
					port <= `OUT_Y2_PORT;
				else port <= `OUT_Y1_PORT;
			end
  		end
	end
end



endmodule
