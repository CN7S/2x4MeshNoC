`include "global.v"
module ram_8x32
(
	input								rst_n	,
	// write port
	input								wr_clk	,
	input								wr_en	,
	input	[`ADDR_WIDTH-1:0]			wr_addr	,
	input	[`DATA_WIDTH-1:0]			wr_data	,
	// read port
	input								rd_clk	,
	input								rd_en	,
	input	[`ADDR_WIDTH-1:0]			rd_addr	,
	output	reg [`DATA_WIDTH-1:0]		rd_data	
	
);


integer i;


// Block Ram Definition
reg [`DATA_WIDTH-1:0]	dual_port_ram	[0:`RAM_SIZE-1];

// write and reset
always@(posedge wr_clk or negedge rst_n) begin
	if(!rst_n)
		for(i = 0; i < `RAM_SIZE; i=i+1)
			dual_port_ram[i] <= {(`DATA_WIDTH){1'b0}};
	else if(wr_en)	
		dual_port_ram[wr_addr] <= wr_data;
end

// read
always@(posedge rd_clk or negedge rst_n) begin
	if(!rst_n)
		rd_data <= {(`DATA_WIDTH){1'b0}};
	else if(rd_en)
		rd_data <= dual_port_ram[rd_addr];
	else 
		rd_data <= {(`DATA_WIDTH){1'b0}};
end

endmodule