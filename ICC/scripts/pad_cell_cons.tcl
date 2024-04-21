# Create corners and P/G pads
create_cell {CornerLL CornerLR CornerTR CornerTL} PCORNERW
create_cell {vss1_l vss1_r vss1_r1 vss1_t vss1_b} PVSS1W
create_cell {vdd1_l vdd1_r vdd1_r1 vdd1_t vdd1_b} PVDD1W
create_cell {vss2_l vss2_r vss2_r1 vss2_t vss2_b} PVSS2W
create_cell {vdd2_l vdd2_r vdd2_r1 vdd2_t vdd2_b} PVDD2W

# Define corner pad locations
set_pad_physical_constraints -pad_name "CornerTL" -side 1
set_pad_physical_constraints -pad_name "CornerTR" -side 2
set_pad_physical_constraints -pad_name "CornerLR" -side 3
set_pad_physical_constraints -pad_name "CornerLL" -side 4

# Define signal and PG pad locations

# Left side
set_pad_physical_constraints -pad_name "PIW_pe_enable0" -side 1 -order 1
set_pad_physical_constraints -pad_name "PIW_pe_enable1" -side 1 -order 2
set_pad_physical_constraints -pad_name "PIW_pe_enable2" -side 1 -order 3
set_pad_physical_constraints -pad_name "PIW_pe_enable3" -side 1 -order 4
set_pad_physical_constraints -pad_name "PIW_pe_enable4" -side 1 -order 5
set_pad_physical_constraints -pad_name "vdd2_l" -side 1 -order 6
set_pad_physical_constraints -pad_name "vdd1_l" -side 1 -order 7
set_pad_physical_constraints -pad_name "vss1_l" -side 1 -order 8
set_pad_physical_constraints -pad_name "vss2_l" -side 1 -order 9
set_pad_physical_constraints -pad_name "PIW_pe_enable5" -side 1 -order 10
set_pad_physical_constraints -pad_name "PIW_pe_enable6" -side 1 -order 11
set_pad_physical_constraints -pad_name "PIW_pe_enable7" -side 1 -order 12

# Top side
set_pad_physical_constraints -pad_name "PO8W_pe_task_receive_finish_flag0" -side 2 -order 1
set_pad_physical_constraints -pad_name "PO8W_pe_task_receive_finish_flag1" -side 2 -order 2
set_pad_physical_constraints -pad_name "PO8W_pe_task_receive_finish_flag2" -side 2 -order 3
set_pad_physical_constraints -pad_name "PO8W_pe_task_receive_finish_flag3" -side 2 -order 4
set_pad_physical_constraints -pad_name "PO8W_pe_task_receive_finish_flag4" -side 2 -order 5
set_pad_physical_constraints -pad_name "vdd2_t" -side 2 -order 6
set_pad_physical_constraints -pad_name "vdd1_t" -side 2 -order 7
set_pad_physical_constraints -pad_name "vss1_t" -side 2 -order 8
set_pad_physical_constraints -pad_name "vss2_t" -side 2 -order 9
set_pad_physical_constraints -pad_name "PO8W_pe_task_receive_finish_flag5" -side 2 -order 10
set_pad_physical_constraints -pad_name "PO8W_pe_task_receive_finish_flag6" -side 2 -order 11
set_pad_physical_constraints -pad_name "PO8W_pe_task_receive_finish_flag7" -side 2 -order 12
# Right side
set_pad_physical_constraints -pad_name "PO8W_pe_task_send_finish_flag0" -side 3 -order 1
set_pad_physical_constraints -pad_name "vdd2_r1" -side 3 -order 2
set_pad_physical_constraints -pad_name "vdd1_r1" -side 3 -order 3
set_pad_physical_constraints -pad_name "vss1_r1" -side 3 -order 4
set_pad_physical_constraints -pad_name "vss2_r1" -side 3 -order 5
set_pad_physical_constraints -pad_name "PO8W_pe_task_send_finish_flag1" -side 3 -order 6
set_pad_physical_constraints -pad_name "PO8W_pe_task_send_finish_flag2" -side 3 -order 7
set_pad_physical_constraints -pad_name "PO8W_pe_task_send_finish_flag3" -side 3 -order 8
set_pad_physical_constraints -pad_name "PO8W_pe_task_send_finish_flag4" -side 3 -order 9
set_pad_physical_constraints -pad_name "vdd2_r" -side 3 -order 10
set_pad_physical_constraints -pad_name "vdd1_r" -side 3 -order 11
set_pad_physical_constraints -pad_name "vss1_r" -side 3 -order 12
set_pad_physical_constraints -pad_name "vss2_r" -side 3 -order 13
set_pad_physical_constraints -pad_name "PO8W_pe_task_send_finish_flag5" -side 3 -order 14
set_pad_physical_constraints -pad_name "PO8W_pe_task_send_finish_flag6" -side 3 -order 15
set_pad_physical_constraints -pad_name "PO8W_pe_task_send_finish_flag7" -side 3 -order 16

# Bottom side
set_pad_physical_constraints -pad_name "PIW_clk" -side 4 -order 1
set_pad_physical_constraints -pad_name "vdd2_b" -side 4 -order 2
set_pad_physical_constraints -pad_name "vdd1_b" -side 4 -order 3
set_pad_physical_constraints -pad_name "vss1_b" -side 4 -order 4
set_pad_physical_constraints -pad_name "vss2_b" -side 4 -order 5
set_pad_physical_constraints -pad_name "PIW_rst_n" -side 4 -order 6
