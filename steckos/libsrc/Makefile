#CC65_HOME=/development/cc65
ASM_INCLUDE=../asminc

all: kernel-lib gfx-lib

clean:
	rm -f *.o

# TODO design fdtable.o 
kernel-lib: crt0.o mainargs.o cputc.o cgetc.o gotoxy.o clrscr.o kbhit.o spi.o rtc.o sysuname.o systime.o oserror.o open.o read.o close.o inviocb.o do_oserr.o sysremove.o sysrename.o closedir.o write.o dir.o seekdir.o rewinddir.o telldir.o opendir.o initcwd.o
	ar65 a ../lib/steckschwein-kernel.lib crt0.o cputc.o cgetc.o gotoxy.o clrscr.o spi.o rtc.o kbhit.o mainargs.o sysuname.o systime.o oserror.o open.o read.o close.o inviocb.o do_oserr.o sysremove.o sysrename.o closedir.o write.o dir.o seekdir.o rewinddir.o telldir.o opendir.o initcwd.o

%.o: %.c
	cc65 --cpu 65c02 -O $<
	ca65 --cpu 65c02 --include-dir $(ASM_INCLUDE) $(@:.o=.s)
    
#%.o: %.asm
#	ca65 --include-dir $(ASM_INCLUDE) $(@:.o=.asm)

gfx-lib: zeropage.o t99xx/t99xx.o t99xx/mode2.o t99xx/mode1.o
	ar65 a ../lib/steckschwein-gfx.lib zeropage.o t99xx/t99xx.o t99xx/mode2.o t99xx/mode1.o
	
%.o: %.s ../kernel/kernel_jumptable.inc
	ca65 -t none --cpu 65c02 --include-dir $(ASM_INCLUDE) -o $@ $(@:.o=.s)