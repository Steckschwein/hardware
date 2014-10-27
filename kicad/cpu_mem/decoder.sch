EESchema Schematic File Version 2
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
LIBS:special
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
LIBS:gal
LIBS:UART
LIBS:osc
LIBS:74xgxx
LIBS:ttl_ieee
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 3
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
L GAL22V10 U5
U 1 1 544D50CB
P 4350 4400
F 0 "U5" H 4400 5150 60  0000 C CNN
F 1 "GAL22V10" H 4400 3650 60  0000 C CNN
F 2 "Sockets_DIP:DIP-24__300_ELL" H 4350 4400 60  0001 C CNN
F 3 "" H 4350 4400 60  0000 C CNN
	1    4350 4400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR34
U 1 1 544D50D2
P 4050 5250
F 0 "#PWR34" H 4050 5250 30  0001 C CNN
F 1 "GND" H 4050 5180 30  0001 C CNN
F 2 "" H 4050 5250 60  0000 C CNN
F 3 "" H 4050 5250 60  0000 C CNN
	1    4050 5250
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR33
U 1 1 544D50D8
P 4050 3550
F 0 "#PWR33" H 4050 3650 30  0001 C CNN
F 1 "VCC" H 4050 3650 30  0000 C CNN
F 2 "" H 4050 3550 60  0000 C CNN
F 3 "" H 4050 3550 60  0000 C CNN
	1    4050 3550
	1    0    0    -1  
$EndComp
Entry Wire Line
	3450 3650 3550 3750
Entry Wire Line
	3450 3750 3550 3850
Entry Wire Line
	3450 3850 3550 3950
Entry Wire Line
	3450 3950 3550 4050
Entry Wire Line
	3450 4050 3550 4150
Entry Wire Line
	3450 4150 3550 4250
Entry Wire Line
	3450 4250 3550 4350
Entry Wire Line
	3450 4350 3550 4450
Text Label 3550 3750 0    60   ~ 0
A15
Text Label 3550 3850 0    60   ~ 0
A14
Text Label 3550 3950 0    60   ~ 0
A13
Text Label 3550 4050 0    60   ~ 0
A12
Text Label 3450 3550 0    60   ~ 0
A
Entry Wire Line
	3450 4450 3550 4550
Entry Wire Line
	3450 4550 3550 4650
Entry Wire Line
	3450 4650 3550 4750
Entry Wire Line
	3450 4750 3550 4850
Text Label 3550 4150 0    60   ~ 0
A11
Text Label 3550 4250 0    60   ~ 0
A10
Text Label 3550 4350 0    60   ~ 0
A9
Text Label 3550 4450 0    60   ~ 0
A8
Text Label 3550 4550 0    60   ~ 0
A7
Text Label 3550 4650 0    60   ~ 0
A6
Text Label 3550 4750 0    60   ~ 0
A5
Text Label 3550 4850 0    60   ~ 0
A4
Entry Wire Line
	6450 2850 6550 2950
Entry Wire Line
	6450 2950 6550 3050
Entry Wire Line
	6450 3050 6550 3150
Entry Wire Line
	6450 3150 6550 3250
Entry Wire Line
	6450 3250 6550 3350
Entry Wire Line
	6450 3350 6550 3450
Entry Wire Line
	6450 3450 6550 3550
Entry Wire Line
	6450 3550 6550 3650
Wire Wire Line
	4050 5100 4050 5250
Wire Wire Line
	4050 3550 4050 3700
Wire Bus Line
	3450 3550 3450 4750
Wire Wire Line
	3550 3750 3650 3750
Wire Wire Line
	3550 3850 3650 3850
Wire Wire Line
	3550 3950 3650 3950
Wire Wire Line
	3550 4050 3650 4050
Wire Wire Line
	3550 4150 3650 4150
Wire Wire Line
	3550 4250 3650 4250
Wire Wire Line
	3550 4350 3650 4350
Wire Wire Line
	3550 4450 3650 4450
Wire Wire Line
	3650 4550 3550 4550
Wire Wire Line
	3650 4650 3550 4650
Wire Wire Line
	3550 4750 3650 4750
Wire Wire Line
	3550 4850 3650 4850
Wire Wire Line
	5050 4650 5100 4650
Wire Wire Line
	5050 4550 5800 4550
Wire Wire Line
	5050 4450 5100 4450
Wire Wire Line
	5050 4350 5100 4350
Wire Wire Line
	5050 4250 5100 4250
Wire Wire Line
	5050 4150 5100 4150
Wire Wire Line
	5050 4050 5100 4050
Wire Wire Line
	5050 3950 5100 3950
Wire Wire Line
	5050 3850 6700 3850
Wire Bus Line
	6450 2800 6450 3550
Wire Wire Line
	6550 2950 6700 2950
