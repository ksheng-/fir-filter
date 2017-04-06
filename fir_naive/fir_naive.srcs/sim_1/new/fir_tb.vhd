----------------------------------------------------------------------
-- Test Bench for FIR filter project
-- Kevin Sheng
----------------------------------------------------------------------

library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


----------------------------------------------------------------------

entity fir_tb is
end entity fir_tb;

architecture testbench of fir_tb is
    signal x_test : std_logic_vector(23 downto 0);
    signal y_test : std_logic_vector(23 downto 0);
    signal clock  : std_logic := '1';
    signal reset  : std_logic := '1';
    
    component fir is
        port (x   : in std_logic_vector(23 downto 0);
              y   : out std_logic_vector(23 downto 0); 
              clk : in std_logic;
              rst : in std_logic
        );
    end component;
    
begin
        UUT: fir port map (x => x_test, y => y_test, clk => clock, rst => reset);
        
        clock <= not clock after 5 ns;

        process
            file x_file: text is in "input.txt";
            file y_file: text is in "output.txt";
            variable x_line: line;
            variable y_line: line;
            variable x_vec: bit_vector(23 downto 0);
            variable y_vec: bit_vector(23 downto 0);
        begin
            reset <= '0';
            while not endfile(x_file) or endfile(x_file) loop
                readline(x_file, x_line);
                read(x_line, x_vec);
                x_test <= to_stdlogicvector(x_vec);
                
                wait for 10 ns;   
                
                readline(y_file, y_line);
                read(y_line, y_vec);
                assert y_test = to_stdlogicvector(y_vec)
                report "Error: Incorrect Output"
                severity error;        
                
                     
            end loop;
            
            reset <= '1';
            
        end process;
end architecture testbench;
