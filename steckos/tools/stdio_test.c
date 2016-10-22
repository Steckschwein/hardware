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
    unsigned int n;
    unsigned char buf[32];
    
    if (argc < 2) {
        return EXIT_FAILURE;
    }
    cprintf("\n");
    f1 = fopen(argv[1], "rb");
    if (! f1) {
        cprintf("could not open '%s': %s\n", argv[1], strerror(errno)); 
        return EXIT_FAILURE;
    }
    cprintf("file '%s' opened fd='%d'\n\r", argv[1], f1);
    i = fread(buf, sizeof(char), sizeof(buf), f1);
    cprintf("read %d\n\r", i);
    for(n=0;n<i && n<16;n++){
        cprintf("$%x ", buf[n]);
    }
    cprintf("\n\r");
    if (feof(f1)) {
        cprintf("end of file reached..., read %d bytes\n", i);
        return EXIT_SUCCESS;
    }
    i = fclose(f1);
    cprintf("file closed %d\n\r", i);
    
    return EXIT_SUCCESS;
}  