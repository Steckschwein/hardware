all: loader.bin shell.bin
clean:
	rm -f *.bin 

%.bin: %.a %.textui.a
	acme -v -f plain --cpu 65c02 -o $@ $<
shell.bin: ../fat/fat.a
loader.bin: shell.bin
transfer: shell.bin
	../transfer.py shell.bin 0xd000
loader: loader.bin
	sudo mcopy loader.bin a:
	sudo mattrib +s a:loader.bin
