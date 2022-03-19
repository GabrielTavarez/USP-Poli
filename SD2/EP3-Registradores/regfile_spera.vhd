library ieee;
use ieee.numeric_bit.all;


entity reg is

    generic(wordSize: natural := 4);

    port(
        clock:  in bit;
        reset:  in bit;
        load:   in bit;
        d:      in bit_vector(wordSize-1 downto 0);
        q:      out bit_vector(wordSize-1 downto 0)
    );
end reg;

architecture arch_reg of reg is

    signal q_s: bit_vector(wordSize-1 downto 0) := (others =>'0');

    begin
        q <= q_s;

        process(clock, reset)
            begin 
                if reset = '1' then
                    q_s <= (others => '0');
                elsif clock'event and clock = '1' and load='1' then
                    q_s <= d;
                end if;
        end process;
end arch_reg;

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;


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

architecture arch_regfile of regfile is

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

    type vectors_q is array (regn-1 downto 0) of bit_vector(wordSize-1 downto 0); 
    signal qs, q1_s, q2_s : vectors_q;

    type vectors_load is array (regn-1 downto 0) of bit;
    signal L, wr_s : vectors_load;

    signal d_s : bit_vector(wordSize-1 downto 0);
    signal clock_s, reset_s : bit;

    begin
        gen_rs: for i in 0 to regn-1 generate

        i_reg_geral : if i < regn-1 generate 
            L(i) <= wr_s(i) and regWrite;
            reg_i : reg 
                generic map(wordSize=>wordSize)
                port map (clock => clock_s , reset => reset_s, load => L(i) , d => d_s , q => qs(i));
            end generate i_reg_geral;

        i_reg_n : if i = regn-1 generate
            reg_zero : reg 
                generic map (wordSize=>wordSize)
                port map (clock => clock, reset => reset, load => '0', d => (others => '0') , q => qs(i));
            end generate i_reg_n;
        end generate gen_rs;

    process (wr)
        begin
            for k in 0 to (regn-1) loop
                if ( k /= to_integer(unsigned(wr)) ) then wr_s(k) <= '0';
                    else wr_s(k) <= '1';
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
        
end arch_regfile; 
