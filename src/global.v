`timescale 1ns/100ps
`define ADDR_WIDTH 	 			3	
`define DATA_WIDTH 	 			32	
`define RAM_SIZE		 		8	
`define ALMOST_FULL_GAP 		3	
`define ALMOST_EMPTY_GAP 		3	
`define FIFO_DEEP 				8	

`define EMPTY					(3'b000)
`define OUT_LOCAL_PORT			(3'b001)
`define OUT_X1_PORT				(3'b010)
`define OUT_X2_PORT				(3'b011)
`define OUT_Y1_PORT				(3'b100)
`define OUT_Y2_PORT				(3'b101)


`define SW_LOCAL			(3'b000)
`define SW_X1				(3'b001)
`define SW_X2				(3'b010)
`define SW_Y1				(3'b011)
`define SW_Y2				(3'b100)
`define SW_STOP				(3'b101)		

/*
parameter ADDR_WIDTH 	= 3		;
parameter DATA_WIDTH 	= 32	;
parameter RAM_SIZE		= 8		;
parameter ALMOST_FULL_GAP = 3;
parameter ALMOST_EMPTY_GAP = 3;
parameter FIFO_DEEP = 8;

*/