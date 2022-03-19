library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee. math_real.log2;

entity calc is
    port(
        clock : in bit;
        reset : in bit;
        instruction : in bit_vector(16 downto 0);
        q1 : out bit_vector(15 downto 0)
    );
end calc;

architecture calc_arch of calc is

component regfile is
    generic(
        regn :  natural := 32;
        wordSize: natural := 64
    );
    port(
        clock : in bit;
        reset : in bit;
        regWrite : in bit;
        rr1, rr2, wr : in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d : in bit_vector(wordSize-1 downto 0);
        q1, q2 : out bit_vector(wordSize-1 downto 0)
    );
end component;

component ULA is
    port(
        x : in bit_vector(15 downto 0);
        y : in bit_vector(15 downto 0);
        op : in bit;
        result : out bit_vector(15 downto 0)
    );
end component;

signal clock_s, reset_s, regWrite, op_s : bit;
signal rr1_s, rr2_s,  wr_s : bit_vector(4 downto 0);
signal d_s, q1_s, q2_s, y_s, x_s, result_s: bit_vector(15 downto 0);
signal opcode_s : bit_vector(1 downto 0);
signal oper1_s, oper2_s , dest_s : bit_vector(4 downto 0);

begin

    reg_bank : regfile
        generic map (
            regn => 32,
            wordSize => 16
        )
        port map (
            clock => clock_s,
            reset => reset_s,
            regWrite => '1',
            rr1 => rr1_s,
            rr2 => rr2_s,
            wr => wr_s,
            d => d_s,
            q1 => q1_s,
            q2 => q2_s
        );

        ULA_0 : ULA
            port map(
                x => x_s,
                y => y_s,
                op => op_s,
                result => result_s
            );
    
    clock_s <= clock;
    reset_s <= reset;

    dest_s <= instruction(4 downto 0);
    oper1_s <= instruction(9 downto 5);
    oper2_s <= instruction(14 downto 10);
    opcode_s <= instruction(16 downto 15);

    rr1_s <= oper1_s;
    rr2_s <= oper2_s;
    wr_s <= dest_s;
    d_s <= result_s;


    x_s <= q1_s;
    --y_s <= q2_s when opcode_s(0) = '0' else bit_vector(signed(oper2_s));
    y_s <= q2_s when opcode_s(0) = '0' else bit_vector(resize(signed(oper2_s), 16)); 
    op_s <= opcode_s(1);

    q1 <= q1_s;

end calc_arch;

--=================ADDSUB=================================================================


library ieee;
use ieee.numeric_bit.all;

entity ULA is
    port(
        x : in bit_vector(15 downto 0);
        y : in bit_vector(15 downto 0);
        op : in bit;
        result : out bit_vector(15 downto 0)
    );
end ULA;

architecture ULA_arch of ULA is

signal result_s : signed(15 downto 0) := "0000000000000000";

begin
    result_s <= signed(x) + signed(y) when op = '0' else signed(x) - signed(y);
    
    result <= bit_vector(result_s);

end ULA_arch;



--================================================REG FILE================================

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee. math_real.log2;

entity regfile is
    generic(
        regn :  natural := 32;
        wordSize: natural := 64
    );


    port(
        clock : in bit;
        reset : in bit;
        regWrite : in bit;
        rr1, rr2, wr : in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d : in bit_vector(wordSize-1 downto 0);
        q1, q2 : out bit_vector(wordSize-1 downto 0)
    );
end regfile;

architecture regfile_arch of regfile is

    
    component reg
        generic(wordSize: natural :=4);

        port(
            clock : in bit;
            reset : in bit;
            load : in bit;
            d : in bit_vector(wordSize-1 downto 0);
            q : out bit_vector(wordSize-1 downto 0)
        );
    end component;
   
    signal clock_s, reset_s : bit;

    type q_vec is array (regn-1 downto 0) of bit_vector(wordSize-1 downto 0); 
    signal qs, q1_s, q2_s : q_vec;

    type load_vec is array (regn-1 downto 0) of bit;
    signal load_s, wr_s : load_vec;

    signal d_s : bit_vector(wordSize-1 downto 0);

    begin

        gen_regs : for i in 0 to regn - 1 generate

            i_geral : if i < regn-1 generate
            load_s(i) <= wr_s(i) and regWrite;
                reg_i : reg 
                    generic map (wordSize=>wordSize)
                    port map (clock => clock_s , reset => reset_s, load => load_s(i) , d => d_s , q => qs(i));
            end generate i_geral;

            i_n : if i = regn-1 generate
                reg_zero : reg 
                    generic map (wordSize=>wordSize)
                    port map (clock => clock, reset => reset, load => '0', d => (others => '0') , q => qs(i));
            end generate i_n;
        end generate gen_regs;

        process (wr)
        begin
            for j in 0 to (regn-1) loop
                if ( j /= to_integer(unsigned(wr)) ) then
                    wr_s(j) <= '0';
                else
                    wr_s(j) <= '1';
                end if;
            end loop;
        end process;

        clock_s <= clock;
        reset_s <= reset;

        d_s <= d;

        q1_s <= qs;
        q2_s <= qs;

        q1 <= q1_s(to_integer(unsigned(rr1)));
        q2 <= q2_s(to_integer(unsigned(rr2)));
        
end regfile_arch; 




--======================REGISTRADOR======================================
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