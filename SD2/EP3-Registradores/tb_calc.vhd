library IEEE;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity testbench is
end testbench;

architecture arch_tb of testbench is

component calc is
    port(
        clock : in bit;
        reset : in bit;
        instruction : in bit_vector(16 downto 0);
        q1 : out bit_vector(15 downto 0)
    );
end component;

    signal instruction_in : bit_vector(16 downto 0);
    signal q1_in :  bit_vector(15 downto 0);

    constant clockPeriod : time := 2 ns;
    signal clock_in: bit := '0';
    signal reset_in: bit;
    signal simulando: bit := '0';
    
begin

	DUT: regfile
    generic map (regn_in, ws_in)
    port map (clock_in, reset_in, regWrite_in, rr1_in, rr2_in, wr_in, d_in, q1_out, q2_out);
    
    clock_in <= (simulando and (not clock_in)) after clockPeriod/2;

    stimulus: process is

		type test_record is record
  			instruction : bit_vector(16 downto 0);
            q1 : bit_vector(15 downto 0);
			str : string(1 to 2);
		end record;


		type tests_array is array (natural range <>) of test_record;
		constant tests : tests_array :=
--       OP-XXX-YYYY-DDDDD, --Q1--   STR
      (("00111110000011111" '00000', "01"),
      );
           
		begin 
			assert false report "Test start." severity note;
			simulando <= '1';
            reset_in <= '1';
            wait for clockPeriod;
            reset_in <= '0';
		for k in tests'range loop
			

            wait for clockPeriod;
			instruction_in <= tests(k).instruction;
            q1_in <= tests(k).Q1;
            wait for 2*clockPeriod;
            
          assert (tests(k).q1 = q1_out)
                report "Fail: q1: " & tests(k).str & "leu: " & integer'image(to_integer(unsigned(q1_out))) severity error;
          assert (tests(k).q2 = q2_out)
                report "Fail: q2: " & tests(k).str & "leu: " & integer'image(to_integer(unsigned(q2_out))) severity error;

		end loop;


		assert false report "Test done." severity note;
		simulando <= '0';
		wait; 
	end process;
end architecture;