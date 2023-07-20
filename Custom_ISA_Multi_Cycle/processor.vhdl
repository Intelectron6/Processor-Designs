library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
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
end entity processor;

architecture arch1 of processor is

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

type state is  (ST_FETCH1, ST_FETCH2, ST_FETCH3, 
			    ST_ADD1, ST_ADD2, 
				ST_SUB1, ST_SUB2,
				ST_NOT1, ST_NOT2,
				ST_AND1, ST_AND2, 
				ST_OR1 , ST_OR2 ,
				ST_XOR1, ST_XOR2,
				ST_INC1, 
				ST_DEC1,
				ST_ROR1, ST_ROR2,
				ST_RSA1, ST_RSA2,
				ST_ROL1, ST_ROL2,
				ST_RSH1, ST_RSH2,
				ST_LSH1, ST_LSH2,
				ST_MVA1, ST_MVA2,
				ST_MVC1, ST_MVC2,
				ST_JMP1, 
				ST_JZ1 ,
				ST_JP1 ,
				ST_JS1 ,
				ST_JC1 ,
				ST_SWP1,
				ST_STR1, ST_STR2,
				ST_HALT);
					
signal stvar_ff : state;
signal stvar_ns : state;

type memory_t is array (0 to mem_size) of std_logic_vector(d_width-1 downto 0);
signal mem : memory_t;

signal m_rd, m_wrt : std_logic;
signal data_rd : std_logic_vector(d_width-1 downto 0);
signal address : std_logic_vector(a_width-1 downto 0);

signal AC_ff : std_logic_vector(7 downto 0); --Accumulator
signal CR_ff : std_logic_vector(7 downto 0); --Count register
signal AR_ff : std_logic_vector(a_width-1 downto 0); --Address register
signal PC_ff : std_logic_vector(a_width-1 downto 0); --Program counter
signal DR_ff : std_logic_vector(d_width-1 downto 0); --Data register
signal IR_ff : std_logic_vector(7 downto 0); -- Instruction register
signal carry_flag_ff : std_logic; --Flag resister

signal AC_ns : std_logic_vector(7 downto 0); --Accumulator next state
signal CR_ns : std_logic_vector(7 downto 0); --Count register next state
signal AR_ns : std_logic_vector(a_width-1 downto 0); --Address register next state
signal PC_ns : std_logic_vector(a_width-1 downto 0); --Program counter next state
signal DR_ns : std_logic_vector(d_width-1 downto 0); --Data register next state
signal IR_ns : std_logic_vector(7 downto 0); -- Instruction register next state
signal carry_flag_ns : std_logic; --Flag register next state

signal sign_flag_ff, parity_flag_ff, zero_flag_ff : std_logic;

signal i : integer;

begin

p1: process(stvar_ff, addr, AR_ff)
begin
	if stvar_ff = ST_HALT then
		address <= addr;
	else
		address <= AR_ff;
	end if;
end process p1;

p2: process(clk, rst, m_rd, m_wrt, stvar_ff)
begin
	if rst = '1' then 
		for i in 0 to mem_size-1 loop
			mem(i) <= "0000000000000000";
		end loop;
	elsif rising_edge(clk) then
		if (m_wrt = '1' and m_rd = '0') then
			if (stvar_ff = ST_STR2) then
				mem((to_integer(unsigned(address)))) <= data_rd;
			elsif (stvar_ff = ST_HALT) then
				mem((to_integer(unsigned(address)))) <= data;
			else null;
			end if;
		end if;
	else null;
	end if;	
end process p2;

p3: process(m_rd, m_wrt, address, mem) 
begin
	if (m_rd = '1' and  m_wrt = '0') then
		data_rd <= mem((to_integer(unsigned(address))));
	else
		data_rd <= "ZZZZZZZZZZZZZZZZ";
	end if;
end process p3;

p4: process(clk)
begin
	if rising_edge(clk) then
		if rst = '1'  then
			stvar_ff <= ST_HALT;
		elsif str = '1' then 
			stvar_ff <= ST_FETCH1; 
		else
			stvar_ff <= stvar_ns;
		end if;
	end if;
end process p4;

