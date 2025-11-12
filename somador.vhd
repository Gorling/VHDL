library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity somador is
    Port ( 
        a    : in  STD_LOGIC_VECTOR(1 downto 0);
        b    : in  STD_LOGIC_VECTOR(1 downto 0);
        soma : out STD_LOGIC_VECTOR(2 downto 0)
    );
end somador;

architecture Behavioral of somador is
begin
    soma <= std_logic_vector(unsigned('0' & a) + unsigned('0' & b));
end Behavioral;
