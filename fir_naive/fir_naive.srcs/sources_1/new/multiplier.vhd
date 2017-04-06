----------------------------------------------------------------------
-- Project 1: FIR Filter
-- Full precision 24 bit multiplier component
-- Takes 2 24 bit Q1.23 inputs and outputs Q1.47 product
-- Kevin Sheng
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------

entity multiplier is
    port (a: in std_logic_vector(23 downto 0);
          b: in std_logic_vector(23 downto 0);
          z: out std_logic_vector(47 downto 0);
          rst: in std_logic
    );
end entity multiplier;

architecture behavioral of multiplier is
begin
    process (a, b, rst)
    begin
        if rst = '1' then
            z <= (others => '0');
        else
            z <= std_logic_vector(shift_left(unsigned(signed(a) * signed(b)), 1));
        end if;
    end process;
end architecture behavioral;
