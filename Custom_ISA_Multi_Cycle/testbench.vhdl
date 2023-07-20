library ieee; 
use ieee.std_logic_1164.all;

entity testbench is 
end entity;

architecture stim of testbench is 

constant INSTR_add: std_logic_vector := "00000000";
constant INSTR_sub: std_logic_vector := "00000001";
constant INSTR_not: std_logic_vector := "00000010";
constant INSTR_and: std_logic_vector := "00000011";
constant INSTR_or : std_logic_vector := "00000100";
constant INSTR_xor: std_logic_vector := "00000101";
constant INSTR_inc: std_logic_vector := "00000110";
constant INSTR_dec: std_logic_vector := "00000111";
constant INSTR_ror: std_logic_vector := "00001000";
constant INSTR_rsa: std_logic_vector := "00001001";
constant INSTR_rol: std_logic_vector := "00001010";
constant INSTR_lsh: std_logic_vector := "00001011";
constant INSTR_rsh: std_logic_vector := "00001100";
constant INSTR_mva: std_logic_vector := "00001101";
constant INSTR_mvc: std_logic_vector := "00001110";
constant INSTR_jz : std_logic_vector := "00001111";
constant INSTR_jp : std_logic_vector := "00010000";
constant INSTR_js : std_logic_vector := "00010001";
constant INSTR_jc : std_logic_vector := "00010010";
constant INSTR_jmp: std_logic_vector := "00010011";
constant INSTR_swp: std_logic_vector := "00010100";
constant INSTR_str: std_logic_vector := "00010101";

constant A_WIDTH : integer := 8; 
constant D_WIDTH : integer := 16;

signal clk, reset, start, write_en : std_logic;
signal addr : std_logic_vector (A_WIDTH-1 downto 0); 
signal data : std_logic_vector (D_WIDTH-1 downto 0);
signal status : std_logic_vector(3 downto 0);
signal acc : std_logic_vector(7 downto 0);
signal cnt : std_logic_vector(7 downto 0);

component processor is
	generic (a_width : positive := 8;
				   d_width : positive := 16;
				   pc_str : std_logic_vector(7 downto 0) := "00000001";
				   mem_size : positive := 2**8 - 1);
	
	port (clk, rst, wrt, str : in std_logic;
			  addr : in std_logic_vector(a_width - 1 downto 0);
			  data : in std_logic_vector(d_width - 1 downto 0);
			  flag : out std_logic_vector(3 downto 0);
			  accum : out std_logic_vector(7 downto 0);
			  count : out std_logic_vector(7 downto 0));
end component;

procedure do_synch_active_high_half_pulse (signal formal_p_clk : in std_logic; 
														               signal formal_p_sig : out std_logic) is
begin
	wait until formal_p_clk='0';  formal_p_sig <= '1';
	wait until formal_p_clk='0';  formal_p_sig <= '0';
end procedure ;

procedure do_program (signal formal_p_clk : in std_logic; 
							 signal formal_p_write_en : out std_logic; 
							 signal formal_p_addr_out , formal_p_data_out : out std_logic_vector;
							 formal_p_ADDRESS_in , formal_p_DATA_in : in std_logic_vector) is
begin
	wait until formal_p_clk='0';  formal_p_write_en <= '1';
	formal_p_addr_out <= formal_p_ADDRESS_in; 
	formal_p_data_out <= formal_p_DATA_in;
	wait until formal_p_clk='0';  formal_p_write_en <='0';
end procedure;

begin
dut_instance : processor port map (clk, reset, write_en, start, addr, data, status, acc, cnt);
             
process begin
	clk <= '0';
	for i in 0 to 199 loop 
		wait for 1 ns; clk <= '1';  wait for 1 ns; clk <= '0';
	end loop;
	wait;
end process;
  
process begin
	reset <= '0';  start <= '0'; write_en <= '0';
	addr <= "00000000";  data <= "0000000000000000";
	
	do_synch_active_high_half_pulse (clk, reset); 

	--Fill the lines between these comments with the required program	
do_program (clk, write_en, addr, data, "00000001" , INSTR_mvc & "00000110");
do_program (clk, write_en, addr, data, "00000010" , INSTR_add & "00000111");
do_program (clk, write_en, addr, data, "00000011" , INSTR_dec & "00000000");
do_program (clk, write_en, addr, data, "00000100" , INSTR_jz  & "00001000");
do_program (clk, write_en, addr, data, "00000101" , INSTR_jmp & "00000010");
do_program (clk, write_en, addr, data, "00000110" , X"0008");
do_program (clk, write_en, addr, data, "00000111" , X"0006");
do_program (clk, write_en, addr, data, "00001000" , INSTR_str & "00001001");
	--Fill the lines between these comments with the required program	
	
	do_synch_active_high_half_pulse (clk, start);
	
	wait;
end process;

end architecture;
