all: dro_player.bin

clean:
	rm -f *.bin

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
#	../transfer.py soundtest.bin 0x0801
	../transfer.py dro_player.bin 0x1000
