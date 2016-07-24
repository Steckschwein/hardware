all: lib
clean:
	rm -f *.o

# TODO design fdtable.o 
lib: crt0.o mainargs.o cputc.o cgetc.o gotoxy.o clrscr.o kbhit.o spi.o rtc.o sysuname.o systime.o oserror.o open.o read.o close.o inviocb.o do_oserr.o
	ar65 a ../lib/steckschwein-kernel.lib crt0.o cputc.o cgetc.o gotoxy.o clrscr.o spi.o rtc.o kbhit.o mainargs.o sysuname.o systime.o oserror.o open.o read.o close.o inviocb.o do_oserr.o    
    
%.o: %.s ${ACME}/*.inc
	ca65 -t none --cpu 65c02 -o $@ $(@:.o=.s)