
analyze -format verilog ../rtl/global.v

analyze -format verilog ../rtl/router/ram_8x32.v
analyze -format verilog ../rtl/router/sync_fifo_8x32.v

analyze -format verilog ../rtl/router/input_unit.v

analyze -format verilog ../rtl/router/data_transfer.v

analyze -format verilog ../rtl/router/out_unit_3port.v

analyze -format verilog ../rtl/router/router_compute_3port.v

analyze -format verilog ../rtl/router/switch_allocation_3port.v

analyze -format verilog ../rtl/router/flow_control_3port.v

analyze -format verilog ../rtl/router/router_border.v
analyze -format verilog ../rtl/router/router_border_chip.v
elaborate router_border_chip

