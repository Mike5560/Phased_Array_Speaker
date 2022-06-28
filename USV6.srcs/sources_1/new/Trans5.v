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

module Transducer5(
    input sysclk,
    input wire w_master_signal,     //input pwm pin so all transducer mods track rising/falling edges
    input wire [3:0] i_delaycnt,    //4 bit base delay input based on input angle 
    output wire w_out_signal        //output piox == module trans_x
    );
    
reg [11:0] r_rising_counter = 12'h0;    // counters to track rising edges
reg [11:0] r_rising_counter2 = 12'h0;
reg [11:0] r_rising_counter3 = 12'h0;
reg [11:0] r_rising_counter4 = 12'h0;
reg [11:0] r_rising_counter5 = 12'h0;
reg [11:0] r_rising_counter6 = 12'h0;
reg [11:0] r_rising_counter7 = 12'h0;
reg [11:0] r_rising_counter8 = 12'h0;
reg [11:0] r_rising_counter9 = 12'h0;
reg [11:0] r_rising_counter10 = 12'h0;
reg [11:0] r_falling_counter = 12'h0;   // counters to track falling edges
reg [11:0] r_falling_counter2 = 12'h0;
reg [11:0] r_falling_counter3 = 12'h0;
reg [11:0] r_falling_counter4 = 12'h0;
reg [11:0] r_falling_counter5 = 12'h0;
reg [11:0] r_falling_counter6 = 12'h0;
reg [11:0] r_falling_counter7 = 12'h0;
reg [11:0] r_falling_counter8 = 12'h0;
reg [11:0] r_falling_counter9 = 12'h0;
reg [11:0] r_falling_counter10 = 12'h0;
reg [11:0] r_mult_match = 12'h5;        // target count to reach
wire w_rising_trigger;                  // trigger to alert rising counters to start count
wire w_falling_trigger;                 // trigger to alert falling counters to start count
reg r_rising = 1'b0;                    // captures the master signal rising edge
reg r_falling = 1'b1;                   // captures the master signal falling edge
reg r_rmeta = 1'b0;                     // double flop to captured master signal (rising)
reg r_fmeta = 1'b1;                     // double flop to captured master signal (falling)
reg r_pio1 = 1'b0;                      // reg to control GPIO, or in this case, w_out_signal
reg r_rsync = 1'b0;                     // rising sync signal (third flip flop)
reg r_rsync_old = 1'b0;                 // rising sync signal (fourth flip flop)
reg r_fsync = 1'b0;                     // falling sync signal (third flip flop)
reg r_fsync_old = 1'b0;                 // falling sync signal (fourth flip flop)
reg r_r1 = 1'b0;                        // register that compares first five rising counter signal states; outputs to r_pio1
reg r_r2 = 1'b0;                        // register that compares last five rising counter signal states; outputs to r_pio1
reg r_f1 = 1'b0;                        // register that compares first five falling counter signal states; outputs to r_pio1
reg r_f2 = 1'b0;                        // register that compares last five falling counter signal states; outputs to r_pio1
reg r_rs1 = 1'b0;                       // output flag of rising counter 1
reg r_rs2 = 1'b0;                       // ....
reg r_rs3 = 1'b0;                       // ....
reg r_rs4 = 1'b0;                       // ....
reg r_rs5 = 1'b0;                       // ....
reg r_rs6 = 1'b0;                       // ....
reg r_rs7 = 1'b0;                       // ....
reg r_rs8 = 1'b0;                       // ....
reg r_rs9 = 1'b0;                       // ....
reg r_rs10 = 1'b0;                      // ....
reg r_fs1 = 1'b0;                       // output flag of falling counter 1
reg r_fs2 = 1'b0;                       // ....
reg r_fs3 = 1'b0;                       // ....
reg r_fs4 = 1'b0;                       // ....
reg r_fs5 = 1'b0;                       // ....
reg r_fs6 = 1'b0;                       // ....
reg r_fs7 = 1'b0;                       // ....
reg r_fs8 = 1'b0;                       // ....
reg r_fs9 = 1'b0;                       // ....
reg r_fs10 = 1'b0;                      // ....
reg [3:0] r_delaycnt = 4'b0000;         //reg input from top to set mult_match
reg [4:0] r_rnext = 4'b0001;            // determines next rising counter in queue
reg [4:0] r_fnext = 4'b0001;            // determines next falling counter in queue

//capture angle variable into reg (value 0-12)
always @(posedge sysclk)
begin
    r_delaycnt <= i_delaycnt;
end

