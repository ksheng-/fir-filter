create_clock -period 20.833 -name clk -waveform {0.000 10.417} [get_ports clk]
set_input_delay -clock [get_clocks clk] -min -add_delay 4.000 [get_ports {x[*]}]
set_input_delay -clock [get_clocks clk] -max -add_delay 4.000 [get_ports {x[*]}]
set_input_delay -clock [get_clocks clk] -min -add_delay 4.000 [get_ports rst]
set_input_delay -clock [get_clocks clk] -max -add_delay 4.000 [get_ports rst]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {y[*]}]
set_output_delay -clock [get_clocks clk] -max -add_delay 4.000 [get_ports {y[*]}]

