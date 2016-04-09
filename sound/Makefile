SONGS=dn2_1.bin	dn2_2.bin prowla.bin alienate.bin pacman.bin

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

all: soundtest.bin synth.bin imfplayer.bin $(SONGS)
#all: $(SONGS)

pacman.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Dpacman=1 -o $@ $<
alienate.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Dalienate=1 -o $@ $<
prowla.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Dprowla=1 -o $@ $<
dn2_1.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Ddn2_1=1 -o $@ $<
dn2_2.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Ddn2_2=1 -o $@ $<

clean:
	rm -f *.bin
transfer: all
	../transfer.py synth.bin
#	../transfer.py soundtest.bin
#	../transfer.py dro_player.bin 0x1000
#	../transfer.py imfplayer.bin 0x1000
