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
EELAYER 25 0
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
P 1850 6050
F 0 "U5" H 1900 6800 60  0000 C CNN
F 1 "GAL22V10" H 1900 5300 60  0000 C CNN
F 2 "Sockets_DIP:DIP-24__300_ELL" H 1850 6050 60  0001 C CNN
F 3 "" H 1850 6050 60  0000 C CNN
	1    1850 6050
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR030
U 1 1 544D50D2
P 1550 6900
F 0 "#PWR030" H 1550 6900 30  0001 C CNN
F 1 "GND" H 1550 6830 30  0001 C CNN
F 2 "" H 1550 6900 60  0000 C CNN
F 3 "" H 1550 6900 60  0000 C CNN
	1    1550 6900
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR031
U 1 1 544D50D8
P 1550 5200
F 0 "#PWR031" H 1550 5300 30  0001 C CNN
F 1 "VCC" H 1550 5300 30  0000 C CNN
F 2 "" H 1550 5200 60  0000 C CNN
F 3 "" H 1550 5200 60  0000 C CNN
	1    1550 5200
	1    0    0    -1  
$EndComp
Entry Wire Line
	950  5300 1050 5400
Entry Wire Line
	950  5400 1050 5500
Entry Wire Line
	950  5500 1050 5600
Entry Wire Line
	950  5600 1050 5700
Entry Wire Line
	950  5700 1050 5800
Entry Wire Line
	950  5800 1050 5900
Entry Wire Line
	950  5900 1050 6000
Entry Wire Line
	950  6000 1050 6100
Text Label 1050 5400 0    60   ~ 0
A15
Text Label 1050 5500 0    60   ~ 0
A14
Text Label 1050 5600 0    60   ~ 0
A13
Text Label 1050 5700 0    60   ~ 0
A12
Text Label 950  5200 0    60   ~ 0
A
Entry Wire Line
	950  6100 1050 6200
Entry Wire Line
	950  6200 1050 6300
Entry Wire Line
	950  6300 1050 6400
Entry Wire Line
	950  6400 1050 6500
Text Label 1050 5800 0    60   ~ 0
A11
Text Label 1050 5900 0    60   ~ 0
A10
Text Label 1050 6000 0    60   ~ 0
A9
Text Label 1050 6100 0    60   ~ 0
A8
Text Label 1050 6200 0    60   ~ 0
A7
Text Label 1050 6300 0    60   ~ 0
A6
Text Label 1050 6400 0    60   ~ 0
A5
Text Label 1050 6500 0    60   ~ 0
A4
Entry Wire Line
	6100 4600 6200 4700
Entry Wire Line
	6100 4700 6200 4800
Entry Wire Line
	6100 4800 6200 4900
Entry Wire Line
	6100 4900 6200 5000
Entry Wire Line
	6100 5000 6200 5100
Entry Wire Line
	6100 5100 6200 5200
Entry Wire Line
	6100 5200 6200 5300
Entry Wire Line
	6100 5300 6200 5400
Wire Wire Line
	1550 6750 1550 6900
Wire Wire Line
	1550 5200 1550 5350
Wire Bus Line
	950  5200 950  6400
Wire Wire Line
	1050 5400 1150 5400
Wire Wire Line
	1050 5500 1150 5500
Wire Wire Line
	1050 5600 1150 5600
Wire Wire Line
	1050 5700 1150 5700
Wire Wire Line
	1050 5800 1150 5800
Wire Wire Line
	1050 5900 1150 5900
Wire Wire Line
	1050 6000 1150 6000
Wire Wire Line
	1050 6100 1150 6100
Wire Wire Line
	1150 6200 1050 6200
Wire Wire Line
	1150 6300 1050 6300
Wire Wire Line
	1050 6400 1150 6400
Wire Wire Line
	1050 6500 1150 6500
Wire Wire Line
	2550 6300 4100 6300
Wire Wire Line
	7850 6200 2550 6200
Wire Wire Line
	2550 6100 2600 6100
Wire Wire Line
	2550 6000 2600 6000
Wire Wire Line
	2550 5900 2600 5900
Wire Wire Line
	2550 5800 2600 5800
Wire Wire Line
	2550 5700 2600 5700
Wire Wire Line
	2550 5600 2600 5600
Wire Bus Line
	6100 4550 6100 5300
Wire Wire Line
	6200 4700 6350 4700
Wire Wire Line
	6200 4800 6350 4800
Wire Wire Line
	6200 4900 6350 4900
Wire Wire Line
	6200 5000 6350 5000
Wire Wire Line
	6200 5100 6350 5100
Wire Wire Line
	6200 5200 6350 5200
