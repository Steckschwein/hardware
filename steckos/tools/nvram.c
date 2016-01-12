#include <conio.h>  
#include <stdlib.h>  
#include <string.h>  
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

unsigned char c,i;
struct nvram n;
unsigned char * p;



void write_nvram()
{
	p = (unsigned char *)&n;
	*(unsigned char*) 0x210 = 0x76; // select NVRAM

	spi_write(0xA0);

	for(i = 0; i<=sizeof(n); i++)
	{
		spi_write(*p++);
	}

	*(unsigned char*) 0x210 = 0x7e;
}

void read_nvram()
{	
	p = (unsigned char *)&n;
	*(unsigned char*) 0x210 = 0x76; // select NVRAM

	spi_write(0x20);
	

	for(i = 0; i<=sizeof(n); i++)
	{
		*p++ = spi_read();
	}
	
	*(unsigned char*) 0x210 = 0x7e;

}


int main ()
{
	
	unsigned char * fname = "loader.bin";
	unsigned char * baud  = "115200";

	unsigned long baudrates[] = {
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

	// unsigned char *x = "115200";
	

	unsigned long l;
	read_nvram();


	l = atol(baud);

	for (i = 1;i<=19;i++)
	{
		if (l == baudrates[i]) break;
	}

	if (i > 19)
	{
		cprintf("\r\nInvalid baudrate\r\n");
		return 1;
	}


	n.signature 	= 0x42;
	n.version 		= 0;
	strcpy(n.filename, fname);
	
	n.uart_baudrate = i;
	n.uart_lsr		= 0x03;
	



	

	cprintf("\r\n");
	cprintf("Signature  : $%02x\r\n", n.signature);
	cprintf("Version    : $%02x\r\n", n.version);
	cprintf("OS filename: %s\r\n", n.filename);
	cprintf("Baud rate  : %lu\r\n", baudrates[n.uart_baudrate % 20]);
	cprintf("UART LSR   : $%02x\r\n", n.uart_lsr);

	write_nvram();
	read_nvram();

	cprintf("\r\n");
	cprintf("Signature  : $%02x\r\n", n.signature);
	cprintf("Version    : $%02x\r\n", n.version);
	cprintf("OS filename: %s\r\n", n.filename);
	cprintf("Baud rate  : %lu\r\n", baudrates[n.uart_baudrate % 20]);
	cprintf("UART LSR   : $%02x\r\n", n.uart_lsr);


	return 0;
}