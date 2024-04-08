// +FHDR-----------------------------------------------------------------------
// Copyright.
 // ----------------------------------------------------------------------------
// FILE NAME       : data_transfer.v
 // DEPARTMENT     : 
 // AUTHOR         : 
 // AUTHOR’S EMAIL : 
 // ----------------------------------------------------------------------------
// RELEASE HISTORY
 // VERSION DATE        AUTHOR  DESCRIPTION
 // 1.0  2024/03/13    
// ----------------------------------------------------------------------------
// KEYWORDS    : Data
 // ----------------------------------------------------------------------------
// PURPOSE     : A delay unit for Data from IN UNIT to OUT UNIT
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