always @ (posedge sysclk) //determing multiple counter based on angle
begin
    case(r_delaycnt)
        
        4'h0 : begin  //30 degrees left
        r_mult_match <= 12'h3D8;
        end
        4'h1 : begin  //25 degrees left
        r_mult_match <= 12'h340;
        end
        4'h2 : begin  //20 degrees left
        r_mult_match <= 12'h2A3;
        end
        4'h3 : begin  //15 degrees left
        r_mult_match <= 12'h200;
        end
        4'h4 : begin  //10 degrees left
        r_mult_match <= 12'h159;
        end
        4'h5 : begin  //5 degrees left
        r_mult_match <= 12'hAF;
        end
        4'h6 : begin  //0 degrees
        r_mult_match <= 12'h5;
        end
        4'h7 : begin  //5 degrees right
        r_mult_match <= 12'h2F;
        end
        4'h8 : begin  //10 degrees right
        r_mult_match <= 12'h5A;
        end
        4'h9 : begin  //15 degrees right
        r_mult_match <= 12'h83;
        end
        4'hA : begin  //20 degrees right
        r_mult_match <= 12'hAC;
        end
        4'hB : begin  //25 degrees right
        r_mult_match <= 12'hD3;
        end
        4'hC : begin  //30 degrees right
        r_mult_match <= 12'hF9;
        end
        4'hD : begin
        r_mult_match <= 12'h13;
        end
        default: begin // dero delay for errors or no reading
        r_mult_match <= 12'h5;
        end
    endcase
end

