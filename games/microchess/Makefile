all: microchess.bin mchess_serial.bin
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../../transfer.py mchess_serial.bin 0x1000
