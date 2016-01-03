all: lib
clean:
	rm -f *.o

lib: crt0.o
	ar65 a stecki.lib crt0.o
    
%.o: %.s
	ca65 --cpu 65c02 $<

