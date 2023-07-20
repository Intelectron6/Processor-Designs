module instruction_decoder (input [15:0] instruction, 
						    output [3:0] opcode,
						    output reg [2:0] reg_addr1,
						    output reg [2:0] reg_addr2,
						    output reg [2:0] reg_addr3,
						    output reg [1:0] cz,
						    output reg [15:0] immediate);
							
	assign opcode = instruction [15:12];
	
	always@(*) begin
	case (opcode)
	
		// For R-Type instruction: ADD, ADC, ADZ, ADL, NDU, NDC, NDZ (7)
		4'b0001, 4'b0010: 
			begin
				reg_addr3 = instruction [11:9];
				reg_addr2 = instruction [8:6];
				reg_addr1 = instruction [5:3];
				cz = instruction [1:0];
				immediate = 16'h0000;
			end
		
		// For I-type instruction : ADI (1)
		4'b0000 :	
			begin
				reg_addr1 = 3'b000;
				reg_addr2 = instruction [8:6];
				reg_addr3 = instruction [11:9];
				cz = 2'b00;
				immediate = {{10{instruction [5]}},instruction [5:0]};
			end
	
		// For I-type instruction : LW (1)	
		4'b0100 :
			begin
				reg_addr1 = 3'b000;
				reg_addr2 = instruction [8:6];
				reg_addr3 = instruction [11:9];
				cz = 2'b00;
				immediate = {{10{instruction[5]}},instruction [5:0]};
			end

		// For I-type instructions : SW, BEQ (2)
		4'b0101, 4'b1000:	
			begin
				reg_addr1 = instruction [11:9];
				reg_addr2 = instruction [8:6];
				reg_addr3 = 3'b000;
				cz = 2'b00;
				immediate = {{10{instruction[5]}},instruction [5:0]};
			end
			
		//For I-type instructions : JLR (1)	
		4'b1010: 
			begin
				reg_addr1 = 3'b000;
				reg_addr2 = instruction [8:6];
				reg_addr3 = instruction [11:9];
				cz = 2'b00;
				immediate = {{10{instruction[5]}},instruction [5:0]};
			end
			
		// For J-type instruction : LHI (1)	
		4'b0011: 
			begin
				reg_addr1 = 3'b000;
				reg_addr2 = 3'b000;
				reg_addr3 = instruction [11:9];
				cz = 2'b00;
				immediate = {instruction [8:0], 7'b00000000};
			end
				
		// For J-type instruction : JAL (1)
		4'b1001:  
			begin
				reg_addr1 = 3'b000;
				reg_addr2 = 3'b000;
				reg_addr3 = instruction [11:9];
				cz = 2'b00;
				immediate = {{7{instruction[5]}},instruction [8:0]};
			end
		
		// For J-type instructions : JRI (1)
		4'b1011:  
			begin
				reg_addr1 = 3'b000;
				reg_addr2 = instruction [11:9];
				reg_addr3 = 3'b000;
				cz = 2'b00;
				immediate = {{7{instruction[5]}},instruction [8:0]};
			end
			
		default: 
			begin
				reg_addr1 = 3'b000;
				reg_addr2 = 3'b000;
				reg_addr3 = 3'b000;
				cz = 2'b00;
				immediate = 16'b0000;
			end		
	endcase
	end
endmodule
