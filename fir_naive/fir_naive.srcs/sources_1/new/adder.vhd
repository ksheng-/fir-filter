----------------------------------------------------------------------
-- Project 1: FIR Filter
-- 48 bit internal adder component
-- Adds all the Q1.47 products of the FIR filter.
-- Kevin Sheng
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------

entity adder is
    port (a: in std_logic_vector(47 downto 0);
          b: in std_logic_vector(47 downto 0);
          z: out std_logic_vector(47 downto 0);
          rst: in std_logic
    );
end entity adder;

architecture behavioral of adder is
begin
    process (a, b, rst)
    begin
        if rst = '1' then
            z <= (others => '0');
        else
            z <= std_logic_vector(signed(a) + signed(b));
        end if;
    end process;
end architecture behavioral;

