library ieee;
use ieee.numeric_bit.all;

entity controlunit is
    port (
        -- To Datapath
        reg2loc : out bit;
        uncondBranch : out bit;
        branch : out bit;
        memRead : out bit;
        memToReg : out bit;
        aluOp : out bit_vector(1 downto 0);
        memWrite : out bit;
        aluSrc : out bit;
        regWrite : out bit;
        -- From Datapath
        opcode : in bit_vector(10 downto 0)
    );
end entity controlunit;

architecture controlunitArch of controlunit is

constant ldur : bit_vector(10 downto 0) := "11111000010";
constant stur : bit_vector(10 downto 0) := "11111000000";
constant cbz : bit_vector(7 downto 0) := "10110100";
constant b : bit_vector(5 downto 0) := "000101";
constant add : bit_vector(10 downto 0) := "10001011000";
constant sub : bit_vector(10 downto 0) := "11001011000";
constant and_ : bit_vector(10 downto 0) := "10001010000";
constant orr : bit_vector(10 downto 0) := "10101010000";


begin

    reg2loc <= '1' when opcode = cbz else
                '0';
    uncondBranch <= '1' when opcode(10 downto 5) = b else
                    '0';

    branch <= '1' when opcode(10 downto 5) = b | opcode(10 downto 3) = cbz else
                '0';

    memRead <= '0' when opcode = stur else '1';

    memToReg <= '1' when opcode = ldur else '0';

    aluOp <= "00" when opcode = ldur else  
            "10" when opcode = stur else
            "01" when opcode(10 downto 3) = cbz else
            "00" when opcode(10 downto 5) = b  else
            "10" when others;

    memWrite <= '1' when stur else '0';

    aluSrc <= '1' when opcode = ldur | opcode = stur else '0';

    regWrite <= 


end architecture;