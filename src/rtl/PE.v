//Copyright [2024/2/16] [author: SJTUME208 / owner: DIC course 2024]
//written by Xie Lin 

`define DATA_SIZE 16
`define DATA_SIZE_0 15
`define TIME_SIZE 8
`define TIME_SIZE_0 7
`define TIME_SUM_SIZE 24
`define TIME_SUM_SIZE_0 23
`define ID_SIZE 3
`define ID_SIZE_0 2
`define ROUTER_NUM 8
`define ROUTER_NUM_0 6
`define LOG_ROUTER_NUM 3
`define LOG_ROUTER_NUM_0 2
`define ROUTER_WIDTH_0 23// ID_SIZE * ROUTER_NUM - 1

`define DST_MIN 0
`define DST_MAX 2
`define SRC_MIN 3
`define SRC_MAX 5
`define TYPE_MIN 6
`define TYPE_MAX 7
`define TIME_MIN 8
`define TIME_MAX 15
`define DATA_MIN 16
`define DATA_MAX 31

`define DATA_WIDTH_NOR 16
`define DATA_WIDTH_DBG 8


module PE#(
    parameter MY_ID = 3'b000,
    parameter ONE_ID = 3'b001,
    parameter TWO_ID = 3'b010,
    parameter THR_ID = 3'b011,
    parameter FOU_ID = 3'b100,
    parameter FIV_ID = 3'b101,
    parameter SIX_ID = 3'b110,
    parameter SEV_ID = 3'b111
    )(
    input wire                          enable_wire,
    input wire                          dbg_mode_wire,
    input wire[`LOG_ROUTER_NUM_0:0]     send_num_wire,//must be a multiple of mode
    input wire[`LOG_ROUTER_NUM_0:0]     receive_num_wire,
    input wire[3:0]                     rate_wire,
    input wire[`ROUTER_WIDTH_0:0]       dst_seq_wire,//dst cannot repeat-----aabaab is not valid
    input wire[`LOG_ROUTER_NUM:0]       mode_wire,
    input wire                          flush_wire,

    output reg                          task_send_finish_flag,
    output reg                          task_receive_finish_flag,

    output wire[`ROUTER_NUM_0:0]                        so_retrsreq_receive_flag,
    output wire[`ROUTER_NUM_0:0]                        so_retrsreq_send_flag,
    output reg[7:0]                                     so_retrsreq_receive_num,
    output reg[7:0]                                     so_retrsreq_send_num,
    output reg[`TIME_SIZE_0:0]                          latency_min,
    output reg[`TIME_SIZE_0:0]                          latency_max,
    output reg[`TIME_SUM_SIZE_0 + `LOG_ROUTER_NUM:0]    latency_sum,

    output reg[`DATA_MAX:0]     data_p2r,
    output reg                  valid_p2r,
    input wire[`DATA_MAX:0]     data_r2p,
    input wire                  valid_r2p,
    input                       full,

    input wire                  rst_n,
    input wire                  clk
    );

// PARAMETER
    //for retry request
    parameter RETRY_REQ = 2'b00;
    parameter RETRY_BAG = 2'b11;
    parameter NORMAL_BAG = 2'b01;
    parameter DEFAULT_TYPE = 2'b00;

    //for latency counting
    parameter LATENCY_MAX = {`TIME_SIZE{1'b1}};
    parameter LATENCY_MIN = {`TIME_SIZE{1'b0}};
    parameter LATENCY_SUM = {(`TIME_SUM_SIZE + `LOG_ROUTER_NUM){1'b0}};

// VARIABLE APPLY
    //arrange input
//
    reg                         enable;
    reg                         dbg_mode;
    reg[`LOG_ROUTER_NUM_0:0]    send_num;//must be a multiple of mode
    reg[`LOG_ROUTER_NUM_0:0]    receive_num;
    reg[3:0]                    rate;
    reg[`ROUTER_WIDTH_0:0]      dst_seq;//dst cannot repeat-----aabaab is not valid
    reg[`LOG_ROUTER_NUM:0]      mode;
    reg                         flush;
    reg                         start;
//
    //basic flags
//
    reg valid_in_flag;
    reg normal_in_flag;
    reg request_in_flag;
    reg retrans_in_flag;

    reg[`TIME_MAX - `SRC_MIN:0] data_in_des_buf;

    wire all_receive_flag_001;
    wire all_receive_flag_010;
    wire all_receive_flag_011;
    wire all_receive_flag_100;
    wire all_receive_flag_101;
    wire all_receive_flag_110;
    wire all_receive_flag_111;
//
    //retrs
    wire so_retrsreq_receive_num_001;
    wire so_retrsreq_receive_num_010;
    wire so_retrsreq_receive_num_011;
    wire so_retrsreq_receive_num_100;
    wire so_retrsreq_receive_num_101;
    wire so_retrsreq_receive_num_110;
    wire so_retrsreq_receive_num_111;

    wire so_retrsreq_send_num_001;
    wire so_retrsreq_send_num_010;
    wire so_retrsreq_send_num_011;
    wire so_retrsreq_send_num_100;
    wire so_retrsreq_send_num_101;
    wire so_retrsreq_send_num_110;
    wire so_retrsreq_send_num_111;
    //latency
//
    reg[`TIME_SIZE_0:0] time_stamp;
    reg[`TIME_SIZE_0:0] latency_diff;
//'
    //data receive miss----send_num
//
    reg                         data_miss;
    reg                         long_time;
    wire[`ROUTER_NUM_0:0]       data_miss_counter;
    wire[`ROUTER_NUM_0:0]       long_time_counter;
    reg[`LOG_ROUTER_NUM_0:0]    data_miss_sum;
    reg[`LOG_ROUTER_NUM_0:0]    long_time_sum;

    wire[`DATA_SIZE_0:0] seq_counter_001;
    wire[`DATA_SIZE_0:0] seq_counter_010;
    wire[`DATA_SIZE_0:0] seq_counter_011;
    wire[`DATA_SIZE_0:0] seq_counter_100;
    wire[`DATA_SIZE_0:0] seq_counter_101;
    wire[`DATA_SIZE_0:0] seq_counter_110;
    wire[`DATA_SIZE_0:0] seq_counter_111;
    //data tag
    wire[`DATA_SIZE_0:0] diff_counter_001;
    wire[`DATA_SIZE_0:0] diff_counter_010;
    wire[`DATA_SIZE_0:0] diff_counter_011;
    wire[`DATA_SIZE_0:0] diff_counter_100;
    wire[`DATA_SIZE_0:0] diff_counter_101;
    wire[`DATA_SIZE_0:0] diff_counter_110;
    wire[`DATA_SIZE_0:0] diff_counter_111;

    wire[`TIME_SIZE_0:0] receive_time_counter_001;
    wire[`TIME_SIZE_0:0] receive_time_counter_010;
    wire[`TIME_SIZE_0:0] receive_time_counter_011;
    wire[`TIME_SIZE_0:0] receive_time_counter_100;
    wire[`TIME_SIZE_0:0] receive_time_counter_101;
    wire[`TIME_SIZE_0:0] receive_time_counter_110;
    wire[`TIME_SIZE_0:0] receive_time_counter_111;
//
    //send miss
//
    reg retrans_flag;

    wire[`DATA_SIZE_0:0] retrans_counter_001;
    wire[`DATA_SIZE_0:0] retrans_counter_010;
    wire[`DATA_SIZE_0:0] retrans_counter_011;
    wire[`DATA_SIZE_0:0] retrans_counter_100;
    wire[`DATA_SIZE_0:0] retrans_counter_101;
    wire[`DATA_SIZE_0:0] retrans_counter_110;
    wire[`DATA_SIZE_0:0] retrans_counter_111;
//
    //receive finish
//
    reg[`ID_SIZE_0:0] sum;
//
    //control valid rate
//
    reg[3:0] rate_out_counter;
    reg valid_enable;
//
    //output enable flags
//
    reg request_out_flag;
    reg retrans_out_flag;
    reg normal_out_flag;//not consider request & retrans
    reg hold_out_flag;
//
    //send finish
//
    reg[`ID_SIZE_0:0] send_num_counter;
//
    //dst
//
    reg[`ID_SIZE_0:0] normal_flag_dst;
    reg[`ID_SIZE_0:0] request_dst;
    reg[`ID_SIZE_0:0] retrans_dst;
    reg[`ID_SIZE_0:0] normal_dst;
//
    //data tag
//
    reg[`DATA_SIZE_0:0] normal_counter; //13位
//

// ARRANGE INPUT
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            enable <= 1'b0;
            flush <= 1'b0;
        end
        else begin
            enable <= enable_wire;
            flush <= flush_wire;
        end
    end

    always @(posedge clk) begin
        send_num <= send_num_wire;
        receive_num <= receive_num_wire;
        dbg_mode <= dbg_mode_wire;
        rate <= rate_wire;
        dst_seq <= dst_seq_wire;
        mode <= mode_wire;
    end

// 001
    PE_single #(
    .MY_ID(MY_ID),
    .TAR_ID(ONE_ID),

    //for retry request
    .NORMAL_BAG(NORMAL_BAG)
    ) PE_single_001(
    .dbg_mode(dbg_mode),
    .enable(enable),
    .data_r2p(data_r2p),
    .valid_r2p(valid_r2p),
    .data_p2r({data_p2r[`SRC_MAX:`SRC_MIN], data_p2r[`DST_MAX:`DST_MIN]}),
    .valid_p2r(valid_p2r),
    //basic flags
    .valid_in_flag(valid_in_flag),
    .normal_in_flag(normal_in_flag),
    .request_in_flag(request_in_flag),
    .retrans_in_flag(retrans_in_flag),
    .task_send_finish_flag(task_send_finish_flag),
    .data_in_des_buf(data_in_des_buf),
    .all_receive_flag(all_receive_flag_001),

    //data receive miss
    .long_time(long_time),
    .seq_counter(seq_counter_001),
    .diff_counter(diff_counter_001),
    .receive_time_counter(receive_time_counter_001),
    .data_miss_flag(data_miss_counter[0]),
    .long_time_flag(long_time_counter[0]),
    .so_retrsreq_send_num(so_retrsreq_send_num_001),
    .so_retrsreq_send_flag(so_retrsreq_send_flag[0]),

    //send miss
    .retrans_counter(retrans_counter_001),
    .so_retrsreq_receive_num(so_retrsreq_receive_num_001),
    .so_retrsreq_receive_flag(so_retrsreq_receive_flag[0]),

    //output flags
    .request_out_flag(request_out_flag),
    .retrans_out_flag(retrans_out_flag),
    .hold_out_flag(hold_out_flag),

    //dst
    .request_dst(request_dst),
    .retrans_dst(retrans_dst),

    .clk(clk),
    .rst_n(rst_n)
    );
// 010
    PE_single #(
    .MY_ID(MY_ID),
    .TAR_ID(TWO_ID),

    //for retry request
    .NORMAL_BAG(NORMAL_BAG)
    ) PE_single_010(
    .dbg_mode(dbg_mode),
    .enable(enable),
    .data_r2p(data_r2p),
    .valid_r2p(valid_r2p),
    .data_p2r({data_p2r[`SRC_MAX:`SRC_MIN], data_p2r[`DST_MAX:`DST_MIN]}),
    .valid_p2r(valid_p2r),
    //basic flags
    .valid_in_flag(valid_in_flag),
    .normal_in_flag(normal_in_flag),
    .request_in_flag(request_in_flag),
    .retrans_in_flag(retrans_in_flag),
    .task_send_finish_flag(task_send_finish_flag),
    .data_in_des_buf(data_in_des_buf),
    .all_receive_flag(all_receive_flag_010),

    //data receive miss
    .long_time(long_time),
    .seq_counter(seq_counter_010),
    .diff_counter(diff_counter_010),
    .receive_time_counter(receive_time_counter_010),
    .data_miss_flag(data_miss_counter[1]),
    .long_time_flag(long_time_counter[1]),
    .so_retrsreq_send_num(so_retrsreq_send_num_010),
    .so_retrsreq_send_flag(so_retrsreq_send_flag[1]),

    //send miss
    .retrans_counter(retrans_counter_010),
    .so_retrsreq_receive_num(so_retrsreq_receive_num_010),
    .so_retrsreq_receive_flag(so_retrsreq_receive_flag[1]),

    //output flags
    .request_out_flag(request_out_flag),
    .retrans_out_flag(retrans_out_flag),
    .hold_out_flag(hold_out_flag),

    //dst
    .request_dst(request_dst),
    .retrans_dst(retrans_dst),

    .clk(clk),
    .rst_n(rst_n)
    );

