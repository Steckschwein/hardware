#!/usr/bin/python

import serial
import sys
import time
import struct

#baudrate=38400
baudrate=115200

try:
	filename 	= sys.argv[1]
	try:
		startaddr   = int(sys.argv[2], 16)
	except IndexError:
		startaddr = 0x1000





	with open(filename, 'r') as content_file:
		content = content_file.read()

	length = len(content)


	ser = serial.Serial(
		port='/dev/tty.usbserial-FTGXH8UA',
		#port='/dev/tty.usbserial-FTAJMAUJ', 
		baudrate=baudrate,
		bytesize=8, 
		parity='N', 
		stopbits=1,
		xonxoff=0, 
		rtscts=0,
		timeout=None
	)
	

	print "Startaddress : 0x%04x (%d)" % (startaddr, startaddr)
	print "length    	: %d bytes" % (length, )

	ser.flushOutput()

	bytes = ser.write(struct.pack('<h', startaddr))
	if ser.read(2) == 'OK':
		print "Start address %d bytes" % (bytes, )

	bytes = ser.write(struct.pack('<h', length))
	if ser.read(2) == 'OK':
		print "Length %d bytes" % (bytes, )
		
	bytes = ser.write(content)
	if ser.read(2) == 'OK':
		print "Length %d bytes" % (bytes, )
		print "Bytes transferred: %d" % (bytes, )

	ser.close()

except IndexError:
	print "%s <filename>" % (sys.argv[0],)
	sys.exit(1)
except IOError:	
	print "%s: file '%s' not found" % (sys.argv[0], filename, )
	sys.exit(1)
