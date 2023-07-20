module processor (input clk, rst, output [15:0] output_pins);

wire [15:0] pc;
wire [15:0] pc_inc;
wire [15:0] pc_next;
wire [15:0] instruction;

assign pc_inc = pc + 1;
assign pc_out = pc;

//Instruction Memory 
instruction_memory imem 
	(pc, 
	 instruction);

wire [3:0] opcode;
wire [2:0] reg_read_addr1, reg_read_addr2, reg_write_addr3;
wire [1:0] cz;
wire [15:0] immediate;

//Instruction Decoder
instuction_decoder idec
	(instruction,
	 opcode,
	 reg_read_addr1, 
	 reg_read_addr2,
	 reg_write_addr3, 
	 cz,
	 immediate);  

wire [1:0] choose_wb_data;
wire pc_en, reg_write_en, c_write_en, z_write_en, alu_choose, loadz_choose;
wire mem_write, mem_read, branch_beq, jump_jal, jump_jlr, jump_jri;

//Controller
controller cnt 
	(opcode, 
	 choose_wb_data,
	 pc_en, 
	 reg_write_en, 
	 c_write_en,
	 z_write_en,
	 loadz_choose,
	 alu_choose, 
	 mem_write, 
	 mem_read, 
	 branch_beq, 
	 jump_jal,
	 jump_jlr,
	 jump_jri);

wire cout, zout, zout2, cin, zin;
wire [15:0] reg_read_data1, reg_read_data2;
reg [15:0] reg_write_data;

//Register File
register_file rf  
	(clk, 
	 rst,
	 pc_en, 
	 pc_next,  
	 reg_write_en,
	 c_write_en,
	 z_write_en,
	 cout,
	 zout2,	 
	 reg_write_addr3,  
	 reg_write_data,    
	 reg_read_addr1,    
	 reg_read_addr2, 
	 reg_read_data1,  
	 reg_read_data2,
	 cin, 
	 zin,
	 pc);

wire [15:0] alu_operand1, alu_operand2;
wire [15:0] alu_result;


assign alu_operand1 = alu_choose ? reg_read_data1 : immediate;
assign alu_operand2 = reg_read_data2;
assign zout2 = loadz_choose ? ~(|reg_wr_data) : zout;

//ALU
arithmetic_logic_unit alu 
	(alu_operand1, 
	 alu_operand2,
	 opcode,
	 cz,
	 cin, 
	 zin,
	 clk, 
	 rst,
	 alu_result,
	 cout, 
	 zout);

wire [15:0] mem_access_addr, mem_write_data, mem_read_data;

assign mem_access_addr = (mem_write | mem_read) ? alu_result : 16'dz;
assign mem_write_data = mem_write ? reg_read_data1 : 16'dz;

//Data Memory
data_memory dmem 
	(clk,  
	 mem_access_addr,  
	 mem_write_data,  
	 mem_write,  
	 mem_read,  
	 mem_read_data,
	 output_pins);  

always@(*)
begin
	case (choose_wb_data)
		2'b00 : reg_write_data = pc_inc;
		2'b01 : reg_write_data = mem_read_data;
		2'b10 : reg_write_data = {immediate, 7'd0};
		2'b11 : reg_write_data = alu_result;
		default : reg_write_data = 16'dz;
	endcase
end

reg [15:0] jump_result;
wire [15:0] pc_plus_imm;

assign pc_plus_imm = pc + immediate;

always@(*)
begin
	if (jump_jri | jump_jlr)
		jump_result = alu_result;
	else if (jump_jal)
		jump_result = pc_plus_imm;
	else if (branch_beq)
		jump_result = zout ? pc_plus_imm : pc_inc;
	else
		jump_result = 16'dz;
end

assign pc_next = (jump_jri | jump_jlr | jump_jal | branch_beq) ? jump_result : pc_inc;

endmodule
