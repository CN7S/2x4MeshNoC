// +FHDR-----------------------------------------------------------------------
// Copyright.
 // ----------------------------------------------------------------------------
// FILE NAME      : input_unit.v
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

module input_unit
(
	input clk,
	input rst_n,
	input enable,
	input data_valid_in,
	input [`DATA_WIDTH-1:0] data_in,
	
	output almost_full,
	output full,
	output almost_empty,
	output empty,
	
	output reg [`DATA_WIDTH-1:0] data_out,
	output reg data_valid
);

wire [`DATA_WIDTH-1:0] fifo_rd_data;


reg hold;
reg fifo_rd_data_valid;
reg [`DATA_WIDTH:0] FIFO_data_buffer;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fifo_rd_data_valid <= 1'b0;
	end
	else begin
		if(enable && !empty) fifo_rd_data_valid <= 1'b1;
		else fifo_rd_data_valid <= 1'b0;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		hold <= 1;
	end
	else begin
		hold <= enable;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		FIFO_data_buffer <= 0;
	end
	else if(hold) begin
		FIFO_data_buffer <= {fifo_rd_data_valid, fifo_rd_data};
	end
end

// data_out
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		{data_valid, data_out} <= 0;
	end
	else if(enable) begin
		if(!hold) begin
			{data_valid, data_out} <= FIFO_data_buffer;
		end
		else begin
			{data_valid, data_out} <= {fifo_rd_data_valid, fifo_rd_data};
		end
	end
end // data_out

sync_fifo_8x32 unit_fifo_local(
	.clk(clk),
	.rst_n(rst_n),
	.wr_en(data_valid_in),
	.wr_data(data_in),
	.almost_full(almost_full),
	.full(full),
	
	.rd_en(enable),
	.rd_data(fifo_rd_data),
	.almost_empty(almost_empty),
	.empty(empty)
);


endmodule