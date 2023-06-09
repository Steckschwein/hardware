EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:74xx
LIBS:contrib
LIBS:tms99xx
LIBS:dram
LIBS:osc
LIBS:mini_din
LIBS:steckschwein
LIBS:yamaha_opl
LIBS:w_connectors
LIBS:v9958-cache
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
L R-RESCUE-v9958 R7
U 1 1 5BE2C4BA
P 3850 2750
F 0 "R7" V 3930 2750 40  0000 C CNN
F 1 "470" V 3857 2751 40  0000 C CNN
F 2 "Discret:R3" V 3780 2750 30  0001 C CNN
F 3 "" H 3850 2750 30  0000 C CNN
	1    3850 2750
	-1   0    0    1   
$EndComp
$Comp
L R-RESCUE-v9958 R8
U 1 1 5BE2C4C1
P 4000 2750
F 0 "R8" V 4080 2750 40  0000 C CNN
F 1 "470" V 4007 2751 40  0000 C CNN
F 2 "Discret:R3" V 3930 2750 30  0001 C CNN
F 3 "" H 4000 2750 30  0000 C CNN
	1    4000 2750
	-1   0    0    1   
$EndComp
$Comp
L R-RESCUE-v9958 R9
U 1 1 5BE2C4C8
P 4150 2750
F 0 "R9" V 4230 2750 40  0000 C CNN
F 1 "470" V 4157 2751 40  0000 C CNN
F 2 "Discret:R3" V 4080 2750 30  0001 C CNN
F 3 "" H 4150 2750 30  0000 C CNN
	1    4150 2750
	-1   0    0    1   
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR040
U 1 1 5BE2C4CF
P 4000 3100
F 0 "#PWR040" H 4000 3100 30  0001 C CNN
F 1 "GND" H 4000 3030 30  0001 C CNN
F 2 "" H 4000 3100 60  0000 C CNN
F 3 "" H 4000 3100 60  0000 C CNN
	1    4000 3100
	1    0    0    -1  
$EndComp
$Comp
L cxa2075M U12
U 1 1 5BE2C4D5
P 5600 3250
F 0 "U12" H 5600 3250 60  0000 C CNN
F 1 "cxa2075M" H 5800 2650 60  0000 C CNN
F 2 "Housings_SOIC:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 5600 2550 60  0001 C CNN
F 3 "" H 5600 2550 60  0000 C CNN
	1    5600 3250
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR041
U 1 1 5BE2C4DC
P 4850 3550
F 0 "#PWR041" H 4850 3550 30  0001 C CNN
F 1 "GND" H 4850 3480 30  0001 C CNN
F 2 "" H 4850 3550 60  0000 C CNN
F 3 "" H 4850 3550 60  0000 C CNN
	1    4850 3550
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR042
U 1 1 5BE2C4E2
P 6750 2550
F 0 "#PWR042" H 6750 2550 30  0001 C CNN
F 1 "GND" H 6750 2480 30  0001 C CNN
F 2 "" H 6750 2550 60  0000 C CNN
F 3 "" H 6750 2550 60  0000 C CNN
	1    6750 2550
	-1   0    0    1   
$EndComp
$Comp
L VCC #PWR043
U 1 1 5BE2C4E8
P 4450 3850
F 0 "#PWR043" H 4450 3950 30  0001 C CNN
F 1 "VCC" H 4450 3950 30  0000 C CNN
F 2 "" H 4450 3850 60  0000 C CNN
F 3 "" H 4450 3850 60  0000 C CNN
	1    4450 3850
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR044
U 1 1 5BE2C4EE
P 7500 3250
F 0 "#PWR044" H 7500 3350 30  0001 C CNN
F 1 "VCC" H 7500 3350 30  0000 C CNN
F 2 "" H 7500 3250 60  0000 C CNN
F 3 "" H 7500 3250 60  0000 C CNN
	1    7500 3250
	0    1    1    0   
