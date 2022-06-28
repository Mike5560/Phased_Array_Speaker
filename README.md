# Phased_Array_Speaker
This is a project receives audio via 3.5mm jack and transmits modulated ultrasound at 40 khz.
Power can be supplied from ~9V - 18V DC, I've found the best results and cleanest sound at around 12 volts, or roughly 3 3.7V lithium ion batteries.
The sound radiates directionally like a flashlight, and a joystick controls the direction in 5 degree increments from 
30 degrees left to 30 degrees right.  Pressing the BTN 0 button on the CMOD will focus the sound at a point 1 meter away.

I will upload the Gerber files and BOM later.  The project can be somewhat expensive to build (~$250) as I have made it.
I used a CMOD A7 35T FPGA board, though many other FPGA boards with >1800 Flip flops, >1800 LUTs and 2 or more ADC inputs should
be capable of running it.  The project is current for Vivado 2021.2.![Front_Image](https://user-images.githubusercontent.com/78199728/176317332-d1329611-d8d8-4863-ae41-bb6e8244707a.jpeg)
![Back_Image](https://user-images.githubusercontent.com/78199728/176317351-4105629f-5049-4989-8cf0-8f61a7647e7e.jpeg)
