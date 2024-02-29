module router_border(
	input				clk		;
	input 				rst_n	;
	
	input [`DATA_WIDTH-1:0]		LOCAL_DATA_IN		;
	input						LOCAL_DATA_VALID_IN	;
	
	output	[`DATA_WIDTH-1:0]	LOCAL_DATA_OUT		;
	output						LOCAL_DATA_VALID_OUT;
	output						LOCAL_FULL_OUT		;
	
	input [`DATA_WIDTH-1:0]		X_DATA_IN		;
	input						X_DATA_VALID_IN	;
	input						X_FULL_IN		;
	
	output	[`DATA_WIDTH-1:0]	X_DATA_OUT		;
	output						X_DATA_VALID_OUT;
	output						X_FULL_OUT		;

	input [`DATA_WIDTH-1:0]		Y_DATA_IN		;
	input						Y_DATA_VALID_IN	;
	input						Y_FULL_IN		;
	
	output	[`DATA_WIDTH-1:0]	Y_DATA_OUT		;
	output						Y_DATA_VALID_OUT;
	output						Y_FULL_OUT		;
);


endmodule


module router_normal(
	input				clk		;
	input 				rst_n	;
	
	input [`DATA_WIDTH-1:0]		LOCAL_DATA_IN		;
	input						LOCAL_DATA_VALID_IN	;
	
	output	[`DATA_WIDTH-1:0]	LOCAL_DATA_OUT		;
	output						LOCAL_DATA_VALID_OUT;
	output						LOCAL_FULL_OUT		;
	
	input [`DATA_WIDTH-1:0]		X1_DATA_IN		;
	input						X1_DATA_VALID_IN	;
	input						X1_FULL_IN		;
	
	output	[`DATA_WIDTH-1:0]	X1_DATA_OUT		;
	output						X1_DATA_VALID_OUT;
	output						X1_FULL_OUT		;

	input [`DATA_WIDTH-1:0]		X2_DATA_IN		;
	input						X2_DATA_VALID_IN	;
	input						X2_FULL_IN		;
	
	output	[`DATA_WIDTH-1:0]	X2_DATA_OUT		;
	output						X2_DATA_VALID_OUT;
	output						X2_FULL_OUT		;


	input [`DATA_WIDTH-1:0]		Y_DATA_IN		;
	input						Y_DATA_VALID_IN	;
	input						Y_FULL_IN		;
	
	output	[`DATA_WIDTH-1:0]	Y_DATA_OUT		;
	output						Y_DATA_VALID_OUT;
	output						Y_FULL_OUT		;

);

endmodule