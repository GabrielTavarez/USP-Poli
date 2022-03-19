library ieee;
use ieee.numeric_bit.all;

entity reg is

generic(wordSize: natural :=4);

port(
    clock : in bit;
    reset : in bit;
    load : in bit;
    d : in bit_vector(wordSize-1 downto 0);
    q : out bit_vector(wordSize-1 downto 0)
);
end reg;

architecture reg_arch of reg is

    signal q_s : bit_vector(wordSize-1 downto 0) := (others => '0');

    begin
    q <= q_s;

        process(clock, reset)
            begin
                if reset = '1' then
                    q_s <= (others => '0');
                elsif clock'event and clock = '1' and load ='1' then
                    q_s <= d;
                end if;
        end process;

        
end reg_arch; 