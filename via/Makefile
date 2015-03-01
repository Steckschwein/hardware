all: via.bin

%.bin: %.a
	acme -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py via.bin 0x1000

clean:
	rm *.bin 
