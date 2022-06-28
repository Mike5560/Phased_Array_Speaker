`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2022 11:00:03 AM
// Design Name: 
// Module Name: Parametric_Testbench
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


module Parametric_Testbench(
    );
    parameter JOYSTICK_COUNT = 2499;
    reg sysclk;
    reg [11:0] joystick_counter;          // count to 9C3 - 2500
    reg [6:0] r_address_reg;              // tells ADC what address (channel) to read from. Drives w_address_out.
    reg [11:0] r_shifted_data_joy;        // ADC input register shifted from 16 to 12 bits when read from joystick channel
    reg [15:0] r_unshifted_data_joy;      // registered incoming 16 bit ADC joystick data
    reg [15:0] r_unshifted_data_aud;      // registered incoming 16 bit ADC audio data
    reg [11:0] r_shifted_data_aud;        // ADC input register shifted from 16 to 12 bits when read from audio channel
    reg [3:0] dir_reg;                    // Register to control beam-formed direction. Doesn't represent an angle, but is enumerated. Drives w_data_dir
    reg reset;                            // placeholder for using a reset function on ADC. Not used
    reg [15:0] data_to_adc;               // placeholder for data to adc, driven to 0, never changes. 
    reg vauxn4;
    reg vauxp4;
    reg vauxp12;
    reg vauxn12;
    wire [1:0] xa_n;
    wire [1:0] xa_p;        
    wire [15:0] data;                     // wire in from ADC data out
    wire ready;                           // wire in from ADC ready out
    wire enable;                          // wire from ADC eoc_out (end of conversion); connected to ADC (enable) den_in
    wire i_PWM;                           // input master PWM signal from PWM_Generator
    wire [3:0] w_data_dir;                // Wire drivern by dir_reg to control beam-formed direction. Doesn't represent an angle, but is enumerated.
    wire [11:0] w_data_aud;               // Shifted audio data to PWM_Generator            
    wire [15:0] di_in;                    // Data to ADC. Driven to 0.
    wire [6:0] w_address_out;             // tells ADC what address (channel) to read from.
    
    Parametric_Top Top_inst(
    .sysclk(sysclk),
    .xa_n(xa_n[1:0]),
    .xa_p(xa_p[1:0]),
    .pio48(pio48),
    .pio47(pio47),
    .pio46(pio46),
    .pio45(pio45),
    .pio44(pio44),
    .pio43(pio43),
    .pio41(pio41),
    .pio40(pio40),
    .pio33(pio33),
    .pio32(pio32),
    .pio29(pio29),
    .pio28(pio28),
    .pio27(pio27)
    );
    
   
    initial
      begin
        sysclk = 1'b0;
        forever #41.66 sysclk = ~sysclk;
      end
      
   
endmodule