$EndComp
$Comp
L R-RESCUE-v9958 R16
U 1 1 5BE2C4F4
P 6550 3450
F 0 "R16" V 6630 3450 40  0000 C CNN
F 1 "2.61k/10%" V 6557 3451 40  0000 C CNN
F 2 "Discret:R3" V 6480 3450 30  0001 C CNN
F 3 "" H 6550 3450 30  0000 C CNN
	1    6550 3450
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R17
U 1 1 5BE2C4FB
P 6550 3550
F 0 "R17" V 6550 3650 40  0000 C CNN
F 1 "75" V 6557 3551 40  0000 C CNN
F 2 "Discret:R3" V 6480 3550 30  0001 C CNN
F 3 "" H 6550 3550 30  0000 C CNN
	1    6550 3550
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R18
U 1 1 5BE2C502
P 6550 3650
F 0 "R18" V 6550 3750 40  0000 C CNN
F 1 "75" V 6557 3651 40  0000 C CNN
F 2 "Discret:R3" V 6480 3650 30  0001 C CNN
F 3 "" H 6550 3650 30  0000 C CNN
	1    6550 3650
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R14
U 1 1 5BE2C509
P 6550 3050
F 0 "R14" V 6550 3150 40  0000 C CNN
F 1 "75" V 6557 3051 40  0000 C CNN
F 2 "Discret:R3" V 6480 3050 30  0001 C CNN
F 3 "" H 6550 3050 30  0000 C CNN
	1    6550 3050
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R13
U 1 1 5BE2C510
P 6550 2950
F 0 "R13" V 6550 3050 40  0000 C CNN
F 1 "75" V 6557 2951 40  0000 C CNN
F 2 "Discret:R3" V 6480 2950 30  0001 C CNN
F 3 "" H 6550 2950 30  0000 C CNN
	1    6550 2950
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R12
U 1 1 5BE2C517
P 6550 2850
F 0 "R12" V 6550 2950 40  0000 C CNN
F 1 "75" V 6557 2851 40  0000 C CNN
F 2 "Discret:R3" V 6480 2850 30  0001 C CNN
F 3 "" H 6550 2850 30  0000 C CNN
	1    6550 2850
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R15
U 1 1 5BE2C51E
P 6550 3150
F 0 "R15" V 6550 3250 40  0000 C CNN
F 1 "43" V 6557 3151 40  0000 C CNN
F 2 "Discret:R3" V 6480 3150 30  0001 C CNN
F 3 "" H 6550 3150 30  0000 C CNN
	1    6550 3150
	0    -1   -1   0   
$EndComp
$Comp
L CP C21
U 1 1 5BE2C525
P 7000 2650
F 0 "C21" H 7025 2750 50  0000 L CNN
F 1 "220µF" H 7025 2550 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D6.3mm_P2.50mm" H 7038 2500 50  0001 C CNN
F 3 "" H 7000 2650 50  0000 C CNN
	1    7000 2650
	-1   0    0    1   
$EndComp
$Comp
L CP C24
U 1 1 5BE2C52C
P 7250 2650
F 0 "C24" H 7275 2750 50  0000 L CNN
F 1 "220µF" H 7275 2550 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D6.3mm_P2.50mm" H 7288 2500 50  0001 C CNN
F 3 "" H 7250 2650 50  0000 C CNN
	1    7250 2650
	-1   0    0    1   
$EndComp
$Comp
L CP C26
U 1 1 5BE2C533
P 7500 2650
F 0 "C26" H 7525 2750 50  0000 L CNN
F 1 "220µF" H 7525 2550 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D6.3mm_P2.50mm" H 7538 2500 50  0001 C CNN
F 3 "" H 7500 2650 50  0000 C CNN
	1    7500 2650
	-1   0    0    1   
$EndComp
$Comp
L CP C27
U 1 1 5BE2C53A
P 7750 2650
F 0 "C27" H 7775 2750 50  0000 L CNN
F 1 "220µF" H 7775 2550 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D6.3mm_P2.50mm" H 7788 2500 50  0001 C CNN
F 3 "" H 7750 2650 50  0000 C CNN
	1    7750 2650
	-1   0    0    1   
$EndComp
$Comp
L CP C20
U 1 1 5BE2C541
P 6850 3850
F 0 "C20" H 6875 3950 50  0000 L CNN
F 1 "220µF" H 6875 3750 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D6.3mm_P2.50mm" H 6888 3700 50  0001 C CNN
F 3 "" H 6850 3850 50  0000 C CNN
	1    6850 3850
	1    0    0    -1  
