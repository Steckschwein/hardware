all: soundtest.bin

clean:
	rm -f *.bin

%.bin: %.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
#	../transfer.py soundtest.bin 0x0801
	../transfer.py dro_player.org.bin 0x1000