p5: process(clk)
begin
	if rising_edge(clk) then
		if rst = '1' then 
			AC_ff <= "00000000";
			CR_ff <= "00000000";
			PC_ff <= PC_STR;
			AR_ff <= "00000000";
			IR_ff <= "00000000";
			DR_ff <= "0000000000000000";
			carry_flag_ff <= '0';	
		else 
			AC_ff <= AC_ns;
		   CR_ff <= CR_ns;	
			PC_ff <= PC_ns;
			AR_ff <= AR_ns; 
			IR_ff <= IR_ns;
			DR_ff <= DR_ns;
			carry_flag_ff <= carry_flag_ns;
		end if;
	end if;
end process p5;

p6: process(stvar_ff, str, IR_ff)
begin
	stvar_ns <= stvar_ff;
	case stvar_ff is
		when ST_HALT => if (str = '1') then stvar_ns <= ST_FETCH1; end if;
		when ST_FETCH1 => stvar_ns <= ST_FETCH2;
		when ST_FETCH2 => stvar_ns <= ST_FETCH3;
		when ST_FETCH3 => 
			case IR_ff is
				when INSTR_add => stvar_ns <= ST_ADD1;
				when INSTR_sub => stvar_ns <= ST_SUB1;
				when INSTR_not => stvar_ns <= ST_NOT1;
				when INSTR_and => stvar_ns <= ST_AND1;
				when INSTR_or  => stvar_ns <= ST_OR1;
				when INSTR_xor => stvar_ns <= ST_XOR1;
				when INSTR_inc => stvar_ns <= ST_INC1;
				when INSTR_dec => stvar_ns <= ST_DEC1;
				when INSTR_ror => stvar_ns <= ST_ROR1;
				when INSTR_rsa => stvar_ns <= ST_RSA1;
				when INSTR_rol => stvar_ns <= ST_ROL1;
				when INSTR_rsh => stvar_ns <= ST_RSH1;
				when INSTR_lsh => stvar_ns <= ST_LSH1;
				when INSTR_jmp => stvar_ns <= ST_JMP1;
				when INSTR_jz  => stvar_ns <= ST_JZ1 ;
				when INSTR_jp  => stvar_ns <= ST_JP1 ;
				when INSTR_js  => stvar_ns <= ST_JS1 ;
				when INSTR_jc  => stvar_ns <= ST_JC1 ;
				when INSTR_swp => stvar_ns <= ST_SWP1;
				when INSTR_mva => stvar_ns <= ST_MVA1;
				when INSTR_mvc => stvar_ns <= ST_MVC1;
				when INSTR_str => stvar_ns <= ST_STR1;
				when others => null;
			end case;
		when ST_ADD1 => stvar_ns <= ST_ADD2;
		when ST_SUB1 => stvar_ns <= ST_SUB2;
		when ST_NOT1 => stvar_ns <= ST_NOT2;
		when ST_AND1 => stvar_ns <= ST_AND2;
		when ST_OR1  => stvar_ns <= ST_OR2 ;
		when ST_XOR1 => stvar_ns <= ST_XOR2;
		when ST_MVA1 => stvar_ns <= ST_MVA2;
		when ST_MVC1 => stvar_ns <= ST_MVC2;
		when ST_STR1 => stvar_ns <= ST_STR2;
		when ST_ROR1 => stvar_ns <= ST_ROR2;
		when ST_RSA1 => stvar_ns <= ST_RSA2;
		when ST_ROL1 => stvar_ns <= ST_ROL2;
		when ST_RSH1 => stvar_ns <= ST_RSH2;
		when ST_LSH1 => stvar_ns <= ST_LSH2;
		when ST_JZ1  => stvar_ns <= ST_FETCH1;
		when ST_JP1  => stvar_ns <= ST_FETCH1;
		when ST_JS1  => stvar_ns <= ST_FETCH1;
		when ST_JC1  => stvar_ns <= ST_FETCH1;
		when ST_JMP1 => stvar_ns <= ST_FETCH1;
		when ST_INC1 => stvar_ns <= ST_FETCH1;
		when ST_DEC1 => stvar_ns <= ST_FETCH1;
		when ST_ROR2 => stvar_ns <= ST_FETCH1;
		when ST_RSA2 => stvar_ns <= ST_FETCH1;
		when ST_ROL2 => stvar_ns <= ST_FETCH1;
		when ST_RSH2 => stvar_ns <= ST_FETCH1;
		when ST_LSH2 => stvar_ns <= ST_FETCH1;
		when ST_SWP1 => stvar_ns <= ST_FETCH1;
		when ST_STR2 => stvar_ns <= ST_FETCH1;
		when ST_ADD2 => stvar_ns <= ST_FETCH1;
		when ST_SUB2 => stvar_ns <= ST_FETCH1;
		when ST_NOT2 => stvar_ns <= ST_FETCH1;
		when ST_AND2 => stvar_ns <= ST_FETCH1;
		when ST_OR2  => stvar_ns <= ST_FETCH1;
		when ST_XOR2 => stvar_ns <= ST_FETCH1;
		when ST_MVA2 => stvar_ns <= ST_FETCH1;
		when ST_MVC2 => stvar_ns <= ST_FETCH1;
		when others => null;
	end case;
