all: nvram.bin
clean:
	rm -f *.bin *.labels

%.bin: %.a ${ACME}/defs.h.a ${ACME}/params.h.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py nvram.bin 
