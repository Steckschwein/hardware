#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <errno.h> 

int main(int argc, char *argv[])
{
    FILE *f1;
    char c;
    unsigned int i;
    if (argc < 2) {
        return EXIT_FAILURE;
    }
    f1 = fopen(argv[1], "rb");
    if (! f1) {
        cprintf("could not open '%s': %s\n", argv[1], strerror(errno)); 
        return EXIT_FAILURE;
    }
    cprintf("file '%s' opened successfully fs='%d'\n", argv[1], f1);
    
    i = fclose(f1);
    cprintf("file closed %d\n", i);
    
    return EXIT_SUCCESS;
    
    if (feof(f1)) {
        cprintf("end of file reached..., read %d bytes\n", i);
        return EXIT_SUCCESS;
    }
    c = fgetc(f1);
    cprintf("read char %x\n", c);
    
    return EXIT_SUCCESS;
}  