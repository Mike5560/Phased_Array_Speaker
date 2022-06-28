`timescale 1ns / 1ps
/*Copyright (c) 2022 Michael Kurta

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/

/* This module is a phase-corrected PWM generator; meaning the rising and falling edges are calculated from
the center of the duty period, rather from than the beginning. This produces less harmonics than traditional
fast PWM if you're not using low pass filtering.
*/
module PWM_Generator(
  input sysclk,
  input wire i_aud_ready,               //data ready signal from Top module
  input wire [11:0] data_in,            //12 bit audio ADC data
  output wire w_PWM                     //master output to transX modules
    );
    
  parameter clks_per_period = 299;      //12Mhz / 40Khz sampling = 299+1
  parameter midpoint = 149;             //midpoint for PWM cycle
  reg [18:0] temp_mult = 19'h0;         //temporary multiply register for cross-multiply function
  reg r_rs1 = 1'b0;                     //rising edge flag
  reg r_fs1 = 1'b0;                     //falling edge flag
  reg r_aud_ready = 1'b0;               //registered audio ready signal
  reg r_signal_out = 1'b0;              //registered output signal
  reg [7:0] r_half_value = 8'h0;        //half of PWM on duty cycle to subtract from and add to midpoint
  reg [11:0] amplitude = 12'h0;         //registered 12-bit audio ADC data
  reg [8:0] shifted_amplitude = 9'h0;   //amplitude right-shifted by 3
  reg [11:0] period_counter = 12'h0;    //counter to track progress through duty cycle
  reg [8:0] rising_period_old = 9'h0;   //when period counter passes this number, trigger a rising edge
  reg [8:0] falling_period_old = 9'h0;  //when period counter passes this number, trigger a falling edge
  reg [8:0] rising_period = 9'h0;       //temporary register for rising_period_old
  reg [8:0] falling_period = 9'h0;      //temporary register for falling_period_old   

  
  always@(posedge sysclk)                             //transition from one 25us (40Khz) period to the next; or just increment period_counter
    begin
      if(period_counter == clks_per_period)
        begin
          period_counter <= 0;
          falling_period_old <= falling_period;
          rising_period_old <= rising_period;
        end
      else
        begin
          period_counter <= period_counter + 1;
        end
    end
    
  always@(posedge sysclk)                             //trigger rising edge flag 
    begin
      if(period_counter >= rising_period_old)
        begin
          r_rs1 = 1'b1;
        end
      else
        begin
          r_rs1 = 1'b0;
        end
     end
   
  always@(posedge sysclk)                             //trigger falling edge flag 
    begin
      if(period_counter >= falling_period_old)
        begin
          r_fs1 = 1'b1;
        end
      else
        begin
          r_fs1 = 1'b0;
        end
     end
          
    
  always@(posedge sysclk)                             //cross mult; input 12 bit integer (data)/4096 = output (falling_period) / 2500
    begin
      r_aud_ready <= i_aud_ready;                     //registers ready signal
      if(r_aud_ready == 1'b1)
        begin
          amplitude <= data_in;                       //registers data
          shifted_amplitude <= (amplitude >> 3);      //divide by 8
          temp_mult <= shifted_amplitude * 75;        //multiply by 625
          r_half_value <= (temp_mult >> 8);           //divide by 256
          rising_period <= midpoint - r_half_value;   //set desired rising edge clock counter (phase corrected)
          falling_period <= midpoint + r_half_value;  //set desired falling edge clock counter (phase corrected)
        end
    end
    
  always@(posedge sysclk)                             //r_signal_out goes high only when r_rs1 and not r_fs1
    begin
      if(r_rs1 && !r_fs1)
        begin
          r_signal_out <= 1'b1;
        end
      else
        begin
          r_signal_out <= 1'b0;
        end
    end
    
    assign w_PWM = r_signal_out;

    
endmodule
