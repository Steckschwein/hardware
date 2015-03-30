all: loader.bin shell.bin
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<
loader.bin: shell.bin
transfer: all
	../transfer.py loader.bin 0x1000

#	../transfer.py shell.bin 0xd000
