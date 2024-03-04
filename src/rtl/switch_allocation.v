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

	//input vaild
	output reg			port_x_valid,
	output reg			port_y_valid,
	output reg 			port_local_valid,

	// allocate outport switch
	output reg	[2:0]	out_x_sw		,
	output reg	[2:0]	out_y_sw		,
	output reg	[2:0]	out_local_sw	
);

reg priority_x;
reg priority_y;
reg priority_local;

reg [2:0] out_x_sw_temp;
reg [2:0] out_y_sw_temp;
reg [2:0] out_local_sw_temp;


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		priority_x 			<= 1'b1;
		priority_y 			<= 1'b0;
		priority_local		<= 1'b0;
	end
	else if(en) begin
		priority_x 			<= priority_local;
		priority_y			<= priority_x;
		priority_local		<= priority_y;
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
		if(port_x_dst != `EMPTY) port_x_valid <= 1;
		else					port_x_valid <= 0;
		if(port_y_dst != `EMPTY) port_y_valid <= 1;
		else					port_y_valid <= 0;
		if(port_local_dst != `EMPTY) port_local_valid <= 1;
		else					port_local_valid <= 0;
	end
end


// out_local_port
always@(*) begin
	if(priority_local) begin
		if(port_local_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else if(port_y_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else begin
			out_local_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x) begin
		if(port_x_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else if(port_y_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_local_sw_temp = `SW_STOP;
		end
	end
	else if(priority_y) begin
		if(port_y_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else  begin
			out_local_sw_temp = `SW_STOP;
		end
	end
end


// out_x_port
always@(*) begin
	if(priority_local) begin
		if(port_local_dst == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_X1;
		end
		else if(port_y_dst == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_Y1;
		end
		else begin
			out_x_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x) begin
		if(port_x_dst == `OUT_X1_PORT)  begin
			out_x_sw_temp = `SW_X1;
		end
		else if(port_y_dst == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_x_sw_temp = `SW_STOP;
		end
	end
	else if(priority_y) begin
		if(port_y_dst == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst == `OUT_X1_PORT) begin
			out_x_sw_temp = `SW_X1;
		end
		else  begin
			out_x_sw_temp = `SW_STOP;
		end
	end
end


// out_y_port
always@(*) begin
	if(priority_local) begin
		if(port_local_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else if(port_y_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else begin
			out_y_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x) begin
		if(port_x_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else if(port_y_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_y_sw_temp = `SW_STOP;
		end
	end
	else if(priority_y) begin
		if(port_y_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else if(port_x_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else  begin
			out_y_sw_temp = `SW_STOP;
		end
	end
end

endmodule



module switch_allocation_4port
(
	input				clk		,
	input				rst_n	,
	input				en		,
	
	// input_dst
	input	[2:0]		port_x1_dst		,
	input	[2:0]		port_y_dst		,
	input	[2:0]		port_x2_dst		,
	input	[2:0]		port_local_dst	,
	
	//input vaild
	output reg			port_x1_valid,
	output reg			port_x2_valid,
	output reg			port_y_valid,
	output reg 			port_local_valid,

	// allocate outport switch
	output reg	[2:0]	out_x1_sw		,
	output reg	[2:0]	out_y_sw		,
	output reg	[2:0]	out_x2_sw		,
	output reg	[2:0]	out_local_sw	
);


reg priority_x1;
reg priority_x2;
reg priority_y;
reg priority_local;

reg [2:0] out_x1_sw_temp;
reg [2:0] out_x2_sw_temp;
reg [2:0] out_y_sw_temp;
reg [2:0] out_local_sw_temp;


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		priority_x1 		<= 1'b1;
		priority_x2 		<= 1'b0;
		priority_y 			<= 1'b0;
		priority_local		<= 1'b0;
	end
	else if(en) begin
		priority_x1 		<= priority_local;
		priority_x2 		<= priority_x1;
		priority_y			<= priority_x2;
		priority_local		<= priority_y;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_x1_sw			<= `SW_STOP;
		out_x2_sw			<= `SW_STOP;
		out_y_sw			<= `SW_STOP;
		out_local_sw		<= `SW_STOP;
	end
	else if(en) begin
		out_x1_sw			<= out_x1_sw_temp;
		out_x2_sw			<= out_x2_sw_temp;
		out_y_sw			<= out_y_sw_temp;
		out_local_sw		<= out_local_sw_temp;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		port_x1_valid 		<= 0;
		port_x2_valid 		<= 0;
		port_y_valid 		<= 0;
		port_local_valid 	<= 0;
	end
	else begin
		if(port_x1_dst != `EMPTY) port_x1_valid <= 1;
		else					port_x1_valid <= 0;
		if(port_x2_dst != `EMPTY) port_x2_valid <= 1;
		else					port_x2_valid <= 0;
		if(port_y_dst != `EMPTY) port_y_valid <= 1;
		else					port_y_valid <= 0;
		if(port_local_dst != `EMPTY) port_local_valid <= 1;
		else					port_local_valid <= 0;
	end
end


// out_local_port
always@(*) begin
	if(priority_local) begin
		if(port_local_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else begin
			out_local_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x1) begin
		if(port_x1_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_local_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x2) begin
		if(port_x2_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else  begin
			out_local_sw_temp = `SW_STOP;
		end
	end
	else if(priority_y) begin
		if(port_y_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_LOCAL_PORT) begin
			out_local_sw_temp = `SW_X2;
		end
		else  begin
			out_local_sw_temp = `SW_STOP;
		end
	end
end


// out_x1_port
always@(*) begin
	if(priority_local) begin
		if(port_local_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_Y1;
		end
		else begin
			out_x1_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x1) begin
		if(port_x1_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_x1_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x2) begin
		if(port_x2_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_X1;
		end
		else  begin
			out_x1_sw_temp = `SW_STOP;
		end
	end
	else if(priority_y) begin
		if(port_y_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_X1_PORT) begin
			out_x1_sw_temp = `SW_X2;
		end
		else  begin
			out_x1_sw_temp = `SW_STOP;
		end
	end
end

// out_x2_port
always@(*) begin
	if(priority_local) begin
		if(port_local_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_Y1;
		end
		else begin
			out_x2_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x1) begin
		if(port_x1_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_x2_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x2) begin
		if(port_x2_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_X1;
		end
		else  begin
			out_x2_sw_temp = `SW_STOP;
		end
	end
	else if(priority_y) begin
		if(port_y_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_X2_PORT) begin
			out_x2_sw_temp = `SW_X2;
		end
		else  begin
			out_x2_sw_temp = `SW_STOP;
		end
	end
end

// out_y_port
always@(*) begin
	if(priority_local) begin
		if(port_local_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else begin
			out_y_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x1) begin
		if(port_x1_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else  begin
			out_y_sw_temp = `SW_STOP;
		end
	end
	else if(priority_x2) begin
		if(port_x2_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X2;
		end
		else if(port_y_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else  begin
			out_y_sw_temp = `SW_STOP;
		end
	end
	else if(priority_y) begin
		if(port_y_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_Y1;
		end
		else if(port_local_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_LOCAL;
		end
		else if(port_x1_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X1;
		end
		else if(port_x2_dst == `OUT_Y1_PORT) begin
			out_y_sw_temp = `SW_X2;
		end
		else  begin
			out_y_sw_temp = `SW_STOP;
		end
	end
end

endmodule