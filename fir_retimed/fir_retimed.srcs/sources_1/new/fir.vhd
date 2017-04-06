----------------------------------------------------------------------
-- Project 1: FIR Filter
-- Retimed FIR filter, systolic with pipelined multipliers
-- Kevin Sheng
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------

entity fir is
    port (x: in std_logic_vector(23 downto 0);
          y: out std_logic_vector(23 downto 0);
          clk: in std_logic;
          rst: in std_logic
    );
end entity fir;

architecture structural of fir is
    component reg is
        port (a: in std_logic_vector(23 downto 0);
              z: out std_logic_vector(23 downto 0);
              clk: in std_logic;
              rst: in std_logic
        );
    end component reg;
    
    component reg48 is
        port (a: in std_logic_vector(47 downto 0);
              z: out std_logic_vector(47 downto 0);
              clk: in std_logic;
              rst: in std_logic
        );
    end component reg48;
    
    component adder is
        port (a: in std_logic_vector(47 downto 0);
              b: in std_logic_vector(47 downto 0);
              z: out std_logic_vector(47 downto 0);
              rst: in std_logic
        );
    end component adder;
    
    component multiplier is
        port (a: in std_logic_vector(23 downto 0);
              b: in std_logic_vector(23 downto 0);
              z: out std_logic_vector(47 downto 0);
              rst: in std_logic
        );
    end component multiplier;
    
    component truncator is
        port (a: in std_logic_vector(47 downto 0);
              z: out std_logic_vector(23 downto 0);
              rst: in std_logic
        );
    end component truncator;
    
    -- Fixed point symmetric FIR filter coefficients, 24 bit Q1.23
    
    type delays_t is array (14 downto 0) of std_logic_vector(23 downto 0);
    type delays_full_t is array (14 downto 0) of std_logic_vector(47 downto 0);
    type taps_t is array (15 downto 0) of std_logic_vector(23 downto 0);
    type arith_t is array (15 downto 0) of std_logic_vector(47 downto 0);
    
    signal b: taps_t := ("000000010000111101100110",
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
                         

    signal delays1: delays_t;
    signal delays2: delays_t;
    signal delays3: delays_full_t;
    signal delays4: delays_full_t;
    signal products: arith_t;
    signal sums: arith_t;
    
begin
    gen_taps: for i in 0 to 15 generate
        
        -- Handle first multiply and sum
        first_tap: if (i = 0) generate
            MULT0: multiplier port map (a => x, b => b(i), z => products(i), rst => rst);
            ADD0: adder port map (a => products(i), b => (others => '0'), z => sums(i), rst => rst);
        end generate first_tap;
        
        -- Handle initial conditions for delay registers
        second_tap: if (i = 1) generate
            DLY1: reg port map (a => x, z => delays1(i-1), clk => clk, rst => rst);
            DLY2: reg port map (a => delays1(i-1), z => delays2(i-1), clk => clk, rst => rst);
            MULT1: multiplier port map (a => delays2(i-1), b => b(i), z => products(i), rst => rst);
            DLY3: reg48 port map (a => products(i), z => delays3(i-1), clk => clk, rst => rst);
            ADD1: adder port map (a => sums(i-1), b => delays3(i-1), z => sums(i), rst => rst);
            DLY4: reg48 port map (a => sums(i), z => delays4(i-1), clk => clk, rst => rst);
        end generate second_tap;
        
        -- Each generate statement is a section of the fir filter
        other_taps: if (i > 1) generate
            DLY1N: reg port map (a => delays2(i-2), z => delays1(i-1), clk => clk, rst => rst);
            DLY2N: reg port map (a => delays1(i-1), z => delays2(i-1), clk => clk, rst => rst);                                                 
            MULTN: multiplier port map (a => delays2(i-1), b => b(i), z => products(i), rst => rst);
            DLY3N: reg48 port map (a => products(i), z => delays3(i-1), clk => clk, rst => rst);
            ADDN: adder port map (a => delays4(i-2), b => delays3(i-1), z => sums(i), rst => rst);
            DLY4N: reg48 port map (a => sums(i), z => delays4(i-1), clk => clk, rst => rst);
        end generate other_taps;
        
    end generate gen_taps;
    
    TRUNC: truncator port map (a => delays4(14), z => y, rst => rst);
    
end architecture structural;
