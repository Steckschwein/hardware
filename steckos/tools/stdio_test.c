#include <stdlib.h>
#include <stdio.h>
#include <conio.h>

int main(int argc, char *argv[])
{
    FILE *f1;
    char c;
    unsigned int i;
    if (argc < 3) {
        return EXIT_FAILURE;
    }
    f1 = fopen(argv[1], "rb");
    if (f1 == NULL) {
        cprintf("could not open file!");
        return EXIT_FAILURE;
    }
    for(;;) {
        if (feof(f1)) {
            cprintf("end of file reached..., read %d bytes", i);
            return EXIT_SUCCESS;
        }
        c = fgetc(f1);
        i++;
    }
}  