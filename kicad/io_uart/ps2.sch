EESchema Schematic File Version 2
LIBS:io-rescue
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:65xxx
LIBS:ttl_ieee
LIBS:mini_din
LIBS:dallas-rtc
LIBS:lp2950l
LIBS:osc
LIBS:io-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 7 7
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L VCC #PWR041
U 1 1 58E7EA2A
P 4150 1650
F 0 "#PWR041" H 4150 1750 30  0001 C CNN
F 1 "VCC" H 4150 1750 30  0000 C CNN
F 2 "" H 4150 1650 60  0000 C CNN
F 3 "" H 4150 1650 60  0000 C CNN
	1    4150 1650
	1    0    0    -1  
$EndComp
Text GLabel 5450 3300 2    60   Output ~ 0
/NMI
$Comp
L ATMEGA8-P IC1
U 1 1 58E7EA33
P 4150 3600
F 0 "IC1" H 3400 4900 40  0000 L BNN
F 1 "ATMEGA8-P" H 4650 2150 40  0000 L BNN
F 2 "Housings_DIP:DIP-28_W7.62mm_LongPads" H 4150 3600 30  0000 C CIN
F 3 "" H 4150 3600 60  0000 C CNN
	1    4150 3600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR042
U 1 1 58E7EA3A
P 8300 4800
F 0 "#PWR042" H 8300 4800 30  0001 C CNN
F 1 "GND" H 8300 4730 30  0001 C CNN
F 2 "" H 8300 4800 60  0000 C CNN
F 3 "" H 8300 4800 60  0000 C CNN
	1    8300 4800
	1    0    0    -1  
$EndComp
NoConn ~ 3250 3200
NoConn ~ 3250 3400
NoConn ~ 5150 2500
NoConn ~ 5150 2600
NoConn ~ 5150 3500
NoConn ~ 5150 3600
NoConn ~ 5150 3700
NoConn ~ 5150 4300
NoConn ~ 5150 4400
NoConn ~ 5150 4500
NoConn ~ 5150 4600
$Comp
L CONN_02X03 P3
U 1 1 58E7EA4D
P 6300 3000
F 0 "P3" H 6300 3200 50  0000 C CNN
F 1 "ISP" H 6300 2800 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03" H 6300 1800 60  0001 C CNN
F 3 "" H 6300 1800 60  0000 C CNN
	1    6300 3000
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR043
U 1 1 58E7EA54
P 6700 3300
F 0 "#PWR043" H 6700 3300 30  0001 C CNN
F 1 "GND" H 6700 3230 30  0001 C CNN
F 2 "" H 6700 3300 60  0000 C CNN
F 3 "" H 6700 3300 60  0000 C CNN
	1    6700 3300
	1    0    0    -1  
$EndComp
$Comp
L MINI_DIN_6 P4
U 1 1 58E7EA5A
P 7450 4250
F 0 "P4" H 7050 4775 50  0000 L BNN
F 1 "PS/2 Keyboard" H 7450 4775 50  0000 L BNN
F 2 "Steckschwein:mini_din-M_DIN6" H 7450 4400 50  0001 C CNN
F 3 "" H 7450 4250 60  0000 C CNN
	1    7450 4250
	1    0    0    -1  
$EndComp
Text GLabel 3150 2500 0    60   Input ~ 0
/RESET
Wire Wire Line
	4150 1650 4150 2200
Wire Wire Line
	3150 2500 3250 2500
Wire Wire Line
	3200 1800 6800 1800
Connection ~ 4150 1800
Wire Wire Line
	5150 3000 6050 3000
Wire Wire Line
	5150 2700 5400 2700
Wire Wire Line
	5150 4100 6000 4100
Wire Wire Line
	4150 5100 4150 5150
Wire Wire Line
	5150 2800 6700 2800
Wire Wire Line
	5150 2900 6150 2900
Wire Wire Line
	5150 3900 5900 3900
Wire Wire Line
	5150 3200 5300 3200
Wire Wire Line
	3200 1800 3200 2800
Connection ~ 3200 1800
Wire Wire Line
	5150 3300 5450 3300
Wire Wire Line
	3200 2800 3250 2800
Wire Wire Line
	3250 2900 3150 2900
Wire Wire Line
	3150 2900 3150 5100
Wire Wire Line
	3150 5100 4150 5100
Wire Wire Line
	3250 2700 3200 2700
Connection ~ 3200 2700
Wire Wire Line
	3250 2500 3250 2150
Wire Wire Line
	3250 2150 5900 2150
Wire Wire Line
	5900 2150 5900 3100
Wire Wire Line
	5900 3100 6050 3100
Wire Wire Line
	6800 1800 6800 4150
Wire Wire Line
	6800 2900 6550 2900
Wire Wire Line
	6700 2800 6700 3000
Wire Wire Line
	6550 3000 7300 3000
Wire Wire Line
	6550 3100 6700 3100
Wire Wire Line
	6700 3100 6700 3300
Connection ~ 6800 1800
Wire Wire Line
	8050 4150 8300 4150
Wire Wire Line
	8300 4150 8300 4800
Wire Wire Line
	6000 4100 6000 3600
Wire Wire Line
	6000 3600 8300 3600
Wire Wire Line
	8300 3600 8300 4050
Wire Wire Line
	8300 4050 7950 4050
Wire Wire Line
	6800 4150 6850 4150
Connection ~ 6800 2900
Wire Wire Line
	7450 4650 7450 4700
Wire Wire Line
	6800 4700 8300 4700
Connection ~ 8300 4700
Wire Wire Line
	7950 4450 7950 4700
Wire Wire Line
	7950 4700 7900 4700
Connection ~ 7950 4700
Wire Wire Line
	6950 4450 6800 4450
Wire Wire Line
	6800 4450 6800 4700
Connection ~ 7450 4700
Wire Wire Line
	8050 4350 8150 4350
Wire Wire Line
	8150 4350 8150 4800
Wire Wire Line
	8150 4800 5900 4800
Wire Wire Line
	5900 4800 5900 3900
Wire Wire Line
	7300 2750 6050 2750
Wire Wire Line
	6050 2750 6050 2900
Connection ~ 6050 2900
Wire Wire Line
	5150 4000 6500 4000
Wire Wire Line
	6500 4000 6500 4350
Wire Wire Line
	6500 4350 6850 4350
Wire Wire Line
	5150 4200 6600 4200
Wire Wire Line
	6600 4200 6600 4050
Wire Wire Line
	6600 4050 6950 4050
Text GLabel 5650 3400 2    60   Input ~ 0
/IRQ
Wire Wire Line
	5150 3400 5650 3400
$Comp
L GND #PWR044
U 1 1 58E7EAAB
P 4150 5150
F 0 "#PWR044" H 4150 5150 30  0001 C CNN
F 1 "GND" H 4150 5080 30  0001 C CNN
F 2 "" H 4150 5150 60  0000 C CNN
F 3 "" H 4150 5150 60  0000 C CNN
	1    4150 5150
	1    0    0    -1  
$EndComp
Connection ~ 5150 3200
Connection ~ 5150 3300
Text HLabel 7300 2750 2    60   Input ~ 0
SPI_MISO
Text HLabel 5400 2700 2    60   Input ~ 0
~SPI_SS
Text HLabel 7300 3000 2    60   Input ~ 0
SPI_MOSI
Connection ~ 6700 3000
Text HLabel 5300 3000 2    60   Input ~ 0
SPI_CLK
Text HLabel 5300 3200 2    60   Output ~ 0
RESET_TRIG
$EndSCHEMATC
