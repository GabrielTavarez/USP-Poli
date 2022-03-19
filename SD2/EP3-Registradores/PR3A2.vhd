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

	process(clock)
	begin
		if reset = '1' then            
				q_s <= (others => '0');
		end if;
		if clock'EVENT AND clock = '1' and load = '1'  then
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
	

	d_s(to_integer(unsigned(wr))) <= d;
	q1 <= q_s(to_integer(unsigned(rr1)));
	q2 <= q_s(to_integer(unsigned(rr2)));

end arch;