create_clock -name ca -period 10.0 [get_ports ca]
create_clock -name virt -period 10.0
set_input_delay -clock ca 1.0 [get_ports d]
set_output_delay -clock virt 1.0 [get_ports q]
