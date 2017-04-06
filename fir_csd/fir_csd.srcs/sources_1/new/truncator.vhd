----------------------------------------------------------------------
-- Project 1: FIR Filter
-- Truncator component
-- Rounds to nearest and towards infinity on ties by adding 1 to the 
-- bit after the truncation point
-- Kevin Sheng
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------

entity truncator is
    port (a: in std_logic_vector(47 downto 0);
          z: out std_logic_vector(23 downto 0);
          rst: in std_logic
    );
end entity truncator;

architecture behavioral of truncator is
    signal rounded: std_logic_vector(47 downto 0);
    constant roundbit: signed(47 downto 0) := (23 => '1', others => '0');
begin
    process (a, rst)
    begin
        if rst = '1' then
            rounded <= (others => '0');
        else
            rounded <= std_logic_vector(roundbit + signed(a));
        end if;
    end process;

    z <= rounded(47 downto 24);
    
end architecture behavioral;