Wire Wire Line
	6550 3050 6700 3050
Wire Wire Line
	6550 3150 6700 3150
Wire Wire Line
	6550 3250 6700 3250
Wire Wire Line
	6550 3350 6700 3350
Wire Wire Line
	6550 3450 6700 3450
Wire Wire Line
	6550 3550 6700 3550
Wire Wire Line
	6550 3650 6700 3650
Text Label 6400 2800 0    60   ~ 0
D
Text Label 6550 2950 0    60   ~ 0
D0
Text Label 6550 3050 0    60   ~ 0
D1
Text Label 6550 3150 0    60   ~ 0
D2
Text Label 6550 3250 0    60   ~ 0
D3
Text Label 6550 3350 0    60   ~ 0
D4
Text Label 6550 3450 0    60   ~ 0
D5
Text Label 6550 3550 0    60   ~ 0
D6
Text Label 6550 3650 0    60   ~ 0
D7
$Comp
L 74LS273 U11
U 1 1 544D56DD
P 7400 3450
F 0 "U11" H 7400 3300 60  0000 C CNN
F 1 "74LS273" H 7400 3100 60  0000 C CNN
F 2 "Sockets_DIP:DIP-20__300_ELL" H 7400 3450 60  0001 C CNN
F 3 "" H 7400 3450 60  0000 C CNN
	1    7400 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	6700 3950 6600 3950
Wire Wire Line
	5800 4550 5800 2300
Wire Wire Line
	5800 2300 8200 2300
Wire Wire Line
	8200 2300 8200 2950
Wire Wire Line
	8100 2950 8750 2950
Text HLabel 850  2500 2    60   Input ~ 0
A4
Entry Wire Line
	650  2400 750  2500
Wire Wire Line
	750  2500 850  2500
Wire Bus Line
	650  650  650  2400
Text Label 650  700  0    60   ~ 0
A[0..15]
Wire Bus Line
	1600 700  1600 1750
Entry Wire Line
	1600 1050 1700 1150
Entry Wire Line
	1600 1250 1700 1350
Entry Wire Line
	1600 1450 1700 1550
Entry Wire Line
	1600 1650 1700 1750
Wire Wire Line
	1700 1150 1850 1150
Wire Wire Line
	1700 1350 1850 1350
Wire Wire Line
	1700 1550 1850 1550
Wire Wire Line
	1700 1750 1850 1750
Text Label 1700 1150 0    60   ~ 0
D7
Text Label 1700 1350 0    60   ~ 0
D5
Text Label 1700 1550 0    60   ~ 0
D3
Text Label 1700 1750 0    60   ~ 0
D1
Text Label 1600 650  0    60   ~ 0
D[0..7]
Entry Wire Line
	1700 1250 1600 1150
Entry Wire Line
	1700 1450 1600 1350
Entry Wire Line
	1700 1650 1600 1550
Entry Wire Line
	1700 1850 1600 1750
Wire Wire Line
	1850 1250 1700 1250
Wire Wire Line
	1850 1450 1700 1450
Wire Wire Line
	1850 1650 1700 1650
Wire Wire Line
	1850 1850 1700 1850
Text Label 1800 1250 2    60   ~ 0
D6
Text Label 1800 1450 2    60   ~ 0
D4
Text Label 1800 1650 2    60   ~ 0
D2
Text Label 1800 1850 2    60   ~ 0
D0
Text HLabel 1850 1850 2    60   Input ~ 0
D0
Text HLabel 1850 1750 2    60   Input ~ 0
D1
Text HLabel 1850 1650 2    60   Input ~ 0
D2
Text HLabel 1850 1550 2    60   Input ~ 0
D3
Text HLabel 1850 1450 2    60   Input ~ 0
D4
Text HLabel 1850 1350 2    60   Input ~ 0
D5
Text HLabel 1850 1250 2    60   Input ~ 0
D6
Text HLabel 1850 1150 2    60   Input ~ 0
D7
Text Label 750  2500 0    60   ~ 0
A4
Entry Wire Line
	650  2300 750  2400
Text HLabel 850  2400 2    60   Input ~ 0
A5
Wire Wire Line
	750  2400 850  2400
Text Label 750  2400 0    60   ~ 0
A5
Entry Wire Line
	650  2200 750  2300
Entry Wire Line
	650  2100 750  2200
Entry Wire Line
	650  2000 750  2100
Entry Wire Line
	650  1900 750  2000
Entry Wire Line
	650  1800 750  1900
Entry Wire Line
	650  1700 750  1800
Entry Wire Line
	650  1600 750  1700
Entry Wire Line
	650  1500 750  1600
Entry Wire Line
	650  1400 750  1500
Entry Wire Line
	650  1300 750  1400
Wire Wire Line
	750  1400 850  1400
