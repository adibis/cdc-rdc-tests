create_clock -name fc -period 2.0 [get_ports fc]
create_clock -name sc -period 20.0 [get_ports sc]
set_input_delay -clock fc 1.0 [get_ports en]
