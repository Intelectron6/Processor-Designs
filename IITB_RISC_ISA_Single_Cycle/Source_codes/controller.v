module controller (input [3:0] opcode, 	
				   output reg [1:0] choose_wb_data,
				   output reg pc_en, 
				   output reg reg_write_en,
				   output reg c_write_en,
				   output reg z_write_en,
					output reg loadz_choose,
				   output reg alu_choose,
				   output reg mem_write,
				   output reg mem_read, 
				   output reg branch_beq,
				   output reg jump_jal,
				   output reg jump_jlr, 
				   output reg jump_jri);
	
	always@(*) begin
		case (opcode)
			4'b0000 : //ADI
			begin
				choose_wb_data = 2'b11; alu_choose = 0; branch_beq = 0; jump_jal = 0;
				jump_jri = 0; jump_jlr = 0; mem_write = 0; mem_read = 0; pc_en = 1; 
				reg_write_en = 1; c_write_en = 1; z_write_en = 1; loadz_choose = 0;
			end
			
			4'b0001 : //ADD
			begin
				choose_wb_data = 2'b11; alu_choose = 1; branch_beq = 0; jump_jal = 0;
				jump_jri = 0; jump_jlr = 0; mem_write = 0; mem_read = 0; pc_en = 1;
				reg_write_en = 1; c_write_en = 1; z_write_en = 1; loadz_choose = 0;
			end
			
			4'b0010 : //NAND
			begin
				choose_wb_data = 2'b11; alu_choose = 1; branch_beq = 0; jump_jal = 0;
				jump_jri = 0; jump_jlr = 0; mem_write = 0; mem_read = 0; pc_en = 1;
				reg_write_en = 1; c_write_en = 0; z_write_en = 1; loadz_choose = 0;
			end
			
			4'b0011 : //LHI
			begin
				choose_wb_data = 2'b10; alu_choose = 0; branch_beq = 0; jump_jal = 0;
				jump_jri = 0; jump_jlr = 0; mem_write = 0; mem_read = 0; pc_en = 1; 
				reg_write_en = 1; c_write_en = 0; z_write_en = 1; loadz_choose = 0;
			end
			
			4'b0100 : //LW
			begin
				choose_wb_data = 2'b01; alu_choose = 0; branch_beq = 0; jump_jal = 0;
				jump_jri = 0; jump_jlr = 0; mem_write = 0; mem_read = 1; pc_en = 1;
				reg_write_en = 1; c_write_en = 0; z_write_en = 1; loadz_choose = 1;				
			end
			
			4'b0101 : //SW
			begin
				choose_wb_data = 2'b00; alu_choose = 0; branch_beq = 0; jump_jal = 0;
				jump_jri = 0; jump_jlr = 0; mem_write = 1; mem_read = 0; pc_en = 1; 
				reg_write_en = 0; c_write_en = 0; z_write_en = 0; loadz_choose = 0;
			end
			
			4'b1000 : //BEQ
			begin
				choose_wb_data = 2'b00; alu_choose = 1; branch_beq = 1; jump_jal = 0;
				jump_jri = 0; jump_jlr = 0; mem_write = 0; mem_read = 0; pc_en = 1; 
				reg_write_en = 0; c_write_en = 0; z_write_en = 0; loadz_choose = 0;
			end
			
			4'b1001 : //JAL
			begin
				choose_wb_data = 2'b00; alu_choose = 1; branch_beq = 0; jump_jal = 1;
				jump_jri = 0; jump_jlr = 0; mem_write = 0; mem_read = 0; pc_en = 1; 
				reg_write_en = 1; c_write_en = 0; z_write_en = 0; loadz_choose = 0;
			end
			
			4'b1010 : //JLR
			begin
				choose_wb_data = 2'b00; alu_choose = 0; branch_beq = 0; jump_jal = 0;
				jump_jri = 0; jump_jlr = 1; mem_write = 0; mem_read = 0; pc_en = 1; 
				reg_write_en = 1; c_write_en = 0; z_write_en = 0; loadz_choose = 0;
			end
			
			4'b1011 : //JRI
			begin
				choose_wb_data = 2'b00; alu_choose = 0; branch_beq = 0; jump_jal = 0;
				jump_jri = 1; jump_jlr = 0; mem_write = 0; mem_read = 0; pc_en = 1; 
				reg_write_en = 0; c_write_en = 0; z_write_en = 0; loadz_choose = 0;			
			end
			
			default :
			begin 
				choose_wb_data = 2'b00; alu_choose = 0; branch_beq = 0; jump_jal = 0;
				jump_jri = 0; jump_jlr = 0; mem_write = 0; mem_read = 0; pc_en = 1; 
				reg_write_en = 0; c_write_en = 0; z_write_en = 0; loadz_choose = 0;
			end	
		endcase
	end
	
endmodule

