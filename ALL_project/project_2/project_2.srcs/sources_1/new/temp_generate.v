`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/04 14:49:51
// Design Name: 
// Module Name: temp_generate
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module temp_generate(clk_125M,nRST,Data,data1);//module temp(clk_125M,nRST,Data,data1);
input clk_125M,nRST;
inout Data;
output data1;

reg [7:0]cnt;
reg [31:0]counter;
reg [4:0]state;
reg[5:0] rec=0;
reg read_begin;
reg [39:0]data,data1;
reg read_done;
reg data_reg;
reg flag;
reg clk;//1MHz

parameter divd=63;
parameter state0=0;
parameter state1=1;
parameter state2=2;
parameter state3=3;
parameter state4=4;
parameter state5=5;
parameter state6=6;
parameter state7=7;
parameter state8=8;
parameter state9=9;
parameter state10=10;
parameter state11=11;
parameter state12=12;
assign Data=(flag)?data_reg:1'bz;

assign LED={data1[19],data1[18],data1[17],data1[16]};

always@(posedge clk_125M)
if(nRST)
begin
    cnt<=0;
    clk<=0;    
end

else begin
	if(cnt<divd)
		cnt<=cnt+8'b1;
	else
	  begin
		cnt<=8'b0;
		clk<=~clk;
	  end
	end
	
	
always @(posedge clk or posedge nRST )//shang sheng yan qu dong 

begin
if(nRST)
begin
  state<=0 ;
  data<=0;
  counter<=0;
  rec<=0;
  data1<=0;
end
else
begin   
case (state)
  state0:begin
         if(counter>=500000)//0.5s
           begin
             counter<=0;
              state<=state1;
              
           end
           else
           begin
           data<=0;
              flag<=1;
              data_reg<=1;
              read_done<=0;             
              counter<=counter+1;//
             
           end
           end
  state1:
      begin
         if(counter>=19000)   //19ms
           begin
//           flag<=0;
           state<=state2;
           counter<=0;
           data_reg<=1;
           end
           else
           begin
           data_reg<=0;
           counter<=counter+1'b1;
           end 
      end 
  state2:
      begin
        counter<=counter+1'b1;
         if(counter==20)      //20us~30us
           begin
              state<=state3;
              counter<=0; 
              flag<=0;            
           end
       end
  state3:
       begin
         if(Data==1)
            begin
               state<=state3;
               counter<=counter+1'b1;
                if(counter==30)      //20us~30us
                         begin
                            state<=state0;
                            counter<=0;            
                         end
                
             end
         else
           begin
                state<=state4;
                 
           end
         end
 state4:
       begin
          if(Data==0)
             begin

               state<=state4;
             end
          else
              begin
             
                state<=state5;
              end
       end
  state5:
         begin
            if(Data==1)
              begin
                state<=state5;
                
              end
            else
              begin
              
                state<=state6;
              end
          end
  state6: 
           begin
              if(Data==0)
               begin
                 state<=state6;
               end
              else
                begin
                
                 read_begin<=1;
                 state<=state7;
              
              
                end
            end
      state7:
           begin
              if(Data==1)
                begin
                state<=state8;               
                end
           end
      state8:
       begin
         if(counter>=50)     //50us

            begin
             counter<=0;
              state<=state9; 
            end           
          else 
             begin     
             counter<=counter+1;
             state<=state8;
           end
       end
   //////////////////    
    state9:
        begin
                 if(Data==1)                
                       begin
                        data[0]<=1;
                       
                       end
                           
                   else 
                       begin
                        data[0]<=0;   
                        end
                  state<=state12;
                  rec<=rec+1;
           end
 // ////////////////////////////////////////////       
                         
         
   state12:
        begin 
        if(rec >= 40)
        begin
            state<=state0;
            rec <= 0;
            data1<=data;
            counter<=0;
        end
        else
        begin
            data<= data<<1;
            if(Data==1)
            state<=state10;
            else
            state<=state11;
        end
        
        end
                              
  state10:
                begin
                   if(Data==1)
                      begin
                      state<=state10;              
                      end
                   else
                      begin
                      state<=state11;
                      end
                 end
                              
         state11:
               begin
                  if(Data==0)
                    begin
                      state<=state11;                
                    end
                  else
                    begin
                      state<=state8;
                    end
               end   
          default: begin state<=state0;end            
  endcase           
end
end
endmodule 
