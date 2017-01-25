#include <stdlib.h>
#include <conio.h> 

int main (){
	
	unsigned char msg[] = "Hello World!\n";
	unsigned short i;
	for(;;)
		//for(i=0;i<sizeof(msg);i++)
		//	cputc(msg[i]);
		cprintf("Hello World!\n");
	
	return EXIT_SUCCESS;
}