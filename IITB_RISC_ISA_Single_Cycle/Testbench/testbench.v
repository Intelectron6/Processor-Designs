`timescale 10ns/1ns

module testbench;

reg clk, rst;
wire [15:0] pc;

processor scp (clk, rst, pc);

always
	#5 clk = ~clk;
	
initial
begin
	clk = 0;
	rst = 1;
	#10;
	rst = 0;
	#1000;
	$stop;
end

endmodule
