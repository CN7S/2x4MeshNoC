## PROBLEM

1. after signal 'task_send_finish_flag' become 1, signal 'p2r_valid' still can be 1.

    Error estimate: p2r_valid can be 1 when 'full' is 1 after send task end.

2. signal 'start' can lead flush work to not be stopped at PE No.0.
