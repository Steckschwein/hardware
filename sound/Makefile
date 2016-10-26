
%.bin: %.a
	acme -vv -f plain --cpu 65c02 -o $@ $<

all: imfplayer.bin 

clean:
	rm -f *.bin
soundtest: soundtest.bin
	../transfer.py soundtest.bin

synth: synth.bin
	../transfer.py synth.bin    
    
imfplayer: imfplayer.bin
	../transfer.py imfplayer.bin    

transfer: all
#	../transfer.py synth.bin
#	../transfer.py soundtest.bin
	../transfer.py imfplayer.bin 
