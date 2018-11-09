#!/usr/bin/python

import argparse
import serial
import sys
import os
import struct
import binascii


import serial.tools.list_ports

def main():
    device = None
    
    try:
        device = os.environ['TRANSFER_DEVICE']
    except KeyError:
        pass
    
    if device == None:
        ports = list(serial.tools.list_ports.grep("^/dev/cu.usbserial*|/dev/tty*"))
        if len(ports)>0:
            try:
                device = ports[0][0]
            except KeyError:
                pass

    parser = argparse.ArgumentParser(description='transfer binary via serial interface')
    parser.add_argument('-d', '--device', help="serial device. can also be set with environment variable TRANSFER_DEVICE.", required=(device==None), default=device)
    parser.add_argument('-b', '--baudrate', type=int, help="baud rate. default 115200", required=False, default=115200)
    parser.add_argument('-s', '--startaddr', help="start address. default 0x1000", required=False, default="0x1000")
    parser.add_argument('filename', help="file to transfer")

    args = parser.parse_args()
    
    try:
        with open(args.filename, 'rb') as content_file:
            content = content_file.read()
    except IOError:
        print("%s: file '%s' not found\n" % (sys.argv[0], args.filename, ))
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
        print("Error opening serial device %s" % (args.device, ))
        sys.exit(1)
        


    if (args.filename[-3:].lower() == "prg"):
        startaddr=int("%s%s" % (
            binascii.hexlify(content[1]),
            binascii.hexlify(content[0])
        ), 16)
        tmp = content[2:]
        content = tmp

    else:
        startaddr=int(args.startaddr, 16)

    length = len(content)

    print ("Startaddress : 0x%04x (%d)" % (startaddr, startaddr))
    print ("Length        : 0x%04x (%d) bytes" % (length, length))

    ser.flushOutput()

    bytes = ser.write(struct.pack('<H', startaddr))
    if ser.read(2) == 'OK':
        print ("Start address %d bytes" % (bytes, ))

    bytes = ser.write(struct.pack('<H', length))
    if ser.read(2) == 'OK':
        print ("Length %d bytes" % (bytes, ))
            
    bytes = ser.write(content)
    if ser.read(2) == 'OK':
        print ("Length %d bytes" % (bytes, ))
        print ("Bytes transferred: %d" % (bytes, ))

    ser.close()

if __name__ == "__main__":
    main()

