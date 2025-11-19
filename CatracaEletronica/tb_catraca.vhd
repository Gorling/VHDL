library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_catraca is
-- Testbench não tem portas
end tb_catraca;

architecture Behavioral of tb_catraca is

    -- Componente a ser testado
    component catraca_eletronica
        Generic ( MAX_PESSOAS : integer := 3 ); -- Mudei para 3 para o teste ser rápido
        Port ( 
            clk           : in STD_LOGIC;
            reset         : in STD_LOGIC;
            sensor_cartao : in STD_LOGIC;
            sensor_giro   : in STD_LOGIC;
            reset_cont    : in STD_LOGIC;
            solenoide     : out STD_LOGIC;
            led_vermelho  : out STD_LOGIC;
            led_verde     : out STD_LOGIC;
            contagem_out  : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Sinais para conectar ao componente
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal sensor_cartao : STD_LOGIC := '0';
    signal sensor_giro : STD_LOGIC := '0';
    signal reset_cont : STD_LOGIC := '0';
    
    signal solenoide : STD_LOGIC;
    signal led_vermelho : STD_LOGIC;
    signal led_verde : STD_LOGIC;
    signal contagem_out : STD_LOGIC_VECTOR(7 downto 0);

    -- Período do Clock
    constant clk_period : time := 10 ns;

begin

    -- Instanciação da UUT (Unit Under Test)
    uut: catraca_eletronica 
    generic map (MAX_PESSOAS => 3) -- Bloqueia após 3 pessoas
    port map (
        clk => clk,
        reset => reset,
        sensor_cartao => sensor_cartao,
        sensor_giro => sensor_giro,
        reset_cont => reset_cont,
        solenoide => solenoide,
        led_vermelho => led_vermelho,
        led_verde => led_verde,
        contagem_out => contagem_out
    );

    -- Processo de Clock
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Processo de Estímulo
    stim_proc: process
    begin		
        -- 1. Reset inicial
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- 2. Pessoa 1: Passa cartão e entra
        sensor_cartao <= '1'; -- Solicita entrada
        wait for 10 ns;
        sensor_cartao <= '0';
        wait for 20 ns; -- Tempo com a catraca liberada
        sensor_giro <= '1'; -- Pessoa gira a catraca
        wait for 10 ns;
        sensor_giro <= '0';
        wait for 20 ns;

        -- 3. Pessoa 2: Passa cartão e entra
        sensor_cartao <= '1';
        wait for 10 ns;
        sensor_cartao <= '0';
        wait for 20 ns;
        sensor_giro <= '1';
        wait for 10 ns;
        sensor_giro <= '0';
        wait for 20 ns;
        
        -- 4. Pessoa 3: Passa cartão e entra (Deve atingir o MAX e BLOQUEAR)
        sensor_cartao <= '1';
        wait for 10 ns;
        sensor_cartao <= '0';
        wait for 20 ns;
        sensor_giro <= '1'; -- Ao processar este giro, count vai para 3 e estado vai para BLOQUEADA
        wait for 10 ns;
        sensor_giro <= '0';
        wait for 40 ns;

        -- 5. Tentativa de entrada enquanto BLOQUEADA (Não deve liberar)
        sensor_cartao <= '1';
        wait for 10 ns;
        sensor_cartao <= '0';
        wait for 40 ns;

        -- 6. Reset de manutenção (Desbloqueia)
        reset_cont <= '1';
        wait for 10 ns;
        reset_cont <= '0';
        
        wait;
    end process;

end Behavioral;
