all: lib
clean:
	rm -f *.o

lib: crt0.o cputc.o cgetc.o gotoxy.o spi.o
	ar65 a stecki.lib crt0.o cputc.o cgetc.o gotoxy.o spi.o
    
    
%.o: %.s
	ca65 -t none --cpu 65c02 -o $@ $(@:.o=.s)

