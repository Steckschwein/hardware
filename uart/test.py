#!/usr/bin/python

import serial
import sys
import time
import struct

try:
#	filename = sys.argv[1]

#	with open(filename, 'r') as content_file:
# 		content = content_file.read()
	
	content = "abcdefghijklmnopqrstuvwxyz1234567890"

	length = len(content)

	ser = serial.Serial(
		port='/dev/tty.usbserial-FTGXH8UA',
		#port='/dev/tty.usbserial-FTAJMAUJ', 
		baudrate=38400,
		bytesize=8, 
		parity='N', 
		stopbits=1,
		xonxoff=0, 
		rtscts=0,
		timeout=1
	)
	
	bytes = 0
	for c in content:
		bytes += ser.write(c)
		time.sleep(0.0005)

	ser.close()
	print "Bytes transferred: %d" % (bytes, )

except IndexError:
	print "%s <filename>" % (sys.argv[0],)
	sys.exit(1)
except IOError:	
	print "%s: file '%s' not found" % (sys.argv[0], filename, )
	sys.exit(1)
