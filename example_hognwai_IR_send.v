/********************************Copyright**************************************                           
    **----------------------------File information--------------------------
    ** File name  :IR_send.v  
    ** CreateDate :2015.06
    ** Funtions   :红外信号的发送程序,发送格式：引导码+8bit用户码+8bit用户反码（或者用户反码）+8bit数据码+8bit用户反码+结束码
    ** Operate on :M5C06N3L114C7
    ** Copyright  :All rights reserved. 
    ** Version    :V1.0
    **---------------------------Modify the file information----------------
    ** Modified by   :
    ** Modified data :        
    ** Modify Content:
    *******************************************************************************/
     
    module  IR_send  (
               clk,
               rst_n,
               
                         key_1,
                         key_2,
                         
                         IR_out,
                         led_1,
                         led_2,
                         led_3,
                         led_4
                         
//                          testdata
                 );
     input          clk;    //24M/20m
     input          rst_n;
     
     input          key_1; 
     input          key_2;
     
     output         IR_out;
     
     output  reg    led_1;
     output  reg    led_2;
   output       led_3;
     output       led_4;
     
//     output  [7;0]  testdata;
     //-------------------//

    `define     CLK_20M
//    `define     CLK_24M    
//    `define     CLK_50M


 `ifdef      CLK_20M
             parameter t_38k    = 10'd526;
             parameter t_38k_half = 10'd263;
             parameter t_9ms    = 18'd179999;
             parameter t_4_5ms  = 17'd89999;
             parameter t_13_5ms = 19'd269999;
             parameter t_560us  = 14'd11199;
             parameter t_1_12ms = 15'd22399;
             parameter t_1_68ms = 16'd33599;
             parameter t_2_24ms = 16'd44799;
      `endif
        
     `ifdef      CLK_24M
             parameter t_38k    = 10'd630;
             parameter t_38k_half = 10'd315;
             parameter t_9ms    = 18'd215999;
             parameter t_4_5ms  = 17'd107999;
             parameter t_13_5ms = 19'd323999;
             parameter t_560us  = 14'd13439;
             parameter t_1_12ms = 15'd26879;
             parameter t_1_68ms = 16'd40319;
             parameter t_2_24ms = 16'd53759;
      `endif
        
     `ifdef      CLK_50M
             parameter t_38k    = 11'd1315;
             parameter t_38k_half = 10'd657;
             parameter t_9ms    = 19'd449999;
             parameter t_4_5ms  = 18'd224999;             
             parameter t_13_5ms = 20'd674999;
             parameter t_560us  = 15'd27999;
             parameter t_1_12ms = 16'd55999;             
             parameter t_1_68ms = 17'd83999;             
             parameter t_2_24ms = 17'd111999;
      `endif    
        
     parameter DATA_USER = 8'h00;
     
     //---------------------------------//
      //分频38Khz时钟
      reg  [10:0]   cnt1;
        wire         clk_38k;
        always @(posedge clk or negedge rst_n)
         begin
          if(!rst_n)
           begin
               cnt1 <= 0;
            end
          else if(cnt1 == t_38k)
            begin
               cnt1 <= 0;
            end
            else cnt1 <= cnt1 + 1;
         end
  assign  clk_38k = (cnt1<t_38k_half)?1:0;
 //-------------------------------------------//
 
