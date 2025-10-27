module program_memory (
	input wire clk, 
	input wire [9:0] addr, 
	output wire [31:0] inst
);

	reg [31:0] mem [0:63];

	initial
	begin
		$readmemb("C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/CPU/Multicycle/mem/program.mem", mem);
	end

	assign inst = mem[addr];

endmodule

