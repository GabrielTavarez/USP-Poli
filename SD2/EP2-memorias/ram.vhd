library ieee;
use ieee.numeric_bit.all;

entity ram is
    generic(
        addressSize  : natural := 5;
        wordSize    : natural := 8
    );
    port (
        ck, wr : in bit;
        addr: in bit_vector(addressSize-1 downto 0);
        data_i: in bit_vector(wordSize-1 downto 0);
        data_o: out bit_vector(wordSize-1 downto 0)
    );
end ram;

architecture ram_arch of ram is

    constant memory_depth    : integer := 2**addressSize;

    type memory_type is array (0 to memory_depth-1) of bit_vector(wordSize-1 downto 0);

    
    signal memory : memory_type;
    signal data_i_s : bit_vector(wordSize-1 downto 0);
    begin
        process(ck)
        begin
            if (ck'event and ck = '1') then
                if(wr = '1') then
                    memory(to_integer(unsigned(addr))) <= data_i;
                end if;
            end if;
        end process;

        data_o <= memory(to_integer(unsigned(addr)));
        data_i_s <= data_i;
end ram_arch;