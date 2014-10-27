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
LIBS:steckschwein-cache
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
L GND #PWR028
U 1 1 544D50D2
P 4050 5250
F 0 "#PWR028" H 4050 5250 30  0001 C CNN
F 1 "GND" H 4050 5180 30  0001 C CNN
F 2 "" H 4050 5250 60  0000 C CNN
F 3 "" H 4050 5250 60  0000 C CNN
	1    4050 5250
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR029
U 1 1 544D50D8
P 4050 3550
F 0 "#PWR029" H 4050 3650 30  0001 C CNN
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
$Comp
L 74LS244 U10
U 1 1 544D53A2
P 6850 3450
F 0 "U10" H 6900 3250 60  0000 C CNN
F 1 "74LS244" H 6950 3050 60  0000 C CNN
F 2 "Sockets_DIP:DIP-20__300_ELL" H 6850 3450 60  0001 C CNN
F 3 "" H 6850 3450 60  0000 C CNN
	1    6850 3450
	1    0    0    -1  
$EndComp
Entry Wire Line
	5900 2850 6000 2950
Entry Wire Line
	5900 2950 6000 3050
Entry Wire Line
	5900 3050 6000 3150
Entry Wire Line
	5900 3150 6000 3250
Entry Wire Line
	5900 3250 6000 3350
Entry Wire Line
	5900 3350 6000 3450
Entry Wire Line
	5900 3450 6000 3550
Entry Wire Line
	5900 3550 6000 3650
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
	5050 3850 6150 3850
Wire Wire Line
	6150 3850 6150 4050
Wire Bus Line
	5900 2800 5900 3550
Wire Wire Line
	6000 2950 6150 2950
Wire Wire Line
	6000 3050 6150 3050
Wire Wire Line
	6000 3150 6150 3150
Wire Wire Line
	6000 3250 6150 3250
Wire Wire Line
	6000 3350 6150 3350
Wire Wire Line
	6000 3450 6150 3450
Wire Wire Line
	6000 3550 6150 3550
Wire Wire Line
	6000 3650 6150 3650
Text Label 5850 2800 0    60   ~ 0
D
Text Label 6000 2950 0    60   ~ 0
D0
Text Label 6000 3050 0    60   ~ 0
D1
Text Label 6000 3150 0    60   ~ 0
D2
Text Label 6000 3250 0    60   ~ 0
D3
Text Label 6000 3350 0    60   ~ 0
D4
Text Label 6000 3450 0    60   ~ 0
D5
Text Label 6000 3550 0    60   ~ 0
D6
Text Label 6000 3650 0    60   ~ 0
D7
$Comp
L 74LS273 U11
U 1 1 544D56DD
P 8600 3450
F 0 "U11" H 8600 3300 60  0000 C CNN
F 1 "74LS273" H 8600 3100 60  0000 C CNN
F 2 "Sockets_DIP:DIP-20__300_ELL" H 8600 3450 60  0001 C CNN
F 3 "" H 8600 3450 60  0000 C CNN
	1    8600 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	7550 2950 7900 2950
Wire Wire Line
	7550 3050 7900 3050
Wire Wire Line
	7550 3150 7900 3150
Wire Wire Line
	7550 3250 7900 3250
Wire Wire Line
	7550 3350 7900 3350
Wire Wire Line
	7550 3450 7900 3450
Wire Wire Line
	7550 3550 7900 3550
Wire Wire Line
	7550 3650 7900 3650
Wire Wire Line
	7900 3950 7800 3950
Wire Wire Line
	7900 3850 7300 3850
Wire Wire Line
	7300 3850 7300 4050
Wire Wire Line
	7300 4050 6150 4050
Connection ~ 6150 3950
Wire Wire Line
	5800 4550 5800 2300
Wire Wire Line
	5800 2300 9400 2300
Wire Wire Line
	9400 2300 9400 2950
Wire Wire Line
	9400 2950 9300 2950
NoConn ~ 9300 3050
NoConn ~ 9300 3150
NoConn ~ 9300 3250
NoConn ~ 9300 3350
NoConn ~ 9300 3450
NoConn ~ 9300 3550
NoConn ~ 9300 3650
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
L VCC #PWR030
U 1 1 544D6887
P 3450 3700
F 0 "#PWR030" H 3450 3800 30  0001 C CNN
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
L VCC #PWR031
U 1 1 544D68A5
P 3750 2200
F 0 "#PWR031" H 3750 2300 30  0001 C CNN
F 1 "VCC" H 3750 2300 30  0000 C CNN
F 2 "" H 3750 2200 60  0000 C CNN
F 3 "" H 3750 2200 60  0000 C CNN
	1    3750 2200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR032
U 1 1 544D68AB
P 3750 3200
F 0 "#PWR032" H 3750 3200 30  0001 C CNN
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
Text HLabel 7800 3950 0    60   Input ~ 0
/RESET
$Comp
L VCC #PWR033
U 1 1 544D6E00
P 6550 2750
F 0 "#PWR033" H 6550 2850 30  0001 C CNN
F 1 "VCC" H 6550 2850 30  0000 C CNN
F 2 "" H 6550 2750 60  0000 C CNN
F 3 "" H 6550 2750 60  0000 C CNN
	1    6550 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 2750 6550 2900
$Comp
L VCC #PWR034
U 1 1 544D6F18
P 8300 2750
F 0 "#PWR034" H 8300 2850 30  0001 C CNN
F 1 "VCC" H 8300 2850 30  0000 C CNN
F 2 "" H 8300 2750 60  0000 C CNN
F 3 "" H 8300 2750 60  0000 C CNN
	1    8300 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	8300 2750 8300 2900
$Comp
L GND #PWR035
U 1 1 544D6F9D
P 6550 4200
F 0 "#PWR035" H 6550 4200 30  0001 C CNN
F 1 "GND" H 6550 4130 30  0001 C CNN
F 2 "" H 6550 4200 60  0000 C CNN
F 3 "" H 6550 4200 60  0000 C CNN
	1    6550 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 4000 6550 4200
$Comp
L GND #PWR036
U 1 1 544D700F
P 8300 4200
F 0 "#PWR036" H 8300 4200 30  0001 C CNN
F 1 "GND" H 8300 4130 30  0001 C CNN
F 2 "" H 8300 4200 60  0000 C CNN
F 3 "" H 8300 4200 60  0000 C CNN
	1    8300 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	8300 4000 8300 4200
$Comp
L VCC #PWR037
U 1 1 544E9402
P 2600 5850
F 0 "#PWR037" H 2600 5950 30  0001 C CNN
F 1 "VCC" H 2600 5950 30  0000 C CNN
F 2 "" H 2600 5850 60  0000 C CNN
F 3 "" H 2600 5850 60  0000 C CNN
	1    2600 5850
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR038
U 1 1 544E9408
P 2600 6400
F 0 "#PWR038" H 2600 6400 30  0001 C CNN
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
$EndSCHEMATC
