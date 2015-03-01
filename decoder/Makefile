all: decoder.jed romram.bin test.bin

clean:
	rm -f *.jed *.fus *.chp *.pin *.bin *.label

%.jed: %.pld
	galasm $<

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: romram.bin
	../transfer.py romram.bin 0x1000
	