end process p6;

p7: process(clk, stvar_ff)
begin
	if ((stvar_ff = ST_FETCH2) or (stvar_ff = ST_ADD1) or (stvar_ff = ST_SUB1) or 
	    (stvar_ff = ST_NOT1) or (stvar_ff = ST_AND1) or (stvar_ff = ST_OR1) or (stvar_ff = ST_XOR1) or
		 (stvar_ff = ST_ROR1) or (stvar_ff = ST_RSA1) or (stvar_ff = ST_MVA1) or (stvar_ff = ST_MVC1) or
		 (stvar_ff = ST_ROL1) or (stvar_ff = ST_RSH1) or (stvar_ff = ST_LSH1)) then
		m_rd <= '1';
	else m_rd <= '0';
	end if;
end process p7;

p8: process(clk, wrt, stvar_ff)
begin
	if ((stvar_ff = ST_STR2) or (wrt = '1'))
		then m_wrt <= '1';
	else	m_wrt <= '0';
	end if;
end process p8;

p9: process(clk, stvar_ff, data_rd, PC_ff, DR_ns, AC_ff, DR_ff, AR_ff, IR_ff, CR_ff, carry_flag_ff, sign_flag_ff, zero_flag_ff, parity_flag_ff)
begin
	AR_ns <= AR_ff; 
	PC_ns <= PC_ff;
	DR_ns <= DR_ff; 
	IR_ns <= IR_ff; 
	AC_ns <= AC_ff;
	CR_ns <= CR_ff;
	carry_flag_ns <= carry_flag_ff;
	case stvar_ff is
		when ST_FETCH1 => AR_ns <= PC_ff;
		when ST_FETCH2 => 
			PC_ns <= std_logic_vector(to_unsigned((to_integer(unsigned(PC_ff)) + 1),8)); 
			DR_ns <= data_rd;
			IR_ns <= DR_ns(d_width-1 downto d_width-8);
			AR_ns <= DR_ns(d_width-9 downto 0);
		when ST_FETCH3 => null;
		when ST_ADD1 => DR_ns <= data_rd;
		when ST_ADD2 => AC_ns <= std_logic_vector(to_signed((to_integer(signed(AC_ff)) + to_integer(signed(DR_ff(7 downto 0)))),8));
							 if to_integer(signed(AC_ff)) + to_integer(signed(DR_ff(7 downto 0))) > 127 then carry_flag_ns <= '1';
							 else carry_flag_ns <= '0'; end if;
							 if to_integer(signed(AC_ff)) + to_integer(signed(DR_ff(7 downto 0))) < -128 then carry_flag_ns <= '1';
							 else carry_flag_ns <= '0'; end if;
		when ST_SUB1 => DR_ns <= data_rd;
		when ST_SUB2 => AC_ns <= std_logic_vector(to_signed((to_integer(signed(AC_ff)) - to_integer(signed(DR_ff(7 downto 0)))),8));
							 if to_integer(signed(AC_ff)) - to_integer(signed(DR_ff(7 downto 0))) > 127 then carry_flag_ns <= '1';
							 else carry_flag_ns <= '0'; end if;
							 if to_integer(signed(AC_ff)) - to_integer(signed(DR_ff(7 downto 0))) < -128 then carry_flag_ns <= '1';
							 else carry_flag_ns <= '0'; end if;
		when ST_NOT1 => DR_ns <= data_rd;
		when ST_NOT2 => AC_ns <= not DR_ff(7 downto 0);
		when ST_AND1 => DR_ns <= data_rd;
		when ST_AND2 => AC_ns <= AC_ff and DR_ff(7 downto 0);
		when ST_OR1  => DR_ns <= data_rd;
		when ST_OR2  => AC_ns <= AC_ff or DR_ff(7 downto 0);
		when ST_XOR1 => DR_ns <= data_rd;
		when ST_XOR2 => AC_ns <= AC_ff xor DR_ff(7 downto 0);
		when ST_JMP1 => PC_ns <= DR_ff(7 downto 0);
		when ST_INC1 => CR_ns <= std_logic_vector(to_signed((to_integer(signed(CR_ff)) + 1),8));
		when ST_DEC1 => CR_ns <= std_logic_vector(to_signed((to_integer(signed(CR_ff)) - 1),8));
		when ST_ROR1 => DR_ns <= data_rd;
		when ST_ROR2 => AC_ns <= std_logic_vector(rotate_right(unsigned(AC_ff), to_integer(unsigned(data_rd))));
		when ST_RSA1 => DR_ns <= data_rd;
		when ST_RSA2 => AC_ns <= std_logic_vector(shift_right(signed(AC_ff), to_integer(unsigned(data_rd))));
		when ST_ROL1 => DR_ns <= data_rd;
		when ST_ROL2 => AC_ns <= std_logic_vector(rotate_left(unsigned(AC_ff), to_integer(unsigned(data_rd))));
		when ST_RSH1 => DR_ns <= data_rd;
		when ST_RSH2 => AC_ns <= std_logic_vector(shift_right(unsigned(AC_ff), to_integer(unsigned(data_rd))));
		when ST_LSH1 => DR_ns <= data_rd;
		when ST_LSH2 => AC_ns <= std_logic_vector(shift_left(unsigned(AC_ff), to_integer(unsigned(data_rd))));
		when ST_MVA1 => DR_ns <= data_rd;
		when ST_MVA2 => AC_ns <= DR_ff(7 downto 0);
		when ST_MVC1 => DR_ns <= data_rd;
		when ST_MVC2 => CR_ns <= DR_ff(7 downto 0);
		when ST_SWP1 => CR_ns <= AC_ff; AC_ns <= CR_ff;
		when ST_JZ1  => 
			if zero_flag_ff = '1' then	PC_ns <= DR_ff(7 downto 0);
			else null;
			end if;
		when ST_JP1  => 
			if parity_flag_ff = '1' then	PC_ns <= DR_ff(7 downto 0);
			else null;
			end if;
		when ST_JS1  => 
			if sign_flag_ff = '1' then	PC_ns <= DR_ff(7 downto 0);
			else null;
			end if;
		when ST_JC1  => 
			if carry_flag_ff = '1' then	PC_ns <= DR_ff(7 downto 0);
			else null;
			end if;
		when ST_STR1 => AR_ns <= DR_ff(7 downto 0);
		when ST_STR2 => null;
		when others  => null;
	end case;
