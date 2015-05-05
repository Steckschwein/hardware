all: name.bin
clean:
	rm -f *.bin 

%.bin: %.a ../lib/defs.h.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py name.bin 
