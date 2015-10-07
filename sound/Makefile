SONGS=prowla.bin dn2_1.bin dn2_2.bin setup.bin imfplay.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

all: soundtest.bin synth.bin  #$(SONGS)

prowla.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Dprowla=1 -o $@ $<
dn2_1.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Ddn2_1=1 -o $@ $<
dn2_2.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Ddn2_2=1 -o $@ $<
setup.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Dsetup=1 -o $@ $<
imfplay.bin: dro_player.a
	acme -v -f plain --cpu 65c02 -Dimfplay=1 -o $@ $<

clean:
	rm -f *.bin
transfer: all
	../transfer.py soundtest.bin
#	../transfer.py dro_player.bin 0x1000
#	../transfer.py imfplayer.bin 0x1000
