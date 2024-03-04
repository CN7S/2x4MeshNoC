`include "global.v"

module router_tb();

reg clk;
reg rst_n;
reg en;

reg [2:0] router_add;
reg [2:0] dst;

wire[2:0] port;

integer i,j;

router_sta ROUTER_STA(
.clk(clk),
.rst_n(rst_n),
.en(en),
.router_add(router_add),
.dst(dst),
.port(port)
);

initial
begin
	clk <= 1;
	rst_n <= 0;
	en <= 0;
	router_add <= 3'b000;
	dst <= 3'b000;

	//$monitor($realtime,,"router_add=%b,dst=%b,port=%b",router_add,dst,port);

	#20
	rst_n <= 1;

	#20
	en <=1;

	#20
	
	for (i=0; i<8; i=i+1)
	begin
		for (j=0; j<8; j=j+1)
		begin
      			#20 dst<=dst+1;
		end
		router_add <= router_add+1;
	end
	$finish;
end

always#5 clk = !clk;

always#10 $display($realtime,,"router_add=%b,dst=%b,port=%b",router_add,dst,port);

endmodule
