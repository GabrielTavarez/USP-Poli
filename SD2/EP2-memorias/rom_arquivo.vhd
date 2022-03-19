library IEEE;
use IEEE.numeric_bit.all;
use std.textio.all;


entity rom_arquivo is
    port(
        addr : in bit_vector (4 downto 0);
        data : out bit_vector (7 downto 0)
    );
end rom_arquivo;

architecture rom_arquivo_arch of rom_arquivo is
    type memory_type is array (0 to 31) of bit_vector(7 downto 0);

    impure function init_mem(nome_arquivo : in string) return memory_type is
        file arquivo : text open read_mode is nome_arquivo;
        variable linha : line;
        variable bit_vector_temp : bit_vector(7 downto 0);
        variable memory_temp : memory_type;
    begin
        for i in memory_type'range loop
            readline(arquivo, linha);
            read(linha, bit_vector_temp);
            memory_temp(i) := bit_vector_temp;
        end loop;
        return memory_temp;
    end;

    signal memory : memory_type := init_mem("conteudo_rom_ativ_02_carga.dat");  

    begin
        data <= memory(to_integer(unsigned(addr)));
end architecture;