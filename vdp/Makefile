all: vdp

clean:
	rm -f *.bin
	
vdp: vramtest.bin t9929.bin

# !!! we have to explicitly list the %.h.a dependency, otherwise changes within the .h.a file are not detected by make
%.bin: %.a *.h.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py t9929.bin 0x1000
#	../transfer.py vramtest.bin 0x1000