$EndComp
$Comp
L CP C22
U 1 1 5BE2C548
P 7100 3850
F 0 "C22" H 7125 3950 50  0000 L CNN
F 1 "220µF" H 7125 3750 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D6.3mm_P2.50mm" H 7138 3700 50  0001 C CNN
F 3 "" H 7100 3850 50  0000 C CNN
	1    7100 3850
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R19
U 1 1 5BE2C54F
P 7750 3400
F 0 "R19" V 7750 3350 40  0000 C CNN
F 1 "240" V 7750 3500 40  0000 C CNN
F 2 "Discret:R3" V 7680 3400 30  0001 C CNN
F 3 "" H 7750 3400 30  0000 C CNN
	1    7750 3400
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR045
U 1 1 5BE2C556
P 7750 3750
F 0 "#PWR045" H 7750 3750 30  0001 C CNN
F 1 "GND" H 7750 3680 30  0001 C CNN
F 2 "" H 7750 3750 60  0000 C CNN
F 3 "" H 7750 3750 60  0000 C CNN
	1    7750 3750
	1    0    0    -1  
$EndComp
$Comp
L C C18
U 1 1 5BE2C55C
P 4800 2500
F 0 "C18" H 4825 2600 50  0000 L CNN
F 1 "100n" H 4825 2400 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3.0mm_W1.6mm_P2.50mm" H 4838 2350 50  0001 C CNN
F 3 "" H 4800 2500 50  0001 C CNN
	1    4800 2500
	1    0    0    -1  
$EndComp
$Comp
L C C16
U 1 1 5BE2C563
P 4600 2500
F 0 "C16" H 4625 2600 50  0000 L CNN
F 1 "100n" H 4625 2400 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3.0mm_W1.6mm_P2.50mm" H 4638 2350 50  0001 C CNN
F 3 "" H 4600 2500 50  0001 C CNN
	1    4600 2500
	1    0    0    -1  
$EndComp
$Comp
L C C15
U 1 1 5BE2C56A
P 4400 2500
F 0 "C15" H 4425 2600 50  0000 L CNN
F 1 "100n" H 4425 2400 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3.0mm_W1.6mm_P2.50mm" H 4438 2350 50  0001 C CNN
F 3 "" H 4400 2500 50  0001 C CNN
	1    4400 2500
	1    0    0    -1  
$EndComp
$Comp
L OSC X1
U 1 1 5BE2C571
P 3500 3400
F 0 "X1" H 3500 3700 70  0000 C CNN
F 1 "OSC" H 3500 3400 70  0000 C CNN
F 2 "Oscillators:Oscillator_DIP-14_LargePads" H 3500 3400 60  0001 C CNN
F 3 "" H 3500 3400 60  0000 C CNN
	1    3500 3400
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R10
U 1 1 5BE2C578
P 4600 3250
F 0 "R10" V 4680 3250 40  0000 C CNN
F 1 "2.2k" V 4607 3251 40  0000 C CNN
F 2 "Discret:R3" V 4530 3250 30  0001 C CNN
F 3 "" H 4600 3250 30  0000 C CNN
	1    4600 3250
	0    -1   -1   0   
$EndComp
$Comp
L C C19
U 1 1 5BE2C57F
P 4850 4050
F 0 "C19" H 4875 4150 50  0000 L CNN
F 1 "100n" H 4875 3950 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3.0mm_W1.6mm_P2.50mm" H 4888 3900 50  0001 C CNN
F 3 "" H 4850 4050 50  0001 C CNN
	1    4850 4050
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR046
U 1 1 5BE2C586
P 4850 4350
F 0 "#PWR046" H 4850 4350 30  0001 C CNN
F 1 "GND" H 4850 4280 30  0001 C CNN
F 2 "" H 4850 4350 60  0000 C CNN
F 3 "" H 4850 4350 60  0000 C CNN
	1    4850 4350
	1    0    0    -1  
$EndComp
$Comp
L CP C17
U 1 1 5BE2C58C
P 4600 4050
F 0 "C17" H 4625 4150 50  0000 L CNN
F 1 "47µF" H 4625 3950 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D6.3mm_P2.50mm" H 4638 3900 50  0001 C CNN
F 3 "" H 4600 4050 50  0000 C CNN
	1    4600 4050
	1    0    0    -1  
