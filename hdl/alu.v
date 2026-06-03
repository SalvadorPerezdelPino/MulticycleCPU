module alu #(parameter DATA_WIDTH=16) (
	input wire [DATA_WIDTH-1:0] a, 
	input wire [DATA_WIDTH-1:0] b,
	input wire [2:0] op_alu, 
	output wire [DATA_WIDTH-1:0] y, 
	output wire zero, 
	output wire sign,
	output wire carry,
	output wire overflow
);
	
	reg [DATA_WIDTH-1:0] s;		   
				
	always @(a, b, op_alu)
	begin
	  case (op_alu)              
		 3'b000: s = a;
		 3'b001: s = ~a;
		 3'b010: s = a + b;
		 3'b011: s = a - b;
		 3'b100: s = a & b;
		 3'b101: s = a | b;
		 3'b110: s = -a;
		 3'b111: s = a*b;
		default: s = 16'bx; 
	  endcase
	end

	assign y = s;
	
	wire [DATA_WIDTH:0] sum_ext = {1'b0, a} + {1'b0, b};
    wire [DATA_WIDTH:0] sub_ext = {1'b0, a} - {1'b0, b};

	assign zero = ~(|y);
	assign sign = y[DATA_WIDTH-1];
	assign carry = (op_alu == 3'b010) ? sum_ext[DATA_WIDTH] : (op_alu == 3'b011) ? sub_ext[DATA_WIDTH] : 1'b0;
	assign overflow = (op_alu == 3'b010) ? ((a[DATA_WIDTH-1] == b[DATA_WIDTH-1]) && (y[DATA_WIDTH-1] != a[DATA_WIDTH-1])) : 
		(op_alu == 3'b011) ? ((a[DATA_WIDTH-1] != b[DATA_WIDTH-1]) && (y[DATA_WIDTH-1] != a[DATA_WIDTH-1])) : 1'b0;


endmodule
