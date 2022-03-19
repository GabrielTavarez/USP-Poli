library ieee;
use ieee.numeric_bit.all;

entity signExtend is
  port(
    i : in bit_vector(31 downto 0); -- input
    o : out bit_vector(63 downto 0) -- output
  );
end signExtend;

architecture signExtendArch of signExtend is
    constant beginTipoD : bit_vector(1 downto 0) := "11";
    constant beginTipoCB : bit_vector(1 downto 0) := "10";
    constant beginTipoB : bit_vector(1 downto 0) := "00";

begin  
    o <= (63 downto 9 => i(20)) & i(20 downto 12) when i(31 downto 30) = beginTipoD else
      (63 downto 19 => i(23)) & i(23 downto 5) when i(31 downto 30) = beginTipoCB else
      (63 downto 26 => i(25)) & i(25 downto 0) when i(31 downto 30) = beginTipoB;

end architecture;
