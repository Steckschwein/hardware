#include <stdio.h>
#include <stdlib.h>
#include <conio.h> 

int main (int argc, const char* argv[])
{
    unsigned char i;

    cprintf("\n\r");
    cprintf("argc: %d\n\r", argc);
    
    for(i=0;i<argc;i++)
        cprintf("argv[%d]: %s\n\r", i, argv[i]);
    
    return EXIT_SUCCESS;
}