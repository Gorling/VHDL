library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity catraca_eletronica is
    Generic (
        MAX_PESSOAS : integer := 5  -- Limite para bloqueio automático (exemplo baixo para simulação)
    );
    Port ( 
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC; -- Reset global
        sensor_cartao : in  STD_LOGIC; -- Sinal quando usuário aproxima crachá
        sensor_giro   : in  STD_LOGIC; -- Sinal quando a catraca gira (pessoa passou)
        reset_cont    : in  STD_LOGIC; -- Botão para zerar a contagem e desbloquear
        
        -- Saídas
        solenoide     : out STD_LOGIC; -- 0: Travada, 1: Destravada
        led_vermelho  : out STD_LOGIC; -- Indica estado BLOQUEADA ou FECHADA
        led_verde     : out STD_LOGIC; -- Indica estado LIBERADA
        contagem_out  : out STD_LOGIC_VECTOR(7 downto 0) -- Mostra contagem binária (para LEDs ou Display)
    );
end catraca_eletronica;

architecture Behavioral of catraca_eletronica is

    -- Definição dos Estados
    type t_estado is (FECHADA, LIBERADA, BLOQUEADA);
    signal estado_atual, proximo_estado : t_estado;

    -- Sinal interno para contagem
    signal contador : integer range 0 to 255 := 0;

begin

    -- ==========================================
    -- PROCESSO 1: Sincronização e Atualização de Estado
    -- ==========================================
    process(clk, reset)
    begin
        if reset = '1' then
            estado_atual <= FECHADA;
            contador <= 0;
        elsif rising_edge(clk) then
            estado_atual <= proximo_estado;
            
            -- Lógica do Contador (Síncrona)
            if reset_cont = '1' then
                contador <= 0;
            elsif estado_atual = LIBERADA and sensor_giro = '1' then
                -- Incrementa apenas quando a pessoa efetivamente passa
                if contador < 255 then
                    contador <= contador + 1;
                end if;
            end if;
        end if;
    end process;

    -- ==========================================
    -- PROCESSO 2: Lógica Combinacional (Próximo Estado)
    -- ==========================================
    process(estado_atual, sensor_cartao, sensor_giro, contador, reset_cont)
    begin
        -- Valores padrão para evitar latches
        proximo_estado <= estado_atual;
        
        case estado_atual is
            
            when FECHADA =>
                -- Se contador atingiu o limite, vai direto para bloqueada
                if contador >= MAX_PESSOAS then
                    proximo_estado <= BLOQUEADA;
                -- Se passou cartão e não está lotado, libera
                elsif sensor_cartao = '1' then
                    proximo_estado <= LIBERADA;
                else
                    proximo_estado <= FECHADA;
                end if;

            when LIBERADA =>
                -- Se a pessoa girou a catraca, volta a fechar
                if sensor_giro = '1' then
                    -- Verifica imediatamente se atingiu o limite para decidir o próximo
                    if (contador + 1) >= MAX_PESSOAS then
                        proximo_estado <= BLOQUEADA;
                    else
                        proximo_estado <= FECHADA;
                    end if;
                else
                    proximo_estado <= LIBERADA;
                end if;

            when BLOQUEADA =>
                -- Só sai do bloqueio se houver um reset específico de contagem/manutenção
                if reset_cont = '1' then
                    proximo_estado <= FECHADA;
                else
                    proximo_estado <= BLOQUEADA;
                end if;

            when others =>
                proximo_estado <= FECHADA;
        end case;
    end process;

    -- ==========================================
    -- Lógica de Saída (Moore/Mealy misto para resposta rápida)
    -- ==========================================
    
    -- Solenoide: Só ativa (destrava) se estiver LIBERADA
    solenoide <= '1' when estado_atual = LIBERADA else '0';

    -- LEDs indicadores
    led_verde    <= '1' when estado_atual = LIBERADA else '0';
    led_vermelho <= '1' when (estado_atual = FECHADA or estado_atual = BLOQUEADA) else '0';

    -- Saída do contador convertida para vetor lógico
    contagem_out <= std_logic_vector(to_unsigned(contador, 8));

end Behavioral;
