library ieee;
use ieee.numeric_bit.all;

entity alucontrol is
  port(
    aluop   : in bit_vector(1 downto 0);
    opcode  : in bit_vector(10 downto 0);
    aluCtrl : out bit_vector(3 downto 0)
  );
end entity;

architecture alucontrolarch of alucontrol is
    signal aluCtrl_s_Rtype : bit_vector(3 downto 0);

begin

    aluCtrl_s_Rtype <= "0010" when opcode = "10001011000" else -- add
                        "0110" when opcode ="11001011000" else -- sub
                        "0000" when opcode ="10001010000" else -- an
                        "0001" when opcode ="10101010000"; -- or

    aluCtrl <= "0010" when aluop = "00" else
                "0111" when aluop = "01" else
                aluCtrl_s_Rtype when aluop = "10";
end architecture; 