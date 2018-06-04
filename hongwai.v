module hongwai(clk,rst,key_1,IR_in_data35,IR_in_data32,IR_out,led_out);
input clk;
input rst;
input key_1; //开关
input [34:0] IR_in_data35;
input [31:0] IR_in_data32;
output IR_out;
output led_out; //完全输出一条指令后让led亮一次

reg led;
reg [34:0] data35;
reg [31:0] data32;
reg [31:0] data32temp;

parameter t_38k    = 10'd3288;
parameter t_38k_half = 10'd1644;
parameter t_9ms    = 18'd900000;//100MHz*9ms
parameter t_4_5ms  = 17'd450000;
parameter t_13_5ms = 19'd1350000;
parameter t_20000us = 14'd2000000;
parameter t_20750us = 14'd2075000;
parameter t_750us = 15'd75000;
parameter t_450us = 16'd45000;
parameter t_1500us = 16'd150000;
parameter t_1200us = 16'd120000;
parameter t_2250us = 16'd225000;
// 这里的二进制数位是错的


//38k分频----------------------------------------------//
reg  [10:0] cnt1;
reg  clk_38k;
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
        assign  clk_38k = (cnt1<t_38k_half)?1:0;
    end
//38k分频----------------------------------------------//

//状态机发送----------------------------------------------//

//状态机发送----------------------------------------------//
parameter  IDEL       = 3'D0;        //初始化状态，等待发送命令
parameter  START      = 3'D1;        //开始发送起始码 
parameter  SEND_35    = 3'D2;        //发送35位数据码
parameter  CONNECT    = 3'D3;        //发送连接码
parameter  SEND_32    = 3'D4;        //发送32位数据码
// parameter  SEND_UNDATA= 3'D5;        //发送数据反码
// parameter  FINISH     = 3'D6;        //发送结束码
// parameter  FINISH_1   = 3'D7;        //发送结束
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
// reg             kaiguan;

reg   [3:0]     i;//记录数据目前的位数

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                state <= IDEL;
                start_en <= 0;
                zero_en <= 0;
                one_en <= 0;
                connect_en <= 0;
                // sendover <= 0;
                // shiftdata <= 0; 
                i <= 35; //给data35来用
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
                            i <= 35;//给data35来用
                            led <= 0;//熄灭一盏小灯
                            if(key_1)//关机
                                begin
                                    state <= START;    
                                    data35 <= 35'b10000010000100000000010000001010010;
                                    data32 <= 32'b00001000000001000000000000000110;
                                end
                            else 
                                begin
                                    if(data32temp != data32)//两者一致说明没有新指令传入，不一样则说明需要进行调制并输出了
                                        begin//好气哦忘记加begin&end了，之后的else老报错 debug半天T_T
                                            data35 <= IR_in_data35;
                                            data32 <= IR_in_data32;
                                            state <= START;
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
                                    i <= 32;    //给data32来用
                                    one_en <= 0;
                                    zero_en <= 0;
                                    state <= CONNECT;
                                end
                            else 
                                begin
                                    if(zero_over||one_over)   //1bit发送结束
                                        begin
                                            i <= i - 1; //减少一位
                                            if (i==0) //是否到了最后一位
                                                data35_over <= 1;
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
                                    i <= 35;    //给data35来用
                                    one_en <= 0;
                                    zero_en <= 0;
                                    data32temp <= data32;//将传送后的值记录下来，在IDEL状态不断进行判断
                                    state <= IDEL;
                                end
                            else 
                                begin
                                    if(zero_over||one_over)   //1bit发送结束
                                        begin
                                            i <= i - 1; //减少一位
                                            if (i==0) //是否到了最后一位
                                                data32_over <= 1;
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


//----------------------------------------------//
//引导码，9ms载波加4.5ms空闲
reg    [19:0]cnt2;//@@@数据长度和13.5ms一致
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
assign start_flag = (start_en&&(cnt2 <= t_9ms))?1:0;

//连接码， 750us载波 20000us空闲
reg    [14:0]     cnt5;//@@@数据长度和20000us一致
wire              finish_flag;
always @(posedge clk or negedge rst)
    begin
        if(!rst)
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
assign connect_over = (cnt5 == t_20000us)?1:0;    
assign connect_flag = (connect_en&&(cnt5 <= t_750us))?1:0;

//----------------------------------------------//
//比特0， 560us载波 + 560us空闲
reg    [15:0]     cnt3;// @@@数据长度和1200us一致
wire              zero_flag;
always @(posedge clk or negedge rst)
    begin
        if(!rst)
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
assign zero_flag = (zero_en&&(cnt3 <= t_750us))?1:0;
    
//----------------------------------------------//
//比特1， 560us载波 + 1.68ms空闲
reg    [16:0]     cnt4;// @@@数据长度和t_2250us一致
wire              one_flag;
always @(posedge clk or negedge rst)
    begin
        if(!rst)
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
assign one_flag = (one_en&&(cnt4 <= t_1500us))?1:0;
    
wire   ir_out;
assign ir_out = start_flag||zero_flag||one_flag||connect_flag;
assign IR_out = ir_out&&clk_38k;
assign led_out = led;

endmodule