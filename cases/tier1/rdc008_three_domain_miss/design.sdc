create_clock -name ca -period 10.0 [get_ports ca]
create_clock -name cb -period 7.0 [get_ports cb]
create_clock -name cc -period 5.0 [get_ports cc]
set_clock_groups -asynchronous -group {ca} -group {cb} -group {cc}
set_input_delay -clock ca 1.0 [get_ports rst]
set_input_delay -clock ca 1.0 [get_ports da]
set_input_delay -clock cb 1.0 [get_ports db]
set_input_delay -clock cc 1.0 [get_ports dc]
