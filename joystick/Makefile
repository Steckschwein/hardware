all: joystick.bin
clean:
	rm -f *.bin 

joystick.bin: joystick.asm
	cl65 --target none  --config ../steckos/kernel/steckos.cfg joystick.asm -o joystick.bin

transfer: all
	../transfer.py joystick.bin
