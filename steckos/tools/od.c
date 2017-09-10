#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h> 

static unsigned char CHARS = 16;
int main (int argc, const char* argv[])
{
	unsigned char buffer[200];
	char c;
	unsigned int i;
	unsigned char p;
	for(i=1;i<argc;i++){
		if(strcmp(argv[i], "-x")){
			break;
		}else if(strcmp(argv[i], "-c")){
			break;
		}
	}	
	i=0;
	p=0;
	while((c = cgetc()) != 0x1b){
		cprintf("%c", c);
		buffer[p++] = c;
		if(p % CHARS == 0){
			i+=CHARS;
			cprintf("\n%08x ", i);
			for(;p>0;p--)
				cprintf("%c", buffer[CHARS-p]);
			cprintf("\n");
		}
	}
    return EXIT_SUCCESS;
}