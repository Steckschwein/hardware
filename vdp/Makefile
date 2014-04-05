all: vdp

clean:
	rm *.bin
	
vdp: t9929.bin

%.bin: %.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py t9929.bin 0x1000