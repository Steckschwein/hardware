all: lib
clean:
	rm -f *.o

lib: crt0.o cputc.o cgetc.o gotoxy.o clrscr.o
	ar65 a steckschwein-kernel.lib crt0.o cputc.o cgetc.o gotoxy.o clrscr.o
    
%.o: %.s
	ca65 -t none --cpu 65c02 -o $@ $(@:.o=.s)

