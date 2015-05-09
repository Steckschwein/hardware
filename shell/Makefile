DEPS=*.raw *.h.a  shell.textui.a shell.gfxui.a ${ACME}/fat.a ${ACME}/t99xx.lib.a ${ACME}/t9929.h.a
all: loader.bin shell.bin
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<
%.raw: %.xpm
	sh xpm2acme.sh $< > $<.raw
assets: sanduhr.raw sanduhr_45.raw sanduhr_90.raw sanduhr_135.raw sanduhr_180.raw sanduhr_225.raw sanduhr_270.raw sanduhr_315.raw
shell.bin: $(DEPS)
loader.bin: shell.bin
transfer: shell.bin
	../transfer.py shell.bin 0xc800
loader: loader.bin
	sudo mcopy loader.bin a:
	sudo mattrib +s a:loader.bin
