all: invaders.bin

clean:
	rm -f *.bin *.labels

%.bin:	%.a ${ACME}/t9929.h.a ${ACME}/*.lib.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py invaders.bin	