end process p9;

p10: process(stvar_ff, addr, AC_ff)
begin
	if stvar_ff = ST_STR2 then
		data_rd <= ("00000000" & AC_ff);
	else
		data_rd <= "ZZZZZZZZZZZZZZZZ";
	end if;
end process p10;

zero_flag_ff <= not(CR_ff(0) or CR_ff(1) or CR_ff(2) or CR_ff(3) or CR_ff(4) or CR_ff(5) or CR_ff(6) or CR_ff(7));
parity_flag_ff <= AC_ff(0) xor AC_ff(1) xor AC_ff(2) xor AC_ff(3) xor AC_ff(4) xor AC_ff(5) xor AC_ff(6) xor AC_ff(7);
sign_flag_ff <= AC_ff(7);

flag <= zero_flag_ff & parity_flag_ff & sign_flag_ff & carry_flag_ff;
accum <= AC_ff;
count <= CR_ff;

pd: process(clk)
begin
	if (clk'event and clk = '1') then
		report "Accumulator value = " & integer'image(to_integer(unsigned(AC_ff)));
		report "Counter Register value = " & integer'image(to_integer(unsigned(CR_ff)));
		report "Mem[9] value = " & integer'image(to_integer(unsigned(mem(9)))); --to visualize the contents of mem[9], can be replaced with whatever
		report "Present state : " & state'image(stvar_ff);
	end if;
end process pd;

end architecture arch1;
