all: 1bir

clean:
	rm -f *.bin
	
1bir: 1bir.bin

%.bin: %.a ${ACME}/t9929.h.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py 1bir.bin 0x1000
