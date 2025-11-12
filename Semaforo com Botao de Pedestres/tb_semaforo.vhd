library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_semaforo is
end tb_semaforo;

architecture Behavioral of tb_semaforo is

    component semaforos
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            btn      : in  STD_LOGIC;
            verde    : out STD_LOGIC;
            amarelo  : out STD_LOGIC;
            vermelho : out STD_LOGIC
        );
    end component;

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC;
    signal btn      : STD_LOGIC;
    signal verde    : STD_LOGIC;
    signal amarelo  : STD_LOGIC;
    signal vermelho : STD_LOGIC;
    
    constant CLK_PERIOD : time := 20 ns;

begin

    uut: semaforos
        port map (
            clk      => clk,
            reset    => reset,
            btn      => btn,
            verde    => verde,
            amarelo  => amarelo,
            vermelho => vermelho
        );

    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stimulus_process : process
    begin
        reset <= '1';
        btn   <= '0';
        wait for 100 ns;
        reset <= '0';
        wait for CLK_PERIOD;

        wait for 15 sec;

        wait for 2 sec;
        
        btn <= '1';
        wait for CLK_PERIOD;
        btn <= '0';

        wait for 20 sec;

        wait;
    end process;

end Behavioral;
```eof
