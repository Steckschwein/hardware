all: FIG65.bin fig6502.bin
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py FIG65.bin 0x0400
#	../transfer.py fig6502.bin 0x0400
