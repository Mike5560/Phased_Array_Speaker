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

/*This project is designed to drive a parametric speaker with an array of 6x6 40khz transducers. It receives a 0-3.3V audio signal and converts it to a PWM output. //////
//Each vertical column of 6 tranducers share the same output. The speaker can beamform from -30 degrees to positive 30 degrees be controlling the output delays of  //////
each column separately. An analog voltage from a joystick is read 16x per second, which determines what angle will be transmitted.                                  //////      
                                                                                                                                                                    //////  
Modules:  Parametric_Top: 1. Selects which ADC channels are read. 2. Truncates ADC data from 16 to 12 bits.  3. Determines a direction based on joystick input.     //////
          4. Drives all outputs controlled by other modules.                                                                                                        //////
                                                                                                                                                                    //////
          PWM_Generator: Creates a PWM signal from digital audio data at 40.1 KS/S.  Duty cycle is  detmined by amplitude.  This provides the master PWM driver     //////
          for the separate transducer modules to delay from.                                                                                                        //////
                                                                                                                                                                    //////
          LED Bar: Meant for debugging the ADC measurement.  Drives 6 pins to control external LEDs.  All 6 LEDs lit indicates a center position.                   //////
                                                                                                                                                                    //////
          TransX: Receives the master pwm signal from PWM_Generator and the direction from Parametric_Top to determine delays for each column of transducers.       //////
          Each column has its own module. There are a number of buffers as the modules may need to track a number of signals at a time due to the output delay.     //////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/          


module Parametric_Top(
    input sysclk,
    input [1:0] xa_n,     //Unipolar differential ADC inputs to channels 20 (vauxn4 - audio) and 28 (vauxn12 - joystick)
    input [1:0] xa_p,     //Unipolar differential ADC inputs to channels 20 (vauxp4 - audio) and 28 (vauxp12 - joystick)
    input btn0,
    output pio48,         //transducer 1 signal
    output pio47,         //transducer 1 inverted signal
    output pio46,         //transducer 2 signal
    output pio45,         //transducer 2 inverted signal
    output pio44,         //transducer 3 signal
    output pio43,         //transducer 3 inverted signal
    output pio41,         //transducer 4 signal
    output pio40,         //transducer 4 inverted signal
    output pio33,         //transducer 5 signal
    output pio32,         //transducer 5 inverted signal
    output pio29,         //transducer 6 signal
    output pio28,         //transducer 1 inverted signal
    output pio27          //constant 3.3V output to joystick
    );
    
    parameter JOYSTICK_COUNT = 2499;
    reg [11:0] joystick_counter = 12'h0;  // count to h9C3 -> d2499
    reg [6:0] r_address_reg;              // tells ADC what address (channel) to read from. Drives w_address_out.
    reg [11:0] r_shifted_data_joy;        // ADC input register shifted from 16 to 12 bits when read from joystick channel
    reg [15:0] r_unshifted_data_joy;      // registered incoming 16 bit ADC joystick data
    reg [15:0] r_unshifted_data_aud;      // registered incoming 16 bit ADC audio data
    reg [11:0] r_shifted_data_aud;        // ADC input register shifted from 16 to 12 bits when read from audio channel
    reg [3:0] dir_reg = 4'b0000;          // Register to control beam-formed direction. Doesn't represent an angle, but is enumerated. Drives w_data_dir
    reg [15:0] data_to_adc = 16'h0;       // placeholder for data to adc, driven to 0, never changes.  
    reg r_aud_ready = 1'b0;               // register for audio data valid
    reg [1:0] r_addr_DV = 2'b0;           // 2'b0 = no data valid, 2'b01 = audio valid, 2'b10 = joystick valid
    reg r_btn0_pressed = 1'b0;            // reg for btn0
    wire [15:0] data;                     // wire in from ADC data out
    wire w_aud_ready;                     // output wire audio data ready
    wire ready;                           // wire in from ADC ready out
    wire enable;                          // wire from ADC eoc_out (end of conversion); connected to ADC (enable) den_in
    wire i_PWM;                           // input master PWM signal from PWM_Generator
    wire [3:0] w_data_dir;                // Wire drivern by dir_reg to control beam-formed direction. Doesn't represent an angle, but is enumerated.
    wire [11:0] w_data_aud;               // Shifted audio data to PWM_Generator            
    wire [15:0] di_in;                    // Data to ADC. Driven to 0.
    wire [6:0] w_address_out;             // tells ADC what address (channel) to read from.
    

    PWM_Generator PWM_inst
      (.sysclk(sysclk),
       .i_aud_ready(w_aud_ready),
       .data_in(w_data_aud),
       .w_PWM(i_PWM)
    );
   
    xadc_wiz_0 ADC_inst (               // ADC IP instantiation
      .di_in(di_in[15:0]),              // input wire [15 : 0] di_in
      .daddr_in(w_address_out[6:0]),    // input wire [6 : 0] daddr_in
      .den_in(enable),                  // input wire den_in
      .dwe_in(0),                       // input wire dwe_in
      .drdy_out(ready),                 // output wire drdy_out
      .do_out(data[15:0]),              // output wire [15 : 0] do_out
      .dclk_in(sysclk),                 // input wire dclk_in
      .vp_in(0),                        // input wire vp_in
      .vn_in(0),                        // input wire vn_in
      .vauxp4(xa_p[0]),                 // input wire vauxp4
      .vauxn4(xa_n[0]),                 // input wire vauxn4
      .vauxp12(xa_p[1]),                // input wire vauxp12
      .vauxn12(xa_n[1]),                // input wire vauxn12
      .channel_out(),                   // output wire [4 : 0] channel_out
      .eoc_out(enable),                 // output wire eoc_out
      .alarm_out(),                     // output wire alarm_out
      .eos_out(),                       // output wire eos_out
      .busy_out()                       // output wire busy_out
);
      
    /*LED_Bar LED_Bar_inst(             //Test module for ADC input / output
      .sysclk(sysclk),
      .w_LED_dir(w_data_dir),
      .pio45(pio45),
      .pio42(pio42),
      .pio39(pio39),
      .pio36(pio36),
      .pio33(pio33),
      .pio30(pio30)
    );*/
    
    Transducer1 Trans1_inst(  
      .sysclk(sysclk),
      .w_master_signal(i_PWM),
      .i_delaycnt(w_data_dir),
      .w_out_signal(pio48)
    );
    Transducer2 Trans2_inst(
      .sysclk(sysclk),
      .w_master_signal(i_PWM),
      .i_delaycnt(w_data_dir),
      .w_out_signal(pio46)
    );
    Transducer3 Trans3_inst(
      .sysclk(sysclk),
      .w_master_signal(i_PWM),
      .i_delaycnt(w_data_dir),
      .w_out_signal(pio44)
    );
    Transducer4 Trans4_inst(
      .sysclk(sysclk),
      .w_master_signal(i_PWM),
      .i_delaycnt(w_data_dir),
      .w_out_signal(pio41)
    );
    Transducer5 Trans5_inst(
      .sysclk(sysclk),
      .w_master_signal(i_PWM),
      .i_delaycnt(w_data_dir),
      .w_out_signal(pio33)
    );
    Transducer6 Trans6_inst(
      .sysclk(sysclk),
      .w_master_signal(i_PWM),
      .i_delaycnt(w_data_dir),
      .w_out_signal(pio29)
    );
    
    assign di_in = data_to_adc; //set data to ADC to an unchanging "0"
    //adjust JOYSTICK_COUNT parameter as desired. It's set to sample the joystick 40,000 / 2,500 (16x) per second
           
    always@(posedge sysclk)     //set address to ADC, increment joystick counter, set r_addr_DV value
      begin                     
        if(ready)               //execute only if ADC has valid data (ready)
          begin
            if(joystick_counter >= JOYSTICK_COUNT)
              begin
                joystick_counter <= 12'h0;
                r_address_reg <= 7'h1C;                     //when joystick counter reaches max value, sample audio for one more cycle (address 7'h1C)
                r_addr_DV <= 2'b01;                         //leave 2'b01 to sample audio for one more cycle
              end
            else if(joystick_counter == 12'h0)
              begin
                r_addr_DV <= 2'b10;                         //set to 2'b10 to sample joystick
                r_address_reg <= 7'h14;
                joystick_counter <= joystick_counter + 1;   //increment to exit the 'if' condition on next ready signal
              end
            else
              begin
                r_addr_DV <= 2'b01;
                joystick_counter <= joystick_counter + 1;   //increment joystick counter and sample audio by default
                r_address_reg <= 7'h14;
              end
          end
        else
          begin
            r_addr_DV <= 2'b00;   //set r_addr_DV to 2'b00 if ADC is not ready
          end
      end
      
    always@(posedge sysclk)
      begin
        case(r_addr_DV)         
          2'b01:                  //register audio data, set r_aud_ready to 1'b1 (HIGH)                   
            begin
              r_shifted_data_aud <= (data >> 4);
              r_aud_ready <= 1'b1;
            end
          2'b10:                  //register joystick data, set r_aud_ready to 1'b0 (LOW) 
            begin
              r_shifted_data_joy <= (data >> 4);
              r_aud_ready <= 1'b0;
            end
          default:             
            begin               
              r_aud_ready <= 1'b0;
            end
        endcase
      end
      
    assign w_data_aud = r_shifted_data_aud;    // output audio data to PWM_Generator Module
    assign w_aud_ready = r_aud_ready;          // output audio ready signal to PWM_Generator Module
      
    assign w_address_out = r_address_reg;      //output desired ADC channel address
      
    //values for dir_reg are not numerically linear to the corresponding ADC values. This is because both the
    //joystick and CMOD XADC inputs contain voltage dividers and present a nonlinear curve.
    always@(posedge sysclk)
      begin
        r_btn0_pressed <= btn0;
        if(r_btn0_pressed)
          begin
            dir_reg <= 4'b1101;
          end
        else if(r_shifted_data_joy <= 12'hBF)  //30 left
          begin
            dir_reg <= 4'b0000;
          end
        else if((r_shifted_data_joy > 12'hBF) && (r_shifted_data_joy <= 12'h17E))  //25 left
          begin
            dir_reg <= 4'b0001;
          end
        else if((r_shifted_data_joy > 12'h17E) && (r_shifted_data_joy <= 12'h23D)) //20 left
          begin
            dir_reg <= 4'b0010;
          end
        else if((r_shifted_data_joy > 12'h23D) && (r_shifted_data_joy <= 12'h2FC))  //15 left
          begin
            dir_reg <= 4'b0011;
          end
        else if((r_shifted_data_joy > 12'h2FC) && (r_shifted_data_joy <= 12'h3BB))  //10 left
          begin
            dir_reg <= 4'b0100;
          end
        else if((r_shifted_data_joy > 12'h3BB) && (r_shifted_data_joy <= 12'h47A))  //5 left
          begin
            dir_reg <= 4'b0101;
          end
        else if((r_shifted_data_joy > 12'h47A) && (r_shifted_data_joy <= 12'h5B0))  //center
          begin
            dir_reg <= 4'b0110;
          end
        else if((r_shifted_data_joy > 12'h5B0) && (r_shifted_data_joy <= 12'h768)) //5 right
          begin
            dir_reg <= 4'b0111;
          end
        else if((r_shifted_data_joy > 12'h768) && (r_shifted_data_joy <= 12'h920)) //10 right
          begin
            dir_reg <= 4'b1000;
          end
        else if((r_shifted_data_joy > 12'h920) && (r_shifted_data_joy <= 12'hAD8)) //15 right
          begin
            dir_reg <= 4'b1001;
          end
        else if((r_shifted_data_joy > 12'hAD8) && (r_shifted_data_joy <= 12'hC90)) //20 right
          begin
            dir_reg <= 4'b1010;
          end
        else if((r_shifted_data_joy > 12'hC90) && (r_shifted_data_joy <= 12'hE48)) //25 right
          begin
            dir_reg <= 4'b1011;
          end
        else                                                                       //30 right
          begin
            dir_reg <= 4'b1100;
          end
      end
      
    assign w_data_dir = dir_reg;  //output 4 bit direction value to TransX modules
    
    assign pio47 = ~pio48;        //complimentary outputs
    assign pio45 = ~pio46;
    assign pio43 = ~pio44;
    assign pio40 = ~pio41;
    assign pio32 = ~pio33;
    assign pio28 = ~pio29;
    
    assign pio27 = 1'b1;          //output HIGH to supply 3.3V to joystick
          
      
endmodule