Wire Wire Line
	6200 5300 6350 5300
Wire Wire Line
	6200 5400 6350 5400
Text Label 6050 4550 0    60   ~ 0
D
Text Label 6200 4700 0    60   ~ 0
D0
Text Label 6200 4800 0    60   ~ 0
D1
Text Label 6200 4900 0    60   ~ 0
D2
Text Label 6200 5000 0    60   ~ 0
D3
Text Label 6200 5100 0    60   ~ 0
D4
Text Label 6200 5200 0    60   ~ 0
D5
Text Label 6200 5300 0    60   ~ 0
D6
Text Label 6200 5400 0    60   ~ 0
D7
Wire Wire Line
	7750 4700 8750 4700
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
L VCC #PWR032
U 1 1 544D6887
P 950 5350
F 0 "#PWR032" H 950 5450 30  0001 C CNN
F 1 "VCC" H 950 5450 30  0000 C CNN
F 2 "" H 950 5350 60  0000 C CNN
F 3 "" H 950 5350 60  0000 C CNN
	1    950  5350
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U9
U 1 1 544D688D
P 1700 4350
F 0 "U9" H 1700 4450 60  0000 C CNN
F 1 "74LS139" H 1700 4250 60  0000 C CNN
F 2 "Sockets_DIP:DIP-16__300_ELL" H 1700 4350 60  0001 C CNN
F 3 "" H 1700 4350 60  0000 C CNN
	1    1700 4350
	1    0    0    -1  
$EndComp
Entry Wire Line
	700  4000 800  4100
Entry Wire Line
	700  4150 800  4250
Text Label 800  4100 0    60   ~ 0
A5
Text Label 800  4250 0    60   ~ 0
A4
Wire Bus Line
	700  3900 700  4200
Wire Wire Line
	800  4100 850  4100
Wire Wire Line
	800  4250 850  4250
Wire Wire Line
	2550 4050 2700 4050
Wire Wire Line
	2550 4250 2700 4250
Wire Wire Line
	2550 4450 2700 4450
Wire Wire Line
	2550 4650 2700 4650
$Comp
L VCC #PWR033
U 1 1 544D68A5
P 1250 3850
F 0 "#PWR033" H 1250 3950 30  0001 C CNN
F 1 "VCC" H 1250 3950 30  0000 C CNN
F 2 "" H 1250 3850 60  0000 C CNN
F 3 "" H 1250 3850 60  0000 C CNN
	1    1250 3850
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR034
U 1 1 544D68AB
P 1250 4850
F 0 "#PWR034" H 1250 4850 30  0001 C CNN
F 1 "GND" H 1250 4780 30  0001 C CNN
F 2 "" H 1250 4850 60  0000 C CNN
F 3 "" H 1250 4850 60  0000 C CNN
	1    1250 4850
	1    0    0    -1  
$EndComp
Wire Wire Line
	1250 3850 1250 3950
Wire Wire Line
	1250 4750 1250 4850
NoConn ~ 2550 4650
Text Label 700  3900 0    60   ~ 0
A
Wire Wire Line
	850  4600 750  4600
Wire Wire Line
	750  4600 750  5050
Wire Wire Line
	750  5050 2700 5050
Wire Wire Line
	2700 5050 2700 5400
Wire Wire Line
	2700 5400 2550 5400
Text HLabel 2600 6100 2    60   Output ~ 0
/CS_ROM
Text HLabel 2600 6000 2    60   Output ~ 0
/CS_LORAM
Text HLabel 2600 5900 2    60   Output ~ 0
/CS_HIRAM
Text HLabel 4100 6300 2    60   Input ~ 0
RW
Text HLabel 2600 5800 2    60   Output ~ 0
/CS_UART
Text HLabel 2600 5700 2    60   Output ~ 0
/CS_VIA
Text HLabel 2600 5600 2    60   Output ~ 0
/CS_VDP
Text HLabel 2700 4050 2    60   Output ~ 0
/CS_IO0
Text HLabel 2700 4250 2    60   Output ~ 0
/CS_IO1
Text HLabel 2700 4450 2    60   Output ~ 0
/CS_IO2
Text HLabel 2700 4650 2    60   Output ~ 0
/CS_IO3
$Comp
L VCC #PWR035
U 1 1 544D6F18
P 6750 4500
F 0 "#PWR035" H 6750 4600 30  0001 C CNN
F 1 "VCC" H 6750 4600 30  0000 C CNN
F 2 "" H 6750 4500 60  0000 C CNN
F 3 "" H 6750 4500 60  0000 C CNN
	1    6750 4500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR036
