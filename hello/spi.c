#include <stdio.h>
#include "../cc65/spi.h"

main ()
{
	char c;
	while(1)
	{
		*(unsigned char*) 0x210 = 0b01111010;
		c = spi_read();
		*(unsigned char*) 0x210 = 0b01111110;

		cprintf("%x\n", c);
	}
}
