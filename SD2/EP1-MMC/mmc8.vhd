--============================MMC============================

entity mmc is
    port(
    reset, clock: in bit; 
    inicia: in bit; 
    A, B: in bit_vector(7 downto 0); 
    fim: out bit; 
    nSomas: out bit_vector(8 downto 0);
    MMC: out bit_vector(15 downto 0) 
	
    );
end entity;

architecture arch_MMC of mmc is
    component UC is
        port(
        clock, reset: in bit;
        inicia: in bit;
        ma_igual_mb, ma_maior_mb, mb_maior_ma, ma_zero, mb_zero: in bit;
        hab_reg_a, hab_reg_b, hab_reg_ma, hab_reg_mb, hab_reg_mmc, hab_reg_nsomas, mux_sel_ma, mux_sel_mb, mux_sel_mmc, mux_sel_soma, mux_sel_nsomas: out bit;
        fim: out bit
        );
    end component;

    component FD is
        port(
        clock, reset: in bit;
        hab_reg_a, hab_reg_b, hab_reg_ma, hab_reg_mb, hab_reg_mmc, hab_reg_nsomas, mux_sel_ma, mux_sel_mb, mux_sel_mmc, mux_sel_soma, mux_sel_nsomas: in bit;
        ma_igual_mb, ma_maior_mb, mb_maior_ma, ma_zero, mb_zero: out bit; 
        A,B : in bit_vector(7 downto 0);
        MMC : out bit_vector(15 downto 0);
		nSomas : out bit_vector(8 downto 0)
        );
    end component;

    signal hab_reg_a_s, hab_reg_b_s, hab_reg_ma_s, hab_reg_mb_s, hab_reg_mmc_s, hab_reg_nsomas_s, mux_sel_ma_s, mux_sel_mb_s, mux_sel_mmc_s, mux_sel_soma_s, mux_sel_nsomas_s: bit;
    signal  ma_igual_mb_s, ma_maior_mb_s, mb_maior_ma_s, ma_zero_s, mb_zero_s: bit;
    signal clock_s: bit;

    begin
        clock_s <= not clock;

        xUC: UC
        port map(
            clock => clock_s,
            reset => reset, 
            inicia => inicia, 
            ma_igual_mb => ma_igual_mb_s, 
            ma_maior_mb => ma_maior_mb_s, 
            mb_maior_ma => mb_maior_ma_s, 
            ma_zero => ma_zero_s, 
            mb_zero => mb_zero_s,
            hab_reg_a => hab_reg_a_s, 
            hab_reg_b => hab_reg_b_s, 
            hab_reg_ma => hab_reg_ma_s, 
            hab_reg_mb => hab_reg_mb_s, 
            hab_reg_mmc => hab_reg_mmc_s, 
            hab_reg_nsomas => hab_reg_nsomas_s, 
            mux_sel_ma => mux_sel_ma_s, 
            mux_sel_mb => mux_sel_mb_s, 
            mux_sel_mmc => mux_sel_mmc_s, 
            mux_sel_soma => mux_sel_soma_s, 
            mux_sel_nsomas => mux_sel_nsomas_s, 
            fim => fim
            );

        xFD: FD
        port map(
            clock => clock,
            reset => reset, 
            ma_igual_mb => ma_igual_mb_s, 
            ma_maior_mb => ma_maior_mb_s, 
            mb_maior_ma => mb_maior_ma_s, 
            ma_zero => ma_zero_s, 
            mb_zero => mb_zero_s,
            hab_reg_a => hab_reg_a_s, 
            hab_reg_b => hab_reg_b_s, 
            hab_reg_ma => hab_reg_ma_s, 
            hab_reg_mb => hab_reg_mb_s, 
            hab_reg_mmc => hab_reg_mmc_s, 
            hab_reg_nsomas => hab_reg_nsomas_s, 
            mux_sel_ma => mux_sel_ma_s, 
            mux_sel_mb => mux_sel_mb_s, 
            mux_sel_mmc => mux_sel_mmc_s, 
            mux_sel_soma => mux_sel_soma_s, 
            mux_sel_nsomas => mux_sel_nsomas_s, 
            A=>A,
            B=>B,
            MMC => MMC,
            nSomas => nSomas

        );

end architecture;




--======================REGISTRADOR 16 BITS =======================
entity reg16 is
    port(
        clock, reset: in  bit;
        load:         in  bit;
        in_register :  in  bit_vector(15 downto 0);
        out_register : out bit_vector(15 downto 0)
    );