U 1 1 544D700F
P 6750 5950
F 0 "#PWR036" H 6750 5950 30  0001 C CNN
F 1 "GND" H 6750 5880 30  0001 C CNN
F 2 "" H 6750 5950 60  0000 C CNN
F 3 "" H 6750 5950 60  0000 C CNN
	1    6750 5950
	1    0    0    -1  
$EndComp
Wire Wire Line
	6750 5750 6750 5950
$Comp
L VCC #PWR037
U 1 1 544E9402
P 5500 6950
F 0 "#PWR037" H 5500 7050 30  0001 C CNN
F 1 "VCC" H 5500 7050 30  0000 C CNN
F 2 "" H 5500 6950 60  0000 C CNN
F 3 "" H 5500 6950 60  0000 C CNN
	1    5500 6950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR038
U 1 1 544E9408
P 5500 7500
F 0 "#PWR038" H 5500 7500 30  0001 C CNN
F 1 "GND" H 5500 7430 30  0001 C CNN
F 2 "" H 5500 7500 60  0000 C CNN
F 3 "" H 5500 7500 60  0000 C CNN
	1    5500 7500
	1    0    0    -1  
$EndComp
$Comp
L C C11
U 1 1 544E940E
P 5500 7200
F 0 "C11" H 5500 7300 40  0000 L CNN
F 1 "100n" H 5506 7115 40  0000 L CNN
F 2 "Discret:C1" H 5538 7050 30  0001 C CNN
F 3 "" H 5500 7200 60  0000 C CNN
	1    5500 7200
	1    0    0    -1  
$EndComp
$Comp
L C C12
U 1 1 544E9415
P 5750 7200
F 0 "C12" H 5750 7300 40  0000 L CNN
F 1 "100n" H 5756 7115 40  0000 L CNN
F 2 "Discret:C1" H 5788 7050 30  0001 C CNN
F 3 "" H 5750 7200 60  0000 C CNN
	1    5750 7200
	1    0    0    -1  
$EndComp
$Comp
L C C13
U 1 1 544E941C
P 6000 7200
F 0 "C13" H 6000 7300 40  0000 L CNN
F 1 "100n" H 6006 7115 40  0000 L CNN
F 2 "Discret:C1" H 6038 7050 30  0001 C CNN
F 3 "" H 6000 7200 60  0000 C CNN
	1    6000 7200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 7400 5500 7500
Wire Wire Line
	5500 7000 6500 7000
Wire Wire Line
	5500 7400 6500 7400
Connection ~ 5750 7000
Connection ~ 6000 7000
Connection ~ 6000 7400
Connection ~ 5750 7400
$Comp
L CONN_01X08 P2
U 1 1 544E9377
P 8200 4200
F 0 "P2" H 8200 4650 50  0000 C CNN
F 1 "CONN_01X08" V 8300 4200 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x08" H 8200 4200 60  0001 C CNN
F 3 "" H 8200 4200 60  0000 C CNN
	1    8200 4200
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7750 4800 8750 4800
Wire Wire Line
	7750 4900 8750 4900
Wire Wire Line
	7750 5000 8750 5000
Wire Wire Line
	7750 5100 8750 5100
Wire Wire Line
	7750 5200 8750 5200
Wire Wire Line
	7750 5300 8750 5300
Wire Wire Line
	7750 5400 8750 5400
Text HLabel 7950 5550 3    60   Output ~ 0
BANK1
Text HLabel 8050 5550 3    60   Output ~ 0
BANK2
Wire Wire Line
	7950 4400 7950 5550
Connection ~ 7950 4800
Wire Wire Line
	8050 4400 8050 5550
Connection ~ 8050 4900
Entry Wire Line
	10350 4600 10250 4700
Entry Wire Line
	10350 4700 10250 4800
Entry Wire Line
	10350 4800 10250 4900
Entry Wire Line
	10350 4900 10250 5000
Entry Wire Line
	10350 5000 10250 5100
Entry Wire Line
	10350 5100 10250 5200
Entry Wire Line
	10350 5200 10250 5300
Entry Wire Line
	10350 5300 10250 5400
Wire Bus Line
	10350 4550 10350 5300
Wire Wire Line
	10250 4700 10150 4700
Wire Wire Line
	10250 4800 10150 4800
Wire Wire Line
	10250 4900 10150 4900
Wire Wire Line
	10250 5000 10150 5000
Wire Wire Line
	10250 5100 10150 5100
Wire Wire Line
	10250 5200 10150 5200
Wire Wire Line
	10250 5300 10150 5300
Wire Wire Line
	10250 5400 10150 5400
