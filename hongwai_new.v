`timescale 1ns / 1ps
module hongwai(clk,rst,key_1,IR_out,led_out);
input clk;
input rst;
input key_1; //
wire [31:0] IR_in_data35_1;
wire [2:0] IR_in_data35_0;
wire [31:0] IR_in_data32;
output IR_out;
output led_out; //
// output IR_outt;
// output IR_outt_rev;

wire IR_in_data35;
assign IR_in_data35 = {IR_in_data35_1,IR_in_data35_0};

reg led;
reg [34:0] data35;
reg [31:0] data32;
reg [31:0] data32temp;

// parameter t_38k    = 12'd2631;//100MHz/38kHz
// parameter t_38k_half = 12'd1316;
// parameter t_9ms    = 21'd9000000;//100MHz*9ms
// parameter t_4_5ms  = 20'd450000;
// parameter t_13_5ms = 21'd1350000;
// parameter t_20000us = 22'd2000000;
// parameter t_20750us = 22'd2075000;
// parameter t_750us = 17'd75000;
// parameter t_450us = 16'd45000;
// parameter t_1500us = 18'd150000;
// parameter t_1200us = 18'd120000;
// parameter t_2250us = 19'd225000;
// PS 100MHz

parameter t_38k    = 12'd3289;//125MHz/38kHz
parameter t_38k_half = 12'd1644;
parameter t_9ms    = 21'd1125000;//125MHz*9ms
parameter t_4_5ms  = 20'd562500;
parameter t_13_5ms = 21'd1687500;
parameter t_20000us = 22'd2500000;
parameter t_20750us = 22'd2575000;
parameter t_750us = 17'd75000;
parameter t_450us = 16'd75000;
parameter t_1500us = 18'd200000;
parameter t_1200us = 18'd150000;
parameter t_2250us = 19'd275000;

//----------------------------------------------//
reg  [12:0] cnt1;
wire  clk_38k;
always @(posedge clk)
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
//----------------------------------------------//

//----------------------------------------------//

parameter  IDEL       = 3'D0;        //
parameter  START      = 3'D1;        //
parameter  SEND_35    = 3'D2;        //
parameter  CONNECT    = 3'D3;        //
parameter  SEND_32    = 3'D4;        //
reg   [2:0]     state;
reg             start_en;//
wire            start_over;//
reg             zero_en;
wire            zero_over;//
reg             one_en;
wire            one_over;
reg             connect_en;
wire            connect_over;
reg             data35_over;
reg             data32_over;
reg             idel_flag;
// reg             kaiguan;

reg   [5:0]     i;//

always @(posedge clk)
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
                i <= 6'd34; //
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
                            i <= 6'd34;//
                            led <= 0;//
                            idel_flag <= 1;
                            if(key_1)//
                                begin
                                    state <= START;    
                                    data35 <= 35'b10000010000100000000010000001010010;
                                    data32 <= 32'b00001000000001000000000000000110;
                                    idel_flag <= 0;
                                end
                            else 
                                begin
                                    if(data32temp != data32)//
                                        begin//
                                            data35 <= IR_in_data35;
                                            data32 <= IR_in_data32;
                                            state <= START;
                                            idel_flag <= 1;
                                        end
                                    else state <= IDEL;//
                                end
                        end
                    START:  //
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
                    SEND_35:    //
                        begin
                            if(data35_over)
                                begin  
                                    i <= 6'd31;    //
                                    one_en <= 0;
                                    zero_en <= 0;
                                    state <= CONNECT;
                                end
                            else 
                                begin
                                    if(zero_over||one_over)   //
                                        begin
                                            if (i==0) //
                                                data35_over <= 1;
                                            i <= i - 1; //
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
                    CONNECT:  //
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
                    SEND_32:    //
                        begin
                            if(data32_over)
                                begin  
                                    i <= 6'd34;    //
                                    one_en <= 0;
                                    zero_en <= 0;
                                    data32temp <= data32;//
                                    state <= IDEL;
                                end
                            else 
                                begin
                                    if(zero_over||one_over)   //
                                        begin
                                            if (i==0) //
                                                data32_over <= 1;
                                            i <= i - 1; 
                                            one_en <= 0;
                                            zero_en <= 0;
                                            led <= 1;
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


//----------------------------------------------//
reg    [20:0]cnt2;
wire         start_flag;
always @(posedge clk)
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


reg    [21:0]     cnt5;
wire              finish_flag;
always @(posedge clk)
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

reg    [17:0]     cnt3;
wire              zero_flag;
always @(posedge clk)
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
reg    [18:0]     cnt4;
wire              one_flag;
always @(posedge clk)
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
assign IR_out = (~ir_out)&&clk_38k;
// assign IR_outt_rev = ~IR_outt;
// assign IR_outt = (~ir_out)&&clk_38k;
assign led_out = led;

endmodule