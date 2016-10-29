
%.bin: %.asm
	cl65 --target none  --config ../steckos/kernel/steckos.cfg -o $@ $<

all: imfplayer.bin 

clean:
	rm -f *.bin
imfplayer: imfplayer.bin
	../transfer.py imfplayer.bin    

