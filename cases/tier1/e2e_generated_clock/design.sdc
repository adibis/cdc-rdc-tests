create_clock -name clk -period 10.0 [get_ports clk]
create_generated_clock -name div -source clk -divide_by 2 [get_nets div]
set_input_delay -clock clk 1.0 [get_ports d]
