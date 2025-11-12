library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity detector is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        data_in  : in  STD_LOGIC;
        detect   : out STD_LOGIC
    );
end detector;

architecture Behavioral of detector is

    type state_type is (S_IDLE, S_1, S_11, S_110, S_1101, S_DETECT);
    signal current_state, next_state : state_type;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= S_IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, data_in)
    begin
        if current_state = S_DETECT then
            detect <= '1';
        else
            detect <= '0';
        end if;

        case current_state is
            when S_IDLE =>
                if data_in = '1' then
                    next_state <= S_1;
                else
                    next_state <= S_IDLE;
                end if;
            when S_1 =>
                if data_in = '1' then
                    next_state <= S_11;
                else
                    next_state <= S_IDLE;
                end if;
            when S_11 =>
                if data_in = '0' then
                    next_state <= S_110;
                else
                    next_state <= S_11;
                end if;
            when S_110 =>
                if data_in = '1' then
                    next_state <= S_1101;
                else
                    next_state <= S_IDLE;
                end if;
            when S_1101 =>
                if data_in = '0' then
                    next_state <= S_DETECT;
                else
                    next_state <= S_1;
                end if;
            when S_DETECT =>
                next_state <= S_IDLE;
        end case;
    end process;

end Behavioral;
