all: lib
clean:
	rm -f *.o

lib: crt0.o mainargs.o cputc.o cgetc.o gotoxy.o clrscr.o kbhit.o spi.o sysuname.o systime.o oserror.o
	ar65 a steckschwein-kernel.lib crt0.o cputc.o cgetc.o gotoxy.o clrscr.o spi.o kbhit.o mainargs.o sysuname.o systime.o oserror.o
    
%.o: %.s ${ACME}/*.inc
	ca65 -t none --cpu 65c02 -o $@ $(@:.o=.s)