Wire Wire Line
	750  1500 850  1500
Wire Wire Line
	750  1600 850  1600
Wire Wire Line
	750  1700 850  1700
Wire Wire Line
	750  1800 850  1800
Wire Wire Line
	750  1900 850  1900
Wire Wire Line
	750  2000 850  2000
Wire Wire Line
	750  2100 850  2100
Wire Wire Line
	750  2200 850  2200
Wire Wire Line
	750  2300 850  2300
Text Label 750  2300 0    60   ~ 0
A6
Text Label 750  2200 0    60   ~ 0
A7
Text Label 750  2100 0    60   ~ 0
A8
Text Label 750  2000 0    60   ~ 0
A9
Text Label 750  1900 0    60   ~ 0
A10
Text Label 750  1800 0    60   ~ 0
A11
Text Label 750  1700 0    60   ~ 0
A12
Text Label 750  1600 0    60   ~ 0
A13
Text Label 750  1500 0    60   ~ 0
A14
Text Label 750  1400 0    60   ~ 0
A15
Text HLabel 850  2300 2    60   Input ~ 0
A6
Text HLabel 850  2200 2    60   Input ~ 0
A7
Text HLabel 850  2100 2    60   Input ~ 0
A8
Text HLabel 850  2000 2    60   Input ~ 0
A9
Text HLabel 850  1900 2    60   Input ~ 0
A10
Text HLabel 850  1800 2    60   Input ~ 0
A11
Text HLabel 850  1700 2    60   Input ~ 0
A12
Text HLabel 850  1600 2    60   Input ~ 0
A13
Text HLabel 850  1500 2    60   Input ~ 0
A14
Text HLabel 850  1400 2    60   Input ~ 0
A15
$Comp
L VCC #PWR30
U 1 1 544D6887
P 3450 3700
F 0 "#PWR30" H 3450 3800 30  0001 C CNN
F 1 "VCC" H 3450 3800 30  0000 C CNN
F 2 "" H 3450 3700 60  0000 C CNN
F 3 "" H 3450 3700 60  0000 C CNN
	1    3450 3700
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U9
U 2 1 544D688D
P 4200 2700
F 0 "U9" H 4200 2800 60  0000 C CNN
F 1 "74LS139" H 4200 2600 60  0000 C CNN
F 2 "Sockets_DIP:DIP-16__300_ELL" H 4200 2700 60  0001 C CNN
F 3 "" H 4200 2700 60  0000 C CNN
	2    4200 2700
	1    0    0    -1  
$EndComp
Entry Wire Line
	3200 2350 3300 2450
Entry Wire Line
	3200 2500 3300 2600
Text Label 3300 2450 0    60   ~ 0
A5
Text Label 3300 2600 0    60   ~ 0
A4
Wire Bus Line
	3200 2250 3200 2550
Wire Wire Line
	3300 2450 3350 2450
Wire Wire Line
	3300 2600 3350 2600
Wire Wire Line
	5050 2400 5200 2400
Wire Wire Line
	5050 2600 5200 2600
Wire Wire Line
	5050 2800 5200 2800
Wire Wire Line
	5050 3000 5200 3000
$Comp
L VCC #PWR31
U 1 1 544D68A5
P 3750 2200
F 0 "#PWR31" H 3750 2300 30  0001 C CNN
F 1 "VCC" H 3750 2300 30  0000 C CNN
F 2 "" H 3750 2200 60  0000 C CNN
F 3 "" H 3750 2200 60  0000 C CNN
	1    3750 2200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR32
U 1 1 544D68AB
P 3750 3200
F 0 "#PWR32" H 3750 3200 30  0001 C CNN
F 1 "GND" H 3750 3130 30  0001 C CNN
F 2 "" H 3750 3200 60  0000 C CNN
F 3 "" H 3750 3200 60  0000 C CNN
	1    3750 3200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3750 2200 3750 2300
Wire Wire Line
	3750 3100 3750 3200
NoConn ~ 5050 3000
Text Label 3200 2250 0    60   ~ 0
A
Wire Wire Line
	3350 2950 3250 2950
Wire Wire Line
	3250 2950 3250 3400
Wire Wire Line
	3250 3400 5200 3400
Wire Wire Line
	5200 3400 5200 3750
Wire Wire Line
	5200 3750 5050 3750
