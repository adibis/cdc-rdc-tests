# SDC subset

Cases declare their timing context in `design.sdc` using five
commands, always in the shapes below. A foreign checker needs
no full SDC parser: anything outside these forms never appears.

`create_clock -name <id> -period <ns> [get_ports <port>]`
declares a root clock on an input port. Every case with two
or more clock ports uses it; periods ground ratio checks
(CDC-013) and nothing else.

`create_generated_clock -name <id> -source <clk> -divide_by <n>
[get_nets <net> | get_pins <pin>]` declares a divided clock.
Only `-divide_by` appears; the target is a net or a flop
output pin.

`set_clock_groups -asynchronous -group {..} -group {..}`
marks the groups pairwise asynchronous. No other group kind
appears; absence of the command means related clocks.

`set_input_delay -clock <clk> <ns> [get_ports <port>]` types
an input port into the named clock's domain. Untyped inputs
carry no domain and trip the port rules instead.

`set_output_delay -clock <clk> <ns> [get_ports <port>]` types
an output port the same way. Rare: one case uses it.

Some cases omit `design.sdc` entirely; there the checker must
derive clocks from the RTL alone.
