-- Il seguente codice è stato testato con successo 
-- utilizzando 17 testbench differenti.
-- In particolare sono state utilizzate le testbench 
-- fornite dai docenti su webbep ed altre create
-- appositamente.
-- La sintesi di Vivado (v 2018) utilizza 
-- 53 Flip Flop e 0 Latch


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_start : in STD_LOGIC;
        i_w : in STD_LOGIC;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out STD_LOGIC;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out STD_LOGIC;
        o_mem_en : out STD_LOGIC
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

signal r1_load: STD_LOGIC := '0';
signal r2_load: STD_LOGIC := '0';
signal addr_sel: STD_LOGIC := '0';
signal sel_done: STD_LOGIC := '0';
signal mem_sel : STD_LOGIC := '0';
signal setting : STD_LOGIC := '0';
signal ch: std_logic_vector(1 downto 0) := (others => '0');
signal addr: std_logic_vector(15 downto 0) := (others => '0');
signal tmp0: std_logic_vector(7 downto 0):= (others => '0');
signal tmp1: std_logic_vector(7 downto 0):= (others => '0');
signal tmp2: std_logic_vector(7 downto 0):= (others => '0');
signal tmp3: std_logic_vector(7 downto 0):= (others => '0');

type S is (S1,S2,S3,S4,S5,S6);
signal cur_state, next_state : S;

begin

    -- il segnale o_mem_we non viene mai utilizzato
    o_mem_we <= '0';

    -- processo per cambiare lo stato della macchina a stati
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            cur_state <= S1;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;

    -- processo che gestisce le condizioni per cambiare stato
    process(cur_state, i_start)
    begin
        next_state <= cur_state;

        case cur_state is
            
            when S1 =>
                if i_start = '1' then
                    next_state <= S2;
                else 
                    next_state <= S1;
                end if;
            when S2 =>
                if i_start = '1' then
                    next_state <= S3;
                else 
                    next_state <= S4;
                end if;
            when S3 =>
                if i_start = '1' then
                    next_state <= S3;
                else
                    next_state <= S4; 
                end if;
            when S4 =>
                next_state <= S5;
            when S5 =>
                next_state <= S6;
            when S6 =>  
                next_state <= S1;
            when others =>
                
        end case;
    end process;

    -- processo tramite cui ogni stato gestisce i vari segnali
    process (cur_state)
    begin
        o_mem_en <= '0';
        o_done <= '0';
        sel_done <= '0';
        addr_sel <= '0';
        r1_load <= '0';
        r2_load <= '0';
        mem_sel <= '0';
        setting <= '0';
        case cur_state is
            when S1 =>
                setting <= '1';
                r1_load <= '1';
            when S2 =>
                setting <= '0';
                r1_load <= '0';
                r2_load <= '1';
            when S3 =>
                r2_load <= '0';
                addr_sel <= '1';
            when S4 =>
                r2_load <= '0';
                addr_sel <= '0';
                o_mem_en <= '1';
            when S5 =>
                o_mem_en <= '0';
                mem_sel <= '1';
            when S6 =>
                mem_sel <= '0';
                sel_done <= '1';
                o_done <= '1';
            when others =>
                o_done <= '0';
                r1_load <= '0';
                r2_load <= '0';
                addr_sel <= '0';
                sel_done <= '0';
                mem_sel <= '0';
                setting <= '0';
        end case;
    end process;

    -- processo per leggere il primo bit che identifica il canale di uscita
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if r1_load = '1' then
                ch(1) <= i_w;
            else
                ch(1) <= ch(1);
            end if;
        end if;
    end process;

    -- processo per leggere il secondo bit che identifica il canale di uscita
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if r2_load = '1' then
                ch(0) <= i_w;
            else
                ch(0) <= ch(0);
            end if;
        end if;
    end process;

    -- processo per leggere gli N bit (max 16) che compongono il segnale di address
    process (i_clk, i_rst)
    begin
        if i_rst ='1' then
            addr <= "0000000000000000";
        elsif rising_edge(i_clk) then 
            if addr_sel = '1' and i_start = '1' then
                addr <= addr(14 downto 0) & i_w;
            elsif setting = '1' then
                addr <= "0000000000000000";
            else
                addr <= addr;
            end if;
        end if;
    end process;


    -- processo che assegna input ricevuto dalla memoria al registro corrispondente al canale di uscita definito
    process(i_clk)
    begin
        if i_rst ='1' then
                tmp0 <= "00000000";
                tmp1 <= "00000000";
                tmp2 <= "00000000";
                tmp3 <= "00000000";
        elsif rising_edge(i_clk) then
            if  mem_sel = '1' then
                case ch is
                    when "00" =>
                        tmp0 <= i_mem_data;
                        tmp1 <= tmp1;
                        tmp2 <= tmp2;
                        tmp3 <= tmp3;
                    when "01" =>
                        tmp0 <= tmp0;
                        tmp1 <= i_mem_data;
                        tmp2 <= tmp2;
                        tmp3 <= tmp3;
                    when "10" =>
                        tmp0 <= tmp0;
                        tmp1 <= tmp1;
                        tmp2 <= i_mem_data;
                        tmp3 <= tmp3;
                    when "11" =>
                        tmp0 <= tmp0;
                        tmp1 <= tmp1;
                        tmp2 <= tmp2;
                        tmp3 <= i_mem_data;
                    when others =>
                        tmp0 <= "00000000";
                        tmp1 <= "00000000";
                        tmp2 <= "00000000";
                        tmp3 <= "00000000";
                end case;
            
            else
                tmp0 <= tmp0;
                tmp1 <= tmp1;
                tmp2 <= tmp2;
                tmp3 <= tmp3;
            end if;
        
        end if;
    end process;

    -- a seguito assegnamento dei registri ai corrisponenti canali di uscita

    --z0
    with sel_done select
        o_z0 <= tmp0 when '1', 
        "00000000" when '0', 
        "XXXXXXXX" when others;
    
    --z1   
    with sel_done select
        o_z1 <= tmp1 when '1', 
        "00000000" when '0', 
        "XXXXXXXX" when others;
    
    --z2
    with sel_done select
        o_z2 <= tmp2 when '1', 
        "00000000" when '0', 
        "XXXXXXXX" when others;
    
    --z3    
    with sel_done select
        o_z3 <= tmp3 when '1', 
        "00000000" when '0', 
        "XXXXXXXX" when others;

    -- assegnamento del segnale intermedio address al segnale di output dell' indirizzo di memoria o_mem_addr
    o_mem_addr <= addr;
    
end Behavioral;
