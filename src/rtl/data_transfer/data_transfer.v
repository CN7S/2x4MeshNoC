`include "global.v"


module data_transfer
(
	input clk,
	input rst_n,
	input enable,
	input [`DATA_WIDTH-1:0] data_in,
	output reg [`DATA_WIDTH-1:0] data_out
);

reg [`DATA_WIDTH-1:0] buffer;


// buffer
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) 
	begin
		buffer <= 0;
	end
	else 
	begin
		if(enable) 	buffer <= data_in;
		else 		buffer <= buffer;
	end
end // buffer

// data_out
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) 
	begin
		data_out <= 0;
	end
	else 
	begin
		if(enable) 	data_out <= buffer;
		else 		data_out <= data_out;
	end
end // data_out


endmodule