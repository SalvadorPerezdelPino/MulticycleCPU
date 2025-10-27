// Camino de datos de la CPU
module datapath #(
	parameter DATA_WIDTH = 16,
	parameter ADDR_WIDTH = 8) (
	input wire clk, 
	input wire reset, 
	// Control del camino de datos
	input wire s_io_wr, s_addr,
	input wire [1:0] s_wd3, s_pc,
	input wire we3, we_pc, we_alu, we_reg, we_rmem, we_wd3,
	// Control de la pila
	input wire push, pop,
	// ALU
	input wire [2:0] op_alu, 
	output wire z, s,
	output wire [5:0] opcode, 
	output wire [9:0] dir,
	// I/O
	input wire read, 
	input wire write, 	
	inout wire [DATA_WIDTH-1:0] bus_data, 
	output wire [ADDR_WIDTH-1:0] bus_addr);
	
	wire [31:0] inst;
	wire [3:0] ra1, ra2, wa3;
	wire [9:0] jmp_pc, jmp_pc_latch, inc_pc, inc_pc_latch, next_pc, ret_dir/*, next_pc_latch*/;
	wire [DATA_WIDTH-1:0] inm, alu_res, rd1, rd2, wd3, alu_inm, data_to_io, data_from_io;
	wire [7:0] inm_to_mem; // No aumenta por diseño
	wire z_alu, s_alu;
	wire [DATA_WIDTH-1:0] /*alu_latch,*/ rd1_latch, rd2_latch, inm_latch, wd3_latch/*, data_from_io_latch*/;
	wire [ADDR_WIDTH-1:0] inst_addr;
	
	assign jmp_pc = inst[9:0];
	assign ra1 = inst[11:8];
	assign ra2 = inst[7:4];
	assign wa3 = inst[3:0];
	assign inm = inst[19:4];
	assign inm_to_mem = inst[7:0];
	assign opcode = inst[31:26];
	
	registro #(10) reg_jump_pc (
		.clk	 (clk), 
		.reset (reset), 
		.enable(we_reg),
		.d		 (jmp_pc),
		.q		 (jmp_pc_latch)
	);
	
	// Mux que selecciona la próxima dirección del program counter
	mux4 #(10) mux_next_pc (
		.d0	(inc_pc_latch),
		.d1	(jmp_pc_latch),
		.d2	(ret_dir),
		.d3	(),
		.s		(s_pc),
		.y		(next_pc)
	);
	
	// Mux que selecciona el valor a almacenar en el banco de registros
	mux4 #(DATA_WIDTH) mux_reg (
		.d0	(alu_res),
		.d1	(inm_latch),
		.d2	(data_from_io),
		.d3	(),
		.s		(s_wd3),
		.y		(wd3)
	
	);
	
	// Mux que selecciona si el dato a escribir en un dispositivo externo viene de un registro o un inmediato
	mux2 #(DATA_WIDTH) mux_to_mem (
		.d0 (rd2_latch),
		.d1 ({8'b0, inm_to_mem}),
		.s (s_io_wr),
		.y (data_to_io)
	);
	
	mux2 #(ADDR_WIDTH) mux_addr (
		.d0 ({{ADDR_WIDTH-DATA_WIDTH{1'b0}}, rd1_latch}), // Rellena con 0
		.d1 (inst_addr),
		.s  (s_addr),
		.y  (bus_addr)
	);
	
	registro #(ADDR_WIDTH) reg_addr (
		.clk	 (clk), 
		.reset (reset), 
		.enable(we_reg),
		.d		 (inst[27:8]),
		.q		 (inst_addr)
	);
	
	// Program counter 
	registro #(10) pc (
		.clk	 (clk), 
		.reset (reset), 
		.enable(we_pc),
		.d		 (next_pc), 
		.q		 (dir)
	);
	
	// Incrementa el program counter para la siguiente instrucción
	sum sum_pc (
		.a	(10'b0000000001), 
		.b	(dir), 
		.y	(inc_pc)
	);
	
	registro #(10) reg_inc_pc (
		.clk	 (clk), 
		.reset (reset), 
		.enable(we_reg),
		.d		 (inc_pc),
		.q		 (inc_pc_latch)
	);
	
	// Memoria que contiene el programa
	localparam PROGFILE = "C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/CPU/Multicycle/program.mem";
	program_memory pm1 (
		.clk (clk), 
		.addr   (dir), 
		.inst  (inst)
	);
	
	registro #(DATA_WIDTH) reg_inm (
		.clk	(clk),
		.reset(reset),
		.enable(we_reg),
		.d(inm),
		.q(inm_latch)
	);
	
	// Banco de registros
	regfile #(DATA_WIDTH) banco_reg	(
		.clk (clk), 
		.we3 (we3), 
		.ra1 (ra1), 
		.ra2 (ra2), 
		.wa3 (wa3), 
		.wd3 (wd3_latch), 
		.rd1 (rd1), 
		.rd2 (rd2)
	); 
	
	
	registro #(DATA_WIDTH) reg_rd2 (
		.clk	(clk),
		.reset(reset),
		.enable(we_reg),
		.d		(rd2),
		.q		(rd2_latch)
	);
	
	registro #(DATA_WIDTH) reg_rd1 (
		.clk	(clk),
		.reset(reset),
		.enable(we_reg),
		.d		(rd1),
		.q		(rd1_latch)
	);
	

	// ALU para operaciones
	alu alu1 (
		.a      (rd1_latch), 
		.b      (rd2_latch), 
		.op_alu (op_alu), 
		.y      (alu_res), 
		.zero   (z_alu),
		.sign   (s_alu)
	);
	
	// Registro intermedio para almacenar el resultado de la ALU durante la fase EX
	registro #(DATA_WIDTH) reg_wd3 (
		.clk	(clk),
		.reset(reset),
		.enable(we_wd3),
		.d			(wd3),
		.q			(wd3_latch)
	);
				 
	// Flag de cero en las operaciones ALU
	ffd ffz (
		.clk	 (clk), 
		.reset (reset), 
		.d		 (z_alu), 
		.carga (we_alu), 
		.q		 (z)
	);
	
	// Flag de signo en las operaciones ALU
	ffd ffs (
		.clk	 (clk), 
		.reset (reset), 
		.d		 (s_alu), 
		.carga (we_alu), 
		.q		 (s)
	);
	
	// Driver de acceso al bus de datos y direcciones
	cd_io cd_io0 (
		.bus_data		(bus_data),
		.data_from_cpu	(data_to_io),
		.data_to_cpu	(data_from_io),
		.write			(write),
		.read			   (read)
	);
	
	// Pila de direcciones para subrutinas
	stack stack0 (
		.push			(push),
		.pop			(pop),
		.clk			(clk),
		.in_data		(inc_pc),
		.out_data	(ret_dir)
	);
		
endmodule
