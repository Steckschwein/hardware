all: demo.bin 
clean:
	rm -f *.bin *.labels
	
%.bin: %.a ${ACME}/t9929.h.a ${ACME}/t99xx.lib.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py demo.bin	
#	../transfer.py sprites.bin	0x1000