end entity;

architecture arch_reg of reg16 is
    begin
        process(clock, reset)
        begin
            if reset = '1' then
                out_register <= (others => '0');
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    out_register <= in_register;
                end if;
            end if; 
        end process;
end architecture;


--===========================REGISTRADOR 9 BITS =====================
entity reg9 is
    port(
        clock, reset: in  bit;
        load:         in  bit;
        in_register :  in  bit_vector(8 downto 0);
        out_register : out bit_vector(8 downto 0)
    );
end entity;

architecture arch_reg of reg9 is
    begin
        process(clock, reset)
        begin
            if reset = '1' then 
                out_register <= (others => '0'); 
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    out_register <= in_register;
                end if;
            end if; 
        end process;
end architecture;

--========================== Unidade de Controle ================================

entity UC is
    port(
        clock, reset: in bit;
        inicia: in bit;
        ma_igual_mb, ma_maior_mb, mb_maior_ma, ma_zero, mb_zero: in bit;
        hab_reg_a, hab_reg_b, hab_reg_ma, hab_reg_mb, hab_reg_mmc, hab_reg_nsomas, mux_sel_ma, mux_sel_mb, mux_sel_mmc, mux_sel_soma, mux_sel_nsomas: out bit;
        fim: out bit
    );
end entity;