always@ (posedge sysclk) //If a counter reaches 1, assign r_rnext to next counter
begin
    if(r_rising_counter == 12'h1)
        r_rnext <= 4'b0010;
    if(r_rising_counter2 == 12'h1)
        r_rnext <= 4'b0011;
    if(r_rising_counter3 == 12'h1)
        r_rnext <= 4'b0100;
    if(r_rising_counter4 == 12'h1)
        r_rnext <= 4'b0101;
    if(r_rising_counter5 == 12'h1)
        r_rnext <= 4'b0110;
    if(r_rising_counter6 == 12'h1)
        r_rnext <= 4'b0111;
    if(r_rising_counter7 == 12'h1)
        r_rnext <= 4'b1000;
    if(r_rising_counter8 == 12'h1)
        r_rnext <= 4'b1001;
    if(r_rising_counter9 == 12'h1)
        r_rnext <= 4'b1010;
    if(r_rising_counter10 == 12'h1)
        r_rnext <= 4'b0001;
end

always @(posedge sysclk) //rising edge detection on pio20
begin
    r_rising <= w_master_signal;
    r_rmeta <= r_rising;
    r_rsync <= r_rmeta;
    r_rsync_old <= r_rsync;
end
                

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_rnext <= 4'b0001 && w_rising_trigger == 1'b1) || (r_rising_counter > 0))
        if(r_rising_counter >= r_mult_match)
            begin
                r_rising_counter <= 12'h0;
                r_rs1 <= 1'b1;
            end
        else
            begin
                r_rising_counter <= r_rising_counter + 1;
                r_rs1 <= 1'b0;
            end
    else
        r_rs1 <= 1'b0;
end            

always @(posedge sysclk)
begin
    if((r_rnext == 4'b0010 && w_rising_trigger == 1'b1) || (r_rising_counter2 > 0))
        if(r_rising_counter2 >= r_mult_match)
            begin
                r_rising_counter2 <= 12'h0;
                r_rs2 <= 1'b1;
            end
        else
            begin
                r_rising_counter2 <= r_rising_counter2 + 1;
                r_rs2 <= 1'b0;
            end
    else
        r_rs2 <= 1'b0;
end

always @(posedge sysclk)
begin
    if((r_rnext == 4'b0011 && w_rising_trigger == 1'b1) || (r_rising_counter3 > 0))
        if(r_rising_counter3 >= r_mult_match)
            begin
                r_rising_counter3 <= 12'h0;
                r_rs3 <= 1'b1;
            end
        else
            begin
                r_rising_counter3 <= r_rising_counter3 + 1;
                r_rs3 <= 1'b0;
            end
    else
        r_rs3 <= 1'b0;
end

always @(posedge sysclk)
begin
    if((r_rnext == 4'b0100 && w_rising_trigger == 1'b1) || (r_rising_counter4 > 0))
        if(r_rising_counter4 >= r_mult_match)
            begin
                r_rising_counter4 <= 12'h0;
                r_rs4 <= 1'b1;
            end
        else
            begin
                r_rising_counter4 <= r_rising_counter4 + 1;
                r_rs4 <= 1'b0;
            end
    else
        r_rs4 <= 1'b0;
end

always @(posedge sysclk)
begin
    if((r_rnext == 4'b0101 && w_rising_trigger == 1'b1) || (r_rising_counter5 > 0))
        if(r_rising_counter5 >= r_mult_match)
            begin
                r_rising_counter5 <= 12'h0;
                r_rs5 <= 1'b1;
            end
        else
            begin
                r_rising_counter5 <= r_rising_counter5 + 1;
                r_rs5 <= 1'b0;
            end
    else
        r_rs5 <= 1'b0;
end

always @(posedge sysclk)
begin
    if((r_rnext == 4'b0110 && w_rising_trigger == 1'b1) || (r_rising_counter6 > 0))
        if(r_rising_counter6 >= r_mult_match)
            begin
                r_rising_counter6 <= 12'h0;
                r_rs6 <= 1'b1;
            end
        else
            begin
                r_rising_counter6 <= r_rising_counter6 + 1;
                r_rs6 <= 1'b0;
            end
    else
        r_rs6 <= 1'b0;
end

always @(posedge sysclk)
begin
    if((r_rnext == 4'b0111 && w_rising_trigger == 1'b1) || (r_rising_counter7 > 0))
        if(r_rising_counter7 >= r_mult_match)
            begin
                r_rising_counter7 <= 12'h0;
                r_rs7 <= 1'b1;
            end
        else
            begin
                r_rising_counter7 <= r_rising_counter7 + 1;
                r_rs7 <= 1'b0;
            end
    else
        r_rs7 <= 1'b0;
end

always @(posedge sysclk)
begin
    if((r_rnext == 4'b1000 && w_rising_trigger == 1'b1) || (r_rising_counter8 > 0))
        if(r_rising_counter8 >= r_mult_match)
            begin
                r_rising_counter8 <= 12'h0;
                r_rs8 <= 1'b1;
            end
        else
            begin
                r_rising_counter8 <= r_rising_counter8 + 1;
                r_rs8 <= 1'b0;
            end
    else
        r_rs8 <= 1'b0;
end

always @(posedge sysclk)
begin
    if((r_rnext == 4'b1001 && w_rising_trigger == 1'b1) || (r_rising_counter9 > 0))
        if(r_rising_counter9 >= r_mult_match)
            begin
                r_rising_counter9 <= 12'h0;
                r_rs9 <= 1'b1;
            end
        else
            begin
                r_rising_counter9 <= r_rising_counter9 + 1;
                r_rs9 <= 1'b0;
            end
    else
        r_rs9 <= 1'b0;
end

always @(posedge sysclk)
begin
    if((r_rnext == 4'b1010 && w_rising_trigger == 1'b1) || (r_rising_counter10 > 0))
        if(r_rising_counter10 >= r_mult_match)
            begin
                r_rising_counter10 <= 12'h0;
                r_rs10 <= 1'b1;
            end
        else
            begin
                r_rising_counter10 <= r_rising_counter10 + 1;
                r_rs10 <= 1'b0;
            end
    else
        begin
            r_rs10 <= 1'b0;
        end
end
          
always @(posedge sysclk) //rising edge detection on pio20
begin
    r_falling <= w_master_signal;
    r_fmeta <= r_falling;
    r_fsync <= r_fmeta;
    r_fsync_old <= r_fsync;
end

always@ (posedge sysclk)
begin
    if(r_falling_counter == 12'h1)
        r_fnext <= 4'b0010;
    if(r_falling_counter2 == 12'h1)
        r_fnext <= 4'b0011;
    if(r_falling_counter3 == 12'h1)
        r_fnext <= 4'b0100;
    if(r_falling_counter4 == 12'h1)
        r_fnext <= 4'b0101;
    if(r_falling_counter5 == 12'h1)
        r_fnext <= 4'b0110;
    if(r_falling_counter6 == 12'h1)
        r_fnext <= 4'b0111;
    if(r_falling_counter7 == 12'h1)
        r_fnext <= 4'b1000;
    if(r_falling_counter8 == 12'h1)
        r_fnext <= 4'b1001;
    if(r_falling_counter9 == 12'h1)
        r_fnext <= 4'b1010;
    if(r_falling_counter10 == 12'h1)
        r_fnext <= 4'b0001;
end

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext <= 4'b0001 && w_falling_trigger == 1'b1) || (r_falling_counter > 0))
        if(r_falling_counter >= r_mult_match)
            begin
                r_falling_counter <= 12'h0;
                r_fs1 <= 1'b1;
            end
        else
            begin
                r_falling_counter <= r_falling_counter + 1;
                r_fs1 <= 1'b0;
            end
    else
        r_fs1 <= 1'b0;
end  

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b0010 && w_falling_trigger == 1'b1) || (r_falling_counter2 > 0))
        if(r_falling_counter2 >= r_mult_match)
            begin
                r_falling_counter2 <= 12'h0;
                r_fs2 <= 1'b1;
            end
        else
            begin
                r_falling_counter2 <= r_falling_counter2 + 1;
                r_fs2 <= 1'b0;
            end
    else
        r_fs2 <= 1'b0;
end  

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b0011 && w_falling_trigger == 1'b1) || (r_falling_counter3 > 0))
        if(r_falling_counter3 >= r_mult_match)
            begin
                r_falling_counter3 <= 12'h0;
                r_fs3 <= 1'b1;
            end
        else
            begin
                r_falling_counter3 <= r_falling_counter3 + 1;
                r_fs3 <= 1'b0;
            end
    else
        r_fs3 <= 1'b0;
end  

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b0100 && w_falling_trigger == 1'b1) || (r_falling_counter4 > 0))
        if(r_falling_counter4 >= r_mult_match)
            begin
                r_falling_counter4 <= 12'h0;
                r_fs4 <= 1'b1;
            end
        else
            begin
                r_falling_counter4 <= r_falling_counter4 + 1;
                r_fs4 <= 1'b0;
            end
    else
        r_fs4 <= 1'b0;
end 

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b0101 && w_falling_trigger == 1'b1) || (r_falling_counter5 > 0))
        if(r_falling_counter5 >= r_mult_match)
            begin
                r_falling_counter5 <= 12'h0;
                r_fs5 <= 1'b1;
            end
        else
            begin
                r_falling_counter5 <= r_falling_counter5 + 1;
                r_fs5 <= 1'b0;
            end
    else
        r_fs5 <= 1'b0;
end

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b0110 && w_falling_trigger == 1'b1) || (r_falling_counter6 > 0))
        if(r_falling_counter6 >= r_mult_match)
            begin
                r_falling_counter6 <= 12'h0;
                r_fs6 <= 1'b1;
            end
        else
            begin
                r_falling_counter6 <= r_falling_counter6 + 1;
                r_fs6 <= 1'b0;
            end
    else
        r_fs6 <= 1'b0;
end  

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b0111 && w_falling_trigger == 1'b1) || (r_falling_counter7 > 0))
        if(r_falling_counter7 >= r_mult_match)
            begin
                r_falling_counter7 <= 12'h0;
                r_fs7 <= 1'b1;
            end
        else
            begin
                r_falling_counter7 <= r_falling_counter7 + 1;
                r_fs7 <= 1'b0;
            end
    else
        r_fs7 <= 1'b0;
end  

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b1000 && w_falling_trigger == 1'b1) || (r_falling_counter8 > 0))
        if(r_falling_counter8 >= r_mult_match)
            begin
                r_falling_counter8 <= 12'h0;
                r_fs8 <= 1'b1;
            end
        else
            begin
                r_falling_counter8 <= r_falling_counter8 + 1;
                r_fs8 <= 1'b0;
            end
    else
        r_fs8 <= 1'b0;
end  

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b1001 && w_falling_trigger == 1'b1) || (r_falling_counter9 > 0))
        if(r_falling_counter9 >= r_mult_match)
            begin
                r_falling_counter9 <= 12'h0;
                r_fs9 <= 1'b1;
            end
        else
            begin
                r_falling_counter9 <= r_falling_counter9 + 1;
                r_fs9 <= 1'b0;
            end
    else
        r_fs9 <= 1'b0;
end  

always @(posedge sysclk) //increment or reset delay counter, set rising output flag 
begin
    if((r_fnext == 4'b1010 && w_falling_trigger == 1'b1) || (r_falling_counter10 > 0))
        if(r_falling_counter10 >= r_mult_match)
            begin
                r_falling_counter10 <= 12'h0;
                r_fs10 <= 1'b1;
            end
        else
            begin
                r_falling_counter10 <= r_falling_counter10 + 1;
                r_fs10 <= 1'b0;
            end
    else
        begin
            r_fs10 <= 1'b0;
        end
end  

always @(posedge sysclk)
begin
    if(r_rs1 || r_rs2 || r_rs3 || r_rs4 || r_rs5)
        r_r1 <= 1;
    else
        r_r1 <= 0;
end

always @(posedge sysclk)
begin
    if(r_rs6 || r_rs7 || r_rs8 || r_rs9 || r_rs10)
        r_r2 <= 1;
    else
        r_r2 <= 0;
end

always @(posedge sysclk)
begin
    if(r_fs1 || r_fs2 || r_fs3 || r_fs4 || r_fs5)
        r_f1 <= 1;
    else
        r_f1 <= 0;
end

always @(posedge sysclk)
begin
    if(r_fs6 || r_fs7 || r_fs8 || r_fs9 || r_fs10)
        r_f2 <= 1;
    else
        r_f2 <= 0;
end

always @(posedge sysclk)
begin
    if((r_r1 || r_r2) && (!r_f1 && !r_f2))
        r_pio1 <= 1'b1;
    else if((r_f1 || r_f2) && (!r_r1 && !r_r2))
        r_pio1 <= 1'b0;
    else
        r_pio1 <= r_pio1;
end

assign w_rising_trigger = (!r_rsync_old) & r_rsync;
assign w_falling_trigger = r_fsync_old & (!r_fsync);
assign w_out_signal = r_pio1; 

endmodule
