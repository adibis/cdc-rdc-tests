create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay -clock clk 1.0 [get_ports rsta]
set_input_delay -clock clk 1.0 [get_ports rstb]
set_input_delay -clock clk 1.0 [get_ports d]
