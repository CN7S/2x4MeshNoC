
analyze -format verilog ../rtl/PE/PE.v
analyze -format verilog ../rtl/PE/PE_single.v

analyze -format verilog ../rtl/PE/PE_chip.v
elaborate PE_chip
