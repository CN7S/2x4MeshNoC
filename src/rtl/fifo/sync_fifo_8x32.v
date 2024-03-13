`include "global.v"
module sync_fifo_8x32
(
	input							clk	,
	input							rst_n	,
	
	// fifo write
	input							wr_en	,
	input	[`DATA_WIDTH-1:0]		wr_data	,
	output	reg						almost_full,
	output 	reg						full	,
	// fifo read
	input							rd_en	,
	output	[`DATA_WIDTH-1:0]		rd_data	,
	output	reg						almost_empty,
	output 	reg						empty	
);


wire	[`ADDR_WIDTH-1:0]	wr_addr	;
wire	[`ADDR_WIDTH-1:0]	rd_addr	;
wire	wen, ren;

reg [`ADDR_WIDTH:0] wr_gap	;
reg	[`ADDR_WIDTH:0]	rd_gap	; 
reg [`ADDR_WIDTH:0]	waddr	;
reg [`ADDR_WIDTH:0]	raddr	;



// Write Control Logic

// ram write enable generated
assign wen = wr_en & (!full);

// fifo write address generated
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		waddr <= {(`ADDR_WIDTH+1){1'b0}};
	else if(wen)
		waddr <= waddr + 1'b1;
end

assign wr_addr = waddr[`ADDR_WIDTH-1:0];

// write gap generated

always@(*) begin
	if(waddr[`ADDR_WIDTH]^raddr[`ADDR_WIDTH])
		wr_gap = raddr[`ADDR_WIDTH-1:0] - waddr[`ADDR_WIDTH-1:0];
	else
		wr_gap = `FIFO_DEEP - waddr + raddr;
end

// full signal
always@(*) begin
	if(wr_gap) 			full = 1'b0;
	else 				full = 1'b1;
end

always@(*) begin
	if(wr_gap < `ALMOST_FULL_GAP) 			almost_full = 1'b1;
	else 									almost_full = 1'b0;
end

// Read Control Logic

// ram read enable generated
assign ren = rd_en & (!empty);

// fifo read address generated
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		raddr <= {(`ADDR_WIDTH+1){1'b0}}; // reset read address
	else if(ren)
		raddr <= raddr + 1'b1; // read address count + 1
end

assign rd_addr = raddr[`ADDR_WIDTH-1:0]; // get ram read address

// read gap generated

always@(*) begin
	rd_gap = waddr - raddr;
end

// empty signal
always@(*) begin
	if(rd_gap) 		empty = 1'b0;
	else 			empty = 1'b1;
end

always@(*) begin
	if(rd_gap < `ALMOST_EMPTY_GAP) 		almost_empty = 1'b1;
	else 								almost_empty = 1'b0;
end


ram_8x32 fifo_ram
(
	.clk(clk),
	.rst_n(rst_n),
	
	.wr_en(wen),
	.wr_addr(wr_addr),
	.wr_data(wr_data),

	.rd_en(ren),
	.rd_addr(rd_addr),
	.rd_data(rd_data)
);

endmodule
