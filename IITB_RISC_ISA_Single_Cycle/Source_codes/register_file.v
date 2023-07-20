module register_file (input clk, 
						  input rst,
						  input pc_en, 
						  input [15:0] pc_new,  
						  input reg_write_en, 
						  input c_write_en,
						  input z_write_en,
						  input c_data,
						  input z_data,
						  input [2:0] reg_write_dest,  
						  input [15:0] reg_write_data,    
						  input [2:0] reg_read_addr_1,    
						  input [2:0] reg_read_addr_2, 
						  output [15:0] reg_read_data_1,  
						  output [15:0] reg_read_data_2,
						  output reg c_flag, 
						  output reg z_flag,
						  output [15:0] pc_current);
							 
	reg [15:0] reg_array [0:7];  	
  	
	always @ (posedge clk or posedge rst) begin  
		if (rst) begin  
			reg_array [0] <= 16'b0;  
			reg_array [1] <= 16'b0;  
			reg_array [2] <= 16'b0;  
			reg_array [3] <= 16'b0;  
			reg_array [4] <= 16'b0;  
			reg_array [5] <= 16'b0;  
			reg_array [6] <= 16'b0; 
			c_flag <= 1'b0;
			z_flag <= 1'b0;
		end  
		else begin  
			if (reg_write_en) begin 
				case (reg_write_dest)
					3'd0 :reg_array [0] <= reg_write_data;
					3'd1 :reg_array [1] <= reg_write_data;
					3'd2 :reg_array [2] <= reg_write_data;
					3'd3 :reg_array [3] <= reg_write_data;
					3'd4 :reg_array [4] <= reg_write_data;
					3'd5 :reg_array [5] <= reg_write_data;
					3'd6 :reg_array [6] <= reg_write_data;
				endcase		 
			end
			if (c_write_en)	c_flag <= c_data;
			if (z_write_en) 	z_flag <= z_data;
		end
	end 

	always@(posedge clk, posedge rst)   
		if (rst)
			reg_array[7] <= 16'd0;
		else if ((reg_write_en == 1) & (reg_write_dest == 3'd7))
			reg_array[7] <= reg_write_data;
		else if (pc_en == 1)
			reg_array[7] <= pc_new;

	assign pc_current = reg_array[7];
	
	assign reg_read_data_1 = reg_array [reg_read_addr_1];  
	assign reg_read_data_2 = reg_array [reg_read_addr_2];  
	
endmodule
	



	
	
	
	
	
