EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:memory
LIBS:special
LIBS:texas
LIBS:audio
LIBS:interface
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:65xxx
LIBS:lp2950l
LIBS:ttl_ieee
LIBS:io-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 4
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
L G65SC22P U1
U 1 1 542879F7
P 2300 3550
F 0 "U1" H 2300 3550 50  0000 L BNN
F 1 "G65SC22P" H 1900 1850 50  0000 L BNN
F 2 "Sockets_DIP:DIP-40__600_ELL" H 2300 3700 50  0001 C CNN
F 3 "" H 2300 3550 60  0000 C CNN
	1    2300 3550
	1    0    0    -1  
$EndComp
$Sheet
S 10000 800  850  2500
U 54287A69
F0 "Connector" 60
F1 "50pin_connector.sch" 60
F2 "A0" I L 10000 900 60 
F3 "A2" I L 10000 1100 60 
F4 "A3" I L 10000 1200 60 
F5 "A1" I L 10000 1000 60 
F6 "D0" I L 10000 1950 60 
F7 "D1" I L 10000 2050 60 
F8 "D2" I L 10000 2150 60 
F9 "D3" I L 10000 2250 60 
F10 "D4" I L 10000 2350 60 
F11 "D5" I L 10000 2450 60 
F12 "D6" I L 10000 2550 60 
F13 "D7" I L 10000 2650 60 
$EndSheet
Entry Wire Line
	9800 800  9900 900 
Entry Wire Line
	9800 900  9900 1000
Entry Wire Line
	9800 1000 9900 1100
Entry Wire Line
	9800 1100 9900 1200
Entry Wire Line
	9800 1850 9900 1950
Entry Wire Line
	9800 1950 9900 2050
Entry Wire Line
	9800 2050 9900 2150
Entry Wire Line
	9800 2150 9900 2250
Entry Wire Line
	9800 2250 9900 2350
Entry Wire Line
	9800 2350 9900 2450
Entry Wire Line
	9800 2450 9900 2550
Entry Wire Line
	9800 2550 9900 2650
Text Label 9900 900  0    60   ~ 0
A0
Text Label 9900 1000 0    60   ~ 0
A1
Text Label 9900 1100 0    60   ~ 0
A2
Text Label 9900 1200 0    60   ~ 0
A3
Text Label 9900 1950 0    60   ~ 0
D0
Text Label 9900 2050 0    60   ~ 0
D1
Text Label 9900 2150 0    60   ~ 0
D2
Text Label 9900 2250 0    60   ~ 0
D3
Text Label 9900 2350 0    60   ~ 0
D4
Text Label 9900 2450 0    60   ~ 0
D5
Text Label 9900 2550 0    60   ~ 0
D6
Text Label 9900 2650 0    60   ~ 0
D7
Entry Wire Line
	1500 2450 1600 2550
Entry Wire Line
	1500 2550 1600 2650
Entry Wire Line
	1500 2650 1600 2750
Entry Wire Line
	1500 2750 1600 2850
Entry Wire Line
	1500 2850 1600 2950
Entry Wire Line
	1500 2950 1600 3050
Entry Wire Line
	1500 3050 1600 3150
Entry Wire Line
	1500 3150 1600 3250
Text Label 1600 2550 0    60   ~ 0
D0
Text Label 1600 2650 0    60   ~ 0
D1
Text Label 1600 2750 0    60   ~ 0
D2
Text Label 1600 2850 0    60   ~ 0
D3
Text Label 1600 2950 0    60   ~ 0
D4
Text Label 1600 3050 0    60   ~ 0
D5
Text Label 1600 3150 0    60   ~ 0
D6
Text Label 1600 3250 0    60   ~ 0
D7
Entry Wire Line
	1500 3350 1600 3450
Entry Wire Line
	1500 3450 1600 3550
Entry Wire Line
	1500 3550 1600 3650
Entry Wire Line
	1500 3650 1600 3750
Text Label 1600 3450 0    60   ~ 0
A0
Text Label 1600 3550 0    60   ~ 0
A1
Text Label 1600 3650 0    60   ~ 0
A2
Text Label 1600 3750 0    60   ~ 0
A3
Text GLabel 1600 3950 0    60   Input ~ 0
/RESET
Text GLabel 1600 4050 0    60   Input ~ 0
/IRQ
Text GLabel 1600 4150 0    60   Input ~ 0
/RW
Text GLabel 1600 4250 0    60   Input ~ 0
PHI2
$Comp
L VCC #PWR01
U 1 1 5428C2B0
P 1650 4550
F 0 "#PWR01" H 1650 4650 30  0001 C CNN
F 1 "VCC" H 1650 4650 30  0000 C CNN
F 2 "" H 1650 4550 60  0000 C CNN
F 3 "" H 1650 4550 60  0000 C CNN
	1    1650 4550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 5428C330
