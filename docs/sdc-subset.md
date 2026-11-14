# SDC subset

Cases declare their timing context in `design.sdc` using five
commands, always in the shapes below. A foreign checker needs
no full SDC parser: anything outside these forms never appears.

`create_clock -name <id> -period <ns> [get_ports <port>]`
declares a root clock, usually on an input port; three cases
declare port-less virtual clocks the same way. Periods ground
ratio checks (CDC-009, CDC-013) and nothing else.

`create_generated_clock -name <id> -source <clk> -divide_by <n>
[get_nets <net> | get_pins <pin>]` declares a divided clock.
Only `-divide_by` appears; the target is a net or a flop
output pin.

`set_clock_groups -asynchronous -group {..} -group {..}
[-group {..}]` marks the groups pairwise asynchronous. Most
cases use two groups; six use three. No other group kind
appears; absence of the command means related clocks, as in
timing analysis. A crossing between related clocks is a timed
path: metastability rules stay silent on it, while ratio rules
(CDC-009, CDC-013) still apply. `cdc001_boundary_fire` and
`cdc001_boundary_related_quiet` pin the difference.

`set_input_delay -clock <clk> <ns> [get_ports <port>]` types
an input port into the named clock's domain. Untyped inputs
carry no domain and trip the port rules instead.

`set_output_delay -clock <clk> <ns> [get_ports <port>]` types
an output port the same way. Rare: two cases use it.

Every case ships `design.sdc`, but two ship it empty: one
zero-byte file, one comments only (`#` introduces a comment).
There the checker derives clocks from the RTL alone.
