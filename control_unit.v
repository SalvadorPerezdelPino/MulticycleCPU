module control_unit (
	input wire [5:0] opcode, 
	input wire z, s,
	input wire clk,
	input wire reset,
	output reg s_addr, s_io_wr, we3, push, pop,
	output reg we_pc, we_alu, we_reg, we_rmem, we_wd3,
	output reg [1:0] s_wd3, s_pc,
	output reg [2:0] op_alu, 
	output reg read, 
	output reg write,
	output reg halted
);
	
	reg [3:0] state, nextstate;

	parameter IFRESET = 4'b0000;
	parameter IF = 4'b0001;
	parameter ID = 4'b0010;
	parameter EX = 4'b0011;
	parameter MEM = 4'b0100;
	parameter WB = 4'b0101;
	parameter JI = 4'b0110;
	parameter JC = 4'b0111;
	parameter RMEM = 4'b1000;
	parameter WMEM = 4'b1001;
	parameter HALTED = 4'b1010;
	
	parameter NOP = 6'b000000;
	parameter HALT = 6'b000001;
	parameter ALU = 6'b111???;
	parameter J = 6'b110000;
	parameter JPOS = 6'b110001;
	parameter JAL = 6'b11010?;
	parameter JR = 6'b11011?;
	parameter JZ = 6'b110011;
	parameter JNZ = 6'b110010;
	parameter LI = 6'b10100?;
	parameter LW_ADDR_R = 6'b1011??;
	parameter LW_R_R = 6'b101011;
	parameter SW_R_R = 6'b101010;
	parameter SW_ADDR_R = 6'b1000??;
	parameter STI = 6'b1001??;
	
	
	always @(posedge clk, posedge reset) begin
		if (reset)
			state <= IFRESET;
		else
			state <= nextstate;
	end
	
	// Funciones de transición
	always @(*) begin
		case (state)
			IFRESET: nextstate = ID;
			IF: nextstate = ID;
			ID: casez(opcode)
					ALU: nextstate = EX;
					J: nextstate = JI;
					JAL: nextstate = JI;
					JR: nextstate = JI;
					JZ: nextstate = JC;
					JNZ: nextstate = JC;
					JPOS: nextstate = JC;
					LI: nextstate = EX;
					LW_ADDR_R: nextstate = RMEM;
					LW_R_R: nextstate = RMEM;
					SW_R_R: nextstate = WMEM;
					SW_ADDR_R: nextstate = WMEM;
					STI: nextstate = WMEM;
					HALT: nextstate = HALTED;
					NOP: nextstate = IF;
					default: nextstate = IF;
				 endcase
			EX: nextstate = WB;
			WB: nextstate = IF;
			JI: nextstate = IF;
			JC: nextstate = IF;
			RMEM: nextstate = WB;
			WMEM: nextstate = IF;	
			HALTED: nextstate = HALTED;
		endcase
	end
	
	// Señales de control por etapa
	always @(*) begin
		casez(state)
			IFRESET: begin
				//we_next_pc <= 1'b0;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b0;
				halted <= 1'b0;
			end
			IF: begin
				// PC -> enable
				//we_next_pc <= 1'b0;
				we_pc <= 1'b1;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b0;
				halted <= 1'b0;
			end
			ID: begin
				// PC -> disable
				//we_next_pc <= 1'b0;
				we_pc <= 1'b0;
				we_reg <= 1'b1;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b0;
				halted <= 1'b0;
			end
			EX: begin
				// PC -> disable
				//we_next_pc <= 1'b0;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b1;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b1;
				halted <= 1'b0;
			end
			WB: begin
				// PC -> disable
				//we_next_pc <= 1'b1;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b1;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b0;
				halted <= 1'b0;
			end
			JI: begin
				//we_next_pc <= 1'b1;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b0;
				halted <= 1'b0;
			end
			JC: begin
				//we_next_pc <= 1'b1;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b0;
				halted <= 1'b0;
			end
			RMEM: begin
				//we_next_pc <= 1'b0;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b1;
				read <= 1'b1;
				write <= 1'b0;
				we_wd3 <= 1'b1;
				halted <= 1'b0;
			end
			WMEM: begin
				//we_next_pc <= 1'b0;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b1;
				we_wd3 <= 1'b0;
				halted <= 1'b0;
			end
			HALTED: begin
				//we_next_pc <= 1'b0;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b0;
				halted <= 1'b1;
			end
			default: begin
				//we_next_pc <= 1'b0;
				we_pc <= 1'b0;
				we_reg <= 1'b0;
				we_alu <= 1'b0;
				we3 <= 1'b0;
				we_rmem <= 1'b0;
				read <= 1'b0;
				write <= 1'b0;
				we_wd3 <= 1'b0;
				halted <= 1'b0;
			end
		endcase
		
	end

	// Señales de control por instrucción
	always @* begin
		casez(opcode)
			ALU: begin // ALU
				s_pc <= 2'b00;
				s_wd3 <= 2'b00;
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				//we3 <= 1'b1;
				//wez <= 1'b1;
				//wes <= 1'b1;
				op_alu <= opcode[2:0];
				push <= 1'b0;
				pop <= 1'b0;
				
			end
			J: begin // J
				s_pc <= 2'b01;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000;
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			JPOS: begin // JPOS
				s_pc <= (~z && ~s) ? 2'b01 : 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; //don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			JAL: begin // JAL
				s_pc <= 2'b01;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000;
				if (state == IF)
					push <= 1'b1;
				else
					push <= 1'b0;
				pop <= 1'b0;
			end
			
			JR: begin // JR
				s_pc <= 2'b10;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000;
				push <= 1'b0;
				if (state == IF)
					pop <= 1'b1;
				else
					pop <= 1'b0;
			end
			
			JZ: begin // JZ
				s_pc <= z ? 2'b01 : 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; //don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			JNZ: begin // JNZ
				s_pc <= z ? 2'b00 : 2'b01;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; // don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			LI: begin // LDI
				s_pc <= 2'b00;
				s_wd3 <= 2'b01; 
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				//we3 <= 1'b1;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; // don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			LW_ADDR_R: begin // LD -> carga lo que hay una dirección inmediata en un registro
				s_pc <= 2'b00;
				s_wd3 <= 2'b10; 
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b1;
				//we3 <= 1'b1;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; // don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			LW_R_R: begin // LD -> carga lo que hay una dirección DENTRO DE UN REGISTRO en otro registro
				s_pc <= 2'b00;
				s_wd3 <= 2'b10; 
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0;
				//we3 <= 1'b1;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; // don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			SW_R_R: begin // STR de registro a memoria en un registro
				s_pc <= 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0;
				s_addr <= 1'b0;
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; // don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			SW_ADDR_R: begin // STR
				s_pc <= 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0;
				s_addr <= 1'b1;
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; // don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			
			STI: begin // STI
				s_pc <= 2'b00;
				s_wd3 <= 2'b10; // don't care
				s_io_wr <= 1'b1;
				s_addr <= 1'b1;
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000; // don't care
				push <= 1'b0;
				pop <= 1'b0;
			end
			NOP: begin
				s_pc <= 2'b00;
				s_wd3 <= 2'b00; 
				s_io_wr <= 1'b0;
				s_addr <= 1'b0;
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000;
				push <= 1'b0;
				pop <= 1'b0;
			end
			default begin
				s_pc <= 2'b00;
				s_wd3 <= 2'b00; 
				s_io_wr <= 1'b0;
				s_addr <= 1'b0;
				//we3 <= 1'b0;
				//wez <= 1'b0;
				//wes <= 1'b0;
				op_alu <= 3'b000;
				push <= 1'b0;
				pop <= 1'b0;
			end
		endcase
	end

endmodule
