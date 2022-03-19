------------------------Registrador-----------------------------------------
library IEEE;
use IEEE.NUMERIC_BIT.all;

entity reg is 
	generic
	(
	wordSize	: natural  := 4
	);
   
	port
	(
	clock  : in  bit;
	reset  : in  bit;
	load : in  bit;
	d    : in  bit_vector(wordSize-1 downto 0);
	q	  : out bit_vector(wordSize-1 downto 0)
	);
end reg;

architecture arch of reg is

signal q_s	: bit_vector(wordSize-1 downto 0)	:= (others => '0');

begin

	q <= q_s;

	process(clock,reset)
	begin
		if reset = '1' then            
				q_s <= (others => '0');
		elsif clock'EVENT AND clock = '1' and load = '1'  then
				q_s <= d;
		end if;
	end process;
   
end arch;

------------banco de Registradores---------------------

library IEEE;
use IEEE.NUMERIC_BIT.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity regfile is 
	generic
	(
	regn: natural := 32;
	wordSize	: natural  := 64
	);
   
	port
	(
		clock  : in  bit;
		reset  : in  bit;
		regWrite : in  bit;
		rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
		d	: in  bit_vector(wordSize-1 downto 0);
		q1, q2	: out bit_vector(wordSize-1 downto 0)
	);
end regfile;

architecture arch of regfile is

	COMPONENT reg IS 
		GENERIC(
			wordSize    : NATURAL  := 4
		);
		
		PORT
		(
			clock  : in  bit;
			reset  : in  bit;
			load : in  bit;
			d    : in  bit_vector(wordSize-1 downto 0);
			q	  : out bit_vector(wordSize-1 downto 0)
		);
	END COMPONENT;

type mux_vector is array(regn-1 downto 0) of bit_vector(wordSize-1 downto 0);
signal d_s, q_s	: mux_vector;
signal clock_s, reset_s : bit;

begin

	clock_s <= clock;
	reset_s <= reset;
			
	gerar_regs: 
		FOR i IN 0 TO regn-2 GENERATE
			registrador_i : reg
				generic map(
					wordSize => wordSize
				)
				port map(
					clock => clock_s,
					reset => reset_s,
					load => regWrite,
					q => q_s(i),
					d => d_s(i)
				);
	end generate;

	ultimo_reg : reg
		generic map(
			wordSize => wordSize
			)
		port map(
			clock => clock_s,
			reset => reset_s,
			load => '0',
			q => q_s(regn-1),
			d => d_s(regn-1)
		);
	

	process(clock)
	begin
		if clock'event and clock = '1' then
			d_s(to_integer(unsigned(wr))) <= d;
		end if;
	end process;

	q1 <= q_s(to_integer(unsigned(rr1)));
	q2 <= q_s(to_integer(unsigned(rr2)));

end arch;

-----------------ULA----------------------------------
library ieee;
use ieee.numeric_bit.all;

entity ULA is
	port(
		op1, op2	: in bit_vector(15 downto 0);
		op	: in bit;
		result	: out bit_vector(15 downto 0)
	);
end ULA;

architecture arch of ULA is

	signal result_s : signed(15 downto 0) := (others => '0');

	begin
		result_s <= signed(op1) + signed(op2) when (op = '0') else 
		signed(op1) - signed(op2);

		result <= bit_vector(result_s);

end arch;
			
-----------------Calculadora------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee. math_real.log2;

entity calc is
    port(
        clock : in bit;
        reset : in bit;
        instruction : in bit_vector(16 downto 0);
        q1 : out bit_vector(15 downto 0)
    );
end calc;

architecture arch of calc is

component regfile is
    generic(
        regn :  natural := 32;
        wordSize: natural := 16
    );
    port(
        clock : in bit;
        reset : in bit;
        regWrite : in bit;
        rr1, rr2, wr : in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d : in bit_vector(wordSize-1 downto 0);
        q1, q2 : out bit_vector(wordSize-1 downto 0)
    );
end component;

component ULA is
	port(
		op1, op2	: in bit_vector(15 downto 0);
		op	: in bit;
		result	: out bit_vector(15 downto 0)
	);
end component;

signal clock_s, reset_s : bit;
signal op_s : bit;
signal d_s, q1_s, q2_s, op1_s, op2_s, result_s: bit_vector(15 downto 0);
signal opcode_s : bit_vector(1 downto 0);
signal oper2_s, oper1_s , dest_s : bit_vector(4 downto 0);



begin

	clock_s <= clock;
	reset_s <= reset;

	reg_bank: regfile
		generic map(
			regn => 32,
			wordSize => 16
		)
		port map(
			clock => clock_s,
			reset => reset_s,
			regWrite => '1',
			rr1 => oper1_s,
			rr2 => oper2_s,
			wr => dest_s,
			d => d_s,
			q1 => q1_s,
			q2 => q2_s
		);

	ALU : ULA
	port map(
		op1 => op1_s,
		op2 => op2_s,
		op => op_s,
		result => result_s
	);

	dest_s <= instruction(4 downto 0);
    oper1_s <= instruction(9 downto 5);
    oper2_s <= instruction(14 downto 10);
    opcode_s <= instruction(16 downto 15);

	op_s <= opcode_s(1);

	d_s <= result_s;

	op1_s <= q1_s;
	op2_s <= q2_s when opcode_s(0) = '0' else bit_vector(resize(signed(oper2_s), 16)); 
    
    q1 <= q1_s;

end arch;