P 1650 5150
F 0 "#PWR02" H 1650 5150 30  0001 C CNN
F 1 "GND" H 1650 5080 30  0001 C CNN
F 2 "" H 1650 5150 60  0000 C CNN
F 3 "" H 1650 5150 60  0000 C CNN
	1    1650 5150
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR03
U 1 1 5428C3FC
P 1300 5450
F 0 "#PWR03" H 1300 5550 30  0001 C CNN
F 1 "VCC" H 1300 5550 30  0000 C CNN
F 2 "" H 1300 5450 60  0000 C CNN
F 3 "" H 1300 5450 60  0000 C CNN
	1    1300 5450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR04
U 1 1 5428C42D
P 1300 6000
F 0 "#PWR04" H 1300 6000 30  0001 C CNN
F 1 "GND" H 1300 5930 30  0001 C CNN
F 2 "" H 1300 6000 60  0000 C CNN
F 3 "" H 1300 6000 60  0000 C CNN
	1    1300 6000
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5428C484
P 1300 5700
F 0 "C1" H 1300 5800 40  0000 L CNN
F 1 "100nF" H 1306 5615 40  0000 L CNN
F 2 "Discret:C1" H 1338 5550 30  0001 C CNN
F 3 "" H 1300 5700 60  0000 C CNN
	1    1300 5700
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR05
U 1 1 5428D273
P 3150 4900
F 0 "#PWR05" H 3150 5000 30  0001 C CNN
F 1 "VCC" H 3150 5000 30  0000 C CNN
F 2 "" H 3150 4900 60  0000 C CNN
F 3 "" H 3150 4900 60  0000 C CNN
	1    3150 4900
	1    0    0    -1  
$EndComp
Text GLabel 3150 5050 2    60   Input ~ 0
/CS_VIA
Wire Wire Line
	2900 4150 4000 4150
Wire Wire Line
	2900 3650 3400 3650
Wire Wire Line
	2900 3550 3800 3550
Wire Wire Line
	2900 3450 3050 3450
Wire Wire Line
	3050 3450 4450 3450
Connection ~ 1300 5900
Connection ~ 1600 5900
Connection ~ 1900 5900
Connection ~ 1900 5500
Connection ~ 1600 5500
Connection ~ 1300 5500
Wire Wire Line
	1300 5900 1600 5900
Wire Wire Line
	1600 5900 1900 5900
Wire Wire Line
	1900 5900 2150 5900
Wire Wire Line
	1300 5500 1600 5500
Wire Wire Line
	1600 5500 1900 5500
Wire Wire Line
	1900 5500 2150 5500
Wire Wire Line
	2900 5050 3150 5050
Wire Wire Line
	3150 4950 3150 4850
Wire Wire Line
	2900 4950 3150 4950
Wire Wire Line
	2900 4750 4250 4750
Wire Wire Line
	3050 4650 2900 4650
Wire Wire Line
	1300 5450 1300 5500
Wire Wire Line
	1300 5900 1300 6000
Wire Wire Line
	1650 5050 1650 5150
Wire Wire Line
	1700 5050 1650 5050
Wire Wire Line
	1650 4650 1700 4650
Wire Wire Line
	1650 4550 1650 4650
Wire Wire Line
	1600 4250 1700 4250
Wire Wire Line
	1600 4150 1700 4150
Wire Wire Line
	1600 4050 1700 4050
Wire Wire Line
	1600 3950 1700 3950
Wire Wire Line
	1600 3750 1700 3750
Wire Wire Line
	1700 3650 1600 3650
Wire Wire Line
	1600 3550 1700 3550
Wire Wire Line
	1600 3450 1700 3450
Wire Bus Line
	1500 3250 1500 3350
Wire Bus Line
	1500 3350 1500 3450
Wire Bus Line
	1500 3450 1500 3550
Wire Bus Line
	1500 3550 1500 3650
Wire Bus Line
	1500 3650 1500 3750
Wire Wire Line
	1700 3250 1600 3250
Wire Wire Line
	1600 3150 1700 3150
Wire Wire Line
	1700 3050 1600 3050
Wire Wire Line
	1600 2950 1700 2950
Wire Wire Line
	1700 2850 1600 2850
Wire Wire Line
	1600 2750 1700 2750
Wire Wire Line
	1700 2650 1600 2650
Wire Wire Line
	1600 2550 1700 2550
Wire Bus Line
	1500 2350 1500 2450
Wire Bus Line
	1500 2450 1500 2550
Wire Bus Line
	1500 2550 1500 2650
Wire Bus Line
	1500 2650 1500 2750
