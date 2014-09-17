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
LIBS:tms9929-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
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
L 4164 U1
U 1 1 5419CCC1
P 5850 2150
F 0 "U1" H 5950 2150 70  0000 C CNN
F 1 "4164" H 5900 2350 70  0000 C CNN
F 2 "" H 5850 2150 60  0000 C CNN
F 3 "" H 5850 2150 60  0000 C CNN
	1    5850 2150
	1    0    0    -1  
$EndComp
$Comp
L TMS9929A U?
U 1 1 5419D4D1
P 2550 2750
F 0 "U?" H 2550 4000 60  0000 C CNN
F 1 "TMS9929A" H 2550 3050 60  0000 C CNN
F 2 "" H 2550 2750 60  0000 C CNN
F 3 "" H 2550 2750 60  0000 C CNN
	1    2550 2750
	1    0    0    -1  
$EndComp
Entry Wire Line
	3350 1750 3450 1850
Entry Wire Line
	3350 1850 3450 1950
Entry Wire Line
	3350 1950 3450 2050
Entry Wire Line
	3350 2050 3450 2150
Entry Wire Line
	3350 2150 3450 2250
Entry Wire Line
	3350 2250 3450 2350
Entry Wire Line
	3350 2350 3450 2450
Entry Wire Line
	5150 1600 5250 1500
Entry Wire Line
	5150 1700 5250 1600
Entry Wire Line
	5150 1800 5250 1700
Entry Wire Line
	5150 1900 5250 1800
Entry Wire Line
	5150 2000 5250 1900
Entry Wire Line
	5150 2100 5250 2000
Entry Wire Line
	5150 2200 5250 2100
Wire Bus Line
	3450 1850 3450 2450
Wire Bus Line
	5150 1600 5150 2200
$Comp
L GND #PWR?
U 1 1 5419DABD
P 5250 2250
F 0 "#PWR?" H 5250 2250 30  0001 C CNN
F 1 "GND" H 5250 2180 30  0001 C CNN
F 2 "" H 5250 2250 60  0000 C CNN
F 3 "" H 5250 2250 60  0000 C CNN
	1    5250 2250
	1    0    0    -1  
$EndComp
Wire Wire Line
	5250 2200 5250 2250
Entry Wire Line
	3350 2550 3450 2650
Entry Wire Line
	3350 2650 3450 2750
Entry Wire Line
	3350 2750 3450 2850
Entry Wire Line
	5150 2700 5250 2600
Entry Wire Line
	5150 2800 5250 2700
Entry Wire Line
	5150 2900 5250 2800
Wire Bus Line
	3450 2650 3450 2850
Wire Bus Line
	5150 2700 5150 2900
$Comp
L CRYSTAL 10.738MHz
U 1 1 5419E797
P 1200 3600
F 0 "10.738MHz" H 1200 3750 60  0000 C CNN
F 1 "CRYSTAL" H 1200 3450 60  0000 C CNN
F 2 "" H 1200 3600 60  0000 C CNN
F 3 "" H 1200 3600 60  0000 C CNN
	1    1200 3600
	0    1    1    0   
$EndComp
$Comp
L GND #PWR?
U 1 1 5419EC6F
P 1750 4100
F 0 "#PWR?" H 1750 4100 30  0001 C CNN
F 1 "GND" H 1750 4030 30  0001 C CNN
F 2 "" H 1750 4100 60  0000 C CNN
F 3 "" H 1750 4100 60  0000 C CNN
	1    1750 4100
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5419ED2E
P 1000 3300
F 0 "C1" H 1000 3400 40  0000 L CNN
F 1 "33pf" H 1006 3215 40  0000 L CNN
F 2 "" H 1038 3150 30  0000 C CNN
F 3 "" H 1000 3300 60  0000 C CNN
	1    1000 3300
	0    -1   -1   0   
$EndComp
$Comp
L C C2
U 1 1 5419EDDB
P 1000 3900
F 0 "C2" H 1000 4000 40  0000 L CNN
F 1 "33pf" H 1006 3815 40  0000 L CNN
F 2 "" H 1038 3750 30  0000 C CNN
F 3 "" H 1000 3900 60  0000 C CNN
	1    1000 3900
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1750 3650 1450 3650
Wire Wire Line
	1450 3650 1450 3900
Wire Wire Line
	1450 3900 1200 3900
Wire Wire Line
	1200 3300 1450 3300
Wire Wire Line
	1450 3300 1450 3550
Wire Wire Line
	1450 3550 1750 3550
Wire Wire Line
	1750 4050 1750 4100
Wire Wire Line
	800  3300 800  4100
Connection ~ 800  3900
$Comp
L GND #PWR?
U 1 1 5419F293
P 800 4100
F 0 "#PWR?" H 800 4100 30  0001 C CNN
F 1 "GND" H 800 4030 30  0001 C CNN
F 2 "" H 800 4100 60  0000 C CNN
F 3 "" H 800 4100 60  0000 C CNN
	1    800  4100
	1    0    0    -1  
$EndComp
$EndSCHEMATC
