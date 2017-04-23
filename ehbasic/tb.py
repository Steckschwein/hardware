#!/usr/bin/python

import argparse
import serial
import sys
import os
import struct
import time


import serial.tools.list_ports
def main():
	ports = list(serial.tools.list_ports.grep("^/dev/cu.usbserial*|/dev/tty*"))

	device = None
	if device == None and len(ports)>0:
		try:
			device = ports[0][0]
		except KeyError:
			pass		
		
	if device == None:
		try:
			device = os.environ['TRANSFER_DEVICE']
		except KeyError:
			pass

	parser = argparse.ArgumentParser(description='transfer binary via serial interface')
	parser.add_argument('-d', '--device', help="serial device. can also be set with environment variable TRANSFER_DEVICE.", required=(device==None), default=device)
	parser.add_argument('-b', '--baudrate', type=int, help="baud rate. default 115200", required=False, default=115200)
	parser.add_argument('filename', help="file to transfer")

	args = parser.parse_args()


	try:
		with open(args.filename, 'r') as content_file:
			content = content_file.readlines()

	except IOError:	
		print "%s: file '%s' not found" % (sys.argv[0], args.filename, )
		sys.exit(1)


	try:
		ser = serial.Serial(
			port=args.device,
			baudrate=args.baudrate,
			bytesize=8, 
			parity=serial.PARITY_NONE, 
			stopbits=1,
			xonxoff=0, 
			rtscts=0,
			timeout=5
		)
	except serial.serialutil.SerialException:
		print "Error opening serial device %s" % (args.device, )
		sys.exit(1)
		

	ser.flushOutput()

	content = [x.strip() for x in content] 

	for line in content:
		ser.write(line)
		ser.write("\r\n")
		time.sleep(0.3)
		print line
	ser.close()

if __name__ == "__main__":
    main()

