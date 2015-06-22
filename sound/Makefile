SONGS=prowla.bin dn2_1.bin dn2_2.bin

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

all: soundtest.bin $(SONGS)

prowla.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Dprowla=1 -o $@ $<
dn2_1.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Ddn2_1=1 -o $@ $<
dn2_2.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Ddn2_2=1 -o $@ $<

clean:
	rm -f *.bin
transfer: all
#	../transfer.py soundtest.bin 0x0801
#	../transfer.py dro_player.bin 0x1000
	../transfer.py imfplayer.bin 0x1000