$EndComp
$Comp
L C C25
U 1 1 5BE2C593
P 7450 3450
F 0 "C25" H 7475 3550 50  0000 L CNN
F 1 "100n" H 7475 3350 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3.0mm_W2.0mm_P2.50mm" H 7488 3300 50  0001 C CNN
F 3 "" H 7450 3450 50  0001 C CNN
	1    7450 3450
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR047
U 1 1 5BE2C59A
P 7450 3750
F 0 "#PWR047" H 7450 3750 30  0001 C CNN
F 1 "GND" H 7450 3680 30  0001 C CNN
F 2 "" H 7450 3750 60  0000 C CNN
F 3 "" H 7450 3750 60  0000 C CNN
	1    7450 3750
	1    0    0    -1  
$EndComp
$Comp
L CP C23
U 1 1 5BE2C5A0
P 7200 3450
F 0 "C23" H 7225 3550 50  0000 L CNN
F 1 "47µF" H 7225 3350 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D6.3mm_P2.50mm" H 7238 3300 50  0001 C CNN
F 3 "" H 7200 3450 50  0000 C CNN
	1    7200 3450
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR048
U 1 1 5BE2C5A7
P 2750 3200
F 0 "#PWR048" H 2750 3300 30  0001 C CNN
F 1 "VCC" H 2750 3300 30  0000 C CNN
F 2 "" H 2750 3200 60  0000 C CNN
F 3 "" H 2750 3200 60  0000 C CNN
	1    2750 3200
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR049
U 1 1 5BE2C5AD
P 2750 3650
F 0 "#PWR049" H 2750 3650 30  0001 C CNN
F 1 "GND" H 2750 3580 30  0001 C CNN
F 2 "" H 2750 3650 60  0000 C CNN
F 3 "" H 2750 3650 60  0000 C CNN
	1    2750 3650
	1    0    0    -1  
$EndComp
NoConn ~ 4200 3550
$Comp
L R-RESCUE-v9958 R11
U 1 1 5BE2C5B4
P 4600 3650
F 0 "R11" V 4680 3650 40  0000 C CNN
F 1 "2.2k" V 4607 3651 40  0000 C CNN
F 2 "Discret:R3" V 4530 3650 30  0001 C CNN
F 3 "" H 4600 3650 30  0000 C CNN
	1    4600 3650
	0    -1   -1   0   
$EndComp
Text Label 6850 4250 1    60   ~ 0
C_OUT
Text Label 7100 4250 1    60   ~ 0
Y_OUT
$Comp
L MINI_DIN_4 X?
U 1 1 5BE2C5C1
P 7000 5250
AR Path="/5BE2C5C1" Ref="X?"  Part="1" 
AR Path="/5BE2B3F4/5BE2C5C1" Ref="J4"  Part="1" 
F 0 "J4" H 6600 5775 50  0000 L BNN
F 1 "S-VIDEO" H 7000 5775 50  0000 L BNN
F 2 "mini_din:mini_din-M_DIN4" H 7000 5400 50  0001 C CNN
F 3 "" H 7000 5250 60  0000 C CNN
	1    7000 5250
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR050
U 1 1 5BE2C5F6
P 7100 1000
F 0 "#PWR050" H 7100 1000 30  0001 C CNN
F 1 "GND" H 7100 930 30  0001 C CNN
F 2 "" H 7100 1000 60  0000 C CNN
F 3 "" H 7100 1000 60  0000 C CNN
	1    7100 1000
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR051
U 1 1 5BE2C5FC
P 6350 5250
F 0 "#PWR051" H 6350 5250 30  0001 C CNN
F 1 "GND" H 6350 5180 30  0001 C CNN
F 2 "" H 6350 5250 60  0000 C CNN
F 3 "" H 6350 5250 60  0000 C CNN
	1    6350 5250
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR052
U 1 1 5BE2C602
P 7650 5250
F 0 "#PWR052" H 7650 5250 30  0001 C CNN
F 1 "GND" H 7650 5180 30  0001 C CNN
F 2 "" H 7650 5250 60  0000 C CNN
F 3 "" H 7650 5250 60  0000 C CNN
	1    7650 5250
	1    0    0    -1  
$EndComp
Text Label 7750 5050 2    60   ~ 0
Y_OUT
Text Label 6450 5050 2    60   ~ 0
C_OUT
$Comp
L GND-RESCUE-v9958 #PWR053
U 1 1 5BE2C60A
P 7000 5750
F 0 "#PWR053" H 7000 5750 30  0001 C CNN
F 1 "GND" H 7000 5680 30  0001 C CNN
F 2 "" H 7000 5750 60  0000 C CNN
F 3 "" H 7000 5750 60  0000 C CNN
	1    7000 5750
	1    0    0    -1  