architecture arch_UC of UC is

    type state is (ESPERA, INICIA_A_B, INICIA_MA_MB, COMP_ZERO, COMP, SOMA_MA, SOMA_MB, ATUALIZA_MMC, FIM_0, FIM_1);
    signal next_state, estado_atual: state;

    begin
        process(clock, reset)
        begin
            if reset = '1' then	
                estado_atual <= ESPERA;		
            elsif (clock'event and clock = '1') then	
                estado_atual <= next_state;
            end if;
        end process;

    update_next_state: process (inicia, ma_zero, mb_zero, ma_igual_mb, ma_maior_mb, mb_maior_ma, estado_atual)
		begin 
		CASE estado_atual is
			when ESPERA => 
				if (inicia = '0') then
					next_state <= ESPERA;
				else 
					next_state <= INICIA_A_B;
				end if;
			
			when INICIA_A_B => 
				next_state <= INICIA_MA_MB;
			
			when INICIA_MA_MB => 
				next_state <= COMP_ZERO;
			
			when COMP_ZERO => 
				if (ma_zero = '1' or mb_zero = '1') then
					next_state <= FIM_0;
				else 
					next_state <= COMP;
				end if;
			
			when COMP => 
				if (ma_igual_mb = '1') then
					next_state <= ATUALIZA_MMC;
				elsif (ma_igual_mb = '0' and ma_maior_mb = '1') then
					next_state <= SOMA_MB;
                elsif (ma_igual_mb = '0' and mb_maior_ma = '1') then
                    next_state <= SOMA_MA;
				end if;
			
			when SOMA_MA => 
				next_state <= COMP;
			
			when SOMA_MB => 
				next_state <= COMP;
			
            when ATUALIZA_MMC =>
                next_state <= FIM_1;

			when FIM_0 => 
				next_state <= ESPERA;
			
			when FIM_1 => 
				next_state <= ESPERA;
            when others => null;
        end case;
    end process;
			
    hab_reg_a <= '1' when (estado_atual = INICIA_A_B) else '0';
    hab_reg_b <= '1' when (estado_atual = INICIA_A_B) else '0';
    hab_reg_ma <= '1' when (estado_atual = INICIA_MA_MB) or (estado_atual = SOMA_MA) else '0';
    hab_reg_mb	<= '1' when (estado_atual = INICIA_MA_MB) or (estado_atual = SOMA_MB) else '0';
    hab_reg_nsomas <= '1' when (estado_atual = INICIA_A_B) or (estado_atual = SOMA_MA) or (estado_atual = SOMA_MB) else '0'; 
	hab_reg_mmc <= '1' when (estado_atual = FIM_0) or (estado_atual = ATUALIZA_MMC) else '0';
	
	mux_sel_ma <= '1' when (estado_atual = SOMA_MA) else '0';
	mux_sel_mb <= '1' when (estado_atual = SOMA_MB) else '0';
	mux_sel_mmc <= '1' when (estado_atual = FIM_1) or (estado_atual = ATUALIZA_MMC) else '0';
	mux_sel_soma <= '1' when (estado_atual = SOMA_MB) else '0';
	mux_sel_nsomas <= '1' when (estado_atual = SOMA_MA) or (estado_atual = SOMA_MB) else '0';
	
    fim <= '1' when (estado_atual = FIM_0) or (estado_atual = FIM_1) else '0';
    
end architecture;

--========================================== Fluxo de Dados ================================
library ieee;
use ieee.numeric_bit.all;

entity FD is
    port(
        clock, reset: in bit;
        hab_reg_a, hab_reg_b, hab_reg_ma, hab_reg_mb, hab_reg_mmc, hab_reg_nsomas, mux_sel_ma, mux_sel_mb, mux_sel_mmc, mux_sel_soma, mux_sel_nsomas: in bit;
        ma_igual_mb, ma_maior_mb, mb_maior_ma, ma_zero, mb_zero: out bit; 
        A,B : in bit_vector(7 downto 0);
        mmc : out bit_vector(15 downto 0);
		nSomas : out bit_vector(8 downto 0)
    );
end entity;

architecture arch_FD of FD is
    component reg16 is
        port(
            clock, reset: in  bit;
            load:         in  bit;
            in_register:  in  bit_vector(15 downto 0);
            out_register: out bit_vector(15 downto 0)
        );
    end component;

    component reg9 is
        port(
            clock, reset: in  bit;
            load:         in  bit;
            in_register:  in  bit_vector(8 downto 0);
            out_register: out bit_vector(8 downto 0)
        );
    end component;

    signal reg_a_in_s, reg_a_out_s, reg_b_in_s, reg_b_out_s, reg_ma_in_s, reg_ma_out_s, reg_mb_in_s, reg_mb_out_s, reg_mmc_in_s, reg_mmc_out_s : bit_vector(15 downto 0);
    signal reg_somas_in_s,reg_somas_out_s: bit_vector(8 downto 0); 
	signal somador_out_s : bit_vector(15 downto 0);

    begin 

        regA: reg16
        port map (clock => clock, reset => reset, load => hab_reg_a, in_register => reg_a_in_s, out_register => reg_a_out_s);

        regB: reg16
        port map (clock => clock, reset => reset, load => hab_reg_b, in_register => reg_b_in_s, out_register => reg_b_out_s);

        regmA: reg16
        port map (clock => clock, reset => reset, load => hab_reg_ma, in_register => reg_ma_in_s, out_register => reg_ma_out_s);
		
		regmB: reg16
        port map (clock => clock, reset => reset, load => hab_reg_mb, in_register => reg_mb_in_s, out_register => reg_mb_out_s);
		
		regMMC: reg16
        port map (clock => clock, reset => reset, load => hab_reg_mmc, in_register => reg_mmc_in_s, out_register => reg_mmc_out_s);
		
		regSomas: reg9
        port map (clock => clock, reset => reset, load => hab_reg_nsomas, in_register => reg_somas_in_s, out_register => reg_somas_out_s);

		reg_a_in_s <= "00000000" & A;
		
		reg_b_in_s <= "00000000" & B;
		
		reg_ma_in_s <= reg_a_out_s when (mux_sel_ma = '0') else somador_out_s ;
		
		reg_mb_in_s <= reg_b_out_s when (mux_sel_mb = '0') else somador_out_s ;
		
		reg_mmc_in_s <= reg_ma_out_s when (mux_sel_mmc = '1') else "0000000000000000";

        mmc <= reg_mmc_out_s;

		reg_somas_in_s <= bit_vector( unsigned(reg_somas_out_s) + 1 ) when (mux_sel_nsomas = '1') else "000000000";

		nSomas <= reg_somas_out_s;

		somador_out_s <= bit_vector((unsigned(reg_a_out_s) + unsigned(reg_ma_out_s))) when (mux_sel_soma = '0') else
			bit_vector((unsigned(reg_b_out_s) + unsigned(reg_mb_out_s)));
		
		ma_igual_mb <= '1' when (unsigned(reg_ma_out_s) = unsigned(reg_mb_out_s)) else '0';
		
		ma_maior_mb <= '1' when (unsigned(reg_ma_out_s) > unsigned(reg_mb_out_s)) else '0';
		
		mb_maior_ma <= '1' when (unsigned(reg_ma_out_s) < unsigned(reg_mb_out_s)) else '0';
		
		ma_zero <= '1' when (unsigned(reg_ma_out_s) = 0) else '0';
		
		mb_zero <= '1' when (unsigned(reg_b_out_s) = 0) else '0';
			
end architecture;


