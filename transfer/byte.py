#!/usr/bin/python

import serial
import sys
import time
import struct

startaddr = 0x1100

with open("test.bin", 'r') as content_file:
	content = content_file.read()

length = len(content)

ser = serial.Serial(
	port='/dev/tty.usbserial-FTGXH8UA',
	baudrate=38400, 
	bytesize=8, 
	parity='N', 
	stopbits=1,  
	xonxoff=0, 
	rtscts=0,
	timeout=None
)


ser.flushOutput()

print "startaddr : %d" %(startaddr, )
print "length    : %d" % (length, )

bytes = ser.write(struct.pack('<h', startaddr))
if ser.read(2) == 'OK':
	print "Start address %d bytes" % (bytes, )

bytes = ser.write(struct.pack('<h', length))
if ser.read(2) == 'OK':
	print "Length %d bytes" % (bytes, )

# for c in content:
# 	bytes = ser.write(c)
# 	time.sleep(0.1)
	
bytes = ser.write(content)
if ser.read(2) == 'OK':
	print "Length %d bytes" % (bytes, )

ser.close()
