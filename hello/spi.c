#include <stdio.h>
#include "../cc65/spi.h"

main ()
{
	char c;
	while(1)
	{
		*(unsigned char*) 0x210 = 0x7A;
		c = spi_read();
		*(unsigned char*) 0x210 = 0x7E;

		cprintf("%x\n", c);
	}
}
