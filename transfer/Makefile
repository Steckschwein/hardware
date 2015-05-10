all: transfer.o
	gcc -Os -o transfer transfer.o

transfer.o: transfer.c
	gcc -c transfer.c

clean:
	rm *.o transfer
