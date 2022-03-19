entity tb is
end tb;

architecture tb_rom of tb is
    component alu
        generic (
            size : natural := 10 --bit size
        );
        port(
            A, B : in bit_vector(size-1 downto 0); --input
            F : out bit_vector(size-1 downto 0); --output
            S : in bit_vector(3 downto 0); --op selection
            Z : out bit; --zero flag
            Ov : out bit; --overflow flag
            Co: out bit --carryout flag
        );
    end component alu;

        signal a4, b4, f4, s4, s2: bit_vector(3 downto 0);
        signal z4, ov4, co4: bit;

        signal a2, b2, f2: bit_vector(2 downto 0);
        signal z2, ov2, co2: bit;
    begin

    DUT1 : alu
        generic map(
            size => 4
        )
        port map(
            A => a4,
            B => b4,
            F => f4,
            S => s4,
            Z => z4,
            Ov => ov4,
            Co => co4
        );
    stimulus1: process is

    begin
        assert false report "BOT 4bits | A=0011 | B=0111" severity note;

        a4 <= "0011";
        b4 <= "0111";

        s4<= "0000";
        wait for 5 ns;
        assert f4 = "0011" report "ghdlfiddle:BAD - Erro em resultado - 4bit | s=0000 (AND)" severity note;
        assert z4 = '0' report "ghdlfiddle:BAD - Erro no z - 4bit | s=0000 (AND)" severity note;
        assert co4 = '0' report "ghdlfiddle:BAD - Erro no co - 4bit | s=0000 (AND)" severity note;
        assert ov4 = '1' report "ghdlfiddle:BAD - Erro no overflow - 4bit | s=0000 (AND)" severity note;
        wait for 5 ns;

        s4<= "0001";
        wait for 5 ns;
        assert f4 = "0111" report "ghdlfiddle:BAD - Erro no resultado - 4bit | s=0001 (OR)" severity note;
        assert z4 = '0' report "ghdlfiddle:BAD - Erro no z - 4bit | s=0001 (OR)" severity note;
        assert co4 = '0' report "ghdlfiddle:BAD - Erro no co - 4bit | s=0001 (OR)" severity note;
        assert ov4 = '1' report "ghdlfiddle:BAD - Erro no overflow - 4bit | s=0001 (OR)" severity note;
        wait for 5 ns;

        s4<= "0010";
        wait for 5 ns;
        assert f4 = "1010" report "ghdlfiddle:BAD - Erro no resultado - 4bit | s=0010 (ADD)" severity note;
        assert z4 = '0' report "ghdlfiddle:BAD - Erro no z - 4bit | s=0010 (ADD)" severity note;
        assert co4 = '0' report "ghdlfiddle:BAD - Erro no co - 4bit | s=0010 (ADD)" severity note;
        assert ov4 = '1' report "ghdlfiddle:BAD - Erro no overflow - 4bit | s=0010 (ADD)" severity note;
        wait for 5 ns;

        s4<= "0110";
        wait for 5 ns;
        assert f4 = "1100" report "ghdlfiddle:BAD - Erro no resultado - 4bit | s=0110 (SUB)" severity note;
        assert z4 = '0' report "ghdlfiddle:BAD - Erro no z - 4bit | s=0110 (SUB)" severity note;
        assert co4 = '0' report "ghdlfiddle:BAD - Erro no co - 4bit | s=0110 (SUB)" severity note;
        assert ov4 = '0' report "ghdlfiddle:BAD - Erro no overflow - 4bit | s=0110 (SUB)" severity note;
        wait for 5 ns;

        s4<= "0111";
        wait for 5 ns;
        assert f4 = b4 report "ghdlfiddle:BAD - Erro no resultado - 4bit | s=0111 (SLT)" severity note;
        assert z4 = '0' report "ghdlfiddle:BAD - Erro no z - 4bit | s=0111 (SLT)" severity note;
        assert co4 = '0' report "ghdlfiddle:BAD - Erro no co - 4bit | s=0111 (SLT)" severity note;
        assert ov4 = '0' report "ghdlfiddle:BAD - Erro no overflow - 4bit | s=0111 (SLT)" severity note;
        wait for 5 ns;

        s4<= "1100";
        wait for 5 ns;
        assert f4 = "1000" report "ghdlfiddle:BAD - Erro no resultado - 4bit | s=1100 (AND - A e B invertidos)" severity note;
        assert z4 = '0' report "ghdlfiddle:BAD - Erro no z - 4bit | s=1100 (AND - A e B invertidos)" severity note;
        assert co4 = '1' report "ghdlfiddle:BAD - Erro no co - 4bit | s=1100 (AND - A e B invertidos)" severity note;
        assert ov4 = '1' report "ghdlfiddle:BAD - Erro no overflow - 4bit | s=1100 (AND - A e B invertidos)" severity note;
        wait for 5 ns;

        s4<= "1001";
        wait for 5 ns;
        assert f4 = "1111" report "ghdlfiddle:BAD - Erro no resultado - 4bit | s=1001 (OR - A invertido)" severity note;
        assert z4 = '0' report "ghdlfiddle:BAD - Erro no z - 4bit | s=1001 (OR - A invertido)" severity note;
        assert co4 = '1' report "ghdlfiddle:BAD - Erro no co - 4bit | s=1001 (OR - A invertido)" severity note;
        assert ov4 = '0' report "ghdlfiddle:BAD - Erro no overflow - 4bit | s=1001 (OR - A invertido)" severity note;
        wait for 5 ns;

        assert false report "EOT 4bits" severity note;

        wait; 
    end process;

    DUT2 : alu
        generic map(
            size => 3
        )
        port map(
            A => a2,
            B => b2,
            F => f2,
            S => s2,
            Z => z2,
            Ov => ov2,
            Co => co2
        );

    stimulus2: process is
        begin
            assert false report "BOT 3bits | A=001 | B=010" severity note;
    
            a2 <= "001";
            b2 <= "010";
    

            s2<= "1110";
            wait for 5 ns;
            assert f2 = "100" report "ghdlfiddle:BAD - Erro no resultado - 3bit | s=1110 (SUB - A invertido)" severity note;
            assert z2 = '0' report "ghdlfiddle:BAD - Erro no z - 3bit | s=1110 (SUB - A invertido)" severity note;
            assert co2 = '1' report "ghdlfiddle:BAD - Erro no co - 3bit | s=1110 (SUB - A invertido)" severity note;
            assert ov2 = '0' report "ghdlfiddle:BAD - Erro no overflow - 3bit | s=1110 (SUB - A invertido)" severity note;
            wait for 5 ns;


            s2<= "0000";
            wait for 5 ns;
            assert f2 = "000" report "ghdlfiddle:BAD - Erro no resultado - 3bit | s=0000 (AND)" severity note;
            assert z2 = '1' report "ghdlfiddle:BAD - Erro no z - 3bit | s=0000 (AND)" severity note;
            assert co2 = '0' report "ghdlfiddle:BAD - Erro no co - 3bit | s=0000 (AND)" severity note;
            assert ov2 = '0' report "ghdlfiddle:BAD - Erro no overflow - 3bit | s=0000 (AND)" severity note;
            wait for 5 ns;

            s2<= "0001";
            wait for 5 ns;
            assert f2 = "011" report "ghdlfiddle:BAD - Erro no resultado - 3bit | s=0001 (OR)" severity note;
            assert z2 = '0' report "ghdlfiddle:BAD - Erro no z - 3bit | s=0001 (OR)" severity note;
            assert co2 = '0' report "ghdlfiddle:BAD - Erro no co - 3bit | s=0001 (OR)" severity note;
            assert ov2 = '0' report "ghdlfiddle:BAD - Erro no overflow - 3bit | s=0001 (OR)" severity note;
            wait for 5 ns;

            s2<= "0010";
            wait for 5 ns;
            assert f2 = "011" report "ghdlfiddle:BAD - Erro no resultado - 3bit | s=0010 (ADD)" severity note;
            assert z2 = '0' report "ghdlfiddle:BAD - Erro no z - 3bit | s=0010 (ADD)" severity note;
            assert co2 = '0' report "ghdlfiddle:BAD - Erro no set - 3bit | s=0010 (ADD)" severity note;
            assert ov2 = '0' report "ghdlfiddle:BAD - Erro no overflow - 3bit | s=0010 (ADD)" severity note;
            wait for 5 ns;

            s2<= "0110";
            wait for 5 ns;
            assert f2 = "111" report "ghdlfiddle:BAD - Erro no resultado - 3bit | s=0110 (SUB)" severity note;
            assert z2 = '0' report "ghdlfiddle:BAD - Erro no z - 3bit | s=0110 (SUB)" severity note;
            assert co2 = '0' report "ghdlfiddle:BAD - Erro no co - 3bit | s=0110 (SUB)" severity note;
            assert ov2 = '0' report "ghdlfiddle:BAD - Erro no overflow - 3bit | s=0110 (SUB)" severity note;
            wait for 5 ns;

            s2<= "0111";
            wait for 5 ns;
            assert f2 = b2 report "ghdlfiddle:BAD - Erro no resultado - 3bit | s=0111 (SLT)" severity note;
            assert z2 = '0' report "ghdlfiddle:BAD - Erro no z - 3bit | s=0111 (SLT)" severity note;
            assert co2 = '0' report "ghdlfiddle:BAD - Erro no co - 3bit | s=0111 (SLT)" severity note;
            assert ov2 = '0' report "ghdlfiddle:BAD - Erro no overflow - 3bit | s=0111 (SLT)" severity note;
            wait for 5 ns;

            s2<= "1100";
            wait for 5 ns;
            assert f2 = "100" report "ghdlfiddle:BAD - Erro no resultado - 3bit | s=1100 (AND - A e B invertidos)" severity note;
            assert z2 = '0' report "ghdlfiddle:BAD - Erro no z - 3bit | s=1100 (AND - A e B invertidos)" severity note;
            assert co2 = '1' report "ghdlfiddle:BAD - Erro no co - 3bit | s=1100 (AND - A e B invertidos)" severity note;
            assert ov2 = '0' report "ghdlfiddle:BAD - Erro no overflow - 3bit | s=1100 (AND - A e B invertidos)" severity note;
            wait for 5 ns;
    
            s2<= "1001";
            wait for 5 ns;
            assert f2 = "110" report "ghdlfiddle:BAD - Erro no resultado - 3bit | s=1001 (OR - A invertido)" severity note;
            assert z2 = '0' report "ghdlfiddle:BAD - Erro no z - 3bit | s=1001 (OR - A invertido)" severity note;
            assert co2 = '1' report "ghdlfiddle:BAD - Erro no co - 3bit | s=1001 (OR - A invertido)" severity note;
            assert ov2 = '0' report "ghdlfiddle:BAD - Erro no overflow - 3bit | s=1001 (OR - A invertido)" severity note;
            wait for 5 ns;
    
						report "ghdlfiddle:GOOD Fim dos testes!";
    
        wait; 
    end process;

end architecture;