`timescale 1ns / 1ps
module hongwai(clk,rst,key_1,IR_out,IR_outt,led_out);
input clk;
input rst;
input key_1; //开关
wire [34:0] IR_in_data35;
wire [32:0] IR_in_data32;
output IR_out;
output led_out; //完全输出一条指令后让led亮一次
output IR_outt;
// output IR_outt_rev;

reg led;
reg [34:0] data35;
reg [32:0] data32;
reg [32:0] data32temp;

parameter t_38k    = 12'd3289;//125MHz/38kHz
parameter t_38k_half = 12'd1644;
parameter t_9ms    = 21'd1125000;//125MHz*9ms
parameter t_4_5ms  = 20'd562500;
parameter t_13_5ms = 21'd1687500;
parameter t_20000us = 22'd2500000;
parameter t_20750us = 22'd2593750;
parameter t_750us = 17'd93750;
parameter t_450us = 16'd56250;
parameter t_1500us = 18'd187500;
parameter t_1200us = 18'd150000;
parameter t_2250us = 19'd281250;

// 按照网上的关于YB0F2遥控器的编码协议
// parameter t_38k    = 12'd3289;//125MHz/38kHz
// parameter t_38k_half = 12'd1644;
// parameter t_9ms    = 21'd1125000;//125MHz*9ms
// parameter t_4_5ms  = 20'd562500;
// parameter t_13_5ms = 21'd1687500;
// parameter t_20000us = 22'd2500000;
// parameter t_20750us = 22'd2575000;
// parameter t_750us = 17'd75000;
// parameter t_450us = 16'd75000;
// parameter t_1500us = 18'd200000;
// parameter t_1200us = 18'd150000;
// parameter t_2250us = 19'd275000;

//38k分频----------------------------------------------//
reg  [12:0] cnt1;
wire  clk_38k;
always @(posedge clk or negedge rst)
    begin
        if(rst)
            begin
                cnt1 <= 0;
            end
        else if(cnt1 == t_38k)
                begin
                    cnt1 <= 0;
                end
            else cnt1 <= cnt1 + 1;
    end
assign  clk_38k = (cnt1<t_38k_half)?0:1;
//38k分频----------------------------------------------//

//状态机发送----------------------------------------------//

parameter  IDEL       = 3'D0;        //初始化状态，等待发送命令
parameter  START      = 3'D1;        //开始发送起始码 
parameter  SEND_35    = 3'D2;        //发送35位数据码
parameter  CONNECT    = 3'D3;        //发送连接码
parameter  SEND_32    = 3'D4;        //发送32位数据码
reg   [2:0]     state;
reg             start_en;//起始_使能
wire            start_over;//起始码是否发送结束
reg             zero_en;
wire            zero_over;//这些判断是否结束的变量虽然存在于always语句里，但是值并没有修改只是用于判断，所以wire型没的毛病
reg             one_en;
wire            one_over;
reg             connect_en;
wire            connect_over;
reg             data35_over;
reg             data32_over;
reg             idel_flag;
// reg             kaiguan;

reg   [5:0]     i;//记录数据目前的位数

always @(posedge clk or negedge rst)
    begin
        if(rst)
            begin
                state <= IDEL;
                start_en <= 0;
                zero_en <= 0;
                one_en <= 0;
                connect_en <= 0;
                // sendover <= 0;
                // shiftdata <= 0; 
                i <= 6'd34; //给data35来用
                // DATA <= 8'D0;
                // kaiguan <= 1;
            end                   
        else 
            begin
                case(state)
                    IDEL:
                        begin
                            start_en <= 0;
                            zero_en <= 0;
                            one_en <= 0;
                            connect_en <= 0;
                            data35_over <= 0;
                            data32_over <= 0;
                            i <= 6'd34;//给data35来用
                            led <= 0;//熄灭一盏小灯
                            idel_flag <= 1;
                            if(key_1)//关机
                                begin
                                    state <= START;    
                                    data35 <= 35'b10000010000100000000010000001010010;
                                    data32 <= 32'b000010000000010000000000000001100;
                                    idel_flag <= 0;
                                end
                            else 
                                begin
                                    if(data32temp != data32)//两者一致说明没有新指令传入，不一样则说明需要进行调制并输出了
                                        begin//好气哦忘记加begin&end了，导致之后的else老报错，debug半天T_T
                                            data35 <= IR_in_data35;
                                            data32 <= IR_in_data32;
                                            state <= START;
                                            idel_flag <= 1;
                                        end
                                    else state <= IDEL;//平时一直在IDEL状态里呆着
                                end
                        end
                    START:  //发送起始码
                        begin
                            if(start_over)    
                                begin                                         
                                    start_en <= 0;
                                    state <= SEND_35;    
                                end
                            else 
                                begin
                                    start_en <= 1;
                                    state <= START;     
                                end     
                        end
                    SEND_35:    //发送35位数据码
                        begin
                            if(data35_over)
                                begin  
                                    i <= 6'd32;    //给data32来用
                                    one_en <= 0;
                                    zero_en <= 0;
                                    state <= CONNECT;
                                end
                            else 
                                begin
                                    if(zero_over||one_over)   //1bit发送结束
                                        begin
                                            if (i==0) //是否到了最后一位
                                                data35_over <= 1;
                                            i <= i - 1; //减少一位
                                            one_en <= 0;
                                            zero_en <= 0;
                                        end
                                    else if(data35[i]) one_en <= 1; 
                                    else if(!data35[i]) zero_en <= 1;
                                    // else 
                                    //     begin
                                    //         i <= i ;
                                    //         one_en <= one_en;
                                    //         zero_en <= zero_en;
                                    //     end  
                                end
                        end
                    CONNECT:  //发送连接码
                        begin
                            if(connect_over)    
                                begin                                         
                                    connect_en <= 0;
                                    state <= SEND_32;   
                                end
                            else 
                                begin
                                    connect_en <= 1;
                                    state <= CONNECT;     
                                end     
                        end
                    SEND_32:    //发送32位数据码
                        begin
                            if(data32_over)
                                begin  
                                    i <= 6'd34;    //给data35来用
                                    one_en <= 0;
                                    zero_en <= 0;
                                    data32temp <= data32;//将传送后的值记录下来，在IDEL状态不断进行判断
                                    state <= IDEL;
                                end
                            else 
                                begin
                                    if(zero_over||one_over)   //1bit发送结束
                                        begin
                                            if (i==0) //是否到了最后一位
                                                data32_over <= 1;
                                            i <= i - 1; //减少一位
                                            one_en <= 0;
                                            zero_en <= 0;
                                            led <= 1;//点亮一盏小灯
                                        end
                                    else if(data32[i]) one_en <= 1; 
                                    else if(!data32[i]) zero_en <= 1;
                                    // else 
                                    //     begin
                                    //         i <= i ;
                                    //         one_en <= one_en;
                                    //         zero_en <= zero_en;
                                    //     end  
                                end
                        end
                    default: state <= IDEL;
                endcase
            end //end all cases
    end
//状态机发送----------------------------------------------//


//----------------------------------------------//
//引导码，9ms载波加4.5ms空闲
reg    [20:0]cnt2;//@@@数据长度和13.5ms一致
wire         start_flag;
always @(posedge clk or negedge rst)
    begin
        if(rst)
            begin
                cnt2 <= 0;
            end
        else if(start_en)
                begin
                    if(cnt2 >= t_13_5ms)  cnt2 <= t_13_5ms+1;        
                    else cnt2 <= cnt2 + 1;
                end
            else cnt2  <= 0;         
    end
assign start_over = (cnt2 == t_13_5ms)?1:0;    
assign start_flag = (start_en&&(cnt2 >= t_9ms))?1:0;

//连接码， 750us载波 20000us空闲
reg    [21:0]     cnt5;//@@@数据长度和20000us一致
wire              finish_flag;
always @(posedge clk or negedge rst)
    begin
        if(rst)
            begin
                cnt5 <= 0;
            end
        else if(connect_en)
                begin
                    if(cnt5 >= t_20750us)  cnt5 <= t_20750us+1;        
                    else cnt5 <= cnt5 + 1;
                end
            else cnt5  <= 0;         
    end
assign connect_over = (cnt5 == t_20750us)?1:0;    
assign connect_flag = (connect_en&&(cnt5 >= t_750us))?1:0;

//----------------------------------------------//
//比特0, 560us载波 + 560us空闲
reg    [17:0]     cnt3;// @@@数据长度和1200us一致
wire              zero_flag;
always @(posedge clk or negedge rst)
    begin
        if(rst)
            begin
                cnt3 <= 0;
            end
        else if(zero_en)
            begin
                if(cnt3 >= t_1200us)  cnt3 <= t_1200us+1;        
                else cnt3 <= cnt3 + 1;
            end
        else cnt3  <= 0;         
    end
assign zero_over = (cnt3 == t_1200us)?1:0;    
assign zero_flag = (zero_en&&(cnt3 >= t_750us))?1:0;
    
//----------------------------------------------//
//比特1, 560us载波 + 1.68ms空闲
reg    [18:0]     cnt4;// @@@数据长度和t_2250us一致
wire              one_flag;
always @(posedge clk or negedge rst)
    begin
        if(rst)
            begin
                cnt4 <= 0;
            end
        else if(one_en)
            begin
                if(cnt4 >= t_2250us)  cnt4 <= t_2250us+1;        
                else cnt4 <= cnt4 + 1;
            end
        else cnt4  <= 0;         
    end
assign one_over = (cnt4 == t_2250us)?1:0;    
assign one_flag = (one_en&&(cnt4 >= t_750us))?1:0;
    
wire   ir_out;
wire  IR_outt_rev;
assign ir_out = start_flag||zero_flag||one_flag||connect_flag||idel_flag;
assign IR_out = ir_out;
// assign IR_outt_rev = ~IR_outt;
assign IR_outt = (~ir_out)&&clk_38k;//38k载波是在低电平时才调制，所以要与上ir_out的非

assign led_out = led;

endmodule