// 011
    PE_single #(
    .MY_ID(MY_ID),
    .TAR_ID(THR_ID),

    //for retry request
    .NORMAL_BAG(NORMAL_BAG)
    ) PE_single_011(
    .dbg_mode(dbg_mode),
    .enable(enable),
    .data_r2p(data_r2p),
    .valid_r2p(valid_r2p),
    .data_p2r({data_p2r[`SRC_MAX:`SRC_MIN], data_p2r[`DST_MAX:`DST_MIN]}),
    .valid_p2r(valid_p2r),
    //basic flags
    .valid_in_flag(valid_in_flag),
    .normal_in_flag(normal_in_flag),
    .request_in_flag(request_in_flag),
    .retrans_in_flag(retrans_in_flag),
    .task_send_finish_flag(task_send_finish_flag),
    .data_in_des_buf(data_in_des_buf),
    .all_receive_flag(all_receive_flag_011),

    //data receive miss
    .long_time(long_time),
    .seq_counter(seq_counter_011),
    .diff_counter(diff_counter_011),
    .receive_time_counter(receive_time_counter_011),
    .data_miss_flag(data_miss_counter[2]),
    .long_time_flag(long_time_counter[2]),
    .so_retrsreq_send_num(so_retrsreq_send_num_011),
    .so_retrsreq_send_flag(so_retrsreq_send_flag[2]),

    //send miss
    .retrans_counter(retrans_counter_011),
    .so_retrsreq_receive_num(so_retrsreq_receive_num_011),
    .so_retrsreq_receive_flag(so_retrsreq_receive_flag[2]),

    //output flags
    .request_out_flag(request_out_flag),
    .retrans_out_flag(retrans_out_flag),
    .hold_out_flag(hold_out_flag),

    //dst
    .request_dst(request_dst),
    .retrans_dst(retrans_dst),

    .clk(clk),
    .rst_n(rst_n)
    );

