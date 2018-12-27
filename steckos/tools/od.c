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
	unsigned char *format = "%c ";
	for(i=1;i<argc;i++){
		if(strncmp(argv[i], "-x", 2) == 0){
			format = "%02x ";
			break;
		}else if(strncmp(argv[i], "-c", 2) == 0){
			format = "%c ";
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
				cprintf(format, buffer[CHARS-p]);
			cprintf("\n");
		}
	}
    return EXIT_SUCCESS;
}
