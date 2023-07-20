module data_memory (input clk,  
					input [15:0] mem_access_addr,  
					input [15:0] mem_write_data,  
					input mem_write,  
					input mem_read,  
					output [15:0] mem_read_data,
					output [15:0] output_pins);  
						  
	integer i;  
	reg [15:0] ram [0:255];
	
	wire [7:0] ram_addr = mem_access_addr[7:0];  
	
	initial begin  
		for (i=0; i<256; i=i+1)  
			ram [i] <= i;  
	end
	
	always @(posedge clk) 
	begin  
		if (mem_write)
			ram [ram_addr] <= mem_write_data;  
	end  
	
	assign mem_read_data = (mem_read == 1'b1) ? ram [ram_addr] : 16'd0;   
	assign output_pins = ram [255];
	
endmodule 