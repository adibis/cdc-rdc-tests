create_clock -name ca -period 10 [get_ports ca]
set_input_delay -clock ca 1.0 [get_ports d]