// 100
    PE_single #(
    .MY_ID(MY_ID),
    .TAR_ID(FOU_ID),

    //for retry request
    .NORMAL_BAG(NORMAL_BAG)
    ) PE_single_100(
    .dbg_mode(dbg_mode),
    .enable(enable),
    .data_r2p(data_r2p),
    .valid_r2p(valid_r2p),
    .data_p2r({data_p2r[`SRC_MAX:`SRC_MIN], data_p2r[`DST_MAX:`DST_MIN]}),
    .valid_p2r(valid_p2r),
    //basic flags
    .valid_in_flag(valid_in_flag),
    .normal_in_flag(normal_in_flag),
    .request_in_flag(request_in_flag),
    .retrans_in_flag(retrans_in_flag),
    .task_send_finish_flag(task_send_finish_flag),
    .data_in_des_buf(data_in_des_buf),
    .all_receive_flag(all_receive_flag_100),

    //data receive miss
    .long_time(long_time),
    .seq_counter(seq_counter_100),
    .diff_counter(diff_counter_100),
    .receive_time_counter(receive_time_counter_100),
    .data_miss_flag(data_miss_counter[3]),
    .long_time_flag(long_time_counter[3]),
    .so_retrsreq_send_num(so_retrsreq_send_num_100),
    .so_retrsreq_send_flag(so_retrsreq_send_flag[3]),

    //send miss
    .retrans_counter(retrans_counter_100),
    .so_retrsreq_receive_num(so_retrsreq_receive_num_100),
    .so_retrsreq_receive_flag(so_retrsreq_receive_flag[3]),

    //output flags
    .request_out_flag(request_out_flag),
    .retrans_out_flag(retrans_out_flag),
    .hold_out_flag(hold_out_flag),

    //dst
    .request_dst(request_dst),
    .retrans_dst(retrans_dst),

    .clk(clk),
    .rst_n(rst_n)
    );

// 101
    PE_single #(
    .MY_ID(MY_ID),
    .TAR_ID(FIV_ID),

    //for retry request
    .NORMAL_BAG(NORMAL_BAG)
    ) PE_single_101(
    .dbg_mode(dbg_mode),
    .enable(enable),
    .data_r2p(data_r2p),
    .valid_r2p(valid_r2p),
    .data_p2r({data_p2r[`SRC_MAX:`SRC_MIN], data_p2r[`DST_MAX:`DST_MIN]}),
    .valid_p2r(valid_p2r),
    //basic flags
    .valid_in_flag(valid_in_flag),
    .normal_in_flag(normal_in_flag),
    .request_in_flag(request_in_flag),
    .retrans_in_flag(retrans_in_flag),
    .task_send_finish_flag(task_send_finish_flag),
    .data_in_des_buf(data_in_des_buf),
    .all_receive_flag(all_receive_flag_101),

    //data receive miss
    .long_time(long_time),
    .seq_counter(seq_counter_101),
    .diff_counter(diff_counter_101),
    .receive_time_counter(receive_time_counter_101),
    .data_miss_flag(data_miss_counter[4]),
    .long_time_flag(long_time_counter[4]),
    .so_retrsreq_send_num(so_retrsreq_send_num_101),
    .so_retrsreq_send_flag(so_retrsreq_send_flag[4]),

    //send miss
    .retrans_counter(retrans_counter_101),
    .so_retrsreq_receive_num(so_retrsreq_receive_num_101),
    .so_retrsreq_receive_flag(so_retrsreq_receive_flag[4]),

    //output flags
    .request_out_flag(request_out_flag),
    .retrans_out_flag(retrans_out_flag),
    .hold_out_flag(hold_out_flag),

    //dst
    .request_dst(request_dst),
    .retrans_dst(retrans_dst),

    .clk(clk),
    .rst_n(rst_n)
    );

