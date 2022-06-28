`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2022 10:08:37 AM
// Design Name: 
// Module Name: LED_Bar
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


module LED_Bar(
  input sysclk,
  input wire [3:0] w_LED_dir,
  output pio45, //reg LED_0
  output pio42, //reg LED_1
  output pio39, //reg LED_2
  output pio36, //reg LED_3
  output pio33, //reg LED_4
  output pio30  //reg LED_5
    );
    
  reg [3:0] r_LED_dir = 4'b0110;
  reg LED_0 = 1'b0;  //all LEDs are external LEDs, so "ON" is 1'b1
  reg LED_1 = 1'b0;
  reg LED_2 = 1'b0;
  reg LED_3 = 1'b0;
  reg LED_4 = 1'b0;
  reg LED_5 = 1'b0;
    
  always@(posedge sysclk)
    begin
      r_LED_dir <= w_LED_dir;    //register data
      case(r_LED_dir)
        4'b0000:
          begin
            LED_0 <= 1'b0;
            LED_1 <= 1'b0;
            LED_2 <= 1'b0;
            LED_3 <= 1'b0;
            LED_4 <= 1'b0;
            LED_5 <= 1'b0;
          end
        4'b0001:
          begin
            LED_0 <= 1'b1;
            LED_1 <= 1'b0;
            LED_2 <= 1'b0;
            LED_3 <= 1'b0;
            LED_4 <= 1'b0;
            LED_5 <= 1'b0;
          end
        4'b0010:
          begin
            LED_0 <= 1'b1;
            LED_1 <= 1'b1;
            LED_2 <= 1'b0;
            LED_3 <= 1'b0;
            LED_4 <= 1'b0;
            LED_5 <= 1'b0;
          end
        4'b0011:
          begin
            LED_0 <= 1'b1;
            LED_1 <= 1'b1;
            LED_2 <= 1'b1;
            LED_3 <= 1'b0;
            LED_4 <= 1'b0;
            LED_5 <= 1'b0;
          end
        4'b0100:
          begin
            LED_0 <= 1'b1;
            LED_1 <= 1'b1;
            LED_2 <= 1'b1;
            LED_3 <= 1'b1;
            LED_4 <= 1'b0;
            LED_5 <= 1'b0;
          end
        4'b0101:
          begin
            LED_0 <= 1'b1;
            LED_1 <= 1'b1;
            LED_2 <= 1'b1;
            LED_3 <= 1'b1;
            LED_4 <= 1'b1;
            LED_5 <= 1'b0;
          end
        4'b0110:
          begin
            LED_0 <= 1'b1;
            LED_1 <= 1'b1;
            LED_2 <= 1'b1;
            LED_3 <= 1'b1;
            LED_4 <= 1'b1;
            LED_5 <= 1'b1;
          end
        4'b0111:
          begin
            LED_0 <= 1'b0;
            LED_1 <= 1'b1;
            LED_2 <= 1'b1;
            LED_3 <= 1'b1;
            LED_4 <= 1'b1;
            LED_5 <= 1'b1;
          end
        4'b1000:
          begin
            LED_0 <= 1'b0;
            LED_1 <= 1'b0;
            LED_2 <= 1'b1;
            LED_3 <= 1'b1;
            LED_4 <= 1'b1;
            LED_5 <= 1'b1;
          end
        4'b1001:
          begin
            LED_0 <= 1'b0;
            LED_1 <= 1'b0;
            LED_2 <= 1'b0;
            LED_3 <= 1'b1;
            LED_4 <= 1'b1;
            LED_5 <= 1'b1;
          end
        4'b1010:
          begin
            LED_0 <= 1'b0;
            LED_1 <= 1'b0;
            LED_2 <= 1'b0;
            LED_3 <= 1'b0;
            LED_4 <= 1'b1;
            LED_5 <= 1'b1;
          end
        4'b1011:
          begin
            LED_0 <= 1'b0;
            LED_1 <= 1'b0;
            LED_2 <= 1'b0;
            LED_3 <= 1'b0;
            LED_4 <= 1'b0;
            LED_5 <= 1'b1;
          end
        4'b1100:
          begin
            LED_0 <= 1'b0;
            LED_1 <= 1'b0;
            LED_2 <= 1'b0;
            LED_3 <= 1'b0;
            LED_4 <= 1'b0;
            LED_5 <= 1'b0;
          end
      endcase
    end
  
  assign pio45 = LED_0;
  assign pio42 = LED_1;
  assign pio39 = LED_2;
  assign pio36 = LED_3;
  assign pio33 = LED_4;
  assign pio30 = LED_5;
            
endmodule
