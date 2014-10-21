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
Sheet 4 4
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
L DB9 J?
U 1 1 54318EBC
P 10950 1950
F 0 "J?" H 10950 2500 70  0000 C CNN
F 1 "DB9" H 10950 1400 70  0000 C CNN
F 2 "" H 10950 1950 60  0000 C CNN
F 3 "" H 10950 1950 60  0000 C CNN
	1    10950 1950
	1    0    0    -1  
$EndComp
$Comp
L DB9 J?
U 1 1 54318F7A
P 10950 4750
F 0 "J?" H 10950 5300 70  0000 C CNN
F 1 "DB9" H 10950 4200 70  0000 C CNN
F 2 "" H 10950 4750 60  0000 C CNN
F 3 "" H 10950 4750 60  0000 C CNN
	1    10950 4750
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U?
U 1 1 544620EF
P 6550 1850
F 0 "U?" H 6550 1950 60  0000 C CNN
F 1 "74LS139" H 6550 1750 60  0000 C CNN
F 2 "" H 6550 1850 60  0000 C CNN
F 3 "" H 6550 1850 60  0000 C CNN
	1    6550 1850
	1    0    0    -1  
$EndComp
$Comp
L LTV847 U?
U 1 1 54462383
P 6600 3450
F 0 "U?" H 6300 4350 60  0000 C CNN
F 1 "LTV846" H 6600 2550 60  0000 C CNN
F 2 "" H 6600 3450 60  0000 C CNN
F 3 "" H 6600 3450 60  0000 C CNN
	1    6600 3450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 54466225
P 5700 2200
F 0 "#PWR?" H 5700 2200 30  0001 C CNN
F 1 "GND" H 5700 2130 30  0001 C CNN
F 2 "" H 5700 2200 60  0000 C CNN
F 3 "" H 5700 2200 60  0000 C CNN
	1    5700 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 2100 5700 2200
Text HLabel 5250 1600 0    60   Input ~ 0
PortSel01
Text HLabel 5250 1750 0    60   Input ~ 0
PortSel02
Wire Wire Line
	5250 1600 5700 1600
Wire Wire Line
	5250 1750 5700 1750
$EndSCHEMATC
