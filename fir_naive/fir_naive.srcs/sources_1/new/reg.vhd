----------------------------------------------------------------------
-- Project 1: FIR Filter
-- 24 bit register
-- Kevin Sheng
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------

entity reg is
    port (a: in std_logic_vector(23 downto 0);
          z: out std_logic_vector(23 downto 0);
          clk: in std_logic;
          rst: in std_logic
    );
end entity reg;

architecture behavioral of reg is
    signal stored: std_logic_vector(23 downto 0); 
begin
    clock: process (rst, clk)
    begin
        if (rst = '1') then
            stored <= (stored'range => '0');
        elsif (clk'event and clk = '1') then
            stored <= a;
        end if;
    end process;
    
    z <= stored;
    
end architecture behavioral;
