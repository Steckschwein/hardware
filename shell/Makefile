all: loader.bin shell.bin
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<
shell.bin: *.h.a ../fat/fat.a ../lib/*.a shell.textui.a ../vdp/t99xx.lib.a ../vdp/*.h.a
loader.bin: shell.bin
transfer: shell.bin
	../transfer.py shell.bin 0xd000
loader: loader.bin
	sudo mcopy loader.bin a:
	sudo mattrib +s a:loader.bin
