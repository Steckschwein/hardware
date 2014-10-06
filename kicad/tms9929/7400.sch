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
L 74LS00 U?
U 1 1 54318D80
P 3050 1700
F 0 "U?" H 3050 1750 60  0000 C CNN
F 1 "74LS00" H 3050 1600 60  0000 C CNN
F 2 "" H 3050 1700 60  0000 C CNN
F 3 "" H 3050 1700 60  0000 C CNN
	1    3050 1700
	1    0    0    -1  
$EndComp
$Comp
L 74LS00 U?
U 2 1 54318DD5
P 3050 2450
F 0 "U?" H 3050 2500 60  0000 C CNN
F 1 "74LS00" H 3050 2350 60  0000 C CNN
F 2 "" H 3050 2450 60  0000 C CNN
F 3 "" H 3050 2450 60  0000 C CNN
	2    3050 2450
	1    0    0    -1  
$EndComp
$Comp
L 74LS00 U?
U 3 1 54318E18
P 4800 1700
F 0 "U?" H 4800 1750 60  0000 C CNN
F 1 "74LS00" H 4800 1600 60  0000 C CNN
F 2 "" H 4800 1700 60  0000 C CNN
F 3 "" H 4800 1700 60  0000 C CNN
	3    4800 1700
	1    0    0    -1  
$EndComp
$Comp
L 74LS00 U?
U 4 1 54318E50
P 4800 2450
F 0 "U?" H 4800 2500 60  0000 C CNN
F 1 "74LS00" H 4800 2350 60  0000 C CNN
F 2 "" H 4800 2450 60  0000 C CNN
F 3 "" H 4800 2450 60  0000 C CNN
	4    4800 2450
	1    0    0    -1  
$EndComp
Text GLabel 2100 1600 0    60   Input ~ 0
/CSVDP
Text GLabel 2100 2350 0    60   Input ~ 0
R/W
Wire Wire Line
	2100 1600 2450 1600
Wire Wire Line
	2350 1600 2350 1800
Wire Wire Line
	2350 1800 2450 1800
Wire Wire Line
	2100 2350 2450 2350
Wire Wire Line
	2350 2000 2350 2550
Wire Wire Line
	2350 2550 2450 2550
Connection ~ 2350 1600
Connection ~ 2350 2350
Wire Wire Line
	3650 1700 3650 1600
Wire Wire Line
	3650 1600 4200 1600
Wire Wire Line
	4200 2350 3950 2350
Wire Wire Line
	3950 2350 3950 1600
Connection ~ 3950 1600
Wire Wire Line
	3650 2450 4200 2450
Wire Wire Line
	4200 2450 4200 2550
Wire Wire Line
	2350 2000 4200 2000
Wire Wire Line
	4200 2000 4200 1800
Wire Wire Line
	5400 2450 5750 2450
Wire Wire Line
	5400 1700 5750 1700
Text GLabel 5750 1700 2    60   Output ~ 0
/VDP_CSR
Text GLabel 5750 2450 2    60   Output ~ 0
/VDP_CSW
$EndSCHEMATC
