all: avr
clean:
	rm -f *.bin *.labels
	( cd avr313 ; make clean )

avr:
	( cd avr313 ; make  )

%.bin: %.a ../lib/defs.h.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py test.bin 