Text Label 10400 4550 2    60   ~ 0
D
Text Label 10250 4700 2    60   ~ 0
D0
Text Label 10250 4800 2    60   ~ 0
D1
Text Label 10250 4900 2    60   ~ 0
D2
Text Label 10250 5000 2    60   ~ 0
D3
Text Label 10250 5100 2    60   ~ 0
D4
Text Label 10250 5200 2    60   ~ 0
D5
Text Label 10250 5300 2    60   ~ 0
D6
Text Label 10250 5400 2    60   ~ 0
D7
Wire Wire Line
	3450 5500 3450 5750
Wire Wire Line
	2550 5500 3450 5500
Text Label 7900 4700 0    60   ~ 0
/ROMOFF
Text Label 3050 6200 0    60   ~ 0
/ROMOFF
Wire Wire Line
	7850 4400 7850 6200
Connection ~ 7850 4700
Wire Wire Line
	7950 4800 7900 4800
Wire Wire Line
	8150 4400 8150 5000
Connection ~ 8150 5000
Wire Wire Line
	8250 4400 8250 5100
Connection ~ 8250 5100
Wire Wire Line
	8350 4400 8350 5200
Connection ~ 8350 5200
Wire Wire Line
	8450 4400 8450 5300
Connection ~ 8450 5300
Wire Wire Line
	8550 4400 8550 5400
Connection ~ 8550 5400
$Comp
L 74LS139 U9
U 2 1 548A0B1E
P 4550 5500
F 0 "U9" H 4550 5600 60  0000 C CNN
F 1 "74LS139" H 4550 5400 60  0000 C CNN
F 2 "Sockets_DIP:DIP-16__300_ELL" H 4550 5500 60  0001 C CNN
F 3 "" H 4550 5500 60  0000 C CNN
	2    4550 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	3450 5750 3700 5750
Wire Wire Line
	3700 5250 3500 5250
$Comp
L VCC #PWR039
U 1 1 548A1DBF
P 9450 4500
F 0 "#PWR039" H 9450 4600 30  0001 C CNN
F 1 "VCC" H 9450 4600 30  0000 C CNN
F 2 "" H 9450 4500 60  0000 C CNN
F 3 "" H 9450 4500 60  0000 C CNN
	1    9450 4500
	1    0    0    -1  
$EndComp
Wire Wire Line
	9450 4500 9450 4650
$Comp
L GND #PWR040
U 1 1 548A1EB2
P 9450 5950
F 0 "#PWR040" H 9450 5950 30  0001 C CNN
F 1 "GND" H 9450 5880 30  0001 C CNN
F 2 "" H 9450 5950 60  0000 C CNN
F 3 "" H 9450 5950 60  0000 C CNN
	1    9450 5950
	1    0    0    -1  
$EndComp
Wire Wire Line
	9450 5750 9450 5950
$Comp
L 74LS273 U11
U 1 1 544D56DD
P 7050 5200
F 0 "U11" H 7050 5050 60  0000 C CNN
F 1 "74LS273" H 7050 4850 60  0000 C CNN
F 2 "Sockets_DIP:DIP-20__300_ELL" H 7050 5200 60  0001 C CNN
F 3 "" H 7050 5200 60  0000 C CNN
	1    7050 5200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 5400 3600 5400
Wire Wire Line
	3600 5400 3600 6300
Connection ~ 3600 6300
Wire Wire Line
	5500 5800 5500 6050
Wire Wire Line
	5500 6050 8650 6050
$Comp
L 74LS244 U12
U 1 1 54AD6087
P 9450 5200
F 0 "U12" H 9500 5000 60  0000 C CNN
F 1 "74LS244" H 9550 4800 60  0000 C CNN
F 2 "" H 9450 5200 60  0000 C CNN
F 3 "" H 9450 5200 60  0000 C CNN
	1    9450 5200
	1    0    0    -1  
$EndComp
Wire Wire Line
	8750 5600 8650 5600
Wire Wire Line
	8650 5600 8650 6050
Wire Wire Line
	8750 5700 8650 5700
Connection ~ 8650 5700
Text GLabel 3500 5250 0    60   Input ~ 0
PHI2
Wire Wire Line
	5500 5800 5400 5800
NoConn ~ 5400 5400
Wire Wire Line
	6350 5600 5700 5600
Wire Wire Line
	5700 5600 5700 5200
Wire Wire Line
	5700 5200 5400 5200
NoConn ~ 5400 5600
Text HLabel 6200 5700 0    60   Input ~ 0
/RESET
Wire Wire Line
	6200 5700 6350 5700
Wire Wire Line
	5500 7000 5500 6950
Wire Wire Line
	6750 4500 6750 4650
$EndSCHEMATC
