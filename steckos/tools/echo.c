#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

int main (int argc, const char* argv[])
{
	int i;
	for(i=1;i<argc;i++)
		cprintf("%s ", argv[i]);
	cprintf("\n");

    return EXIT_SUCCESS;
}