$EndComp
NoConn ~ 4950 3450
Text Label 3000 2100 0    60   ~ 0
RGB_B
Text Label 3000 2200 0    60   ~ 0
RGB_R
Text Label 3000 2300 0    60   ~ 0
RGB_G
Text Label 3000 2400 0    60   ~ 0
CSYNC
Text HLabel 3000 2100 0    60   Input ~ 0
RGB_B
Text HLabel 3000 2200 0    60   Input ~ 0
RGB_R
Text HLabel 3000 2300 0    60   Input ~ 0
RGB_G
Text HLabel 3000 2400 0    60   Input ~ 0
CSYNC
$Comp
L DIN-8 J2
U 1 1 5BE1DD3F
P 7450 1250
F 0 "J2" H 7575 1475 50  0000 C CNN
F 1 "RGB" H 7000 1050 50  0000 L CNN
F 2 "w_conn_av:DIN-8" H 7450 1250 50  0001 C CNN
F 3 "" H 7450 1250 50  0001 C CNN
	1    7450 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 2300 4600 2300
Wire Wire Line
	3850 2300 3850 2500
Wire Wire Line
	4000 2200 4000 2500
Wire Wire Line
	4150 2100 4150 2500
Wire Wire Line
	3850 3000 3850 3050
Wire Wire Line
	3850 3050 4150 3050
Wire Wire Line
	4150 3050 4150 3000
Wire Wire Line
	4000 3000 4000 3100
Connection ~ 4000 3050
Wire Wire Line
	4850 2750 4950 2750
Wire Wire Line
	6250 2750 6750 2750
Wire Wire Line
	4450 3850 4950 3850
Wire Wire Line
	6250 3250 7500 3250
Wire Wire Line
	6250 3450 6300 3450
Wire Wire Line
	6800 3450 6800 3250
Connection ~ 6800 3250
Wire Wire Line
	6750 2750 6750 2550
Wire Wire Line
	6250 2850 6300 2850
Wire Wire Line
	6250 2950 6300 2950
Wire Wire Line
	6250 3050 6300 3050
Wire Wire Line
	6250 3550 6300 3550
Wire Wire Line
	6250 3650 6300 3650
Wire Wire Line
	6250 3150 6300 3150
Wire Wire Line
	6800 2850 7000 2850
Wire Wire Line
	7000 2850 7000 2800
Wire Wire Line
	6800 2950 7250 2950
Wire Wire Line
	7250 2950 7250 2800
Wire Wire Line
	6800 3050 7500 3050
Wire Wire Line
	7500 3050 7500 2800
Wire Wire Line
	6800 3150 7750 3150
Wire Wire Line
	7750 3150 7750 2800
Wire Wire Line
	7750 3650 7750 3650
Wire Wire Line
	6800 3650 6850 3650
Wire Wire Line
	6850 3650 6850 3700
Wire Wire Line
	6800 3550 7100 3550
Wire Wire Line
	7100 3550 7100 3700
Wire Wire Line
	4950 2850 4800 2850
Wire Wire Line
	4800 2850 4800 2650
Wire Wire Line
	4950 2950 4600 2950
Wire Wire Line
	4600 2950 4600 2650
Wire Wire Line
	4950 3050 4400 3050
Wire Wire Line
	4400 3050 4400 2650
Wire Wire Line
	4850 2750 4850 3550
Wire Wire Line
	4950 3350 4850 3350
Connection ~ 4850 3350
Wire Wire Line
	4200 3250 4350 3250
Wire Wire Line
	4850 3250 4950 3250
Wire Wire Line
	4850 4200 4850 4350
Wire Wire Line
	4600 4200 4600 4250
Wire Wire Line
	4600 4250 4850 4250
Connection ~ 4850 4250
Wire Wire Line
	7450 3600 7450 3750
Wire Wire Line
	7200 3600 7200 3650
Wire Wire Line
	7200 3650 7450 3650
Connection ~ 7450 3650
Wire Wire Line
	7750 3650 7750 3750
Wire Wire Line
	2750 3200 2750 3250
