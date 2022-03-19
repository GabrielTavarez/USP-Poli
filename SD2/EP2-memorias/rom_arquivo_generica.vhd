library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom_arquivo_generica is
    generic(
        addressSize  : natural := 5;
        wordSize    : natural := 8;
        datFileName : string := "conteudo_rom_ativ_02_carga.dat"
    );
    port (
        addr: in bit_vector(addressSize-1 downto 0);
        data: out bit_vector(wordSize-1 downto 0)
    );
end rom_arquivo_generica;

architecture rom_arch of rom_arquivo_generica is

    constant memory_depth    : integer := 2**addressSize;

    type memory_type is array (0 to memory_depth-1) of bit_vector(wordSize-1 downto 0);

    impure function init_mem(nome_arquivo : in string) return memory_type is
        file arq : text open read_mode is nome_arquivo;
        variable linha : line;
        variable temp_bv : bit_vector(wordSize-1 downto 0);
        variable temp_mem : memory_type;

    begin
        for i in memory_type'range loop
            readline(arq, linha);
            read(linha, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        return temp_mem;

    end;
    
    signal mem : memory_type := init_mem(datFileName);
    begin
        data <= mem(to_integer(unsigned(addr)));
end rom_arch;