----------------------------------------------------------------------
-- Project 1: FIR Filter
-- Behavioral reference implementation
-- Kevin Sheng
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------

entity fir is
    port (x: in std_logic_vector(23 downto 0);
          y: out std_logic_vector(23 downto 0);
          clk: in std_logic
    );
end entity fir;

architecture rtl of fir is

    type arr16_24 is array (15 downto 0) of std_logic_vector(23 downto 0);
    type arr16_48 is array (15 downto 0) of std_logic_vector(47 downto 0);
    
    -- Filter taps
    constant ntaps: integer := 16;
    -- DAC resolution on Zedboard
    constant nbits: integer := 24;
    
    -- Fixed point symmetric FIR filter coefficients, 24 bit Q1.23
    signal b: arr16_24 := ("000000010000111101100110",
                           "000000011010101110000100",   
                           "000000110110000100001001",
                           "000001011111111100000101",
                           "000010010001110010101011",
                           "000011000010110110110001",
                           "000011101001111111011011",
                           "000011111111101011010000",
                           "000011111111101011010000",
                           "000011101001111111011011",
                           "000011000010110110110001",
                           "000010010001110010101011",
                           "000001011111111100000101",
                           "000000110110000100001001",
                           "000000011010101110000100",
                           "000000010000111101100110"); 
    
    signal xn: arr16_24 := (others => "000000000000000000000000");
    --signal sum: arr16_48 := (others => "000000000000000000000000000000000000000000000000");
    --signal sum_truncated: arr16_24 := (others => "000000000000000000000000");
    signal product: arr16_48 := (others => "000000000000000000000000000000000000000000000000");
    signal product_rounded: arr16_48 := (others => "000000000000000000000000000000000000000000000000");
    signal product_truncated: arr16_24 := (others => "000000000000000000000000");
    
begin
    step: process(clk)
    begin
        if (clk'event and clk = '1') then
            for i in ntaps-1 downto 1 loop
                -- Clock in Q1.23 input
                xn(i) <= xn(i-1);
            end loop;
            xn(0) <= x;
        end if;     
    end process step;
    
    mult: process(xn)
    begin
        for i in 0 to ntaps-1 loop
            -- Q2.46 product, shift left to remove redundant signed bit results in Q1.47
            product(i) <= std_logic_vector(shift_left(unsigned(signed(xn(i)) * signed(b(i))), 1));
        end loop;
    end process mult;
    
    add: process(product)
        variable sum: std_logic_vector(47 downto 0) := (others => '0');
        constant roundbit: signed(47 downto 0) := (23 => '1', others => '0');
    begin
        for i in 0 to ntaps-1 loop
            if (i = 0) then
                sum := product(i);
            else
                -- No need to saturate, output is guaranteed to be Q1.23 since the filter is unity gain
                -- Twos complement intermediate overflow property
                sum := std_logic_vector(signed(product(i)) + signed(sum));
            end if;
        end loop;    
        -- Round by adding 1 to the bit after the truncation point.
        -- Rounds to nearest, and towards infinity on ties. 
        sum := std_logic_vector(roundbit + signed(sum));
        -- Output truncated accumulated sum
        y <= sum(47 downto 24);
    end process add;
    
    -- Rounding and trucating functions, removedto match matlab 'Floor' output.
    
    --    round: process(product)
    --        constant roundbit: signed(47 downto 0) := (23 => '1', others => '0');
    --    begin
    --        for i in 0 to ntaps-1 loop
    --            -- Round by adding bit after truncation point
    --            -- Round to nearest, on ties round up
    --            product_rounded(i) <= std_logic_vector(signed(product(i)) + roundbit);
    --        end loop;
    --    end process round;
        
    --    trunc: process(product)
    --    begin
    --        for i in 0 to ntaps-1 loop
    --            -- Truncate to prevent bit growth
    --            product_truncated(i) <= product(i)(47 downto 24);
    --        end loop;
    --    end process trunc;

end architecture rtl;
