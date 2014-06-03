all: test.bin avr
clean:
	rm -f *.bin *.labels
	( cd avr-keyboard-interface/software ; make clean )

avr:
	( cd avr-keyboard-interface/software ; make )
%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py test.bin 
