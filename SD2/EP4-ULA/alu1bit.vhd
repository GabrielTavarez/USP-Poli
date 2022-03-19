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

    result <= and_ab when operation = "00" else
                or_ab when operation = "01" else
                sum_s when operation = "10" else
                less;


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
