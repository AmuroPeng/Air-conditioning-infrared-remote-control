`timescale 1ns/1ps

module testbench();
 
reg clk, rst, key_1;
wire IR_out, led_out; 
// wire [3:0] count; 
// reg [34:0] IR_in_data35;
// reg [31:0] IR_in_data32;
   
hongwai U0 ( 
.clk (clk), 
.rst   (rst), 
.key_1 (key_1), 
// .IR_in_data35   (IR_in_data35),
// .IR_in_data32   (IR_in_data32),
.IR_out (IR_out),
.led_out (led_out)
); 
   
initial begin
   clk = 0; 
//    IR_in_data35 = 35'b11111000001111100000111110000011111;
//    IR_in_data32 = 32'b11111000001111100000111110000011;
   rst = 0; 
   #10
   rst = 1;
   #10
   rst = 0;
   #100
   key_1 = 1; 
end 
   
always  
   #12.5   clk = !clk; 

endmodule