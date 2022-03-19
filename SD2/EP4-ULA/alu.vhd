library ieee;
use ieee.numeric_bit.all;

entity alu is 
    generic (size : natural := 10 );
    port(
        A,B :in bit_vector (size - 1 downto 0);
        F : out bit_vector(size - 1 downto 0);
        S : in bit_vector(3 downto 0);
        Z : out bit;
        Ov : out bit;
        Co : out bit
    );
end entity alu;

architecture alu_arch of alu is

component alu1bit is
    port(
        a,b, less, cin : in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert : in bit;
        operation: in bit_vector(1 downto 0 )
    );
end component;

signal result_s, cout_s, overflow_s, set_s: bit_vector(size-1 downto 0);
constant zeros_vec : bit_vector(size-1 downto 0) := (others => '0');


begin

generate_alus: for i in 0 to size-1 generate
    generate_0 : if i = 0 generate
        alu_0 : alu1bit port map(
            a => A(i),
            b => B(i),
            less => set_s(size-1),
            cin => S(2),
            result => result_s(i),
            cout => cout_s(i),
            set => set_s(i),
            overflow => overflow_s(i),
            ainvert => S(3), 
            binvert => S(2),
            operation => S(1 downto 0 )
        );
    end generate;

    generate_i : if i > 0 and i<size-1 generate
        alu_i: alu1bit port map(
            a => A(i),
            b => B(i),
            less => '0',
            cin => cout_s(i-1),
            result => result_s(i),
            cout => cout_s(i),
            set => set_s(i),
            overflow => overflow_s(i),
            ainvert => S(3), 
            binvert => S(2),
            operation => S(1 downto 0 )
        );
    end generate;

    generate_siz :if i = size-1 generate
        alu_size: alu1bit port map(
            a => A(i),
            b => B(i),
            less => '0',
            cin => cout_s(i-1),
            result => result_s(i),
            cout => cout_s(i),
            set => set_s(i),
            overflow => overflow_s(i),
            ainvert => S(3), 
            binvert => S(2),
            operation => S(1 downto 0 )
        );
    end generate;
end generate;
    F <= result_s;
    Z <= '1' when (zeros_vec = result_s) else '0'; 
    Ov <= overflow_s(size-1);
    Co <= cout_s(size-1);



end;