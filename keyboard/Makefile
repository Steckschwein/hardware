all: test.bin avr
clean:
	rm -f *.bin *.labels
	( cd avr ; make clean )

avr:
	( cd avr ; make )
%.bin: %.a ../bios/defs.h.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py test.bin 