//    wire         key_1_flg;
//        wire         key_2_flg;
//      key_shake   U1(
//            .clk_100M(clk),
//            .rst_n(rst_n),
//           
//            .key_in(key_1),
//            .key_out(key_1_flg)
//             );
//                         
//        key_shake  U2(
//            .clk_100M(clk),
//            .rst_n(rst_n),
//           
//            .key_in(key_2),
//            .key_out(key_2_flg)
//             );
   reg   [2:0]      key_1_flag;
     wire             key_1_neg;
     wire             key_1_pos;
     always @(posedge clk or negedge rst_n)
     begin
      if(!rst_n)
       begin
           key_1_flag <= 3'b000;
        end
      else 
        begin
           key_1_flag <= {key_1_flag[1:0],key_1};
        end
      end
    assign key_1_pos = (key_1_flag[2:1]== 2'b01);
    
    
     reg   [2:0]      key_2_flag;
     wire             key_2_neg;
     wire             key_2_pos;
     always @(posedge clk or negedge rst_n)
     begin
      if(!rst_n)
       begin
           key_2_flag <= 3'b000;
        end
      else 
        begin
           key_2_flag <= {key_2_flag[1:0],key_2};
        end
      end
    assign key_2_pos = (key_2_flag[2:1] == 2'b01);
    
 //------------------------------------------//     
    parameter  IDEL       = 3'D0;        //初始化状态，等待发送命令
        parameter  START      = 3'D1;        //开始发送引导码 
        parameter  SEND_USER  = 3'D2;        //发送用户码
        parameter  SEND_UNUSER= 3'D3;        //发送用户反码
        parameter  SEND_DATA  = 3'D4;        //发送数据
        parameter  SEND_UNDATA= 3'D5;        //发送数据反码
        parameter  FINISH     = 3'D6;        //发送结束码
        parameter  FINISH_1   = 3'D7;        //发送结束
    reg   [2:0]     state;
    reg             start_en;
        wire            start_over;
        reg             zero_en;
        wire            zero_over;
        reg             one_en;
        wire            one_over;
         reg             finish_en;
        wire            finish_over;
        reg             sendover;
        reg   [7:0]     shiftdata;
        reg   [3:0]     i;
        reg   [7:0]     DATA;
        always @(posedge clk or negedge rst_n)
         begin
          if(!rst_n)
           begin
              state <= IDEL;
                    start_en <= 0;
                    zero_en <= 0;
                    one_en <= 0;
                    finish_en <= 0;
                    sendover <= 0;
                    shiftdata <= 0; 
                    i <= 0;
                    DATA <= 8'D0;
                    
                    led_1 <= 1;
                    led_2 <= 1;                    
            end
          else 
            begin
               case(state)
                     IDEL:
                        begin
                          start_en <= 0;
                                zero_en <= 0;
                                one_en <= 0;
                                finish_en <= 0;
                                sendover <= 0; 
                                shiftdata <= 0;
                                i <= 0;
                                DATA <= 8'd0;
                                
                                if(key_1_pos)
                                  begin
                                    state <= START;    
                                        DATA <= 8'd1;
                                    end
                                 else if(key_2_pos)
                                     begin
                                            state <= START;    
                                            DATA <= 8'd2;
                                        end
                                else state <= IDEL;
                         end
                      START:              //发送引导码
                           begin
                                     
                                 if(start_over)    
                                   begin                                         
                                         start_en <= 0;
                                         state <= SEND_USER;    
                                         shiftdata <= DATA_USER;
                                      end
                                 else 
                                      begin
                                         start_en <= 1;
                                         state <= START;     
                                      end     
                            end
                        SEND_USER:
                          begin
//                                    led_3 <= 1;
                                    if((i==7)&&(one_over||zero_over))  //结束位
                                        begin
                                              i <=0;    
                                      shiftdata <= ~DATA_USER;
                                              state <= SEND_UNUSER;
                                                one_en <= 0;
                                              zero_en <= 0;
                                         end
                                    else
                                      begin                                                
                                            if(zero_over||one_over)   //1bit发送结束
                                              begin
                                                i <= i + 1;
                                                     one_en <= 0;
                                                     zero_en <= 0;
                                                 end
                                            else if(shiftdata[i])
                                                begin
                                                     one_en <= 1;       
                                                 end
                                            else if(!shiftdata[i]) zero_en <= 1;
                                          else 
                                                begin
                                                 i <= i ;
                                                     one_en <= one_en;
                                                     zero_en <= zero_en;
                                                 end    
                                       end
                             end
                        SEND_UNUSER:
                           begin
                                    led_1 <= ~led_1;     
                                 if((i==7)&&(one_over||zero_over))  //结束位
                                        begin
                                              i <=0;                                                 
                                              state <= SEND_DATA;
                                                shiftdata <= DATA;
                                                one_en <= 0;
                                                zero_en <= 0;
                                                
                                         end
                                    else
                                      begin                                        
                                            if(zero_over||one_over)   //1bit发送结束
                                              begin
                                                 i <= i + 1;
                                                     one_en <= 0;
                                                     zero_en <= 0;
                                                 end
                                            else if(shiftdata[i])
                                                begin
                                                     one_en <= 1;       
                                                 end
                                            else if(!shiftdata[i]) zero_en <= 1;
                                          else 
                                                begin
                                                 i <= i ;
                                                     one_en <= one_en;
                                                     zero_en <= zero_en;
                                                 end    
                                       end     
                                     
                                end
                        SEND_DATA:
                           begin
                                     led_2 <= ~led_2    ;
                                    if((i==7)&&(one_over||zero_over))  //结束位
                                        begin
                                              i <=0;                                                  
                                              state <= SEND_UNDATA;
                                                shiftdata <= ~DATA;
                                                one_en <= 0;
                                                zero_en <= 0;
                                         end
                                    else
                                      begin                                                
                                            if(zero_over||one_over)   //1bit发送结束
                                              begin
                                                i <= i + 1;
                                                     one_en <= 0;
                                                     zero_en <= 0;
                                                 end
                                            else if(shiftdata[i])
                                                begin
                                                     one_en <= 1;       
                                                 end
                                            else if(!shiftdata[i]) zero_en <= 1;
                                          else 
                                                begin
                                                 i <= i ;
                                                     one_en <= one_en;
                                                     zero_en <= zero_en;
                                                 end    
                                       end 
                                                                          
                                end
                    SEND_UNDATA:
                        begin
                                    
                                if((i==7)&&(one_over||zero_over))  //结束位
                                        begin
                                              i <=0;    
                                              shiftdata <= 0;
                                              state <= FINISH;
                                                one_en <= 0;
                                                zero_en <= 0;
                                         end
                                    else
                                      begin                                            
                                            if(zero_over||one_over)   //1bit发送结束
                                              begin
                                                 i <= i + 1;
                                                     one_en <= 0;
                                                     zero_en <= 0;
                                                 end
                                            else if(shiftdata[i])
                                                begin
                                                     one_en <= 1;       
                                                 end
                                            else if(!shiftdata[i]) zero_en <= 1;
                                          else 
                                                begin
                                                 i <= i ;
                                                     one_en <= one_en;
                                                     zero_en <= zero_en;
                                                 end    
                                       end         
                                    
                                end
                        FINISH:
                           begin
                                    if(finish_over)    
                                    begin
                                         finish_en <= 0;
                                         state <= FINISH_1;     
                                      end
                                   else 
                                      begin
                                         finish_en <= 1;
                                         state <= FINISH;     
                                      end      
                                     
                                 end
                        FINISH_1:
                              begin
                                            
                                      sendover <= 1;
                                        state <= IDEL;
                                        
                              end
                                                
                      default: state <= IDEL;
                    endcase
            end
          end
            
        
        
  //----------------------------------------------//
     //引导码，9ms载波加4.5ms空闲
     reg    [19:0]     cnt2;
     wire              start_flag;
     always @(posedge clk or negedge rst_n)
     begin
      if(!rst_n)
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
    
  //----------------------------------------------//
     //比特0， 560us载波 + 560us空闲
     reg    [15:0]     cnt3;
     wire              zero_flag;
     always @(posedge clk or negedge rst_n)
     begin
      if(!rst_n)
       begin
           cnt3 <= 0;
        end
      else if(zero_en)
        begin
          if(cnt3 >= t_1_12ms)  cnt3 <= t_1_12ms+1;        
            else cnt3 <= cnt3 + 1;
            end
        else cnt3  <= 0;         
     end
    assign zero_over = (cnt3 == t_1_12ms)?1:0;    
    assign zero_flag = (zero_en&&(cnt3 <= t_560us))?1:0;
    
   //----------------------------------------------//
     //比特1， 560us载波 + 1.68ms空闲
     reg    [16:0]     cnt4;
     wire              one_flag;
     always @(posedge clk or negedge rst_n)
     begin
      if(!rst_n)
       begin
           cnt4 <= 0;
        end
      else if(one_en)
        begin
          if(cnt4 >= t_2_24ms)  cnt4 <= t_2_24ms+1;        
            else cnt4 <= cnt4 + 1;
            end
        else cnt4  <= 0;         
     end
    assign one_over = (cnt4 == t_2_24ms)?1:0;    
    assign one_flag = (one_en&&(cnt4 <= t_560us))?1:0;
    
    //----------------------------------------------//
     //结束码， 560us载波 
     reg    [14:0]     cnt5;
     wire              finish_flag;
     always @(posedge clk or negedge rst_n)
     begin
      if(!rst_n)
       begin
           cnt5 <= 0;
        end
      else if(finish_en)
        begin
          if(cnt5 >= t_560us)  cnt5 <= t_560us+1;        
            else cnt5 <= cnt5 + 1;
            end
        else cnt5  <= 0;         
     end
    assign finish_over = (cnt5 == t_560us)?1:0;    
    assign finish_flag = (finish_en&&(cnt5 <= t_560us))?1:0;
    
 //-----------------------------------//
 wire   ir_out;
 assign ir_out = start_flag||zero_flag||one_flag||finish_flag;
 assign IR_out = ir_out&&clk_38k;
 
 assign led_3 = i[1];
 assign led_4 = i[0];
 
    endmodule