Wire Bus Line
	1500 2750 1500 2850
Wire Bus Line
	1500 2850 1500 2950
Wire Bus Line
	1500 2950 1500 3050
Wire Bus Line
	1500 3050 1500 3150
Wire Wire Line
	10000 2650 9900 2650
Wire Wire Line
	9900 2550 10000 2550
Wire Wire Line
	10000 2450 9900 2450
Wire Wire Line
	9900 2350 10000 2350
Wire Wire Line
	10000 2250 9900 2250
Wire Wire Line
	9900 2150 10000 2150
Wire Wire Line
	10000 2050 9900 2050
Wire Wire Line
	9900 1950 10000 1950
Wire Bus Line
	9800 1750 9800 1850
Wire Bus Line
	9800 1850 9800 1950
Wire Bus Line
	9800 1950 9800 2050
Wire Bus Line
	9800 2050 9800 2150
Wire Bus Line
	9800 2150 9800 2250
Wire Bus Line
	9800 2250 9800 2350
Wire Bus Line
	9800 2350 9800 2450
Wire Bus Line
	9800 2450 9800 2550
Wire Wire Line
	9900 1200 10000 1200
Wire Wire Line
	10000 1100 9900 1100
Wire Wire Line
	9900 1000 10000 1000
Wire Wire Line
	9900 900  10000 900 
Wire Bus Line
	9800 700  9800 800 
Wire Bus Line
	9800 800  9800 900 
Wire Bus Line
	9800 900  9800 1000
Wire Bus Line
	9800 1000 9800 1100
Wire Bus Line
	9800 1100 9800 1200
Wire Wire Line
	3050 4650 3050 3450
Connection ~ 3050 3450
$Sheet
S 4450 3000 1400 1700
U 542907F9
F0 "SD Card" 60
F1 "sd_card.sch" 60
F2 "SPI_CLK" I L 4450 3450 60 
F3 "SPI_MOSI" I L 4450 3600 60 
F4 "SPI_MISO" I L 4450 3750 60 
F5 "SPI_SS1" I L 4450 3900 60 
$EndSheet
Text Label 3300 3450 0    60   ~ 0
SPI_CLK
Text Label 3300 3550 0    60   ~ 0
SPI_SS1
Text Label 3300 3650 0    60   ~ 0
SPI_SS2
Text Label 3300 4150 0    60   ~ 0
SPI_MOSI
Text Label 3300 4750 0    60   ~ 0
SPI_MISO
Wire Wire Line
	4000 4150 4000 3600
Wire Wire Line
	4000 3600 4450 3600
Wire Wire Line
	3800 3550 3800 3900
Wire Wire Line
	3800 3900 4450 3900
Wire Wire Line
	4250 4750 4250 3750
Wire Wire Line
	4250 3750 4450 3750
$Sheet
S 4450 1500 1400 1100
U 54318D23
F0 "Joystick Ports" 60
F1 "joystick.sch" 60
F2 "PortSel01" I L 4450 1600 60 
F3 "PortSel02" I L 4450 1700 60 
F4 "J_Right" I L 4450 1900 60 
F5 "J_Left" I L 4450 2000 60 
F6 "J_Up" I L 4450 2100 60 
F7 "J_Down" I L 4450 2200 60 
F8 "J_Fire1" I L 4450 2300 60 
F9 "J_Fire2" I L 4450 2400 60 
$EndSheet
Wire Wire Line
	2900 2550 3000 2550
Wire Wire Line
	3000 2550 3000 1600
Wire Wire Line
	3000 1600 4450 1600
Wire Wire Line
	4450 1700 3100 1700
Wire Wire Line
	3100 1700 3100 2650
Wire Wire Line
	3100 2650 2900 2650
Wire Wire Line
	2900 2750 3200 2750
Wire Wire Line
	3200 2750 3200 1900
Wire Wire Line
	3200 1900 4450 1900
Wire Wire Line
	4500 2000 3300 2000
Wire Wire Line
	3300 2000 3300 2850
Wire Wire Line
	3300 2850 2900 2850
Wire Wire Line
	2900 2950 3400 2950
Wire Wire Line
	3400 2950 3400 2100
Wire Wire Line
	3400 2100 4500 2100
Wire Wire Line
	4500 2200 3500 2200
Wire Wire Line
	3500 2200 3500 3050
Wire Wire Line
	3500 3050 2900 3050
Wire Wire Line
	2900 3150 3600 3150
Wire Wire Line
	3600 3150 3600 2300
Wire Wire Line
	3600 2300 4500 2300
Wire Wire Line
	4500 2400 3700 2400
Wire Wire Line
	3700 2400 3700 3250
Wire Wire Line
	3700 3250 2900 3250
$EndSCHEMATC