// 110
    PE_single #(
    .MY_ID(MY_ID),
    .TAR_ID(SIX_ID),

    //for retry request
    .NORMAL_BAG(NORMAL_BAG)
    ) PE_single_110(
    .dbg_mode(dbg_mode),
    .enable(enable),
    .data_r2p(data_r2p),
    .valid_r2p(valid_r2p),
    .data_p2r({data_p2r[`SRC_MAX:`SRC_MIN], data_p2r[`DST_MAX:`DST_MIN]}),
    .valid_p2r(valid_p2r),
    //basic flags
    .valid_in_flag(valid_in_flag),
    .normal_in_flag(normal_in_flag),
    .request_in_flag(request_in_flag),
    .retrans_in_flag(retrans_in_flag),
    .task_send_finish_flag(task_send_finish_flag),
    .data_in_des_buf(data_in_des_buf),
    .all_receive_flag(all_receive_flag_110),

    //data receive miss
    .long_time(long_time),
    .seq_counter(seq_counter_110),
    .diff_counter(diff_counter_110),
    .receive_time_counter(receive_time_counter_110),
    .data_miss_flag(data_miss_counter[5]),
    .long_time_flag(long_time_counter[5]),
    .so_retrsreq_send_num(so_retrsreq_send_num_110),
    .so_retrsreq_send_flag(so_retrsreq_send_flag[5]),

    //send miss
    .retrans_counter(retrans_counter_110),
    .so_retrsreq_receive_num(so_retrsreq_receive_num_110),
    .so_retrsreq_receive_flag(so_retrsreq_receive_flag[5]),

    //output flags
    .request_out_flag(request_out_flag),
    .retrans_out_flag(retrans_out_flag),
    .hold_out_flag(hold_out_flag),

    //dst
    .request_dst(request_dst),
    .retrans_dst(retrans_dst),

    .clk(clk),
    .rst_n(rst_n)
    );

// 111
    PE_single #(
    .MY_ID(MY_ID),
    .TAR_ID(SEV_ID),

    //for retry request
    .NORMAL_BAG(NORMAL_BAG)
    ) PE_single_111(
    .dbg_mode(dbg_mode),
    .enable(enable),
    .data_r2p(data_r2p),
    .valid_r2p(valid_r2p),
    .data_p2r({data_p2r[`SRC_MAX:`SRC_MIN], data_p2r[`DST_MAX:`DST_MIN]}),
    .valid_p2r(valid_p2r),
    //basic flags
    .valid_in_flag(valid_in_flag),
    .normal_in_flag(normal_in_flag),
    .request_in_flag(request_in_flag),
    .retrans_in_flag(retrans_in_flag),
    .task_send_finish_flag(task_send_finish_flag),
    .data_in_des_buf(data_in_des_buf),
    .all_receive_flag(all_receive_flag_111),

    //data receive miss
    .long_time(long_time),
    .seq_counter(seq_counter_111),
    .diff_counter(diff_counter_111),
    .receive_time_counter(receive_time_counter_111),
    .data_miss_flag(data_miss_counter[6]),
    .long_time_flag(long_time_counter[6]),
    .so_retrsreq_send_num(so_retrsreq_send_num_111),
    .so_retrsreq_send_flag(so_retrsreq_send_flag[6]),

    //send miss
    .retrans_counter(retrans_counter_111),
    .so_retrsreq_receive_num(so_retrsreq_receive_num_111),
    .so_retrsreq_receive_flag(so_retrsreq_receive_flag[6]),

    //output flags
    .request_out_flag(request_out_flag),
    .retrans_out_flag(retrans_out_flag),
    .hold_out_flag(hold_out_flag),

    //dst
    .request_dst(request_dst),
    .retrans_dst(retrans_dst),

    .clk(clk),
    .rst_n(rst_n)
    );

// INPUT
// BASIC FLAGS
    always @(*) begin
        if(!enable)
            valid_in_flag = 1'b0;
        else if(valid_r2p && (data_r2p[`DST_MAX:`DST_MIN] == MY_ID))
            valid_in_flag = 1'b1;
        else
            valid_in_flag = 1'b0;
    end

    always @(*) begin
        if(!enable || task_receive_finish_flag)
            normal_in_flag = 1'b0;
        else if(valid_r2p && (data_r2p[`DST_MAX:`DST_MIN] == MY_ID) && (data_r2p[`TYPE_MAX:`TYPE_MIN] == NORMAL_BAG))
            normal_in_flag = 1'b1;
        else
            normal_in_flag = 1'b0;
    end

    always @(*) begin
        if(!enable)
            request_in_flag = 1'b0;
        else if(valid_r2p && (data_r2p[`DST_MAX:`DST_MIN] == MY_ID) && (data_r2p[`TYPE_MAX:`TYPE_MIN] == RETRY_REQ))
            request_in_flag = 1'b1;
        else
            request_in_flag = 1'b0;
    end

    always @(*) begin
        if(!enable || task_receive_finish_flag)
            retrans_in_flag = 1'b0;
        else if(valid_r2p && (data_r2p[`DST_MAX:`DST_MIN] == MY_ID) && (data_r2p[`TYPE_MAX:`TYPE_MIN] == RETRY_BAG))
            retrans_in_flag = 1'b1;
        else
            retrans_in_flag = 1'b0;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            data_in_des_buf <= {(`TIME_MAX - `SRC_MIN + 1){1'b0}};
        else if(valid_in_flag)
            data_in_des_buf <= data_r2p[`TIME_MAX:`SRC_MIN];
        else
            data_in_des_buf <= data_in_des_buf;
    end
