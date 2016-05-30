#SONGS=dn2_1.bin	dn2_2.bin prowla.bin alienate.bin pacman.bin

%.bin: %.a
	acme -vv -f plain --cpu 65c02 -o $@ $<

all: soundtest.bin synth.bin imfplayer.bin 
#all: $(SONGS)

clean:
	rm -f *.bin
soundtest: soundtest.bin
	../transfer.py soundtest.bin

synth: synth.bin
	../transfer.py synth.bin    
    
imfplayer: imfplayer.bin
	../transfer.py imfplayer.bin    

dro_player: dro_player.bin
	../transfer.py dro_player.bin
    
transfer: all
#	../transfer.py synth.bin
#	../transfer.py soundtest.bin
	../transfer.py imfplayer.bin 
