#include <conio.h>  
#include <stdlib.h>  
#include "../../cc65/spi.h"

/*
param_sig	= $00 ; 1  byte  - parameter array signature byte. must be $42
param_version	= $01 ; 1  byte  - version number. initially zero
param_filename	= $02 ; 11 bytes - file to boot. example "LOADER  BIN"
param_baud	= $0d ; 1  byte  - baudrate divisor value, entry# from .uart_divisor, default 15 (9600 baud)    
param_lsr       = $0e ; 1  byte  - uart lcr value , default %00000011 (8N1)
param_checksum  = $5f ; checksum
*/

struct nvram 
{
	unsigned char signature;
	unsigned char version;
	unsigned char filename[11];
	unsigned char uart_baudrate;
	unsigned char uart_lsr;
};
int main ()
{
	unsigned char c,i;
	struct nvram n;
	

	unsigned long baudrates[20] = {
	-1,
	50,	
	75,
	110,	
	134,
	150,
	300,
	600,
	1200,
	1800,	
	2000,	
	2400,	
	3600,
	4800,
	7200,	
	9600,	
	19200,
	38400,	
	56000,	
	115200
	};

	unsigned char *x = "115200";
	unsigned char * p;

	unsigned long l;

	l = atol(x);
	for (i = 1;i<=19;i++)
	{
		if (l == baudrates[i])
			break;
	}

	cprintf("\r\n%d\r\n", i);

	
	while(1) {}
	p = (unsigned char *)&n;




	// *(unsigned char*) 0x210 = 0x76; // select NVRAM
	// c = spi_write(0xA0);
	// c = spi_write(0x42);

	// *(unsigned char*) 0x210 = 0x7e;

	*(unsigned char*) 0x210 = 0x76; // select NVRAM

	c = spi_write(0x20);
	

	for(i = 0; i<=sizeof(n); i++)
	{
		*p++ = spi_read();
	}
	
	*(unsigned char*) 0x210 = 0x7e;
	cprintf("\r\n");
	cprintf("Signature  : $%02x\r\n", n.signature);
	cprintf("Version    : $%02x\r\n", n.version);
	cprintf("OS filename: %s\r\n", n.filename);
	cprintf("Baud rate  : %lu\r\n", baudrates[n.uart_baudrate % 20]);
	cprintf("UART LSR   : $%02x\r\n", n.uart_lsr);


	


	
	
	return 0;
}