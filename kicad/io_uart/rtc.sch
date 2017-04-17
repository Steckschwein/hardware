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
Sheet 6 7
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
L DS1306 U7
U 1 1 58E7934B
P 4850 3400
F 0 "U7" H 4450 4200 50  0000 L BNN
F 1 "DS1306" H 4450 2500 50  0000 L BNN
F 2 "Housings_DIP:DIP-16_W7.62mm_LongPads" H 4850 3550 50  0001 C CNN
F 3 "" H 4850 3400 60  0000 C CNN
	1    4850 3400
	1    0    0    -1  
$EndComp
$Comp
L Crystal X1
U 1 1 58E79352
P 3750 3100
F 0 "X1" H 3750 3190 30  0000 C CNN
F 1 "CRYSTAL_SMD" H 3780 2990 30  0000 L CNN
F 2 "Crystals:Crystal_Round_Vertical_3mm_BigPad" H 3750 3100 60  0001 C CNN
F 3 "" H 3750 3100 60  0000 C CNN
	1    3750 3100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR037
U 1 1 58E79359
P 4200 4300
F 0 "#PWR037" H 4200 4300 30  0001 C CNN
F 1 "GND" H 4200 4230 30  0001 C CNN
F 2 "" H 4200 4300 60  0000 C CNN
F 3 "" H 4200 4300 60  0000 C CNN
	1    4200 4300
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR038
U 1 1 58E7935F
P 4150 2750
F 0 "#PWR038" H 4150 2750 30  0001 C CNN
F 1 "GND" H 4150 2680 30  0001 C CNN
F 2 "" H 4150 2750 60  0000 C CNN
F 3 "" H 4150 2750 60  0000 C CNN
	1    4150 2750
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR039
U 1 1 58E79365
P 5650 2500
F 0 "#PWR039" H 5650 2600 30  0001 C CNN
F 1 "VCC" H 5650 2600 30  0000 C CNN
F 2 "" H 5650 2500 60  0000 C CNN
F 3 "" H 5650 2500 60  0000 C CNN
	1    5650 2500
	1    0    0    -1  
$EndComp
$Comp
L Battery BT1
U 1 1 58E7936D
P 3900 2900
F 0 "BT1" H 3900 3100 50  0000 C CNN
F 1 "BATTERY" H 3900 2710 50  0000 C CNN
F 2 "Connect:CR2032H" H 3900 2900 60  0001 C CNN
F 3 "" H 3900 2900 60  0000 C CNN
	1    3900 2900
	0    1    1    0   
$EndComp
$Comp
L GND #PWR040
U 1 1 58E79374
P 3500 2950
F 0 "#PWR040" H 3500 2950 30  0001 C CNN
F 1 "GND" H 3500 2880 30  0001 C CNN
F 2 "" H 3500 2950 60  0000 C CNN
F 3 "" H 3500 2950 60  0000 C CNN
	1    3500 2950
	1    0    0    -1  
$EndComp
NoConn ~ 4250 3700
NoConn ~ 4250 3900
NoConn ~ 5450 2900
$Comp
L 7400 U2
U 4 1 58E7937F
P 6500 3900
F 0 "U2" H 6500 3950 60  0000 C CNN
F 1 "7400" H 6500 3800 60  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm_LongPads" H 6500 3900 60  0001 C CNN
F 3 "" H 6500 3900 60  0000 C CNN
	4    6500 3900
	-1   0    0    1   
$EndComp
Wire Wire Line
	3900 3100 4250 3100
Wire Wire Line
	4250 3300 3350 3300
Wire Wire Line
	3350 3300 3350 3100
Wire Wire Line
	3350 3100 3600 3100
Wire Wire Line
	4250 4100 4200 4100
Wire Wire Line
	4200 4100 4200 4300
Wire Wire Line
	4250 2700 4150 2700
Wire Wire Line
	4150 2700 4150 2750
Wire Wire Line
	5450 2700 5650 2700
Wire Wire Line
	5650 2500 5650 4100
Wire Wire Line
	5650 3100 5450 3100
Connection ~ 5650 2700
Wire Wire Line
	5450 3500 5950 3500
Wire Wire Line
	5450 3700 5950 3700
Wire Wire Line
	5650 4100 5450 4100
Connection ~ 5650 3100
Wire Wire Line
	5450 3900 5900 3900
Wire Wire Line
	7100 3900 7400 3900
Wire Wire Line
	5450 3300 5950 3300
Wire Wire Line
	7100 3800 7100 4000
Connection ~ 7100 3900
Text GLabel 3950 3500 0    60   Input ~ 0
/IRQ
Wire Wire Line
	3950 3500 4250 3500
Wire Wire Line
	3500 2950 3500 2900
Wire Wire Line
	3500 2900 3750 2900
Wire Wire Line
	4050 2900 4250 2900
Text HLabel 5950 3300 2    60   Output ~ 0
SPI_MISO
Text HLabel 5950 3500 2    60   Input ~ 0
SPI_MOSI
Text HLabel 5950 3700 2    60   Input ~ 0
SPI_CLK
Text HLabel 7400 3900 2    60   Input ~ 0
SPI_SS
$EndSCHEMATC