Wire Wire Line
	2750 3250 2800 3250
Wire Wire Line
	2800 3550 2750 3550
Wire Wire Line
	2750 3550 2750 3650
Wire Wire Line
	4850 3650 4950 3650
Wire Wire Line
	4350 3650 4250 3650
Wire Wire Line
	7000 1350 7000 2500
Wire Wire Line
	7250 2000 7250 2500
Wire Wire Line
	7500 1550 7500 2500
Wire Wire Line
	7750 2500 7750 2300
Wire Wire Line
	7100 4000 7100 4250
Wire Wire Line
	6850 4000 6850 4250
Wire Wire Line
	7100 850  7100 1000
Wire Wire Line
	6350 5250 6350 5150
Wire Wire Line
	6350 5150 6400 5150
Wire Wire Line
	7600 5150 7650 5150
Wire Wire Line
	7650 5150 7650 5250
Wire Wire Line
	6500 5050 6200 5050
Wire Wire Line
	7500 5050 7800 5050
Wire Wire Line
	6500 5450 6500 5650
Wire Wire Line
	6500 5650 7500 5650
Wire Wire Line
	7500 5650 7500 5450
Connection ~ 7000 5650
Wire Wire Line
	7000 5650 7000 5750
Wire Wire Line
	4600 3900 4600 3850
Connection ~ 4600 3850
Wire Wire Line
	4850 3900 4850 3850
Connection ~ 4850 3850
Wire Wire Line
	7200 3250 7200 3300
Connection ~ 7200 3250
Wire Wire Line
	7450 3250 7450 3300
Connection ~ 7450 3250
Connection ~ 3850 2300
Wire Wire Line
	3000 2200 4800 2200
Connection ~ 4000 2200
Wire Wire Line
	3000 2100 4400 2100
Connection ~ 4150 2100
Wire Wire Line
	4600 2300 4600 2350
Wire Wire Line
	3000 2400 4250 2400
Wire Wire Line
	4250 2400 4250 3650
Wire Wire Line
	4800 2200 4800 2350
Wire Wire Line
	4400 2100 4400 2350
Wire Wire Line
	7150 1250 6800 1250
Text HLabel 6800 1250 0    60   Input ~ 0
AUDIO_OUT
Wire Wire Line
	7150 1150 6800 1150
Wire Wire Line
	7450 950  7450 850 
Wire Wire Line
	7450 850  7100 850 
Wire Wire Line
	7750 1150 8100 1150
Wire Wire Line
	7750 1250 8900 1250
Wire Wire Line
	7750 1350 8400 1350
Text Label 7850 1150 0    60   ~ 0
G_OUT
$Comp
L VCC #PWR054
U 1 1 5BE1EA79
P 6800 1050
F 0 "#PWR054" H 6800 1150 30  0001 C CNN
F 1 "VCC" H 6800 1150 30  0000 C CNN
F 2 "" H 6800 1050 60  0000 C CNN
F 3 "" H 6800 1050 60  0000 C CNN
	1    6800 1050
	1    0    0    -1  
$EndComp
Wire Wire Line
	6800 1150 6800 1050
$Comp
L Conn_Coaxial J3
U 1 1 5BE208A4
P 9050 1250
F 0 "J3" H 9060 1370 50  0000 C CNN
F 1 "Composite" V 9165 1250 50  0000 C CNN
F 2 "misc:rca" H 9050 1250 50  0001 C CNN
F 3 "" H 9050 1250 50  0001 C CNN
	1    9050 1250
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR055
U 1 1 5BE20A09
P 9050 1600
F 0 "#PWR055" H 9050 1600 30  0001 C CNN
F 1 "GND" H 9050 1530 30  0001 C CNN
F 2 "" H 9050 1600 60  0000 C CNN
F 3 "" H 9050 1600 60  0000 C CNN
	1    9050 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	9050 1450 9050 1600
Wire Wire Line
	7750 2300 8400 2300
Wire Wire Line
	8400 2300 8400 1250
Connection ~ 8400 1350
Wire Wire Line
	7450 1550 7500 1550
Wire Wire Line
	7250 2000 8100 2000
Wire Wire Line
	8100 2000 8100 1150
Wire Wire Line
	7000 1350 7150 1350
Connection ~ 8400 1250
$EndSCHEMATC
