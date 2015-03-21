all: microchess.bin
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py microchess.bin 0x0400
