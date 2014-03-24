#!/usr/bin/python

import serial
import sys
import time
import struct

ser = serial.Serial(
	#port='/dev/tty.usbserial-FTAJMAUJ', 
	port='/dev/ttyS5', 
	baudrate=19200, 
	bytesize=8, 
	parity='N', 
	stopbits=1,  
	xonxoff=0, 
	rtscts=0,
	timeout=1
)

bytes = ser.write("Hello World!")
ser.close()
print "Bytes transferred: %d" % (bytes, )