// RECEIVE FINISH
    always @(*) begin
        if(!enable)
            sum = `ID_SIZE'd0;
        else
            sum = all_receive_flag_001 + all_receive_flag_010 + all_receive_flag_011 + all_receive_flag_100 + all_receive_flag_101 + all_receive_flag_110 + all_receive_flag_111;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            task_receive_finish_flag <= 1'b0;
        else if(!enable)
            task_receive_finish_flag <= task_receive_finish_flag;
        else if(receive_num == {`LOG_ROUTER_NUM{1'b0}})
            task_receive_finish_flag <= 1'b1;
        else if(sum >= receive_num)
            task_receive_finish_flag <= 1'b1;
        else
            task_receive_finish_flag <= 1'b0;
    end
// LATENCY
    always @(*) begin
        if(!enable)
            latency_diff = `TIME_SIZE'd0;
        else if(data_r2p[`TIME_MAX:`TIME_MIN] < time_stamp)
            latency_diff = time_stamp - data_r2p[`TIME_MAX:`TIME_MIN];
        else
            latency_diff = {`TIME_SIZE{1'b1}} - data_r2p[`TIME_MAX:`TIME_MIN] + time_stamp + 1'b1;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            latency_max <= LATENCY_MIN;
        else if(!enable || !valid_r2p || data_r2p[`DST_MAX:`DST_MIN] != MY_ID)
            latency_max <= latency_max;
        else if((data_r2p[`TYPE_MAX:`TYPE_MIN] == NORMAL_BAG) && (data_r2p[`SRC_MAX:`SRC_MIN] != MY_ID))
            latency_max <= (latency_max > latency_diff) ? latency_max : latency_diff;
        else
            latency_max <= latency_max;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            latency_min <= LATENCY_MAX;
        else if(!enable || !valid_r2p || data_r2p[`DST_MAX:`DST_MIN] != MY_ID)
            latency_min <= latency_min;
        else if((data_r2p[`TYPE_MAX:`TYPE_MIN] == NORMAL_BAG) && (data_r2p[`SRC_MAX:`SRC_MIN] != MY_ID))
            latency_min <= (latency_min < latency_diff) ? latency_min : latency_diff;
        else
            latency_min <= latency_min;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            latency_sum <= LATENCY_SUM;
        else if(!enable || !valid_r2p || data_r2p[`DST_MAX:`DST_MIN] != MY_ID)
            latency_sum <= latency_sum;
        else if((data_r2p[`TYPE_MAX:`TYPE_MIN] == NORMAL_BAG) && (data_r2p[`SRC_MAX:`SRC_MIN] != MY_ID) && (data_r2p[`TIME_MAX:`SRC_MIN] != data_in_des_buf))
            latency_sum <= latency_sum + latency_diff;
        else
            latency_sum <= latency_sum;
    end

// RECEIVE MISS
    always @(*) begin
        if(!enable)
            data_miss_sum = data_miss_sum;
        else
            data_miss_sum = data_miss_counter[0] + data_miss_counter[1] + data_miss_counter[2] + data_miss_counter[3] + data_miss_counter[4] + data_miss_counter[5] + data_miss_counter[6];
    end

    always @(*) begin
        if(!enable)
            long_time_sum = long_time_sum;
        else
            long_time_sum = long_time_counter[0] + long_time_counter[1] + long_time_counter[2] + long_time_counter[3] + long_time_counter[4] + long_time_counter[5] + long_time_counter[6];
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            data_miss <= 1'b0;
        else if(!enable)
            data_miss <= data_miss;
        else if((!valid_enable || full) && data_miss)
            data_miss <= 1'b1;
        else if(data_miss_sum > `LOG_ROUTER_NUM'd1)
            data_miss <= 1'b1;
        else begin
            case ({normal_in_flag, data_r2p[`SRC_MAX:`SRC_MIN]})
                {1'b1, ONE_ID}: data_miss <= (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_001 + 1'b1)) ? 1'b1 : 1'b0;
                {1'b1, TWO_ID}: data_miss <= (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_010 + 1'b1)) ? 1'b1 : 1'b0;
                {1'b1, THR_ID}: data_miss <= (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_011 + 1'b1)) ? 1'b1 : 1'b0;
                {1'b1, FOU_ID}: data_miss <= (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_100 + 1'b1)) ? 1'b1 : 1'b0;
                {1'b1, FIV_ID}: data_miss <= (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_101 + 1'b1)) ? 1'b1 : 1'b0;
                {1'b1, SIX_ID}: data_miss <= (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_110 + 1'b1)) ? 1'b1 : 1'b0;
                {1'b1, SEV_ID}: data_miss <= (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_111 + 1'b1)) ? 1'b1 : 1'b0;
                default: data_miss <= data_miss;
            endcase
        end
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            long_time <= 1'b0;
        else if(!enable)
            long_time <= long_time;
        else if((!valid_enable || full) && long_time)
            long_time <= 1'b1;
        else if(long_time_sum > `LOG_ROUTER_NUM'd1)
            long_time <= 1'b1;
        else if((receive_time_counter_001 == {`TIME_SIZE{1'b1}}) || (receive_time_counter_010 == {`TIME_SIZE{1'b1}}) || (receive_time_counter_011 == {`TIME_SIZE{1'b1}}) || 
                (receive_time_counter_100 == {`TIME_SIZE{1'b1}}) || (receive_time_counter_101 == {`TIME_SIZE{1'b1}}) || (receive_time_counter_110 == {`TIME_SIZE{1'b1}}) || 
                (receive_time_counter_111 == {`TIME_SIZE{1'b1}}))
            long_time <= 1'b1;
        else
            long_time <= 1'b0;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            so_retrsreq_send_num <= 8'b0000_0000;
        else if(so_retrsreq_send_num_001 || so_retrsreq_send_num_010 ||
                so_retrsreq_send_num_011 || so_retrsreq_send_num_100 ||
                so_retrsreq_send_num_101 || so_retrsreq_send_num_110 ||
                so_retrsreq_send_num_111 )
            so_retrsreq_send_num <= so_retrsreq_send_num + 1'b1;
        else
            so_retrsreq_send_num <= so_retrsreq_send_num;
    end

// SEND MISS
    always @(*) begin
        if(!enable)
            retrans_flag = 1'b0;
        else if((retrans_counter_001 != {`DATA_SIZE{1'b0}}) || (retrans_counter_010 != {`DATA_SIZE{1'b0}}) || 
                (retrans_counter_011 != {`DATA_SIZE{1'b0}}) || (retrans_counter_100 != {`DATA_SIZE{1'b0}}) || 
                (retrans_counter_101 != {`DATA_SIZE{1'b0}}) || (retrans_counter_110 != {`DATA_SIZE{1'b0}}) || 
                (retrans_counter_111 != {`DATA_SIZE{1'b0}}))
            retrans_flag = 1'b1;
        else
            retrans_flag = 1'b0;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            so_retrsreq_receive_num <= 8'b0000_0000;
        else if(so_retrsreq_receive_num_001 || so_retrsreq_receive_num_010 ||
                so_retrsreq_receive_num_011 || so_retrsreq_receive_num_100 ||
                so_retrsreq_receive_num_101 || so_retrsreq_receive_num_110 ||
                so_retrsreq_receive_num_111 )
            so_retrsreq_receive_num <= so_retrsreq_receive_num + 1'b1;
        else
            so_retrsreq_receive_num <= so_retrsreq_receive_num;
    end

// OUTPUT
// TIME STAMP
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            time_stamp <= `TIME_SIZE'd0;
        else if(enable)
            time_stamp <= time_stamp + 1'b1;
        else
            time_stamp <= time_stamp;
    end
// CONTROL VALID RATE
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            rate_out_counter <= 4'h0;
        else if(!enable)
            rate_out_counter <= rate_out_counter;
        else if(rate_out_counter == 4'h9)
            rate_out_counter <= 4'h0;
        else
            rate_out_counter <= rate_out_counter + 1'b1;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            valid_enable <= 1'b0;
        else if(rate == 4'h0)
            valid_enable <= 1'b1;
        else if(rate_out_counter == 4'h0)
            valid_enable <= 1'b0;
        else if(rate == rate_out_counter)
            valid_enable <= 1'b1;
        else
            valid_enable <= valid_enable;
    end

// OUTPUT ENABLE FLAGS
    always @(*) begin
        if(!enable || task_receive_finish_flag)
            request_out_flag = 1'b0;
        else if(!full && (data_miss || long_time) && valid_enable)
            request_out_flag = 1'b1;
        else
            request_out_flag = 1'b0;
    end

    always @(*) begin
        if(!enable)
            retrans_out_flag = 1'b0;
        else if(valid_enable && !full && retrans_flag && !data_miss && !long_time)
            retrans_out_flag = 1'b1;
        else
            retrans_out_flag = 1'b0;
    end

    always @(*) begin
        if(!enable || task_send_finish_flag)
            normal_out_flag = 1'b0;
        else if(valid_enable && !full && !retrans_flag && !data_miss && !long_time)
            normal_out_flag = 1'b1;
        else
            normal_out_flag = 1'b0;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            hold_out_flag <= 1'b0;
        else if(enable && !valid_enable && valid_p2r && full)
            hold_out_flag <= 1'b1;
        else if(!valid_enable)
            hold_out_flag <= hold_out_flag;
        else
            hold_out_flag <= 1'b0;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            start <= 1'b0;
        else if(valid_p2r && (data_p2r[`SRC_MAX:`SRC_MIN] == MY_ID))
            start <= 1'b1;
        else
            start <= start;
    end
// SEND FINISH
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            send_num_counter <= 3'b000;
        else if(dbg_mode && (normal_counter == {{(`DATA_SIZE - `DATA_WIDTH_DBG){1'b0}}, {`DATA_WIDTH_DBG{1'b1}}}) && normal_out_flag && (normal_dst != MY_ID) && !hold_out_flag)
            send_num_counter <= send_num_counter + 1'b1;
        else if(!dbg_mode && (normal_counter == {{(`DATA_SIZE - `DATA_WIDTH_NOR){1'b0}}, {(`DATA_WIDTH_NOR){1'b1}}}) && normal_out_flag && (normal_dst != MY_ID) && !hold_out_flag)
            send_num_counter <= send_num_counter + 1'b1;
        else
            send_num_counter <= send_num_counter;
    end
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            task_send_finish_flag <= 1'b0;
        else if(send_num == 3'b000)
            task_send_finish_flag <= 1'b1;
        else if((send_num_counter + 1'b1 == send_num) && dbg_mode && (normal_counter == {{(`DATA_SIZE - `DATA_WIDTH_DBG){1'b0}}, {`DATA_WIDTH_DBG{1'b1}}}) && normal_out_flag && !hold_out_flag && (normal_dst != MY_ID))
            task_send_finish_flag <= 1'b1;
        else if((send_num_counter + 1'b1 == send_num) && !dbg_mode && (normal_counter == {{(`DATA_SIZE - `DATA_WIDTH_NOR){1'b0}}, {(`DATA_WIDTH_NOR){1'b1}}}) && normal_out_flag && !hold_out_flag && (normal_dst != MY_ID))
            task_send_finish_flag <= 1'b1;
        else
            task_send_finish_flag <= task_send_finish_flag;
    end
// DST
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            normal_flag_dst <= MY_ID;
        else begin
            case (mode)
                4'b0001: normal_flag_dst <= dst_seq[2:0];
                4'b0010: normal_flag_dst <= dst_seq[5:3];
                4'b0011: normal_flag_dst <= dst_seq[8:6];
                4'b0100: normal_flag_dst <= dst_seq[11:9];
                4'b0101: normal_flag_dst <= dst_seq[14:12];
                4'b0110: normal_flag_dst <= dst_seq[17:15];
                4'b0111: normal_flag_dst <= dst_seq[20:18];
                4'b1000: normal_flag_dst <= dst_seq[23:21];
                default: normal_flag_dst <= SEV_ID;
            endcase
        end
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            request_dst <= MY_ID;
        else if((!valid_enable || full) && long_time)
            request_dst <= request_dst;
        else if((receive_time_counter_001 == {`TIME_SIZE{1'b1}}) || (normal_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == ONE_ID) && (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_001 + 1'b1))))
            request_dst <= ONE_ID;
        else if((receive_time_counter_010 == {`TIME_SIZE{1'b1}}) || (normal_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == TWO_ID) && (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_010 + 1'b1))))
            request_dst <= TWO_ID;
        else if((receive_time_counter_011 == {`TIME_SIZE{1'b1}}) || (normal_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == THR_ID) && (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_011 + 1'b1))))
            request_dst <= THR_ID;
        else if((receive_time_counter_100 == {`TIME_SIZE{1'b1}}) || (normal_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == FOU_ID) && (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_100 + 1'b1))))
            request_dst <= FOU_ID;
        else if((receive_time_counter_101 == {`TIME_SIZE{1'b1}}) || (normal_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == FIV_ID) && (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_101 + 1'b1))))
            request_dst <= FIV_ID;
        else if((receive_time_counter_110 == {`TIME_SIZE{1'b1}}) || (normal_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == SIX_ID) && (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_110 + 1'b1))))
            request_dst <= SIX_ID;
        else if((receive_time_counter_111 == {`TIME_SIZE{1'b1}}) || (normal_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == SEV_ID) && (data_r2p[`DATA_MAX:`DATA_MIN] > (seq_counter_111 + 1'b1))))
            request_dst <= SEV_ID;
        else if((long_time_counter[0] || (diff_counter_001 != {`DATA_SIZE{1'b0}})) && (!request_out_flag || hold_out_flag || request_dst != ONE_ID))
            request_dst <= ONE_ID;
        else if((long_time_counter[1] || (diff_counter_010 != {`DATA_SIZE{1'b0}})) && (!request_out_flag || hold_out_flag || request_dst != TWO_ID))
            request_dst <= TWO_ID;
        else if((long_time_counter[2] || (diff_counter_011 != {`DATA_SIZE{1'b0}})) && (!request_out_flag || hold_out_flag || request_dst != THR_ID))
            request_dst <= THR_ID;
        else if((long_time_counter[3] || (diff_counter_100 != {`DATA_SIZE{1'b0}})) && (!request_out_flag || hold_out_flag || request_dst != FOU_ID))
            request_dst <= FOU_ID;
        else if((long_time_counter[4] || (diff_counter_101 != {`DATA_SIZE{1'b0}})) && (!request_out_flag || hold_out_flag || request_dst != FIV_ID))
            request_dst <= FIV_ID;
        else if((long_time_counter[5] || (diff_counter_110 != {`DATA_SIZE{1'b0}})) && (!request_out_flag || hold_out_flag || request_dst != SIX_ID))
            request_dst <= SIX_ID;
        else if((long_time_counter[6] || (diff_counter_111 != {`DATA_SIZE{1'b0}})) && (!request_out_flag || hold_out_flag || request_dst != SEV_ID))
            request_dst <= SEV_ID;
        else
            request_dst <= MY_ID;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            retrans_dst <= MY_ID;
        else if(request_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == ONE_ID) && (data_r2p[`TIME_MAX:`SRC_MIN] != data_in_des_buf))
            retrans_dst <= ONE_ID;
        else if(request_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == TWO_ID) && (data_r2p[`TIME_MAX:`SRC_MIN] != data_in_des_buf))
            retrans_dst <= TWO_ID;
        else if(request_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == THR_ID) && (data_r2p[`TIME_MAX:`SRC_MIN] != data_in_des_buf))
            retrans_dst <= THR_ID;
        else if(request_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == FOU_ID) && (data_r2p[`TIME_MAX:`SRC_MIN] != data_in_des_buf))
            retrans_dst <= FOU_ID;
        else if(request_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == FIV_ID) && (data_r2p[`TIME_MAX:`SRC_MIN] != data_in_des_buf))
            retrans_dst <= FIV_ID;
        else if(request_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == SIX_ID) && (data_r2p[`TIME_MAX:`SRC_MIN] != data_in_des_buf))
            retrans_dst <= SIX_ID;
        else if(request_in_flag && (data_r2p[`SRC_MAX:`SRC_MIN] == SEV_ID) && (data_r2p[`TIME_MAX:`SRC_MIN] != data_in_des_buf))
            retrans_dst <= SEV_ID;
        else if((retrans_counter_001 != {`DATA_SIZE{1'b0}}) && ((retrans_counter_001 != `DATA_SIZE'd1) || !retrans_out_flag || hold_out_flag || retrans_dst != ONE_ID))
            retrans_dst <= ONE_ID;
        else if((retrans_counter_010 != {`DATA_SIZE{1'b0}}) && ((retrans_counter_010 != `DATA_SIZE'd1) || !retrans_out_flag || hold_out_flag || retrans_dst != TWO_ID))
            retrans_dst <= TWO_ID;
        else if((retrans_counter_011 != {`DATA_SIZE{1'b0}}) && ((retrans_counter_011 != `DATA_SIZE'd1) || !retrans_out_flag || hold_out_flag || retrans_dst != THR_ID))
            retrans_dst <= THR_ID;
        else if((retrans_counter_100 != {`DATA_SIZE{1'b0}}) && ((retrans_counter_100 != `DATA_SIZE'd1) || !retrans_out_flag || hold_out_flag || retrans_dst != FOU_ID))
            retrans_dst <= FOU_ID;
        else if((retrans_counter_101 != {`DATA_SIZE{1'b0}}) && ((retrans_counter_101 != `DATA_SIZE'd1) || !retrans_out_flag || hold_out_flag || retrans_dst != FIV_ID))
            retrans_dst <= FIV_ID;
        else if((retrans_counter_110 != {`DATA_SIZE{1'b0}}) && ((retrans_counter_110 != `DATA_SIZE'd1) || !retrans_out_flag || hold_out_flag || retrans_dst != SIX_ID))
            retrans_dst <= SIX_ID;
        else if((retrans_counter_111 != {`DATA_SIZE{1'b0}}) && ((retrans_counter_111 != `DATA_SIZE'd1) || !retrans_out_flag || hold_out_flag || retrans_dst != SEV_ID))
            retrans_dst <= SEV_ID;
        else
            retrans_dst <= MY_ID;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            normal_dst <= MY_ID;
        else if(!enable && !start)
            normal_dst <= (mode == 4'h0) ? ONE_ID : dst_seq[2:0];
        else if(!enable)
            normal_dst <= normal_dst;
        else if(normal_out_flag && (mode == 4'h0))
            case (normal_dst)
                ONE_ID: normal_dst <= TWO_ID;
                TWO_ID: normal_dst <= THR_ID;
                THR_ID: normal_dst <= FOU_ID;
                FOU_ID: normal_dst <= FIV_ID;
                FIV_ID: normal_dst <= SIX_ID;
                SIX_ID: normal_dst <= SEV_ID;
                SEV_ID: normal_dst <= ONE_ID;
                default: normal_dst <= MY_ID;
            endcase
        else if(normal_out_flag && (normal_dst == dst_seq[2:0]))
            normal_dst <= (normal_dst == normal_flag_dst) ? dst_seq[2:0] : dst_seq[5:3];
        else if(normal_out_flag && (normal_dst == dst_seq[5:3]))
            normal_dst <= (normal_dst == normal_flag_dst) ? dst_seq[2:0] : dst_seq[8:6];
        else if(normal_out_flag && (normal_dst == dst_seq[8:6]))
            normal_dst <= (normal_dst == normal_flag_dst) ? dst_seq[2:0] : dst_seq[11:9];
        else if(normal_out_flag && (normal_dst == dst_seq[11:9]))
            normal_dst <= (normal_dst == normal_flag_dst) ? dst_seq[2:0] : dst_seq[14:12];
        else if(normal_out_flag && (normal_dst == dst_seq[14:12]))
            normal_dst <= (normal_dst == normal_flag_dst) ? dst_seq[2:0] : dst_seq[17:15];
        else if(normal_out_flag && (normal_dst == dst_seq[17:15]))
            normal_dst <= (normal_dst == normal_flag_dst) ? dst_seq[2:0] : dst_seq[20:18];
        else if(normal_out_flag && (normal_dst == dst_seq[20:18]))
            normal_dst <= (normal_dst == normal_flag_dst) ? dst_seq[2:0] : dst_seq[23:21];
        else if(normal_out_flag && (normal_dst == dst_seq[23:21]))
            normal_dst <= dst_seq[2:0];
        else
            normal_dst <= normal_dst;
    end
// DATA TAG
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            normal_counter <= {`DATA_SIZE{1'b0}};
        else if(task_send_finish_flag)
            normal_counter <= {`DATA_SIZE{1'b0}};
        else if(normal_out_flag && (normal_dst == normal_flag_dst) && !hold_out_flag)
            normal_counter <= normal_counter + 1'b1;
        else
            normal_counter <= normal_counter;
    end
// DATA OUT && VALID
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            data_p2r <= {(`DATA_MAX + 1){1'b0}};
        else if(!enable || full)
            data_p2r <= data_p2r;
        else if(!valid_enable)
            data_p2r <= data_p2r;
        else if(hold_out_flag)
            data_p2r <= {data_p2r[`DATA_MAX:`DATA_MIN], time_stamp, data_p2r[`TYPE_MAX:`DST_MIN]};
        else if((data_miss || long_time) && !task_receive_finish_flag) begin
            case (request_dst)
                ONE_ID: data_p2r <= {diff_counter_001, time_stamp, RETRY_REQ, MY_ID, ONE_ID};
                TWO_ID: data_p2r <= {diff_counter_010, time_stamp, RETRY_REQ, MY_ID, TWO_ID};
                THR_ID: data_p2r <= {diff_counter_011, time_stamp, RETRY_REQ, MY_ID, THR_ID};
                FOU_ID: data_p2r <= {diff_counter_100, time_stamp, RETRY_REQ, MY_ID, FOU_ID};
                FIV_ID: data_p2r <= {diff_counter_101, time_stamp, RETRY_REQ, MY_ID, FIV_ID};
                SIX_ID: data_p2r <= {diff_counter_110, time_stamp, RETRY_REQ, MY_ID, SIX_ID};
                SEV_ID: data_p2r <= {diff_counter_111, time_stamp, RETRY_REQ, MY_ID, SEV_ID};
                default: data_p2r <= {{`DATA_SIZE{1'b0}}, time_stamp, RETRY_REQ, MY_ID, MY_ID}; 
            endcase
        end
        else if(retrans_flag)
            data_p2r <= {{{`DATA_SIZE_0{1'b0}}, 1'b1}, time_stamp, RETRY_BAG, MY_ID, retrans_dst};
        else if(!task_send_finish_flag)
            data_p2r <= {normal_counter, time_stamp, NORMAL_BAG, MY_ID, normal_dst};
        else
            data_p2r <= {(`DATA_MAX + 1){1'b0}};
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            valid_p2r <= 1'b0;
        else if(!enable && flush && !start)
            valid_p2r <= 1'b1;
        else if(!enable && !start)
            valid_p2r <= 1'b0;
        else if(!enable)
            valid_p2r <= valid_p2r;
        else if(full)
            valid_p2r <= valid_enable;
        else if(!valid_enable)
            valid_p2r <= 1'b0;
        else if((data_miss || long_time) && !task_receive_finish_flag)
            valid_p2r <= 1'b1;
        else if((!task_send_finish_flag && (normal_dst != MY_ID)) || retrans_flag)
            valid_p2r <= 1'b1;
        else
            valid_p2r <= 1'b0;
    end
endmodule