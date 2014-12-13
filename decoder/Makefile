all: decoder.jed romram.bin

clean:
	rm -f *.jed *.fus *.chp *.pin *.bin *.label

%.jed: %.pld
	galasm $<

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: romram.bin
	../transfer.py romram.bin 0x1000
	
