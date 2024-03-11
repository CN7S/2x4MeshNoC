`include "global.v"

module router_sta_3_tb();

reg clk;
reg rst_n;
reg en;
reg valid;

reg [2:0] router_add;
reg [2:0] dst;

wire[2:0] port;

integer i,j;

router_sta_3port ROUTER_STA_3(
.clk(clk),
.rst_n(rst_n),
.en(en),
.router_add(router_add),
.dst(dst),
.port(port)
);

initial
begin
	clk = 1;
	rst_n = 0;
	en = 0;
	valid = 0;
	router_add = 3'b000;
	dst = 3'b000;

	#20
	rst_n = 1;

	#20
	en = 1;
	
	#20 
	valid = 1;

	#20
	for ( i=0; i<8; i=i+1)
	begin
		for (j=0; j<8; j=j+1)
		begin
      			#20 dst = dst+1;
		end
		router_add = router_add+1;
	end
	$finish;
end

always#5 clk = !clk;

always#10 $display($realtime,,"router_add=%b,dst=%b,port=%b",router_add,dst,port);


endmodule


////////
module router_sta_4_tb();

reg clk;
reg rst_n;
reg en;
reg valid;

reg [2:0] router_add;
reg [2:0] dst;

wire[2:0] port;

integer i,j;

router_sta_4port ROUTER_STA_4(
.clk(clk),
.rst_n(rst_n),
.en(en),
.router_add(router_add),
.dst(dst),
.port(port)
);

initial
begin
	clk = 1;
	rst_n = 0;
	en = 0;
	valid = 0;
	router_add = 3'b000;
	dst = 3'b000;

	#20
	rst_n = 1;

	#20
	en = 1;
	
	#20 
	valid = 1;

	#20
	
	for (i=0; i<8; i=i+1)
	begin
		for (j=0; j<8; j=j+1)
		begin
      			#20 dst <= dst+1;
		end
		router_add <= router_add+1;
	end
$finish;
end

always#5 clk = !clk;

always#10 $display($realtime,,"router_add=%b,dst=%b,port=%b",router_add,dst,port);

endmodule
