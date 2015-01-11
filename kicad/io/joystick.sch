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
LIBS:dallas-rtc
LIBS:mini_din
LIBS:io-cache
EELAYER 25 0
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
L DB9 J1
U 1 1 54318EBC
P 10950 1950
F 0 "J1" H 10950 2500 70  0000 C CNN
F 1 "DB9" H 10950 1400 70  0000 C CNN
F 2 "Connect:DB9MC" H 10950 1950 60  0001 C CNN
F 3 "" H 10950 1950 60  0000 C CNN
	1    10950 1950
	1    0    0    -1  
$EndComp
$Comp
L DB9 J2
U 1 1 54318F7A
P 10950 4750
F 0 "J2" H 10950 5300 70  0000 C CNN
F 1 "DB9" H 10950 4200 70  0000 C CNN
F 2 "Connect:DB9MC" H 10950 4750 60  0001 C CNN
F 3 "" H 10950 4750 60  0000 C CNN
	1    10950 4750
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U3
U 1 1 544620EF
P 6550 1850
F 0 "U3" H 6550 1950 60  0000 C CNN
F 1 "74LS139" H 6550 1750 60  0000 C CNN
F 2 "Sockets_DIP:DIP-16__300_ELL" H 6550 1850 60  0001 C CNN
F 3 "" H 6550 1850 60  0000 C CNN
	1    6550 1850
	1    0    0    -1  
$EndComp
$Comp
L LTV847 U6
U 1 1 54462383
P 6600 3450
F 0 "U6" H 6300 4350 60  0000 C CNN
F 1 "LTV846" H 6600 2550 60  0000 C CNN
F 2 "Sockets_DIP:DIP-16__300_ELL" H 6600 3450 60  0001 C CNN
F 3 "" H 6600 3450 60  0000 C CNN
	1    6600 3450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR031
U 1 1 54466225
P 5700 2200
F 0 "#PWR031" H 5700 2200 30  0001 C CNN
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
Text HLabel 4300 2050 0    60   Input ~ 0
J_Right
Text HLabel 4250 2200 0    60   Input ~ 0
J_Left
Text HLabel 4200 2400 0    60   Input ~ 0
J_Up
Text HLabel 4250 2550 0    60   Input ~ 0
J_Down
Text HLabel 4200 2800 0    60   Input ~ 0
J_Fire1
Text HLabel 4200 2950 0    60   Input ~ 0
J_Fire2
$EndSCHEMATC
