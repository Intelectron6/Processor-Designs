module arithmetic_logic_unit (input [15:0] a, b,
							  input [3:0] opcode,
							  input [1:0] cz,
							  input clk, rst,
							  input c_in, z_in,
							  output reg [15:0] result,
							  output reg c_out, z_out);
				
	always@(*) begin	
	case(opcode)	
		4'b0000: 
			begin
			{c_out, result} = a + b;
			z_out = ~(|result);
			end
			
		4'b0001: 
			begin
			if (cz == 2'b00) 
				{c_out, result} = a + b;
			else if (cz == 2'b01)
				{c_out, result} = z_in ? (a + b) : 17'd0;
			else if (cz == 2'b10)
				{c_out, result} = c_in ? (a + b) : 17'd0;
			else
				{c_out, result} = a + {b[14:0], 1'b0};
			z_out = ~(|result);
			end
			
		4'b0010:
			begin
			if (cz == 2'b00) 
				result = ~(a & b);
			else if (cz == 2'b01)
				result = z_in ? (~(a & b)) : 16'h0000;
			else if (cz == 2'b10)
				result = c_in ? (~(a & b)) : 16'h0000;
			else
				result = 16'h0000;
			z_out = ~(|result);
			c_out = c_in;
			end
		
		4'b0100:
			begin
				result = a + b;
				z_out = z_in;
				c_out = c_in;
			end
			
		4'b0101:
			begin
				result = a + b;
				z_out = z_in;
				c_out = c_in;
			end
		
		4'b1000:
			begin
				result = a - b;
				z_out = ~(|result);
				c_out = c_in;
			end
			
		4'b1011:
			begin
				result = a + b;
				z_out = z_in;
				c_out = c_in;
			end
			
		default:
			begin
				result = a + b;
				z_out = z_in;
				c_out = c_in;
			end
	endcase
	end

endmodule
