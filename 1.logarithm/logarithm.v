module logarithm #(
	parameter n = 8 ,
	parameter m = 16,
	parameter k = 5 ,
	parameter p = 16
) (
	input        clk  , // Clock
	input        reset, // Asynchronous reset active low
	input        start,
	input  [0:n] x    ,
	output [1:p] y    ,
	output       done
);

	reg [2:0] current_state;
	reg [2:0] next_state   ;
	reg       z_gt2        ;
	reg       i_positive   ;
	reg [2:0] sel_z        ;
	reg       load_z       ;
	reg       sel_i        ;
	reg       load_i       ;
	reg       shift_y      ;
	reg       done         ;

	reg  [  m+1:0] z           ;
	wire [  m+1:0] trunc_square;
	wire [  m+1:0] trunc_div   ;
	wire [  m+1:0] z_input     ;
	reg  [  k-1:0] i           ;
	wire [  k-1:0] i_input     ;
	wire [  k-1:0] i_minus_1   ;
	reg  [    1:p] yy          ;
	wire [    m:0] mult_in     ;
	wire [2*m+1:0] mult_out    ;

	assign z_input = (sel_z == 2'd00) ?  {1'b0, x, {(m-n){1'd0}}} :
	(sel_z == 2'd01) ? 	trunc_square :
	trunc_div;
	assign mult_in     = z[m:0];
	assign mult_out     = mult_in * mult_in;
	assign trunc_square = mult_out[2*m+1:m];
	assign trunc_div    = {1'd0, z[m+1:1]};

	always @(posedge clk or negedge reset) begin : proc_z
		if(~reset) begin
			z <= 0;
		end else begin
			if (load_z == 1'b1)
				z <= z_input;
		end
	end

	assign i_input = sel_i ? i_minus_1 : p;
	assign i_minus_1 = i - 1;
	wire [15:0] binary_p = p;

	always @(posedge clk or negedge reset) begin : proc_i
		if(~reset) begin
			i <= 0;
		end else begin
			if (load_i == 1'b1)
				i <= i_input;
		end
	end

	always @(posedge clk or negedge reset) begin : proc_yy
		if(~reset) begin
			yy <= 0;
		end else begin
			if (shift_y == 1'b1)
				yy <= {yy[2:p], z[m+1]};
		end
	end

	always @(posedge clk or negedge reset) begin : proc_current_state
		if(~reset) begin
			current_state <= 0;
		end else begin
			current_state <= next_state;
		end
	end

	assign i_positive = i ? 1 : 0;
	assign z_gt2 = z[m+1];
	assign y = yy;

	always @(*) begin
		next_state = current_state;
		case (current_state)
			3'd0 : begin
				if (~start)
					next_state = 3'd1;
			end
			3'd1 : begin
				if (start)
					next_state = 3'd2;
			end
			3'd2 : begin
				next_state = 3'd3;
			end
			3'd3 : begin
				next_state = 3'd4;
			end
			3'd4 : begin
				if (z_gt2)
					next_state = 3'd5;
				else
					next_state = 3'd6;
			end
			3'd5 : begin
				next_state = 3'd6;
			end
			3'd6 : begin
				if (i_positive)
					next_state = 3'd3;
				else
					next_state = 3'd0;
			end
			default : next_state = 3'd0;
		endcase
	end

	always @(*) begin
		case (current_state)
			3'd0, 3'd1: begin
				sel_z   = 2'b00;
				load_z  = 1'b0;
				sel_i   = 1'b0;
				load_i  = 1'b0;
				shift_y = 1'b0;
				done    = 1'b1;
			end
			3'd2 : begin
				sel_z   = 2'b00;
				load_z  = 1'b1;
				sel_i   = 1'b0;
				load_i  = 1'b1;
				shift_y = 1'b0;
				done    = 1'b0;
			end
			3'd3 : begin
				sel_z   = 2'b01;
				load_z  = 1'b1;
				sel_i   = 1'b1;
				load_i  = 1'b1;
				shift_y = 1'b0;
				done    = 1'b0;
			end
			3'd4 : begin
				sel_z   = 2'b00;
				load_z  = 1'b0;
				sel_i   = 1'b0;
				load_i  = 1'b0;
				shift_y = 1'b1;
				done    = 1'b0;
			end
			3'd5 : begin
				sel_z   = 2'b10;
				load_z  = 1'b1;
				sel_i   = 1'b0;
				load_i  = 1'b0;
				shift_y = 1'b0;
				done    = 1'b0;
			end
			3'd6 : begin
				sel_z   = 2'b00;
				load_z  = 1'b0;
				sel_i   = 1'b0;
				load_i  = 1'b0;
				shift_y = 1'b0;
				done    = 1'b0;
			end
			default : begin
				sel_z   = 2'b00;
				load_z  = 1'b0;
				sel_i   = 1'b0;
				load_i  = 1'b0;
				shift_y = 1'b0;
				done    = 1'b0;
			end
		endcase
	end
endmodule