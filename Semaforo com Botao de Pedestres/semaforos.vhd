library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity semaforos is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        btn      : in  STD_LOGIC;
        verde    : out STD_LOGIC;
        amarelo  : out STD_LOGIC;
        vermelho : out STD_LOGIC
    );
end semaforos;

architecture Behavioral of semaforos is

    constant CLK_FREQ           : integer := 50_000_000;
    constant TEMPO_VERDE        : integer := 5;
    constant TEMPO_AMARELO      : integer := 2;
    constant TEMPO_VERMELHO     : integer := 5;
    constant TEMPO_VERMELHO_PED : integer := TEMPO_VERMELHO * 2;

    type state_type is (S_VERDE, S_AMARELO, S_VERMELHO, S_VERMELHO_PED);
    
    signal current_state : state_type;
    signal timer_count   : integer range 0 to CLK_FREQ * TEMPO_VERMELHO_PED;
    signal ped_request   : std_logic := '0';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= S_VERDE;
            timer_count   <= 0;
            ped_request   <= '0';
        elsif rising_edge(clk) then
            case current_state is
                when S_VERDE =>
                    if btn = '1' then
                        ped_request <= '1';
                    end if;
                    if timer_count = (CLK_FREQ * TEMPO_VERDE) - 1 then
                        current_state <= S_AMARELO;
                        timer_count   <= 0;
                    else
                        timer_count <= timer_count + 1;
                    end if;

                when S_AMARELO =>
                    if timer_count = (CLK_FREQ * TEMPO_AMARELO) - 1 then
                        if ped_request = '1' then
                            current_state <= S_VERMELHO_PED;
                        else
                            current_state <= S_VERMELHO;
                        end if;
                        timer_count <= 0;
                    else
                        timer_count <= timer_count + 1;
                    end if;

                when S_VERMELHO =>
                    if timer_count = (CLK_FREQ * TEMPO_VERMELHO) - 1 then
                        current_state <= S_VERDE;
                        timer_count   <= 0;
                    else
                        timer_count <= timer_count + 1;
                    end if;

                when S_VERMELHO_PED =>
                    if timer_count = (CLK_FREQ * TEMPO_VERMELHO_PED) - 1 then
                        current_state <= S_VERDE;
                        timer_count   <= 0;
                        ped_request   <= '0';
                    else
                        timer_count <= timer_count + 1;
                    end if;
            end case;
        end if;
    end process;

    process(current_state)
    begin
        case current_state is
            when S_VERDE =>
                verde    <= '1';
                amarelo  <= '0';
                vermelho <= '0';
            when S_AMARELO =>
                verde    <= '0';
                amarelo  <= '1';
                vermelho <= '0';
            when S_VERMELHO | S_VERMELHO_PED =>
                verde    <= '0';
                amarelo  <= '0';
                vermelho <= '1';
        end case;
    end process;

end Behavioral;
