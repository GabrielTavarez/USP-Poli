library ieee;
use ieee.numeric_bit.all;

entity alu is 
    generic (size : natural := 10 );
    port(
        A,B :in bit_vector (size - 1 downto 0); --entradas
        F : out bit_vector(size - 1 downto 0); --resultado
        S : in bit_vector(3 downto 0); --opcode
        Z : out bit; --flag se for igual a zero
        Ov : out bit; --flag se houver oveflow
        Co : out bit --flag de carry out
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
            less => '0',
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


--============================ ULA 1BIT ========================

library ieee;
use ieee.numeric_bit.all;

entity alu1bit is
    port(
        a,b, less, cin : in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert : in bit;
        operation: in bit_vector(1 downto 0 )
    );
end entity;

architecture alu1bit_arch of alu1bit is

component fulladder is
    port (
        a, b, cin: in bit;
        s, cout: out bit
    );
end component;

component overflow_detector is
    port(
        a, b, s : in bit;
        ovf : out bit
    );
end component;

signal a_sel, b_sel: bit;
signal sum_s, cout_s, and_ab, or_ab :bit;
signal overflow_s : bit;

begin

    a_sel <= a when ainvert = '0' else not(a);
    b_sel <= b when binvert = '0' else not(b);

    fulladde_01 : fulladder port map(
        a => a_sel,
        b => b_sel,
        cin =>  cin,
        s => sum_s,
        cout => cout_s
    );

    overflow_detector_01 : overflow_detector port map(
        a => a_sel,
        b => b_sel,
        s => sum_s,
        ovf => overflow_s
    );

    and_ab <= a_sel and b_sel;
    or_ab <= a_sel or b_sel;

    result <= and_ab when operation = "00" else --and
                or_ab when operation = "01" else -- or
                sum_s when operation = "10" else -- sum
                b; --pass b


    set <= sum_s;
    cout <= cout_s;
    overflow <= overflow_s;




end architecture;


--============= OVERFLOW DETECTOR =========================================
library ieee;
use ieee.numeric_bit.all;

entity overflow_detector is
    port(
        a, b, s : in bit;
        ovf : out bit
    );
end entity;

architecture overflow_detector_ach of overflow_detector is

    signal nxor_ab, xor_bs : bit;

begin

    nxor_ab <= not(a xor b);
    xor_bs <= b xor s;
    
    ovf <= nxor_ab and xor_bs;


end;


entity fulladder is
    port (
        a, b, cin : in bit;
        s, cout : out bit
    );
end entity fulladder;

architecture fulladder_P5A2 of fulladder is

begin
    s <= (a xor b) xor cin;
    cout <= (a and b) or (cin and a) or (cin and b);
end architecture fulladder_P5A2;
