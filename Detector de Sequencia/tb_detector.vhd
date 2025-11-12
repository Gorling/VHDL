library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_detector is
end tb_detector;

architecture Behavioral of tb_detector is

    component detector
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            data_in  : in  STD_LOGIC;
            detect   : out STD_LOGIC
        );
    end component;

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC;
    signal data_in  : STD_LOGIC;
    signal detect   : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: detector
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => data_in,
            detect   => detect
        );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stimulus_process : process
    begin
        reset <= '1';
        data_in <= '0';
        wait for 2 * CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        -- Teste com a sequência CORRETA "11010"
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        wait for 2 * CLK_PERIOD;

        -- Teste com bits incorretos no meio
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        wait for 2 * CLK_PERIOD;

        -- Teste com sequência correta após uma falha
        data_in <= '1'; wait for CLK_PERIOD; 
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        wait for 2 * CLK_PERIOD;
        
        wait;

    end process;

end Behavioral;
