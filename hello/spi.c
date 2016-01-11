#include <conio.h>  
#include "../cc65/spi.h"

int main ()
{
	unsigned char c;
	
	while(1)
	{
		*(unsigned char*) 0x210 = 0x7a;
		c = spi_read();
		*(unsigned char*) 0x210 = 0x7e;

		cprintf("%x\n", c);
	}
	
	return 0;
}
