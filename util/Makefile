all: strcmp.test.bin
clean:
	rm -f *.bin 

%.bin: %.a ../lib/defs.h.a
	acme -v -f plain --cpu 65c02 -o $@ $<

test: all
	../transfer.py strcmp.test.bin -s 0x1000
