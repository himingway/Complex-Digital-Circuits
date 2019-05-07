
`timescale 1ns/1ps

module tb_logarithm (); /* this is automatically generated */

	logic rstb;
	logic srst;
	logic clk;

	// clock
	initial begin
		clk = '0;
		forever #(0.5) clk = ~clk;
	end

	// reset
	initial begin
		x = 9'b110110001;
		start = 1'd1;
		reset = 1'd0;
		#100
		reset = 1'd1;
		#100
		start = 1'd0;
		#100
		start = 1'd1;
		#100
		start = 1'd0;
		#500
		start = 1'd1;
	end

	// (*NOTE*) replace reset, clock, others

	parameter n = 8;
	parameter m = 16;
	parameter k = 5;
	parameter p = 16;

	logic       reset;
	logic       start;
	logic [0:n] x;
	logic [1:p] y;
	logic       done;

	logarithm #(
			.n(n),
			.m(m),
			.k(k),
			.p(p)
		) inst_logarithm (
			.clk   (clk),
			.reset (reset),
			.start (start),
			.x     (x),
			.y     (y),
			.done  (done)
		);

	initial begin
		// do something
		repeat(1200)@(posedge clk);
		$finish;
	end

	// dump wave
	initial begin
		$dumpfile("logarithm.vcd");
		$dumpvars(0, tb_logarithm);
	end

endmodule