Text HLabel 5100 4450 2    60   Output ~ 0
/CS_ROM
Text HLabel 5100 4350 2    60   Output ~ 0
/CS_LORAM
Text HLabel 5100 4250 2    60   Output ~ 0
/CS_HIRAM
Text HLabel 5100 4650 2    60   Input ~ 0
RW
Text HLabel 5100 4150 2    60   Output ~ 0
/CS_UART
Text HLabel 5100 4050 2    60   Output ~ 0
/CS_VIA
Text HLabel 5100 3950 2    60   Output ~ 0
/CS_VDP
Text HLabel 5200 2400 2    60   Output ~ 0
/CS_IO0
Text HLabel 5200 2600 2    60   Output ~ 0
/CS_IO1
Text HLabel 5200 2800 2    60   Output ~ 0
/CS_IO2
Text HLabel 5200 3000 2    60   Output ~ 0
/CS_IO3
Text HLabel 6600 3950 0    60   Input ~ 0
/RESET
$Comp
L VCC #PWR35
U 1 1 544D6F18
P 7100 2750
F 0 "#PWR35" H 7100 2850 30  0001 C CNN
F 1 "VCC" H 7100 2850 30  0000 C CNN
F 2 "" H 7100 2750 60  0000 C CNN
F 3 "" H 7100 2750 60  0000 C CNN
	1    7100 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	7100 2750 7100 2900
$Comp
L GND #PWR36
U 1 1 544D700F
P 7100 4200
F 0 "#PWR36" H 7100 4200 30  0001 C CNN
F 1 "GND" H 7100 4130 30  0001 C CNN
F 2 "" H 7100 4200 60  0000 C CNN
F 3 "" H 7100 4200 60  0000 C CNN
	1    7100 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	7100 4000 7100 4200
$Comp
L VCC #PWR28
U 1 1 544E9402
P 2600 5850
F 0 "#PWR28" H 2600 5950 30  0001 C CNN
F 1 "VCC" H 2600 5950 30  0000 C CNN
F 2 "" H 2600 5850 60  0000 C CNN
F 3 "" H 2600 5850 60  0000 C CNN
	1    2600 5850
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR29
U 1 1 544E9408
P 2600 6400
F 0 "#PWR29" H 2600 6400 30  0001 C CNN
F 1 "GND" H 2600 6330 30  0001 C CNN
F 2 "" H 2600 6400 60  0000 C CNN
F 3 "" H 2600 6400 60  0000 C CNN
	1    2600 6400
	1    0    0    -1  
$EndComp
$Comp
L C C11
U 1 1 544E940E
P 2600 6100
F 0 "C11" H 2600 6200 40  0000 L CNN
F 1 "100n" H 2606 6015 40  0000 L CNN
F 2 "Discret:C1" H 2638 5950 30  0001 C CNN
F 3 "" H 2600 6100 60  0000 C CNN
	1    2600 6100
	1    0    0    -1  
$EndComp
$Comp
L C C12
U 1 1 544E9415
P 2850 6100
F 0 "C12" H 2850 6200 40  0000 L CNN
F 1 "100n" H 2856 6015 40  0000 L CNN
F 2 "Discret:C1" H 2888 5950 30  0001 C CNN
F 3 "" H 2850 6100 60  0000 C CNN
	1    2850 6100
	1    0    0    -1  
$EndComp
$Comp
L C C13
U 1 1 544E941C
P 3100 6100
F 0 "C13" H 3100 6200 40  0000 L CNN
F 1 "100n" H 3106 6015 40  0000 L CNN
F 2 "Discret:C1" H 3138 5950 30  0001 C CNN
F 3 "" H 3100 6100 60  0000 C CNN
	1    3100 6100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 5850 2600 5900
Wire Wire Line
	2600 6300 2600 6400
Wire Wire Line
	2600 5900 3100 5900
Wire Wire Line
	2600 6300 3100 6300
Connection ~ 2850 5900
Connection ~ 3100 5900
Connection ~ 3100 6300
Connection ~ 2850 6300
$Comp
L CONN_01X08 P2
U 1 1 544E9377
P 8950 3300
F 0 "P2" H 8950 3750 50  0000 C CNN
F 1 "CONN_01X08" V 9050 3300 50  0000 C CNN
F 2 "" H 8950 3300 60  0000 C CNN
F 3 "" H 8950 3300 60  0000 C CNN
	1    8950 3300
	1    0    0    -1  
$EndComp
Connection ~ 8200 2950
Wire Wire Line
	8100 3050 8750 3050
Wire Wire Line
	8100 3150 8750 3150
Wire Wire Line
	8100 3250 8750 3250
Wire Wire Line
	8750 3350 8100 3350
Wire Wire Line
	8100 3450 8750 3450
Wire Wire Line
	8100 3550 8750 3550
Wire Wire Line
	8100 3650 8750 3650
Text HLabel 8350 2600 1    60   Output ~ 0
BANK1
Text HLabel 8500 2600 1    60   Output ~ 0
BANK2
Wire Wire Line
	8350 2600 8350 3050
Connection ~ 8350 3050
Wire Wire Line
	8500 2600 8500 3150
Connection ~ 8500 3150
$EndSCHEMATC
