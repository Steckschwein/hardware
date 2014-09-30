all: decoder.jed test.bin romram.bin

clean:
	rm -f *.jed *.fus *.chp *.pin *.bin *.label

%.jed: %.pld
	galasm $<

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: test.bin
	../transfer.py romram.bin 0x1000